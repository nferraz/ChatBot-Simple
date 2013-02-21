#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

plan tests => 3;

my $count = 0;
pattern 'count' => sub {
  return ++$count;
};

for my $i (1..3) {
  my $response = ChatBot::Simple::process_pattern('count');
  is($response, $i);
}
