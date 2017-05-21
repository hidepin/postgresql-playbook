#!/bin/bash
#############################################################################
#  Copyright (c) 2009-2017, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
#############################################################################

log_directory="${1}"
expired_date="${2:--1}"
archive_directory="${log_directory}/log_archive"
archive_filename="${archive_directory}/$(date +postgresql-%Y%m%d.tar.gz)"

# check expired_date
[ ${expired_date} -ge 1 q] || exit 1

# change the current directory to log directory
cd "${log_directory}" || exit 1

# create a directory that store archive file
mkdir -p "${archive_directory}" || exit 1

# search the csv log files that have been updated in more than one day ago
target_files=($(find -maxdepth 1 -type f -name "*.csv" -daystart -ctime +0)) || exit 1

# create archive file
if [ ${#target_files[@]} -gt 0 ] ; then

	if [ -e "${archive_filename}" ] ; then
		echo "archive file \"${archive_filename}\" already exists" 1>&2
		exit 1
	fi

	tar cfz "${archive_filename}" ${target_files[@]} --remove-files || exit 1
fi

# change the current directory to log directory
cd "${archive_directory}" || exit 1

# search the tar log files
target_files=($(find -maxdepth 1 -type f -name "*.tar.gz" -daystart -ctime +${expired_date})) || exit 1

# remove archive file
if [ ${#target_files[@]} -gt 0 ] ; then

    rm ${target_files[@]} || exit 1
fi

exit 0
