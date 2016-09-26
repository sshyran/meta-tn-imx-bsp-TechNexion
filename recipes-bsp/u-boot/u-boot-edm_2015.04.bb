require recipes-bsp/u-boot/u-boot.inc

DESCRIPTION = "u-boot Technexion boards."
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=c7383a594871c03da76b3707929d2919"

PROVIDES += "u-boot"

SRCBRANCH = "tn-imx_v2015.04_4.1.15_1.0.0_ga"
SRCREV = "e45490bed55bda12487a5bd12312458df14d8310"
SRC_URI = "git://github.com/TechNexion/u-boot-edm.git;branch=${SRCBRANCH} \
           "

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(mx6|mx6ul|mx7)"
