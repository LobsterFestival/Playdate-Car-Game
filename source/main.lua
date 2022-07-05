--[[ These are Libs that are used in every project --]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- This is used to make calling playdate lib functions less verbose
local gfx <const> = playdate.graphics
local sfx <const> = playdate.sound

-- ##### GLOBALS #####
-- Lets try using just tables for everything in true Lua fashion
-- TODO: Make a Car player sprite

player = {sprite = nil, speed = 4, timer = nil, health = 3}

-- This was in example code, we might still use it.
local playTimer = nil
local playTime = 30 * 1000

-- Dont know if we are doing score but its here
local score = 0

-- #### END GLOBALS ##### 

local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local tacoBellDong = playdate.sound.sampleplayer.new("sounds/tacoBell.wav")

local function initialize()
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

	-- Background Image init
	local backgroundImage1 = gfx.image.new("images/bg1")
	local backgroundImage2 = gfx.image.new("images/bg2")
	-- jl / Look into
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage1:draw(0, 0)
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
		-- This should be abstracted to a handlerPlayerMovement function
		if playdate.buttonIsPressed(playdate.kButtonUp) then
			player.sprite:moveBy(0, -player.speed)
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			player.sprite:moveBy(player.speed, 0)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			player.sprite:moveBy(0, player.speed)
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			player.sprite:moveBy(-player.speed, 0)
		end
		-- Crank handling goes here
	end

	playdate.timer.updateTimers()
	-- Look into exactly what this call does
	gfx.sprite.update()

	-- 3 args, text, x, y
	-- We should abstract UI updates to another function as well
	gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 5, 5)
	gfx.drawText("Score: " .. score, 320, 5)
end