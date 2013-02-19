use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'ChatBot::Simple',
    AUTHOR              => q{Nelson Ferraz <nferraz@gmail.com>},
    VERSION_FROM        => 'lib/ChatBot/Simple.pm',
    ABSTRACT_FROM       => 'lib/ChatBot/Simple.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ChatBot-Simple-*' },
);
