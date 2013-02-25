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

  my $output = shift @rest;

  push @patterns, {
    input  => $input,
    output => $output,
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
  my ($str, $pattern) = @_;

  my @named_vars = $pattern =~ m{(:\S+)}g;

  # make ":var" match '(\S+)'
  $pattern =~ s{:\S+}{'(\S+)'}ge;

  if ($str =~ m/$pattern/) {
    if ($1) {
      my @match = ($1,$2,$3,$4,$5,$6,$7,$8,$9);
      my %result = map { $_ => shift @match } @named_vars;
      return \%result;
    } else {
      return {}; # true, but no variables to replace
    }
  }

  return;
}

sub replace_vars {
  my ($pattern, $named_vars) = @_;
  for my $var (keys %$named_vars) {
    next if $var eq '';
    $pattern =~ s{$var}{$named_vars->{$var}}g;
  }
  return $pattern;
}

sub process_transform {
  my $str = shift;

  for my $tr (@transforms) {
    next unless match($str, $tr->{input});
    if (ref $tr->{code} eq 'CODE') {
      warn "Transform code not implemented\n";
    }
    #warn sprintf("Replace '%s' with '%s' in '%s'\n", $tr->{input}, $tr->{output}, $str);
    $str =~ s/$tr->{input}/$tr->{output}/g;
  }

  # No transformations found...
  return $str;
}

sub process_pattern {
  my $str = shift;

  for my $pt (@patterns) {
    my $match = match($str, $pt->{input});
    next if !$match;

    my $response;

    if ($pt->{code} and ref $pt->{code} eq 'CODE') {
      $response = $pt->{code}($str,$match);
    }

    $response //= $pt->{output};

    if (ref $response eq 'ARRAY') {
      # deal with multiple responses
      $response = $response->[ rand(scalar(@$response)) ];
    }

    my $response_interpolated = replace_vars($response, $match);

    return $response_interpolated;
  }

  warn "Couldn't find a match for '$str'";
  return;
}

sub process {
  my $str = shift;
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

__END__

=head1 NAME

ChatBot::Simple - new and flexible chatbot engine in Perl

=head1 SYNOPSIS

  use ChatBot::Simple;

  pattern 'hello' => 'hi!';

  pattern "what is your name" => "my name is ChatBot::Simple, and yours?";

  pattern "my name is :name" => "nice to meet you, :name";

  transform "what's" => "what is";

=head1 DESCRIPTION

ChatBot::Simple is a new and flexible chatbot engine in Perl.

Instead of specifying the chatbot knowledge base in xml, we are
going to use the powerfult text manipulation capabilities of Perl.

=head1 METHODS

=head2 pattern

pattern is used to register response patterns:

  pattern 'hello' => 'hi!';

Multiple (random) responses:

  pattern 'hello' => [ 'hi!', 'hello!', 'what\'s up?' ];

=head2 transform

transform is used to register text normalizations:

  transform "what's" => "what is";
  pattern "what is your name" => "my name is ChatBot::Simple";

=head2 process

process will read a sentence, apply all the possible transforms and
patterns, and return a response.

=head1 TODO

There are some powerful features that I'm planning, that will make
ChatBot::Simple much more powerful than any engine I know of.

Named variables:

  pattern "my name is :name" => "hello, :name!";

Code execution:

  my %mem;

  pattern "my name is :name" => sub {
    my ($str,$param) = @_;
    $mem{name} = $param->{name};
  } => "nice to meet you, :name!";

  pattern "what is my name?" => sub {
    return $mem{name} ? "Your name is $mem{name}"
                      : "I don't know!";
  };

(See more examples in the C<t/> directory)

=head1 METHODS

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2013 Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
