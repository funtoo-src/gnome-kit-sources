# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
GNOME_ORG_MODULE="${PN/pp/++}"

inherit gnome2

DESCRIPTION="C++ wrapper for the libxml2 XML parser library"
HOMEPAGE="http://libxmlplusplus.sourceforge.net/"

LICENSE="LGPL-2.1"
SLOT="2.6"
KEYWORDS="*"
IUSE="doc"

RDEPEND="
	>=dev-libs/libxml2-2.7.7
	>=dev-cpp/glibmm-2.32
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

multilib_src_configure() {
	ECONF_SOURCE="${S}" gnome2_src_configure \
		$(use_enable doc documentation)
}
