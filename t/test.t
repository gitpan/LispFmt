#!/usr/local/bin/perl
# -*- perl -*-

# Tests...

use lib '..';
use Lisp::Fmt;

my $testno = 0;

sub test {
    my( $f, $r ) = @_;
    my( $g );

    $testno ++;
    $g = fmt( @{$f} );

    print "got <$g> expected <$r>\n";
    
    if( $g eq $r ){
	print "ok $testno\n";
    }else{
	print "not ok $testno\n";
    }
}


my($fmt) = "Items:~#[ none~; ~a~; ~a and ~a~:;~!{~#[~; and~] ~a~^,~}~].";

@tests = (

    # field test
    [ ["~10a", "abc"], "abc       "],
    [ ["~10!a", "abc"], "       abc"],
    [ ["~10a", "0123456789abc"], "0123456789abc"],
    [ ["~10!a", "0123456789abc"], "0123456789abc"],
    
    # pad character test
    [ ["~10,,,'*a", "abc"], "abc*******"],
    [ ["~10,,,'Xa", "abc"], "abcXXXXXXX"],
    [ ["~10,,,42a", "abc"], "abc*******"],
    [ ["~10,,,'*!a", "abc"], "*******abc"],
    [ ["~10,,3,'*a", "abc"], "abc*******"],
    [ ["~10,,3,'*a", "0123456789abc"], "0123456789abc***"],
    [ ["~10,,3,'*!a", "0123456789abc"], "***0123456789abc"],

    # colinc, minpad padding test
    [ ["~10,8,0,'*a", 123],  "123********"],
    [ ["~10,9,0,'*a", 123],  "123*********"],
    [ ["~10,10,0,'*a", 123], "123**********"],
    [ ["~10,11,0,'*a", 123], "123***********"],
    [ ["~8,1,0,'*a", 123], "123*****"],
    [ ["~8,2,0,'*a", 123], "123******"],
    [ ["~8,3,0,'*a", 123], "123******"],
    [ ["~8,4,0,'*a", 123], "123********"],
    [ ["~8,5,0,'*a", 123], "123*****"],
    [ ["~8,1,3,'*a", 123], "123*****"],
    [ ["~8,1,5,'*a", 123], "123*****"],
    [ ["~8,1,6,'*a", 123], "123******"],
    [ ["~8,1,9,'*a", 123], "123*********"],

    # plural test
    [ ["test~p", 1], "test"],
    [ ["test~p", 2], "tests"],
    [ ["test~p", 0], "tests"],
    [ ["tr~!p", 1], "try"],
    [ ["tr~!p", 2], "tries"],
    [ ["tr~!p", 0], "tries"],
    [ ["~a test~:p", 10], "10 tests"],
    [ ["~a test~:p", 1], "1 test"],

    # tilde test
    [ ["~~~~"], "~~"],
    [ ["~3~"], "~~~"],

    # indirection test
    [ ["~a ~? ~a", 10, "~a ~a", [20, 30], 40], "10 20 30 40"],
    [ ["~a ~@? ~a", 10, "~a ~a", 20, 30, 40], "10 20 30 40"],

    # variable parameter
    [ ["~va", 10, "abc"], "abc       "],
    [ ["~v,,,va", 10, 42, "abc"], "abc*******"],

    #  number of remaining arguments as parameter
    [ ["~#,,,'*!a ~a ~a ~a", 1, 1, 1, 1], "***1 1 1 1"],

    # argument jumping
    [ ["~a ~* ~a", 10, 20, 30], "10  30"],
    [ ["~a ~2* ~a", 10, 20, 30, 40], "10  40"],
    [ ["~a ~:* ~a", 10], "10  10"],
    [ ["~a ~a ~2:* ~a ~a", 10, 20], "10 20  10 20"],
    [ ["~a ~a ~!* ~a ~a", 10, 20], "10 20  10 20"],
    [ ["~a ~a ~4!* ~a ~a", 10, 20, 30, 40, 50, 60], "10 20  50 60"],

    # char test
    [ ["~c", "a"], "a"],
    [ ["~!c", "a"], "\"a\""],
    [ ["~65c"], "A"],
    [ ["~7!c"], '"\07"'],

    [ ["~!c" , 32], '"\040"'],
    [ ["~!c" , 0],  '"\00"'],
    [ ["~!c" , 27], '"\033"'],
    [ ["~!c" , 127], '"\0177"'],
    [ ["~!c" , 128], '"\0200"'],
    [ ["~!c" , 255], '"\0377"'],

    [ ["~:c", "a"], "a"],
    [ ["~7:c"], "BEL"],
    [ ["~:c" ,1], "SOH"],
    [ ["~:c" ,27], "ESC"],
    [ ["~:c" ,128], "\\0200"],
    [ ["~:c" ,127], "\\0177"],
    [ ["~:c" ,255], "\\0377"],

    # case conversion
    [ ["~a ~(~a~) ~a", "abc", "HELLO WORLD", "xyz"], "abc hello world xyz"],
    [ ["~a ~:(~a~) ~a", "abc", "HELLO WORLD", "xyz"], "abc Hello World xyz"],
    [ ["~a ~!(~a~) ~a", "abc", "HELLO WORLD", "xyz"], "abc Hello world xyz"],
    [ ["~a ~:!(~a~) ~a", "abc", "hello world", "xyz"], "abc HELLO WORLD xyz"],
    [ ["~:!(~p~)",2],"S"],
    [ ["~:(~a ~a ~a~) ~a", "abc", "xyz", "123", "world"], "Abc Xyz 123 world"],

    # conditionals
    [ ["~[abc~;xyz~]", 0], "abc"],
    [ ["~[abc~;xyz~]", 1], "xyz"],
    [ ["~[abc~;xyz~:;456~]", 99], "456"],
    [ ["~0[abc~;xyz~:;456~]"], "abc"],
    [ ["~1[abc~;xyz~:;456~] ~a", 100], "xyz 100"],
    [ ["~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]"], "no arg"],
    [ ["~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]", 10], "10"],
    [ ["~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]", 10, 20], "10 and 20"],
    [ ["~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]", 10, 20, 30], "10, 20 and 30"],
    [ ["~:[hello~;world~] ~a", 1, 10], "world 10"],
    [ ["~:[hello~;world~] ~a","", 10], "hello 10"],
    [ ["~![~a tests~]", ""], ""],
    [ ["~![~a tests~]", 10], "10 tests"],
    [ ["~![~a test~:p~] ~a", 10, "done"], "10 tests done"],
    [ ["~![~a test~:p~] ~a", 1, "done"], "1 test done"],
    [ ["~![~a test~:p~] ~a", 0, "done"], "0 tests done"],
    [ ["~![~a test~:p~] ~a", "", "done"], " done"],
    [ ["~![ level = ~A~]~![ length = ~A~]", "", 5], " length = 5"],
    [ ["~[abc~;~[4~;5~;6~]~;xyz~]", 0], "abc"],   # ; nested conditionals (irrghh]
    [ ["~[abc~;~[4~;5~;6~]~;xyz~]", 2], "xyz"],
    [ ["~[abc~;~[4~;5~;6~]~;xyz~]", 1, 2], "6"],

    # iteration
    [ ["~{ ~a ~}", [qw(a b c)]], " a  b  c "],
    [ ["~{ ~a ~}", []], ""],
    [ ["~{ ~a ~5,,,'*a~}", [qw(a b c d)]], " a b**** c d****"],
    [ ["~{ ~a,~a ~}", [qw(a 1 b 2 c 3)]], " a,1  b,2  c,3 "],
    [ ["~2{ ~a,~a ~}", [qw(a 1 b 2 c 3)]], " a,1  b,2 "],
    [ ["~3{~a ~} ~a", [qw(a b c d e)], 100], "a b c  100"],
    [ ["~0{~a ~} ~a", [qw(a b c d e)], 100], " 100"],
    [ ["~:{ ~a,~a ~}", [[qw(a b)], [qw(c d e f)], [qw(g h)]]], " a,b  c,d  g,h "],
    [ ["~2:{ ~a,~a ~}", [[qw(a b)], [qw(c d e f)], [qw(g h)]]], " a,b  c,d "],
    [ ["~!{ ~a,~a ~}", qw(a 1 b 2 c 3)], " a,1  b,2  c,3 "],
    [ ["~2!{ ~a,~a ~} <~a|~a>", qw(a 1 b 2 c 3)], " a,1  b,2  <c|3>"],
    [ ["~:!{ ~a,~a ~}", [qw(a 1)], [qw(b 2)], [qw(c 3)]], " a,1  b,2  c,3 "],
    [ ["~2:!{ ~a,~a ~} ~a", [qw(a 1)], [qw(b 2)], [qw(c 3)]], " a,1  b,2  [c, 3]"],
    [ ["~{~}", "<~a,~a>", [qw(a 1 b 2 c 3)]], "<a,1><b,2><c,3>"],
    [ ["~{ ~a ~{<~a>~}~} ~a", ["a", [1, 2], "b", [3, 4]], 10], " a <1><2> b <3><4> 10"],

    # up and out
    [ ["abc ~^ xyz"], "abc "],
    [ ["~!(abc ~^ xyz~) ~a", 10], "Abc  xyz 10"],
    [ ["done. ~^ ~A warning~:p. ~^ ~A error~:p."], "done. "],
    [ ["done. ~^ ~A warning~:p. ~^ ~A error~:p.", 10], "done.  10 warnings. "],
    [ ["done. ~^ ~A warning~:p. ~^ ~A error~:p.", 10, 1], "done.  10 warnings.  1 error."],
    [ ["~{ ~a ~^<~a>~} ~a", [qw(a b c d e f)], 10], " a <b> c <d> e <f> 10"],
    [ ["~{ ~a ~^<~a>~} ~a", [qw(a b c d e)], 10], " a <b> c <d> e  10"],
    [ ["abc~0^ xyz"], "abc"],
    [ ["abc~9^ xyz"], "abc xyz"],
    [ ["abc~7,4^ xyz"], "abc xyz"],
    [ ["abc~7,7^ xyz"], "abc"],
    [ ["abc~3,7,9^ xyz"], "abc"],
    [ ["abc~8,7,9^ xyz"], "abc xyz"],
    [ ["abc~3,7,5^ xyz"], "abc xyz"],

    # numerical test
    [ ["~d", 100], "100"],
    [ ["~x", 100], "64"],
    [ ["~o", 100], "144"],
    [ ["~b", 100], "1100100"],
    [ ["~!d", 100], "+100"],
    [ ["~!d", -100], "-100"],
    [ ["~!x", 100], "+64"],
    [ ["~!o", 100], "+144"],
    [ ["~!b", 100], "+1100100"],
    [ ["~10d", 100], "       100"],
    [ ["~:d", 123], "123"],
    [ ["~:d", 1234], "1,234"],
    [ ["~:d", 12345], "12,345"],
    [ ["~:d", 123456], "123,456"],
    [ ["~:d", 12345678], "12,345,678"],
    [ ["~:d", -123], "-123"],
    [ ["~:d", -1234], "-1,234"],
    [ ["~:d", -12345], "-12,345"],
    [ ["~:d", -123456], "-123,456"],
    [ ["~:d", -12345678], "-12,345,678"],
    [ ["~10:d", 1234], "     1,234"],
    [ ["~10:d", -1234], "    -1,234"],
    [ ["~10,'*d", 100], "*******100"],
    [ ["~10,,'|:d", 12345678], "12|345|678"],
    [ ["~10,,,2:d", 12345678], "12,34,56,78"],
    [ ["~14,'*,'|,4:!d", 12345678], "****+1234|5678"],
    [ ["~10r", 100], "100"],
    [ ["~2r", 100], "1100100"],
    [ ["~8r", 100], "144"],
    [ ["~16r", 100], "64"],
    [ ["~16,10,'*r", 100], "********64"],

    # complexity tests

    [ [$fmt ], "Items: none."],
    [ [$fmt, "foo"], "Items: foo."],
    [ [$fmt, "foo", "bar"], "Items: foo and bar."],
    [ [$fmt, "foo", "bar", "baz"], "Items: foo, bar, and baz."],
    [ [$fmt, "foo", "bar", "baz", "zok"], "Items: foo, bar, baz, and zok."],

    # tab tests
    [ ["~0&~3t"], "   "],
    [ ["~0&~10t"], "          "],
    [ ["~0&1234567890~,8tABC"],  "1234567890       ABC"],
    [ ["~0&1234567890~0,8tABC"], "1234567890      ABC"],
    [ ["~0&1234567890~1,8tABC"], "1234567890       ABC"],
    [ ["~0&1234567890~2,8tABC"], "1234567890ABC"],
    [ ["~0&1234567890~3,8tABC"], "1234567890 ABC"],
    [ ["~0&1234567890~4,8tABC"], "1234567890  ABC"],
    [ ["~0&1234567890~5,8tABC"], "1234567890   ABC"],
    [ ["~0&1234567890~6,8tABC"], "1234567890    ABC"],
    [ ["~0&1234567890~7,8tABC"], "1234567890     ABC"],
    [ ["~0&1234567890~8,8tABC"], "1234567890      ABC"],
    [ ["~0&1234567890~9,8tABC"], "1234567890       ABC"],
    [ ["~0&1234567890~10,8tABC"], "1234567890ABC"],
    [ ["~0&1234567890~11,8tABC"], "1234567890 ABC"],
    [ ["~0&12345~,8tABCDE~,8tXYZ"], "12345    ABCDE   XYZ"],
    [ ["~,8t+++~,8t==="], " +++     ==="],
    [ ["~0&ABC~,8,'.tDEF"], "ABC......DEF"],
    [ ["~0&~3,8!tABC"], "        ABC"],
    [ ["~0&1234~3,8!tABC"], "1234    ABC"],
    [ ["~0&12~3,8!tABC~3,8!tDEF"], "12      ABC     DEF"],

    # justification tests
    [ ["~10<~A~>", "foo"], "       foo"],
    [ ["~10!<~A~>", "foo"], "foo       "],
    [ ["~10!:<~A~>", "foo"], "    foo   "],

    [ ["~10<~A~;~A~>", "foo", "bar"], "foo    bar"],
    [ ["~10:<~A~;~A~>", "foo", "bar"], "  foo  bar"],
    [ ["~10!<~A~;~A~>", "foo", "bar"], "foo  bar  "],
    [ ["~10!:<~A~;~A~>", "foo", "bar"], "  foobar  "],

    [ ["~15<~A~;~A~;~A~>", "foo", "bar", "baz"], "foo  bar    baz"],
    [ ["~15:<~A~;~A~;~A~>", "foo", "bar", "baz"], "  foobar    baz"],
    [ ["~15!<~A~;~A~;~A~>", "foo", "bar", "baz"], "foo  bar  baz  "],
    [ ["~15!:<~A~;~A~;~A~>", "foo", "bar", "baz"], "  foobar  baz  "],
    
    # roman numeral test
    [ ["~!r", 4], "IV"],
    [ ["~!r", 19], "XIX"],
    [ ["~!r", 50], "L"],
    [ ["~!r", 100], "C"],
    [ ["~!r", 1000], "M"],
    [ ["~!r", 99], "XCIX"],
    [ ["~!r", 1994], "MCMXCIV"],

    # old roman numeral test
    [ ["~:!r", 4], "IIII"],
    [ ["~:!r", 5], "V"],
    [ ["~:!r", 10], "X"],
    [ ["~:!r", 9], "VIIII"],
    
    # cardinal/ordinal English number test
    [ ["~r", 4], "four"],
    [ ["~r", 10], "ten"],
    [ ["~r", 19], "nineteen"],
    [ ["~r", 1984], "one thousand, nine hundred eighty four"],
    [ ["~:r", -1984], "minus one thousand, nine hundred eighty fourth"],

    # perl-esque formats
    [ ["~<<<<<<", "foo"], "foo    "],
    [ ["~>>>>>>", "bar"], "    bar"],
    [ ["~||||||", "baz"], "  baz  "],
    [ ["~>>>>>~<<<<<~||", "foo", "bar", "."], "   foobar    . "],

    # implementation specific extensions
    [ ["~=(~A~A~=)", "~", "A", "foo"], "foo"],

);

print "1..", scalar(@tests), "\n";
foreach (@tests){
    test( @{$_} );
}

