-- CONFIGURATION

-- # of frames to use for FPS calculation
--  Lower = more responsive but less accurate
-- Higher = less responsive but more accurate
-- A good value is 60
track_l	= 60;

-- # of frames to use when determining the maximimum/minimum graphs
--  Lower = less useful
-- Higher = less efficient, but more interesting
-- A good value is 300
track_m	= 300;



-- ######################################################################### --
-- #                                                                       # --
-- # Don't fuck with shit below this line unless you know wtf you're doing # --
-- #                                                                       # --
-- ######################################################################### --




require "x_functions";

if not x_requires then
	-- Sanity check. If they require a newer version, let them know.
	timer	= 1;
	while (true) do
		timer = timer + 1;
		for i = 0, 32 do
			gui.drawbox( 6, 28 + i, 250, 92 - i, "#000000");
		end;
		gui.text( 10, 32, string.format("This Lua script requires the x_functions library."));
		gui.text( 53, 42, string.format("It appears you do not have it."));
		gui.text( 39, 58, "Please get the x_functions library at");
		gui.text( 14, 69, "http://xkeeper.shacknet.nu/");
		gui.text(114, 78, "emu/nes/lua/x_functions.lua");

		warningboxcolor	= string.format("%02X", math.floor(math.abs(30 - math.fmod(timer, 60)) / 30 * 0xFF));
		gui.drawbox(7, 29, 249, 91, "#ff" .. warningboxcolor .. warningboxcolor);

		FCEU.frameadvance();
	end;

else
	x_requires(4);
end;

require 'ul_time';


function findminfps(c)
	ret	= 99999;
	for i = c - track_m, c do
		if track_f[i] then
			oldret	= ret;
			ret	= math.min(track_f[i], ret);
			if ret ~= oldret then
				ret2	= i;
			end;
		end;
	end;
	return ret, ret2;
end;
function findmaxfps(c)
	ret	= 0;
	for i = c - track_m, c do
		if track_f[i] then
			oldret	= ret;
			ret	= math.max(track_f[i], ret);
			if ret ~= oldret then
				ret2	= i;
			end;
		end;
	end;
	return ret, ret2;
end;


function drawarrow(p) 

	for i = 0, 2 do
		line(p - i, 183 - i * 2, p - i, 178, "white");
		line(p + i, 183 - i * 2, p + i, 178, "white");
	end;

end;


t1, t2	= time.sec_usec();
last_t	= t1 + t2 / 1000000 - 1;
t		= last_t;
total_t	= 0;
c		= 0;

track_t	= {};
track_f	= {};


point	= 20;
max_t	= 0;
max_f	= 0;
min_t	= 0;
min_f	= 0;

graph	= {};


barsize	= {};
barsize[1]	= {
	maxfps	= 15,
	bgcolor	= "#dd0000",
	}
barsize[2]	= {
	maxfps	= 30,
	bgcolor	= "#aaaa00",
	}
barsize[3]	= {
	maxfps	= 60,
	bgcolor	= "#00aa00",
	}
barsize[4]	= {
	maxfps	= 120,
	bgcolor	= "#008888",
	}
barsize[5]	= {
	maxfps	= 240,
	bgcolor	= "#0000dd",
	}
barsize[6]	= {
	maxfps	= 480,
	bgcolor	= "#dd00dd",
	}
barsize[7]	= {
	maxfps	= 1920,
	bgcolor	= "#888888",
	}

bgcolor	= barsize[1]['bgcolor'];
max_fps	= barsize[1]['maxfps'];

fcntr	= {
	0, 0, 0, 0,
	};


while true do
	last_t	= t;
	t1, t2	= time.sec_usec();
	t		= t1 + t2 / 1000000;

	tx		= t - last_t;

	total_t	= total_t + tx;
	if track_t[c - track_l] then
		total_t	= total_t - track_t[c - track_l];
	end;
	track_t[c]	= tx;


--	text(50, 50, t);

	if c >= track_l then
		tracked_c	= track_l;
	else
		tracked_c	= c;
	end;


	fps			= (tracked_c / total_t);
	track_f[c]	= fps;
	temp		= math.min(4, math.floor(fps / 15) + 1);
	fcntr[temp]	= fcntr[temp] + 1;
	for i = 1, 4 do
		text( 7 + (i - 1) * 60, 20, string.format("%9d", fcntr[i]));
	end;

	
	if max_t > track_m or fps > max_f then
		max_f, max_t	= findmaxfps(c);
		done	= false;
		for i = 1, 7 do
			if barsize[i]['maxfps'] >= math.floor(max_f) and not done then
				max_fps	= barsize[i]['maxfps'];
				bgcolor	= barsize[i]['bgcolor'];
				done	= true;
			end;
		end;
	end;
	if min_t > track_m or fps < min_f then
		min_f, min_t	= findminfps(c);
	end;
	max_t	= max_t	+ 1;
	min_t	= min_t	+ 1;
	graph[c]	= fps;

	point2	= -8 + (fps / max_fps * 240);
--	point	= point2

	point	= point + (point2 - point) * 0.025;

	point	= math.max(15, math.min(207, point));

	text( point - 10, 189, string.format("%5.4fspf", (total_t / tracked_c)));
	text( point - 10, 197, string.format("%6.2ffps", (tracked_c / total_t)));


	line(   5, 184, 245, 184, "black");
	line(   5, 185, 245, 185, bgcolor);
	line(   5, 186, 245, 186, bgcolor);
	line(   5, 187, 245, 187, bgcolor);
	line(   5, 188, 245, 188, "black");
--180
	line(   4,   1,   4, 179, "blue");
	line( 246,   1, 246, 179, "blue");
	line(  65,   1,  65, 179, "blue");
	line( 125,   1, 125, 179, "blue");
	line( 185,   1, 185, 179, "blue");

	line(   4, 180,   4, 190, "white");
	line( 246, 180, 246, 190, "white");
	line(  65, 180,  65, 190, "white");
	line( 125, 180, 125, 190, "white");
	line( 185, 180, 185, 190, "white");

	line(   5, 186,   5 + math.min(240, (fps / max_fps * 240)), 186, "white");


	for i = 0, 183 do
		
		if graph[c - i] then
			p	= 5 + math.min(240, (graph[c - i] / max_fps * 240));
			pixel(p, 183 - i, "white");
		else
			pixel(0, 183 - i, "clear");
		end;
	end;



	max_p	= 5 + math.min(240, (max_f / max_fps * 240));
	min_p	= 5 + math.min(240, (min_f / max_fps * 240));
--	cur_p	= 5 + math.min(240, (1 / tx / max_fps * 240));

--	text(5, 10, string.format("%6.6f, %6.6f, %6.6f", min_f, max_f, tx));

--	line(max_p, 183, max_p, 188, "white");
--	line(min_p, 183, min_p, 188, "white");

	drawarrow(min_p);
	drawarrow(max_p);
--	drawarrow(cur_p);

	
	c		= c + 1;
	FCEU.frameadvance();


	track_t[c - track_m]	= nil;
	track_f[c - track_m]	= nil;
	graph[c - track_m]	= nil;

end;
