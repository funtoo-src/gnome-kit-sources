# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"

inherit flag-o-matic gnome2 meson

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="https://developer.gnome.org/libwnck/stable/"

LICENSE="LGPL-2+"
SLOT="3"
KEYWORDS="*"

IUSE="doc +introspection startup-notification tools"

RDEPEND="
	x11-libs/cairo[X]
	>=x11-libs/gtk+-3.22:3[introspection?]
	>=dev-libs/glib-2.32:2
	x11-libs/libX11
	x11-libs/libXres
	x11-libs/libXext
	introspection? ( >=dev-libs/gobject-introspection-0.6.14:= )
	startup-notification? ( >=x11-libs/startup-notification-0.4 )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.9
	>=sys-devel/gettext-0.19.4
	>=dev-util/meson-0.50.0
	virtual/pkgconfig
"
# eautoreconf needs
#	sys-devel/autoconf-archive

src_configure() {
	# Don't collide with SLOT=1
	local emesonargs=(
		-Dintrospection=$(usex introspection enabled disabled)
		-Dstartup_notification=auto
		$(meson_use tools install_tools)
		$(meson_use doc gtk_doc)
	)

	meson_src_configure
}