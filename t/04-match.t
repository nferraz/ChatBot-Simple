#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @tests = (
  {
    input => 'foo',
    pattern => 'foo',
    expect => {},
  },
  {
    input => 'foo',
    pattern => 'bar',
    expect => undef,
  },
  {
    input => 'my name is foo',
    pattern => 'my name is :name',
    expect => { ':name' => 'foo' },
  },
  {
    input => 'my name is foo bar',
    pattern => 'my name is :first_name :last_name',
    expect => { ':first_name' => 'foo', ':last_name' => 'bar' },
  },
  {
    input   => 'my name is foo bar',
    pattern => 'my name is *',
    expect  => { '*' => 'foo bar' },
  },
  {
    input   => 'my real name is foo',
    pattern => 'my * is :value',
    expect  => { '*' => 'real name', ':value' => 'foo' },
  },

);

plan tests => scalar @tests;

for my $test (@tests) {
  my $input   = $test->{input};
  my $pattern = $test->{pattern};
  my $expect  = $test->{expect};

  my $output = ChatBot::Simple::match($input,$pattern);

  cmp_deeply($output,$expect,"'$input' ~ '$pattern'");
}
