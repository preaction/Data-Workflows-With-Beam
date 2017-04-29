
use v5.24;
use Test::More;
use experimental 'refaliasing';

use ETL::Earl::Transform::FillForward;

my @in = (
    { date => '2017-01-01', name => 'Foo', value => 1.23 },
    { date => '2017-01-04', name => 'Foo', value => 1.34 },
);

my $xform = ETL::Earl::Transform::FillForward->new;
( my $out ) = $xform->transform( \@in );

is scalar @$out, 4, '4 items in output (2 items added)';
is $out->[1]{date}, '2017-01-02', '2017-01-02 date added';
is $out->[1]{value}, 1.23, '2017-01-02 value correct';
is $out->[2]{date}, '2017-01-03', '2017-01-03 date added';
is $out->[2]{value}, 1.23, '2017-01-03 value correct';

done_testing;
