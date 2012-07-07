# Augedit build script

set(AUGEDIT_SRC
main.vala
)

# Vala
find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16.0" MINIMUM)
include(ValaPrecompile)

# Packages
find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED
    gthread-2.0
    glib-2.0>=2.30.0
    gio-2.0>=2.28.0
    gtk+-3.0>=3.2.0
    gee-1.0>=0.6.0
)

set(AUGEDIT_PACKAGES
    glib-2.0 gtk+-3.0 gee-1.0 gio-2.0 posix
)

set(GSETTINGS_DIR ${CMAKE_SOURCE_DIR}/src)

set(CFLAGS 
    ${DEPS_CFLAGS}
    ${DEPS_CFLAGS_OTHER}
    -D_VERSION=\"${VERSION}\"
    -D_INSTALL_PREFIX=\"${CMAKE_INSTALL_PREFIX}\"
    -D_SOURCE_ROOT_DIR=\"${CMAKE_SOURCE_DIR}\"
    -D_GSETTINGS_DIR=\"${CMAKE_BINARY_DIR}/gsettings\"
)

set(LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories(${LIB_PATHS})
add_definitions(${CFLAGS})

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

