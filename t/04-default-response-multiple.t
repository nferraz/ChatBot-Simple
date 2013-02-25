#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

plan tests => 2;

pattern 'hi' => [ 'hi!', 'hello!', 'howdy?' ];

srand(1);

{
  my $response = ChatBot::Simple::process_pattern('hi');
  is($response, 'hi!');
}

{
  my $response = ChatBot::Simple::process_pattern('hi');
  is($response, 'hello!');
}

{
  my $response = ChatBot::Simple::process_pattern('hi');
  is($response, 'howdy?');
}
