cmake_minimum_required(VERSION 3.13)
project(airport C)

set(CMAKE_C_STANDARD 11)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
find_package(MySQL REQUIRED)

add_executable(airport
        main.c
        controller/agenzia.c
        controller/amministratore.c
        controller/login.c
        model/db.c
        utils/db.c
        utils/dotenv.c
        utils/io.c
        utils/validation.c
        view/agenzia.c
        view/amministratore.c
        view/login.c
)

include_directories(${MYSQL_INCLUDE_DIR})
target_link_libraries(airport ${MYSQL_LIBRARIES})

if(MSVC)
    add_compile_options(PRIVATE /W4 /WX)
else()
    add_compile_options(PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()
