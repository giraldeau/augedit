AC_PREREQ(2.63)

m4_define(augedit_major_version, 0)
m4_define(augedit_minor_version, 0)
m4_define(augedit_micro_version, 1)
m4_define(augedit_version, augedit_major_version.augedit_minor_version.augedit_micro_version)

AC_INIT([augedit], [augedit_version])
AC_CONFIG_SRCDIR(src/main.c)

AC_DEFINE(AUGEDIT_MAJOR_VERSION, augedit_major_version, [Augedit major version])
AC_SUBST(AUGEDIT_MAJOR_VERSION, augedit_major_version)
AC_DEFINE(AUGEDIT_MINOR_VERSION, augedit_minor_version, [Augedit minor version])
AC_SUBST(AUGEDIT_MINOR_VERSION, augedit_minor_version)
AC_DEFINE(AUGEDIT_MICRO_VERSION, augedit_micro_version, [Augedit micro version])
AC_SUBST(AUGEDIT_MICRO_VERSION, augedit_micro_version)

AUGEDIT_API_VERSION=augedit_api_version
AC_SUBST(AUGEDIT_API_VERSION)

AM_INIT_AUTOMAKE([1.11 dist-bzip2 no-dist-gzip -Wno-portability])

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

GNOME_MAINTAINER_MODE_DEFINES
GNOME_COMPILE_WARNINGS([maximum])
GNOME_DEBUG_CHECK

AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AC_ISC_POSIX
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET

GTK_DOC_CHECK([1.14],[--flavour no-tmpl])

###############
# GLib tools. #
###############
AC_PATH_PROG(GLIB_GENMARSHAL, glib-genmarshal)
AC_PATH_PROG(GLIB_MKENUMS, glib-mkenums)

#############
# GSettings #
#############
GLIB_GSETTINGS

################
# Translations #
################
AM_GLIB_GNU_GETTEXT
IT_PROG_INTLTOOL([0.40.0])

GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [Gettext package])

###################
# gnome-doc-utils #
###################

PKG_PROG_PKG_CONFIG
GNOME_DOC_INIT

################
# Dependencies #
################
GLIB_REQUIRED=2.25.10
GTHREAD_REQUIRED=2.12.0
GTK_REQUIRED=2.20.0
GCONF_REQUIRED=2.31.1

PKG_CHECK_MODULES(AUGEDIT, [
    glib-2.0 >= $GLIB_REQUIRED
    gthread-2.0 >= $GTHREAD_REQUIRED
    gtk+-2.0 >= $GTK_REQUIRED
    gconf-2.0 >= $GCONF_REQUIRED
])

AC_SUBST(AUGEDIT_CFLAGS)
AC_SUBST(AUGEDIT_LIBS)

################
# Output files #
################
AC_CONFIG_FILES([
Makefile
src/Makefile
po/Makefile.in
])

AC_OUTPUT

echo "
Augedit ${VERSION}

Configuration:
       Prefix           : ${prefix}
       Compiler         : ${CC}
"
