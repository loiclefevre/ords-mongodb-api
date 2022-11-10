# Oracle REST Data Services (ORDS) + MongoDB API on Docker

This image has been greatly inspired from Tim Hall's Dockerfile [Docker : Oracle REST Data Services (ORDS) on Docker](https://oracle-base.com/articles/linux/docker-oracle-rest-data-services-ords-on-docker)

Directory contents when software is included.

```
$ tree
.
├── build.sh
├── Dockerfile
├── download.sh
├── README.md
├── scripts
│   ├── healthcheck.sh
│   ├── install_os_packages.sh
│   ├── ords_software_installation.sh
│   └── start.sh
└── software
    ├── jdk-11.0.16.1_linux-x64_bin.tar.gz
    ├── ords-latest.zip
    ├── put_software_here.txt
    └── sqlcl-latest.zip
```

## Setup
Download a JDK 11 and copy the tarball in the `software` directory.
Example: [jdk-11.0.16.1_linux-x64_bin.tar.gz](https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html)

Run the `./download.sh` script to download the latest versions of ORDS and SQLcl.

## Building the image
Run `./build.sh`