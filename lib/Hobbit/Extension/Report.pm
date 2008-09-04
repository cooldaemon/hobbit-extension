package Hobbit::Extension::Report;

use warnings;
use strict;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors(qw(ip name color message));

=head1 NAME

Hobbit::Extension::Report - Hobbit Monitor Report class.

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

=head2 new

=cut

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->green();
  $self->message('');
  return $self;
}

=head2 message

=cut

=head2 green yellow red purple

=cut

BEGIN {
  for my $color (qw(green yellow red purple)) {
    no strict 'refs';
    *{'Hobbit::Extension::Report::' . $color} = sub {shift->color($color)};
  }
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

1; # End of Hobbit::Extension::Report
