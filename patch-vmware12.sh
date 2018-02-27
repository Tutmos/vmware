#!/bin/bash
#
# script for downloading and installing
# https://github.com/mkubecek/vmware-host-modules
#
# License GPL
#

CWD=$(pwd)
VMWARE_VERSION="workstation-12.5.9"
SOURCEDIR="$HOME/virtual-guests/install/vmware-host-modules"

if [ "$EUID" -ne 0 ]
  then echo "Please install as root"
  exit 1
fi

cleanup() {
    cd "$CWD"
}

install_dependencies() {
    apt-get -y install git
    clone_gitrepo
}

clone_gitrepo() {
    if [ ! -e "$SOURCEDIR" ]; then
        SOURCEDIR=$(mktemp -d)
        echo "created $SOURCEDIR"
        git clone --branch "$VMWARE_VERSION" "https://github.com/mkubecek/vmware-host-modules.git" "$SOURCEDIR"
        cd "$SOURCEDIR"
    else
        cd "$SOURCEDIR"
        git checkout $VMWARE_VERSION
    fi
}

install_vmwarepatch() {
    make tarballs
    if [ ! -e vmmon.tar ]; then
        echo something went wrong
        exit 1
    fi
    mv -f /usr/lib/vmware/modules/source/vmmon.tar /usr/lib/vmware/modules/source/vmmon_backup.tar
    mv -f /usr/lib/vmware/modules/source/vmnet.tar /usr/lib/vmware/modules/source/vmnet_backup.tar
    cp vmmon.tar vmnet.tar /usr/lib/vmware/modules/source
    vmware-modconfig --console --install-all
}

trap cleanup EXIT
install_dependencies
install_vmwarepatch