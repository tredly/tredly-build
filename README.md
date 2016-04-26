# Tredly
Version 0.9.0
Apr 21 2016

This is a software package to simplify the usage and management of containers within Unix. You can find out more information about Tredly at **[http://tredly.com](http://tredly.com)**

## Installation

Requires Tredly 0.9.0 **[https://github.com/vuid-com/tredly-host](https://github.com/vuid-com/tredly-host)**

Checkout this repo and run `./tredly.sh install clean` to install. Note that the "clean" option will uninstall tredly before reinstalling.

## Usage

Tredly requires a [Tredlyfile](https://github.com/tredly/tredly-host/wiki/Tredlyfile) as the "recipe" for a container. This file contains all of the information Tredly needs to build and start your container.

To see the help, use `tredly --help`

## Uninstalling

Run `./tredly.sh uninstall` from the checkout directory to uninstall tredly.

### ZFS Datasets

A list of ZFS datasets used by Tredly is available in `doc/zfs.md`

## Contributing

We encourage you to contribute to Tredly. Please check out the [Contributing documentation](https://github.com/tredly/tredly-build/blob/master/CONTRIBUTING.md) for guidelines about how to get involved.

## License

Tredly is released under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl-3.0.en.html).
