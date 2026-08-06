#!/bin/bash

set -ouex pipefail

# Copia eventuali file personalizzati
cp -avf "/ctx/system_files"/. /

# Abilita il repository Mesa Git
dnf5 -y copr enable xxmitsu/mesa-git

# Aggiorna tutto lo stack Mesa
dnf5 -y distro-sync --refresh --allowerasing

# Disabilita il repository dopo l'installazione
dnf5 -y copr disable xxmitsu/mesa-git

# Mostra le versioni installate durante la build
rpm -qa | grep '^mesa' | sort

# Mantiene il servizio previsto dal template
systemctl enable podman.socket
