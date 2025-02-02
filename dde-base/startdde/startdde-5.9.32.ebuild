# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="pkg.deepin.io/dde/startdde"
EGO_VENDOR=(
"golang.org/x/net aaf60122140d3fcf75376d319f0554393160eb50 github.com/golang/net"
"golang.org/x/xerrors 9bdfabe github.com/golang/xerrors"
"github.com/davecgh/go-spew 87df7c6"
"github.com/cryptix/wav 8bdace674401f0bd3b63c65479b6a6ff1f9d5e44"
"github.com/godbus/dbus e0a146e"
"github.com/fsnotify/fsnotify 7f4cf4d"
"golang.org/x/sys cc9327a github.com/golang/sys"
"github.com/stretchr/testify acba37e"
"github.com/pmezard/go-difflib 792786c"
"github.com/stretchr/objx 35313a9"
"gopkg.in/yaml.v3 496545a github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot

DESCRIPTION="starter of Deepin Desktop Environment"
HOMEPAGE="https://github.com/linuxdeepin/startdde"
SRC_URI="https://github.com/linuxdeepin/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
		${EGO_VENDOR_URI}"

RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"
IUSE=""

RDEPEND=">=dde-base/dde-daemon-5.9.0
		x11-wm/dde-kwin
		>=dde-base/deepin-desktop-schemas-5.4.0
		dev-qt/dde-qt5platform-plugins
		"

DEPEND="${RDEPEND}
		gnome-base/libgnome-keyring
		app-misc/ddcutil
		>=dev-go/go-gir-generator-2.0.0
		>=dev-go/go-dbus-factory-1.8.0.0
		dev-util/cmake
		>=dde-base/dde-api-5.3.0.1
		>=dev-go/deepin-go-lib-5.4.5
		"
BDEPEND="app-misc/jq"

src_prepare() {
	mkdir -p "${T}/golibdir/"
	cp -r  "${S}/src/${EGO_PN}/vendor"  "${T}/golibdir/src"

	rm -r "${S}/src/${EGO_PN}/vendor/github.com/godbus"
	rm -r "${S}/src/${EGO_PN}/vendor/github.com/fsnotify"

	export -n GOCACHE XDG_CACHE_HOME
	export GOPATH="${S}:$(get_golibdir_gopath):${T}/golibdir/"

	LIBDIR=$(get_libdir)
	cd ${S}/src/${EGO_PN}
	sed -i "s|/lib/|/${LIBDIR}/|g" Makefile
	sed -i "s|/usr/lib/|/usr/${LIBDIR}/|g" \
		misc/auto_launch/*.json \
		startmanager.go \
		session.go \
		utils.go \
		watchdog/dde_polkit_agent.go || die
	default_src_prepare
}

src_compile() {
	cd ${S}/src/${EGO_PN}
	emake
}

src_install() {
	cd ${S}/src/${EGO_PN}
	emake DESTDIR="${D}" install

	rm -r ${D}/etc/X11/

	exeinto /etc/X11/xinit/xinitrc.d
	doexe ${S}/src/${EGO_PN}/misc/Xsession.d/*
}
