package Reflexive::Stream::Filtering;
BEGIN {
  $Reflexive::Stream::Filtering::VERSION = '1.103450';
}

#ABSTRACT: Provides a Reflex Stream object that can use POE::Filters
use Moose;
extends 'Reflex::Stream';
with 'Reflexive::Role::StreamFiltering';




1;



=pod

=head1 NAME

Reflexive::Stream::Filtering - Provides a Reflex Stream object that can use POE::Filters

=head1 VERSION

version 1.103450

=head1 DESCRIPTION

Reflexive::Stream::Filtering provides a Reflex::Stream subclass that takes and
uses a POE::Filter instance to filter inbound and outbound data similar to a
POE::Wheel object. But this class is much much simpler. The goal is to merely
shim in a POE::Filter instance and to do it as unobtrusively as possible.

The main implemetation of this functionality is actually within
L<Reflexive::Role::StreamFiltering>. Its documentation is included here for
convenience.

=head1 PUBLIC_ATTRIBUTES

=head2 filter

    is: bare, isa: POE::Filter, default: POE::Filter::Stream

This attribute is mostly to be provided at construction of the Stream. If none
is provided then POE::Filter::Stream (which is just a passthrough) is used.

Internally, the following handles are provided:

    {
        'filter_get' => 'get_one',
        'filter_start' => 'get_one_start',
        'filter_put' => 'put',
    }

Incidentially, only the newer POE::Filter get_one_start/get_one interace is
supported.

=head1 PUBLIC_METHODS

=head2 put

    (Any)

This method is around advised to run the provided data through the fliter before
passing it along to the original method if the filter returns multiple filtered
chunks then each chunk will get its own method call.

=head1 PROTECTED_METHODS

=head2 on_data

    (Dict[data => Any])

on_data is overridden from the underlying base class (which gained the method
from the parameterized role that was consumed). Data is then passed on to the
filter via get_one_start. Then get_one is called until no more filtered chunks
are returned. Each filtered chunk is then delievered via the emitted data event

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Nicholas R. Perez <nperez@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
