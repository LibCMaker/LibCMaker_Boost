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

# Part of "LibCMaker/cmake/cmr_find_package.cmake".

# See description for "cmr_boost_cmaker()" for params and vars.

  #-----------------------------------------------------------------------
  # Library specific build arguments
  #-----------------------------------------------------------------------

## +++ Common part of the lib_cmaker_<lib_name> function +++
  set(find_LIB_VARS
    B2_PROGRAM_PATH
    BUILD_BCP_TOOL
    Boost_USE_MULTITHREADED
    Boost_USE_STATIC_RUNTIME
    BOOST_DEBUG_SHOW_COMMANDS
    BOOST_DEBUG_CONFIGURATION
    BOOST_DEBUG_BUILDING
    BOOST_DEBUG_GENERATOR
    BOOST_DEBUG_INSTALL
    BOOST_ABBREVIATE_PATHS
    BOOST_HASH
    BOOST_REBUILD_OPTION
    BOOST_BUILD_ALL_COMPONENTS
    BOOST_BUILD_STAGE
    BOOST_BUILD_STAGE_DIR
    BOOST_BUILD_FLAGS
    BOOST_LAYOUT_TYPE
    BOOST_WITHOUT_ICU
    BOOST_WITH_ICU_DIR
  )

  foreach(d ${find_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND find_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

  set(lib_LANGUAGES CXX C ASM)
  set(lib_BUILD_MODE INSTALL)

  if(BUILD_HOST_TOOLS)
    cmr_print_status("======== Build host tools for cross building ========")
    set(lib_BUILD_MODE BUILD_HOST_TOOLS INSTALL)
  elseif(B2_PROGRAM_PATH)
    cmr_print_status(
      "======== Cross building with 'b2' tool in ${B2_PROGRAM_PATH} ========"
    )
    list(APPEND find_CMAKE_ARGS
      -DB2_PROGRAM_PATH=${B2_PROGRAM_PATH}
    )
  endif()

  cmr_lib_cmaker_main(
    LibCMaker_DIR ${find_LibCMaker_DIR}
    NAME          ${find_NAME}
    VERSION       ${find_VERSION}
    COMPONENTS    ${find_COMPONENTS}
    LANGUAGES     ${lib_LANGUAGES}
    BASE_DIR      ${find_LIB_DIR}
    DOWNLOAD_DIR  ${cmr_DOWNLOAD_DIR}
    UNPACKED_DIR  ${cmr_UNPACKED_DIR}
    BUILD_DIR     ${lib_BUILD_DIR}
    CMAKE_ARGS    ${find_CMAKE_ARGS}
    ${lib_BUILD_MODE}
  )
