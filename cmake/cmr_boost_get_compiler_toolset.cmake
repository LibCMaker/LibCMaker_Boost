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

function(cmr_boost_get_compiler_toolset)
  set(toolset_version "")

  # http://stackoverflow.com/a/10055571
  if(ANDROID)
    set(toolset_name "${ANDROID_TOOLCHAIN}")
    if(toolset_name MATCHES "clang")
      set(toolset_name "${toolset_name}-linux")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    if(APPLE)
      set(toolset_name "darwin")
    else()
      set(toolset_name "gcc")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    set(toolset_name "clang-darwin")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    if(WIN32)
      set(toolset_name "clang-win")
    elseif("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
      set(toolset_name "clang-linux")
    else()
      set(toolset_name "clang")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    set(toolset_name "intel")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(toolset_name "msvc")
    if(CMAKE_GENERATOR_TOOLSET MATCHES "v140")
      set(toolset_version "14.0")
    elseif(CMAKE_GENERATOR_TOOLSET MATCHES "v141")
      set(toolset_version "14.1")
    endif()
  elseif()
    cmr_print_error("Unsupported compiler system.")
  endif()

#  if(ANDROID)
#    set(toolset_version "ndk")
#  endif()

  set(toolset_full_name ${toolset_name})
  string(COMPARE NOTEQUAL "${toolset_version}" "" has_toolset_version)
  if(has_toolset_version)
    set(toolset_full_name ${toolset_name}-${toolset_version})
  endif()

  set(use_cmake_archiver TRUE)
  if(APPLE)
    # TODO: for both gcc and clang or only for gcc?
    # Using CMAKE_AR on OSX leads to error (b2 use 'libtool'):
    # * https://travis-ci.org/ingenue/bcm/jobs/204617507
    set(use_cmake_archiver FALSE)
  endif()

  set(boost_compiler "${CMAKE_CXX_COMPILER}")
  if(MSVC)
#    string(REPLACE "/" "\\" boost_compiler "${boost_compiler}")  # NOTE: no not work with MSVC in bash.
  endif()

  # TODO: mpi
  set(using_mpi "")
  set(copy_mpi_command "")

  set(toolset_name ${toolset_name} PARENT_SCOPE)
  set(toolset_version ${toolset_version} PARENT_SCOPE)
  set(toolset_full_name ${toolset_full_name} PARENT_SCOPE)
  set(use_cmake_archiver ${use_cmake_archiver} PARENT_SCOPE)
  set(boost_compiler ${boost_compiler} PARENT_SCOPE)
  set(using_mpi ${using_mpi} PARENT_SCOPE)
  set(copy_mpi_command ${copy_mpi_command} PARENT_SCOPE)
endfunction()
