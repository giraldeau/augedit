AM_CPPFLAGS = $(AUGEDIT_CFLAGS) -I$(top_srcdir)/src

AM_VALAFLAGS = $(AUGEDIT_VALAFLAGS)

TESTS = \
        test-load

check_PROGRAMS = $(TESTS)

test_load_SOURCES = test-load.vala
test_load_LDADD = $(top_builddir)/src/libaugedit.la $(AUGEDIT_LIBS)
test_load_VALAFLAGS = $(AM_VALAFLAGS) $(top_builddir)/src/augedit.vapi

TESTS_ENVIRONMENT = \
  PATH='$(abs_top_builddir)/src$(PATH_SEPARATOR)'"$$PATH" \
  abs_top_builddir='$(abs_top_builddir)' \
  abs_top_srcdir='$(abs_top_srcdir)' \
  LANG=en_US

CLEANFILES = *.c *.stamp test-report.xml test-report.html

