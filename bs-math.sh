#!/bin/sh
#
# bs-math: "arbitrary" precision math routines
#
# Written entirely in Bourne shell. No external programs (not even test).
#
# Copyright (C) 2001,  Jonathan H N Chin <jc254@newton.cam.ac.uk>
# ALL RIGHTS RESERVED
#
# 2001-11-10: initial version, derived from bs-broadcast
# 2002-04-06: documented interface; hid local variables;
#             added the add/mul tests that got left out before
# 2007-10-09: fixed double-digit test printout

# ======================================================================
#
# interface:
#
#   conversion:
#     dec2bin $D  - convert decimal number $D into binary
#     bin2dec $B  - convert binary number $B into decimal
#
#   helper functions:
#     length2mask $D $C
#       - convert decimal number $D into a string made up of
#         $D copies of the character (or string) $C
#     pad $L $N
#       - pad number $N (binary or decimal) to length $L
#         if $N has more than $L digits, it is truncated
#     unpad $N
#       - strip leading zeros from number $N
#
#   arithmetic operators on binary numbers (not variadic, sorry):
#     not  $B
#     add  $B1 $B2
#     mul  $B1 $B2
#     and  $B1 $B2
#     or   $B1 $B2
#     xor  $B1 $B2
#     nand $B1 $B2
#     nor  $B1 $B2
#     xnor $B1 $B2
#
# notes:
#   * all commands take an optional extra final argument
#       - if given, it is a variable and the answer is stored into it
#       - otherwise, the answer will be found in $ans
#
#   * names starting __BSAPM_ are reserved for use by this library
#     (this file will be much clearer if you strip out all occurrences
#     of "__BSAPM_" before you start reading)
#
# ======================================================================

PATH=/nowhere	# we don't need it, right?

# ----------------------------------------------------------------------
# truth values

__BSAPM_TRUE(){
	(exit 0)
}

__BSAPM_FALSE(){
	(exit 1)
}

# ----------------------------------------------------------------------
# bit/digit extraction

__BSAPM_newvar(){
	eval "$1=\"\$2\" ${1}digit= ${1}bit= ${1}rest="
}

for __BSAPM_proc in __BSAPM_high __BSAPM_low; do
	case $__BSAPM_proc in
		__BSAPM_high) __BSAPM_S1='${__BSAPM_rest}' __BSAPM_S2='*' __BSAPM_S3='${__BSAPM_rest}' __BSAPM_S4='' ;;
		__BSAPM_low)  __BSAPM_S1='*' __BSAPM_S2='${__BSAPM_rest}' __BSAPM_S3='' __BSAPM_S4='$__BSAPM_rest' ;;
	esac
	eval $__BSAPM_proc'(){
	eval "__BSAPM_str=\$$1 __BSAPM_digit=\$${1}__BSAPM_digit __BSAPM_bit=\$${1}bit __BSAPM_rest=\$${1}rest"
	case $__BSAPM_str in
		$__BSAPM_rest)'"           __BSAPM_digit=  __BSAPM_bit=                                            ;;
		${__BSAPM_S1}0$__BSAPM_S2) __BSAPM_digit=0 __BSAPM_bit=0    __BSAPM_rest=${__BSAPM_S3}0$__BSAPM_S4 ;;
		${__BSAPM_S1}1$__BSAPM_S2) __BSAPM_digit=1 __BSAPM_bit=1    __BSAPM_rest=${__BSAPM_S3}1$__BSAPM_S4 ;;
		${__BSAPM_S1}2$__BSAPM_S2) __BSAPM_digit=2 __BSAPM_bit=10   __BSAPM_rest=${__BSAPM_S3}2$__BSAPM_S4 ;;
		${__BSAPM_S1}3$__BSAPM_S2) __BSAPM_digit=3 __BSAPM_bit=11   __BSAPM_rest=${__BSAPM_S3}3$__BSAPM_S4 ;;
		${__BSAPM_S1}4$__BSAPM_S2) __BSAPM_digit=4 __BSAPM_bit=100  __BSAPM_rest=${__BSAPM_S3}4$__BSAPM_S4 ;;
		${__BSAPM_S1}5$__BSAPM_S2) __BSAPM_digit=5 __BSAPM_bit=101  __BSAPM_rest=${__BSAPM_S3}5$__BSAPM_S4 ;;
		${__BSAPM_S1}6$__BSAPM_S2) __BSAPM_digit=6 __BSAPM_bit=110  __BSAPM_rest=${__BSAPM_S3}6$__BSAPM_S4 ;;
		${__BSAPM_S1}7$__BSAPM_S2) __BSAPM_digit=7 __BSAPM_bit=111  __BSAPM_rest=${__BSAPM_S3}7$__BSAPM_S4 ;;
		${__BSAPM_S1}8$__BSAPM_S2) __BSAPM_digit=8 __BSAPM_bit=1000 __BSAPM_rest=${__BSAPM_S3}8$__BSAPM_S4 ;;
		${__BSAPM_S1}9$__BSAPM_S2) __BSAPM_digit=9 __BSAPM_bit=1001 __BSAPM_rest=${__BSAPM_S3}9$__BSAPM_S4 ;;
	esac"'
	eval "$1=\$__BSAPM_str ${1}digit=\$__BSAPM_digit ${1}bit=\$__BSAPM_bit ${1}rest=\$__BSAPM_rest"
}'
done

# ----------------------------------------------------------------------

__BSAPM_addHelper(){
	__BSAPM_low __BSAPM_addvar1
	__BSAPM_low __BSAPM_addvar2
	case ${__BSAPM_addvar1bit}${__BSAPM_addvar2bit}${__BSAPM_c} in
		00?|0?)	__BSAPM_addans=$__BSAPM_c$__BSAPM_addans; __BSAPM_c=0 __BSAPM_nc=1; __BSAPM_addHelper ;;
		11?)    __BSAPM_addans=$__BSAPM_c$__BSAPM_addans; __BSAPM_c=1 __BSAPM_nc=0; __BSAPM_addHelper ;;
		???|1?) __BSAPM_addans=$__BSAPM_nc$__BSAPM_addans;                          __BSAPM_addHelper ;;
		1)      __BSAPM_addans=$__BSAPM_c$__BSAPM_addans;
	esac
}

__BSAPM_mulHelper(){
	__BSAPM_high __BSAPM_mulvar1
	case $__BSAPM_mulvar1bit in
		0) __BSAPM_mulans=${__BSAPM_mulans}0;                      __BSAPM_mulHelper ;;
		1) add ${__BSAPM_mulans}0 $__BSAPM_mulvar2 __BSAPM_mulans; __BSAPM_mulHelper ;;
	esac
}

__BSAPM_makeBoolHelper(){
	eval $1'Helper(){
	__BSAPM_low '$1'var1
	__BSAPM_low '$1'var2
	case ${'$1'var1bit}${'$1'var2bit} in
		'"$2"') '$1'ans=0$'$1'ans; '$1'Helper ;;
		'"$3"') '$1'ans=1$'$1'ans; '$1'Helper ;;
	esac
}'
}

__BSAPM_makeBoolHelper __BSAPM_and	'?|00|01|10'	'11'
__BSAPM_makeBoolHelper __BSAPM_or	'00'		'?|01|10|11'
__BSAPM_makeBoolHelper __BSAPM_xor	'00|11'		'?|01|10'

__BSAPM_makeBoolHelper __BSAPM_nand	'11'		'?|00|01|10'
__BSAPM_makeBoolHelper __BSAPM_nor	'?|01|10|11'	'00'
__BSAPM_makeBoolHelper __BSAPM_xnor	'?|01|10'	'00|11'

__BSAPM_dec2binHelper(){
	__BSAPM_high __BSAPM_dec2binvar1
	case $__BSAPM_dec2binvar1bit in
		?*)	mul $__BSAPM_dec2binans 1010
			add $ans $__BSAPM_dec2binvar1bit __BSAPM_dec2binans
			__BSAPM_dec2binHelper
			;;
	esac
}

__BSAPM_doubledecimal(){
	__BSAPM_low __BSAPM_dub
	case $__BSAPM_dubdigit$__BSAPM_c in
		[05]0|0) __BSAPM_dubans=0$__BSAPM_dubans ;; [05]1|1) __BSAPM_dubans=1$__BSAPM_dubans ;;
		[16]0)   __BSAPM_dubans=2$__BSAPM_dubans ;; [16]1)   __BSAPM_dubans=3$__BSAPM_dubans ;;
		[27]0)   __BSAPM_dubans=4$__BSAPM_dubans ;; [27]1)   __BSAPM_dubans=5$__BSAPM_dubans ;;
		[38]0)   __BSAPM_dubans=6$__BSAPM_dubans ;; [38]1)   __BSAPM_dubans=7$__BSAPM_dubans ;;
		[49]0)   __BSAPM_dubans=8$__BSAPM_dubans ;; [49]1)   __BSAPM_dubans=9$__BSAPM_dubans ;;
	esac
	case $__BSAPM_dubdigit in
		[0-4]) __BSAPM_c=0; __BSAPM_doubledecimal ;;
		[5-9]) __BSAPM_c=1; __BSAPM_doubledecimal ;;
	esac
}
__BSAPM_bin2decHelper(){
	__BSAPM_high __BSAPM_bin2decvar1
	case $__BSAPM_bin2decvar1bit in
		0) __BSAPM_c=0 ;;
		1) __BSAPM_c=1 ;;
	esac
	case $__BSAPM_bin2decvar1bit in
		[01])	__BSAPM_newvar __BSAPM_dub "$__BSAPM_bin2decans"
			__BSAPM_dubans=
			__BSAPM_doubledecimal
			__BSAPM_bin2decans=$__BSAPM_dubans
			__BSAPM_bin2decHelper
			;;
	esac
}

# ----------------------------------------------------------------------

__BSAPM_makeop1(){
	eval ${1}'(){
	__BSAPM_newvar __BSAPM_'$1'var1 "$1"
	__BSAPM_'$1'ans=0
	__BSAPM_'$1'Helper
	eval "${2-ans}=$__BSAPM_'$1'ans"
}'
}

__BSAPM_makeop2(){
	eval ${1}'(){
	__BSAPM_newvar __BSAPM_'$1'var1 "$1"
	__BSAPM_newvar __BSAPM_'$1'var2 "$2"
	__BSAPM_c=0 __BSAPM_nc=1
	__BSAPM_'$1'ans=
	__BSAPM_'$1'Helper
	eval "${3-ans}=$__BSAPM_'$1'ans"
}'
}

for op in dec2bin bin2dec                  ; do __BSAPM_makeop1 $op; done
for op in add mul and or xor nand nor xnor ; do __BSAPM_makeop2 $op; done

not(){
	nand "$1" "$@"
}

# ----------------------------------------------------------------------

length2mask(){ # decimal maskchar (bitmask)
	dec2bin "$1"
	__BSAPM_newvar __BSAPM_l2m $ans
	__BSAPM_l2mans=
	while __BSAPM_TRUE; do
		__BSAPM_high __BSAPM_l2m
		case $__BSAPM_l2mbit in
			1) __BSAPM_l2mans="$2$__BSAPM_l2mans$__BSAPM_l2mans" ;;
			0) __BSAPM_l2mans="$__BSAPM_l2mans$__BSAPM_l2mans" ;;
			*) break ;;
		esac
	done
	eval "${3-ans}=$__BSAPM_l2mans"
}

# ----------------------------------------------------------------------
# pad/unpad

pad(){ # decimallength number (paddednumber)
	length2mask "$1" '?' __BSAPM_padcase
	__BSAPM_newvar __BSAPM_pv "$2"
	__BSAPM_padans=
	while __BSAPM_TRUE; do
		__BSAPM_low __BSAPM_pv
		case "$__BSAPM_padans" in
			$__BSAPM_padcase)
				break
				;;
			*)
				case "$__BSAPM_pvdigit" in
					?) __BSAPM_padans=$__BSAPM_pvdigit$__BSAPM_padans ;;
					*) __BSAPM_padans=0$__BSAPM_padans ;;
				esac
				;;
		esac
	done
	eval "${3-ans}=$__BSAPM_padans"
}

unpad(){
	__BSAPM_newvar __BSAPM_upv "$1"
	__BSAPM_unpadans= __BSAPM_unpadtmp=
	while __BSAPM_TRUE; do
		__BSAPM_low __BSAPM_upv
		case $__BSAPM_upvdigit in
			0) __BSAPM_unpadtmp=0$__BSAPM_unpadtmp ;;
			?) __BSAPM_unpadtmp=$__BSAPM_upvdigit$__BSAPM_unpadtmp; __BSAPM_unpadans=$__BSAPM_unpadtmp ;;
			*) break;
		esac
	done
	case x$__BSAPM_unpadans in x) __BSAPM_unpadans=0 ;; esac
	eval "${2-ans}=$__BSAPM_unpadans"
}

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
__BSAPM_unittests(){

echo ""
echo '=== padding/unpadding ================================================'

for __BSAPM_v in 0 1 10 0001 101010 00012034304259234 921310 00001224; do
	pad 5 $__BSAPM_v
	echo "pad 5 $__BSAPM_v -> $ans"
done
for __BSAPM_v in 0 1 10 0001 101010 00012034304259234 921310 00001224; do
	unpad $__BSAPM_v
	echo "unpad $__BSAPM_v -> $ans"
done

echo ""
echo '=== conversion routines =============================================='

for __BSAPM_v in 0 1 2 8 65534 18446744073709551615; do
	dec2bin $__BSAPM_v
	echo -n "$__BSAPM_v -> $ans -> "
	bin2dec $ans
	echo "$ans"
done

echo ""

for __BSAPM_v in 0 1 2 3 4 5 6 7 8 12 24; do
	length2mask $__BSAPM_v '?'
	echo "$__BSAPM_v	-> $ans"
done

echo ""
echo '=== operations on single digit binary numbers ========================'

echo '          !   &   |   ^   !&  !|  !^  add mul'
for __BSAPM_v1 in 0 1; do
	for __BSAPM_v2 in 0 1; do
		echo -n "    $__BSAPM_v1 $__BSAPM_v2 | "
		not	$__BSAPM_v2;             echo -n "$ans   "
		and	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		or	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		xor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		nand	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		nor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		xnor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		add	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		mul	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans   "
		echo ""
	done
done

echo ""
echo '=== operations on double digit binary numbers ========================'

echo '          !   &   |   ^   !&  !|  !^  add mul'
for __BSAPM_v1 in 00 01 10 11; do
	for __BSAPM_v2 in 00 01 10 11; do
		echo -n "  $__BSAPM_v1 $v__BSAPM_2 | "
		not	$__BSAPM_v2;             echo -n "$ans  "
		and	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		or	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		xor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		nand	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		nor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		xnor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		add	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		mul	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		echo ""
	done
done

echo ""
echo '=== operations on three digit binary numbers ========================='

echo '          !   &   |   ^   !&  !|  !^  add mul'
for __BSAPM_v1 in 000 001 010 011 100 101 110 111; do
	for __BSAPM_v2 in 000 001 010 011 100 101 110 111; do
		echo -n "$__BSAPM_v1 $__BSAPM_v2 | "
		not	$__BSAPM_v2;             echo -n "$ans "
		and	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans "
		or	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans "
		xor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans "
		nand	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans "
		nor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans "
		xnor	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans "
		add	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		mul	$__BSAPM_v1 $__BSAPM_v2; echo -n "$ans  "
		echo ""
	done
done

echo '======================================================================'

}

