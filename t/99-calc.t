#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use ChatBot::Simple;

my @tests = (
  {
    input => "what's 2 + 2",
    expect => "4"
  },
  {
    input => "what's 2 - 2",
    expect => "0",
  },
  {
    input => "what's foo + bar",
    expect => "I don't know how to calculate that",
  },
  {
    input => "what's 2 # 2",
    expect => "I don't know how to calculate that",
  },
);

# now we implement the rules above

transform "what's" => "what is";

pattern "what is :num1 :op :num2?" => sub {
    my ($str,$param) = @_;

    die Dumper $param;

    my ($num1,$op,$num2) = ($param->{num1}, $param->{op}, $param->{num2});

    if ($num1 =~ /\D/ or $num2 =~ /\D/) {
        return "I don't know how to calculate that";
    }

    return $op eq '+' ? $num1 + $num2
         : $op eq '-' ? $num1 - $num2
         : $op eq '*' ? $num1 * $num2
         : $op eq '/' ? $num1 / $num2
         : "I don't know how to calculate that";
};


plan tests => scalar @tests;

for my $test (@tests) {
  my $output = ChatBot::Simple::process($test->{input});
  is($output,$test->{expect},$test->{input} . " -> " . $test->{expect});
}
