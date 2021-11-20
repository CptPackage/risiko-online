cmake_minimum_required(VERSION 3.10)

project(risiko_online)
include_directories(.)

set(LIBS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/libs")

IF(UNIX)
    set(CMAKE_CXX_FLAGS "-std=c++17")
    link_directories("${LIBS_PATH}/unix/pdcurses/")
ELSE (WIN32)
    set(CMAKE_CXX_FLAGS "/std:c++latest")
    include_directories("${LIBS_PATH}/include")
    include_directories("${LIBS_PATH}/include/pdcurses")
    link_directories("${LIBS_PATH}/windows/pdcurses/")
ENDIF (UNIX)

add_executable (mod_launcher launchers/mod_launcher.c)
add_executable (player_launcher launchers/player_launcher.c)
    
IF(UNIX)
    target_link_libraries(mod_launcher m ncurses)
    target_link_libraries(player_launcher m ncurses)
ELSE (WIN32)
    target_link_libraries(mod_launcher pdcurses.lib)
    target_link_libraries(player_launcher pdcurses.lib)
ENDIF (UNIX)
