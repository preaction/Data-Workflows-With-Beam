package ETL::Earl::Runner;

=head1 NAME

ETL::Earl::Runner - Run an ETL::Earl job

=head1 SYNOPSIS

    beam run <container> <service>

=cut

use v5.24;
use Moo;
use experimental 'signatures';
use Log::Any '$LOG';
use Scalar::Util qw( blessed );
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
    $LOG->info( 'Reading data from source ' . blessed $self->source );
    my @data = $self->source->read;
    for my $xform ( @{ $self->transforms } ) {
        $LOG->info( 'Transforming data with ' . blessed $xform );
        @data = $xform->transform( @data );
    }
    $LOG->info( 'Writing data to destination ' . blessed $self->destination );
    $self->destination->write( @data );
}

1;
