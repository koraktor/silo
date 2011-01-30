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

## Installation

You can install Silo using RubyGems. This is the easiest way of installing
and recommended for most users.

    $ gem install silo

If you want to use the development code you should clone the Git repository:

    $ git clone git://github.com/koraktor/silo.git
    $ cd silo
    $ rake install

## Basic usage

### Configuration files

Silo searches for configuration files (`.silo`) in the current working
directory, your home directory and your systems global configuration directory
(i.e. /etc on Unix).

They can be used to set Silo-specific options globally or for single
directories. That way you may have one general Silo repository for common
backups and another Silo repository for e.g. work-related files.

Configuration files are expected in a Git-like format and
may contain the following sections and variables:

* repository

  * path – The path of the default repository to use
  * prefix – The path inside the repository to store files to per default

#### Sample

    [repository]
      path   = /Users/jondoe/backup.git
      prefix = work

This would usually save and restore files to and from
`/Users/jondoe/backup.git` and save files into the directory `work` inside the
repository.

### Initialize a repository

    $ silo init [repository path]

### Add files or directories to the repository

    $ silo add file [file ...] [--prefix <prefix>]

The prefix allows to organize the files inside the repository.

### Restore files or directories from the repository

    $ silo restore file [file ...] [--prefix <prefix>]

The prefix is the directory inside your file system where the restored files
will be saved.

### Remove files or directories from the repository

    $ silo remove file [file ...]
    $ silo rm file [file ...]

### Completely purge files or directories from the repository

    $ silo purge file [file ...] [--no-clean]

This will completely remove the specified files from the repository and thus
reduce the required disk space.

**WARNING**: There's no method built-in to Silo or Git to recover files after
purging.

The `--no-clean` flag will cause Git commits to persist even after their
contents have been purged.

### Manage remote repositories for mirrored backups

    $ silo remote [-v]
    $ silo remote add name url
    $ silo remote rm name

Add or remove a remote repository with the specified name. When adding a remote
repository the specified location may be given as any location Git understands
– including file system paths.

### Distribute the state of your repository to all mirror repositories

    $ silo distribute

### List repository contents

    $ silo list [file ...] [-l] [-r]

The `-l` flag will list each directory and file in a separate line, `-r` will
reverse the listing.

### Display info about repository contents

    $ silo info [file ...] [-v]

## Using the Ruby API

The documentation of the Ruby API can be seen at [RubyDoc.info][1]. The API
documentation of the current development version is also available [there][5].

## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
LICENSE file.

## Credits

* Sebastian Staudt – koraktor(at)gmail.com

## See Also

* [API documentation][1]
* [Silo's homepage][2]
* [GitHub project page][3]
* [GitHub issue tracker][4]

Follow Silo on Twitter [@silorb](http://twitter.com/silorb).

 [1]: http://rubydoc.info/gems/silo/frames
 [2]: http://koraktor.github.com/silo
 [3]: http://github.com/koraktor/silo
 [4]: http://github.com/koraktor/silo/issues
 [5]: http://rubydoc.info/github/koraktor/silo/master/frames
