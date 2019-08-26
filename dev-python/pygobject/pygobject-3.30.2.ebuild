# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6,3_7} )

inherit gnome-meson python-r1 virtualx

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="https://wiki.gnome.org/Projects/PyGObject"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"

IUSE="+cairo test +threads"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	test? ( cairo )
"

COMMON_DEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.38:2
	>=dev-libs/gobject-introspection-1.46.0:=
	virtual/libffi:=
	cairo? (
		>=dev-python/pycairo-1.11.1[${PYTHON_USEDEP}]
		x11-libs/cairo )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	cairo? ( x11-libs/cairo[glib] )
	test? (
		dev-libs/atk[introspection]
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc
		x11-libs/cairo[glib]
		x11-libs/gdk-pixbuf:2[introspection]
		x11-libs/gtk+:3[introspection]
		x11-libs/pango[introspection]
		python_targets_python2_7? ( dev-python/pyflakes[$(python_gen_usedep python2_7)] ) )
"
# gnome-base/gnome-common required by eautoreconf

# We now disable introspection support in slot 2 per upstream recommendation
# (see https://bugzilla.gnome.org/show_bug.cgi?id=642048#c9); however,
# older versions of slot 2 installed their own site-packages/gi, and
# slot 3 will collide with them.
RDEPEND="${COMMON_DEPEND}
	!<dev-python/pygtk-2.13
	!<dev-python/pygobject-2.28.6-r50:2[introspection]
"

src_prepare() {
	# FAIL: test_cairo_font_options (test_cairo.TestPango)
	# AssertionError: <type 'cairo.SubpixelOrder'> != <type 'int'>
	sed -e 's/^.*type(font_opts.get_subpixel_order()), int.*/#/' \
		-i tests/test_cairo.py || die

	gnome-meson_src_prepare
}

src_configure() {

	configuring() {

		# This is run for each python implementation; EPYTHON will be auto-set to the python implementation
		# currently active.

		if ! python_is_python3; then
			# python eclasses install python binaries into this ${T}/${EPYTHON}, and set up python3 ones to be "duds" when
			# we are building for a python2 target (to trigger errors.) Unfortunately, meson.build tries to be
			# smarter than this lame trick and detects that the python3 implementations are broken and dies.
			rm -f ${T}/${EPYTHON}/bin/python3*
		fi

		local emesonargs=(
			-Dpython=${EPYTHON}
			$(meson_use cairo pycairo)
		)

		meson_src_configure
	}

	python_foreach_impl run_in_build_dir configuring
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome-meson_src_compile
}

src_test() {
	export GIO_USE_VFS="local" # prevents odd issues with deleting ${T}/.gvfs
	export GIO_USE_VOLUME_MONITOR="unix" # prevent udisks-related failures in chroots, bug #449484
	export SKIP_PEP8="yes"

	testing() {
		export XDG_CACHE_HOME="${T}/${EPYTHON}"
		run_in_build_dir virtx emake check
		unset XDG_CACHE_HOME
	}
	python_foreach_impl testing
	unset GIO_USE_VFS
}

src_install() {
	python_foreach_impl run_in_build_dir gnome-meson_src_install

	dodoc -r examples
}
