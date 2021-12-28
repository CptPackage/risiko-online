cmake_minimum_required(VERSION 3.10)

set(CMAKE_GENERATOR_PLATFORM win32)
set(LIBS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/libs")
set(BACKEND_PATH "${CMAKE_CURRENT_SOURCE_DIR}/backend")
set(CLIENTS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/clients")
set(GUI_PATH "${CMAKE_CURRENT_SOURCE_DIR}/gui")
set(LAUNCHERS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/launchers")

project(risiko_online)
# include_directories(.)

include_directories(${CLIENTS_PATH})
include_directories(${LIBS_PATH})
include_directories(${BACKEND_PATH})
include_directories(${GUI_PATH})
include_directories(${LAUNCHERS_PATH})

# add_library(clients "${CLIENTS_PATH}/moderator/m_client.c" "${CLIENTS_PATH}/moderator/m_client.h")

IF(UNIX)
    set(CMAKE_CXX_FLAGS "-std=c++17")
    link_directories("${LIBS_PATH}/unix/pdcurses/")
ELSE (WIN32)
    set(CMAKE_CXX_FLAGS "/std:c++latest")
    include_directories("${LIBS_PATH}/include")
    include_directories("${LIBS_PATH}/include/pdcurses")
    link_directories("${LIBS_PATH}/windows/pdcurses/")
ENDIF (UNIX)

include_directories("/clients")
include_directories("/gui")
include_directories("/backend")

add_executable (mod_launcher launchers/mod_launcher.c clients)
    
IF(UNIX)
    target_link_libraries(mod_launcher m ncurses)
ELSE (WIN32)
    target_link_libraries(mod_launcher pdcurses.lib)
ENDIF (UNIX)

