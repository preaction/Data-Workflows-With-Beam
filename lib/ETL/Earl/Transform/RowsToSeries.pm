package ETL::Earl::Transform::RowsToSeries;
use v5.24;
use Moo;
use experimental 'signatures', 'refaliasing';

sub transform( $self, @rows ) {
    my %tsz;
    for \my %row ( @rows ) {
        my $date = $row{date};
        for my $col ( keys %row ) {
            push $tsz{ $col }->@*, {
                date => $date,
                name => $col,
                value => $row{ $col },
            };
        }
    }
    return values %tsz;
}

1;
