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

  # simple pattern/responses
  pattern 'hello'              => 'hi!';
  pattern 'what is your name?' => 'my name is ChatBot::Simple';
  pattern 'my name is :name'   => 'hello, :name! how do you do?';

  # simple transformations
  transform "what's" => "what is";

  # simple responses
  process("hello");             # -> 'hi!'
  process("what's your name?"); # -> 'my name is ChatBot::Simple'
  process("my name is foo");    # -> 'hello, foo! how do you do?'

  # and much more!

=head1 DESCRIPTION

ChatBot::Simple is a new and flexible chatbot engine in Perl.

=head1 METHODS

=head2 pattern

Use C<pattern> to declare input patterns and responses:

    pattern 'hello'         => 'hi!';
    pattern ['hello', 'hi'] => ['hello', 'hi', 'how are you doing?']

    # named variables
    pattern 'my name is :name' => 'hello, :name!';

    # regular expressions with captured variables
    pattern qr{good (morning|afternoon|night)} => 'good :1, :name!';

    # perl code
    pattern 'what is :n1 times :n2' => sub {
        my ($input, $param) = @_;
        my ($n1, $n2) = ($param->{n1}, $param->{n2});
        if ($n1 <= 10 and $n2 <= 10) {
            my $answer = $param->{n1} + $param->{n2};
            return "the answer is $answer!";
        }
        return;
    } => "sorry, I only know how to multiply up to 10";

Use a catch-all variable to deal with unrecognized patterns:

    pattern ':something_else' => "sorry, I don't understand that";


=head2 transform

Use <transform> for simple normalization:

    transform "isn't"  => "is not";
    transform "aren't" => "are not";
    transform "what's" => "what is";


=head2 context

Use C<context> to isolate patterns that could have different meanings
according to the context where they appear. Examples:

    {
        context 'do you like x?';

        pattern 'yes' => 'I like it too';
        pattern 'no'  => 'why not?';
    }

    {
        context 'have you ever x?';

        pattern 'yes' => 'tell me more about that!';
        pattern 'no'  => 'would you like to?';
    }


Use the C<"global"> context to register patterns and transformations
that should be applied in all contexts:

    {
        context "global";

        pattern 'tell me a joke' => 'knock, knock';
    }


=head2 process

C<process(str)> will apply all the possible transformations and patterns,
and return a valid response according to the context:

    while (<>) {
        my $chatbot_response = process($_);
        print "$chatbot_response\n";
    }

(See more examples in the C<examples/> and C<t/> directories)


=head1 LICENSE AND COPYRIGHT

Copyright (C) 2013 Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
