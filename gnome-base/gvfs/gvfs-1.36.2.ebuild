# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
GNOME2_EAUTORECONF="yes"
inherit gnome2 systemd meson

DESCRIPTION="Virtual filesystem implementation for gio"
HOMEPAGE="https://wiki.gnome.org/Projects/gvfs"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="afp archive bluray cdda elogind fuse google gnome-keyring gnome-online-accounts gphoto2 gtk +http ios mtp nfs policykit samba systemd test +udev udisks zeroconf"
REQUIRED_USE="
	cdda? ( udev )
	elogind? ( !systemd udisks )
	google? ( gnome-online-accounts )
	mtp? ( udev )
	udisks? ( udev )
	systemd? ( !elogind udisks )
"

# Tests with multiple failures, this is being handled upstream at:
# https://bugzilla.gnome.org/700162
RESTRICT="test"

RDEPEND="
	app-crypt/gcr:=
	>=dev-libs/glib-2.51:2
	dev-libs/libxml2:2
	net-misc/openssh
	afp? ( >=dev-libs/libgcrypt-1.2.2:0= )
	archive? ( app-arch/libarchive:= )
	bluray? ( media-libs/libbluray:= )
	elogind? ( >=sys-auth/elogind-229:0= )
	fuse? ( >=sys-fs/fuse-2.8.0:0 )
	gnome-keyring? ( app-crypt/libsecret )
	gnome-online-accounts? ( >=net-libs/gnome-online-accounts-3.7.1:= )
	google? (
		>=dev-libs/libgdata-0.17.7:=[crypt,gnome-online-accounts]
		>=net-libs/gnome-online-accounts-3.17.1:= )
	gphoto2? ( >=media-libs/libgphoto2-2.5.0:= )
	gtk? ( >=x11-libs/gtk+-3.0:3 )
	http? ( >=net-libs/libsoup-2.42:2.4 )
	ios? (
		>=app-pda/libimobiledevice-1.2:=
		>=app-pda/libplist-1:= )
	mtp? (
		>=dev-libs/libusb-1.0.21
		>=media-libs/libmtp-1.1.12 )
	nfs? ( >=net-fs/libnfs-1.9.8 )
	policykit? (
		sys-auth/polkit
		sys-libs/libcap )
	samba? ( >=net-fs/samba-4[client] )
	systemd? ( >=sys-apps/systemd-206:0= )
	udev? (
		cdda? ( dev-libs/libcdio-paranoia )
		>=virtual/libgudev-147:=
		virtual/libudev:= )
	udisks? ( >=sys-fs/udisks-1.97:2 )
	zeroconf? ( >=net-dns/avahi-0.6 )
"
DEPEND="${RDEPEND}
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
	dev-util/gdbus-codegen
	dev-util/gtk-doc-am
	test? (
		>=dev-python/twisted-core-12.3.0
		|| (
			net-analyzer/netcat
			net-analyzer/netcat6 ) )
	!udev? ( >=dev-libs/libgcrypt-1.2.2:0 )
"
# libgcrypt.m4, provided by libgcrypt, needed for eautoreconf, bug #399043
# test dependencies needed per https://bugzilla.gnome.org/700162

PATCHES=(
	"${FILESDIR}"/${PN}-1.30.2-sysmacros.patch #580234
)

src_prepare() {
# 	if ! use udev; then
# 		sed -e 's/gvfsd-burn/ /' \
# 			-e 's/burn.mount.in/ /' \
# 			-e 's/burn.mount/ /' \
# 			-i daemon/Makefile.am || die
# 	fi
# 
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-Ddbus_service_dir="${EPREFIX}"/usr/share/dbus-1/services
		-Dsystemduserunitdir=no
		-Dtmpfilesdir=no
		-Dadmin=$(usex policykit true false)
		-Dafc=$(usex ios true false)
		-Dafp=$(usex afp true false)
		-Darchive=$(usex archive true false)
		-Dcdda=$(usex cdda true false)
		-Dgdu=false
		-Dgoa=$(usex gnome-online-accounts true false)
		-Dgoogle=$(usex google true false)
		-Dgphoto2=$(usex gphoto2 true false)
		-Dhttp=$(usex http true false)
		-Dmtp=$(usex mtp true false)
		-Dnfs=$(usex nfs true false)
		-Dsmb=$(usex samba true false)
		-Dudisks2=$(usex udisks true false)
		-Dbluray=$(usex bluray true false)
		-Dfuse=$(usex fuse true false)
		-Dgcr=true
		-Dgudev=$(usex udev true false)
		-Dkeyring=$(usex gnome-keyring true false)
		-Dlogind=$(usex elogind true false)
		-Dlibusb=$(usex mtp true false)
		-Dman=true
	)

	meson_src_configure
}