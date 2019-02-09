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

cmake_minimum_required(VERSION 3.4)

# FindThreads work in environments, where only CXX is enabled, since CMake 3.4.
project(LibCMaker_Boost_Build_Host_Tools_Test CXX)

option(CMAKE_VERBOSE_MAKEFILE "CMAKE_VERBOSE_MAKEFILE" OFF)
option(cmr_PRINT_DEBUG "cmr_PRINT_DEBUG" OFF)


#-----------------------------------------------------------------------
# Configure to find_package()
#-----------------------------------------------------------------------

# Set CMake's search path for find_*() commands.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")

if(ANDROID)
  list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_INSTALL_PREFIX}")
endif()


#-----------------------------------------------------------------------
# Set path vars
#-----------------------------------------------------------------------

if(NOT LibCMaker_LIB_DIR)
  message(FATAL_ERROR
    "Please set LibCMaker_LIB_DIR with path to LibCMaker's libraries directory.")
endif()
if(NOT HOST_TOOLS_STAMP_FILE_NAME)
  message(FATAL_ERROR
    "Please set HOST_TOOLS_STAMP_FILE_NAME with name of stamp file.")
endif()

set(LibCMaker_DIR "${LibCMaker_LIB_DIR}/LibCMaker")
set(cmr_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}")

if(NOT cmr_UNPACKED_DIR)
  set(cmr_UNPACKED_DIR "${PROJECT_BINARY_DIR}/download/unpacked_host_tools")
endif()
if(NOT cmr_BUILD_DIR)
  set(cmr_BUILD_DIR "${PROJECT_BINARY_DIR}")
endif()


#-----------------------------------------------------------------------
# LibCMaker settings
#-----------------------------------------------------------------------

set(LibCMaker_DIR "${LibCMaker_LIB_DIR}/LibCMaker")
list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")
include(cmr_find_package)


#-----------------------------------------------------------------------
# Download, configure, build, install and find the required libraries
#-----------------------------------------------------------------------

if(NOT BOOST_WITHOUT_ICU)
  include(${LibCMaker_LIB_DIR}/LibCMaker_ICU/cmr_build_icu_host_tools.cmake)
endif()
include(${LibCMaker_LIB_DIR}/LibCMaker_Boost/cmr_build_boost_host_tools.cmake)


#-----------------------------------------------------------------------
# Stub target
#-----------------------------------------------------------------------

add_custom_target(${PROJECT_NAME} ALL
  COMMAND ${CMAKE_COMMAND} -E touch
    "${PROJECT_BINARY_DIR}/${HOST_TOOLS_STAMP_FILE_NAME}"
  COMMAND ${CMAKE_COMMAND} -E echo
    "Host tools are ready."
)
