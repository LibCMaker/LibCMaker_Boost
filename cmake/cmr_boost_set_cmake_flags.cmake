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

# Based on the hunter,
# https://github.com/ruslo/hunter

# Copyright (c) 2016-2017, Ruslan Baratov
# All rights reserved.

include(CMakeParseArguments) # cmake_parse_arguments

include(cmr_print_error)
include(cmr_boost_get_lang_standard_flag)

function(cmr_boost_set_cmake_flags)
  cmake_parse_arguments(bscf "SKIP_INCLUDES" "" "" "${ARGV}")
  # -> bscf_SKIP_INCLUDES

  string(COMPARE NOTEQUAL "${bscf_UNPARSED_ARGUMENTS}" "" has_unparsed)
  if(has_unparsed)
    cmr_print_error("Unparsed arguments: ${bscf_UNPARSED_ARGUMENTS}")
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_C_COMPILER_TARGET}" "" has_value)
  string(COMPARE NOTEQUAL "${CMAKE_C_COMPILE_OPTIONS_TARGET}" "" has_option)
  if(has_value AND has_option)
    set(CMAKE_C_FLAGS
      "${CMAKE_C_FLAGS} ${CMAKE_C_COMPILE_OPTIONS_TARGET}${CMAKE_C_COMPILER_TARGET}"
    )
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_CXX_COMPILER_TARGET}" "" has_value)
  string(COMPARE NOTEQUAL "${CMAKE_CXX_COMPILE_OPTIONS_TARGET}" "" has_option)
  if(has_value AND has_option)
    set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}"
    )
    set(CMAKE_SHARED_LINKER_FLAGS
      "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}"
    )
    set(CMAKE_STATIC_LINKER_FLAGS
      "${CMAKE_STATIC_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}"
    )
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_ASM_COMPILER_TARGET}" "" has_value)
  string(COMPARE NOTEQUAL "${CMAKE_ASM_COMPILE_OPTIONS_TARGET}" "" has_option)
  if(has_value AND has_option)
    set(CMAKE_ASM_FLAGS
      "${CMAKE_ASM_FLAGS} ${CMAKE_ASM_COMPILE_OPTIONS_TARGET}${CMAKE_ASM_COMPILER_TARGET}"
    )
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN}" "" has_value)
  string(COMPARE NOTEQUAL "${CMAKE_C_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}" "" has_option)
  if(has_value AND has_option)
    set(CMAKE_C_FLAGS
      "${CMAKE_C_FLAGS} ${CMAKE_C_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN}"
    )
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}" "" has_value)
  string(COMPARE NOTEQUAL "${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}" "" has_option)
  if(has_value AND has_option)
    set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}"
    )
    set(CMAKE_SHARED_LINKER_FLAGS
      "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}"
    )
    set(CMAKE_STATIC_LINKER_FLAGS
      "${CMAKE_STATIC_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}"
    )
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_ASM_COMPILER_EXTERNAL_TOOLCHAIN}" "" has_value)
  string(COMPARE NOTEQUAL "${CMAKE_ASM_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}" "" has_option)
  if(has_value AND has_option)
    set(CMAKE_ASM_FLAGS
      "${CMAKE_ASM_FLAGS} ${CMAKE_ASM_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_ASM_COMPILER_EXTERNAL_TOOLCHAIN}"
    )
  endif()

  # --sysroot=/path/to/sysroot do not added by CMake 3.7+
  if(CMAKE_SYSROOT)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} --sysroot=${CMAKE_SYSROOT}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --sysroot=${CMAKE_SYSROOT}")
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} --sysroot=${CMAKE_SYSROOT}")
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_C_COMPILE_OPTIONS_PIC}" "" has_pic)
  if(CMAKE_POSITION_INDEPENDENT_CODE AND has_pic)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_COMPILE_OPTIONS_PIC}")
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_CXX_COMPILE_OPTIONS_PIC}" "" has_pic)
  if(CMAKE_POSITION_INDEPENDENT_CODE AND has_pic)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_PIC}")
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_ASM_COMPILE_OPTIONS_PIC}" "" has_pic)
  if(CMAKE_POSITION_INDEPENDENT_CODE AND has_pic)
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${CMAKE_ASM_COMPILE_OPTIONS_PIC}")
  endif()


  set(CMAKE_SHARED_LINKER_FLAGS
    "${CMAKE_CXX_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}"
  )

  # CMake 3.6+
  if(NOT bscf_SKIP_INCLUDES AND CMAKE_VERSION VERSION_GREATER 3.5.9)
    foreach(x ${CMAKE_C_STANDARD_INCLUDE_DIRECTORIES})
      # CMake >= 2.8.5 has CMAKE_INCLUDE_SYSTEM_FLAG_C:
      # https://stackoverflow.com/a/6274608
      set(CMAKE_C_FLAGS
        "${CMAKE_C_FLAGS} ${CMAKE_INCLUDE_SYSTEM_FLAG_C} ${x}"
      )
    endforeach()
    foreach(x ${CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES})
      set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} ${CMAKE_INCLUDE_SYSTEM_FLAG_CXX} ${x}"
      )
    endforeach()
    foreach(x ${CMAKE_ASM_STANDARD_INCLUDE_DIRECTORIES})
      set(CMAKE_ASM_FLAGS
        "${CMAKE_ASM_FLAGS} ${CMAKE_INCLUDE_SYSTEM_FLAG_ASM} ${x}"
      )
    endforeach()
  endif()

  # TODO: work with CMAKE_C_STANDARD_LIBRARIES_INIT
  set(CMAKE_SHARED_LINKER_FLAGS
    "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_CXX_STANDARD_LIBRARIES_INIT}"
  )
  set(CMAKE_STATIC_LINKER_FLAGS
    "${CMAKE_STATIC_LINKER_FLAGS} ${CMAKE_CXX_STANDARD_LIBRARIES_INIT}"
  )

  if(MSVC)
    # Disable auto-linking
    # TODO: check with BOOST_ALL_DYN_LINK == OFF
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DBOOST_ALL_NO_LIB=1")

    # Fix some compile errors
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DNOMINMAX")

    # Fix boost.python:
    # include\pymath.h: warning C4273: 'round': inconsistent dll linkage
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /DHAVE_ROUND")
  endif()

  string(COMPARE NOTEQUAL "${CMAKE_OSX_SYSROOT}" "" have_osx_sysroot)
  if(have_osx_sysroot)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -isysroot ${CMAKE_OSX_SYSROOT}")
  endif()

# NOTE: 'cflags' is passed to the both the C and C++ compilers.
#  cmr_boost_get_lang_standard_flag(C flag)
#  string(COMPARE NOTEQUAL "${flag}" "" has_flag)
#  if(has_flag)
#    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${flag}")
#  endif()

  cmr_boost_get_lang_standard_flag(CXX flag)
  string(COMPARE NOTEQUAL "${flag}" "" has_flag)
  if(has_flag)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${flag}")
  endif()

  # Need to find out how to add flags on a per variant mode
  # ... e.g. "gdwarf" etc as per
  # https://cdcvs.fnal.gov/redmine/projects/build-framework/repository/boost-ssi-build/revisions/master/entry/build_boost.sh

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" PARENT_SCOPE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" PARENT_SCOPE)
  set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS}" PARENT_SCOPE)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}" PARENT_SCOPE)
  set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS}" PARENT_SCOPE)
endfunction()
