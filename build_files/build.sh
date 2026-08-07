#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

# Rimuove il blocco Bazzite sulla versione di Mesa
dnf5 versionlock delete 'mesa-*' || true

# Abilita Mesa Git
dnf5 -y copr enable xxmitsu/mesa-git

# Installa/sincronizza Mesa Git ignorando le esclusioni di Bazzite
dnf5 -y \
    --setopt=disable_excludes='*' \
    distro-sync \
    --refresh \
    --allowerasing \
    'mesa-*'

# Blocca la versione Mesa installata nell'immagine
dnf5 versionlock add 'mesa-*'

# Disabilita il COPR Mesa Git nell'immagine finale
dnf5 -y copr disable xxmitsu/mesa-git

# Verifica versioni Mesa
rpm -qa | grep '^mesa' | sort

# Disabilita terra-mesa tramite override DNF
dnf5 -y config-manager setopt terra-mesa.enabled=0 || true
dnf5 -y config-manager setopt terra-mesa-source.enabled=0 || true

# Disabilita anche direttamente le sezioni nel file .repo.
# bootc-image-builder può leggere direttamente questi file durante il depsolve ISO.
if [[ -f /etc/yum.repos.d/terra-mesa.repo ]]; then
    sed -i '/^\[terra-mesa\]/,/^\[/ s/^enabled=.*/enabled=0/' \
        /etc/yum.repos.d/terra-mesa.repo

    sed -i '/^\[terra-mesa-source\]/,/^\[/ s/^enabled=.*/enabled=0/' \
        /etc/yum.repos.d/terra-mesa.repo
fi

# Controllo finale dello stato dei repo Terra
dnf5 repolist --all | grep -i terra || true

systemctl enable podman.socket
