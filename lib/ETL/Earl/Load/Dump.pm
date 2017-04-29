package ETL::Earl::Load::Dump;
use v5.24;
use Moo;
use experimental 'signatures';
use Data::Dumper;

sub write ( $self, @data ) {
    say Dumper \@data;
}

1;

