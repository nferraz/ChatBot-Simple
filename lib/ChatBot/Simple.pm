package ChatBot::Simple;

use strict;
use warnings;
use Data::Dumper;

our $VERSION = '0.01';

require Exporter;

our @ISA = qw/Exporter/;

our @EXPORT = qw/context pattern transform/;

our $__context__ = '';

my ( %patterns, %transforms, %memory );

sub context {
    my ($context) = @_;

    $__context__ = $context;

    return;
}

sub pattern {
    my ( $pattern, @rest ) = @_;

    my @patterns = ref $pattern eq 'ARRAY' ? @{$pattern} : ($pattern);
    my $code     = ref $rest[0] eq 'CODE'  ? shift @rest : undef;

    my $response = shift @rest;

    $patterns{$__context__} //= [];

    for my $pattern (@patterns) {
        push @{ $patterns{$__context__} },
          {
            pattern  => $pattern,
            response => $response,
            code     => $code,
          };
    }
}

sub transform {
    my ( $pattern, @rest ) = @_;

    my @patterns = ref $pattern eq 'ARRAY' ? @{$pattern} : ($pattern);
    my $code     = ref $rest[0] eq 'CODE'  ? shift @rest : undef;

    my $transform_to = shift @rest;

    $transforms{$__context__} //= [];
    for my $pattern (@patterns) {
        push @{ $transforms{$__context__} },
          {
            pattern   => $pattern,
            transform => $transform_to,
            code      => $code,
          };
    }

}

sub match {
    my ( $input, $pattern ) = @_;

    # regex match
    if ( ref $pattern eq 'Regexp' ) {
        if ( $input =~ $pattern ) {
            my @matches = ( $1, $2, $3, $4, $5, $6, $7, $8, $9 );
            my $i       = 0;
            my %result  = map { ':' . ++$i => $_ } grep { defined $_ } @matches;
            return \%result;
        }
        else {
            return;
        }
    }

    # text pattern (like "my name is :name")

    # first, extract the named variables
    my @named_vars = $pattern =~ m{(:\S+)}g;

    # transform named variables to '(\S+)'
    $pattern =~ s{:\S+}{'(.*)'}ge;

    # do the pattern matching
    if ( $input =~ m/\b$pattern\b/ ) {
        my @matches = ( $1, $2, $3, $4, $5, $6, $7, $8, $9 );
        my %result = map { $_ => shift @matches } @named_vars;

        # override memory with new information
        %memory = ( %memory, %result );

        return \%result;
    }

    return;
}

sub replace_vars {
    my ( $pattern, $named_vars ) = @_;

    my %vars = ( %memory, %{$named_vars} );

    for my $var ( keys %vars ) {
        next if $var eq '';

        # escape regex characters
        my $quoted_var = $var;
        $quoted_var =~ s{([\.\*\+])}{\\$1}g;

        $pattern =~ s{$quoted_var}{$vars{$var}}g;
    }
    return $pattern;
}

sub process_transform {
    my $str = shift;

    for my $tr ( @{ $transforms{$__context__} } ) {
        next unless match( $str, $tr->{pattern} );
        if ( ref $tr->{code} eq 'CODE' ) {
            warn "Transform code not implemented\n";
        }

        my $input = $tr->{pattern};
        my $vars = match( $str, $input );

        if ($vars) {
            my $input = replace_vars( $tr->{pattern}, $vars );
            $str =~ s/$input/$tr->{transform}/g;
            $str = replace_vars( $str, $vars );
        }
    }

    # No transformations found...
    return $str;
}

sub process_pattern {
    my $input = shift;

    for my $context ( 'global', $__context__, 'fallback' ) {
        for my $pt ( @{ $patterns{$context} } ) {
            my $match = match( $input, $pt->{pattern} );
            next if !$match;

            my $response;

            if ( $pt->{code} and ref $pt->{code} eq 'CODE' ) {
                $response = $pt->{code}( $input, $match );
            }

            $response //= $pt->{response};

            if ( ref $response eq 'ARRAY' ) {

                # deal with multiple responses
                $response = $response->[ rand( scalar(@$response) ) ];
            }

            my $response_interpolated = replace_vars( $response, $match );

            return $response_interpolated;
        }
    }

    warn "Couldn't find a match for '$input' (context = '$__context__')\n";
    warn Dumper $patterns{$__context__};

    return '';
}

sub process {
    my $input = shift;
    my $tr    = process_transform($input);
    my $res   = process_pattern($tr);
    return $res;
}

sub patterns {
    return \@{ $patterns{$__context__} };
}

sub transforms {
    return \@{ $transforms{$__context__} };
}

1;

__END__

=head1 NAME

ChatBot::Simple - new and flexible chatbot engine in Perl

=head1 SYNOPSIS

  use ChatBot::Simple;

  # simple pattern/response
  pattern 'hello' => 'hi!';
  pattern "what is your name?" => "my name is ChatBot::Simple";

  # simple transformations
  transform "what's" => "what is";

  # simple responses
  process("hello");
  process("what's your name?");

  # and much more!

=head1 DESCRIPTION

ChatBot::Simple is a new and flexible chatbot engine in Perl.

Instead of specifying the chatbot knowledge base in xml, we are
going to use the powerful text manipulation capabilities of Perl.

=head1 METHODS

=head2 pattern

pattern is used to register response patterns:

  pattern 'hello' => 'hi!';

=head2 transform

transform is used to register text normalizations:

  transform "what's" => "what is";

Like C<pattern>, you can use named variables and code:

  transform "I am called :name" => "my name is :name";

  transform "foo" => sub {
    # ...
  } => "bar";

Differently from C<pattern>, you can specify multiple transformations
at once:

  transform "goodbye", "byebye", "hasta la vista", "sayonara" => "bye";

=head2 process

process will read a sentence, apply all the possible transforms and
patterns, and return a response.

=head1 FEATURES

=head2 Multiple (random) responses:

  pattern 'hello' => [ 'hi!', 'hello!', 'what\'s up?' ];

=head2 Named variables

  pattern "my name is :name" => "hello, :name!";

=head2 Code execution

  my %mem;

  pattern "my name is :name" => sub {
    my ($input,$param) = @_;
    $mem{name} = $param->{name};
  } => "nice to meet you, :name!";

=head2 Regular expressions

  pattern qr{what is (\d+) ([+-/*]) (\d+)} => sub {
    my ($input,$param) = @_;
    my ($n1,$op,$n2) = ($param->{1}, $param->{2}, $param->{3});
    # ...
    return $result;
  };

(See more examples in the C<t/> directory)

=head1 METHODS

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2013 Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
