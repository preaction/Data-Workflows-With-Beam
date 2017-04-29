package ETL::Earl::Transform::FillBackward;
use v5.24;
use Moo;
use experimental 'signatures', 'refaliasing';
use DateTime;

sub transform( $self, @tsz ) {
    for \my @ts ( @tsz ) {
        my $next_date = _parse_dt( $ts[$#ts]{date} );
        for ( my $i = $#ts-1; $i >= 0; $i-- ) {
            my $cur_date = _parse_dt( $ts[$i]{date} );
            my $days = $cur_date->delta_days( $next_date )->delta_days;
            #; say "$next_date - $cur_date = $days days";
            for ( my $d = 1; $d < $days; $d++ ) {
                #; say "Adding $d to $next_date";
                splice @ts, $i+1, 0, {
                    name => $ts[$i+1]{name},
                    date => $next_date->add( days => -1 )->strftime( '%Y-%m-%d' ),
                    value => $ts[$i+1]{value},
                };
            }
            $next_date = $cur_date;
        }
    }
    return @tsz;
}

sub _parse_dt( $date ) {
    my ( $y, $m, $d ) = split /-/, $date;
    return DateTime->new( year => $y, month => $m, day => $d );
}

1;
