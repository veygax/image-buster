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

# ---- FetchContent for rlImGui ----
include(FetchContent)
FetchContent_Declare(
    rlimgui
    GIT_REPOSITORY https://github.com/raylib-extras/rlImGui.git
    GIT_TAG main
)
FetchContent_MakeAvailable(rlimgui)

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

# Find required packages
find_package(raylib CONFIG REQUIRED)
find_package(imgui CONFIG REQUIRED)
find_package(glfw3 CONFIG REQUIRED)

# Get raylib include directories for IDE syntax highlighting
get_target_property(RAYLIB_INCLUDE_DIRS raylib INTERFACE_INCLUDE_DIRECTORIES)

# Create rlImGui library and link it
add_library(rlImGui STATIC
    ${rlimgui_SOURCE_DIR}/rlImGui.cpp
)

target_include_directories(rlImGui PUBLIC
    ${rlimgui_SOURCE_DIR}
    ${RAYLIB_INCLUDE_DIRS}
)

target_link_libraries(rlImGui
    PUBLIC raylib
    PUBLIC imgui::imgui
)

# Add rlImGui include directories to the executable
target_include_directories(image-buster_exe PRIVATE 
    ${rlimgui_SOURCE_DIR}
    ${rlimgui_SOURCE_DIR}/extras
    ${RAYLIB_INCLUDE_DIRS}
)

target_link_libraries(image-buster_exe 
    PRIVATE image-buster_lib
    PRIVATE raylib
    PRIVATE imgui::imgui
    PRIVATE rlImGui
    PRIVATE glfw
)

# On Windows, we need to link with winmm for timeBeginPeriod/timeEndPeriod
if(WIN32)
    target_link_libraries(image-buster_exe PRIVATE winmm)
endif()

# Copy resources folder to build directory
add_custom_command(TARGET image-buster_exe POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_SOURCE_DIR}/resources $<TARGET_FILE_DIR:image-buster_exe>/resources
)

# Create compile_commands.json for clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

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
