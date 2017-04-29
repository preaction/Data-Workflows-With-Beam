package ETL::Earl::Extract::DBI;
use v5.24;
use Moo;
use experimental 'signatures';

has dbh => (
    is => 'ro',
);

has table => (
    is => 'ro',
);

sub read( $self ) {
    return $self->dbh->selectall_array(
        'SELECT * FROM ' . $self->table,
        { Slice => {} },
    );
}

1;
