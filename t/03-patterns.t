#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @test = (
    {
        input  => 'what is your name',
        output => 'my name is chatbot',
    },
);

plan tests => scalar @test + 1;

# setup; no tests are performed here
for my $test (@test) {
    my $input  = $test->{input};
    my $output = $test->{output};

    pattern $input => $output;
}

# test if setup worked
my @patterns = ChatBot::Simple::patterns();

my @expected = [
    {
        'input'  => 'what is your name',
        'output' => [ 'my name is chatbot' ],
        'code'   => undef
    }
];

cmp_deeply( \@patterns, \@expected ) or warn Dumper(@patterns);

for my $test (@test) {
    my $input  = $test->{input};
    my $expected = $test->{output};

    my $output = ChatBot::Simple::process_pattern($input);

    is($output,$expected);
}
