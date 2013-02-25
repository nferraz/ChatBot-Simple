#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

plan tests => 1;

pattern 'hi' => 'hi!';

my $response = ChatBot::Simple::process_pattern('hi');

is($response, 'hi!');
