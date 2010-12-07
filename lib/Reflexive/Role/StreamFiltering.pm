package Reflexive::Role::StreamFiltering;
BEGIN {
  $Reflexive::Role::StreamFiltering::VERSION = '1.103410';
}

#ABSTRACT: Provides a composable behavior for Reflex::Streams to use POE::Filters
use Moose::Role;

requires qw/ on_data put emit /;

use POE::Filter::Stream;
use MooseX::Params::Validate;
use MooseX::Types::Moose(':all');
use MooseX::Types::Structured(':all');


has filter =>
(
    is => 'bare',
    isa => 'POE::Filter',
    default => sub { POE::Filter::Stream->new() },
    handles =>
    {
        'filter_get' => 'get_one',
        'filter_start' => 'get_one_start',
        'filter_put' => 'put',
    }
);



around on_data => sub
{
    my ($orig, $self, $args) = pos_validated_list
    (
        \@_,
        { isa => CodeRef },
        { isa => __PACKAGE__ },
        { isa => Dict[data => Any] },
    );

    $self->filter_start([$args->{data}]);
    while(1)
    {
        my $ret = $self->filter_get();
        if($#$ret == -1)
        {
            last;
        }
        else
        {
            for(0..$#$ret)
            {
                $self->emit
                (
                    event => 'data',
                    args => { data => $ret->[$_] }
                );
            }
        }
    }
};


around put => sub
{
    my ($orig, $self, $arg) = pos_validated_list
    (
        \@_,
        { isa => CodeRef },
        { isa => __PACKAGE__ },
        { isa => Any }
    );
    my $ret = $self->filter_put([$arg]);

    $self->$orig($_) for @$ret;
};

1;



=pod

=head1 NAME

Reflexive::Role::StreamFiltering - Provides a composable behavior for Reflex::Streams to use POE::Filters

=head1 VERSION

version 1.103410

=head1 DESCRIPTION

Reflexive::Role::StreamFiltering provides a composable behavior that takes and
uses a POE::Filter instance to filter inbound and outbound data similar to a
POE::Wheel object. But this class is much much simpler. The goal is to merely
shim in a POE::Filter instance and to do it as unobtrusively as possible. The
same filter is used for both inbound and outbound filtering.

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

on_data is the advised to intercept data events. Data is passed through the
ilter via get_one_start. Then get_one is called until no more filtered chunks
are returned. Each filtered chunk is then delievered via the emitted data event
which is reemitted.

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Nicholas R. Perez <nperez@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
