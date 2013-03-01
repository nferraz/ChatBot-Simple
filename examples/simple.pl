#!/usr/bin/perl

use strict;
use warnings;

use Introduction;
use Calculator;

use ChatBot::Simple;

print "> ";
while (my $input = <>) {
  chomp $input;

  my $response = ChatBot::Simple::process($input);

  print "$response\n\n> ";
}
