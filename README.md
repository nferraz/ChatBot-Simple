NAME
====

ChatBot::Simple - a new and flexible chatbot engine in Perl.

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

Simple pattern/responses
------------------------

	pattern 'hello' => 'hi!';

Multiple (random) responses
---------------------------

	pattern 'hello' => [ 'hi!', 'hello!', 'wazzzzup!' ];

Named parameters
----------------

	pattern "my name is :name" => "hello, :name!";

Code execution
--------------

	my %mem;

	pattern "my name is :name" => sub {
		my ($str,$param) = @_;

		$mem{name} = $param->':name';

		return;
	} => "nice to meet you, :name!";

Multiple named parameters
-------------------------

	my %var;

	pattern "define :variable as :value" => sub {
		my ($str,$param) = @_;

		my $variable = $param->{':variable'};
		my $value    = $param->{':value'};

		$var{$variable} = $value;

		return;
	} => 'ok';

Regular expressions
-------------------

	pattern qr{what is (\d+) ([+-/*]) (\d+)} => sub {
		my ($str,$param) = @_;

		my ($n1,$op,$n2) = ($param->{1}, $param->{2}, $param->{3});
		# ...

		return $result;
	};

Transformations
---------------

Transformations can be used to normalize input, and are performed
before the pattern matching:

	transform "I'm"    => "I am"
	transform "you're" => "you are";
	transform "what's" => "what is";

They can use parameters as well:

	transform "I am called :name" => "my name is :name";

(See more examples in the "t/" directory.)

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

https://github.com/nferraz/st


LICENSE AND COPYRIGHT
=====================

Copyright (C) 2013 Nelson Ferraz

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

