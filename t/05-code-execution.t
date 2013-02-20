#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

plan tests => 1;

pattern 'my name is :name' => sub {
} => 'Hello, :name';

my $response = ChatBot::Simple::process_pattern('my name is larry');

is($response, 'Hello, larry');
