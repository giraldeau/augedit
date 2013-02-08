AM_CPPFLAGS = \
    -I$(top_builddir) \
    -DDATADIR=\"$(datadir)\" \
    -DPREFIX=\""$(prefix)"\" \
    -DSYSCONFDIR=\""$(sysconfdir)"\" \
    -DLIBDIR=\""$(libdir)"\" \
    -DPACKAGE_DATADIR=\""$(pkgdatadir)"\" \
    -DPACKAGE_LOCALEDIR=\""$(datadir)/locale"\" \
    $(AUGEDIT_CFLAGS)

AM_VALAFLAGS = $(AUGEDIT_VALAFLAGS)

bin_PROGRAMS = augedit
noinst_LTLIBRARIES = libaugedit.la

libaugedit_la_SOURCES = augedit-loader.vala \
    augedit-application.vala \
    augedit-span.vala
libaugedit_la_VALAFLAGS = $(AM_VALAFLAGS) --library augedit -H augedit.h

augedit_SOURCES = main.vala
augedit_LDADD = libaugedit.la $(AUGEDIT_LIBS)
augedit_VALAFLAGS = $(AM_VALAFLAGS) augedit.vapi

CLEANFILES = *.h *.c *.vapi *.stamp
