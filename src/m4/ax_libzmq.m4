# ===========================================================================
#      ref.
# ===========================================================================
#
# SYNOPSIS
#
#   AX_LIBZMQ([USE_PKGCONFIG], [MINIMUM-VERSION])
#
# DESCRIPTION
#
#   Test for the zeromq libraries of a particular version (or newer)
#
#   If no path to the installed zeromq library is given the macro searchs
#   under /usr, /usr/local, /opt and /opt/local. Further documentation is
#   available at <address>.
#
#   This macro calls:
#
#     AC_SUBST(LIBZMQ_CFLAGS) / AC_SUBST(LIBZMQ_LIBS)
#
#   And sets:
#
#     HAVE_ZEROMQ
#
# LICENSE
#
#   Copyright (c) 2018 The Auroracoin Developers
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 1

AC_DEFUN([AX_LIBZMQ],
[
	AC_ARG_WITH([libzmq],
	AS_HELP_STRING([--with-libzmq],[Build with zeromq support.]),
        [
        AC_MSG_CHECKING(whether to build with support for zeromq)
        if test "$withval" = "no"; then
	    want_zmq="no"
	    AC_MSG_RESULT([$want_zmq])
        elif test "$withval" = "yes"; then
            want_zmq="yes"
            AC_MSG_RESULT([$want_zmq])
        else
	    want_zmq="no"
	    AC_MSG_RESULT([$want_zmq])
	fi
        ],
        [
        AC_MSG_CHECKING(if we want zeromq support)
        want_zmq="no"
        AC_MSG_RESULT([$want_zmq])
        ])

if test "x$want_zmq" = "xyes"; then
    if test x$1 = "xyes"; then
        dnl Check with pkg-config for libzeromq
        PKG_CHECK_MODULES([LIBZMQ],[libzmq >= $2],
          [AC_DEFINE([HAVE_ZMQ],[1],[Define to 1 to enable ZMQ functions])],
          [AC_DEFINE([HAVE_ZMQ],[0],[Define to 1 to enable ZMQ functions])
          AC_MSG_WARN([libzmq not found.])]
        )
    else
        dnl Try to find libzeromq without pkg-config
        AC_CHECK_HEADER([zmq.h],
            [AC_DEFINE([HAVE_ZMQ],[1],[Define to 1 to enable ZMQ functions])],
            AC_MSG_WARN([zmq.h not found.])
            use_zmq=no
            [AC_DEFINE([HAVE_ZMQ],[0],[Define to 1 to enable ZMQ functions])])
        AC_CHECK_LIB([zmq],[zmq_ctx_shutdown],
            [AC_DEFINE([HAVE_ZMQ],[1],[Define to 1 to enable ZMQ functions])
            LIBZMQ_CFLAGS=""
            LIBZMQ_LIBS="-lzmq"],
            [AC_MSG_WARN([libzmq not found.])
            use_zmq=no
            AC_DEFINE([HAVE_ZMQ],[0],[Define to 1 to enable ZMQ functions])])

        dnl check for the correct MAJOR version
        AC_MSG_CHECKING(whether zeromq is at least MAJOR version $2)
        AC_REQUIRE([AC_PROG_CC])

        CPPFLAGS_SAVED="$CPPFLAGS"
        CPPFLAGS="$CPPFLAGS $LIBZMQ_CFLAGS"
        export CPPFLAGS

        LDFLAGS_SAVED="$LDFLAGS"
        LDFLAGS="$LDFLAGS $LIBZMQ_LIBS"
        export LDFLAGS

        AC_LANG_PUSH(C)
        AC_RUN_IFELSE([AC_LANG_PROGRAM([[
            @%:@include <zmq.h>
            ]], [[
            #if ZMQ_VERSION_MAJOR >= $2
            // Everything is okay
            #else
            #  error ZeroMQ version is too old
            #endif
            ]])],
            [AC_MSG_RESULT(yes)],
            [AC_MSG_RESULT(no)
            AC_MSG_WARN([libzmq too old.])
            use_zmq=no
            AC_DEFINE([HAVE_ZMQ],[0],[Define to 1 to enable ZMQ functions])
            ],
            [])

        CPPFLAGS="$CPPFLAGS_SAVED"
        export CPPFLAGS
        LDFLAGS="$LDFLAGS_SAVED"
        export LDFLAGS
        AC_LANG_POP([C])

        AC_SUBST(LIBZMQ_CFLAGS)
        AC_SUBST(LIBZMQ_LIBS)
    fi
fi

])
