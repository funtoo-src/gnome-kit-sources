# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3+ )
VALA_USE_DEPEND="vapigen"

inherit gnome.org meson python-r1 vala

DESCRIPTION="Git library for GLib"
HOMEPAGE="https://wiki.gnome.org/Projects/Libgit2-glib"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="python +ssh +vala"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

# libgit2-glib is now compatible with SONAME 26 and 27 of libgit2.
RDEPEND="
	>=dev-libs/gobject-introspection-1.62.0:=
	>=dev-libs/glib-2.62.2:2
	<dev-libs/libgit2-0.29:0=[ssh?]
	>=dev-libs/libgit2-0.28.0:0
	python? (
		${PYTHON_DEPS}
		dev-python/pygobject:3[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	default
	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		# apparently broken; fails to build
		-Dgtk_doc=false
		# we install python scripts manually
		-Dpython=false
		$(meson_use ssh)
		$(meson_use vala vapi)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	if use python ; then
		install_gi_override() {
			python_moduleinto "$(python_get_sitedir)/gi/overrides"
			python_domodule "${S}"/${PN}/Ggit.py
		}
		python_foreach_impl install_gi_override
	fi
}