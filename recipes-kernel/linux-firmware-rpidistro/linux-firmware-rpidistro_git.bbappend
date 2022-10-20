do_install_append() {
    ln -s brcmfmac43430-sdio.AP6212.txt ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.friendlyarm,nanopi-r1.txt
}
