inherit systemd

do_install_append_mx8() {
	# Install pulseaudio systemd service
	install -m 644 -p -D ${WORKDIR}/build/src/pulseaudio.service ${D}${systemd_user_unitdir}/pulseaudio.service
	install -m 644 -p -D ${WORKDIR}/pulseaudio-${PV}/src/daemon/systemd/user/pulseaudio.socket ${D}${systemd_user_unitdir}/pulseaudio.socket

	# Execute these manually on behalf of systemctl script (from systemd-systemctl-native.bb)
	# because it does not support systemd's user mode.
	install -d ${D}${systemd_user_unitdir}/sockets.target.wants/
	ln -sf ${systemd_user_unitdir}/pulseaudio.socket \
		${D}${systemd_user_unitdir}/sockets.target.wants/

	install -d ${D}${systemd_user_unitdir}/default.target.wants/
	ln -sf ${systemd_user_unitdir}/pulseaudio.service \
		${D}${systemd_user_unitdir}/default.target.wants/
}

FILES_${PN}-server += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '${systemd_user_unitdir}/pulseaudio.socket', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '${systemd_user_unitdir}/sockets.target.wants/pulseaudio.socket', '', d)} \
"
