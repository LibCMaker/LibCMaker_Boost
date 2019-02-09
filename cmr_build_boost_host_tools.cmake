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
set(BOOST_lib_VERSION     "1.68.0")
set(BOOST_lib_DIR         "${CMAKE_CURRENT_LIST_DIR}")

# To use our Find<LibName>.cmake.
list(APPEND CMAKE_MODULE_PATH "${BOOST_lib_DIR}/cmake/modules")

# Set required compiler language standards.
# Set in main project.
#set(CMAKE_C_STANDARD 99)    # 11 99 90
#set(CMAKE_CXX_STANDARD 11)  # 17 14 11 98


#-----------------------------------------------------------------------
# LibCMaker_<LibName> specific vars and options
#-----------------------------------------------------------------------

if(DEFINED BUILD_SHARED_LIBS)
  set(tmp_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
endif()
set(BUILD_SHARED_LIBS OFF)  # Always static for host tools.

set(BUILD_HOST_TOOLS ON)

option(PRINT_BOOST_DEBUG "Extra debug info from 'b2' tool" OFF)


#-----------------------------------------------------------------------
# Library specific vars and options
#-----------------------------------------------------------------------

set(BUILD_BCP_TOOL OFF)  # Build 'bcp' program.

option(BOOST_WITHOUT_ICU "Disable Unicode/ICU support in Regex" ON)


#-----------------------------------------------------------------------
# Build, install and find the library
#-----------------------------------------------------------------------

cmr_find_package(
  LibCMaker_DIR   ${LibCMaker_DIR}
  NAME            ${BOOST_lib_NAME}
  VERSION         ${BOOST_lib_VERSION}
  LIB_DIR         ${BOOST_lib_DIR}
  REQUIRED
  FIND_MODULE_NAME BoostHostTools
)

if(DEFINED tmp_BUILD_SHARED_LIBS)
  set(BUILD_SHARED_LIBS ${tmp_BUILD_SHARED_LIBS})
else()
  unset(BUILD_SHARED_LIBS)
endif()
