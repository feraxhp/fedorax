FROM fedora:43
LABEL maintainer="https://github.com/feraxhp"

RUN dnf update -y && \
    dnf install -y openssh-server sudo passwd git msedit jq && \
    dnf clean all

RUN curl -sS https://starship.rs/install.sh -o /tmp/st.sh && \
    chmod +x /tmp/st.sh && \
    /tmp/st.sh --yes && \
    rm -f /tmp/st.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
