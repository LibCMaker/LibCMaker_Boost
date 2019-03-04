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

#-----------------------------------------------------------------------
# The file is an example of the convenient script for the library build.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Lib's name, version, paths
#-----------------------------------------------------------------------

set(BOOST_lib_NAME        "Boost")
set(BOOST_lib_VERSION     "1.69.0")
# NOTE: this autodetection from 'FindBoost.cmake' is broken for Boost 1.69.0
# for Android shared arm64-v8a build with link error:
# libboost_system.so.1.69.0, needed by install/lib/libboost_filesystem.so, not found
#set(BOOST_lib_COMPONENTS  regex filesystem)  # deps will also be compiled.
set(BOOST_lib_COMPONENTS  regex filesystem system)
set(BOOST_lib_DIR         "${CMAKE_CURRENT_LIST_DIR}")

# To use our Find<LibName>.cmake.
list(APPEND CMAKE_MODULE_PATH "${BOOST_lib_DIR}/cmake/modules")

# Set required compiler language standards.
# Used by LibCMaker_Boost for Boost building.
# It is set in main project.
#set(CMAKE_CXX_STANDARD 11)  # 20 17 14 11 98


#-----------------------------------------------------------------------
# LibCMaker_<LibName> specific vars and options
#-----------------------------------------------------------------------

# Extra debug info from 'b2' tool.
option(BOOST_DEBUG_SHOW_COMMANDS
  "B2 debug: Show commands as they are executed"
  OFF
)
option(BOOST_DEBUG_CONFIGURATION "B2 debug: Diagnose configuration" OFF)
option(BOOST_DEBUG_BUILDING
  "B2 debug: Report which targets are built with what properties"
  OFF
)
option(BOOST_DEBUG_GENERATOR
  "B2 debug: Diagnose generator search/execution"
  OFF
)
option(BOOST_DEBUG_INSTALL
  "Extra debug info from 'b2' tool during the installation phase."
  OFF
)

if(CMAKE_HOST_WIN32)
  # Compresses target paths by abbreviating each component.
  # This option is useful to keep paths from becoming longer
  # than the filesystem supports.
  option(BOOST_ABBREVIATE_PATHS
    "Compresses target paths by abbreviating each component."
    OFF
  )
  # Compresses target paths using an MD5 hash.
  # This option is useful to keep paths from becoming longer
  # than the filesystem supports.
  # This option produces shorter paths than --abbreviate-paths does,
  # but at the cost of making them less understandable.
  option(BOOST_HASH
    "Compresses target paths using an MD5 hash."
    ON
  )
endif()


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

option(BOOST_BUILD_ALL_COMPONENTS "Build all Boost components" OFF)

option(BOOST_REBUILD_OPTION "Rebuild everything" OFF)

set(b2_FILE_NAME "b2")
if(CMAKE_HOST_WIN32)
  set(b2_FILE_NAME "b2.exe")
endif()
set(_b2_program_path "${cmr_INSTALL_DIR}/bin/${b2_FILE_NAME}")

if(EXISTS ${_b2_program_path})
  set(B2_PROGRAM_PATH ${_b2_program_path})  # Use 'b2' in specified path.
endif()

option(BUILD_BCP_TOOL "Build 'bcp' program" OFF)

# Used to build lib and for find_project().
option(Boost_USE_MULTITHREADED "Boost_USE_MULTITHREADED" ON)

# Whether to link to static or shared C and C++ runtime (set 'runtime-link').
# cmr_USE_MSVC_STATIC_RUNTIME must be ON for Boost_USE_STATIC_RUNTIME=ON.
if(MSVC)
  if(BUILD_SHARED_LIBS)
    set(Boost_USE_STATIC_RUNTIME OFF)
  elseif(cmr_USE_MSVC_STATIC_RUNTIME)
    set(Boost_USE_STATIC_RUNTIME ON)
  else()
    set(Boost_USE_STATIC_RUNTIME OFF)
  endif()
else()
  if(BUILD_SHARED_LIBS)
    set(Boost_USE_STATIC_RUNTIME OFF)
  else()
    set(Boost_USE_STATIC_RUNTIME ON)
  endif()
endif()

#set(BOOST_LAYOUT_TYPE "system" CACHE STRING
#  "Determine whether to choose library names and header locations, may be 'versioned', 'tagged' or 'system'"
#)
# Default value in 'cmr_build_rules_boost()'
# is 'versioned' for MSVC and 'system' for others.
#
# From 'b2 --help':
# Determine whether to choose library names and header locations
# such that multiple versions of Boost or multiple compilers
# can be used on the same system.
# -- versioned -- Names of boost binaries include the Boost version number,
# name and version of the compiler and encoded build properties.
# Boost headers are installed in a subdirectory of <HDRDIR>
# whose name contains the Boost version number.
# -- tagged -- Names of boost binaries include the encoded build properties
# such as variant and threading, but do not including compiler name and
# version, or Boost version. This option is useful if you build several
# variants of Boost, using the same compiler.
# -- system -- Binaries names do not include the Boost version number or
# the name and version number of the compiler. Boost headers are installed
# directly into <HDRDIR>. This option is intended for system integrators
# building distribution packages.

option(BOOST_WITHOUT_ICU "Disable Unicode/ICU support in Regex" OFF)

if(NOT BOOST_WITHOUT_ICU)
  # Specify the root of the ICU library installation
  # and enable Unicode/ICU support in Regex.
  set(BOOST_WITH_ICU_DIR "${cmr_INSTALL_DIR}"
    CACHE PATH "Specify the root of the ICU library installation"
  )
endif()

option(BOOST_BUILD_STAGE
  "Build and install only compiled library files to the stage directory"
  OFF
)
if(BOOST_BUILD_STAGE)
  # Install library files here.
  # TODO: use CMAKE_STAGING_PREFIX instead of cmr_INSTALL_DIR?
  set(BOOST_BUILD_STAGE_DIR "${cmr_INSTALL_DIR}/stage"
    CACHE PATH "Stage directory, install library files here."
  )
endif()

set(BOOST_BUILD_FLAGS "" CACHE STRING
  "Additional flags to pass to the b2 tool"
)


#-----------------------------------------------------------------------
# Vars to find_project(Boost) only
#-----------------------------------------------------------------------

# Use to select installed Boost configuration.
# For more vars see in 'cmake/FindBoost.cmake' file.

#set(Boost_USE_MULTITHREADED ON)  # Set above.
#set(Boost_USE_STATIC_RUNTIME ON)  # Set above.

# Here we depend to BUILD_SHARED_LIBS for Boost_USE_STATIC_LIBS.
if(BUILD_SHARED_LIBS)
  set(Boost_USE_STATIC_LIBS OFF)
else()
  set(Boost_USE_STATIC_LIBS ON)
endif()

#set(BOOST_ROOT "${cmr_INSTALL_DIR}" CACHE PATH "BOOST_ROOT")

option(Boost_NO_SYSTEM_PATHS "Boost_NO_SYSTEM_PATHS" ON)


#-----------------------------------------------------------------------
# Build, install and find the library
#-----------------------------------------------------------------------

# For specified boost components dependence components will builded too.

# Install specified library version and components.
cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${BOOST_lib_NAME}
  VERSION         ${BOOST_lib_VERSION}
  COMPONENTS      ${BOOST_lib_COMPONENTS}
  LIB_DIR         ${BOOST_lib_DIR}
  REQUIRED
)

# Install specified library version and only headers.
#cmr_find_package(
#  LibCMaker_DIR   ${LibCMaker_DIR}
#  NAME            ${BOOST_lib_NAME}
#  VERSION         ${BOOST_lib_VERSION}
#  LIB_DIR         ${BOOST_lib_DIR}
#  REQUIRED
#)
