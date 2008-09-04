package Hobbit::Extension::Plugin::TCPConnectTime;

use warnings;
use strict;

use Time::HiRes qw(time);
use IO::Socket;

=head1 NAME

Hobbit::Extension::Plugin::TCPConnectTime - This module report necessary time by the TCP connection.

=head1 VERSION

version 0.001

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

See also Hobbit::Extension module.

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 validate

=cut

sub validate {
    my ($arg_of) = @_;

    return if !defined $arg_of->{port} || $arg_of->{port} !~ /^\d{1,5}$/;
    return if $arg_of->{port} < 1 || 65535 < $arg_of->{port};
    return if defined $arg_of->{timeout} && $arg_of->{timeout} !~ /^\d+$/;
    return if !defined $arg_of->{color} && ref $arg_of->{color} ne 'HASH';

    for (qw(yellow red)) {
        return if    !defined $arg_of->{color}->{$_}
                  || $arg_of->{color}->{$_} !~ /^\d+$/;
    }
    return if $arg_of->{color}->{red} <= $arg_of->{color}->{yellow};

    return 1;
}

=head2 run

=cut

sub run {
    my ($arg_of, $report) = @_;

    my $start_time = time;

    my $socket = IO::Socket::INET->new(
        PeerAddr => $report->ip,
        PeerPort => $arg_of->{port},
        Timeout  => $arg_of->{timeout} || 5,
    );

    if (!$socket) {
        $report->red();
        $report->message($arg_of->{timeout});
        return;
    } 

    my $end_time = time;

    $socket->close();

    my $connect_time = int(($end_time - $start_time) * 1000);

      $arg_of->{color}->{red} * 1000    < $connect_time ? $report->red()
    : $arg_of->{color}->{yellow} * 1000 < $connect_time ? $report->yellow()
    : $report->green()
    ;

    $report->message($connect_time);
}

=head1 AUTHOR

Masahito Ikuta, C<< <cooldaemon@gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-hobbit-extension@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Masahito Ikuta, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Hobbit::Extension::Plugin::TCPConnectTime
