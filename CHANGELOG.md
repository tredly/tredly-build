# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.10.1] - 2016-05-09
#### Fixed
- Fixed incomplete merge in `lib/ip4_functions.sh`

#### Changed
- Using Major.Minor instead of Major.Minor.Patch when comparing Tredly version against Tredlyfile version

## [0.10.0] - 2016-05-05
#### Added
- Added this CHANGELOG.md file
- Added CONTRIBUTING.md guidelines
- Implemented `urlRedirect=` for URLs
- Implemented ability to set container resource limits (RAM, CPU, HDD) and whitelist (`ipv4whitelist`) on the command line.
- Added `any` keyword for ports
- Including sample Tredlyfile
- Added .gitignore
- Container limit modification implemented
- Added numbering (1 to 999) url blocks. This creates a grouping feature for URLS and their different settings.
- Validate SSLCerts for URLs, validate Certs for redirects.
- Put own IP address and hostname into hosts file
- Added `$request_uri` for redirects.
- Create default directories in partition data directory
- Copy in SSL certs from `partition/container`
- Automate SSL cert installation to Layer 7 proxy
- Implemented IPv4 address change, hostname change, gateway change
- Tredlyfile version is checked when building and will fail if it does not match the Tredly version

#### Fixed
- Incorrect filename for `IPFW_FORWARDS` in defines.sh
- Fix resolv.conf search
- Bugfix for nginx proxy upstream file
- CHMOD the SSL key to not be world readable

#### Changed
- Using MIT license instead of GPLv3
- Allow 80, 443 (TCP) and 53 (UDP) out ports by default (except when `any` is set)
- Update validate to new standard
- Update locations to include relevant proxy files
- Check that redirect urls exist
- Enforcing gateway when changing IP address

## 0.9.0 - 2016-04-21
#### Added
- Initial release of Tredly

[0.10.1]: https://github.com/tredly/tredly-build/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/tredly/tredly-build/compare/v0.9.0...v0.10.0
