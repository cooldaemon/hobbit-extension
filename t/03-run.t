use Test::More tests => 4;

use Hobbit::Extension;

my $RESULT_FILE = 't/bin/bbout';

for my $run_args (
    [target_name => 'localhost',],
    [server => 1, grep_command => 't/bin/bbhostgrep',]
) {
    _clear_result();
    _run(@$run_args,);
    my $results = _get_result();

    if ($results->[0] eq '127.0.0.1') {
        pass('disp ip');
    } else {
        fail('disp ip');
    }

    if ($results->[1] =~ /^status\slocalhost\.mytest\sgreen\s\w{3}\s\w{3}\s\d{1,2}\s\d{2}:\d{2}:\d{2}\s\w{3}\s\d{4}\sOK$/) {
        pass('status name.column color date message');
    } else {
        fail('status name.column color date message');
    }
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
        column     => 'mytest',
        callback   => sub {shift->message('OK');},
        bb_command => 't/bin/bb',
        disp_ip    => '127.0.0.1',
        @_,
    );
}
