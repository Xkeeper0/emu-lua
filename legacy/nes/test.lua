

require("x_functions");

local cdlua_open = package.loadlib("cdlua51.dll", "cdlua_open");
cdlua_open();
cdluaiup_open()

cdlua_canvas = cd.CreateCanvas(CD_IUP, iuplua_canvas) 

if cdlua_canvas == nil then 
	-- deal with error 
	gui.popup("uh oh");
else 
	cd.Activate(cdlua_canvas);
end

cd.LineStyle(CD_DASHED); 
cd.Line(0, 0, 100, 100); 

while (true) do
	FCEU.frameadvance();
end;

cd.KillCanvas(cdlua_canvas);
