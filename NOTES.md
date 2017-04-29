
The larger an application gets, the more likely it is that it will
require some kind of external configuration file. As common tasks are
made into modules, there will come a need to create multiple tasks that
vary only in small ways easily accessible to non-programmers.

As an example, let's consider a massive market data platform. Incoming
foreign exchange rates, government bond prices, interest rates, and
other data are polled from market data providers, stored in a database,
and analyses performed. There are thousands of different data streams,
but most of them require the same few operations: Extract the live data,
transform into the format our database(s) expect, and load into the
database. This pattern is common enough that it's given a name: Extract,
Transform, Load (ETL).

A good ETL framework is organized into small, modular bits: Extractors
know how to read from a source into an internal format, Loaders know how
to write to a destination from that internal format, and Transformers
manipulate data in that internal format in a variety of ways. With this
well-defined API between modules, we can quickly and easily add new data
feeds or storage to our system, and create new transformations confident
that they will work with any data we throw at it.

But this talk isn't about writing an ETL framework. This talk is about
how you can use the Beam framework to avoid writing most of an ETL
framework, allowing you to focus on the important parts.

# Configuration with Beam::Wire

Beam::Wire is, in technical terms, an inversion of control container.
That's not important. What's important is that we can use YAML to
describe how to construct objects. So, if we have a module that allows
us to read from a SQL database using DBI called ETL::Earl::Extract::DBI,
we can configure a real DBI object like so:

    dbh:
        $class: DBI
        $method: connect
        $args:
            - 'dbi:mysql:fx_rates'
            - fxuser
            - fxpassword

First, the name of the object we're creating is `dbh`. This will be
important later when we need to refer to it. The `$class` sets the class
of the object. `$method` sets the constructor method (DBI uses
`connect`). `$args` sets the arguments. DBI takes an array of arguments
which the first is the data source name (DSN), the second is the user,
the third is the password.

Now that we have a DBI object, we can create our ETL::Earl::Extract::DBI
object and pass it in:

    extract:
        $class: ETL::Earl::Extract::DBI
        dbh:
            $ref: dbh
        table: rates_raw

First, I don't need to specify `$method` if the constructor is `new`,
which I'm using Moo so that's true. Second, I don't need to use `$args`
if it's a list of name/value pairs, which I'm using Moo so that's true.
Last, I pass in the constructed DBI object by using `$ref` and giving it
the name.

Now when I ask Beam::Wire to give me the `extract` object, it will
construct our DBI object, pass it in to the ETL::Earl::Extract::DBI
constructor, and give me the result. Translated, it would look like this
Perl:

    my $dbh = DBI->connect( 'dbi:mysql:fx_rates', 'fxuser', 'fxpassword' );
    my $extract = ETL::Earl::Extract::DBI->new( dbh => $dbh );

We can continue in this way to configure more extractors, transforms,
and loaders.

## Re-using configuration

So far, I haven't shown anything too onerous to write yourself in code,
but Beam::Wire has a few features that make it easy to manage large data
platforms.

### extends

We can share configuration between a lot of objects using `$extends`.
For example, we had a `table` in our ETL::Earl::Extract::DBI object, so
to make a bunch of them that all share the same database connection
info, we could do:

    database:
        $class: ETL::Earl::Extract::DBI
        dbh:
            $ref: dbh

    rates_db:
        $extends: database
        table: rates

    fx_db:
        $extends: database
        table: fx

    bonds_db:
        $extends: database
        table: bonds

By using `$extends`, the individual `*_db` objects get their `$class`
and `dbh` from the `database` configuration. Now if we need to change
where our database lives, we only have to change one object, the
`database` object.

### Inner containers

If we have a whole collection of objects that we want to share, we can
consume a whole container by configuring another Beam::Wire object as
a service.

    common:
        $class: Beam::Wire
        file: common.yml

The `file` points to a file relative to the current config file and
loads it as a Beam::Wire object. We can access the objects inside by
using `common/<object_name>`. So, if our `database` object was inside
`common.yml`, we could extend it by doing:

    rates_db:
        $extends: common/database
        table: rates

This lets us organize our configuration effectively to keep like objects
close together and shared objects all in one place.

# Execution with Beam::Runner

Now that we have our objects defining the various things we can do, we
need to assemble them into an actual "task". Beam provides a way for us
to do this with minimal code using Beam::Runner. Beam::Runner takes
a Beam::Wire configuration file and an object that implements a `run`
method, and then it runs it.

So, our basic runner class could be:

    package ETL::Earl::Run;
    use Moo;
    has source => ( is => 'ro' );
    has destination => ( is => 'ro' );
    has transforms => ( is => 'ro' );
    sub run {
        my ( $self, @args ) = @_;
        my @data = $self->source->read;
        for my $xform ( @{ $self->transforms } ) {
            @data = $xform->xform( @data );
        }
        $self->destination->write( @data );
    }

This is very similar to App::Cmd and MooseX::Runnable, so what does
Beam::Runner get us?

### Discoverable

Beam::Runner knows where all your runnable objects are: It can look
inside all of your containers and list your runnable objects. Using the
`beam list` command that comes with Beam::Runner, you get a list of all
the tasks you can run.

### Documented

Each task's documentation can be viewed with the `beam help` command.
This read's the module's documentation much like Pod::Usage does (the
`NAME`, `SYNOPSIS`, `DESCRIPTION`, and other POD sections) and displays
it for the end-user.

### Extensible

And finally, having a known calling convention (much like our
constructor did) allows us to build on top and create new ways to
execute our tasks, for example, Beam::Minion.

# Job Queueing with Beam::Minion

Eventually our jobs are going to require more hardware. There's only so
much software can do. Since we have a common calling convention
(Beam::Runner) and a common configuration (Beam::Wire), we can very
easily distribute our jobs using a job queue like Minion. I've taken the
liberty of writing Beam::Minion to do just this.

To get Beam::Minion working, we need to have Beam::Runner working. So,
we need a Beam::Wire configuration and a runnable object inside. Once
we've done that, we can spawn a Beam::Minion worker:

    beam minion worker <container>

This worker will run any job that's in the container file you give it.
That's it. Now we can run a job:

    beam minion run <container> <task> <args...>

