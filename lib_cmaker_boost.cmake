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


# See description for "cmr_boost_cmaker()" for params and vars.


## +++ Common part of the lib_cmaker_<lib_name> function +++
set(lib_NAME "Boost")

# To find library's LibCMaker source dir.
set(lcm_${lib_NAME}_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root.")
endif()

include(${LIBCMAKER_SRC_DIR}/cmake/modules/lib_cmaker_init.cmake)

function(lib_cmaker_boost)

  # Make the required checks.
  # Add library's and common LibCMaker module paths to CMAKE_MODULE_PATH.
  # Unset lcm_CMAKE_ARGS.
  # Set vars:
  #   cmr_CMAKE_MIN_VER
  #   cmr_lib_cmaker_main_PATH
  #   cmr_printers_PATH
  #   lower_lib_NAME
  # Parce args and set vars:
  #   arg_VERSION
  #   arg_COMPONENTS
  #   arg_DOWNLOAD_DIR
  #   arg_UNPACKED_DIR
  #   arg_BUILD_DIR
  lib_cmaker_init(${ARGN})

  include(${cmr_lib_cmaker_main_PATH})
  include(${cmr_printers_PATH})

  cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Library specific build arguments
  #-----------------------------------------------------------------------
  
  set(lib_LANGUAGES CXX C ASM)

## +++ Common part of the lib_cmaker_<lib_name> function +++
  set(cmr_LIB_VARS
    B2_PROGRAM_PATH
    BUILD_BCP_TOOL
    Boost_USE_MULTITHREADED
    Boost_USE_STATIC_RUNTIME
    PRINT_BOOST_DEBUG
    BOOST_BUILD_STAGE
    BOOST_BUILD_STAGE_DIR
    BOOST_LAYOUT_TYPE
  )

  foreach(d ${cmr_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND lcm_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
## --- Common part of the lib_cmaker_<lib_name> function ---


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

  # Build tools for cross building if need
  if(IOS OR ANDROID OR WINDOWS_STORE)

    if(NOT B2_PROGRAM_PATH)
      include(GNUInstallDirs)
      set(b2_FILE_NAME "b2")
      if(WIN32)
        set(b2_FILE_NAME "b2.exe")
      endif()
      
      set(_b2_program_path "${CMAKE_INSTALL_FULL_BINDIR}/${b2_FILE_NAME}")
  
      if(NOT EXISTS ${_b2_program_path})
        cmr_print_message("-------- Build tools for cross building --------")
    
        cmr_lib_cmaker_main(
          NAME          ${lib_NAME}
          VERSION       ${arg_VERSION}
          COMPONENTS    ${arg_COMPONENTS}
          BASE_DIR      ${lcm_${lib_NAME}_SRC_DIR}
          DOWNLOAD_DIR  ${arg_DOWNLOAD_DIR}
          UNPACKED_DIR  ${arg_UNPACKED_DIR}/host_tools_sources
          BUILD_DIR     ${arg_BUILD_DIR}_host_tools
          CMAKE_ARGS    ${lcm_CMAKE_ARGS}
          BUILD_HOST_TOOLS
          INSTALL
        )
      endif()
  
      set(B2_PROGRAM_PATH "${_b2_program_path}"
        CACHE PATH "Specify an absolute path to the 'b2' tool."
      )
      list(APPEND lcm_CMAKE_ARGS
        -DB2_PROGRAM_PATH=${B2_PROGRAM_PATH}
      )
    endif()

    cmr_print_message(
      "-------- Cross building with 'b2' tool in ${B2_PROGRAM_PATH} --------"
    )
    
    cmr_lib_cmaker_main(
      NAME          ${lib_NAME}
      VERSION       ${arg_VERSION}
      COMPONENTS    ${arg_COMPONENTS}
      BASE_DIR      ${lcm_${lib_NAME}_SRC_DIR}
      DOWNLOAD_DIR  ${arg_DOWNLOAD_DIR}
      UNPACKED_DIR  ${arg_UNPACKED_DIR}
      BUILD_DIR     ${arg_BUILD_DIR}
      CMAKE_ARGS    ${lcm_CMAKE_ARGS}
      BUILD
    )

  else()  # if(NOT (IOS OR ANDROID OR WINDOWS_STORE))
    cmr_lib_cmaker_main(
      NAME          ${lib_NAME}
      VERSION       ${arg_VERSION}
      COMPONENTS    ${arg_COMPONENTS}
      BASE_DIR      ${lcm_${lib_NAME}_SRC_DIR}
      DOWNLOAD_DIR  ${arg_DOWNLOAD_DIR}
      UNPACKED_DIR  ${arg_UNPACKED_DIR}
      BUILD_DIR     ${arg_BUILD_DIR}
      CMAKE_ARGS    ${lcm_CMAKE_ARGS}
      INSTALL
    )
  endif()
endfunction()
