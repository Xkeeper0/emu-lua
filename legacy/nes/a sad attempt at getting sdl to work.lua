------------------------------------------------------------------------
--
-- luasdl.lua
-- Currently for testing purposes.
--
-- This file is part of LuaSDL.
--
-- PUBLIC DOMAIN. Author: Kein-Hong Man <khman@users.sf.net> 2007
--
------------------------------------------------------------------------

------------------------------------------------------------------------
-- NOTE: currently contains a lot of test code
-- TODO: * from list... ok, err =  xpcall(f2, debug.traceback)
--       * wrap caller and allow return to an SDL screen with messages
------------------------------------------------------------------------

-- local ref to SDL library
require("SDL");

local SDL = SDL


-- test initialization of SDL
if SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING) < 0 then
  error("Couldn't initialize SDL: "..SDL.SDL_GetError().."\n")
  os.exit(1)
end

SDL.SDL_WM_SetCaption(SDL.LuaSDL_Version, SDL.LuaSDL_Version)

------------------------------------------------------------------------

local option
local screen = SDL.SDL_SetVideoMode(640, 480, 32, 0)
if not screen then
  error("Couldn't set video mode: "..SDL.SDL_GetError().."\n")
end

  -- clear to grey
local info = SDL.SDL_GetVideoInfo()
local rect = SDL.SDL_Rect_local()
rect.x, rect.y = 0, 0
rect.w, rect.h = info.current_w, info.current_h
local grey = SDL.SDL_MapRGB(screen.format, 0x80, 0x80, 0x80)
SDL.SDL_FillRect(screen, rect, grey)
  -- update screen later...


  local spray = function()
    -- draw some pixels
    if SDL.SDL_MUSTLOCK(screen) ~= 0 then
      if SDL.SDL_LockSurface(screen) < 0 then
        error("Can't lock screen: "..SDL.SDL_GetError().."\n")
      end
    end
    for i = 1, 1000 do
      local c = SDL.SDL_MapRGB(screen.format, math.random(0, 255),
                               math.random(0, 255), math.random(0, 255))
      local x = math.random(0, screen.w-1)
      local y = math.random(0, screen.h-1)
      SDL.SDL_PutPixel(screen, x, y, c)
    end
    if SDL.SDL_MUSTLOCK(screen) ~= 0 then
      SDL.SDL_UnlockSurface(screen)
    end
  end
--]=]

  -- display screen and event loop
  SDL.SDL_UpdateRect(screen, 0, 0, 0, 0)
  local event = SDL.SDL_Event_local()
  while true do
    while (SDL.SDL_PollEvent(event) == 0) do
		FCEU.frameadvance();
    end
    local c = event.type
    if c == SDL.SDL_KEYDOWN then
      local key = event.key.keysym.sym
      if key == SDL.SDLK_ESCAPE then
        break
      elseif demo_list[key] then
        option = demo_list[key]
        break
      elseif key == SDL.SDLK_0 then
        spray()
        SDL.SDL_UpdateRect(screen, 0, 0, 0, 0)
      end
    elseif c == SDL.SDL_QUIT then
      break
    end--if c
  end--while

  -- timer test
-- [=[
  if c_handle then
    SDL.SDL_RemoveTimer(c_handle)
  end
--]=]


------------------------------------------------------------------------

SDL.SDL_Quit()
-- end of default script
