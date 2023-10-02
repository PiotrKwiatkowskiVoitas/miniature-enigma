set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
cmake_minimum_required(VERSION 3.16)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER  arm-none-eabi-gcc)
set(CMAKE_AR arm-none-eabi-ar)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_OBJDUMP arm-none-eabi-objdump)
set(SIZE arm-none-eabi-size)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

SET (CMAKE_C_COMPILER_WORKS 1)
SET (CMAKE_CXX_COMPILER_WORKS 1)

project(Testing_ci C CXX ASM)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 11)

string(SUBSTRING ${STM_CODE} 0 2 STM_CODE_SHORT)
string(SUBSTRING ${STM_CODE} 0 4 STM_CODE_MEDIUM)
string(SUBSTRING ${STM_CODE} 4 1 STM_CODE_FIRST_CHAR)
string(SUBSTRING ${STM_CODE} 5 1 STM_CODE_SECOND_CHAR)
message(${STM_CODE})
message(${STM_CODE_SHORT})
message(${STM_CODE_MEDIUM})

if (${BUILD_TYPE} STREQUAL "R")
    set(CMAKE_BUILD_TYPE "Release")
elseif (${BUILD_TYPE} STREQUAL "S")
    set(CMAKE_BUILD_TYPE "MinSizeRel")
else ()
    set(CMAKE_BUILD_TYPE "Debug")
endif ()

if (${STM_CODE_SHORT} STREQUAL "L0")
    set(CORTEX_TYPE "cortex-m0plus")
elseif (${STM_CODE_SHORT} STREQUAL "F1")
    set(CORTEX_TYPE "cortex-m1")
elseif (${STM_CODE_SHORT} STREQUAL "F4")
    set(CORTEX_TYPE "cortex-m4")
elseif (${STM_CODE_SHORT} STREQUAL "H7")
    set(CORTEX_TYPE "cortex-m7")
endif()

add_compile_options(-mfloat-abi=soft)

add_compile_options(-mcpu=${CORTEX_TYPE} -mthumb -mthumb-interwork)
add_compile_options(-ffunction-sections -fdata-sections -fno-common -fmessage-length=0)
add_compile_options(-fno-exceptions -fno-rtti -fno-use-cxa-atexit -w -pedantic -Wswitch-default -Wswitch-enum -Wconversion -fstack-usage -MMD -MP)

# uncomment to mitigate c++17 absolute addresses warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-register")

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    message(STATUS "Maximum optimization for speed")
    add_compile_options(-Ofast)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    message(STATUS "Maximum optimization for speed, debug info included")
    add_compile_options(-Ofast -g)
elseif ("${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel")
    message(STATUS "Maximum optimization for size")
    add_compile_options(-Os -g0)
else ()
    message(STATUS "Minimal optimization, debug info included")
    add_compile_options(-Og -g)
endif ()

include_directories(
    Core/Inc
    Core/Inc/hardware_implementations
    Drivers/STM32${STM_CODE_SHORT}xx_HAL_Driver/Inc
    Drivers/STM32${STM_CODE_SHORT}xx_HAL_Driver/Inc/Legacy
    Drivers/CMSIS/Device/ST/STM32${STM_CODE_SHORT}xx/Include
    Drivers/CMSIS/Include
    Third_party/etl/include
)

add_definitions(-DUSE_HAL_DRIVER -DSTM32${STM_CODE_MEDIUM}xx -DDEBUG)
add_definitions(-DSTM32${STM_CODE_MEDIUM}${STM_CODE_FIRST_CHAR}x)
add_definitions(-DSTM32${STM_CODE_MEDIUM}x${STM_CODE_SECOND_CHAR})

file(GLOB_RECURSE SOURCES "Core/*.*" "Drivers/*.*")

set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/STM32${STM_CODE}_FLASH.ld)

add_link_options(-Wl,-gc-sections,--print-memory-usage,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map)
add_link_options(-mcpu=${CORTEX_TYPE} -mthumb -mthumb-interwork)
add_link_options(-T ${LINKER_SCRIPT})
add_link_options(-specs=nano.specs -specs=nosys.specs)


add_executable(${PROJECT_NAME}.elf ${SOURCES} ${LINKER_SCRIPT})

set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
        COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
        COMMENT "Building ${HEX_FILE}
Building ${BIN_FILE}")

