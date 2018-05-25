<?php
	error_reporting(0);
	$dir_root = "/home/jjeffers/cam.aprsworld.com";

	$camera = $_REQUEST['camera'];
	$date = split("-", $_REQUEST['date'], 2);

	$num_days = cal_days_in_month(CAL_GREGORIAN, $date[1], $date[0]);
	$images = array_fill(0, $num_days, 0);


	$dir = dir($dir_root . "/" . $camera . "/" . $date[0] . "/" . $date[1]);
	if ($dir) {
		while ($day = $dir->read()) {
			if ($day > 0 && $day < 32) {
				$dir_day = dir($dir_root . "/" . $camera . "/" . $date[0] . "/" . $date[1] . "/" . $day);
				if ($dir_day) {
					$images_num = 0;
					while ($day_file = $dir_day->read()) {
						if (preg_match("((([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9]))_(([0-9][0-9])([0-9][0-9])([0-9][0-9])).jpg)", $day_file)) {
							$images_num++;
						}
					}
					$dir_day->close();

					$images[$day] = $images_num;
				}
			}
		}
		$dir->close();
	}

	$ret = array(	"camera" => $camera,
			"date" => $date[0] . "-" . $date[1],
			"images" => $images);
	echo json_encode($ret);
?>
