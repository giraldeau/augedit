#!/bin/sh
# Run this to generate all the initial makefiles, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

PKG_NAME="augedit"

(test -f $srcdir/src/main.vala) || {
    echo -n "**Error**: Directory "\`$srcdir\'" does not look like the"
    echo " top-level $PKG_NAME directory"
    exit 1
}

which gnome-autogen.sh || {
    echo "You need to install gnome-common"
    exit 1
}

ACLOCAL_FLAGS="$ACLOCAL_FLAGS" USE_GNOME2_MACROS=1 . gnome-autogen.sh
