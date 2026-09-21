-- mesen toolkit
-- for when you resent mesen't
--
-- fceux has a nice "give me every fucking button that's pushed" thing (input.get),
-- but mesen only has "hey is this key held down"
-- not a big fan of this one!!!
--
-- 


-- man this is all gonna be worthless huh. damn.

-- [working ...]
-- emu.isKeyPressed(keyName)
-- Returns whether or not a specific key is pressed. The "keyName" must be the same as the string shown in the UI when the key is bound to a button.
-- notably not included: a list of these to review instead of having to push them all
-- notably also not included: does it work with any key pressed or just keyboard keys, e.g. controllers
-- i love finding things out
-- hey guys
-- there's this cool thing ont he internet now that youre an open sourec project
-- its called Github Issues
-- thank's.

local tools	= {}
local CACHE_BUSTERS = -1 -- who u gonna call
local keyCachePrev = {}
local keyCacheThis = {}
local keysWeCareAbout = {}
local keysWeDoNotCareAbout = { leftclick = true, middleclick = true, rightclick = true }

tools.frame = 0
tools.mouse = {}

-- either get the cached version if we have it
-- or cache it and then get it. or get it and then cache it.
-- one of those.
-- just get me cache. i mean, cash.
local function isKeyPressed(keyName) 
	if keysWeCareAbout[keyName] or keysWeDoNotCareAbout[keyName] then
		return keyCacheThis[keyName]
	end
	keysWeCareAbout[keyName]	= true
	keyCacheThis[keyName] = emu.isKeyPressed(keyName)
	return keyCacheThis[keyName]
end


local function bustin_makes_me_feel_good()
	-- call this whenever the fuck you feel like it. call it tomorrow. call it yesterday. call it instead of your mother. see if i care
	CACHE_BUSTERS = CACHE_BUSTERS + 1
	keyCachePrev = keyCacheThis
	keyCacheThis = {}
	for k in pairs(keysWeCareAbout) do
		-- "doesnt this just grow every time you check more keys"
		-- yes
		-- does it matter theres only like 200 of them thats less than the emu.getState
		-- you arent gonna care. if you do fuck you.
		keyCacheThis[k]	= emu.isKeyPressed(k)
	end

	-- you might ask, ok, but why this, then.
	-- same reason as being able to detect single presses
	-- and having some delta of movement.
	tools.mouse = emu.getMouseState()
	-- Table - { x = int, y = int, relativeX = int, relativeY = int, left = bool, middle = bool, right = bool } 
	keyCacheThis.leftclick		= tools.mouse.left
	keyCacheThis.middleclick	= tools.mouse.middle
	keyCacheThis.rightclick		= tools.mouse.right
end

-- because mesen does not have anything convenient like "a frame counter"
-- or maybe "access to registers that doesn't give you a 500 entry table",
-- (DEEP INHALING SIGH)
emu.addEventCallback(bustin_makes_me_feel_good, emu.eventType.inputPolled)


local function frame_counter()
	tools.frame = tools.frame + 1
end
emu.addEventCallback(frame_counter, emu.eventType.endFrame)

local function reset_frame_counter()
	tools.frame = 0
end
emu.addEventCallback(frame_counter, emu.eventType.reset)
emu.addEventCallback(frame_counter, emu.eventType.stateLoaded)



-- input tracking functions...
-- held: previous frame + this frame
-- pressed: only this frame
-- released: only last frame
-- these only "work" if you check them every frame.
-- eventually i could just, hm

-- check if the key is actually held right now
function tools.keyPressed(keyName)
	-- easiest case, just check if it is.
	return isKeyPressed(keyName)
end

-- if the key was held both this and the previous frame
function tools.keyHeld(keyName)
	return keyCachePrev[keyName] and isKeyPressed(keyName)
end

-- held previous and now no longer
function tools.keyReleased(keyName)
	return keyCachePrev[keyName] and not isKeyPressed(keyName)
end



return tools