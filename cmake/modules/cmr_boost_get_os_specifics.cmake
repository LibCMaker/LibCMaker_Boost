# ****************************************************************************
#  Project:  LibCMaker_Boost
#  Purpose:  A CMake build script for Boost Libraries
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
#
#    This file is part of the LibCMaker_Boost project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

function(cmr_boost_get_os_specifics out_OS_SPECIFICS)
  if(ANDROID)
    # TODO: set --layout=system for link=shared for Android
    #list(APPEND os_specifics "--layout=system")
    list(APPEND os_specifics "--layout=tagged")

    # Whether to link to static or shared C and C++ runtime.
    # TODO: see BUILD_SHARED_LIBS and ANDROID_STL=c++_static/c++_shared
    list(APPEND os_specifics "runtime-link=shared")

    # Legal values for 'target-os':
    # "aix" "android" "appletv" "bsd" "cygwin" "darwin" "freebsd" "haiku" "hpux"
    # "iphone" "linux" "netbsd" "openbsd" "osf" "qnx" "qnxnto" "sgi" "solaris"
    # "unix" "unixware" "windows" "vms" "elf"
    list(APPEND os_specifics "target-os=android")

    # Legal values for 'binary-format':
    # "elf" "mach-o" "pe" "xcoff"
    list(APPEND os_specifics "binary-format=elf")

    # Legal values for 'architecture':
    # "x86" "ia64" "sparc" "power"
    # "mips1" "mips2" "mips3" "mips4" "mips32" "mips32r2" "mips64"
    # "parisc" "arm" "combined" "combined-x86-power"
    #
    # Legal values for 'abi':
    # "aapcs" "eabi" "ms" "n32" "n64" "o32" "o64" "sysv" "x32"
    if(ANDROID_SYSROOT_ABI STREQUAL arm
        OR ANDROID_SYSROOT_ABI STREQUAL arm64)
      set(cmr_BJAM_ARCH arm)
      set(cmr_BJAM_ABI aapcs)
    elseif(ANDROID_SYSROOT_ABI STREQUAL x86
        OR ANDROID_SYSROOT_ABI STREQUAL x86_64)
      set(cmr_BJAM_ARCH x86)
      set(cmr_BJAM_ABI sysv)
    elseif(ANDROID_SYSROOT_ABI STREQUAL mips)
      set(cmr_BJAM_ARCH mips1)
      set(cmr_BJAM_ABI o32)
    elseif(ANDROID_SYSROOT_ABI STREQUAL mips64)
      set(cmr_BJAM_ARCH mips1)
      set(cmr_BJAM_ABI o64)
    endif()

    # Legal values for 'address-model':
    # "16" "32" "64" "32_64"
    if(ANDROID_SYSROOT_ABI MATCHES "^.{3,4}64$")
      set(cmr_BJAM_ADDR_MODEL 64)
    else()
      set(cmr_BJAM_ADDR_MODEL 32)
    endif()
    
    list(APPEND os_specifics "address-model=${cmr_BJAM_ADDR_MODEL}")
    list(APPEND os_specifics "architecture=${cmr_BJAM_ARCH}")
    list(APPEND os_specifics "abi=${cmr_BJAM_ABI}")
  endif()


  if(APPLE OR MSVC OR (UNIX AND NOT ANDROID))
    # TODO: address-model=64 for MSVC and amd64
    #string(COMPARE EQUAL "${cmr_MSVC_ARCH}" "amd64" is_x64)
    #if(MSVC AND is_x64)
    #  list(APPEND os_specifics "address-model=64")
    #endif()

    list(APPEND os_specifics "--layout=tagged")
  endif()

  set(${out_OS_SPECIFICS} ${os_specifics} PARENT_SCOPE)
endfunction()
