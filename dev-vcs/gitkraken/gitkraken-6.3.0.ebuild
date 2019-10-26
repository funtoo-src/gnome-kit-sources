# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils pax-utils xdg-utils gnome2-utils

DESCRIPTION="Git GUI client"
SRC_URI="https://release.gitkraken.com/linux/GitKraken-v${PV}.tar.gz -> ${PN}-amd64-${PV}.tar.gz"
HOMEPAGE="https://www.gitkraken.com/"
KEYWORDS="~amd64"
SLOT="0"
LICENSE="Axosoft, LLC"
IUSE=""

RDEPEND="
	x11-libs/libXScrnSaver
	gnome-base/libgnome-keyring
	dev-libs/nss
"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
}

src_install() {
	declare GITKRAKEN_HOME=/opt/${PN}

	# Install gitkraken in /opt
	dodir ${GITKRAKEN_HOME%/*}
	mv "${S}" "${ED}"${GITKRAKEN_HOME} || die
	insinto ${GITKRAKEN_HOME}
	doins "${FILESDIR}/gitkraken.png"

	# Create /usr/bin/gitkraken
	dodir /usr/bin/
	cat <<-EOF >"${ED}"usr/bin/${PN}
	#!/bin/sh
	exec /opt/${PN}/${PN} "\$@"
	EOF
	fperms 0755 /usr/bin/${PN}

	insinto /usr/share/applications
	doins "${FILESDIR}/gitkraken.desktop"
}

pkg_postinst() {
	xdg_desktop_database_update
}
