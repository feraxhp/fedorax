# Fedorax


[![Build & Publish Container](https://github.com/feraxhp/fedorax/actions/workflows/docker.yml/badge.svg)](https://github.com/feraxhp/fedorax/actions/workflows/docker.yml)

is just a simple image base on fedora linux, ready to be used as development platform.
It is meant to be use in conjuction with zed.

#### example
~~~yml
version: "3.8"
services:
  fedorax:
    image: ghcr.io/feraxhp/fedorax:latest
    ports:
      - 23:22
    environment:
      - TZ=Europe/Moscow
      - USER_NAME=feraxhp
      - USER_PASS=${USER_PASS}
      - USER_SUDO=true
    volumes:
      - cprojects:/data/cprojects  # Here comes the project dir structure projects/{p,t,j}projects/
      - girep:/data/girep          # To the feraxhp/girep comand configurations 
      - ssh:/etc/ssh               # To avoid generating a ssh-key every time
    restart: unless-stopped
    healthcheck:
      test:
        - CMD
        - bash
        - '-c'
        - "echo -n '' > /dev/tcp/localhost/22"
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
~~~
