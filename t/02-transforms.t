#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @test = (
    {
        input  => 'hello',
        output => 'hi',
    },
);

plan tests => scalar @test + 1;

for my $test (@test) {
    my $input  = $test->{input};
    my $output = $test->{output};

    transform $input => $output;
}

my @transforms = ChatBot::Simple::transforms();

my @expected = [
    {
        'input'  => 'hello',
        'output' => 'hi',
        'code'   => undef
    }
];

cmp_deeply( \@transforms, \@expected ) or warn Dumper(@transforms);

for my $test (@test) {
    my $input  = $test->{input};
    my $expected = $test->{output};

    my $output = ChatBot::Simple::process_transform($input);

    is($output,$expected);
}
