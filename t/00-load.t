use Test::More tests => 3;

BEGIN {
  use_ok('Hobbit::Extension');
}

diag("Testing Hobbit::Extension $Hobbit::Extension::VERSION");

my $h = Hobbit::Extension->_new;
isa_ok($h, 'Hobbit::Extension');

my $r = Hobbit::Extension::Report->new;
isa_ok($r, 'Hobbit::Extension::Report');

