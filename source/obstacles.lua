--                                      ##### GLOBALS #####

-- This is used to make calling playdate lib functions less verbose
-- Remember local means local to this file, can't use these consts in main.lua
local gfx <const> = playdate.graphics
local sfx <const> = playdate.sound
local geo <const> = playdate.geometry

local SCREENHEIGHT <const> = playdate.display.getHeight()
local SCREENWIDTH <const> = playdate.display.getWidth()

local BSPAWN_START <const> = SCREENWIDTH - 200 -- center of screen
local BSPAWN_END <const> = SCREENWIDTH

-- Lanes ordered top to bottom with Lane 1 being the closest to the screen top
-- TODO: adjust positions when play area is finalized
local RSPAWN_LANE1 <const> = 60
local RSPAWN_LANE2 <const> = 120
local RSPAWN_LANE3 <const> = 180

local LANES = {RSPAWN_LANE1,RSPAWN_LANE2,RSPAWN_LANE3}

-- PLACEHOLDER: update art assets when complete
phObstacleImage = gfx.image.new("images/coin")
-- NOTE: Same image but have to have different sprites, multiples of the same obstacle will have to have unique sprites
-- associated with them, I'll figure out that handling later
phObs1Sprite = gfx.sprite.new(phObstacleImage)
phObs2Sprite = gfx.sprite.new(phObstacleImage)

-- Each of these tables contains information about each of the different obstacles 
-- Each obstacle will deduct 1 health from the player and despawn the obstacle on hit
-- NOTE: Honestly we might not need to track this info in tables but we can see as development goes on
tumbleweed = {name="tumbleweed",sprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
pothole = {name="pothole",sprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
-- vertical flip will determine if the cactus image sprite is pointing up or down on the road
cactus = {name="cactus",sprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil,verticalFlip=0}
ramp = {name="ramp",sprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
roadkill = {name="roadkill",sprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
-- style determines which image sprite to use for different types of cars on the road
car = {name="car",sprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil,style=0}

tumbleweed.sprite = phObs1Sprite
pothole.sprite = phObs2Sprite

-- TODO: sprite initilization for other objects go below (decorations, etc)

--                                           ##### END GLOBALS #####

-- function that will remove obstacle.sprite from the drawing stack and other tasks
-- e.g if the object despawns without being hit by player, increase their score, etc.
function despawnObstacle(obstacle)
    print("removing obstacle")
    obstacle.sprite:remove()
end

function spawnObjectRight()
    spawnLane = LANES[math.random( #LANES )] -- pick a random lane from our 3 lanes
    pothole.sprite:moveTo(SCREENWIDTH + 30, spawnLane) -- 30 pixels off screen right
    pothole.sprite:add()
    return pothole
end

function spawnObjectBottom()
    local randX = math.random(BSPAWN_START, BSPAWN_END)
    tumbleweed.sprite:moveTo(randX, SCREENHEIGHT + 30) -- 30 pixels below screen
    tumbleweed.sprite:add()
    return tumbleweed
end

-- 