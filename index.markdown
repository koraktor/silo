---
layout: default
title:  About
---
<div id="logo">
  <img alt="Silo logo" src="graphics/silo.png" />
</div>

Silo
===============

Silo is command-line utility and Ruby API for Git-based backups. With Silo you
can backup arbitrary files into one or more Git repositories and take advantage
of Git's compression, speed and other features. No Git knowledge needed.

If you want to keep up with the latest development, [follow Silo on
Twitter][1].

## Concept

To backup files into a repository Silo uses the well-known and established
version control system (VCS) [Git][2]. Instead of using Git's frontend commands
for the end-user, so called "porcelain" commands, Silo makes use of the more
low-level "plumbing" commands. These can be used to write directly to the Git
repository, bypassing the automatisms tailored for source code histories.

## Requirements
- [Git][2] – Version 1.6 or newer
- [Grit][3] – a Ruby API for Git
- [Rubikon][4] – a Ruby framework for console applications

## Problems?

- If you think you found an error in Silo, please check the [issue tracker][5]
  for a report. If the error hasn't been reported yet, please submit an issue
  report.
- Additionally you're welcome to ask for support by messaging [me (koraktor)][6]
  at GitHub or [@silorb][1] at Twitter.

## License
Silo is free software; you can redistribute it and/or modify it under the terms
of the new BSD License. A copy of this license can be found [here][7].

  [1]: http://twitter.com/silorb
  [2]: http://git-scm.com
  [3]: https://github.com/mojombo/grit
  [4]: http://koraktor.de/rubikon
  [5]: https://github.com/koraktor/silo/issues
  [6]: https://github.com/koraktor
  [7]: license.html
