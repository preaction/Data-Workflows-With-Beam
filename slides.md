
# Data Workflows With Beam

<http://preaction.github.io/Data-Workflows-With-Beam/>

<div style="width: 40%; float: left">

by [Doug Bell](http://preaction.me)  
<small>(he, him, his)</small>  
[<i class="fa fa-twitter"></i> @preaction](http://twitter.com/preaction)  
[<i class="fa fa-github"></i> preaction](http://github.com/preaction)  
<img src="http://chicago.pm.org/theme/images/chicagopm-small.png" style="border: none; vertical-align: middle" />
[Chicago.PM](http://chicago.pm.org)  

</div>
<div style="width: 20%; float: left; text-align: center">
<img src="http://preaction.me/images/avatar-small.jpg" style="display: inline-block; max-width: 100%"/>
</div>
<div style="width: 40%; float: left">

[<i class="fa fa-file-text-o"></i> Notes](https://github.com/preaction/Data-Workflows-With-Beam/blob/master/NOTES.md)  
<small> </small>  
[Source on <i class="fa fa-github"></i>](https://github.com/preaction/Data-Workflows-With-Beam/)  

[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode)  

<small>
For speaker view, press `S`<br/>
For full-screen, press `F`
</small>
</div>

------

# <del>Data</del>

Note:
This talk is not about data. I don't know your data, so I don't know how
to help you with your data.

------

# CPAN Testers

Note:
My current data is CPAN Testers reports. When people run the built-in
tests for a CPAN module, they have the option of sending that test
report to CPAN Testers.

---

<div class="flex-row">
    <div>
        <pre>{
  "reporter": "Doug Bell",
  "language": {
    "name": "Perl 5",
    "version": "5.26.0",
    "archname": "x86_64-linux"
  },
  "distribution": {
    "name": "Beam-Runner",
    "version": "0.012"
  },
  "result": {
    "grade": "pass",
    "output": {
        "uncategorized": "..."
    }
  }
}</pre>
    </div>
    <div class="fragment fade-in">
        ➡️
    </div>
    <div class="fragment fade-in">
        <pre>+-------------+----------+--------+
| dist        | version  | grade  |
+-------------+----------+--------+
| Beam-Runner | 0.012    | pass   |
| Beam-Runner | 0.012    | pass   |
| Beam-Runner | 0.012    | fail   |
| Beam-Runner | 0.012    | na     |
| Beam-Runner | 0.012    | pass   |
| Beam-Runner | 0.011    | fail   |
| Beam-Runner | 0.011    | fail   |
+-------------+----------+--------+</pre>
    </div>
</div>

Note:
CPAN Testers processes that data from a large data structure into
relational database tables using some very simple transformations.

------

# Time Series

Note:
In the past, I've worked with financial time series data.

---

<table>
<thead>
    <tr><th>Date</th><th>Value</th></tr>
</thead>
<tbody>
    <tr><td>2017-05-05</td><td>2.34</td></tr>
    <tr><td>2017-05-06</td><td>2.56</td></tr>
    <tr><td>2017-05-07</td><td>2.91</td></tr>
    <tr><td>2017-05-08</td><td>2.78</td></tr>
    <tr><td>2017-05-09</td><td>2.98</td></tr>
</tbody>
</table>

Note:
Time series are date/value pairs, and we had thousands of series
each spanning decades.

---

# FX

Note:
Foreign exchange data...

---

# Bonds

Note:
... government bonds...

---

# Rates

Note:
... inter-bank interest rates...

---

# Swaps

Note:
... interest rate swaps...

---

# Futures

Note:
... and futures contracts.

---

# Filled

Note:
Data needed to be filled-in...

---

# Analyzed

Note:
... analyzed...

---

# Stored

Note:
... and stored in multiple databases for hundreds of downstream systems.

------

<div class="flex-row">
<span style="color: hotpink; font: 400% Comic Sans MS">Data</span>
<span style="color: green; font: 400% Courier New">Data</span>
</div>

Note:
These two data sets could not be more different...

---

<div class="flex-row">
<span style="font-size: 400%">Code</span>
<span style="font-size: 400%">Code</span>
</div>

Note:
... but they have similar computing problems that can be satisfied
with the same code.

------

# <del>Data</del>

Note:
So, this talk is not about data.

---

# Workflow

Note:
It's about workflow.

---

# Config

Note:
It's about configuration.

---

# Execution

Note:
It's about execution.

---

# Everything Else

Note:
It's about everything but the data itself.

------

# <del>Data</del>

Note:
So, since it's not about data...

---

# Data

Note:
... let's start with some code for processing data.

---

<pre class="larger"><code data-noescape data-trim># Extract
<span class="fragment highlight-current-red">my $id = shift @ARGV;</span>
my @raw_ts = <span class="fragment highlight-current-red">$dbh</span>-&gt;selectall_array(
  'SELECT * FROM bonds WHERE cusip=?', [ $id ], { Slice => {} }
);
</code></pre>

Note:
What this does isn't important, but you're curious, so I'll say that it
calculates the movement of a time series. We give it an ID on the
command-line, it loads the data from a database handle (DBI object).

---

<pre class="larger"><code data-noescape data-trim># Transform
my @move_ts;
my $prev_pt = shift @ts;
for my $pt ( @ts ) {
  push @move_ts, {
    stamp => $pt-&gt;{stamp},
    value => <span class="fragment highlight-current-red">$pt-&gt;{value} - $prev_pt-&gt;{value},</span>
  };
  $prev_pt = $pt;
}
</code></pre>

Note:
Then it transforms the data to a new time series, calculating the daily
change by subtracting the current day's value from the previous.

---

<pre class="larger"><code data-noescape data-trim># Load
for my $pt ( @move_ts ) {
  <span class="fragment highlight-current-red">$dbh</span>-&gt;do(
    'REPLACE INTO bonds_move ( stamp, value )
      VALUES ( ?, ? )',
    [ $pt-&gt;{qw( stamp value )} ],
  );
}
</code></pre>

Note:
Then it loads that data into the database.

---

# Code

Note:
This is a perfectly useful bit of code...

---

# <del>Program</del>

Note:
... but we can't yet call it a program.

---

# <code>$dbh</code>

Note:
We've got a database connection we need to configure...

---

# Config

Note:
... so we need a configuration file.

---

# Tests

Note:
We need to write some tests to verify it works, so it needs to be
testable.

---

# Deploy

Note:
We need to be able to deploy it to our production servers.

---

# Everything Else

Note:
So, we need to do everything but the data.

------

# Module

Note:
In Perl, the best way to make something testable, configurable, and
deployable is to put it in a module.

---

# Object

Note:
And a good way to make something reusable is to make it into an object.

---

<div class="flex-row">
<h1>Module</h1>
<h1>Object</h1>
</div>

Note:
So we'll do both of those things.

---

<pre class="larger"><code data-noescape>package <span class="fragment highlight-current-red">My::DailyChange</span>;
use v5.26;
<span class="fragment highlight-current-red">use Moo;</span>
<span class="fragment highlight-current-red">has dbh =&gt; (
  is =&gt; 'ro',
  required =&gt; 1,
);</span>
<span class="fragment highlight-current-red">sub run {</span>
  my ( $self, $id ) = @_;
  # Extract
  my @raw_ts = $self->dbh->selectall_array(
    'SELECT * FROM bonds WHERE cusip=?', [ $id ]
  );
</code></pre>

Note:
We'll put our code in a module named My::DailyChange, turn it into an
object class with the Moo library, create a "dbh" attribute to hold
our database handle, and put all of our code in a "run" method.

---

# Testable

Note:
This is easily testable

---

<pre class="larger"><code data-noescape>use Test::More;
<span class="fragment highlight-current-red">use My::DailyChange;</span>
my $obj = My::DailyChange-&gt;new(
  <span class="fragment highlight-current-red">dbh =&gt; DBI-&gt;connect( 'dbi:SQLite::memory::' )</span>,
);
<span class="fragment highlight-current-red">$obj-&gt;run( '008000AA7' );</span>
is_deeply
  <span class="fragment highlight-current-red">$obj->dbh->selectrow_hashref(
    'SELECT * FROM bonds_move'
  )</span>,
  <span class="fragment highlight-current-red">{ stamp => '2017-05-05', value => -0.012 }</span>,
  'daily change calculated correctly';
done_testing;
</code></pre>

Note:
We just load our module, give it a database handle, call the "run"
method, and verify that our calculated data matches what we expected.

---

# Deployable

Note:
This module is easily-deployable with any kind of CPAN toolchain, and
you've probably already solved this problem somehow (I, for example, use
Dist::Zilla).

---

# <del>Runnable</del>

Note:
We do need a way to run it, though.

---

# Config

Note:
And we need a way to configure the database connection.

---

<pre class="larger"><code>#!/usr/bin/env perl
<span class="fragment highlight-current-red">use YAML qw( LoadFile );
my $config = LoadFile( 'config.yml' );</span>
use My::DailyChange;
my $script = My::DailyChange-&gt;new(
    dbh => <span class="fragment highlight-current-red">DBI-&gt;connect( $config->{dsn} )</span>,
);
<span class="fragment highlight-current-red">$script-&gt;run( @ARGV );</span>
</code></pre>

Note:
We could write our own code for this, which would be pretty easy. Some
of us have probably written scripts like this dozens of times. We have
a YAML config file, we configure a data source name (DSN), and then we
call our "run" method.

---

# Scaling

Note:
If you've only got the one thing, this is probably fine. But CPAN
Testers has dozens of data processing scripts, and the bank I worked at
had hundreds. Writing 10 lines of code, the same code, for each script
is a maintenance nightmare.


------

# Beam::Runner

Note:
So let's use someone else's code for doing this (mine): Beam::Runner.

---

<div class="flex-row">
<h1 class="fragment fade-in">Runnable</h1>
<h1>Class</h1>
</div>

Note:
Beam::Runner takes a class exactly as we've written here and runs
it. But that's not the valuable part.

---

# Config

Note:
The valuable part is we get a configuration file to easily configure our
module.

---

# Centralized

Note:
We have a centralized place to list all the runnable modules we've
configured.

---

# Documentation

Note:
We can easily read the documentation for the module

---

# Distributed

Note:
And we can, without changing our code, run it on a distributed job queue
for horizontal scaling.

------

# Getting Started

Note:
To get started using Beam::Runner, we need to mark our module as
runnable.

---

<pre class="larger"><code data-noescape>package My::DailyChange;
use v5.26;
use Moo;
<span class="fragment fade-right">with 'Beam::Runnable';</span>
</code></pre>

Note:
Done. When we add the 'Beam::Runnable' role to our class, we've created
a Beam::Runner "task".

---

# Config

Note:
Next, we write our configuration file.

---

<pre class="larger"><code data-noescape># etc/bond.yml
<span class="fragment fade-in">daily_change:
  <span class="fragment fade-in">$class: My::DailyChange</span>
  <span class="fragment fade-in">dbh:</span>
    <span class="fragment fade-in">$class: DBI</span>
    <span class="fragment fade-in">$method: connect</span>
    <span class="fragment fade-in">$args:
      - 'dbi:SQLite:data.db'</span>
</code></pre>

Note:
Let's call this file "bond.yml" and put it in an "etc" directory. We
need to give our task a name, how about "daily_change"? Then, we tell it
to use our My::DailyChange module. Finally, we need create the database
handle. We give that a class (DBI), we give it the method to call
(connect), and the arguments to give (the data source name).

---
<!-- .slide: data-background="black" class="inverse" -->

# Beam::Wire

Note:
This configuration file is being processed by Beam::Wire.

---
<!-- .slide: data-background="black" class="inverse" -->

<pre class="largest"><code>$class: DBI
$method: connect
$args:
 - 'dbi:SQLite:data.db'
</code></pre>

Note:
Beam::Wire takes the special `$` sigils...

---
<!-- .slide: data-background="black" class="inverse" -->

<pre class="largest"><code>DBI-&gt;connect( 'dbi:SQLite:data.db' )</code></pre>

Note:
... and makes real Perl objects out of them.

---
<!-- .slide: data-background="black" class="inverse" -->

# Flexible

Note:
Beam::Wire can do a lot of very flexible things for creating objects,
but that's another topic and I've got more stuff to get through yet.

---

<pre class="larger"><code data-noescape># etc/bond.yml
daily_change:
  $class: My::DailyChange</span>
  dbh:</span>
    $class: DBI</span>
    $method: connect</span>
    $args:
      - 'dbi:SQLite:data.db'</span>
</code></pre>

Note:
Once we have the configuration file...

---

<pre class="largest"><code>$ export BEAM_PATH=etc</code></pre>

Note:
... we tell Beam::Runner where to find it by setting the BEAM_PATH environment
variable.

---

<pre class="largest"><code>$ beam run <span class="fragment highlight-current-red">bond</span> <span class="fragment highlight-current-red">daily_change</span> <span class="fragment highlight-current-red">008000AA7</span></code></pre>

Note:
And then we can run our script by giving the name of the config file and
the name of the task. Any additional arguments are given to the "run"
method, just as we did before.

------

# That's it

Note:
That's the basics of Beam::Runner. It's okay to be underwhelmed: So far
I've saved you from writing 10 lines of code, and showed you how to
write a script in a way you might already do.

---

<pre class="largest"><code>$ beam list
<b>bond</b>
- <b>daily_change</b> -- My::DailyChange
</code></pre>

Note:
I can show you how to list the tasks you have available, and your
operations/support team will love you for this, but that's not very
exciting. (It's half the reason I wrote this, but I'm weird and like
organization stuff like this).

---

# Abstraction

Note:
But this abstraction, an object with a run method that takes arguments,
allows us to do a lot of very fun things...

------

# Beam::Runnable<br/>::Single

Note:
For example, we can make sure only one instance of our task is being run
at a time by adding the Beam::Runnable::Single role.

---

<pre class="larger"><code data-trim data-noescape># etc/bond.yml
daily_change:
  $class: My::DailyChange
  dbh:
    $class: DBI
    $method: connect
    $args:
      - 'dbi:SQLite:data.db'
  <span class="fragment fade-in"><span class="fragment highlight-current-red">$with:
    - Beam::Runnable::Single</span>
  <span class="fragment highlight-current-red">pid_file: /var/run/bond-daily_change.pid</span></span></code></pre>

Note:
We don't even have to change our code to add the role, we can add it
right in the configuration file. We add the role with `$with`, and give
it a process ID file to use with the `pid_file` attribute.

---

<pre class="largest"><code>$ beam run bond daily_change 008000AA7
Process already running (PID: 1432)
</code></pre>

Note:
Now if we try to run our task, but there's already a running instance,
it will die with an error message instead.

------

# More Tools

Note:
There are other small, useful things like this included in Beam::Runner

---

# Beam::Runnable<br/>::Timeout::Alarm

Note:
This role uses the `alarm` Perl function to set a timeout for your
script. After the timeout is reached, the script will exit with an error
code.

---

# Beam::Runnable<br/>::AllowUsers

Note:
This role checks to see if the current user is allowed to run this task,
otherwise it dies with an error. This can be used to make sure only
'root' runs this task, for example.

---

# Beam::Runnable<br/>::DenyUsers

Note:
This role checks to see if the current user is prevented from running
this task, otherwise it dies with an error. This can be used to make
sure 'root' never runs this task, for example.

------

# Future Ideas

Note:
And there are more roles like this that could be created.

---

# Memory Limit

Note:
Memory limits could be enforced with a role, dying if the task takes too
much memory.

---

# Different User

Note:
The task could be run as a different user with a role.

---

# Re-try task

Note:
With a role, the task could be re-tried if it fails.

---

# Parallelization

Note:
Simple parallelization could be implemented with a role, with each
instance of the task taking one of the arguments on the command-line.
Give 5 arguments, get 5 parallel tasks, much like how GNU Parallel
works.

---

# Abstract

Note:
None of these roles require any knowledge of what the task is doing, but
they simplify the job of processing data.

---

# Re-usable

Note:
So they can be general for all such processing tasks. Solve a problem once,
re-use it when needed.

------

# Distributed

Note:
Another thing this abstraction allows us to do is distribute our jobs to
other machines.

---

# Beam::Minion

Note:
For that, I've written Beam::Minion to use the Minion task runner (part
of the Mojolicious ecosystem).

---

# No New Code

Note:
For this to work, we don't need any new code.

---

# Install Beam::Minion

Note:
We just install Beam::Minion

---

<pre class="larger"><code>$ export BEAM_MINION="sqlite:///tmp/minion.db"</code></pre>

Note:
Configure a database connection for it to use (for true distributing to
other machines, we'll need a networked database like Postgres or MySQL).

---

<pre class="largest"><code>$ beam minion worker</code></pre>

Note:
And start a worker.

---

<pre class="larger"><code>$ beam minion run bond daily_change 008000AA7
$ beam minion run bond daily_change 008000AA8
$ beam minion run bond daily_change 008000AA9</code></pre>

Note:
And then we can queue up a bunch of jobs and have them run on our
worker.

------

# Beam::Runner

Note:
So, with this simple abstraction we've...

---

# Runnable Module

Note:
... created a runnable module...

---

<pre class="larger"><code data-trim data-noescape># etc/bond.yml
daily_change:
  $class: My::DailyChange
  dbh:
    $class: DBI
    $method: connect
    $args:
      - 'dbi:SQLite:data.db'
  <span class="fragment fade-in">$with:
    - Beam::Runnable::Single
  pid_file: /var/run/bond-daily_change.pid</span></code></pre>


Note:
Configured an instance of our module and given it a database to use... and
prevented our task from running more than once at a time.

---

<pre class="larger"><code data-noescape>use Test::More;
use My::DailyChange;
my $obj = My::DailyChange-&gt;new(
  dbh =&gt; DBI-&gt;connect( 'dbi:SQLite::memory::' ),
);
$obj-&gt;run( '008000AA7' );
is_deeply
  $obj->dbh->selectrow_hashref(
    'SELECT * FROM bonds_move'
  ),
  { stamp => '2017-05-05', value => -0.012 },
  'daily change calculated correctly';
done_testing;
</code></pre>

Note:
We've tested our module.

---

<pre class="larger"><code>$ beam minion worker
$ beam minion run bond daily_change 008000AA7
$ beam minion run bond daily_change 008000AA8
$ beam minion run bond daily_change 008000AA9</code></pre>

Note:
And we've run our task on a distributed processing system...

------

# External

Note:
These are all external things that Beam::Runner and Beam::Wire provide us.

---

# Internal

Note:
But, there are other benefits unique to Beam::Wire that we can apply internally
to our code. If we go back to our code, it was divided into three parts.

---

# Extract

Note:
The extract part read from the database into an internal format (an array of
hashrefs).

---

# Transform

Note:
The transform part took that array and made a new array of hashrefs.

---

# Load

Note:
And the load part took the array of hashrefs and loaded it into the database.

---

# Re-use

Note:
To make it easier to build new processes, by re-using these parts, we can break
each of these steps into its own module. This is a common-enough pattern that it
has a name: Extract, Transform, Load (or ETL).

---

<pre class="larger"><code data-noescape data-trim><span class="fragment fade-in">package My::Extract::DBI; use Moo;</span>
<span class="fragment fade-in">has dbh => ( is => 'ro', required => 1 );</span>
<span class="fragment fade-in">has table => ( is => 'ro', required => 1 );</span>
sub run {
  my ( $self, $id ) = @_;
  <span class="fragment fade-in">my $table = $self->table;</span>
  my @ts = $self-&gt;dbh-&gt;selectall_array(
    "SELECT * FROM $table WHERE id=?", [ $id ], { Slice => {} }
  );
<span class="fragment fade-in">  return @ts;
}</span></code></pre>

Note:
For our extractor, we'll need the database handle, but we'll also take a table
name so we can load data from other tables too. Then we'll return the data we
extracted.

---

<pre class="larger"><code data-noescape data-trim><span class="fragment
fade-in">package My::Transform::DailyChange; use Moo;</span>
<span class="fragment fade-in">sub run {
  my ( $self, $prev_pt, @ts ) = @_;</span>
  my @move_ts;
  for my $pt ( @ts ) {
    push @move_ts, {
      stamp => $pt-&gt;{stamp},
      value => $pt-&gt;{value} - $prev_pt-&gt;{value},
    };
    $prev_pt = $pt; }
  <span class="fragment fade-in">return @move_ts; }</span></code></pre>

Note:
For our transformer, nothing really changes. It gets data as arguments and
returns the transformed data.

---

<pre class="larger"><code data-noescape data-trim><span class="fragment
fade-in">package My::Load::DBI; use Moo;</span>
<span class="fragment fade-in">has dbh => ( is => 'ro', required => 1 );</span>
<span class="fragment fade-in">has table => ( is => 'ro', required => 1 );</span>
<span class="fragment fade-in">sub run {
  my ( $self, $id ) = @_;</span>
  <span class="fragment fade-in">my $table = $self->table;</span>
  for my $pt ( @ts ) {
    $dbh-&gt;do(
      "REPLACE INTO $table ( stamp, value )
        VALUES ( ?, ? )",
      [ $pt-&gt;{qw( stamp value )} ] );
  }
<span class="fragment fade-in">}</span></code></pre>

Note:
For our loader, we get the data as arguments and write it to the database. Like
our extractor, we'll get a database handle and a table name so we can load the
data anywhere.

---

<pre class="larger"><code data-noescape data-trim><span class="fragment
fade-in" data-fragment-index=1>package My::Runner;</span> <span class="fragment fade-in" data-fragment-index=2>use Moo;</span>
<span class="fragment fade-in" data-fragment-index=3>with 'Beam::Runner';</span>
<span class="fragment fade-in" data-fragment-index=6>has extract => ( is => 'ro' );</span>
<span class="fragment fade-in" data-fragment-index=8>has transforms => ( is => 'ro' );</span>
<span class="fragment fade-in" data-fragment-index=10>has load => ( is => 'ro' );</span>
<span class="fragment fade-in" data-fragment-index=4>sub run {
  my ( $self, @args ) = @_;</span>
  <span class="fragment fade-in" data-fragment-index=7>my @ts = $self->extract->run( @args );</span>
  <span class="fragment fade-in" data-fragment-index=9>for my $xform ( @{ $self->transforms } ) {
    @ts = $xform->run( @ts ); }</span>
  <span class="fragment fade-in" data-fragment-index=11>$self->load->run( @ts );</span>
<span class="fragment fade-in" data-fragment-index=5>}</span>

Note:
Finally, we need a module to bring them all together: Extract from the
extractor, transform with the transforms, and load into the loader.

---

<pre class="larger"><code><span class="fragment fade-in">dbh:</span>
  <span class="fragment fade-in">$class: DBI
  $method: connect
  $args:
    - 'dbi:SQLite:data.db'</span>
<span class="fragment fade-in">daily_change:</span></code></pre>

Note:
Now that we have all these things, we can re-configure our bond process. First,
since we use the same database for the extract and load steps, let's configure
that separately. We can configure other objects just as before: Give it a name
like "dbh", then the class, method, and args like before. Then we're back to
configuring our daily_change task.

---

<pre class="larger"><code>daily_change:
  <span class="fragment fade-in">$class: My::Runner</span>
  <span class="fragment fade-in">extract:</span>
    <span class="fragment fade-in">$class: My::Extract::DBI</span>
    <span class="fragment fade-in">dbh:
      $ref: dbh</span>
    <span class="fragment fade-in">table: bonds</span></code></pre>

Note:
We give it our new runner class, configure an extractor with our extractor
class, give it a reference ($ref) to our configured database handle, and tell it
our source table is "bonds".

---

<pre class="larger"><code>    <span class="fragment fade-in">transforms:</span>
    <span class="fragment fade-in">- $class: My::Transform::DailyChange</span>
  <span class="fragment fade-in">load:</span>
    <span class="fragment fade-in">$class: My::Load::DBI</span>
    <span class="fragment fade-in">dbh:
      $ref: dbh</span>
    <span class="fragment fade-in">table: bonds_move</span></code></pre>

Note:
Then we configure our transform, and finally our load, which gets the same
database handle, but has a different table name.

---

<pre class="larger"><code># etc/rates.yml
daily_change:
  $class: My::Runner
  extract:
    $class: My::Extract::DBI
    dbh:
      $ref: dbh
    table: <span class="fragment highlight-red">rates</span></code></pre>

<pre class="larger"><code># etc/fx.yml
daily_change:
  $class: My::Runner
  extract:
    $class: My::Extract::DBI
    dbh:
      $ref: dbh
    table: <span class="fragment highlight-blue">fx</span></code></pre>

Note:
But now I can also configure one for rates and fx data without writing any new
code, just new configuration. This makes it easier to manage dozens of these
processes.

---

<pre class="larger"><code>package My::Transform::FillForward; use Moo;
sub run {
  my ( $self, @ts ) = @_;
  for my $i ( 0 .. $#ts ) {
    if ( !$ts[$i]{value} ) {
      $ts[$i]{value} = $ts[$i-1]{value};
    }
  }
  return @ts;
}</code></pre>

Note:
And if I need to add more steps, I can write a new transformer. This one
forward-fills missing data from the previous date.

---

<pre class="larger"><code># etc/fx.yml
daily_change:
  $class: My::Runner
  extract:
    $class: My::Extract::DBI
    dbh:
      $ref: dbh
    table: fx
  transforms:
    <span class="fragment fade-in">- $class: My::Transform::FillForward</span>
    - $class: My::Transform::DailyChange</code></pre>

Note:
Then I can add it to my process by changing its configuration.

---

<div class="flex-row">
<h2 class="fragment fade-in">Beam::Wire</h2>
<h2 class="fragment fade-in">Beam::Runner</h2>
</div>

Note:
So with Beam::Wire configuring our objects, and Beam::Runner to run them, we can
build a huge but maintainable data platform that maximizes re-use and scales
horizontally for growth.

------

# Questions?

------

# Thank You

<http://preaction.github.io/Data-Workflows-With-Beam/>

<div style="width: 40%; float: left">

by [Doug Bell](http://preaction.me)  
<small>(he, him, his)</small>  
[<i class="fa fa-twitter"></i> @preaction](http://twitter.com/preaction)  
[<i class="fa fa-github"></i> preaction](http://github.com/preaction)  
[Chicago.PM](http://chicago.pm.org)  

</div>
<div style="width: 20%; float: left; text-align: center">
<img src="http://preaction.me/images/avatar-small.jpg" style="display: inline-block; max-width: 100%"/>
</div>
<div style="width: 40%; float: left">

[<i class="fa fa-file-text-o"></i> Notes](https://github.com/preaction/Data-Workflows-With-Beam/blob/master/NOTES.md)  
<small> </small>  
[Source on <i class="fa fa-github"></i>](https://github.com/preaction/Data-Workflows-With-Beam/)  

[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode)  

</div>

