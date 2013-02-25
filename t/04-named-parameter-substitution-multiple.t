#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

plan tests => 1;

pattern 'my name is :first_name :last_name' => 'Hello, :first_name :last_name';

my $response = ChatBot::Simple::process_pattern('my name is Larry Wall');

is($response, 'Hello, Larry Wall');
