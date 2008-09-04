use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Hobbit::Extension',
    AUTHOR              => 'Masahito Ikuta <cooldaemon@gmail.com>',
    VERSION_FROM        => 'lib/Hobbit/Extension.pm',
    ABSTRACT_FROM       => 'lib/Hobbit/Extension.pm',
#   LICENSE             => 'perl',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'            => 0,
        'Test::Exception'       => 0,
        'UNIVERSAL::require'    => 0,
        'Class::Accessor::Fast' => 0,
        'Time::HiRes'           => 0,
        'IO::Socket'            => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Hobbit-Extension-*' },
);

