#!/bin/sh

# Root Directory of Collected Image Snapshots
home="/mnt/cam.aprsworld.com/"

# Arguments
output=${1}
camera=${2}
ts_beg=${3}
ts_end=${4}

output_syntax () {
	echo "Syntax: tl-gen [output] [camera] [start_time] ([end_time])"
	echo "        Where times are in the format [yyyymmdd_HHmmss]."
}

### Validate Arguments
if [ ! ${output} ] ; then
	echo "You must specify an output file!"
	output_syntax
	exit 0
fi
if [ ! ${camera} ] ; then
	echo "You must specify a camera!"
	output_syntax
	exit 0
fi
if [ ! ${ts_beg} ] ; then
	echo "You must specifify a starting timestamp!"
	output_syntax
	exit 0
fi
# Optional Timestamp_End parameter (use current time if not present)
if [ ! ${ts_end} ] ; then
	ts_end=$(date -u "+%Y%m%d_%H%M%S")
fi

#
# Validate a Timestamp
#
timestamp_validate () {
	ts=${1}
	date=$(echo ${ts} | cut -d _ -f 1)
	time=$(echo ${ts} | cut -s -d _ -f 2)
	if [ ! ${date} ]; then
		return 0
	fi
	if [ ! ${time} ]; then
		time="000000"
	fi

	### Validate Date
	date_year=$(echo ${date} | cut -c 1-4)
	date_month=$(echo ${date} | cut -c 5-6)
	date_day=$(echo ${date} | cut -c 7-8)

	# Validate Year
	if [ ! ${date_year} ]; then
		return 0
	fi
	if [ ${date_year} -lt 1970 ]; then
		return 0
	fi
	if [ ${date_year} -gt $(date -u "+%Y") ]; then
		return 0
	fi

	# Validate Month
	if [ ! ${date_month} ]; then
		return 0
	fi
	if [ ${date_month} -lt 1 ]; then
		return 0
	fi
	if [ ${date_month} -gt 12 ]; then
		return 0
	fi

	# Validate Day
	if [ ! ${date_day} ]; then
		return 0
	fi
	if [ ${date_day} -lt 0 ]; then
		return 0
	fi
	# TODO: Proper Last Day based on Date
	if [ ${date_day} -gt 31 ]; then
		return 0
	fi

	### Validate Time
	time_hour=$(echo ${time} | cut -c 1-2)
	time_minute=$(echo ${time} | cut -c 3-4)
	time_second=$(echo ${time} | cut -c 5-6)

	# Validate Hour
	if [ ! ${time_hour} ]; then
		return 0
	fi
	if [ ${time_hour} -lt 0 ]; then
		return 0
	fi
	if [ ${time_hour} -gt 23 ]; then
		return 0
	fi

	# Validate Minute
	if [ ! ${time_minute} ]; then
		return 0
	fi
	if [ ${time_minute} -lt 0 ]; then
		return 0
	fi
	if [ ${time_minute} -gt 59 ]; then
		return 0
	fi

	# Validate Second
	if [ ! ${time_second} ]; then
		return 0
	fi
	if [ ${time_second} -lt 0 ]; then
		return 0
	fi
	# TODO: Proper Leap Second based on Date
	if [ ${time_second} -gt 61 ]; then
		return 0
	fi

	### Everything looks valid
	return 1
}

timestamp_validate ${ts_beg}
if [ $? -eq 0 ]; then
	echo "You must enter a valid beginning timestamp!"
	output_syntax
	exit 0
fi
timestamp_validate ${ts_end}
if [ $? -eq 0 ]; then
	echo "If you enter an ending timestamp it must be valid!"
	output_syntax
	exit 0
fi

### Validate ts_end > ts_beg
ts_beg_date=$(echo ${ts_beg} | cut -d _ -f 1)
ts_beg_time=$(echo ${ts_beg} | cut -s -d _ -f 2)
if [ ! ${ts_beg_time} ]; then
	ts_beg_time="000000"
fi
ts_end_date=$(echo ${ts_end} | cut -d _ -f 1)
ts_end_time=$(echo ${ts_end} | cut -s -d _ -f 2)
if [ ! ${ts_end_time} ]; then
	ts_end_time="000000"
fi

if [ ${ts_beg_date} -gt ${ts_end_date} ]; then
	echo "Start time must be before ending time!"
	output_syntax
	exit 0
fi
if [ ${ts_beg_date} -eq ${ts_end_date} ]; then
	if [ ${ts_beg_time} -gt ${ts_end_time} ]; then
		echo "Start time must be before ending time!"
		output_syntax
		exit 0
	fi
fi


### Prepare symbolic links for video generation...
### TODO: Ensure the camera and date directories exist?
echo "Generating timelapse for ${camera} ${ts_beg}-${ts_end}."
IFS='
'
files=$(find "${home}/${camera}/" -type f -name '*.jpg' -print | sort)
seq=0
tmp_dir=$(mktemp -d /tmp/tl-gen.XXXXXXXXXX)
if [ ! $? ] ; then
	echo "Unable to create temporary direcroy! Aborting."
	exit 0
fi
for file in ${files} ; do
	ts=$(basename "${file}" | cut -d . -f 1)
	ts_date=$(echo ${ts} | cut -d _ -f 1)
	ts_time=$(echo ${ts} | cut -s -d _ -f 2)
	if [ ${ts_date} -eq ${ts_beg_date} ]; then
		if [ ${ts_time} -ge ${ts_beg_time} ]; then
			ln -s "${file}" "${tmp_dir}/$(printf %05d ${seq}).jpg"
			seq=$((${seq}+1))
		fi
		if [ ${ts_date} -eq ${ts_end_date} ]; then
			if [ ${ts_time} -gt ${ts_end_time} ]; then
				break;
			fi
		fi
	fi
	if [ ${ts_date} -gt ${ts_beg_date} ]; then
		if [ ${ts_date} -gt ${ts_end_date} ]; then
			break
		fi
		if [ ${ts_date} -eq ${ts_end_date} ]; then
			if [ ${ts_time} -gt ${ts_end_time} ]; then
				break
			fi
		fi
		ln -s "${file}" "${tmp_dir}/$(printf %05d ${seq}).jpg"
		seq=$((${seq}+1))
	fi
done

### G-Streamer Invocation
#gst-launch-1.0 multifilesrc location="${tmp_dir}/%05d.jpg" index=0 caps="image/jpeg,framerate=24/1" ! jpegdec ! omxh264enc ! mp4mux faststart=TRUE faststart-file="${tmp_dir}/tmp.mp4" ! filesink location="${home}/${camera}/${date_year}/${date_month}/${date_day}/${camera}-${date_year}${date_month}${date_day} ${time_beg}-${time_end}.mp4"
gst-launch-1.0 multifilesrc location="${tmp_dir}/%05d.jpg" index=0 caps="image/jpeg,framerate=24/1" ! jpegdec ! x264enc quantizer=20 ! mp4mux faststart=TRUE faststart-file="${tmp_dir}/tmp.mp4" ! filesink location="${output}"
rm -rf "${tmp_dir}"
exit 1
