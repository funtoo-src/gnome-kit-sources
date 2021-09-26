# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
VALA_MIN_API_VERSION="0.26"
VALA_USE_DEPEND="vapigen"

inherit gnome3 meson python-single-r1 vala

DESCRIPTION="A text editor for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Gedit"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"

IUSE="+introspection +python gtk-doc spell vala"
REQUIRED_USE="python? ( introspection ${PYTHON_REQUIRED_USE} )"

KEYWORDS="*"

DEPEND="
	>=dev-libs/glib-2.52:2
	>=dev-libs/libpeas-1.14.1[gtk]
	>=x11-libs/gtk+-3.22.0:3[introspection?]
	>=x11-libs/gtksourceview-4.0.2:4[introspection?]
	>=gui-libs/tepl-4.4:4
	x11-libs/libX11

	spell? ( >=app-text/gspell-0.2.5:0= )
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/pycairo[${PYTHON_USEDEP}]
			>=dev-python/pygobject-3:3[cairo,${PYTHON_USEDEP}]
			dev-libs/libpeas[python,${PYTHON_SINGLE_USEDEP}]
		')
	)
"
RDEPEND="${DEPEND}
	x11-themes/adwaita-icon-theme
	gnome-base/gsettings-desktop-schemas
	gnome-base/gvfs
"
BDEPEND="
	${vala_depend}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/glib-utils
	gtk-doc? ( >=dev-util/gtk-doc-1 )
	dev-util/itstool
	>=sys-devel/gettext-0.18
	virtual/pkgconfig
"
PATCHES=(
	# Don't force off overlay scrollbars for dubious reasons that GNOME designers heavily
	# disagree with; those wanting them off in general would set that globally for gtk
	"${FILESDIR}"/restore-overlay-scrollbars.patch
	# Make gspell and python optional
	"${FILESDIR}"/3.36-make-gspell-optional.patch
	"${FILESDIR}"/3.36-make-python-optional.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	use vala && vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use python)
		$(meson_use gtk-doc gtk_doc)
		-Duser_documentation=true
		$(meson_feature spell)
	)
	meson_src_configure
}

# Only appdata and desktop file validation in v3.32.2
src_test() { :; }

src_install() {
	meson_src_install
	if use python; then
		python_optimize
		python_optimize "${ED}/usr/$(get_libdir)/gedit/plugins/"
	fi
}