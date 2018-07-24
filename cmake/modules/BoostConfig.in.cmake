
# - Boost CMake Configuration File to replace FindBoost
# Use of find_package's CONFIG mode plus use if imported targets
# provides a most robust location mechanism.
#
# This config file aims for compatibility with FindBoost's interface
# and results. The following variables are set by this config file,
# with differences from FindBoost noted:
#
# Boost_FOUND              True if headers and requested libraries were found.
# Boost_INCLUDE_DIRS       Boost include directories.
# Boost_LIBRARY_DIRS       Link directories for Boost libraries.
# Boost_LIBRARIES          Boost component libraries to be linked.
# Boost_<C>_FOUND          True if component <C> was found (<C> is upper-case).
# Boost_<C>_LIBRARY        Libraries to link for component <C> (will be
#                          an imported target).
# Boost_VERSION            Boost's X.Y.Z version number
#                          NB: FindBoost sets this as the value of
#                          BOOST_VERSION in boost/version.hpp
# Boost_MAJOR_VERSION    - Boost major version number (X in X.y.z).
# Boost_MINOR_VERSION    - Boost minor version number (Y in x.Y.z).
# Boost_SUBMINOR_VERSION - Boost subminor version number (Z in x.y.Z).
#
# The following `IMPORTED` targets are also defined:
#
#   Boost::boost         - Target for header-only dependencies (Boost
#                          include directory).
#   Boost::<C>           - Target for specific component dependency
#                          (shared or static library); <C> is lower-case.
#
# As with FindBoost, several variables can be set prior to the call to
# find_package(Boost) to influence which threading and link model
# libraries will be searched for:
#
#  Boost_USE_MULTITHREADED  Set to OFF to use the non-multithreaded
#                           libraries ('mt' tag).  Default is ON.
#  Boost_USE_STATIC_LIBS    Set to ON to force the use of the static
#                           libraries.  Default is OFF.
#
# Fatal errors will be emitted (i.e. configuration failed) if the requested
# thread/link model libs are not provided by this install of Boost.
#
# The main departure from FindBoost is in the separation of Release
# and Debug (and in the future, Profile) libraries. Whilst FindBoost
# stores paths to Release and Debug libs in separate variables,
# BoostConfig uses imported targets which store both paths and link
# the one appropriate for the client's build mode. For example:
#
#  find_package(Boost 1.58.0 REQUIRED regex)
#  add_executable(foo foo.cpp)
#  target_link_libraries(foo ${Boost_REGEX_LIBRARY})
#
# would link `foo` to `libboost_regex-mt.so` when foo is built in
# Release mode, and to `libboost_regex-mt-d.so` when foo is built in
# Debug mode.
#


@PACKAGE_INIT@
# set_and_check() generated by configure_package_config_file().
# check_required_components() generated by configure_package_config_file().


#-----------------------------------------------------------------------
# Set the config path, for internal use only
#
get_filename_component(Boost_CONFIG_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


#-----------------------------------------------------------------------
# Versioning variables for compatibility with FindBoost
#
set(Boost_MAJOR_VERSION     "@Boost_MAJOR_VERSION@")
set(Boost_MINOR_VERSION     "@Boost_MINOR_VERSION@")
set(Boost_SUBMINOR_VERSION  "@Boost_SUBMINOR_VERSION@")


#-----------------------------------------------------------------------
# Configure variables for compatibility
# with FindBoost's link/thread model selection.
#

#-----------------------------------------------------------------------
# - Boost_USE_STATIC_LIBS
if(NOT DEFINED Boost_USE_STATIC_LIBS)
  set(Boost_USE_STATIC_LIBS OFF)
endif()
if(Boost_USE_STATIC_LIBS)
  set(Boost_LINKMODEL_TAG "static")
else()
  set(Boost_LINKMODEL_TAG "shared")
endif()


#-----------------------------------------------------------------------
# - Boost_USE_MULTITHREADED
if(NOT DEFINED Boost_USE_MULTITHREADED)
  set(Boost_USE_MULTITHREADED ON)
endif()
if(Boost_USE_MULTITHREADED)
  set(Boost_THREADMODEL_TAG "multithread")
else()
  set(Boost_THREADMODEL_TAG "singlethread")
endif()


#-----------------------------------------------------------------------
# Set the header path
#
get_filename_component(
  Boost_INCLUDE_DIR "@PACKAGE_CMAKE_INSTALL_FULL_INCLUDEDIR@"
  ABSOLUTE CACHE
)
# Add type and description to cached variable.
set(Boost_INCLUDE_DIR "${Boost_INCLUDE_DIR}" CACHE
  PATH "Path to the Boost headers"
)
mark_as_advanced(Boost_INCLUDE_DIR)
set(Boost_INCLUDE_DIRS "${Boost_INCLUDE_DIR}")


#-----------------------------------------------------------------------
# Set the library path
#
get_filename_component(
  Boost_LIBRARY_DIR "@PACKAGE_CMAKE_INSTALL_FULL_LIBDIR@"
  ABSOLUTE CACHE
)
# Add type and description to cached variable.
set(Boost_LIBRARY_DIR "${Boost_LIBRARY_DIR}" CACHE
  PATH "Path to the Boost libraries"
)
mark_as_advanced(Boost_LIBRARY_DIR)
set(Boost_LIBRARY_DIRS "${Boost_LIBRARY_DIR}")


#-----------------------------------------------------------------------
# Load library depends file for link/thread model requested
#
if(NOT Boost_LIBDEPS_LOADED)
  include(
    "${Boost_CONFIG_DIR}/BoostTargets-${Boost_LINKMODEL_TAG}-${Boost_THREADMODEL_TAG}.cmake"
  )
  set(Boost_LIBDEPS_LOADED 1)
endif()


#-----------------------------------------------------------------------
# Handle components as loaded by the BoostTargets file
#
foreach(_boost_component ${Boost_INSTALLED_COMPONENTS})
  # Map FindBoost's 'Boost_<C>_LIBRARY' variables to the imported target names.
  string(TOUPPER "${_boost_component}" _boost_component_upper)

  set(Boost_${_boost_component_upper}_FOUND 1)
  set(Boost_${_boost_component_upper}_LIBRARY "Boost::${_boost_component}"
    CACHE FILEPATH "Path (imported) to the Boost ${_boost_component} library"
  )
  mark_as_advanced(Boost_${_boost_component_upper}_LIBRARY)

  if(Boost_FIND_REQUIRED_${_boost_component})
    list(APPEND Boost_LIBRARIES ${Boost_${_boost_component_upper}_LIBRARY})
  endif()

  if(Boost_FIND_COMPONENTS)
    list(REMOVE_ITEM Boost_FIND_COMPONENTS ${_boost_component})
  endif()
endforeach()

if(Boost_LIBRARIES)
  list(REMOVE_DUPLICATES Boost_LIBRARIES)
endif()


#-----------------------------------------------------------------------
# Finally, handle any remaining components.
# We should have dealt with all available components above,
# and removed them from the list of FIND_COMPONENTS so any left
# we either didn't find or don't know about.
# Emit a warning if REQUIRED isn't set, or FATAL_ERROR otherwise.
#
list(REMOVE_DUPLICATES Boost_FIND_COMPONENTS)

foreach(_remaining ${Boost_FIND_COMPONENTS})
  if(Boost_FIND_REQUIRED)
    message(FATAL_ERROR "Boost component ${_remaining} not found")
  elseif(NOT Boost_FIND_QUIETLY)
    message(WARNING " Boost component ${_remaining} not found")
  endif()
  unset(Boost_FIND_REQUIRED_${_remaining})
endforeach()


#-----------------------------------------------------------------------
# Check the required components are found.
#
check_required_components("@PROJECT_NAME@")
