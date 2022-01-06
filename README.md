# Git2JSS
## Table of Contents
* [Description](#description)
* [Installation](#installation)
* [Usage](#usage)
* [Requirements](#requirements)

## Description
git2jss is a command-line utility written in Ruby used to synchronize a git repository with a Jamf Software Server (JSS) script database. This utility would not be possible without the following libraries: [ruby-jss](https://github.com/PixarAnimationStudios/ruby-jss), [ruby-git](https://github.com/ruby-git/ruby-git), and [ruby-keychain](https://github.com/fcheung/keychain).

## Installation
Currently, the command line utility can only be installed from source pending better testing. At a later date, it will be available from ruby-gems.org. A sufficiently configured Ruby environment must already be set up (I recommend doing so with [rbenv](https://github.com/rbenv/rbenv)). One can build the gem with the following commands, after cloning the repository:

```
$ cd /path/to/git2jss
$ gem build ./git2jss.gemspec
$ gem install ./git2jss-<version>.gem
```

## Usage
At its simplest, you can invoke `git2jss` like so:
```
$ git2jss -f file/in/repo -n "Name to use in the JSS Database" -s path/to/repo
```

## Requirements
Git2JSS was written with the following in mind:
* Mac OS X 10.9 or higher
* Ruby 2.7

