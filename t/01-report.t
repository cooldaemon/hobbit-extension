use Test::More tests => 12;

use Hobbit::Extension::Report;

my $report = Hobbit::Extension::Report->new();

for (qw(ip name color message green yellow red purple)) {
    can_ok($report, $_,);
}

$report->green();
is($report->color(), 'green', 'Hobbit::Extension::Report::green',);

$report->yellow();
is($report->color(), 'yellow', 'Hobbit::Extension::Report::yellow',);

$report->red();
is($report->color(), 'red', 'Hobbit::Extension::Report::red',);

$report->purple();
is($report->color(), 'purple', 'Hobbit::Extension::Report::purple',);
