package ETL::Earl::Extract::Govt::FedH15;
use v5.24;
use Moo;
use experimental 'signatures';
extends 'ETL::Earl::Extract::HTTP';

has '+format' => (
    default => 'csv',
);

has '+url' => (
    default => 'https://www.federalreserve.gov/datadownload/Output.aspx?rel=H15&series=bf17364827e38702b42a58cf8eaa3f78&lastobs=&from=&to=&filetype=csv&label=include&layout=seriescolumn&type=package',
);

around read => sub {
    my ( $orig, $self, @args ) = @_;
    my @raw_data = $self->$orig( @args );

    # Clean up data into dates and bond descriptions
    # my @new_data;
    # for my $raw_row ( @raw_data ) {
    #     my %new_row = (
    #         date => $raw_row->{'Series Description'} . '-01',
    #     );
    #     for my $pair ( keys %rates ) {
    #         $new_row{ $pair } = $raw_row->{ $key };
    #     }
    #     push @new_data, \%new_row;
    # }

    return @raw_data[0..5];
};

1;
