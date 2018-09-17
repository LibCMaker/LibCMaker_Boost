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

cmake_minimum_required(VERSION 3.4)

project(LibCMaker_Boost_Build_Host_Tools_Test C CXX)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(cmr_PRINT_DEBUG ON)
#set(PRINT_BOOST_DEBUG ON)  # Extra debug info from 'b2' tool.


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")


#-----------------------------------------------------------------------
# Set common vars to LibCMaker_Boost
#-----------------------------------------------------------------------

set(BOOST_lib_NAME        "Boost")
set(BOOST_lib_VERSION     "1.64.0")
set(BOOST_lib_DIR         "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_Boost")

# Set required compiler language standards.
set(CMAKE_C_STANDARD 99)    # 11 99 90
set(CMAKE_CXX_STANDARD 11)  # 17 14 11 98

#set(PRINT_BOOST_DEBUG ON)  # Extra debug info from 'b2' tool.


#-----------------------------------------------------------------------
# Library specific common vars and options
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
# Set vars to LibCMaker_Boost to build host tools
#-----------------------------------------------------------------------

set(cmr_UNPACKED_DIR  "${PROJECT_BINARY_DIR}/host_tools_sources")
set(cmr_BUILD_DIR     "${PROJECT_BINARY_DIR}/build_boost_host_tools")

# To use our FindBoostHostTools.cmake.
list(APPEND CMAKE_MODULE_PATH "${BOOST_lib_DIR}/cmake/modules")

set(BUILD_HOST_TOOLS ON)


#-----------------------------------------------------------------------
# Library specific vars and options to build host tools
#-----------------------------------------------------------------------

set(BUILD_BCP_TOOL OFF)  # Build 'bcp' program.

# Disable Unicode/ICU support in Regex.
set(BOOST_WITHOUT_ICU ON)


#-----------------------------------------------------------------------
# Build and install the ICU host tools
#-----------------------------------------------------------------------

if(NOT BOOST_WITHOUT_ICU)
  #-----------------------------------------------------------------------
  # Set common vars to LibCMaker_ICU
  #-----------------------------------------------------------------------

  set(ICU_lib_NAME        "ICU")
  set(ICU_lib_VERSION     "61.1")
  set(ICU_lib_COMPONENTS  i18n uc data)
  set(ICU_lib_DIR         "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_ICU")

  # To use our FindICU.cmake.
  list(APPEND CMAKE_MODULE_PATH "${ICU_lib_DIR}/cmake/modules")

  set(COPY_ICU_CMAKE_BUILD_SCRIPTS ON)


  #-----------------------------------------------------------------------
  # Library specific common vars and options
  #-----------------------------------------------------------------------

  # Compile with strict compiler options
  set(ICU_ENABLE_STRICT ON)
  # Compile with 'm' library.
  set(ICU_USE_LIB_M OFF)
  # Enable auto cleanup of libraries
  set(ICU_ENABLE_AUTO_CLEANUP OFF)
  # Enable draft APIs (and internal APIs)
  set(ICU_ENABLE_DRAFT ON)
  # Add a version suffix to symbols
  set(ICU_ENABLE_RENAMING ON)
  # Enable function and data tracing
  set(ICU_ENABLE_TRACING OFF)
  # Enable plugins
  set(ICU_ENABLE_PLUGINS OFF)
  # Disable dynamic loading
  set(ICU_DISABLE_DYLOAD ON)
  # Use rpath when linking
  set(ICU_ENABLE_RPATH OFF)
  # Compile with 'wxs' or 'w' libraries.
  set(ICU_USE_WCS_OR_W_LIB OFF)

  # Build ICU's icuio library
  set(ICU_ENABLE_ICUIO ON)
  # Build ICU's Paragraph Layout library. icu-le-hb must be available via find_package(icu-le-hb). See http://harfbuzz.org
  set(ICU_ENABLE_LAYOUTEX OFF) # TODO: not released
  # ...
  #set(ICU_ENABLE_LAYOUT OFF)

  # Specify how to package ICU data. Possible values: files, archive, library, static, auto. See http://userguide.icu-project.org/icudata for more info
  set(ICU_DATA_PACKAGING "auto") # TODO: 'files' mode is not released
  # Tag a suffix to the library names
  set(ICU_LIBRARY_SUFFIX "")
  # Build ICU tests
  set(ICU_ENABLE_TESTS OFF) # TODO: not released
  # Build ICU samples
  set(ICU_ENABLE_SAMPLES OFF) # TODO: not released


  #-----------------------------------------------------------------------
  # Set vars to LibCMaker_ICU to build host tools
  #-----------------------------------------------------------------------

  set(BUILD_SHARED_LIBS OFF)  # Always static for host tools.


  #-----------------------------------------------------------------------
  # Library specific vars and options to build host tools
  #-----------------------------------------------------------------------

  # Enable cross compiling
  set(ICU_CROSS_COMPILING OFF)
  # Specify an absolute path to the build directory of an ICU built for the current platform
  set(ICU_CROSS_BUILDROOT "")

  # Build ICU extras
  set(ICU_ENABLE_EXTRAS OFF) # TODO: not released

  # Build ICU's tools
  set(ICU_ENABLE_TOOLS ON)


  #-----------------------------------------------------------------------
  # Build and find the ICU host tools
  #-----------------------------------------------------------------------

  find_package(Threads REQUIRED)

  # TODO: build by COMPONENTS in find_package()

  # Make build and install the library's host tools at a config CMake phase.
  include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)
  cmr_find_package(
    LibCMaker_DIR   ${LibCMaker_DIR}
    NAME            ${ICU_lib_NAME}
    VERSION         ${ICU_lib_VERSION}
    COMPONENTS      ${ICU_lib_COMPONENTS}
    LIB_DIR         ${ICU_lib_DIR}
    REQUIRED
    CUSTOM_LOGIC_FILE
      ${ICU_lib_DIR}/cmake/cmr_find_package_icu_host_tools_custom.cmake
  )

  # ICU_CROSS_BUILDROOT set in cmr_find_package_icu_host_tools_custom.cmake.
endif()


#-----------------------------------------------------------------------
# Build, install and find the Boost host tools
#-----------------------------------------------------------------------

# Make build and install the library at a config CMake phase.
include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)
cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${BOOST_lib_NAME}
  VERSION         ${BOOST_lib_VERSION}
  LIB_DIR         ${BOOST_lib_DIR}
  REQUIRED
  FIND_MODULE_NAME BoostHostTools
)


#-----------------------------------------------------------------------
# Stub target
#-----------------------------------------------------------------------


add_custom_target(build_host_tools ALL
  COMMAND ${CMAKE_COMMAND} -E echo
    "Host tools are ready in ${b2_FILE}."
)
