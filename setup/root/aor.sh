#!/bin/bash

# exit script if return code != 0
set -e

# define arch official repo (aor) packages
aor_packages="nzbget"

# download and install package
#curl -L -o "/tmp/$aor_packages.tar.xz" "https://www.archlinux.org/packages/community/x86_64/$aor_packages/download/"
curl -L -o "/tmp/$aor_packages.tar.xz" "https://archive.archlinux.org/repos/2017/04/13/community/os/x86_64/nzbget-18.0-1-x86_64.pkg.tar.xz"
pacman -U "/tmp/$aor_packages.tar.xz" --noconfirm
