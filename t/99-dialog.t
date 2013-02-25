#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @tests = (
  {
    input => "my name is foo",
    expect => "ok",
  },
  {
    input => "what's my name?",
    expect => "your name is foo",
  },
  {
    input => "my name is bar",
    expect => "I thought your name was foo",
  },
  {
    input => "what's my name?",
    expect => "your name is bar",
  },
);

# now we implement the rules above

transform "what's" => "what is";

pattern "my name is :name" => "ok";

pattern "what is my name" => "your name is :name";


plan tests => scalar @tests;

my %mem;

for my $test (@tests) {
  my $output = ChatBot::Simple::process_pattern($test->{input});
  is($output,$test->{expect},$test->{input} . " -> " . $test->{expect});
}
