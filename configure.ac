AC_PREREQ([2.69])
AC_INIT([augedit],[0.1.0],[augeas-devel@redhat.com])
AC_CONFIG_HEADERS([augedit-config.h])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([1.11 -Wall -Wno-portability dist-xz no-define no-dist-gzip nostdinc subdir-objects])
AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

PKG_PROG_PKG_CONFIG([0.24])

AC_CONFIG_FILES([Makefile po/Makefile.in
                src/Makefile
                tests/Makefile])

AC_PROG_CC
AM_PROG_CC_C_O
AM_PROG_VALAC([0.14.0])

LT_PREREQ([2.2])
LT_INIT([disable-static])

GNOME_MAINTAINER_MODE_DEFINES
GNOME_COMPILE_WARNINGS([maximum])
GLIB_GSETTINGS

# i18n
AC_SUBST([GETTEXT_PACKAGE], [$PACKAGE_TARNAME])
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [GETTEXT package name])
IT_PROG_INTLTOOL([0.50.0])

pkg_modules="glib-2.0 >= 2.24.1
             gobject-2.0 >= 2.24.1
             gthread-2.0
             glib-2.0 >= 2.30.0
             gio-2.0 >= 2.28.0
             gee-1.0 >= 0.6.0
             gtk+-3.0 >= 3.2.0
             libxml-2.0
             augeas >= 0.8"

PKG_CHECK_MODULES(AUGEDIT, [$pkg_modules])
AC_SUBST(AUGEDIT_CFLAGS)
AC_SUBST(AUGEDIT_LIBS)

AC_OUTPUT

