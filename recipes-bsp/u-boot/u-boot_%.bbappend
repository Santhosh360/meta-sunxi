FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += " bc-native dtc-native swig-native python3-native flex-native bison-native "
DEPENDS_append_sun50i = " atf-sunxi "

COMPATIBLE_MACHINE = "(sun4i|sun5i|sun7i|sun8i|sun50i)"

DEFAULT_PREFERENCE_sun4i="1"
DEFAULT_PREFERENCE_sun5i="1"
DEFAULT_PREFERENCE_sun7i="1"
DEFAULT_PREFERENCE_sun8i="1"
DEFAULT_PREFERENCE_sun50i="1"

SRC_URI += " \
           file://0001-nanopi_neo_air_defconfig-Enable-eMMC-support.patch \
           file://0002-Added-nanopi-r1-board-support.patch \
           file://0003-h3-enable-alt-uart-console.patch \
           file://0004-enable-nanopi-r1-uart1-console.patch \
           file://0005-enable-r_pio-gpio-access-h3-h5.patch \
           file://0006-h3-Fix-PLL1-setup-to-never-use-dividers.patch \
           file://0007-h3-enable-power-led.patch \
           file://0008-h3-set-safe-axi_apb-clock-dividers.patch \
           file://boot.cmd \
           file://nanopi-r1-env.txt \
           "
# fix booting issue on orange pi zero
SRC_URI_append_orange-pi-zero = " file://0002-Revert-sunxi-psci-avoid-error-address-of-packed-memb.patch"

SRC_URI_append_nanopi-neo = " file://0002-Revert-sunxi-psci-avoid-error-address-of-packed-memb.patch"

UBOOT_ENV_SUFFIX = "scr"
UBOOT_ENV = "boot"

EXTRA_OEMAKE += ' HOSTLDSHARED="${BUILD_CC} -shared ${BUILD_LDFLAGS} ${BUILD_CFLAGS}" '
EXTRA_OEMAKE_append_sun50i = " BL31=${DEPLOY_DIR_IMAGE}/bl31.bin "

do_compile_sun50i[depends] += "atf-sunxi:do_deploy"

do_compile_append() {
    ${B}/tools/mkimage -C none -A arm -T script -d ${WORKDIR}/boot.cmd ${WORKDIR}/${UBOOT_ENV_BINARY}
    
    # Add the soc specific parameters in the environment
    sed -e "s,overlay_prefix=,overlay_prefix=${OVERLAY_PREFIX},g" \
        -i ${WORKDIR}/nanopi-r1-env.txt
    sed -e "s,overlays=,overlays=${DEFAULT_OVERLAYS} ,g" \
        -i ${WORKDIR}/nanopi-r1-env.txt
    # Select boot partition
    if [ ! -z "${SUNXI_BOOT_IMAGE}" ]; then
        sed -e "s,rootdev=,rootdev=/dev/${SUNXI_STORAGE_DEVICE}p2 ,g" \
            -i ${WORKDIR}/nanopi-r1-env.txt
    else
        sed -e "s,rootdev=,rootdev=/dev/${SUNXI_STORAGE_DEVICE}p1 ,g" \
            -i ${WORKDIR}/nanopi-r1-env.txt
    fi
}

do_install_append() {
    # Install files to rootfs/boot/
    install -D -m 644 ${WORKDIR}/nanopi-r1-env.txt ${D}/boot/nanopi-r1-env.txt
}

do_deploy_append() {
    install -D -m 644 ${WORKDIR}/nanopi-r1-env.txt ${DEPLOYDIR}/
}
