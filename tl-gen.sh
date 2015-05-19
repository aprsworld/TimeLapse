#!/bin/sh

home="/home/suravad/cam.aprsworld.com/timeLapseTest"

camera=${1}
ts_beg=${2}
if [ ! ${camera} ] ; then
	echo "You must specifify a camera!"
	echo "Syntax: tl-get [camera] [start_time] ([end_time])"
	echo "        Where times are in the format [yyyymmdd_HHmmss]"
	echo "        and both are with-in the same day."
fi
if [ ! ${ts_beg} ] ; then
	echo "You must specifify a starting time!"
	echo "Syntax: tl-get [camera] [start_time] ([end_time])"
	echo "        Where times are in the format [yyyymmdd_HHmmss]"
	echo "        and both are with-in the same day."
	exit 0
fi	
ts_end=${3}
date_beg=$(echo ${ts_beg} | cut -d _ -f 1)
if [ ! ${ts_end} ]; then
	ts_end="${date_beg}_235959"
fi
date_end=$(echo ${ts_end} | cut -d _ -f 1)
if [ ${date_beg} -ne ${date_end} ]; then
	echo "Beginning Timestamp and Ending Timestamp not within same day!"
	exit 0
fi
date=${date_beg}
date_year=$(echo ${date} | cut -c 1-4)
date_month=$(echo ${date} | cut -c 5-6)
date_day=$(echo ${date} | cut -c 7-8)
#### XXX TODO : Validate timestamps and date
time_beg=$(echo ${ts_beg} | cut -d _ -f 2)
time_end=$(echo ${ts_end} | cut -d _ -f 2)


echo "Generating timelapse for ${camera} ${date} ${time_beg}-${time_end}."
IFS='
'
files=$(find "${home}/${camera}/${date_year}/${date_month}/${date_day}/" -type f -name '*.jpg' -print | sort)
seq=0
### TODO : Ensure the camera and date directories exist?
tmp_dir="${home}/${camera}/${date_year}/${date_month}/${date_day}/tl_gen_tmp"
if [ -d ${tmp_dir} ] ; then
	echo "Temporary generation directory already exists! Aborting."
	exit 0
fi
mkdir ${tmp_dir}
if [ ! $? ] ; then
	echo "Unable to create temporary direcroy! Aborting."
	exit 0
fi
for file in ${files} ; do
	time=$(basename "${file}" | cut -d . -f 1 | cut -d _ -f 2)
	if [ ${time} -gt ${time_beg} ] ; then
		if [ ${time} -gt ${time_end} ] ; then
			break
		fi
		ln -s "${file}" "${tmp_dir}/$(printf %05d ${seq}).jpg"
		seq=$((${seq}+1))
	fi
done
### TODO XXX gstreamer invokation
rm -rf "${tmp_dir}"
exit 1
