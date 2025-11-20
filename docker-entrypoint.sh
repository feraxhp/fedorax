#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------------------
# Variables de entorno que se esperan
#   USER_NAME   – nombre del usuario a crear
#   USER_PASS   – contraseña (texto plano)
#   USER_SUDO   – "true" si quieres sudo sin password
# ------------------------------------------------------------------
USER_NAME=${USER_NAME:-}
USER_PASS=${USER_PASS:-}
USER_SUDO=${USER_SUDO:-false}

# ------------------------------------------------------------------
# 1️⃣ Creamos el usuario (si no existe) y configuramos sudo
# ------------------------------------------------------------------
if [[ -z "$USER_NAME" || -z "$USER_PASS" ]]; then
    echo "⚠️  USER_NAME y USER_PASS son obligatorios. Saliendo."
    exit 1
fi

if ! id "$USER_NAME" &>/dev/null; then
    echo "🛠️  Creando usuario $USER_NAME ..."
    useradd -m -s /bin/bash "$USER_NAME"
    echo "$USER_NAME:$USER_PASS" | chpasswd

    if [[ "$USER_SUDO" == "true" ]]; then
        echo "✅  Añadiendo $USER_NAME a sudoers (sin password)"
        echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USER_NAME"
        chmod 0440 "/etc/sudoers.d/$USER_NAME"
    fi
else
    echo "👋  El usuario $USER_NAME ya existe."
fi



# ------------------------------------------------------------------
# 2️⃣ Configuramos OpenSSH
# ------------------------------------------------------------------
# 2.1. Habilitamos la autenticación por contraseña
#      (y deshabilitamos root para mayor seguridad)
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
# 2.2. Permitimos la autenticación pública por si alguien
#      quiere usar claves (opcional)
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# 2.3. Si el usuario necesita acceso a su propio .ssh, lo creamos
SSH_DIR="/home/$USER_NAME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USER_NAME:$USER_NAME" "$SSH_DIR"

# 2.4. Generamos claves de host si no existen
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "🔑  Generando claves de host..."
    ssh-keygen -A
fi


# ------------------------------------------------------------------
# 3️⃣ Descargar .fx (y demás configuraciones)
# ------------------------------------------------------------------
echo "🔧  Descargando .fx ..."
# Si quieres que el clon se haga como el usuario creado:
if [[ -d /home/$USER_NAME/.fx ]]; then
    echo "El directorio (.fx) ya existe"
else
    sudo -u "$USER_NAME" git clone https://github.com/feraxcf/.fx /home/$USER_NAME/.fx
    
    sudo -u "$USER_NAME" mkdir -p /home/$USER_NAME/.config/
    
    chown -R "$USER_NAME:$USER_NAME" /data/cprojects
    chown -R "$USER_NAME:$USER_NAME" /data/girep
    
    sudo -u "$USER_NAME" ln -s /data/girep /home/$USER_NAME/.config/girep
    sudo -u "$USER_NAME" ln -s /data/cprojects /home/$USER_NAME/projects
    
    sudo -u "$USER_NAME" /home/$USER_NAME/.fx/config.bash
fi

# ------------------------------------------------------------------
# 3️⃣ Iniciamos sshd en segundo plano
# ------------------------------------------------------------------
echo "🚀  Iniciando sshd ..."
#   -D significa "daemonize" (se queda en foreground)
#   -e significa "redirect logs to stderr"
exec /usr/sbin/sshd -D -e

