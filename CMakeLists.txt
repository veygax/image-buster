cmake_minimum_required(VERSION 3.14)

include(cmake/prelude.cmake)

project(
    image-buster
    VERSION 0.1.0
    DESCRIPTION "a raylib imgui project that messes with images"
    HOMEPAGE_URL "https://example.com/"
    LANGUAGES CXX
)

include(cmake/project-is-top-level.cmake)
include(cmake/variables.cmake)

# ---- Declare library ----

add_library(
    image-buster_lib OBJECT
    source/lib.cpp
)

target_include_directories(
    image-buster_lib ${warning_guard}
    PUBLIC
    "\$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/source>"
)

target_compile_features(image-buster_lib PUBLIC cxx_std_20)

find_package(fmt REQUIRED)
target_link_libraries(image-buster_lib PRIVATE fmt::fmt)

# ---- Declare executable ----

add_executable(image-buster_exe source/main.cpp)
add_executable(image-buster::exe ALIAS image-buster_exe)

set_property(TARGET image-buster_exe PROPERTY OUTPUT_NAME image-buster)

target_compile_features(image-buster_exe PRIVATE cxx_std_20)

target_link_libraries(image-buster_exe PRIVATE image-buster_lib)

# ---- Install rules ----

if(NOT CMAKE_SKIP_INSTALL_RULES)
  include(cmake/install-rules.cmake)
endif()

# ---- Developer mode ----

if(NOT image-buster_DEVELOPER_MODE)
  return()
elseif(NOT PROJECT_IS_TOP_LEVEL)
  message(
      AUTHOR_WARNING
      "Developer mode is intended for developers of image-buster"
  )
endif()

include(cmake/dev-mode.cmake)
