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

# Part of "LibCMaker/cmake/modules/cmr_build_rules.cmake".


  # Based on the BoostBuilder:
  # https://github.com/drbenmorgan/BoostBuilder
  # Based on the build-boost.sh from CrystaX NDK:
  # https://www.crystax.net/
  # https://github.com/crystax/android-platform-ndk/blob/master/build/tools/build-boost.sh
  # Based on the Hunter:
  # https://github.com/ruslo/hunter
  
  
  # CMake build/bundle script for Boost Libraries.
  # Automates build of Boost, allowing optional builds of library components.
  
  
  # Useful vars:
  #   BUILD_SHARED_LIBS         -- build shared libs.
  #   Boost_USE_MULTITHREADED   -- build multithread (-mt) libs, default is ON.
  #   Boost_USE_STATIC_RUNTIME  -- link to static or shared C and C++ runtime.
  #   BOOST_LAYOUT_TYPE         -- choose library names and header locations,
  #                                "versioned", "tagged" or "system",
  #   BOOST_WITHOUT_ICU         -- disable Unicode/ICU support in Regex.
  #   BOOST_WITH_ICU_DIR        -- root of the ICU library installation.
  #
  #   BOOST_BUILD_STAGE       -- build and install only compiled library files.
  #   BOOST_BUILD_STAGE_DIR   -- Install library files here.
  #
  #   cmr_PRINT_DEBUG
  #
  #   lib_DOWNLOAD_DIR  -- for downloaded files
  #   lib_UNPACKED_DIR  -- for unpacked sources
  #   lib_BUILD_DIR     -- for build files
  #
  #   lib_BUILD_HOST_TOOLS -- build only 'b2' program and 'bcp' if specified.
  #   BUILD_BCP_TOOL       -- build 'bcp' program.
  #   B2_PROGRAM_PATH      -- Use 'b2' in specified path.
  #
  #   lib_VERSION "1.64.0"
  #     Version of boost library.
  #
  #   lib_COMPONENTS regex filesystem
  #     List libraries to build. Dependence libs will builded too.
  #     By default will installed only header lib.
  #     May be "all" to build all boost libs,
  #     in this case, there must be only one keyword "all".
  #     The complete list of libraries provided by Boost can be found by
  #     running the bootstrap.sh script supplied with Boost as:
  #       ./bootstrap.sh --with-libraries=all --show-libraries


  # "Boost.Build User Manual"
  # https://boostorg.github.io/build/manual/develop/


  #-----------------------------------------------------------------------
  # Initialization
  #
  include(GNUInstallDirs)
  
  set(boost_modules_DIR "${lib_BASE_DIR}/cmake/modules")

  cmr_print_message("Copy 'boost/config/user.hpp' to unpacked sources.")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
      ${lib_BASE_DIR}/boost/config/user.hpp
      ${lib_SRC_DIR}/boost/config/user.hpp
  )
  

  #-----------------------------------------------------------------------
  # Check COMPONENTS and get lib list
  #
  include(cmr_boost_get_lib_list)
  cmr_boost_get_lib_list(
    boost_LIB_LIST VERSION ${lib_VERSION} COMPONENTS ${lib_COMPONENTS}
  )


  #-----------------------------------------------------------------------
  # bootstrap_ARGS
  #
  set(bootstrap_ARGS)
  # TODO: for MINGW
  #if(MINGW)
  #  list(APPEND bootstrap_ARGS "gcc")
  #endif()
  if(ANDROID)
    # TODO: add work with ICU
    list(APPEND bootstrap_ARGS "--without-icu")
  endif()


  #-----------------------------------------------------------------------
  # Unicode/ICU support in Regex
  #
  if(BOOST_WITHOUT_ICU)
    # Disable Unicode/ICU support in Regex.
    list(APPEND bootstrap_ARGS
      "--without-icu"
    )
  elseif(BOOST_WITH_ICU_DIR)
    # Specify the root of the ICU library installation
    # and enable Unicode/ICU support in Regex.
    list(APPEND bootstrap_ARGS
      "--with-icu=${BOOST_WITH_ICU_DIR}"
    )
  endif()


  #-----------------------------------------------------------------------
  # common_b2_ARGS
  #
  set(common_b2_ARGS)
  list(APPEND common_b2_ARGS "-a") # Rebuild everything
  list(APPEND common_b2_ARGS "-q") # Stop at first error
  
  if(cmr_PRINT_DEBUG AND PRINT_BOOST_DEBUG)
    # Show commands as they are executed
    list(APPEND common_b2_ARGS "-d+2")
    # Diagnose configuration
    list(APPEND common_b2_ARGS "--debug-configuration")
    # Report which targets are built with what properties
    list(APPEND common_b2_ARGS "--debug-building")
    # Diagnose generator search/execution
    list(APPEND common_b2_ARGS "--debug-generator")
  else()
    # Suppress all informational messages
    list(APPEND common_b2_ARGS "-d0")
  endif()
  
  # Parallelize build if possible
  if(NOT DEFINED cmr_BUILD_MULTIPROC)
    set(cmr_BUILD_MULTIPROC ON)
  endif()
  if(cmr_BUILD_MULTIPROC AND NOT DEFINED cmr_BUILD_MULTIPROC_CNT)
    set(cmr_BUILD_MULTIPROC_CNT "1")
    include(ProcessorCount) # ProcessorCount
    ProcessorCount(CPU_CNT)
    if(CPU_CNT GREATER 0)
      set(cmr_BUILD_MULTIPROC_CNT ${CPU_CNT})
    endif()
    list(APPEND common_b2_ARGS "-j" "${cmr_BUILD_MULTIPROC_CNT}")
  endif()
  
  # Build in this location instead of building within the distribution tree.
  list(APPEND common_b2_ARGS
    "--build-dir=${lib_VERSION_BUILD_DIR}"
  )


  #-----------------------------------------------------------------------
  # bcp_b2_ARGS
  #
  # We need to use a custom set of layout and toolset arguments
  # for bcp building to prevent "duplicate target" errors.
  set(bcp_b2_ARGS)
  list(APPEND bcp_b2_ARGS ${common_b2_ARGS})


  #-----------------------------------------------------------------------
  # Run bootstrap script and build b2 (bjam) if required
  #
  if(DEFINED B2_PROGRAM_PATH AND NOT EXISTS ${B2_PROGRAM_PATH})
    cmr_print_fatal_error(
      "B2_PROGRAM_PATH is defined as\n'${B2_PROGRAM_PATH}'\n and there is not 'b2' tool in this path."
    )
  endif()

  if(B2_PROGRAM_PATH)
    set(b2_FILE ${B2_PROGRAM_PATH})
    list(APPEND bootstrap_ARGS "--with-bjam=${b2_FILE}")
  else()
    set(b2_FILE_NAME "b2")
    unset(b2_FILE CACHE)
    find_program(b2_FILE NAMES ${b2_FILE_NAME}
      PATHS ${lib_SRC_DIR} NO_DEFAULT_PATH
    )
    if(NOT b2_FILE)
      if(CMAKE_HOST_WIN32)
        set(b2_FILE_NAME "b2.exe")
      endif()
      set(b2_FILE "${lib_SRC_DIR}/${b2_FILE_NAME}")
    endif()
  endif()

  if(cmr_PRINT_DEBUG)
    cmr_print_debug_message(
      "bootstrap.sh options:")
    cmr_print_debug_message("------")
    foreach(opt ${bootstrap_ARGS})
      cmr_print_debug_message("  ${opt}")
    endforeach()
    cmr_print_debug_message("------")
  endif()

  set(bootstrap_FILE_NAME "bootstrap.sh")
  if(CMAKE_HOST_WIN32)
    set(bootstrap_FILE_NAME "bootstrap.bat")
  endif()
  set(bootstrap_FILE "${lib_SRC_DIR}/${bootstrap_FILE_NAME}")
  set(bootstrap_STAMP "${lib_VERSION_BUILD_DIR}/bootstrap_stamp")
  
  # Add the files in the source tree:
  #   <boost sources>/b2
  #   <boost sources>/bjam
  #   <boost sources>/bootstrap.log
  #   <boost sources>/project-config.jam
  #   <boost sources>/tools/build/src/engine/bin.*/*
  #   <boost sources>/tools/build/src/engine/bootstrap/*
  add_custom_command(OUTPUT ${bootstrap_STAMP}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${lib_VERSION_BUILD_DIR}
    COMMAND ${bootstrap_FILE} ${bootstrap_ARGS}
    COMMAND ${CMAKE_COMMAND} -E touch ${bootstrap_STAMP}
    WORKING_DIRECTORY ${lib_SRC_DIR}
    COMMENT "Run bootstrap script."
  )

  if(lib_BUILD_HOST_TOOLS AND NOT BUILD_BCP_TOOL)
    add_custom_target(run_bootstrap ALL
      DEPENDS ${bootstrap_STAMP}
    )
  endif()

  if(NOT B2_PROGRAM_PATH)
    install(
      PROGRAMS ${b2_FILE}
      DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
  endif()


  #-----------------------------------------------------------------------
  # Build and install bcp program if required
  #
  if(BUILD_BCP_TOOL)
    if(cmr_PRINT_DEBUG)
      cmr_print_debug_message("b2 options for 'bcp' tool building:")
      cmr_print_debug_message("------")
      foreach(opt ${bcp_b2_ARGS})
        cmr_print_debug_message("  ${opt}")
      endforeach()
      cmr_print_debug_message("------")
    endif()

    set(bcp_FILE_NAME "bcp")
    if(CMAKE_HOST_WIN32)
      set(bcp_FILE_NAME "bcp.exe")
    endif()
    set(bcp_FILE "${lib_SRC_DIR}/dist/bin/${bcp_FILE_NAME}")

    # Add the files in the source tree:
    #   <boost sources>/dist/*
    add_custom_command(OUTPUT ${bcp_FILE}
      COMMAND
        ${b2_FILE} ${bcp_b2_ARGS} "${lib_SRC_DIR}/tools/bcp"
      WORKING_DIRECTORY ${lib_SRC_DIR}
      DEPENDS ${bootstrap_STAMP}
      COMMENT "Build 'bcp' tool."
    )
    
    if(lib_BUILD_HOST_TOOLS)
      add_custom_target(build_bcp ALL
        DEPENDS ${bcp_FILE}
      )
    endif()
    
    install(
      PROGRAMS ${bcp_FILE}
      DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
  endif()

  
  #-----------------------------------------------------------------------
  # Return if build tools only
  #
  if(lib_BUILD_HOST_TOOLS)
    return()  # Return to cmr_build_rules().
  endif()


  #-----------------------------------------------------------------------
  # b2_args
  #
  set(b2_ARGS)
  list(APPEND b2_ARGS ${common_b2_ARGS})
  
  if(boost_LIB_LIST)
    list(APPEND b2_ARGS ${boost_LIB_LIST})
  endif()


  #-----------------------------------------------------------------------
  # Install options and directories
  #
  if(lib_BUILD)
    if(BOOST_BUILD_STAGE AND BOOST_BUILD_STAGE_DIR)
      # Build and install only compiled library files to the stage directory.
      list(APPEND b2_ARGS "stage")
  
      # Install library files here.
      list(APPEND b2_ARGS
        "--stagedir=${BOOST_BUILD_STAGE_DIR}"
      )
    else()
      # Install headers and compiled library files to the configured locations.
      list(APPEND b2_ARGS "install")
  
      # Install architecture independent files here
      list(APPEND b2_ARGS
        "--prefix=${CMAKE_INSTALL_PREFIX}"
      )
      # Install header files here
      list(APPEND b2_ARGS
        "--includedir=${CMAKE_INSTALL_FULL_INCLUDEDIR}"
      )
      # Install library files here
      list(APPEND b2_ARGS
        "--libdir=${CMAKE_INSTALL_FULL_LIBDIR}"
      )
    endif()
  endif()


  #-----------------------------------------------------------------------
  # Compiler toolset
  #
  include(cmr_boost_get_compiler_toolset)
  cmr_boost_get_compiler_toolset()
  # Out vars:
  # -> toolset_name
  # -> toolset_version
  # -> toolset_full_name
  # -> use_cmake_archiver
  # -> boost_compiler
  # -> using_mpi
  # -> copy_mpi_command

  list(APPEND b2_ARGS "toolset=${toolset_full_name}")


  #-----------------------------------------------------------------------
  # Build variants
  #
  include(cmr_boost_get_build_variants)
  cmr_boost_get_build_variants(build_variants)
  # Use:
  # -> BUILD_SHARED_LIBS
  # -> Boost_USE_MULTITHREADED  # Set to ON by default.
  
  list(APPEND b2_ARGS ${build_variants})


  #-----------------------------------------------------------------------
  # OS specifics
  #
  include(cmr_boost_get_os_specifics)
  cmr_boost_get_os_specifics(os_specifics)
  list(APPEND b2_ARGS ${os_specifics})


  #-----------------------------------------------------------------------
  # Compiler and linker flags
  #
  # If Clang then
  #   CMAKE_C99_EXTENSION_COMPILE_OPTION '-std=gnu99'
  #   CMAKE_CXX11_EXTENSION_COMPILE_OPTION '-std=gnu++11'
  # So disable it.
  set(CMAKE_C_EXTENSIONS OFF)
  set(CMAKE_CXX_EXTENSIONS OFF)
  
  include(cmr_boost_set_cmake_flags)
  cmr_boost_set_cmake_flags()
  # Out vars:
  # -> CMAKE_C_FLAGS
  # -> CMAKE_CXX_FLAGS
  # -> CMAKE_ASM_FLAGS
  # -> CMAKE_SHARED_LINKER_FLAGS
  
  if(BUILD_SHARED_LIBS)
    set(jam_link_FLAGS ${CMAKE_SHARED_LINKER_FLAGS})
  else()
    set(jam_link_FLAGS ${CMAKE_STATIC_LINKER_FLAGS})
  endif()


  #-----------------------------------------------------------------------
  # Generate 'user-config.jam' file
  #
  # Instead of CMAKE_BUILD_TYPE and etc., use the $<CONFIG:Debug> or similar.
  # https://stackoverflow.com/a/24470998
  set(jam_CMAKE_FILE
    "${boost_modules_DIR}/cmr_boost_generate_user_config_jam.cmake"
  )
  set(user_jam_FILE "${lib_VERSION_BUILD_DIR}/user-config.jam")
  
  add_custom_command(OUTPUT ${user_jam_FILE}
    COMMAND ${CMAKE_COMMAND}
      -DLIBCMAKER_SRC_DIR=${LIBCMAKER_SRC_DIR}
      -Duser_jam_FILE=${user_jam_FILE}
      -Dtoolset_name=${toolset_name}
      -Dtoolset_version=${toolset_version}
      -Dboost_compiler=${boost_compiler}
      -Duse_cmake_archiver=${use_cmake_archiver}
      -Dusing_mpi=${using_mpi}
      -Dbuild_TYPE="$<UPPER_CASE:$<CONFIG>>"
      -Djam_c_FLAGS="\"${CMAKE_C_FLAGS}\""
      -Djam_cxx_FLAGS="\"${CMAKE_CXX_FLAGS}\""
      -Djam_asm_FLAGS="\"${CMAKE_ASM_FLAGS}\""
      -Djam_link_FLAGS="\"${jam_link_FLAGS}\""
      -Djam_AR=${CMAKE_AR}
      -Djam_RANLIB=${CMAKE_RANLIB}
      -Dcmr_PRINT_DEBUG=${cmr_PRINT_DEBUG}
      -P ${jam_CMAKE_FILE}
    WORKING_DIRECTORY ${lib_VERSION_BUILD_DIR}
    DEPENDS ${bootstrap_STAMP}
    COMMENT "Generate 'user-config.jam' file."
  )

  list(APPEND b2_ARGS "--user-config=${user_jam_FILE}")


  #-----------------------------------------------------------------------
  # Build boost library
  #
  if(cmr_PRINT_DEBUG)
    cmr_print_debug_message("b2 options for Boost library building:")
    cmr_print_debug_message("------")
    foreach(opt ${b2_ARGS})
      cmr_print_debug_message("  ${opt}")
    endforeach()
    cmr_print_debug_message("------")
  endif()

  set(boost_STAMP "${lib_VERSION_BUILD_DIR}/boost_stamp")

  add_custom_command(OUTPUT ${boost_STAMP}
    COMMAND ${b2_FILE} ${b2_ARGS}
    COMMAND ${CMAKE_COMMAND} -E touch ${boost_STAMP}
    WORKING_DIRECTORY ${lib_SRC_DIR}
    DEPENDS ${bootstrap_STAMP} ${bcp_FILE} ${user_jam_FILE}
    COMMENT "Build Boost library."
  )
  
  add_custom_target(build_boost ALL
    DEPENDS ${boost_STAMP}
  )
