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

# Part of "LibCMaker/cmake/modules/cmr_get_download_params.cmake".

  include(cmr_get_version_parts)
  cmr_get_version_parts(${version} major minor patch tweak)
  set(version_underscore "${major}_${minor}_${patch}")

  if(version VERSION_EQUAL "1.63.0")
    set(arch_file_sha
      "beae2529f759f6b3bf3f4969a19c2e9d6f0c503edcb2de4a61d1428519fcb3b0"
    )
  endif()
  if(version VERSION_EQUAL "1.64.0")
    set(arch_file_sha
      "7bcc5caace97baa948931d712ea5f37038dbb1c5d89b43ad4def4ed7cb683332"
    )
  endif()
  if(version VERSION_EQUAL "1.65.1")
    set(arch_file_sha
      "9807a5d16566c57fd74fb522764e0b134a8bbe6b6e8967b83afefd30dcd3be81"
    )
  endif()
  if(version VERSION_EQUAL "1.66.0")
    set(arch_file_sha
      "5721818253e6a0989583192f96782c4a98eb6204965316df9f5ad75819225ca9"
    )
  endif()
  if(version VERSION_EQUAL "1.67.0")
    set(arch_file_sha
      "2684c972994ee57fc5632e03bf044746f6eb45d4920c343937a465fd67a5adba"
    )
  endif()

  set(base_url "https://downloads.sourceforge.net/project/boost/boost")
  set(src_dir_name    "boost-${version}")
  set(arch_file_name  "${src_dir_name}.tar.bz2")
  set(unpack_to_dir   "${unpacked_dir}/${src_dir_name}")

  set(${out_ARCH_SRC_URL}
    "${base_url}/${version}/boost_${version_underscore}.tar.bz2" PARENT_SCOPE
  )
  set(${out_ARCH_DST_FILE}  "${download_dir}/${arch_file_name}" PARENT_SCOPE)
  set(${out_ARCH_FILE_SHA}  "${arch_file_sha}" PARENT_SCOPE)
  set(${out_SHA_ALG}        "SHA256" PARENT_SCOPE)
  set(${out_UNPACK_TO_DIR}  "${unpack_to_dir}" PARENT_SCOPE)
  set(${out_UNPACKED_SOURCES_DIR}
    "${unpack_to_dir}/boost_${version_underscore}" PARENT_SCOPE
  )
  set(${out_VERSION_BUILD_DIR} "${build_dir}/${src_dir_name}" PARENT_SCOPE)
