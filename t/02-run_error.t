use Test::More tests => 6;
use Test::Exception;

use Hobbit::Extension;

#eval 'use Test::Exception';
#if ($@) {
#    plan skip_all => 'Test::Exception required for testing exception based code';
#} else {
#    plan tests => 7;
#}

my @params = (
    column   => 'mytest',
    callback => sub {},
);

my @envs = (
    bb_command   => 't/bin/bb',
    grep_command => 't/bin/bbhostgrep',
    disp_ip      => '127.0.0.1',
    target_name  => 'localhost',
);

for (qw(column callback)) {
    dies_ok {Hobbit::Extension->run(
        _filter_params(\@params, $_),
        @envs,
    );} 'Unsets ' . $_ . '.';
}

for (qw(bb_command disp_ip target_name)) {
    dies_ok {Hobbit::Extension->run(
        @params,
        _filter_params(\@envs, $_),
    );} 'Unsets ' . $_ . '.';
}

lives_ok {Hobbit::Extension->run(
    @params, @envs
);} 'Sets all variables.';

sub _filter_params {
    my ($params, $target) = @_;

    my %value_of = @$params;
    delete $value_of{$target};
    my @results;
    while (my ($key, $value) = each %value_of) {
        push @results, $key, $value;
    }
    return @results;
}
