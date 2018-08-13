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

include(${LIBCMAKER_SRC_DIR}/cmake/modules/cmr_print_debug.cmake)

set(jam_c_FLAGS "${CMAKE_C_FLAGS_${build_TYPE}} ${jam_c_FLAGS}")
set(jam_cxx_FLAGS "${CMAKE_CXX_FLAGS_${build_TYPE}} ${jam_cxx_FLAGS}")
set(jam_asm_FLAGS "${CMAKE_ASM_FLAGS_${build_TYPE}} ${jam_asm_FLAGS}")

# https://boostorg.github.io/build/manual/develop/index.html#bbv2.reference.tools
# using <toolset_name> : [<version>] : [c++-compiler-command] : [compiler options] ;

file(WRITE ${user_jam_FILE}
  "using ${toolset_name}\n"
  "  : ${toolset_version}\n"
)

file(APPEND ${user_jam_FILE}
  "  : \"${boost_compiler}\"\n : \n"
)

if(use_cmake_archiver)
  # We need custom '<archiver>' and '<ranlib>' for
  # Android LTO ('*-gcc-ar' instead of '*-ar')
  # WARNING: no spaces between '<archiver>' and '${CMAKE_AR}'!
  file(APPEND ${user_jam_FILE}
    " <archiver>\"${jam_AR}\"\n"
    " <ranlib>\"${jam_RANLIB}\"\n"
  )
endif()

string(REPLACE " " ";" c_flags_list "${jam_c_FLAGS}")
foreach(c_flag ${c_flags_list})
  file(APPEND ${user_jam_FILE}
    " <cflags>${c_flag}\n"
  )
endforeach()

string(REPLACE " " ";" cxx_flags_list "${jam_cxx_FLAGS}")
foreach(cxx_flag ${cxx_flags_list})
  file(APPEND ${user_jam_FILE}
    " <cxxflags>${cxx_flag}\n"
  )
endforeach()

string(REPLACE " " ";" asm_flags_list "${jam_asm_FLAGS}")
foreach(asm_flag ${asm_flags_list})
  file(APPEND ${user_jam_FILE}
    " <compileflags>${asm_flag}\n"
  )
endforeach()

string(REPLACE " " ";" link_flags_list "${jam_link_FLAGS}")
foreach(link_flag ${link_flags_list})
  file(APPEND ${user_jam_FILE}
    " <linkflags>${link_flag}\n"
  )
endforeach()
  
file(APPEND ${user_jam_FILE}
  ";\n"
  "${using_mpi}\n"
)

if(cmr_PRINT_DEBUG)
  cmr_print_debug("------")
  cmr_print_debug("Boost user jam config:")
  file(READ "${user_jam_FILE}" user_jam_CONTENT)
  cmr_print_debug("------\n${user_jam_CONTENT}")
  cmr_print_debug("------")
endif()
