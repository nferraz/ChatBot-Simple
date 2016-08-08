NAME
====

ChatBot::Simple - new and flexible chatbot engine in Perl


DESCRIPTION
===========

ChatBot::Simple is a flexible chatbot engine written in Perl.

Instead of specifying the chatbot knowledge base in xml, we are
going to use the powerful text manipulation capabilities of Perl.

The rationale behind this decision is that "simple" AI languages,
like AIML, are only simple if you want to do simple things. Once
you start adding features, they quickly become unmanageable.

ChatBot::Simple's design goal is to make easy things easy, and
difficult things possible.


FEATURES
========

pattern
-------

Use "pattern" to declare input patterns and responses:

    pattern 'hello' => 'hi!';


### Multiple patterns

    pattern ['hello', 'hi'] => 'hi!';


### Multiple (random) responses

    pattern ['hello', 'hi'] => ['hello', 'hi', 'how are you doing?'];


### Named variables

    pattern 'my name is :name' => 'hello, :name!';


### Regular expressions with captured variables

    pattern qr{good (morning|afternoon|night)} => 'good :1, :name!';


### Perl code

    pattern 'what is :n1 times :n2' => sub {
        my ($input, $param) = @_;
        my ($n1, $n2) = ($param->{n1}, $param->{n2});
        if ($n1 <= 10 and $n2 <= 10) {
            my $answer = $param->{n1} + $param->{n2};
            return "the answer is $answer!";
        }
        return;
    } => "sorry, I only know how to multiply up to 10";

### Unrecognized patterns

When everything fails, you can use a catch-all variable to deal
with unrecognized patterns:

    pattern ':something_else' => "sorry, I don't understand that";


transform
---------

Use "transform" for simple normalization:

    transform "isn't"  => "is not";
    transform "aren't" => "are not";
    transform "what's" => "what is";


context
-------

Use "context" to isolate patterns that could have different meanings
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

Use the "global" context to register patterns and transformations that
should be applied in all contexts:

    {
        context "global";

        pattern 'tell me a joke' => 'knock, knock';
    }


process
-------

"process(str)" will apply all the possible transformations and
patterns, and return a valid response according to the context:

    while (<>) {
        chomp;
        my $chatbot_response = process($_);
        print "$chatbot_response\n";
    }

(See more examples in the "examples/" and "t/" directories)


INSTALLATION
============

To install this module, run the following commands:

	perl Makefile.PL
	make
	make test
	make install


SUPPORT AND DOCUMENTATION
=========================

After installing, you can find documentation for this module with the
perldoc command.

    perldoc ChatBot::Simple

Send comments, suggestions and bug reports to:

https://github.com/nferraz/ChatBot-Simple/issues

Or fork the code on github:

https://github.com/nferraz/ChatBot-Simple


LICENSE AND COPYRIGHT
=====================

Copyright (C) 2013, 2014, 2015, 2016 Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

