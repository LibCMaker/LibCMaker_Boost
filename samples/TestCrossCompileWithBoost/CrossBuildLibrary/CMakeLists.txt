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

cmake_minimum_required(VERSION 3.3)

project(LibCMaker_Boost_Cross_Compile_Test C CXX)

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
# Set vars to LibCMaker_Boost to cross build
#-----------------------------------------------------------------------

set(BOOST_lib_COMPONENTS  regex)
#set(BOOST_lib_COMPONENTS  filesystem)  # 'system' will also be compiled.
#set(BOOST_lib_COMPONENTS  all)

# To use below for sample sources.
set(cmr_UNPACKED_DIR ${CMAKE_CURRENT_BINARY_DIR}/download/unpacked)

# To use our FindBoost.cmake.
list(APPEND CMAKE_MODULE_PATH "${BOOST_lib_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# Library specific vars and options to cross build
#-----------------------------------------------------------------------

set(b2_FILE_NAME "b2")
if(CMAKE_HOST_WIN32)
  set(b2_FILE_NAME "b2.exe")
endif()
set(_b2_program_path
  "${PROJECT_BINARY_DIR}/@_host_tools/inst/bin/${b2_FILE_NAME}"
)

set(B2_PROGRAM_PATH ${_b2_program_path})  # Use 'b2' in specified path.
set(BUILD_BCP_TOOL OFF)  # Build 'bcp' program.
set(Boost_USE_MULTITHREADED ON)  # Use to build lib and for find_project().
# Whether to link to static or shared C and C++ runtime.
# If DEFINED then add 'runtime-link' to 'b2' tool with value
# 'static' for 'ON' or 'shared' for OFF.
#set(Boost_USE_STATIC_RUNTIME ON)

# Determine whether to choose library names and header locations.
set(BOOST_LAYOUT_TYPE "tagged")  # "versioned", "tagged" or "system",
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

# Disable Unicode/ICU support in Regex.
set(BOOST_WITHOUT_ICU OFF)

# Specify the root of the ICU library installation
# and enable Unicode/ICU support in Regex.
#set(BOOST_WITH_ICU_DIR "DIR")  # See setting below.

# Build and install only compiled library files to the stage directory.
set(BOOST_BUILD_STAGE OFF)
# Install library files here.
set(BOOST_BUILD_STAGE_DIR "${CMAKE_INSTALL_PREFIX}/stage")


#-----------------------------------------------------------------------
# Build and install the ICU
#-----------------------------------------------------------------------

if(NOT BOOST_WITHOUT_ICU)
  #-----------------------------------------------------------------------
  # Set common vars to LibCMaker_ICU
  #-----------------------------------------------------------------------

  set(ICU_lib_NAME     "ICU")
  set(ICU_lib_VERSION  "61.1")
  set(ICU_lib_DIR      "${CMAKE_CURRENT_LIST_DIR}/cmake/LibCMaker_ICU")

  # To use our FindICU.cmake.
  list(APPEND CMAKE_MODULE_PATH "${ICU_lib_DIR}/cmake/modules")

  set(COPY_ICU_CMAKE_BUILD_SCRIPTS ON)


  #-----------------------------------------------------------------------
  # Library specific common vars and options
  #-----------------------------------------------------------------------

  # Compile with strict compiler options
  set(ICU_ENABLE_STRICT ON)
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
  set(ICU_DISABLE_DYLOAD OFF)
  # Use rpath when linking
  set(ICU_ENABLE_RPATH OFF)

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
  # Set vars to LibCMaker_ICU to cross build
  #-----------------------------------------------------------------------

  # Enable cross compiling
  set(ICU_CROSS_COMPILING ON)
  # Specify an absolute path to the build directory of an ICU built for the current platform
  set(ICU_CROSS_BUILDROOT
    "${PROJECT_BINARY_DIR}/@_host_tools/build_icu_host_tools/build_ICU/icu-${ICU_lib_VERSION}/source"
  )


  # Build ICU extras
  set(ICU_ENABLE_EXTRAS OFF) # TODO: not released

  # Build ICU's tools
  set(ICU_ENABLE_TOOLS OFF)


  #-----------------------------------------------------------------------
  # Cross build, install and find the ICU
  #-----------------------------------------------------------------------

  # TODO: build by COMPONENTS in find_package()

  # Make build and install the library at a config CMake phase.
  include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)
  cmr_find_package(
    LibCMaker_DIR   ${LibCMaker_DIR}
    NAME            ${ICU_lib_NAME}
    VERSION         ${ICU_lib_VERSION}
  #  COMPONENTS      TODO
    LIB_DIR         ${ICU_lib_DIR}
    REQUIRED
    CONFIG
  )


  set(BOOST_WITH_ICU_DIR "${CMAKE_INSTALL_PREFIX}")  # See description above.
endif()


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

#set(BOOST_ROOT ${CMAKE_INSTALL_PREFIX})
set(Boost_NO_SYSTEM_PATHS ON)


#-----------------------------------------------------------------------
# Build, install and find the Boost
#-----------------------------------------------------------------------

# 'system' will also be built and found.

# Make build and install the library at a config CMake phase.
# For specified boost components dependence components will builded too.
include(${LibCMaker_DIR}/cmake/cmr_find_package.cmake)

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

# Install specified library version and all libs.
#cmr_find_package(
#  LibCMaker_DIR   ${LibCMaker_DIR}
#  NAME            ${BOOST_lib_NAME}
#  VERSION         ${BOOST_lib_VERSION}
#  COMPONENTS      all
#  LIB_DIR         ${BOOST_lib_DIR}
#  REQUIRED
#)


#-----------------------------------------------------------------------
# Link to the library
#-----------------------------------------------------------------------

# Build test executables.

# To run it on Linux with the shared libs
# which are built with non standard path in CMAKE_INSTALL_PREFIX use:
# LD_LIBRARY_PATH="<${CMAKE_INSTALL_PREFIX}>/lib:.:$LD_LIBRARY_PATH" ./LibCMaker_Boost_Compile_Test_2
# where <${CMAKE_INSTALL_PREFIX}> is path which is used
# as value for CMAKE_INSTALL_PREFIX.

# Get an example sources from the lib sources.
set(BOOST_version_underscore "1_64_0")
set(lib_SRC_DIR
  "${cmr_UNPACKED_DIR}/boost-${BOOST_lib_VERSION}/boost_${BOOST_version_underscore}"
)
set(lib_EXAMPLES_SRC_DIR ${lib_SRC_DIR}/libs/filesystem/example)
# TODO: add compilation of filesystem example.

# Example #1
add_executable(${PROJECT_NAME} test_header.cpp)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

# Boost
#target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} Boost::boost)

# Example #2
add_executable(${PROJECT_NAME}_2 test_compiled.cpp)
set_property(TARGET ${PROJECT_NAME}_2 PROPERTY CXX_STANDARD 11)

# Boost
#target_include_directories(${PROJECT_NAME}_2 PRIVATE ${Boost_INCLUDE_DIRS})
#target_link_libraries(${PROJECT_NAME}_2 ${Boost_LIBRARIES})

# 'system' will also be added as IMPORT library.
target_link_libraries(${PROJECT_NAME}_2 Boost::filesystem)
