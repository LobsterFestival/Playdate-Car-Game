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
player = { sprite = nil, speed = 4, modifiedSpeed = 0, timer = nil, health = 3 }

-- This was in example code, we might still use it.
local playTimer = nil
local playTime = 30 * 1000

-- Dont know if we are doing score but its here
local score = 0

-- 										#### END GLOBALS #####

obstaclesOnScreen = {}

local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function initPlayer()
	math.randomseed(playdate.getSecondsSinceEpoch())
	-- Loads image of sprite and sets that to Sprite object
	local playerImage = gfx.image.new("images/player")
	player.sprite = gfx.sprite.new(playerImage)
	-- default location
	player.sprite:moveTo(200, 120)
	-- set collider
	player.sprite:setCollideRect(0, 0, player.sprite:getSize())
	-- actually put it into the game
	player.sprite:add()
	resetTimer()
end

-- Initilize and draw to screen all UI/HUD elements, including screen safe zone so player cant drive over the HUD
local function initHUD()

end

-- Initilize the background, starting decorations, start timer to first object spawn
-- This will be used as our reset game function as well
local rightSpawnerTimer = nil
local bottomSpawnerTimer = nil
function initGameState()
	-- background image init
	-- decorations init

	-- start timer for spawning objects into gamefield
	-- TODO: need to make the timing more dynamic, this will spawn at a constant rate, LAME
	-- Callback function used by obstacle timer to handle spawning and adding obstacles to array
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
		print("Spawned bottom object " .. obs.name.. " at " .. obs.x .. "," .. obs.y)
	end

	local delayTimeInital = math.random(800, 1100) -- 1.5 - 3 seconds
	local delayTimeSecondary = math.random(800, 1100) -- 1.5 - 4 seconds
	rightSpawnerTimer = playdate.timer.keyRepeatTimerWithDelay(delayTimeInital, delayTimeSecondary, rightObjectTimerCallback)
	bottomSpawnerTimer = playdate.timer.keyRepeatTimerWithDelay(delayTimeInital, delayTimeSecondary, bottomObjectTimerCallback)

end

-- TODO: Need to have function that handles background image changing

-- Game init (british accent)
initPlayer()
initHUD()
initGameState()

-- This function is called 30 times a second and is where the main game logic takes place
function playdate.update()
	-- Time is up!
	-- End game handling should be done in another function as well
	if playTimer.value == 0 then
		-- Press A, restarts game
		-- TODO: obvs update for out own reset stuff
		if playdate.buttonJustPressed(playdate.kButtonA) then
			resetTimer()
			score = 0
		end
		-- Main Game Loop, player movement and coin pick up
	else
		--will be handling crank stuff up here since the speed values affect everything more or less
		-- the .0x is just to make the speedramp up less while still being finely tunable
		-- -2 is minimum modifier 8 is maximum
		speedModifier += playdate.getCrankTicks(60) * .04
		if speedModifier > 8 then
			speedModifier = 8;
		end
		if speedModifier < -2 then
			speedModifier = -2;
		end
		player.modifiedSpeed = player.speed + speedModifier

		-- This should be abstracted to a handlerPlayerMovement function
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
		-- Crank handling goes here
	end


	gfx.sprite.update()
	playdate.timer.updateTimers()
	-- Look into exactly what this call does


	-- 3 args, text, x, y
	-- We should abstract UI updates to another function as well
	gfx.drawText("Time: " .. math.ceil(playTimer.value / 1000), 5, 5)
	gfx.drawText("Score: " .. score, 320, 5)
	-- this'll be used for fine tuning my shit
	gfx.drawText("speed: " .. player.modifiedSpeed, 5, 30)
end
