FROM gitpod/openvscode-server:latest

LABEL org.opencontainers.image.source="https://github.com/stack4ops/code"
LABEL org.opencontainers.image.description="openvscode-server"
LABEL org.opencontainers.image.licenses="Apache-2.0"

ARG TARGETARCH
ARG USERNAME=www-data
ARG USER_UID=33
ARG USER_GID=33

# ---- User / ENV ----
USER root
ENV USERNAME=${USERNAME}
ENV HOME=/home/${USERNAME}
ENV WORKSPACE=${HOME}/workspace
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin
ENV OPENVSCODE_SERVER_ROOT=${HOME}/.openvscode-server
ENV OPENVSCODE=${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server

# ---- Base packages ----
RUN <<'EOF'
set -e

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  jq \
  tzdata \
  unzip

rm -rf /var/lib/apt/lists/*

ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone
EOF


# ---- User setup ----
RUN <<'EOF'
set -e

userdel -f ${USERNAME} 2>/dev/null || true

groupadd --gid ${USER_GID} ${USERNAME}
useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME}

mkdir -p ${HOME}
mkdir -p ${WORKSPACE}

echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}
chmod 0440 /etc/sudoers.d/${USERNAME}

EOF


# ---- Install latest OpenVSCode Server ----
RUN <<'EOF'
set -e

case "$TARGETARCH" in
  amd64) ARCH="x64" ;;
  arm64) ARCH="arm64" ;;
  *) echo "Unsupported TARGETARCH: $TARGETARCH"; exit 1 ;;
esac

LATEST=$(curl -fsSL https://api.github.com/repos/gitpod-io/openvscode-server/releases/latest | jq -r .tag_name)

curl -fsSL \
  https://github.com/gitpod-io/openvscode-server/releases/download/${LATEST}/${LATEST}-linux-${ARCH}.tar.gz \
  -o /tmp/openvscode-server.tar.gz

rm -rf ${OPENVSCODE_SERVER_ROOT}
mkdir -p ${OPENVSCODE_SERVER_ROOT}

tar -xzf /tmp/openvscode-server.tar.gz -C ${OPENVSCODE_SERVER_ROOT} --strip-components=1
rm /tmp/openvscode-server.tar.gz

chmod g+rw ${HOME}
chown -R ${USERNAME}:${USERNAME} ${HOME}

EOF

# ---- Prepare Extensions Directory (no installation in build) ----
# RUN <<'EOF'
# set -e
# mkdir -p ${HOME}/.openvscode-server/extensions
# chown -R ${USERNAME}:${USERNAME} ${HOME}/.openvscode-server/extensions
# EOF

USER ${USERNAME}

# Hinweis:
# Extensions können jetzt **manuell im Container** installiert werden:
# ${OPENVSCODE} --install-extension GitHub.copilot
# ${OPENVSCODE} --install-extension GitHub.copilot-chat
# ${OPENVSCODE} --install-extension ClaudeAI.claude