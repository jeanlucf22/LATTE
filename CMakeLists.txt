cmake_minimum_required(VERSION 3.9)
project(latte VERSION 1.2.2 LANGUAGES Fortran)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_Fortran_FLAGS)
  #release comes with -O3 by default
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_Fortran_FLAGS)

# Cmake modules/macros are in a subdirectory to keep this file cleaner
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/Modules)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

list(APPEND CMAKE_PREFIX_PATH ${PROGRESS_DIR})
list(APPEND CMAKE_PREFIX_PATH ${BML_DIR})
include(GNUInstallDirs)

set(PRECISION DOUBLE CACHE STRING "The float precision")
set_property(CACHE PRECISION PROPERTY STRINGS DOUBLE SINGLE)
string(TOUPPER ${PRECISION} PRECISION)

if((NOT ${PRECISION} STREQUAL SINGLE) AND (NOT ${PRECISION} STREQUAL DOUBLE))
  message(FATAL_ERROR "PRECISION needs to be either SINGLE or DOUBLE")
endif()

option(OPENMP "Use OpenMP" OFF)
if(OPENMP)
  find_package(OpenMP REQUIRED)
endif()

option(DO_MPI "Use MPI" OFF)
if(DO_MPI)
  find_package(MPI REQUIRED)
  if (NOT MPI_Fortran_FOUND)
    message(FATAL_ERROR "Can not find suitable MPI library")
  endif()
endif()

option(PROGRESS "Use progress library" OFF)
if(PROGRESS)
  find_package(PROGRESS CONFIG REQUIRED)
  if(TARGET PROGRESS::progress)
    set(PROGRESS_LIBRARIES PROGRESS::progress)
  else()
    find_package(PROGRESS MODULE REQUIRED)
  endif()
  message(STATUS "Found PROGRESS: ${PROGRESS_LIBRARIES}")
  message(STATUS "Found PROGRESS: ${PROGRESS_INCLUDE_DIR}")
  message(STATUS "Found PROGRESS: ${PROGRESS_INCLUDEDIR}")
else()
  find_package(BLAS REQUIRED)
  find_package(LAPACK REQUIRED)
  message(STATUS "Linking BLAS via ${BLAS_LIBRARIES}")
  message(STATUS "Linking LAPACK via ${LAPACK_LIBRARIES}")
endif()  

option(DBCSR_OPT "Whether to use DBCSR" OFF)

option(GPUOPT "Whether to use the GPU" OFF)
if(GPUOPT)
  find_package(CUDA REQUIRED)
endif()

find_package(Doxygen)
if(DOXYGEN_FOUND)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/Doxyfile.in Doxyfile)
  add_custom_target(doc
    COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile)
endif()

if(NOT DBCSR_OPT)
  set(DBCSR_SOURCES)
endif()

#only "ON" and "OFF" support
foreach(_def GPUOPT DBCSR_OPT DO_MPI PROGRESS)
  if(${${_def}})
    set(${_def} ON)
  else()
    set(${_def} OFF)
  endif()
endforeach()

add_subdirectory(src)

include(CMakePackageConfigHelpers)
configure_file(cmake/LATTEConfig.cmakein ${CMAKE_CURRENT_BINARY_DIR}/LATTEConfig.cmake @ONLY)
write_basic_package_version_file("LATTEConfigVersion.cmake" VERSION ${PROJECT_VERSION} COMPATIBILITY ExactVersion)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/LATTEConfig.cmake" "${CMAKE_CURRENT_BINARY_DIR}/LATTEConfigVersion.cmake" DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/LATTE)
add_library(LATTE::latte ALIAS latte)
