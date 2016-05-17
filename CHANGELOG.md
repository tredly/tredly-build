# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.10.5] - 2016-05-17
#### Fixed
- `urlRedirect` and `urlCert` bugfix - strip trailing slash (Closes tredly/tredly-host#36)

## [0.10.4] - 2016-05-16
#### Fixed
- Removed semicolon from dns servers within container in `/etc/resolv.conf` (tredly/tredly-build#41)
- Fixed IP being referenced as partition name for container group members
- Fixed `containergroup` array. Now local instead of global. (Potential fix for tredly/tredly-host#36)

## [0.10.3] - 2016-05-13
#### Fixed
- Removed hard coded values from `tredly-host.conf` (tredly/tredly-build#38)

#### Changes
- Better checking on whether IP falls in subnet (If `lifNetwork` is blank then checks are not conducted).
- Updated Tredlyfile.sample documentation

## [0.10.2] - 2016-05-12
#### Added
- Added host wide default 404 page
- Added extra checks to prevent error messages on the command line when ipfw, unbound or vimage is not loaded.
- Added function to handle IPFW tables preserved across reboots, and doco for reserved ip addresses

#### Changed
- Matching Tredly version to Tredlyfile version on `major.minor` only rather than `major.minor.patch` (#30)
- Improved validation and error reporting of `urlCerts`, `fileFolderMapping` and `urlRedirectCerts`
- Moved config to Tredly-host
- Moved to tables instead of variables for IPFW wherever possible

#### Fixed
- Copying `sslCerts` from container directory is fixed (#28)

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

[0.10.5]: https://github.com/tredly/tredly-build/compare/v0.10.4...v0.10.5
[0.10.4]: https://github.com/tredly/tredly-build/compare/v0.10.3...v0.10.4
[0.10.3]: https://github.com/tredly/tredly-build/compare/v0.10.2...v0.10.3
[0.10.2]: https://github.com/tredly/tredly-build/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/tredly/tredly-build/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/tredly/tredly-build/compare/v0.9.0...v0.10.0
