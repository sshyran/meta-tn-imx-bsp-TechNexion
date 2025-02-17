#!/bin/sh
#
# i.MX Yocto Project Build Environment Setup Script
#
# Copyright (C) 2011-2016 Freescale Semiconductor
# Copyright 2018 TechNexion Ltd.
# Copyright 2017 NXP
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

. sources/meta-fsl-bsp-release/imx/tools/setup-utils.sh

CWD=`pwd`
PROGNAME="$CWD/sources/base/setup-environment"

usage ()
{
  echo -e "Usage: . $0 [build directory]"
}

if [ $? != 0 -o $# -lt 1 ]; then
  usage
  return 1
fi

while test -n "$1"; do
  case "$1" in
    "--help" | "-h")
      usage
      return 0
      ;;
    *)
      BUILDDIRECTORY=$1
    ;;
  esac
  shift
done

THIS_SCRIPT="setup-environment.sh"
if [ "$(basename -- $0)" = "${THIS_SCRIPT}" ]; then
    echo "Error: This script needs to be sourced. Please run as '. $0'"
    return 1
fi

if [ -z "$MACHINE" ]; then
  echo "Error: MACHINE environment variable not defined"
  return 1
fi

if [ -z "$DISTRO" ]; then
  echo "Error: DISTRO environment variable not defined"
  return 1
fi

# Get TechNexion MACHINE configs
TNCONFIGS=$(ls $CWD/sources/meta-tn-imx-bsp/conf/machine/*.conf | xargs -n 1 basename | grep -E -c "$MACHINE")
# Get i.MX MACHINE configs
FSLCONFIGS=$(ls $CWD/sources/meta-fsl-bsp-release/imx/meta-bsp/conf/machine/*.conf $CWD/sources/meta-freescale*/conf/machine/*.conf | xargs -n 1 basename | grep -E -c "$MACHINE")
# Set up the basic yocto environment by sourcing fsl community's setup-environment bash script with/without TEMPLATECONF
if [ $TNCONFIGS -gt 0 ] ; then
  echo "Setup TechNexion Yocto"
  echo "    TEMPLATECONF=$CWD/sources/meta-tn-imx-bsp/conf MACHINE=$MACHINE DISTRO=$DISTRO source $PROGNAME $BUILDDIRECTORY"
  echo ""
  TEMPLATECONF="$CWD/sources/meta-tn-imx-bsp/conf" MACHINE=$MACHINE DISTRO=$DISTRO source $PROGNAME $BUILDDIRECTORY
elif [ $FSLCONFIGS -gt 0 ]; then
  echo "Setup Freescale/i.MX Yocto"
  echo "    MACHINE=$MACHINE DISTRO=$DISTRO source $PROGNAME $BUILDDIRECTORY"
  echo ""
  MACHINE=$MACHINE DISTRO=$DISTRO source $PROGNAME $BUILDDIRECTORY
else
  echo "Setup OpenEmbedded Yocto"
  echo "    MACHINE=$MACHINE source $PROGNAME $BUILDDIRECTORY"
  echo ""
  MACHINE=$MACHINE source $PROGRAME $BUILDDIRECTORY
fi

#
# For some reason, our modified original bblayers.conf.sample are replaced by
# FSL community's base/conf/bblayer.conf
# So workaround by appending additional layers
#
echo -e "\nTechNexion setup-environment.sh wrapper: Further modification to bblayers.conf and local.conf"
if [ $TNCONFIGS -gt 0 -o $FSLCONFIGS -gt 0 ]; then
  if [ -d $PWD/../sources/meta-fsl-bsp-release ]; then
    # copy new EULA into community so setup uses latest i.MX EULA
    cp $PWD/../sources/meta-fsl-bsp-release/imx/EULA.txt $PWD/../sources/meta-freescale/EULA
    if ! grep -Fq "meta-fsl-bsp-release" $PWD/conf/bblayers.conf; then
      # add freescale bsp layers to bblayers.conf
      echo "" >> $PWD/conf/bblayers.conf
      echo "# setup Freescale i.MX Yocto Project Release layers in bblayers.conf" | tee -a $PWD/conf/bblayers.conf
      hook_in_layer meta-fsl-bsp-release/imx/meta-bsp
      hook_in_layer meta-fsl-bsp-release/imx/meta-sdk
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-openembedded/meta-gnome \"" >> $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-openembedded/meta-networking \"" >> $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-openembedded/meta-python \"" >> $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-openembedded/meta-filesystems \"" >> $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-browser \"" >> $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-qt5 \"" >> $PWD/conf/bblayers.conf
    fi
  fi
fi
if [ $TNCONFIGS -gt 0 ] ; then
  # add technexion bsp layers to bblayers.conf
  if [ -d $PWD/../sources/meta-tn-imx-bsp ]; then
    if ! grep -Fq "meta-tn-imx-bsp" $PWD/conf/bblayers.conf; then
      echo "" >> $PWD/conf/bblayers.conf
      echo "# setup Technexion i.MX Yocto Project Release Layers in bblayers.conf" | tee -a $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-tn-imx-bsp \"" >> $PWD/conf/bblayers.conf
    fi
  fi
  # add meta-qt4 bsp layers to bblayers.conf
  if [ -d $PWD/../sources/meta-qt4 ]; then
    if ! grep -Fq "meta-qt4" $PWD/conf/bblayers.conf; then
      echo "" >> $PWD/conf/bblayers.conf
      echo "# setup meta-qt4 release layers in bblayers.conf" | tee -a $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-qt4 \"" >> $PWD/conf/bblayers.conf
    fi
  fi
  # add technexion nfc bsp layers (from nxp) to bblayers.conf
  if [ -d $PWD/../sources/meta-nxp-nfc ]; then
    if ! grep -Fq "meta-nxp-nfc" $PWD/conf/bblayers.conf; then
      echo "" >> $PWD/conf/bblayers.conf
      echo "# setup NXP nfc release layer in bblayers.conf" | tee -a $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-nxp-nfc \"" >> $PWD/conf/bblayers.conf
    fi
  fi
  # add technexion virtualization bsp layers to bblayers.conf
  if [ -d $PWD/../sources/meta-virtualization ]; then
    # has meta-virtualization
    if ! grep -Fq "meta-virtualization" $PWD/conf/bblayers.conf; then
      echo "" >> $PWD/conf/bblayers.conf
      echo "# setup i.MX Container OS and OTA layers in bblayers.conf" | tee -a $PWD/conf/bblayers.conf
      echo "BBLAYERS += \" \${BSPDIR}/sources/meta-virtualization \"" >> $PWD/conf/bblayers.conf
    fi
    if ! grep -Fq "BBMULTICONFIG" $PWD/conf/local.conf; then
      mkdir -p $PWD/conf/multiconfig
      cat > $PWD/conf/multiconfig/container.conf << EOF
MACHINE = "tn-container"
DISTRO = "fsl-imx-xwayland"
DISTRO_FEATURES_append = " virtualization"
TMPDIR = "\${TOPDIR}/tmp-container"
TN_CONTAINER_IMAGE_TYPE ?= "tar.gz"
EOF
      echo "TN_CONTAINER_IMAGE_TYPE = \"tar.gz\"" >> $PWD/conf/local.conf
      echo "BBMULTICONFIG = \"container\"" >> $PWD/conf/local.conf
      echo "setup BBMULTICONFIG in local.conf with conf/multiconfig/container.conf"
      cat $PWD/conf/multiconfig/container.conf
      echo "BBMASK += \"meta-tn-imx-bsp/recipes-python/pyqt4/python3-pyqt_4.11.3.bb\"" >> $PWD/conf/local.conf
      echo "BBMASK += \"meta-tn-imx-bsp/recipes-qt/qt4/qt4-embedded_%.bbappend\"" >> $PWD/conf/local.conf
    fi
  else
    # no meta-virtualization
    if ! grep -Fq "meta-tn-imx-bsp/recipes-containers/docker-disk/docker-disk.bb" $PWD/conf/local.conf; then
      echo "BBMASK += \"meta-tn-imx-bsp/recipes-containers/docker-disk/docker-disk.bb\"" >> $PWD/conf/local.conf
    fi
    if ! grep -Fq "meta-tn-imx-bsp/recipes-containers/docker/docker_%.bbappend" $PWD/conf/local.conf; then
      echo "BBMASK += \"meta-tn-imx-bsp/recipes-containers/docker/docker_%.bbappend\"" >> $PWD/conf/local.conf
    fi
    # for boot2qt
    if grep -Fq "DISTRO ?= \"b2qt\"" $PWD/conf/local.conf; then
      if ! grep -Fq "meta-tn-imx-bsp/recipes-graphics/wayland/weston_%.bbappend" $PWD/conf/local.conf; then
        echo "BBMASK += \"meta-tn-imx-bsp/recipes-graphics/wayland/weston_%.bbappend\"" >> $PWD/conf/local.conf
      fi
      if ! grep -Fq "meta-tn-imx-bsp/recipes-qt/qt5/qtbase_%.bbappend" $PWD/conf/local.conf; then
        echo "BBMASK += \"meta-tn-imx-bsp/recipes-qt/qt5/qtbase_%.bbappend\"" >> $PWD/conf/local.conf
      fi
    fi
  fi
fi

unset CWD
unset PROGNAME
unset THIS_SCRIPT
unset TNCONFIGS
unset FSLCONFIGS
unset MACHINE
unset DISTRO
unset BUILDDIRECTORY
unset TEMPLATECONF
unset LAYERSCONF
