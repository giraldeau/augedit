# Augedit build script

set(AUGEDIT_SRC
main.vala
)

set(GSETTINGS_DIR ${CMAKE_SOURCE_DIR}/src)

# Augedit client app
#################################################
vala_precompile(AUGEDIT_VALA_C
    ${AUGEDIT_SRC}
PACKAGES
    ${AUGEDIT_PACKAGES}
OPTIONS
    --thread
    --enable-checking
    --fatal-warnings
)

add_executable(augedit ${AUGEDIT_VALA_C})
target_link_libraries(augedit ${DEPS_LIBRARIES} gthread-2.0)
install(TARGETS augedit RUNTIME DESTINATION bin)
add_custom_command(
    TARGET
        augedit
    POST_BUILD
    COMMAND
        ${CMAKE_COMMAND} -E copy augedit ${CMAKE_BINARY_DIR}/
)

# GSettings
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


