# bs-math
## an arbitrary precision maths library written entirely in Bourne shell     

In late 2001, I wrote <A HREF="bs-math.sh">the skeleton</A>
of a pure <A HREF="https://www.freebsd.org/cgi/man.cgi?query=sh&manpath=4.4BSD+Lite2"><CODE>/bin/sh</CODE></A> implementation of various mathematical
operations (doesn't even use <CODE>test</CODE> or <CODE>echo</CODE>).
It includes the boolean operators and conversion between binary and
decimal, plus a few helper functions.
The code is notionally arbitrary-precision, but will in fact be limited
by how long a particular Bourne shell implementation allows variables
to be.

A <A HREF="bs-broadcast.sh">sample script</A> calculates a broadcast
address given IP address and netmask, and is merely proof-of-concept
code to disprove Randal L. Schwartz's assertion, on the SAGE mailing list,
that it couldn't be done. He had written:

<BLOCKQUOTE>
There are no solutions in sh (other than brute force).  Sh has insufficient
computing ability - it'll have to call some other program (and I bet a lot
of the answers will probably try using bc or expr).
</BLOCKQUOTE>

Of course, <A HREF="http://en.wikipedia.org/wiki/Clarke's_law"><CITE>Clarke's First Law</CITE></A> applies here.

Coming back to it a year later, I realized that the code doesn't understand
negative numbers. I'm not entirely sure how to rectify that;
while the code does have all the boolean operators, it is arbitrary
precision, and so I don't think normal digital-computer like operations
will work. It's been over a decade since I studied that sort of thing.
And, do I really care?

