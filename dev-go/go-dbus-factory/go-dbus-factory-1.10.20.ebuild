# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/linuxdeepin/go-dbus-factory"

EGO_VENDOR=(
	"golang.org/x/net aaf60122140d3fcf75376d319f0554393160eb50 github.com/golang/net"
	"github.com/godbus/dbus e0a146e"
	"github.com/fsnotify/fsnotify 7f4cf4d"
	"golang.org/x/sys cc9327a github.com/golang/sys"
)

inherit golang-vcs-snapshot

DESCRIPTION="Go bindings to generate D-Bus services"
HOMEPAGE="https://github.com/linuxdeepin/go-dbus-factory"
SRC_URI="https://github.com/linuxdeepin/go-dbus-factory/archive/${PV}.tar.gz -> ${P}.tar.gz
${EGO_VENDOR_URI}"

RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"
IUSE=""

DEPEND="dev-go/deepin-go-lib
	>=dev-go/go-gir-generator-2.0.0"

src_compile() {
	mkdir -p "${T}/golibdir/"
	cp -r  "${S}/src/${EGO_PN}/vendor"  "${T}/golibdir/src"

	export -n GOCACHE XDG_CACHE_HOME
	export GOPATH="${S}:$(get_golibdir):${T}/golibdir/"
	cd ${S}/src/${EGO_PN}
	emake bin
	#	${S}/src/${EGO_PN}/gen.sh
}

src_install() {
	insinto $(get_golibdir)/src/${EGO_PN}
	cd ${S}/src/${EGO_PN}
	doins -r object_manager net.* org.* com.*
}
