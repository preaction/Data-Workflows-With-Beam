package ETL::Earl::Runner;

=head1 NAME

ETL::Earl::Runner - Run an ETL::Earl job

=head1 SYNOPSIS

    beam run <container> <service>

=cut

use v5.24;
use Moo;
use experimental 'signatures';
with 'Beam::Runnable';

has source => (
    is => 'ro',
);

has destination => (
    is => 'ro',
);

has transforms => (
    is => 'ro',
    default => sub { [] },
);

sub run( $self, @args ) {
    my @data = $self->source->read;
    for my $xform ( @{ $self->transforms } ) {
        @data = $xform->transform( @data );
    }
    $self->destination->write( @data );
}

1;
