package Hobbit::Extension;

use warnings;
use strict;

use UNIVERSAL::require;
use Hobbit::Extension::Report;

=head1 NAME

Hobbit::Extension - This module is a tool to make Extension of Hobbit Monitor easily.

=head1 VERSION

version 0.001

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

    use Hobbit::Extension;

    Hobbit::Extension->run(
        server   => 1,          # Default mode is client side extension.
        column   => 'mytest',
        callback => sub {
            my ($report) = @_;
            if (OK_CONDITION) {
                # Default color is green.
                $report->message('OK');
            } else {
                $report->red(); # or yellow or purple.
                $report->message('NG');
            }
        },
    );

    Hobbit::Extension->run(
        plugin  => 'TCPConnectTime'
        column  => 'mytest',
        port    => '80',
        timeout => '10',
        color   => {yellow => '0.3', red => '0.5'},
    );

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 run

=cut

sub run {
    my $class = shift;
    my $self = $class->_new(@_);

    $self->_load_plugin() or die 'Plugin not found.';
    $self->_valid_args() or die 'Some parametaers is wrong.';
    $self->_valid_env() or die 'Some environments isn\'t defined.';

    my $report = Hobbit::Extension::Report->new({
        ip   => '127.0.0.1',
        name => $self->{target_name},
    });
    
    ($self->{server} ? \&_server_side_processes : \&_processes)
        ->($self, $report,);
}

sub _new {
    my $class = shift;
    my %arg_of = (
        bb_command   => $ENV{BB},
        grep_command =>
            ($ENV{BBHOST} ? $ENV{BBHOME} . '/bin/bbhostgrep' : ''),
        disp_ip      => $ENV{DISP},
        target_name  => $ENV{MACHINE},
        @_,
    );
    return bless \%arg_of, $class;
}

sub _load_plugin {
    my ($self) = @_;

    return 1 if !$self->{plugin};
    $self->{plugin} = {
        name => __PACKAGE__ . '::Plugin::' . $self->{plugin},
    };
    $self->{plugin}->{name}->use() or return;

    for (qw(validate run)) {
        $self->{plugin}->{$_} = $self->{plugin}->{name}->can($_) or return;
    }

    return 1;
}

sub _args {
    my ($self) = @_;

    my %arg_of;
    while (my ($key, $value,) = each %$self) {
        next if $key =~ /^(?:
            bb_command|grep_command|disp_ip|target_name|column
        )$/x;
        $arg_of{$key} = $value;
    }
    return \%arg_of;
}

sub _valid_args {
    my ($self) = @_;

    return if !defined $self->{column};
    return if length($self->{column}) < 1;

    return $self->{plugin}->{validate}->($self->_args) if $self->{plugin};

    return if !defined $self->{callback};
    return if ref($self->{callback}) ne 'CODE';
   
    return 1;
}

sub _valid_env {
    my ($self) = @_;

    return 1 if $self->{debug};

    my @names = qw(bb_command disp_ip);
    if ($self->{server}) {
        push @names, 'grep_command';
    } else {
        push @names, 'target_name';
    }

    for (@names) {
        return if !$self->{$_};
        next if !/_command$/;
        return if !-x $self->{$_};
    }

    return 1;
}

sub _server_side_processes {
    my ($self, $report) = @_;

    for (@{$self->_get_target_list}) {
        $report->ip($_->{ip});
        $report->name($_->{name});
        $self->_processes($report);
    }
}

sub _get_target_list {
    my ($self) = @_;

    if (!-x $self->{grep_command}) {
        warn 'Please check bbhostgrep command.';
        return [{ip => '127.0.0.1', name => 'localhost'}];
    }

    my $command = $self->{grep_command} . ' ' . $self->{column};

    my @targets;
    for(`$command`) {
        my ($ip, $name,) = split /\s/;
        push @targets, {ip => $ip, name => $name,};
    }
    return \@targets;
}

sub _processes {
    my ($self, $report) = @_;

    if ($self->{plugin}) {
        $self->{plugin}->{run}->($self->_args, $report);
    } else {
        $self->{callback}->($report);
    }

    $self->_send_report($report);
}

sub _send_report {
    my ($self, $report) = @_;

    my $command = sprintf(
        qq{%s %s "status %s.%s %s %s\n\n%s\n"},
        $self->{bb_command},
        $self->{disp_ip},
        $report->name,
        $self->{column},
        $report->color,
        `date`,
        $report->message,
    );

    if ($self->{debug}) {
        print $command;
        return;
    }

    `$command`;
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

1; # End of Hobbit::Extension
