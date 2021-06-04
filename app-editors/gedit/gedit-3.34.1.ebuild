# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python3+ )
VALA_MIN_API_VERSION="0.26"
VALA_USE_DEPEND="vapigen"

inherit gnome.org meson python-single-r1 vala virtualx xdg

DESCRIPTION="A text editor for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Gedit"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"

IUSE="+introspection +python spell vala"
REQUIRED_USE="python? ( introspection ${PYTHON_REQUIRED_USE} )"

KEYWORDS="*"

# X libs are not needed for OSX (aqua)
COMMON_DEPEND="
	>=dev-libs/libxml2-2.5.0:2
	>=dev-libs/glib-2.62.2:2[dbus]
	>=x11-libs/gtk+-3.24.12:3[introspection?]
	>=x11-libs/gtksourceview-4[introspection?]
	>=dev-libs/libpeas-1.14.1[gtk]

	gnome-base/gsettings-desktop-schemas
	gnome-base/gvfs

	x11-libs/libX11

	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	python? (
		${PYTHON_DEPS}
		dev-python/pycairo[${PYTHON_USEDEP}]
		>=dev-python/pygobject-3:3[cairo,${PYTHON_USEDEP}]
		dev-libs/libpeas[python,${PYTHON_USEDEP}] )
	spell? ( >=app-text/gspell-1.8.1 )
"
RDEPEND="${COMMON_DEPEND}
	x11-themes/adwaita-icon-theme
"
DEPEND="${COMMON_DEPEND}
	${vala_depend}
	app-text/docbook-xml-dtd:4.1.2
	app-text/yelp-tools
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.50.1
	>=sys-devel/gettext-0.18
	virtual/pkgconfig
"

pkg_setup() {
	use python && [[ ${MERGE_TYPE} != binary ]] && python-single-r1_pkg_setup
}

src_prepare() {
	vala_src_prepare
	xdg_src_prepare
}