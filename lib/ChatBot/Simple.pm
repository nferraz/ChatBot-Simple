package ChatBot::Simple;

use strict;
use warnings;

our $VERSION = '0.01';

require Exporter;

our @ISA = qw/Exporter/;

our @EXPORT = qw/pattern transform %mem/;

my %mem;

my (@patterns, @transforms);

sub pattern {
  my ($input, @rest) = @_;

  my $code = ref $rest[0] eq 'CODE' ? shift @rest : undef;

  push @patterns, {
    input  => $input,
    output => [ @rest ],
    code   => $code,
  };
}

sub transform {
  my (@expr) = @_;

  my $transform_to = pop @expr;

  my $code = ref $expr[-1] eq 'CODE' ? pop @expr : undef;

  for my $exp (@expr) {
    push @transforms, {
      input  => $exp,
      output => $transform_to,
      code   => $code,
    };
  }
}

sub match {
  my ($str1,$str2) = @_;
  # TODO: take variables into consideration
  # example: "my name is foo" should match "my name is :name"
  return lc($str1) eq lc($str2);
}

sub process_transform {
  my $str = shift;

  for my $tr (@transforms) {
    next unless match($str, $tr->{input});
    warn "Transform code not implemented\n" if $tr->{code};
    return process_transform( $tr->{output} );
  }

  # No transformations found...
  return $str;
}

sub process_pattern {
  my $str = shift;

  for my $pt (@patterns) {
    next unless match($str, $pt->{input});
    warn "Pattern code not implemented\n" if $pt->{code};
    my $response = $pt->{output}->[0]; # TODO: deal with multiple possible responses
    return $response;
  }

  return;
}

sub process {
  my $str = shift;
  $DB::single=1;
  my $tr  = process_transform($str);
  my $res = process_pattern($tr);
  return $res;
}

sub patterns {
  return \@patterns;
}

sub transforms {
  return \@transforms;
}

1;
