
This talk is not about data. I don't know your data, so I don't know how
to help you with your data. My current data is CPAN Testers reports:
When people run the built-in tests for a CPAN module, they have the
option of sending that test report to CPAN Testers. CPAN Testers
processes that data into useful reports for CPAN authors with some very
simple transformations from large data structure to relational tables.
In the past, I've dealt with financial time series data. Foreign
exchange data, government bond data, and interest rate data combined and
transformed and correlated and adjusted into dozens of configurations
stored in multiple databases for hundreds of downstream systems to
consume. These two kinds of data could not be more different, but they
have some similar computing problems that can be satisfied with the same
code.

So this talk is not about data. It's about workflows. It's about
configuration. It's about execution. It's about everything but the data
itself.

So since this isn't about data, let's start with some code for
processing data. What this does isn't important, but you're curious, so
I'll say that it calculates the movement of a time series. So, for each
day, how much did the value change?

    # Extract
    my $id = shift @ARGV;
    my @raw_ts = $dbh->selectall_array(
        'SELECT * FROM bonds WHERE cusip=?', [ $id ]
    );

    # Transform
    my @move_ts;
    my $prev_point = shift @ts;
    for my $point ( @ts ) {
        push @move_ts, {
            stamp => $point->{stamp},
            value => $point->{value} - $prev_point->{value},
        };
        $prev_point = $point;
    }

    # Load
    for my $point ( @move_ts ) {
        $dbh->do(
            'REPLACE INTO bonds_move ( stamp, value ) VALUES ( ?, ? )',
            [ $point->{qw( stamp value )} ],
        );
    }

This is a perfectly useful bit of code. We give it an identifier as an
argument on the command-line, and this script extracts the bond data,
transforms it into the daily movement, and loads it into another table.

But we can't yet call it a program:

* We've got a database connection we need to configure, so we need
  a configuration file
* We need to write some tests to verify it works, so we need to make it
  testable
* We need to be able to deploy it to our production servers

So, we need to do everything but the data.

In Perl, the best way to make something testable, configurable, and
deployable is to put it in a module. In programming, the best way to
make something reusable is to make it into an object. So we'll do both
of those things: We'll put our code in a module named "My::DailyChange",
turn it into an object class with the "Moo" library, create a "dbh"
attribute to hold our database handle, and put all of our code in
a "run" method.

    package My::DailyChange;
    use v5.26;
    use Moo;
    has dbh => ( is => 'ro', required => 1 );
    sub run ( $self, $id ) {
        # Extract
        my @raw_ts = $self->dbh->selectall_array(
            'SELECT * FROM bonds WHERE cusip=?', [ $id ]
        );

        # Transform
        my @move_ts;
        my $prev_point = shift @ts;
        for my $point ( @ts ) {
        push @move_ts, {
                stamp => $point->{stamp},
                value => $point->{value} - $prev_point->{value},
            };
            $prev_point = $point;
        }

        # Load
        for my $point ( @move_ts ) {
            $self->dbh->do(
                'REPLACE INTO bonds_move ( stamp, value ) VALUES ( ?, ? )',
                [ $point->{qw( stamp value )} ],
            );
        }
    }

So, this is easily-testable: Load My::DailyChange, give it a database
handle, call the "run" method, and see what happens. It's also
easily-deployable with any kind of CPAN toolchain (I prefer
Dist::Zilla).

We do need a way to run it, though, and a way to tell it what database
connection information to use. Rather than writing our own code for
this, which would be pretty easy:

    use My::DailyChange;
    my $script = My::DailyChange->new(
        dbh => DBI->connect( 'dbi:SQLite:data.db' ),
    );
    $script->run( @ARGV );

Instead let's use code someone (me) already wrote: Beam::Runner.

Beam::Runner takes a module exactly like we've written and runs it.
That's not the valuable part. The valuable parts are that it also can:

* Easily configure any number of instances of our module
* List all of the runnable modules we've configured
* Show documentation for the module
* Run the module on a distributed job queue

To get started using Beam::Runner, we need to mark our module as
runnable:

    package My::DailyChange;
    use v5.26;
    use Moo;
    with 'Beam::Runnable';

Done. When we add the Beam::Runnable role to our class, we've created
a Beam::Runner "task".

Next, we need to write a configuration file for our module. We need to
give our task a name (how about daily_change?), then we tell it to use
our My::DailyChange module. Finally, we create a DBI object for it. Once
again we give a class (DBI), and now we give a method to call (connect),
and arguments to give (the DSN).

    # etc/bond.yml
    daily_change:
        $class: My::DailyChange
        dbh:
            $class: DBI
            $method: connect
            $args:
                - 'dbi:SQLite:data.db'

This is all processed by Beam::Wire

Once we have our configuration file, we need to tell Beam::Runner where
to find it by setting the `BEAM_PATH` environment variable:

    $ export BEAM_PATH=etc

Now we can run our task by giving the name of the config file and the
name of the task:

    $ beam run bond daily_change <bond_id>

Any additional arguments are given to the `run()` method.

So that's the basics of Beam::Runner. It's okay to be underwhelmed, so
far I've saved you from writing 10 lines of code. There are some little
things like the list of tasks we could run:

    $ beam list
    bond
    - daily_change -- My::DailyChange

But though that's useful, and your operations team will love you for it,
it's not very exciting. But this abstraction allows us to do a lot of
other things:

For one, we can make sure that only one instance of our task is being
run at a time by adding the Beam::Runnable::Single role. We don't even
have to change our code to add the role, we can do that in the
configuration file:

    # etc/bond.yml
    daily_change:
        $class: My::DailyChange
        dbh:
            $class: DBI
            $method: connect
            $args:
                - 'dbi:SQLite:data.db'
        $with:
            - Beam::Runnable::Single
        pid_file: /var/run/bond-daily_change.pid

We compose the role with `$with`, and give it a PID file path to use
using the `pid_file` attribute. Now, only one instance of our task can
be run at a time. If another one tries to be run, it will exit with an
error message. There's a couple other small, useful things like this
included in Beam::Runner:

* The Beam::Runnable::Timeout::Alarm role uses the `alarm` Perl function
  to set a timeout for your script to limit execution. After the timeout
  is reached, the script will exit with an error code.
* The Beam::Runnable::AllowUsers role will restrict who can run the task
  to the given list of users.

Other roles like this could be created:

* Memory limits could be enforced with a role
* The task could be run as a different user with a role
* With a role, the task could be re-tried if it fails
* Simple parallelization could be done with fork over the arguments to
  run() (much like GNU Parallel)

None of these roles not require any knowledge of what the task is doing,
but they simplify the job of processing data.

Another thing this abstraction allows us to do is distribute our jobs to
other machines. I've written Beam::Minion to distribute Beam::Runner
jobs using the Minion task runner. For this to work, we don't need to
change any code or configuration, we just need to install Beam::Minion,
configure a database connection for it, and start a worker:

    $ cpanm Beam::Minion Minion::Backend::SQLite
    $ export BEAM_MINION="sqlite:///tmp/minion.db" # For true distributing to other machines, try Postgres or MySQL
    $ beam minion worker

And then in another terminal we can start our job:

    $ export BEAM_MINION="sqlite:///tmp/minion.db"
    $ beam minion run bond daily_change

And our task will be run on our worker.

With this simple abstraction, we've:

* Created a runnable module
* Configured an instance of our module and given it a database to use
* Easily enabled testing of our module
* Prevented our task from running more than once at a time
* Run our task on a distributed processing system

Those are the benefits that Beam::Runner can provide externally, but
there are other benefits that Beam::Wire can provide internally. If we
go back to our script, it was divided into three parts: Extract,
Transform, Load

Let's break those each into its own module. This is a common enough
pattern that it has a name: Extract, Transform, Load, or ETL.

The extractor reads from somewhere and provides us with data in a common
format (for us, an array of hashrefs with "stamp" and "value" fields,
which we'll just call a time series).

For our extractor, we'll need a database handle, but we'll also take
a table name as an attribute. This way we can extract data from whatever
database table we want.

The transformer takes a time series and returns a time series after
having done something, just as before. Nothing really changes here.

The loader takes the common data format and writes it to somewhere. Just
like our extractor, we need a database handle, and a table name to write
to.

Finally, we need a module that will bring them all together: Extract
data from the extractor, transform it with all the transformers, and
load it into the loader.

Now that we have these things, we can configure our bond loader, but we
can also configure one for foreign exchange and interest rates without
writing any new code, just new configuration.

I can now manage dozens of these processes, and if I need to add more
steps, I can write a new transformer. For example, here's one that
forward fills the data, which is hugely important in financial data with
all the different kinds of holiday calendars and sometimes just plain
old missing data: When a point is missing for a day, it takes the point
for the previous day (filling it forward).

Now I can easily add forward filling to my FX process by changing its
configuration.

So, with Beam::Wire configuring our objects, and Beam::Runner to run
them, we can a build huge but maintainable data platform that can handle
any kind of data we might encounter.

