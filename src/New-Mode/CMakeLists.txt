cmake_minimum_required(VERSION 3.13)
project(risiko C)

set(CMAKE_C_STANDARD 11)
set(THREADS_PREFER_PTHREAD_FLAG ON)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
find_package(MySQL REQUIRED)
find_package(Threads REQUIRED)

add_executable(risiko
        launcher.c
        controller/moderator.c
        controller/player.c
        controller/login.c
        model/session.c
        model/db.c
        model/p_match.c
        model/p_match_history.c
        utils/db.c
        utils/dotenv.c
        utils/io.c
        utils/validation.c
        utils/view.c
        utils/mem.c
        view/login.c
        view/m_mainmenu.c
        view/p_mainmenu.c
        view/p_match_history.c
        view/p_match_result.c
        view/p_lobby.c
        view/p_game_waiting.c
        view/p_game_ingame.c
        view/calibrate.c
)

include_directories(${MYSQL_INCLUDE_DIR})
target_link_libraries(risiko ${MYSQL_LIBRARIES} Threads::Threads)

if(MSVC)
    add_compile_options(PRIVATE /W4 /WX)
else()
    add_compile_options(PRIVATE -Wall -Wextra -Wpedantic -Werror -lpthread)
endif()
