package ETL::Earl::Format::CSV;
use v5.24;
use Moo;
use experimental 'signatures';
use Text::CSV;

sub parse( $self, $text ) {
    open my $fh, '<', \$text;
    my $csv = Text::CSV->new;
    $csv->column_names( $csv->getline( $fh ) );
    return @{ $csv->getline_hr_all( $fh ) };
}

1;
