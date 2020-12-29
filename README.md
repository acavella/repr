<!-- PROJECT LOGO -->
# reposync

<!-- PROJECT SHIELDS -->
<p align="center">
  <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/altCipher/reposync?style=flat-square">
  <img alt="GitHub closed issues" src="https://img.shields.io/github/issues-closed/altCipher/reposync?style=flat-square">
  <img alt="GitHub" src="https://img.shields.io/github/license/altCipher/reposync?style=flat-square">
  <img alt="GitHub release (latest SemVer including pre-releases)" src="https://img.shields.io/github/v/release/altCipher/reposync?include_prereleases&style=flat-square">
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/altCipher/reposync">
</p>

## Overview

Performs sync of online YUM repositories and prepares incremental updates for use with an offline repository.

- Retrieves rpms from a subscribed online YUM/DNF repository
- Builds incremental update tar for use on offline repository server
- Generates client side script to automatically deploy and update client repository

## Requirements
- Bash
- yum-utils
- tar

## Installation

1. Download the [latest release](https://github.com/altCipher/reposync/releases)
2. Extract the zip on the online server
3. Configure server and client repo details in rs-server.conf
4. Execute reposync.sh on the server to build an initial repository and manifest

## Security Vulnerabilities

If you discover a security vulnerability within revoke, please send an e-mail to [tony@cavella.com](mailto:tony@cavella.com?Revoke%20Security%20Vulnerability). Security vulnerabilities are taken very seriously and will be addressed with the utmost priority.

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the GNU General Public License v3.0. See `LICENSE` for more information.

## Contact
<!--lint disable no-auto-link-without-protocol-->
Tony Cavella - <tony@cavella.com>

Project Link: [https://github.com/altCipher/reposync](https://github.com/altCipher/reposync)

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Google](https://www.flaticon.com/authors/google) - TickInCircle icon used in logo.
* [Img Shields](https://shields.io) - Shields used in `README`
* [Choose an Open Source License](https://choosealicense.com) - Project `LICENSE`
* [GitHub Pages](https://pages.github.com)
* [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) - Adam Pritchard's markdown cheatsheet.
* [Semantic Version](https://semver.org) - Semantic Versioning Specification v2.0.0
