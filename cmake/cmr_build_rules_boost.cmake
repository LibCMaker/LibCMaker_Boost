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

# Part of "LibCMaker/cmake/cmr_build_rules.cmake".


  # Based on the BoostBuilder:
  # https://github.com/drbenmorgan/BoostBuilder
  # Based on the build-boost.sh from CrystaX NDK:
  # https://www.crystax.net/
  # https://github.com/crystax/android-platform-ndk/blob/master/build/tools/build-boost.sh
  # Based on the Hunter:
  # https://github.com/ruslo/hunter
  # Based on the code from cget:
  # https://github.com/pfultz2/cget/blob/master/cget/cmake/boost.cmake

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


  #-----------------------------------------------------------------------
  # bootstrap_ARGS
  #
  set(bootstrap_ARGS)
  # TODO: for MINGW
  #if(MINGW)
  #  list(APPEND bootstrap_ARGS "gcc")
  #endif()


  #-----------------------------------------------------------------------
  # Run bootstrap script and build b2 (bjam) if required
  #
  if(DEFINED B2_PROGRAM_PATH AND NOT EXISTS ${B2_PROGRAM_PATH})
    cmr_print_error(
      "B2_PROGRAM_PATH is defined as\n'${B2_PROGRAM_PATH}'\n and there is not 'b2' tool in this path."
    )
  endif()

  set(bootstrap_SRC_DIR "${lib_SRC_DIR}/tools/build")

  if(B2_PROGRAM_PATH)
    set(b2_FILE ${B2_PROGRAM_PATH})
  else()
    set(b2_FILE_NAME "b2")
    unset(b2_FILE CACHE)
    find_program(b2_FILE NAMES ${b2_FILE_NAME}
      PATHS ${bootstrap_SRC_DIR} NO_DEFAULT_PATH
    )
  endif()

  if(NOT B2_PROGRAM_PATH AND NOT b2_FILE)  # Need to build b2.
    set(bootstrap_FILE_NAME "bootstrap.sh")
    if(CMAKE_HOST_WIN32)
      set(bootstrap_FILE_NAME "bootstrap.bat")
    endif()
    set(bootstrap_FILE "${bootstrap_SRC_DIR}/${bootstrap_FILE_NAME}")
    set(bootstrap_STAMP "${lib_VERSION_BUILD_DIR}/bootstrap_stamp")

    cmr_print_value(bootstrap_FILE)

    if(cmr_PRINT_DEBUG)
      cmr_print_debug(
        "bootstrap.sh options:")
      cmr_print_debug("------")
      foreach(opt ${bootstrap_ARGS})
        cmr_print_debug("  ${opt}")
      endforeach()
      cmr_print_debug("------")
    endif()

    # Will add the files in the source tree:
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
      VERBATIM
      WORKING_DIRECTORY ${bootstrap_SRC_DIR}
      COMMENT "Run bootstrap script, build 'b2' program."
    )

    if(lib_BUILD_HOST_TOOLS AND NOT BUILD_BCP_TOOL)
      add_custom_target(run_bootstrap ALL
        DEPENDS ${bootstrap_STAMP}
      )
    endif()

    # Prepare the file path to install it.
    if(CMAKE_HOST_WIN32)
      set(b2_FILE_NAME "b2.exe")
    endif()
    set(b2_FILE "${bootstrap_SRC_DIR}/${b2_FILE_NAME}")

    # Install compiled b2.
    install(
      PROGRAMS ${b2_FILE}
      DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
  endif()

  cmr_print_value(b2_FILE)


  #-----------------------------------------------------------------------
  # common_b2_ARGS
  #
  set(common_b2_ARGS)
  list(APPEND common_b2_ARGS "-q") # Stop at first error

  # Parallelize build if possible
  if(NOT cmr_BUILD_MULTIPROC
        OR cmr_BUILD_MULTIPROC AND NOT cmr_BUILD_MULTIPROC_CNT)
    set(cmr_BUILD_MULTIPROC_CNT "1")
  endif()
  list(APPEND common_b2_ARGS "-j" "${cmr_BUILD_MULTIPROC_CNT}")

  # Build in this location instead of building within the distribution tree.
  list(APPEND common_b2_ARGS
    "--build-dir=${lib_VERSION_BUILD_DIR}"
  )

  if(BUILD_FOR_WINXP OR CMAKE_GENERATOR_TOOLSET STREQUAL "v141_xp")
    # From https://www.boost.org/users/history/version_1_68_0.html
    # Boost.WinAPI has been updated to target Windows 7 by default,
    # where possible. In previous releases Windows Vista was the default.
    # Boost.WinAPI is used internally as the Windows SDK abstraction layer
    # in a number of Boost libraries, including Boost.Beast, Boost.Chrono,
    # Boost.DateTime, Boost.Dll, Boost.Log, Boost.Process, Boost.Stacktrace,
    # Boost.System, Boost.Thread and Boost.UUID.
    # To select the target Windows version define BOOST_USE_WINAPI_VERSION
    # to the numeric version similar to _WIN32_WINNT while compiling Boost
    # and user's code. For example:
    #  b2 release define=BOOST_USE_WINAPI_VERSION=0x0501 stage
    # The list of Windows API version numbers can be seen on this page:
    # https://msdn.microsoft.com/en-us/library/6sehtctf.aspx
    list(APPEND common_b2_ARGS
      "define=BOOST_USE_WINAPI_VERSION=0x0501"
    )
  endif()

  if(CMAKE_HOST_WIN32)
    if(BOOST_HASH)
      # Compresses target paths using an MD5 hash.
      # This option is useful to keep paths from becoming longer
      # than the filesystem supports.
      # This option produces shorter paths than --abbreviate-paths does,
      # but at the cost of making them less understandable.
      list(APPEND common_b2_ARGS
        "--hash"
      )
    elseif(BOOST_ABBREVIATE_PATHS)
      # Compresses target paths by abbreviating each component.
      # This option is useful to keep paths from becoming longer
      # than the filesystem supports.
      list(APPEND common_b2_ARGS
        "--abbreviate-paths"
      )
    endif()
  endif()


  #-----------------------------------------------------------------------
  # bcp_b2_ARGS
  #
  # We need to use a custom set of layout and toolset arguments
  # for bcp building to prevent "duplicate target" errors.
  set(bcp_b2_ARGS)
  list(APPEND bcp_b2_ARGS ${common_b2_ARGS})

  if(cmr_PRINT_DEBUG)
    if(BOOST_DEBUG_SHOW_COMMANDS)
      # Show commands as they are executed
      list(APPEND bcp_b2_ARGS "-d+2")
    endif()
    if(BOOST_DEBUG_CONFIGURATION)
      # Diagnose configuration
      list(APPEND bcp_b2_ARGS "--debug-configuration")
    endif()
    if(BOOST_DEBUG_BUILDING)
      # Report which targets are built with what properties
      list(APPEND bcp_b2_ARGS "--debug-building")
    endif()
    if(BOOST_DEBUG_GENERATOR)
      # Diagnose generator search/execution
      list(APPEND bcp_b2_ARGS "--debug-generator")
    endif()
  else()
    # Suppress all informational messages
    list(APPEND bcp_b2_ARGS "-d0")
  endif()

  if(BOOST_REBUILD_OPTION)
    list(APPEND bcp_b2_ARGS "-a") # Rebuild everything
  endif()


  #-----------------------------------------------------------------------
  # Build and install bcp program if required
  #
  if(BUILD_BCP_TOOL)
    if(cmr_PRINT_DEBUG)
      cmr_print_debug("b2 options for 'bcp' tool building:")
      cmr_print_debug("------")
      foreach(opt ${bcp_b2_ARGS})
        cmr_print_debug("  ${opt}")
      endforeach()
      cmr_print_debug("------")
    endif()

    set(bcp_FILE_NAME "bcp")
    if(CMAKE_HOST_WIN32)
      set(bcp_FILE_NAME "bcp.exe")
    endif()
    set(bcp_FILE "${lib_SRC_DIR}/dist/bin/${bcp_FILE_NAME}")

    cmr_print_value(bcp_FILE)

    # Will add the files in the source tree:
    #   <boost sources>/dist/*
    add_custom_command(OUTPUT ${bcp_FILE}
      COMMAND ${b2_FILE} ${bcp_b2_ARGS} "${lib_SRC_DIR}/tools/bcp"
      VERBATIM
      WORKING_DIRECTORY ${lib_SRC_DIR}
      DEPENDS ${bootstrap_STAMP}
      COMMENT "Build 'bcp' program."
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
  # Check COMPONENTS and get lib list
  #
  cmr_print_value(BOOST_BUILD_ALL_COMPONENTS)
  include(cmr_boost_get_lib_list)
  cmr_boost_get_lib_list(
    boost_LIB_LIST VERSION ${lib_VERSION} COMPONENTS ${lib_COMPONENTS}
  )


  #-----------------------------------------------------------------------
  # Patch 'boost/<...>/user.hpp' files
  #
  set(android_user_config_STAMP
    "${lib_VERSION_BUILD_DIR}/android_user_config_stamp"
  )
  if(ANDROID AND NOT EXISTS ${android_user_config_STAMP})
    cmr_print_status("Patch 'boost/config/user.hpp' in unpacked sources.")
    file(APPEND ${lib_SRC_DIR}/boost/config/user.hpp
"
#if defined __USE_FILE_OFFSET64 && defined(__ANDROID__) && defined(__ANDROID_API__) && __ANDROID_API__ < 21
#undef _FILE_OFFSET_BITS
#undef __USE_FILE_OFFSET64
#endif
"
    )
    file(WRITE ${android_user_config_STAMP} "stamp")
  endif()

  if(NOT BOOST_WITHOUT_ICU)
    set(regex_user_config_STAMP
      "${lib_VERSION_BUILD_DIR}/regex_user_config_stamp"
    )
    if(NOT EXISTS ${regex_user_config_STAMP})
      cmr_print_status("Patch 'boost/regex/user.hpp' in unpacked sources.")
      file(APPEND ${lib_SRC_DIR}/boost/regex/user.hpp
"
// define this if you want to enable support for Unicode via ICU.
#define BOOST_HAS_ICU
"
      )
      file(WRITE ${regex_user_config_STAMP} "stamp")
    endif()

    if(ANDROID OR MSVC OR MINGW)
      cmr_print_status("Patch 'libs/regex/build/Jamfile.v2' in unpacked sources.")
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
          ${lib_BASE_DIR}/patch/boost-${lib_VERSION}/libs/regex/build/Jamfile.v2
          ${lib_SRC_DIR}/libs/regex/build/Jamfile.v2
      )
    endif()
  endif()


  #-----------------------------------------------------------------------
  # b2_ARGS
  #
  set(b2_ARGS)
  list(APPEND b2_ARGS ${common_b2_ARGS})

  if(boost_LIB_LIST)
    list(APPEND b2_ARGS ${boost_LIB_LIST})
  endif()


  #-----------------------------------------------------------------------
  # OS specifics
  #
  include(cmr_boost_get_os_specifics)
  cmr_boost_get_os_specifics(os_specifics)
  list(APPEND b2_ARGS ${os_specifics})


  #-----------------------------------------------------------------------
  # Install options and directories
  #
  if(BOOST_BUILD_STAGE)
    # Build and install only compiled library files to the stage directory.
    list(APPEND b2_ARGS "stage")
    if(BOOST_BUILD_STAGE_DIR)
      # Install library files here
      list(APPEND b2_ARGS
        "--stagedir=${BOOST_BUILD_STAGE_DIR}"
      )
    endif()
    install(CODE
      "message(\"Compiled library files in the stage directory is installed.\")"
    )
  else()
    # Install architecture independent files here
    list(APPEND b2_ARGS
      "--prefix=${CMAKE_INSTALL_PREFIX}"
    )
    # Install header files here
    list(APPEND b2_ARGS
      "--includedir=${CMAKE_INSTALL_FULL_INCLUDEDIR}"
    )
    # Install binary files here
    list(APPEND b2_ARGS
      "--bindir=${CMAKE_INSTALL_FULL_BINDIR}"
    )
    # Install library files here
    list(APPEND b2_ARGS
      "--libdir=${CMAKE_INSTALL_FULL_LIBDIR}"
    )
    # Install architecture dependent files here
    list(APPEND b2_ARGS
      "--exec-prefix=${CMAKE_INSTALL_FULL_BINDIR}"
    )
    # Used by compilation (without 'install' and 'stage')
    list(APPEND b2_ARGS
      "--stagedir=${lib_VERSION_BUILD_DIR}/stage"
    )
  endif()


  #-----------------------------------------------------------------------
  # Unicode/ICU support in Regex
  #
  if(BOOST_WITHOUT_ICU)
    # Disable Unicode/ICU support in Regex.
    list(APPEND b2_ARGS
      "--disable-icu"
    )
  else()
    if(BOOST_WITH_ICU_DIR)
      # Specify the root of the ICU library installation.
      list(APPEND b2_ARGS
        "-sICU_PATH=${BOOST_WITH_ICU_DIR}"
      )
    endif()
    if(MSVC)
      # If ICU has been built with non-standard names for it's binaries.
      # Will use "linker-options-for-icu" when linking the library
      # rather than the default ICU binary names.
#      list(APPEND b2_ARGS
#        "-sICU_LINK=\"/LIBPATH:${CMAKE_INSTALL_PREFIX}/bin /LIBPATH:${CMAKE_INSTALL_PREFIX}/lib icuin.lib icuuc.lib icudt.lib\""
#      )
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
  if(BUILD_SHARED_LIBS)
    list(APPEND b2_ARGS "link=shared")
  else()
    list(APPEND b2_ARGS "link=static")
  endif()

  option(
    Boost_USE_MULTITHREADED "Build Boost multi threaded library variants" ON
  )
  if(Boost_USE_MULTITHREADED)
    list(APPEND b2_ARGS "threading=multi")

    if(CMAKE_CXX_STANDARD EQUAL 98)
      find_package(Threads REQUIRED)
      if(CMAKE_USE_PTHREADS_INIT)
        list(APPEND b2_ARGS "threadapi=pthread")
      elseif(CMAKE_USE_WIN32_THREADS_INIT)
        list(APPEND b2_ARGS "threadapi=win32")
      endif()
    endif()

  else()
    list(APPEND b2_ARGS "threading=single")
  endif()

  # Instead of CMAKE_BUILD_TYPE and etc., use the $<CONFIG:Debug> or similar.
  # https://stackoverflow.com/a/24470998
  list(APPEND b2_ARGS "variant=$<LOWER_CASE:$<CONFIG>>")

  set(BOOST_DEFAULT_LAYOUT_TYPE "system")
  if(MSVC)
    set(BOOST_DEFAULT_LAYOUT_TYPE "versioned")
  endif()
  set(BOOST_LAYOUT_TYPE ${BOOST_DEFAULT_LAYOUT_TYPE} CACHE STRING
    "Determine whether to choose library names and header locations, may be 'versioned', 'tagged' or 'system'"
  )
  list(APPEND b2_ARGS "--layout=${BOOST_LAYOUT_TYPE}")


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

# NOTE: C++ standard is set in cmr_boost_set_cmake_flags()
#  if(CMAKE_CXX_STANDARD)
#    if(lib_VERSION VERSION_GREATER "1.65.9")  # From 1.66.0
#      if(toolset_name MATCHES "gcc" OR toolset_name MATCHES "darwin"
#          OR toolset_name MATCHES "msvc")
#        list(APPEND b2_ARGS "cxxstd=${CMAKE_CXX_STANDARD}")
#      endif()
#    endif()
#    if(lib_VERSION VERSION_GREATER "1.66.9")  # From 1.67.0
#      if(toolset_name MATCHES "clang")
#        list(APPEND b2_ARGS "cxxstd=${CMAKE_CXX_STANDARD}")
#      endif()
#    endif()
#  endif()

  get_directory_property(B2_COMPILE_FLAGS COMPILE_OPTIONS)
  string(REPLACE ";" " " B2_COMPILE_FLAGS "${B2_COMPILE_FLAGS}")

  get_directory_property(B2_INCLUDE_DIRECTORIES INCLUDE_DIRECTORIES)
  foreach(DIR ${B2_INCLUDE_DIRECTORIES})
    if(MSVC)  # TODO: check the flags for other compilers.
      string(APPEND B2_COMPILE_FLAGS " /I ${DIR}")
    else()
      string(APPEND B2_COMPILE_FLAGS " -isystem ${DIR}")
    endif()
  endforeach()

  get_directory_property(B2_COMPILE_DEFINITIONS COMPILE_DEFINITIONS)
  foreach(DEF ${B2_COMPILE_DEFINITIONS})
    if(MSVC)
      string(APPEND B2_COMPILE_FLAGS " /D ${DEF}")
    else()
      string(APPEND B2_COMPILE_FLAGS " -D${DEF}")
    endif()
  endforeach()

  set(B2_C_FLAGS "${CMAKE_C_FLAGS} ${B2_COMPILE_FLAGS}")
  set(B2_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${B2_COMPILE_FLAGS}")

  get_directory_property(B2_LINK_FLAGS LINK_FLAGS)
  string(REPLACE ";" " " B2_LINK_FLAGS "${B2_LINK_FLAGS}")
  if(BUILD_SHARED_LIBS)
    string(APPEND B2_LINK_FLAGS " ${CMAKE_SHARED_LINKER_FLAGS}")
  else()
    string(APPEND B2_LINK_FLAGS " ${CMAKE_STATIC_LINKER_FLAGS}")
  endif()

  # Compensate for extra spaces in the flags, which can cause build failures
  foreach(_b2_flags B2_C_FLAGS B2_CXX_FLAGS B2_LINK_FLAGS)
    string(REGEX REPLACE "  +" " " ${_b2_flags} "${${_b2_flags}}")
    string(STRIP "${${_b2_flags}}" ${_b2_flags})
  endforeach()

  # Instead of CMAKE_BUILD_TYPE and etc., use the $<CONFIG:Debug> or similar.
  # https://stackoverflow.com/a/24470998
  string(APPEND B2_C_FLAGS
    " $<$<CONFIG:Release>:${CMAKE_C_FLAGS_RELEASE}>$<$<CONFIG:Debug>:${CMAKE_C_FLAGS_DEBUG}>"
  )
  string(APPEND B2_CXX_FLAGS
    " $<$<CONFIG:Release>:${CMAKE_CXX_FLAGS_RELEASE}>$<$<CONFIG:Debug>:${CMAKE_CXX_FLAGS_DEBUG}>"
  )

  set(cmr_PATH_SEP ":")
  if(CMAKE_HOST_WIN32)
    set(cmr_PATH_SEP ";")
  endif()

  set(B2_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${CMAKE_SYSTEM_PREFIX_PATH})
  set(B2_SYSTEM_PATH)
  foreach(P ${B2_PREFIX_PATH})
    list(APPEND B2_SYSTEM_PATH "${P}/bin")
  endforeach()
  if(NOT CMAKE_HOST_WIN32)
    string(REPLACE ";" "${cmr_PATH_SEP}" B2_SYSTEM_PATH "${B2_SYSTEM_PATH}")
  endif()

  set(B2_PATH "${B2_SYSTEM_PATH}${cmr_PATH_SEP}$ENV{PATH}")

  # Only add these arguments if they are not empty
  if(NOT "${B2_C_FLAGS}" STREQUAL "")
    list(APPEND b2_ARGS "cflags=${B2_C_FLAGS}")
  endif()
  if(NOT "${B2_CXX_FLAGS}" STREQUAL "")
    list(APPEND b2_ARGS "cxxflags=${B2_CXX_FLAGS}")
  endif()
  if(NOT "${B2_LINK_FLAGS}" STREQUAL "")
    list(APPEND b2_ARGS "linkflags=${B2_LINK_FLAGS}")
  endif()

  set(B2_ENV_COMMAND ${CMAKE_COMMAND} -E env
    "PATH=${B2_PATH}"
    "CC=${CMAKE_C_COMPILER}"
    "CXX=${CMAKE_CXX_COMPILER}"
    "CFLAGS=${B2_C_FLAGS}"
    "CXXFLAGS=${B2_CXX_FLAGS}"
    "LDFLAGS=${B2_LINK_FLAGS}"
  )


  #-----------------------------------------------------------------------
  # Generate 'user-config.jam' file
  #
  cmr_print_status("Generate 'user-config.jam' file.")

  set(user_jam_FILE "${lib_VERSION_BUILD_DIR}/user-config.jam")

  include(cmr_boost_generate_user_config_jam)
  cmr_boost_generate_user_config_jam()
  # Used vars:
  #   user_jam_FILE
  #   toolset_name
  #   toolset_version
  #   boost_compiler
  #   CMAKE_RC_COMPILER
  #   CMAKE_AR
  #   CMAKE_RANLIB
  #   use_cmake_archiver
  #   using_mpi
  #   cmr_PRINT_DEBUG

  if(cmr_PRINT_DEBUG)
    cmr_print_debug("------")
    cmr_print_debug("Boost user jam config:")
    file(READ "${user_jam_FILE}" user_jam_CONTENT)
    cmr_print_debug("------\n${user_jam_CONTENT}")
    cmr_print_debug("------")
  endif()

  list(APPEND b2_ARGS "--user-config=${user_jam_FILE}")


  #-----------------------------------------------------------------------
  # Additional flags
  #
  list(APPEND b2_ARGS "--ignore-site-config")
  list(APPEND b2_ARGS "pch=off")

  set(BOOST_BUILD_FLAGS "" CACHE STRING
    "Additional flags to pass to the b2 tool"
  )
  list(APPEND b2_ARGS ${BOOST_BUILD_FLAGS})


  #-----------------------------------------------------------------------
  # b2_ARGS_BUILD
  #
  set(b2_ARGS_BUILD)
  list(APPEND b2_ARGS_BUILD ${b2_ARGS})

  if(cmr_PRINT_DEBUG)
    if(BOOST_DEBUG_SHOW_COMMANDS)
      # Show commands as they are executed
      list(APPEND b2_ARGS_BUILD "-d+2")
    endif()
    if(BOOST_DEBUG_CONFIGURATION)
      # Diagnose configuration
      list(APPEND b2_ARGS_BUILD "--debug-configuration")
    endif()
    if(BOOST_DEBUG_BUILDING)
      # Report which targets are built with what properties
      list(APPEND b2_ARGS_BUILD "--debug-building")
    endif()
    if(BOOST_DEBUG_GENERATOR)
      # Diagnose generator search/execution
      list(APPEND b2_ARGS_BUILD "--debug-generator")
    endif()
  else()
    # Suppress all informational messages
    list(APPEND b2_ARGS_BUILD "-d0")
  endif()

  if(BOOST_REBUILD_OPTION)
    list(APPEND b2_ARGS_BUILD "-a") # Rebuild everything
  endif()


  #-----------------------------------------------------------------------
  # Build boost library
  #
  if(cmr_PRINT_DEBUG)
    cmr_print_debug("b2 options for Boost library building:")
    cmr_print_debug("------")
    foreach(opt ${b2_ARGS_BUILD})
      cmr_print_debug("  ${opt}")
    endforeach()
    cmr_print_debug("------")
  endif()

  set(boost_build_STAMP "${lib_VERSION_BUILD_DIR}/boost_build_stamp")

  add_custom_command(OUTPUT ${boost_build_STAMP}
#    COMMAND ${B2_ENV_COMMAND} ${b2_FILE} ${b2_ARGS_BUILD}
    COMMAND ${b2_FILE} ${b2_ARGS_BUILD}
    COMMAND ${CMAKE_COMMAND} -E touch ${boost_build_STAMP}
    VERBATIM
    WORKING_DIRECTORY ${lib_SRC_DIR}
    DEPENDS ${bootstrap_STAMP} ${bcp_FILE}
    COMMENT "Build Boost library."
  )

  if(NOT lib_INSTALL)
    add_custom_target(boost_build ALL
      DEPENDS ${boost_build_STAMP}
    )
  endif()


  #-----------------------------------------------------------------------
  # b2_ARGS_INSTALL
  #
  if(lib_INSTALL)
    set(b2_ARGS_INSTALL)
    list(APPEND b2_ARGS_INSTALL ${b2_ARGS})

    if(cmr_PRINT_DEBUG AND BOOST_DEBUG_INSTALL)
      if(BOOST_DEBUG_SHOW_COMMANDS)
        # Show commands as they are executed
        list(APPEND b2_ARGS_INSTALL "-d+2")
      endif()
      if(BOOST_DEBUG_CONFIGURATION)
        # Diagnose configuration
        list(APPEND b2_ARGS_INSTALL "--debug-configuration")
      endif()
      if(BOOST_DEBUG_BUILDING)
        # Report which targets are built with what properties
        list(APPEND b2_ARGS_INSTALL "--debug-building")
      endif()
      if(BOOST_DEBUG_GENERATOR)
        # Diagnose generator search/execution
        list(APPEND b2_ARGS_INSTALL "--debug-generator")
      endif()
    else()
      # Suppress all informational messages
      list(APPEND b2_ARGS_INSTALL "-d0")
    endif()

    # Install headers and compiled library files to the configured locations.
    list(APPEND b2_ARGS_INSTALL "install")
  endif()


  #-----------------------------------------------------------------------
  # Install boost library
  #
  if(lib_INSTALL)
    if(cmr_PRINT_DEBUG)
      cmr_print_debug("b2 options for Boost library installing:")
      cmr_print_debug("------")
      foreach(opt ${b2_ARGS_INSTALL})
        cmr_print_debug("  ${opt}")
      endforeach()
      cmr_print_debug("------")
    endif()

    set(boost_install_STAMP "${lib_VERSION_BUILD_DIR}/boost_install_stamp")

    add_custom_command(OUTPUT ${boost_install_STAMP}
#      COMMAND ${B2_ENV_COMMAND} ${b2_FILE} ${b2_ARGS_INSTALL}
      COMMAND ${b2_FILE} ${b2_ARGS_INSTALL}
      COMMAND ${CMAKE_COMMAND} -E touch ${boost_install_STAMP}
      VERBATIM
      WORKING_DIRECTORY ${lib_SRC_DIR}
      DEPENDS ${boost_build_STAMP}
      COMMENT "Install Boost library."
    )

    add_custom_target(boost_install ALL
      DEPENDS ${boost_install_STAMP}
    )

    install(CODE "message(STATUS \"Boost library is installed.\")")
  endif()
