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


# TODO: work with ICU.


cmake_minimum_required(VERSION 3.2)

project(LibCMaker_Boost_Compile_Test CXX)

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

# To use our FindBoost.cmake.
list(APPEND CMAKE_MODULE_PATH
  "${PROJECT_SOURCE_DIR}/cmake/LibCMaker_Boost/cmake"
)


#-----------------------------------------------------------------------
# Set path to LibCMaker root
#-----------------------------------------------------------------------

set(LIBCMAKER_SRC_DIR "${PROJECT_SOURCE_DIR}/cmake/LibCMaker")
# Uncomment it if need functions from LibCMaker
#list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")


#-----------------------------------------------------------------------
# Set vars to LibCMaker_Boost and FindBoost
#-----------------------------------------------------------------------

# Standard CMake vars.
#set(BUILD_SHARED_LIBS ON)

# Set required compiler language standards.
set(CMAKE_C_STANDARD 99)    # 11 99 90
set(CMAKE_CXX_STANDARD 11)  # 17 14 11 98

# Vars to lib_cmaker_boost().
set(BOOST_lib_VERSION     "1.64.0")
set(BOOST_lib_COMPONENTS  filesystem)  # 'system' will also be compiled. 
#set(BOOST_lib_COMPONENTS  all)
set(BOOST_DOWNLOAD_DIR    "${PROJECT_BINARY_DIR}")
set(BOOST_UNPACKED_DIR    "${PROJECT_BINARY_DIR}")
set(BOOST_BUILD_DIR       "${PROJECT_BINARY_DIR}/build_boost")

#set(PRINT_BOOST_DEBUG ON)  # Extra debug info from 'b2' tool.

# Library specific vars.
#set(B2_PROGRAM_PATH "/bin/b2")  # Use 'b2' in specified path.
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

# Build and install only compiled library files to the stage directory.
set(BOOST_BUILD_STAGE OFF)
# Install library files here.
set(BOOST_BUILD_STAGE_DIR "${CMAKE_INSTALL_PREFIX}/stage")


#-----------------------------------------------------------------------
# Build and install the Boost
#-----------------------------------------------------------------------

include(${PROJECT_SOURCE_DIR}/cmake/LibCMaker_Boost/lib_cmaker_boost.cmake)

# Make compile, build and install the library at a config CMake phase.
# For specified boost components dependence components will builded too.

# Install specified library version and components.
lib_cmaker_boost(
  VERSION       ${BOOST_lib_VERSION}
  COMPONENTS    ${BOOST_lib_COMPONENTS}
  DOWNLOAD_DIR  ${BOOST_DOWNLOAD_DIR}
  UNPACKED_DIR  ${BOOST_UNPACKED_DIR}
  BUILD_DIR     ${BOOST_BUILD_DIR}
)

# Install specified library version and only headers.
#lib_cmaker_boost(
#  VERSION       ${BOOST_lib_VERSION}
#  DOWNLOAD_DIR  ${BOOST_DOWNLOAD_DIR}
#  UNPACKED_DIR  ${BOOST_UNPACKED_DIR}
#  BUILD_DIR     ${BOOST_BUILD_DIR}
#)

# Install specified library version and all libs.
#lib_cmaker_boost(
#  VERSION       ${BOOST_lib_VERSION}
#  COMPONENTS    all
#  DOWNLOAD_DIR  ${BOOST_DOWNLOAD_DIR}
#  UNPACKED_DIR  ${BOOST_UNPACKED_DIR}
#  BUILD_DIR     ${BOOST_BUILD_DIR}
#)


#-----------------------------------------------------------------------
# find_package()
#-----------------------------------------------------------------------

# Build test executables.

# Vars to find_project() only. Use to select installed Boost configuration.
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

# 'system' will also be found.
find_package(Boost ${lib_VERSION} REQUIRED COMPONENTS filesystem)


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
  "${BOOST_UNPACKED_DIR}/boost-${BOOST_lib_VERSION}/boost_${BOOST_version_underscore}/"
)
set(lib_EXAMPLES_SRC_DIR ${lib_SRC_DIR}/libs/filesystem/example)

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
