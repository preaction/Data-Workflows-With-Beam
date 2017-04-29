package ETL::Earl::Extract::FX::FedG5;
use v5.24;
use Moo;
use experimental 'signatures';
extends 'ETL::Earl::Extract::HTTP';

has '+format' => (
    default => 'csv',
);

has '+url' => (
    default => 'https://www.federalreserve.gov/datadownload/Output.aspx?rel=H10&series=c5d6e0edf324b2fb28d73bcacafaaa02&lastobs=120&from=&to=&filetype=csv&label=include&layout=seriescolumn&type=package',
);

around read => sub {
    my ( $orig, $self, @args ) = @_;
    my @raw_data = $self->$orig( @args );

    # Build map of column => ccy pair from header lines
    my %map;
    for my $key ( keys $raw_data[0]->%* ) {
        next if $key eq 'Series Description';
        my ( $base ) = $raw_data[0]{$key} =~ /_Per_(\w+)$/;
        my $ccy = $raw_data[2]{$key};
        $map{ $key } = "$ccy$base";
    }

    # Clean up data into dates and currency pairs
    my @new_data;
    for my $raw_row ( @raw_data[5..$#raw_data] ) {
        my %new_row = (
            date => $raw_row->{'Series Description'} . '-01',
            map { $map{ $_ } => $raw_row->{ $_ } } keys %map,
        );
        push @new_data, \%new_row;
    }

    return @new_data;
};

1;
