
# Data Workflows With Beam

This presentation covers how the Beam libraries can be used to configure
and deploy a large data processing platform.

* [View the talk](http://preaction.github.io/Data-Workflows-With-Beam/)
* [Read the notes](http://github.com/preaction/Data-Workflows-With-Beam/blob/master/NOTES.md)

## Abstract

The biggest problem in a large data processing system is how to organize
it: Where are the scripts? Where's the configuration? How can the
scripts share code and configuration? How do we turn our ad-hoc data
processing scripts into a cohesive data platform?

The Beam framework consists of tools for integrating systems, no matter
what Perl libraries you're using.
[Beam::Wire](http://metacpan.org/pod/Beam::Wire) provides a powerful
configuration file for sharing information.
[Beam::Runner](http://metacpan.org/pod/Beam::Runner) provides
organization and discovery for data scripts. And
[Beam::Minion](http://metacpan.org/pod/Beam::Minion) provides a scalable
compute cluster using the Minion task engine. With these tools, you can
build a flexible, maintainable data processing system, or start better
organizing your existing data processing system.

## Covered Topics

This talk covers:

* Basic usage of [Beam::Wire](http://metacpan.org/pod/Beam::Wire)
* Introduction of ETL (Extract, Transform, Load) concepts
* Usage of [Beam::Runner](http://metacpan.org/pod/Beam::Runner)
* Basic usage of [Beam::Minion](http://metacpan.org/pod/Beam::Minion)

## Included Code

In this repository is an example ETL framework called `ETL::Earl`. This
ETL is built to handle financial time series data. Modules are in the
`lib/` directory, configuration (Beam::Wire container files) in the
`etc/` directory.

# AUTHOR

About the author.

Speaking credentials.

# HISTORY

* Topic first discussed at [Chicago.PM](http://chicago.pm.org) -- April 2017
* Completely rewritten for [The Perl Conference
  2017](http://www.perlconference.us/tpc-2017-dc/) -- June 2017

# COPYRIGHT AND LICENSE

Copyright 2017 Doug Bell <preaction@cpan.org>

The presentation content is licensed under CC-BY-SA 4.0.

The Perl code is licensed under CC-BY-SA 4.0, or the same terms as Perl
itself (Artistic License 1.0, or GPL 1.0+ at your discretion).

