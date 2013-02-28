#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @test = (
    {
        pattern  => 'hello',
        transform => 'hi',
    },
);

plan tests => scalar @test + 1;

for my $test (@test) {
    my $pattern  = $test->{pattern};
    my $transform = $test->{transform};

    transform $pattern => $transform;
}

my @transforms = ChatBot::Simple::transforms();

my @expected = [
    {
        'pattern'  => 'hello',
        'transform' => 'hi',
        'code'   => undef
    }
];

cmp_deeply( \@transforms, \@expected ) or warn Dumper(@transforms);

for my $test (@test) {
    my $pattern  = $test->{pattern};
    my $expected = $test->{transform};

    my $transform = ChatBot::Simple::process_transform($pattern);

    is($transform,$expected);
}
