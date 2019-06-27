# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Userspace system daemon to enable security levels for Thunderbolt 3 on Linux."
HOMEPAGE="https://gitlab.freedesktop.org/bolt/bolt"
SRC_URI="https://gitlab.freedesktop.org/bolt/bolt/-/archive/${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"

IUSE="systemd"

RDEPEND="$DEPEND"
DEPEND="app-text/asciidoc
	dev-libs/glib
	dev-util/umockdev
	sys-auth/polkit[introspection]"

src_configure() {
	local emesonargs=(
		$(meson_use systemd systemd)
		-Dman=true
	)

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	newinitd "${FILESDIR}/init.d.boltd" boltd
	meson_src_install
}
