# repr 2

*Enterprise Linux (EL) Offline Package Downloader*

This project provides a streamlined, automated way to create a fully self-contained, offline YUM/DNF repository based on the installed packages of one or more source systems. It is highly useful for air-gapped environments or managing offline servers.

## Features

- Multiple Input Support: Accepts multiple text files containing package lists and intelligently combines them.
- Automatic Deduplication: Sorts and filters out duplicate packages across multiple lists before downloading.
- Full Dependency Resolution: Downloads the requested packages and all of their required dependencies.
- Smart DNF Versioning: Automatically detects whether the host system is running DNF version 4 or 5 and applies the correct flags (--skip-broken vs --skip-unavailable) to prevent failures on missing third-party packages.
- Local Repository Generation: Automatically runs createrepo to generate necessary YUM/DNF repository metadata.
- Auto-Archiving: Compresses the downloaded RPMs and metadata into a portable .tar.gz archive.
- Auto-Cleanup: Safely removes the uncompressed source directory after the archive is successfully built to save disk space.

## Prerequisites

- An internet-connected AlmaLinux, Rocky Linux, or RHEL-based system.
- sudo privileges (required for installing prerequisites like dnf-plugins-core and createrepo, and for running dnf download).

## Usage

**Step 1: Generate a Package List** 

On the system(s) you want to mirror or update, generate a list of currently installed packages. You can use the list_packages.sh script if you have it, or simply run the following command and save the output to a text file:

``` shell 
dnf list installed > server1_packages.txt
```

*(Repeat this step on any other servers if you want to combine their requirements into a single offline repository).* 

**Step 2: Download and Archive Packages**

Transfer the text file(s) to your internet-connected machine. Make sure the downloader script is executable:

``` shell
chmod +x download_packages.sh
```

Run the script, passing the text file(s) as arguments:

``` shell
./download_packages.sh server1_packages.txt server2_packages.txt
```

**What the script does:**

1. Creates a timestamped directory.
2. Parses the input files, skipping headers and removing duplicates.
3. Downloads all RPMs and their dependencies.
4. Generates repository metadata using createrepo.
5. Packages everything into offline_packages_YYYYMMDD_HHMMSS.tar.gz.
6. Deletes the temporary uncompressed directory.

**Step 3: Using the Offline Repository**

1. Transfer the resulting .tar.gz file to your offline/air-gapped machine.
2. Extract the archive:

``` shell 
tar -xzf offline_packages_20260321_120000.tar.gz
```

3. Create a new repository configuration file in /etc/yum.repos.d/. For example, create /etc/yum.repos.d/offline.repo:

``` shell
[offline-repo]
name=Offline Packages
baseurl=file:///path/to/extracted/offline_packages_20260321_120000
enabled=1
gpgcheck=0
```

4. You can now install packages offline using standard DNF commands:

``` shell
sudo dnf install <package_name>
```

## Troubleshooting

Missing Packages Warning: If the script warns that some packages failed to download, this is usually because the input list contains custom, local, or third-party RPMs that are not available in the standard repositories of the internet-connected downloading machine. Ensure your downloading machine has the same third-party repositories (like EPEL) enabled as your source machines.