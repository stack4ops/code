ARG BASE_IMAGE=debian
ARG BASE_TAG=latest
ARG HTTP_PROXY=
ARG HTTPS_PROXY=
ARG http_proxy=
ARG https_proxy=

FROM ${BASE_IMAGE}:${BASE_TAG}
LABEL maintainer="Stefan Schneider <eqsoft4@gmail.com>"

ARG USERNAME=www-data
ARG USER_UID=33
ARG USER_GID=$USER_UID
# customizing for php development
ARG PHP_VERSION=8.3
ENV PHP_VERSION=$PHP_VERSION

ENV OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"
ENV OPENVSCODE="${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server"

USER root

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Europe/Berlin
SHELL ["/bin/bash", "-c"]

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
software-properties-common \
apt-transport-https
apt-add-repository ppa:ondrej/php
apt-get update
apt-get install -y --no-install-recommends \
tzdata \
curl \
openssl \
git \
php7.4 \
php8.0 \
php8.1 \
php8.2 \
php8.3
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone
update-alternatives --set php /usr/bin/php${PHP_VERSION}
apt-get update
curl --silent --show-error https://getcomposer.org/installer | php && mv ${PWD}/composer.phar /usr/bin/
ln -s /usr/bin/composer.phar /usr/bin/composer
userdel -f $USERNAME
groupadd --gid $USER_GID $USERNAME
useradd --uid $USER_UID --gid $USERNAME -m -s /bin/bash $USERNAME
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME
chmod g+rw /home
chown -R $USERNAME:$USERNAME /home/workspace
chown -R $USERNAME:$USERNAME ${OPENVSCODE_SERVER_ROOT}
EOF

# user context www-data
USER $USERNAME
ENV SHELL /bin/bash
SHELL ["/bin/bash", "-c"]
RUN \
    # Direct download links to external .vsix not available on https://open-vsx.org/
    # The two links here are just used as example, they are actually available on https://open-vsx.org/
    #urls=(\
    #    https://github.com/rust-lang/rust-analyzer/releases/download/2022-12-26/rust-analyzer-linux-x64.vsix \
    #    https://github.com/VSCodeVim/Vim/releases/download/v1.24.3/vim-1.24.3.vsix \
    #)\
    # Create a tmp dir for downloading
    #&& tdir=/tmp/exts && mkdir -p "${tdir}" && cd "${tdir}" \
    # Download via wget from $urls array.
    #&& wget "${urls[@]}" && \
    # List the extensions in this array
    exts=(\
        # From https://open-vsx.org/ registry directly
        gitpod.gitpod-theme \
        bmewburn.vscode-intelephense-client \
        #GitLab.gitlab-workflow \
        #shyykoserhiy.git-autoconfig \
        # eamodio.gitlens \
        # From filesystem, .vsix that we downloaded (using bash wildcard '*')
        #"${tdir}"/* \
    )\
    # Install the $exts
    && for ext in "${exts[@]}"; do ${OPENVSCODE} --install-extension "${ext}"; done
