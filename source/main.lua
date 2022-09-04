--[[ These are Libs that are used in every project --]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "obstacles"

-- 										##### GLOBALS #####
-- This is used to make calling playdate lib functions less verbose
local gfx <const> = playdate.graphics
local sfx <const> = playdate.sound
local geo <const> = playdate.geometry

-- consts for screen height and width at 1x display scale
local SCREENHEIGHT <const> = playdate.display.getHeight()
local SCREENWIDTH <const> = playdate.display.getWidth()

local speedModifier = 0

player = { sprite = nil, speed = 4, modifiedSpeed = 0, timer = nil, health = 30000 }

-- globals cause lazy
bgImg1 = gfx.image.new('images/lexiBG1.png')
bg1 = gfx.sprite.new(bgImg1)
offscreenGoalPointX = -400

local bgImg2 = gfx.image.new('images/lexiBG2.png')
local bg2 = gfx.sprite.new(bgImg2)
leftSideGoalPointX = 0
-- start without background scrolling
g_backgroundScrolling = false

-- This was in example code, we might still use it.
-- local playTimer = nil
-- local playTime = 30 * 1000
-- local function resetTimer()
-- 	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
-- end

-- Dont know if we are doing score but its here
local score = 0
-- 										#### END GLOBALS #####

local function initPlayer()
	player.health = 3
	math.randomseed(playdate.getSecondsSinceEpoch())
	-- Loads image of sprite and sets that to Sprite object
	local playerImage = gfx.image.new("images/player")
	player.sprite = gfx.sprite.new(playerImage)
	player.sprite:setGroups(1)
	-- default location
	player.sprite:moveTo(200, 120)
	-- set collider
	player.sprite:setCollideRect(0, 0, player.sprite:getSize())
	-- actually put it into the game
	player.sprite:add()
	player.sprite:setZIndex(50)

	-- gfx.sprite.setBackgroundDrawingCallback(
	-- 	function(x, y, width, height)
	-- 		-- x,y,width,height is the updated area in sprite-local coordinates
	-- 		-- The clip rect is already set to this area, so we don't need to set it ourselves
	-- 		bg1:draw(0, 0)
	-- 	end
	-- )
end

-- -- Initilize and draw to screen all UI/HUD elements, including screen safe zone so player cant drive over the HUD
local function initHUD()

end

-- Initilize the background, starting decorations, start timer to first object spawn
-- This will be used as our reset game function as well
local rightSpawnerTimer = nil
local bottomSpawnerTimer = nil
function initGameState()
	-- background image init
	local function rightObjectTimerCallback()
		print("R timer callback fired~!")
		-- object is now added to game offscreen
		local obs = spawnObjectRight()
		print("Spawned right object " .. obs.name .. " at " .. obs.x .. "," .. obs.y)
	end

	local function bottomObjectTimerCallback()
		print("B timer callback fired~!")
		-- object is now added to game offscreen
		local obs = spawnObjectBottom()
		print("Spawned bottom object " .. obs.name .. " at " .. obs.x .. "," .. obs.y)
	end

	-- start timer for spawning objects into gamefield
	-- TODO: need to make the timing more dynamic, this will spawn at a constant rate, LAME
	-- Callback function used by obstacle timer to handle spawning and adding obstacles to array
	local delayTimeInital = math.random(800, 1100) -- 800 ms to 1.1 s
	local delayTimeSecondary = math.random(800, 1100) -- 800 ms to 1.1 s
	rightSpawnerTimer = playdate.timer.keyRepeatTimerWithDelay(delayTimeInital, delayTimeSecondary, rightObjectTimerCallback)
	bottomSpawnerTimer = playdate.timer.keyRepeatTimerWithDelay(delayTimeInital, delayTimeSecondary,
		bottomObjectTimerCallback)
end

-- NEXT: Define screen safe zone for player and obstacles
-- NEXT: define UI elements and update system for syncing player health to icons
-- NEXT: define timer system and system to link to setting sun animation
-- 		 |-> define how we can keep the time going
-- NEXT:

function loadBackground()
	-- set center points for each BG at the far left side in the center (0,0.5)
	-- centers are defined as a franction of the width and height, see playdate docs
	-- bg1 will be drawn filly on screen so center at (0,120)
	-- bg2 will be drawn offscreen at the "back" of bg1, so (400,120)
	-- bg1 will move off screen toward a position where it will be fully offscreen
	-- <- bg1 starts at (0,120) moves towards (-400,120) jl/ hopefully it works like this
	-- <- bg2 starts at (400, 120) moves towards (0,120)
	bg1:setCenter(0,0.5)
	bg2:setCenter(0,0.5)
	bg1:moveTo(0,120)
	bg2:moveTo(400,120)
	bg1:setZIndex(-50)
	bg2:setZIndex(-50)
	bg1:add()
	bg2:add()
	-- bg sprites are now added to screen, we need another function to start/stop scrolling
	-- when the game ends we need to stop the background
end

-- turn background scrolling on or off
-- takes a bool true to start, false to stop
function startBackgroundScrolling(scrolling)
	-- NOTE: eventually this will also turn the animation for background on and off too
	-- turn on scrolling
	if scrolling and not g_backgroundScrolling then
		print("Starting BG scrolling")
		g_backgroundScrolling = true
	-- turn off scrolling
	elseif not scrolling and g_backgroundScrolling then
		-- jl/ hope this works
		g_backgroundScrolling = false
		print("stopping BG scrolling")		
	end
end

-- check backgrounds and see if they have reached their goal points
-- when they have reset to new positions
function bgPositionCheck()
	if bg1.x <= offscreenGoalPointX then
		print("Moving BG1 to 400,120")
		-- move it back to right side to continue scrolling
		bg1:moveTo(400,120)
	end
	if bg2.x <= offscreenGoalPointX then
		print("Moving BG2 to 400,120")
		-- move it back to right side to continue scrolling
		bg2:moveTo(400,120)
	end
end

-- Game init (british accent)
initPlayer()
-- initHUD()
initGameState()
loadBackground()
-- start scrolling on game init
startBackgroundScrolling(true)

gameOverText = ""


-- This function is called 30 times a second and is where the main game logic takes place
function playdate.update()
	-- DEBUG:
	print("ONLY BG1 LOADED")
	print("Background scrolling: ".. tostring(g_backgroundScrolling))
	print("BG1 X pos: ".. bg1.x)
	-- END DEBUG
	-- will be handling crank stuff up here since the speed values affect everything more or less
	-- the .0x is just to make the speedramp up less while still being finely tunable
	-- -2 is minimum modifier 8 is maximum
	if g_backgroundScrolling then
		bg1:moveBy(-2,0)
		bg2:moveBy(-2,0)
		bgPositionCheck()
	elseif not g_backgroundScrolling then
		bg1:moveBy(0,0)
		bg2:moveBy(0,0)
	end
	-- PLACEHOLDER: finish end state handling, the game over text is a super hack for now
	if player.health == 0 then
		gameOverText = "GAME OVER \nPress A"
		rightSpawnerTimer:remove()
		bottomSpawnerTimer:remove()
		-- stop background scrolling
		startBackgroundScrolling(false)
		if playdate.buttonJustPressed(playdate.kButtonA) then
			player.sprite:remove()
			gameOverText = ""
			initPlayer()
			initGameState()
			startBackgroundScrolling(true)
		end
	else
		speedModifier += playdate.getCrankTicks(60) * .04
		if speedModifier > 8 then
			speedModifier = 8;
		end
		if speedModifier < -2 then
			speedModifier = -2;
		end
		player.modifiedSpeed = player.speed + speedModifier

		-- This should be abstracted to a handlerPlayerMovement function
		-- should also move the backgroundImage not player
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			player.sprite:moveBy(0, -player.speed)
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			player.sprite:moveBy(player.modifiedSpeed, 0)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			player.sprite:moveBy(0, player.speed)
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			player.sprite:moveBy(-player.modifiedSpeed, 0)
		end

		gfx.sprite.update()

		-- 3 args, text, x, y
		-- this'll be used for fine tuning my shit
		-- gfx.drawText("speed: " .. player.modifiedSpeed, 5, 30)

	end
	playdate.timer.updateTimers()
	-- TODO: fix this hack
	gfx.drawText(gameOverText, 180, 120)
end
