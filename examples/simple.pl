#!/usr/bin/perl

use strict;
use warnings;

use ChatBot::Simple;

# the chatbot knowlege is stored in perl modules:
use Introduction;
use Calculator;

# TODO: use Module::Pluggable to load knowledge automatically

print "> ";
while (my $input = <>) {
  chomp $input;

  my $response = ChatBot::Simple::process($input);

  print "$response\n\n> ";
}
