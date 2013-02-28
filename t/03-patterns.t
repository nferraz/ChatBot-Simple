#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @test = (
    {
        pattern  => 'what is your name',
        response => 'my name is chatbot',
    },
);

plan tests => scalar @test + 1;

# setup; no tests are performed here
for my $test (@test) {
    my $pattern  = $test->{pattern};
    my $response = $test->{response};

    pattern $pattern => $response;
}

# test if setup worked
my @patterns = ChatBot::Simple::patterns();

my @expected = [
    {
        'pattern'  => 'what is your name',
        'response' => 'my name is chatbot',
        'code'   => undef
    }
];

cmp_deeply( \@patterns, \@expected ) or warn Dumper(@patterns);

for my $test (@test) {
    my $pattern  = $test->{pattern};
    my $expected = $test->{response};

    my $response = ChatBot::Simple::process_pattern($pattern);

    is($response,$expected);
}
