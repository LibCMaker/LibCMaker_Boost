# ****************************************************************************
#  Project:  LibCMaker_STLCache
#  Purpose:  A CMake build script for STLCache library
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
#
#    This file is part of the LibCMaker_STLCache project.
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

# - Find Boost host tools
# Find the Boost host tools
# This module defines
#  b2_FILE, where to find b2 program
#  bcp_FILE, where to find bcp program
#  BoostHostTools_FOUND, If false, do not try to use Boost host tools.

find_program (b2_FILE
  NAMES b2
  PATH_SUFFIXES bin
  NO_CMAKE_ENVIRONMENT_PATH
  NO_SYSTEM_ENVIRONMENT_PATH
  NO_CMAKE_SYSTEM_PATH
)
mark_as_advanced(b2_FILE)

if(BUILD_BCP_TOOL)
  find_program (bcp_FILE
    NAMES bcp
    PATH_SUFFIXES bin
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
  )
  mark_as_advanced(bcp_FILE)
endif()


# Handle the QUIETLY and REQUIRED arguments and set BoostHostTools_FOUND to TRUE
# if all listed variables are TRUE.
include(FindPackageHandleStandardArgs)
if(BUILD_BCP_TOOL)
  find_package_handle_standard_args(BoostHostTools DEFAULT_MSG b2_FILE bcp_FILE)
else()
  find_package_handle_standard_args(BoostHostTools DEFAULT_MSG b2_FILE)
endif()
