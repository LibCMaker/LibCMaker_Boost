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

if(DEFINED BUILD_SHARED_LIBS)
  set(tmp_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
endif()
set(BUILD_SHARED_LIBS OFF)  # Always static for host tools.

set(BUILD_HOST_TOOLS ON)

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

option(BOOST_REBUILD_OPTION "Rebuild everything" OFF)

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
