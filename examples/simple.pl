#!/usr/bin/perl

use strict;
use warnings;

# this example shows how to organize data in a separate package
# and how to set topics, memorize stuff, etc.

package Foo;

use ChatBot::Simple;

no warnings 'uninitialized';

my %mem;

transform 'hello' => 'hi';

pattern 'hi' => sub {
  my ($input, $param) = @_;
  if (!$mem{name}) {
    $mem{topic} = 'name';
    return "hi! what's your name?";
  }
  return;
};

pattern "my name is :name" => sub {
  my ($input,$param) = @_;
  $mem{name} = $param->{':name'};
  $mem{topic} = 'how_are_you';
  return "Hello, :name! How are you?";
};

transform 'goodbye', 'bye-bye', 'sayonara' => 'bye';

pattern 'bye' => 'bye!';

pattern 'fine' => 'great!';

pattern qr{^(\w+)$} => sub {
  my ($input,$param) = @_;
  if ($mem{topic} eq 'name') {
    $mem{name} = $param->{1};
    $mem{topic} = 'how_are_you';
    return "Hello, $mem{name}! How are you?";
  }
  return;
} => "I don't understand that!";


##### MAIN LOOP ######

package main;

use ChatBot::Simple;

print "> ";
while (my $input = <>) {
  chomp $input;

  my $response = ChatBot::Simple::process($input);

  print "$response\n\n> ";
}
