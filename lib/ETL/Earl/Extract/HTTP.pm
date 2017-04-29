package ETL::Earl::Extract::HTTP;
use v5.24;
use Moo;
use experimental 'signatures';
use HTTP::Tiny;
use Types::Standard qw( Str );
use ETL::Earl::Format;

has url => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has format => (
    is => 'ro',
    isa => Str,
);

sub read( $self, @args ) {
    my $res = HTTP::Tiny->new->get( $self->url );
    my $fmt = ETL::Earl::Format->formatter( $self->format );
    return $fmt->parse( $res->{content} );
}

1;
