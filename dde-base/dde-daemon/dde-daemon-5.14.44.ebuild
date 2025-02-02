# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )

EGO_PN="github.com/linuxdeepin/dde-daemon"
EGO_VENDOR=(
"github.com/msteinert/pam f29b9f28d6f9a1f6c4e6fd5db731999eb946574b"
"github.com/axgle/mahonia 3358181d7394e26beccfae0ffde05193ef3be33a"
"gopkg.in/alecthomas/kingpin.v2 947dcec5ba9c011838740e680966fd7087a71d0d github.com/alecthomas/kingpin"
"golang.org/x/image f315e440302883054d0c2bd85486878cb4f8572c github.com/golang/image"
"golang.org/x/net aaf60122140d3fcf75376d319f0554393160eb50 github.com/golang/net"
"golang.org/x/text f21a4dfb5e38f5895301dc265a8def02365cc3d0 github.com/golang/text"
"github.com/alecthomas/units 2efee857e7cfd4f3d0138cc3cbb1b4966962b93a"
"github.com/alecthomas/template a0175ee3bccc567396460bf5acd36800cb10c49c"
"github.com/cryptix/wav 8bdace674401f0bd3b63c65479b6a6ff1f9d5e44"
"github.com/nfnt/resize 83c6a9932646f83e3267f353373d47347b6036b2"
"github.com/gosexy/gettext 74466a0a0c4a62fea38f44aa161d4bbfbe79dd6b"
"github.com/davecgh/go-spew 87df7c6"
"github.com/mattn/go-sqlite3 98a44bc"
"github.com/rickb777/date 2248ec4"
"github.com/rickb777/plural 7589705"
"golang.org/x/xerrors 9bdfabe github.com/golang/xerrors"
"github.com/jinzhu/gorm 7ea143b"
"github.com/jinzhu/inflection 196e6ce"
"github.com/kelvins/sunrisesunset 14f1915"
"github.com/mozillazg/go-pinyin 63be21f"
"github.com/teambition/rrule-go c4b1bf2"
"github.com/godbus/dbus e0a146e"
"github.com/fsnotify/fsnotify 7f4cf4d"
"golang.org/x/sys cc9327a github.com/golang/sys"
"github.com/Lofanmi/pinyin-golang 30cdbfc"
"github.com/stretchr/testify acba37e"
"github.com/pmezard/go-difflib 792786c"
"github.com/stretchr/objx 35313a9"
"gopkg.in/yaml.v3 496545a github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot pam python-any-r1 udev

DESCRIPTION="Daemon handling the DDE session settings"
HOMEPAGE="https://github.com/linuxdeepin/dde-daemon"
SRC_URI="https://github.com/linuxdeepin/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
${EGO_VENDOR_URI}"

RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"
IUSE="grub bluetooth systemd elogind"
REQUIRED_USE="^^ ( systemd elogind )"

RDEPEND="x11-wm/dde-kwin
		x11-libs/libxkbfile
		app-text/iso-codes
		sys-apps/accountsservice
		sys-power/acpid
		sys-fs/udisks:2
		gnome-extra/polkit-gnome
		>=dde-base/deepin-desktop-schemas-5.4.0
		net-misc/networkmanager
		gnome-base/gvfs[udisks]
		sys-libs/pam
		>sys-power/upower-0.99
		dev-libs/libnl:3
		bluetooth? ( net-wireless/bluez )
		grub? ( dde-extra/deepin-grub2-themes )
		systemd? ( sys-apps/systemd )
		elogind? ( sys-auth/elogind )
		virtual/libcrypt
	"
DEPEND="${RDEPEND}
		>=dev-go/go-gir-generator-2.0.0
		>=dev-go/go-x11-client-0.6.0
		>=dev-go/deepin-go-lib-5.4.5
		>=dev-go/go-dbus-factory-1.9.6
		>=dde-base/dde-api-5.3.0.1
		>=dde-base/deepin-gettext-tools-1.0.8
		dev-libs/libinput
		dev-db/sqlite:3
		=dev-lang/python-3*
		"
PATCHES=(
	"${FILESDIR}"/${PN}-5.14.44-fix-vanilla-libinput.patch
)

src_prepare() {

	cd ${S}/src/${EGO_PN}

	if use elogind; then
		sed -i "s|libsystemd|libelogind|g" Makefile
		sed -i "s|systemd/sd-bus.h|elogind/systemd/sd-bus.h|g" misc/pam-module/deepin_auth.c
	fi

	mkdir -p "${T}/golibdir/"
	cp -r  "${S}/src/${EGO_PN}/vendor"  "${T}/golibdir/src"

	rm -r "${S}/src/${EGO_PN}/vendor/github.com/godbus"
	rm -r "${S}/src/${EGO_PN}/vendor/github.com/fsnotify"

	export GOPATH="${S}:$(get_golibdir_gopath):${T}/golibdir/"

	LIBDIR=$(get_libdir)
	sed -i "s|lib/deepin-daemon|${LIBDIR}/deepin-daemon|g" Makefile
	sed -i "s|/usr/lib/|/usr/${LIBDIR}/|g" \
		misc/dde-daemon/gesture.json \
		misc/dde-daemon/gesture/conf.json \
		misc/dde-daemon/keybinding/system_actions.json \
		misc/applications/deepin-toggle-desktop.desktop \
		misc/services/*.service \
		misc/system-services/*.service \
		misc/systemd/services/*.service \
		grub2/modify_manger.go \
		network/secret_agent.go \
		network/examples/python/gen_dbus_code.sh \
		network/nm_generator/nm_docs/NetworkManager.conf.html \
		accounts/image_blur.go \
		keybinding/shortcuts/system_shortcut.go \
		bin/search/main.go \
		bin/dde-system-daemon/main.go \
		bin/dde-authority/fprint_transaction.go \
		service_trigger/manager.go \
		session/power/lid_switch.go \
		session/power/constant.go || die

	default_src_prepare
}

src_compile() {
	cd ${S}/src/${EGO_PN}
	export -n GOCACHE XDG_CACHE_HOME
	export PAM_MODULE_DIR=$(getpam_mod_dir)
	default_src_compile
}

src_install() {
	cd ${S}/src/${EGO_PN}
	default_src_install
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
