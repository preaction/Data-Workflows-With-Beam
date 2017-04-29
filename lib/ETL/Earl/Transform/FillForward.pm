package ETL::Earl::Transform::FillForward;
use v5.24;
use Moo;
use experimental 'signatures', 'refaliasing';
use DateTime;

sub transform( $self, @tsz ) {
    for \my @ts ( @tsz ) {
        my $prev_date = _parse_dt( $ts[0]{date} );
        for ( my $i = 1; $i <= $#ts; $i++ ) {
            my $cur_date = _parse_dt( $ts[$i]{date} );
            my $days = $cur_date->delta_days( $prev_date )->delta_days;
            for ( my $d = 1; $d < $days; $d++ ) {
                splice @ts, $i, 0, {
                    name => $ts[$i-1]{name},
                    date => $prev_date->add( days => 1 )->strftime( '%Y-%m-%d' ),
                    value => $ts[$i-1]{value},
                };
                $i++;
            }
            $prev_date = $cur_date;
        }
    }
    return @tsz;
}

sub _parse_dt( $date ) {
    my ( $y, $m, $d ) = split /-/, $date;
    return DateTime->new( year => $y, month => $m, day => $d );
}

1;
