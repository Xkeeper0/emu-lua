<?php

	$datain			= trim(file_get_contents("machriderspeed.xrp"));
	$dataarray		= explode("\n", $datain);

	$len			= count($dataarray);

	$image			= imagecreate($len, 500);
	$col['bg']		= imagecolorallocate($image,   0,   0,   0);
	$col['line']	= imagecolorallocate($image,  38,  78, 128);
//	$col['line']	= imagecolorallocate($image,  38,  78, 128);
	$col['gear0']	= imagecolorallocate($image,  38,  68, 148);
	$col['gear1']	= imagecolorallocate($image,  58, 108, 175);
	$col['gear2']	= imagecolorallocate($image,  78, 138, 215);
	$col['gear3']	= imagecolorallocate($image,  98, 155, 255);

	for ($y = 0; $y < 500; $y+= 50) {
		imageline($image, 0, $y, $len, $y, $col['line']);
	}

	for ($x = 0; $x < $len; $x+= 60) {
		imageline($image, $x, 0, $x, 500, $col['line']);
	}

	foreach($dataarray as $value) {
		$value	= explode(":", $value);
		$x		= $value[0];
		$y		= $value[1];
		$gear	= "gear". trim($value[2]);

//		print $gear ."<br>";
		imageline($image, $x, 499 - $y, $x, 499, $col[$gear]);
	}

	header("Content-type: image/png");
	imagepng($image);
	imagedestroy($image);

