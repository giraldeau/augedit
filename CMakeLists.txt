# Augedit build script
# Based on Geary build script from Yorba Foundation
#
# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

cmake_minimum_required(VERSION 2.8)
cmake_policy(VERSION 2.6)

project(augedit C)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )

#
# Base bits
#
set(GETTEXT_PACKAGE "augedit")
set(RELEASE_NAME "Augeas configuration editor.")
set(VERSION "0.0.1")
set(VERSION_INFO "Release")
#ENABLE_TESTING()
#INCLUDE(CTest)
#set(MEMORYCHECK_COMMAND FILEPATH=/home/kitware/local/bin/valgrind)

# Packaging filenamesnames.
set(ARCHIVE_BASE_NAME ${CMAKE_PROJECT_NAME}-${VERSION})
set(ARCHIVE_FULL_NAME ${ARCHIVE_BASE_NAME}.tar.gz)
set(ARCHIVE_DEBUILD_FULL_NAME ${CMAKE_PROJECT_NAME}_${VERSION}.orig.tar.gz)

# from stellarium project
FIND_PACKAGE(Iconv REQUIRED)
FIND_PACKAGE(Gettext REQUIRED)
FIND_PACKAGE(XGettext REQUIRED)
ADD_DEFINITIONS(-DGETTEXT_PACKAGE="augedit")

# Vala
find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16.0" MINIMUM)
include(ValaPrecompile)

# Packages
find_package(PkgConfig)
pkg_check_modules(PKG_BASE REQUIRED
    gthread-2.0
    glib-2.0>=2.30.0
    gio-2.0>=2.28.0
    gtk+-3.0>=3.2.0
    gee-1.0>=0.6.0
)
# Find other packages: for unkown reason, must be done separately
pkg_check_modules(PKG_LIBXML QUIET libxml-2.0)
pkg_check_modules(PKG_AUGEAS QUIET augeas>=0.8)

set(DEPS_CFLAGS
    -I${CMAKE_SOURCE_DIR}/src
    ${PKG_BASE_CFLAGS}
    ${PKG_LIBXML_CFLAGS}
    ${PKG_AUGEAS_CFLAGS}
)
set(DEPS_CFLAGS_OTHER
    ${PKG_BASE_CFLAGS_OTHER}
    ${PKG_LIBXML_CFLAGS_OTHER}
    ${PKG_AUGEAS_CFLAGS_OTHER}
)
set(DEPS_LIBRARIES
    ${PKG_BASE_LIBRARIES}
    ${PKG_LIBXML_LIBRARIES}
    ${PKG_AUGEAS_LIBRARIES}
)
set(LIB_PATHS
    ${PKG_BASE_LIBRARY_DIRS}
    ${PKG_LIBXML_LIBRARY_DIRS}
    ${PKG_AUGEAS_LIBRARY_DIRS}
)

set(AUGEDIT_PACKAGES
    augeas glib-2.0 gtk+-3.0 gee-1.0 gio-2.0 posix
)

set(CFLAGS 
    ${DEPS_CFLAGS}
    ${DEPS_CFLAGS_OTHER}
    -D_VERSION=\"${VERSION}\"
    -D_INSTALL_PREFIX=\"${CMAKE_INSTALL_PREFIX}\"
    -D_SOURCE_ROOT_DIR=\"${CMAKE_SOURCE_DIR}\"
    -D_GSETTINGS_DIR=\"${CMAKE_BINARY_DIR}/gsettings\"
)

link_directories(${LIB_PATHS})
add_definitions(${CFLAGS})

option(ICON_UPDATE "Run gtk-update-icon-cache after the install." ON)
option(DESKTOP_UPDATE "Run update-desktop-database after the install." ON)

if (ICON_UPDATE)
    message(STATUS "Icon cache will be updated")
endif ()

if (DESKTOP_UPDATE)
    message(STATUS "Desktop database will be updated")
endif ()

add_subdirectory(po)
add_subdirectory(src)
add_subdirectory(tests)
#add_subdirectory(icons)
#add_subdirectory(sql)
#add_subdirectory(ui)
#add_subdirectory(help)

#
# Install augedit.desktop
#
#install(
#    FILES
#        augeas.desktop
#    DESTINATION
#        share/applications
#)

#
# Uninstall target
#
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY
)

add_custom_target(
    uninstall
    COMMAND 
        ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    COMMAND 
        ${glib_schema_compiler} ${GSETTINGS_DIR}
)

# Optional: run update-desktop-database at install time.
if (DESKTOP_UPDATE)
    install(
        CODE
            "execute_process (COMMAND update-desktop-database)"
        CODE
            "message (STATUS \"Updating desktop database\")"
    )
    
    add_custom_target(
        uninstall-desktop-update
        DEPENDS
            uninstall
        COMMAND
            update-desktop-database
    )
endif ()

# Dist
# This generates the dist tarballs
add_custom_target(
    dist
    COMMAND 
        git archive --prefix=${ARCHIVE_BASE_NAME}/ HEAD
        | xz -z > ${CMAKE_BINARY_DIR}/${ARCHIVE_FULL_NAME}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

# Ubuntu
# Builds the source Debian package used for the Launchpad PPA
add_custom_target(
    ubuntu_pre
    DEPENDS
        dist
    COMMAND 
        ${CMAKE_COMMAND} -E copy ${ARCHIVE_FULL_NAME} ${ARCHIVE_DEBUILD_FULL_NAME}
    COMMAND
        tar xvfx ${ARCHIVE_FULL_NAME}
)

add_custom_target(
    ubuntu
    DEPENDS
        ubuntu_pre
    COMMAND
        ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/debian" 
        "${CMAKE_CURRENT_BINARY_DIR}/${ARCHIVE_BASE_NAME}/debian"
    COMMAND 
        debuild -S -k$ENV{GPGKEY}
    COMMAND

    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${ARCHIVE_BASE_NAME}"
)

MESSAGE(STATUS)
MESSAGE(STATUS "========================================")
MESSAGE(STATUS "AUGEDIT_PACKAGES=${AUGEDIT_PACKAGES}")
MESSAGE(STATUS "CFLAGS=${CFLAGS}")
MESSAGE(STATUS "DEPS_INCLUDE_DIRS=${DEPS_INCLUDE_DIRS}")
MESSAGE(STATUS "PC_LIBXML_INCLUDE_DIRS=${PC_LIBXML_INCLUDE_DIRS}")
MESSAGE(STATUS "PC_AUGEAS_INCLUDE_DIRS=${PC_AUGEAS_INCLUDE_DIRS}")
MESSAGE(STATUS "PC_LIBXML_LIBRARIES=${PC_LIBXML_LIBRARIES}")
MESSAGE(STATUS "PC_AUGEAS_LIBRARIES=${PC_AUGEAS_LIBRARIES}")
MESSAGE(STATUS "LIB_PATHS=${LIB_PATHS}")
MESSAGE(STATUS "========================================")
MESSAGE(STATUS)
