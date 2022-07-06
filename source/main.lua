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
player = {sprite = nil, speed = 4, modifiedSpeed = 0, timer = nil, health = 3}

-- This was in example code, we might still use it.
local playTimer = nil
local playTime = 30 * 1000

-- Dont know if we are doing score but its here
local score = 0

-- 										#### END GLOBALS #####

-- TODO: seeded with value to prevent nil check, correct logic
obstaclesOnScreen = {tumbleweed}

-- Callback function used by obstacle timer to handle spawning and adding obstacles to array
function rightObjectTimerCallback()
	local obs = getRandomRightSpawningObject()
	obstaclesOnScreen[#obstaclesOnScreen+1] = obs
	-- object is now added to game offscreen
	spawnObjectRight(obs)
end

function bottomObjectTimerCallback()
	local obs = getRandomBottomSpawningObject()
	obstaclesOnScreen[#obstaclesOnScreen+1] = obs
	-- object is now added to game offscreen
	spawnObjectBottom(obs)
end

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

-- Initilize and draw to screen all UI/HUD elements, including screen safe zone so player cant drive over the HUD
local function initHUD()

end

-- Initilize the background, starting decorations, start timer to first object spawn
-- This will be used as our reset game function as well
local function initGameState()
	-- background image init
	-- decorations init

	-- start timer for spawning objects into gamefield
	-- TODO: need to make the timing more dynamic, this will spawn at a constant rate, LAME
	local delayTimeInital = math.random(1500,3000) -- 1.5 - 3 seconds
	local delayTimeSecondary = math.random(1500,4000) -- 1.5 - 4 seconds
	playdate.timer.keyRepeatTimerWithDelay(delayTimeInital, delayTimeSecondary, rightObjectTimerCallback())
	playdate.timer.keyRepeatTimerWithDelay(delayTimeInital, delayTimeSecondary, bottomObjectTimerCallback())
end

-- TODO: Need to have function that handles background image changing

-- Game init (british accent)
initPlayer()
initHUD()
initGameState()

-- DEBUG: for testing spawn one object and handle its lifecycle globaly
obs = nil
obsBott = nil
-- END DEBUG

-- PLACEHOLDER: until collision detection is worked out
local playerHit = false
-- TODO: look over this handling when its not 1 am :^)
function handleObstacles()
	-- every object spawned get added to obstaclesOnScreen and on despawn is removed
	-- we need a way to stagger spawns of objects, random amount of time between some min and max
	delayTime = math.random(1500, 5000)	
	-- handle each objects checking
	for k, object in pairs(obstaclesOnScreen) do
		-- DEBUG:
		print("Object " .. object.name .. " being handled.")
		print("Object" .. object.name .. " location: " .. object.sprite.x .. "," .. object.sprite.y)

		-- END DEBUG
		-- player collisions
		if playerHit == true then
			-- deduct health from player
			-- despawn object
		else
			-- what kind of object are we dealing with
			if object.location == "right" then
				object.sprite:moveBy(-player.speed, 0) -- toward player at their speed
				if object.sprite.x < 0 then
					despawnObstacle(object)
				end 
			else
				object.sprite:moveBy(-player.speed*0.2, 5) -- sorta drift towards player and up TODO: magic numbers
				if object.sprite.y < 0 then
					despawnObstacle(object)
				end
			end
		end
	end
end



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

	handleObstacles()

	playdate.timer.updateTimers()
	-- Look into exactly what this call does
	gfx.sprite.update()

	-- 3 args, text, x, y
	-- We should abstract UI updates to another function as well
	gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 5, 5)
	gfx.drawText("Score: " .. score, 320, 5)
	-- this'll be used for fine tuning my shit
	gfx.drawText("speed: " .. player.modifiedSpeed , 5 , 30)
end