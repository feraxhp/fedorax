FROM fedora:43
LABEL maintainer="https://github.com/feraxhp"

RUN dnf update -y && \
    dnf install -y \
        openssh-server \
        openssl-devel \
        passwd \
        git && \
    dnf clean all

RUN dnf install -y @development-tools rust cargo && \
    dnf clean all

RUN dnf install -y msedit jq zip btop bat && \
    dnf clean all

RUN cargo install eza

RUN curl -sS https://starship.rs/install.sh -o /tmp/st.sh && \
    chmod +x /tmp/st.sh && \
    /tmp/st.sh --yes && \
    rm -f /tmp/st.sh

RUN echo "-> Installing grp" && \
    version_name=$(curl -s "https://api.github.com/repos/feraxhp/grp/releases/latest" | jq -r '.name') && \
    nversion=$(echo "$version_name" | cut -d'v' -f2) && \
    echo "$nversion" && \
    dnf install -y "https://github.com/feraxhp/grp/releases/download/$version_name/grp-$nversion-1.x86_64.rpm" && \
    echo "-> Installing cim" && \
    version_name=$(curl -s "https://api.github.com/repos/feraxhp/cim/releases/latest" | jq -r '.name') && \
    nversion=$(echo "$version_name" | cut -d'v' -f2) && \
    dnf install -y "https://github.com/feraxhp/cim/releases/download/$version_name/cim-$nversion-1.x86_64.rpm"

RUN mkdir -p /data/{cprojects,girep}

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
