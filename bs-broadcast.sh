#!/bin/sh
#
# bs-broadcast: compute broadcast address from ipaddress and netmask
#
# Written entirely in Bourne shell. No external programs (not even test).
#
# Copyright (C) 2001, Jonathan H N Chin <jc254@newton.cam.ac.uk>
# ALL RIGHTS RESERVED
#
# 2001-11-07: initial version
# 2001-11-08: remove dependency on built-in echo; misc minor tweaks
# 2001-11-09: alternative (better?) echo
# 2001-11-10: better echo
# 2001-11-12: factored out the math routines to a separate file
# 2007-10-09: renamed include file

# ======================================================================

. bs-math.sh

PATH=/nowhere	# we don't need it, right?
ME=$0		# irix /bin/sh seems to lose track of $0

# ======================================================================
# messages/errors/warnings

ECHO(){
	# unfortunately, embedded spaces/newlines get compacted
	# and non-alpanumerics get surrounded by quotes
	(set -ext; : $1 2>&-) 2>&1
}

usage(){
	ECHO 1>&2 "Usage: $ME IP MASK0"
	ECHO 1>&2 "where IP and MASK are decimal dotted quads."
	ECHO 1>&2 "Assumes supplied MASK is valid. GIGO."
	exit 1
}

oops(){
	ECHO 1>&2 "$ME: error: $1"
	exit 1
}

# ======================================================================
# convenience routines

mkseg(){
	dec2bin $1
	pad 8 $ans
	eval "${2-ans}=$ans"
}

bcseg(){
	not $2
	or $1 $ans
	bin2dec $ans
	unpad $ans
	eval "${3-ans}=$ans"
}

# ----------------------------------------------------------------------
# parse arguments, do the calculation

set x $*
shift
case "x$1x" in xx) usage ;; esac
case "x$3x" in x?*x) oops "too many arguments" ;; esac

ip=$1
mask=$2

IFS=.
set x $ip
IFS="
 	"
shift
case "$ip" in
	*.*.*.*.*|*[!0-9.]*) oops "bad ip format" ;;
	"$1.$2.$3.$4") ;;
	*) oops "incomplete ip" ;;
esac

mkseg $1 IP1
mkseg $2 IP2
mkseg $3 IP3
mkseg $4 IP4

IFS=.
set x $mask
IFS="
 	"
shift
case "$mask" in
	*.*.*.*.*|*[!0-9.]*) oops "bad mask format" ;;
	"$1.$2.$3.$4") ;;
	*) oops "incomplete mask" ;;
esac
mkseg $1 MASK1
mkseg $2 MASK2
mkseg $3 MASK3
mkseg $4 MASK4

bcseg $IP1 $MASK1 BC1
bcseg $IP2 $MASK2 BC2
bcseg $IP3 $MASK3 BC3
bcseg $IP4 $MASK4 BC4

ECHO "$BC1.$BC2.$BC3.$BC4"
exit 0

# ======================================================================

