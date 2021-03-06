# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit desktop flag-o-matic

DESCRIPTION="Open-source replacement for Quake 3 Arena"
HOMEPAGE="http://openarena.ws/"
SRC_URI="mirror://sourceforge/oarena/${P}.zip
	mirror://sourceforge/oarena/src/${PN}-engine-source-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+client +curl +openal +vorbis"

RDEPEND="
	client? (
		media-libs/libsdl[joystick,opengl,video]
		media-libs/speex
		media-libs/speexdsp
		virtual/jpeg:0
		virtual/opengl
		x11-libs/libXext
		x11-libs/libX11
		x11-libs/libXau
		x11-libs/libXdmcp
		curl? ( net-misc/curl )
		openal? ( media-libs/openal )
		vorbis? ( media-libs/libvorbis )
	)
"
DEPEND="${RDEPEND}
	app-arch/unzip
"

S="${WORKDIR}"/${PN}-engine-source-${PV}
BUILD_DIR="${PN}-build"
DIR="/usr/share/${PN}"

PATCHES=( "${FILESDIR}"/${P}-makefile.patch
	"${FILESDIR}"/${P}-unbundling.patch )

src_prepare() {
	default
	touch jpegint.h
}

src_compile() {
	local myopts

	# enable voip, disable mumble
	# also build always server and use smp by default
	myopts="USE_INTERNAL_SPEEX=0 USE_VOIP=1 USE_MUMBLE=0
		BUILD_SERVER=1 BUILD_CLIENT_SMP=1 USE_LOCAL_HEADERS=0"
	use client || myopts="${myopts} BUILD_CLIENT=0"
	use curl || myopts="${myopts} USE_CURL=0"
	use openal || myopts="${myopts} USE_OPENAL=0"
	use vorbis || myopts="${myopts} USE_CODEC_VORBIS=0"

	emake \
		V=1 \
		DEFAULT_BASEDIR="${DIR}" \
		BR="${BUILD_DIR}" \
		${myopts} \
		OPTIMIZE=
}

src_install() {
	cd "${S}"/"${BUILD_DIR}"
	use client && newbin openarena-smp.* "${PN}"
	newbin oa_ded.* "${PN}-ded"

	cd "${WORKDIR}"/${P}

	insinto "${DIR}"
	doins -r baseoa missionpack

	dodoc CHANGES CREDITS LINUXNOTES README
	if use client; then
		newicon "${S}"/misc/quake3.png ${PN}.png
		make_desktop_entry ${PN} "OpenArena"
	fi
}
