--[[ These are Libs that are used in every project --]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

-- This is used to make calling playdate lib functions less verbose
local gfx <const> = playdate.graphics
local sfx <const> = playdate.sound

-- All local variables to access anywhere
-- We might consider taking an object orientated approach to structuring our code
-- i.e Player class with handle button press method, etc
-- I would like to try and write it all in a procedural manner, but it could get messy.
-- Hopefully we can keep the game scope down enough to keep it clean. -JL

-- TODO: Make a Car player sprite
local playerSprite = nil

-- TODO: sprite initilization for other objects go below

-- Placeholder for speed
local playerSpeed = 4
local speedModifier = 0
local speedWithModifier = 0

-- This was in example code, we might still use it.
local playTimer = nil
local playTime = 30 * 1000

-- Dont know if we are doing score but its here
local score = 0

local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local tacoBellDong = playdate.sound.sampleplayer.new("sounds/tacoBell.wav")

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	-- Loads image of sprite and sets that to Sprite object
	local playerImage = gfx.image.new("images/player")
	playerSprite = gfx.sprite.new(playerImage)
	-- default location
	playerSprite:moveTo(200, 120)
	-- set collider
	playerSprite:setCollideRect(0, 0, playerSprite:getSize())
	-- actually put it into the game
	playerSprite:add()

	-- Background Image init
	local backgroundImage = gfx.image.new("images/background")
	-- jl / Look into
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0, 0)
			gfx.clearClipRect()
		end
	)
	

	resetTimer()
end
-- Need to have function that handles background image changing

-- Need to have function(s) for spawning objects onto play field
-- Every object should handle its interactions with the player itself
-- Every object should handle its own movement

initialize()

-- This function is called 30 times a second and is where the main game logic takes place
function playdate.update()
	-- Time is up!
	-- End game handling should be done in another function as well
	if playTimer.value == 0 then
		-- Press A, restarts screen 
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
		speedWithModifier = playerSpeed + speedModifier

		-- This should be abstracted to a handlerPlayerMovement function
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			playerSprite:moveBy(0, -playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			playerSprite:moveBy(speedWithModifier, 0)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			playerSprite:moveBy(0, playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			playerSprite:moveBy(-speedWithModifier, 0)
		end

		--local collisions = nil --coinSprite:overlappingSprites() this is what one type of collision call looks like. -JL
		--if #collisions >= 1 then
			
		--end
	end

	playdate.timer.updateTimers()
	-- Look into exactly what this call does
	gfx.sprite.update()

	-- 3 args, text, x, y
	-- We should abstract UI updates to another function as well
	gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 5, 5)
	gfx.drawText("Score: " .. score, 320, 5)
	-- this'll be used for fine tuning my shit
	gfx.drawText("speed: " .. speedWithModifier , 5 , 30)
end