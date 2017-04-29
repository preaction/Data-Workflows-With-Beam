package ETL::Earl::Format;
use v5.24;
use Moo;
use experimental 'signatures';
use Module::Runtime qw( use_module );

our %formatters = (
    csv => 'ETL::Earl::Format::CSV',
);

sub formatter( $class, $name ) {
    return use_module( $formatters{ lc $name } )->new;
}

1;
