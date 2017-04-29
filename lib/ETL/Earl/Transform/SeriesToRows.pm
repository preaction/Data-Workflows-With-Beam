package ETL::Earl::Transform::SeriesToRows;
use v5.24;
use Moo;
use experimental 'signatures', 'refaliasing';

sub transform( $self, @tsz ) {
    my %rows;
    for \my @ts ( @tsz ) {
        for my $item ( @ts ) {
            my $date = $item->{date};
            unless ( $rows{ $date } ) {
                $rows{ $date } = { date => $date };
            }
            $rows{ $date }{ $item->{name} } = $item->{value};
        }
    }
    return values %rows;
}

1;
