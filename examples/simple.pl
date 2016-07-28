#!/usr/bin/perl

use strict;
use warnings;

use ChatBot::Simple;

# the chatbot knowlege is stored in perl modules:
use Introduction;
use Calculator;

context '';

print "> ";
while (my $input = <>) {
  chomp $input;

  my $response = ChatBot::Simple::process($input);

  print "$response\n\n$ChatBot::Simple::__context__> ";
}
