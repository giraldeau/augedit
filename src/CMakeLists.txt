# Augedit build script

# Augedit library
##################################################
set(AUGEDITLIB_SRC
augedit-application.vala
augedit-loader.vala
)

vala_precompile(AUGEDITLIB_VALA_C
    ${AUGEDITLIB_SRC}
PACKAGES
    ${AUGEDIT_PACKAGES}
GENERATE_VAPI
    augedit-static
OPTIONS
    --thread
    --enable-checking
#    --fatal-warnings
)

add_library(augedit-static STATIC ${AUGEDITLIB_VALA_C})
target_link_libraries(augedit-static ${DEPS_LIBRARIES} gthread-2.0)

set(AUGEDIT_SRC
main.vala
)


# Augedit client app
#################################################
vala_precompile(AUGEDIT_VALA_C
    ${AUGEDIT_SRC}
PACKAGES
    ${AUGEDIT_PACKAGES}
    augedit-static
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/src
    -g
    --save-temps
    --thread
    --enable-checking
#    --fatal-warnings
)

add_executable(augedit ${AUGEDIT_VALA_C})
target_link_libraries(augedit ${DEPS_LIBRARIES} gthread-2.0 augedit-static)
install(TARGETS augedit RUNTIME DESTINATION bin)
add_custom_command(
    TARGET
        augedit
    POST_BUILD
    COMMAND
        ${CMAKE_COMMAND} -E copy augedit ${CMAKE_BINARY_DIR}/
)


# GSettings
set(GSETTINGS_DIR ${CMAKE_SOURCE_DIR}/src)
include(GSettings)
add_schemas(augedit ${GSETTINGS_DIR})

## Make clean: remove copied files
##################################################
set_property(
    DIRECTORY ..
    APPEND
    PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
        augedit
)


