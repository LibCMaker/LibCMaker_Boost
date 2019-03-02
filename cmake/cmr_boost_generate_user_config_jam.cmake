# ****************************************************************************
#  Project:  LibCMaker_Boost
#  Purpose:  A CMake build script for Boost Libraries
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
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

function(cmr_boost_generate_user_config_jam)
  # https://boostorg.github.io/build/manual/develop/index.html#bbv2.reference.tools
  # using <toolset_name> : [<version>] : [c++-compiler-command] : [compiler options] ;

  file(WRITE ${user_jam_FILE}
    "using ${toolset_name}\n"
    "  : ${toolset_version}\n"
  )

  if(CMAKE_GENERATOR_TOOLSET MATCHES "v140")
    file(APPEND ${user_jam_FILE}
      "  : \n : \n"
    )
  else()
    file(APPEND ${user_jam_FILE}
      "  : \"${boost_compiler}\"\n : \n"
    )
  endif()

  if(CMAKE_RC_COMPILER)
    file(APPEND ${user_jam_FILE}
# TODO: is qoutes needed?
      #" <rc>\"${CMAKE_RC_COMPILER}\"\n"
      " <rc>${CMAKE_RC_COMPILER}\n"
    )
  endif()

  if(use_cmake_archiver)
    # We need custom '<archiver>' and '<ranlib>' for
    # Android LTO ('*-gcc-ar' instead of '*-ar')
    # WARNING: no spaces between '<archiver>' and '${CMAKE_AR}'!

    if(CMAKE_AR)
      file(APPEND ${user_jam_FILE}
# TODO: is qoutes needed?
      #" <archiver>\"${CMAKE_AR}\"\n"
        " <archiver>${CMAKE_AR}\n"
      )
    endif()

    if(CMAKE_RANLIB)
      file(APPEND ${user_jam_FILE}
# TODO: is qoutes needed?
      #" <ranlib>\"${CMAKE_RANLIB}\"\n"
        " <ranlib>${CMAKE_RANLIB}\n"
      )
    endif()
  endif()

  foreach(prefix_path ${CMAKE_PREFIX_PATH})
    file(APPEND ${user_jam_FILE}
      " <include>${prefix_path}/include\n"
      " <library-path>${prefix_path}/lib\n"
    )
  endforeach()

  file(APPEND ${user_jam_FILE}
    ";\n"
    "${using_mpi}\n"
  )
endfunction()
