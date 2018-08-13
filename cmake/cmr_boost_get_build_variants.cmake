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

function(cmr_boost_get_build_variants out_BUILD_VARIANTS)

  if(BUILD_SHARED_LIBS)
    list(APPEND build_variants "link=shared")
  else()
    list(APPEND build_variants "link=static")
  endif()

  option(
    Boost_USE_MULTITHREADED "Build Boost multi threaded library variants" ON
  )
  if(Boost_USE_MULTITHREADED)
    list(APPEND build_variants "threading=multi")
  else()
    list(APPEND build_variants "threading=single")
  endif()

  # Instead of CMAKE_BUILD_TYPE and etc., use the $<CONFIG:Debug> or similar.
  # https://stackoverflow.com/a/24470998
  list(APPEND build_variants "variant=$<LOWER_CASE:$<CONFIG>>")

  set(${out_BUILD_VARIANTS} ${build_variants} PARENT_SCOPE)
endfunction()
