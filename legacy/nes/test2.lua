
require("auxlib");

function idle_cb()

	offset					= 0x0600 + 0x0020 * 0;
	v	= 0x7FF - (memory.readbyte(offset + 0x06) * 0xFF + memory.readbyte(offset + 0x05));
	a	= math.log10((0x7FF - v) / 0x7FF) * -0x1000;

	gauge.value = a;
	return iup.DEFAULT
end

gauge = iup.gauge{}
gauge.size = "528x20"
gauge.show_text = "NO"
gauge.expand	= "NO";
gauge.max		= 13200;

dlg = iup.dialog{gauge; title = "IupGauge"}
dlg.resize	= "NO";
dlg.maxbox	= "NO";
dlg.minbox	= "NO";
dlg.size	= "800x40";

-- Registers idle callback
-- iup.SetIdle(idle_cb)

dlg:showxy(iup.CENTER, iup.CENTER)

while (true) do

	idle_cb();
	FCEU.frameadvance();
end;
