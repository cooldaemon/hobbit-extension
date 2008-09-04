use Test::More tests => 2;

use Hobbit::Extension;

my $RESULT_FILE = 't/bin/bbout';

_clear_result();
_run();
my $results = _get_result();

if ($results->[0] eq '127.0.0.1') {
    pass('disp ip');
} else {
    fail('disp ip');
}

if ($results->[1] =~ /^status\slocalhost\.mytest\sred\s\w{3}\s\w{3}\s\d{1,2}\s\d{2}:\d{2}:\d{2}\s\w{3}\s\d{4}\s10$/) {
    pass('status name.column color date message');
} else {
    fail('status name.column color date message');
}

sub _clear_result {
    unlink $RESULT_FILE;
}

sub _get_result {
    my @results;

    open my $result_fh, '<', $RESULT_FILE;
    while (<$result_fh>) {
        chomp;
        push @results, $_;
    }
    close $result_fh;

    return \@results;
}

sub _run {
    Hobbit::Extension->run(
        server       => 1,
        column       => 'mytest',
        plugin       => 'TCPConnectTime',
        port         => 65535,
        timeout      => 10,
        color        => {yellow => 2, red => 5},
        bb_command   => 't/bin/bb',
        disp_ip      => '127.0.0.1',
        grep_command => 't/bin/bbhostgrep',
    );
}

