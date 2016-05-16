# Tredly

- Version: 0.10.4
- Date: May 16 2016
- [Release notes](https://github.com/tredly/tredly-build/blob/master/CHANGELOG.md)
- [GitHub repository](https://github.com/tredly/tredly-build)

## Overview

This is a software package to simplify the usage and management of containers within FreeBSD. You can find out more information about Tredly at **<http://www.tredly.com>**

## Requirements

To install Tredly, your server must be running **FreeBSD 10.3 (or above) as Root-on-ZFS**. Further details can be found at the [Tredly Docs site](http://www.tredly.com/docs/?p=31).

You must also have [Tredly Host 0.10.0](https://github.com/tredly/tredly-host) or newer installed.

## Installation

Tredly-Build is installed automatically when you install [Tredly Host](https://github.com/tredly/tredly-host). If you want to install it manually, or to update your install, follow the steps below:

### Via Git

1. Clone the Tredly-Build repository to the desired location (we suggest `/tmp`):

```
    git clone git://github.com/tredly/tredly-build.git /tmp
    cd /usr/local/etc/tredly-build
```

1. Run `./tredly.sh install clean` to complete install. Note that the "clean" option will uninstall any existing installations of Tredly Build first.

## Usage

Tredly requires a [Tredlyfile](http://www.tredly.com/docs/?cat=6) as the "recipe" for a container. This file contains all of the information Tredly needs to build and start your container.

To see the help, use `tredly --help`

## Uninstalling

To remove Tredly-Build run the following command from your `tredly-build` folder (most likely `/usr/local/etc`): `./tredly.sh uninstall`

### ZFS Datasets

A list of ZFS datasets used by Tredly is available in `doc/zfs.md`

## Contributing

We encourage you to contribute to Tredly. Please check out the [Contributing documentation](https://github.com/tredly/tredly-build/blob/master/CONTRIBUTING.md) for guidelines about how to get involved.

## License

Tredly is released under the [MIT License](http://www.opensource.org/licenses/MIT).
