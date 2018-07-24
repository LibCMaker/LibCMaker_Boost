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

include(${LIBCMAKER_SRC_DIR}/cmake/modules/cmr_print_debug_message.cmake)

set(cxx_FLAGS "${CMAKE_CXX_FLAGS_${build_TYPE}} ${cxx_FLAGS}")

file(WRITE ${user_jam_FILE}
  "using ${toolset_name}\n"
  "  : ${toolset_version}\n"
)

if(MSVC)
  # For Visual Studio C++ flags must not be set in compiler section.
  # Section <compileflags> should be used.
  #   * https://github.com/ruslo/hunter/issues/179
  file(APPEND ${user_jam_FILE}
    "  : \"${boost_compiler}\"\n"
  )
else()
  # For Android C++ flags must be part of the compiler section:
  #   * https://github.com/ruslo/hunter/issues/174
  # For 'sanitize-address' toolchain flags must be part of the compiler section:
  #   * https://github.com/ruslo/hunter/issues/269
  file(APPEND ${user_jam_FILE}
    "  : \"${boost_compiler}\" ${cxx_FLAGS}\n"
  )
endif()

if(use_cmake_archiver)
  # We need custom '<archiver>' and '<ranlib>' for
  # Android LTO ('*-gcc-ar' instead of '*-ar')
  # WARNING: no spaces between '<archiver>' and '${CMAKE_AR}'!
  file(APPEND ${user_jam_FILE}
    "  : <archiver>\"${jam_AR}\"\n"
    " <ranlib>\"${jam_RANLIB}\"\n"
  )
endif()

if(MSVC)
  # See 'boost_compiler' section
  string(REPLACE " " ";" cxx_flags_list "${cxx_FLAGS}")
  foreach(cxx_flag ${cxx_flags_list})
    file(APPEND ${user_jam_FILE}
      "  <compileflags>${cxx_flag}\n"
    )
  endforeach()
endif()

file(APPEND ${user_jam_FILE}
  ";\n"
  "${using_mpi}\n"
)

if(cmr_PRINT_DEBUG)
  cmr_print_debug_message("------")
  cmr_print_debug_message("Boost user jam config:")
  file(READ "${user_jam_FILE}" user_jam_CONTENT)
  cmr_print_debug_message("------\n${user_jam_CONTENT}")
  cmr_print_debug_message("------")
endif()
