AM_CPPFLAGS = -I$(top_builddir)\
    $(AUGEDIT_CFLAGS)

AM_VALAFLAGS = \
    --thread \
    --vapidir  $(top_srcdir)/src/vapi \
    --pkg config \
    --pkg gtk+-3.0 \
    --pkg augeas

bin_PROGRAMS = augedit

augedit_SOURCES = main.vala \
    augedit-loader.vala \
    augedit-application.vala

augedit_LDADD = $(AUGEDIT_LIBS)

CLEANFILES = *.h *.c *.vapi *.stamp
