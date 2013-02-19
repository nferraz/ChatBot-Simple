#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'ChatBot::Simple' ) || print "Bail out!\n";
}

diag( "Testing ChatBot::Simple $ChatBot::Simple::VERSION, Perl $], $^X" );
