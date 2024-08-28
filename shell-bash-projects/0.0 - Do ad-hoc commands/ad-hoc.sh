#!/bin/bash

# Create a log folder
mkdir /var/log/ad-hoc-bash/
cd /var/log/ad-hoc-bash/
touch project-one.log

# do test connectivities
URL_TO_TEST = "https://google.com"

if [(ping $URL_TO_TEST) << ]
