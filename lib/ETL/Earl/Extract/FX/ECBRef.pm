package ETL::Earl::Extract::FX::ECBRef;
use v5.24;
use Moo;
use experimental 'signatures';
use Types::Standard qw( Str );
use Mojo::UserAgent;
use Mojo::DOM;

has 'url' => (
    is => 'ro',
    isa => Str,
    default => 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml',
);

sub read( $self, @args ) {
    my $tx = Mojo::UserAgent->new->get( $self->url );
    return $tx->res->dom->find( 'Cube[time]' )
        ->map( sub( $cube ) {
            return {
                date => $cube->attr( 'time' ),
                $cube->children->map( sub( $item ) {
                    my $ccy = $item->attr( 'currency' );
                    my $pair = $ccy eq 'GBP' ? 'EURGBP' : $ccy . 'EUR';
                    return ( $pair => $item->attr( 'rate' ) );
                } )->each,
            };
        } )
        ->sort( sub { $a->{date} cmp $b->{date} } )
        ->each;
}

1;
