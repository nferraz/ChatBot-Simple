#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

plan tests => 2;

{
  my $match = ChatBot::Simple::match('hello world', 'hello :name');
  ok($match);
}

{
  my $match = ChatBot::Simple::match('foo bar', 'hello :name');
  ok(!$match); # *not* match
}
