<?php
	error_reporting(0);
	$dir_root = '/mnt/cam.aprsworld.com'; // TODO: Use relative dir

	// Headers
	// header('Content-Type:	application/json');  // IE6 dies horribly with this...
	header('Content-Type:	text/plain');

	// Inputs
	$camera = $_REQUEST['camera'];
	$date_s = $_REQUEST['date'];
	$date = split('-', $date_s);

	// Constants
	$dir_s = $dir_root . '/' . $camera . '/';
	$num_days = cal_days_in_month(CAL_GREGORIAN, $date[1], $date[0]);

	// Sanity
	if (!$camera || !$num_days || !is_dir($dir_s) || fileperms($dir_s) & 0004 != 0004) {
		echo '{ "error": "Invalid Parameters" }';
		return 0;
	}

	// Values
	$struct = Array();
	$images_total = 0;

	// Do the dead - Necrophilia is hawt
	$dir = dir($dir_s . $date[0] . '/' . $date[1]);
	if ($dir) {
		while ($day = $dir->read()) {
			if ($day > 0 && $day < $num_days) {
				// Constants
				$dir_day = dir($dir_root . '/' . $camera . '/' . $date[0] . '/' . $date[1] . '/' . $day);
				// Values
				$images_num = 0;
				$images = null;

				// Recurse
				if ($dir_day) {
					$images = Array();
					while ($day_file = $dir_day->read()) {
						if (preg_match('((([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9]))_(([0-9][0-9])([0-9][0-9])([0-9][0-9])).jpg)', $day_file)) {
							$images[$images_num] = $day_file;
							$images_num++;
						}
					}
					sort($images);
					$dir_day->close();
				}

				// Update Return Structure
				$struct[$date_s . '-' . $day] = Array(
						'count' => $images_num,
						'images' => $images
				);
				$images_total += $images_num;
			}
		}
		$dir->close();
	}

	// Update Return Structure
	$struct[$date_s] = Array('count' => $images_total);
	ksort($struct);

	// Return Results
	echo json_encode($struct, JSON_PRETTY_PRINT);
?>
