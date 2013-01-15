AC_PREREQ([2.65])
AC_INIT([augedit],[0.1.0],[augeas-devel@redhat.com])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE
AC_CONFIG_FILES([Makefile
                src/Makefile
                tests/Makefile])

LT_INIT
AC_PROG_CC
AM_PROG_VALAC

pkg_modules="glib-2.0 >= 2.24.1
             gobject-2.0 >= 2.24.1"
PKG_CHECK_MODULES(AUGEDIT, [$pkg_modules])
AC_SUBST(AUGEDIT_CFLAGS)
AC_SUBST(AUGEDIT_LIBS)

AC_OUTPUT

