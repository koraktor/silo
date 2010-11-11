Silo
====

Silo is command-line utility and Ruby API for Git-based backups. With Silo you
can backup arbitrary files into one or more Git repositories and take advantage
of Git's compression, speed and other features. No Git knowledge needed.

## Concept

To backup files into a repository Silo uses the well-known and established
version control system (VCS) Git. Instead of using Git's frontend commands for
the end-user, so called *"porcelain"* commands, Silo makes use of the more
low-level *"plumbing"* commands. These can be used to write directly to the Git
repository, bypassing the automatisms tailored for source code histories.

## Requirements

* Grit &ndash; a Ruby API for Git
* Rubikon &ndash; a Ruby framework for console applications
* Git >= 1.6

## Basic usage

### Initialize a repository

    silo init [repository path]

## Using the Ruby API

The documentation of the Ruby API can be seen at [RubyDoc.info][1].

## Credits

* Sebastian Staudt &ndash; koraktor(at)gmail.com

## See Also

* [API documentation][1]
* [Silo's homepage][2]
* [GitHub project page][3]
* [GitHub issue tracker][4]

Follow Silo on Twitter [@silorb](http://twitter.com/silorb).

 [1]: http://rubydoc.info/gems/silo
 [2]: http://koraktor.github.com/silo
 [3]: http://github.com/koraktor/silo
 [4]: http://github.com/koraktor/silo/issues
