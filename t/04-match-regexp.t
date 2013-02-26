#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @tests = (
  {
    input => 'hello',
    pattern => qr/hello/,
    expect => {},
  },
  {
    input => 'my name is foo',
    pattern => qr/my name is (\w+)/,
    expect => { '1' => 'foo' },
  },
  {
    input => 'my name is foo bar',
    pattern => qr/my name is (\w+) (\w+)/,
    expect => { '1' => 'foo', '2' => 'bar' },
  },
  {
    input => 'foo',
    pattern => qr/bar/,
    expect => undef,
  },
);

plan tests => scalar @tests;

for my $test (@tests) {
  my $input   = $test->{input};
  my $pattern = $test->{pattern};
  my $expect  = $test->{expect};

  my $output = ChatBot::Simple::match($input, $pattern);

  cmp_deeply($output,$expect,"'$input' ~ $pattern");
}
