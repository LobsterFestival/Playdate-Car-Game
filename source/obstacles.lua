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

-- PLACEHOLDER: Fucking playdate doesn't tell you if it failed to load an image, the function
-- will simply return nil, and sprite doesn't complain on loading nil objects...
-- register sprites through this function so if you messed up the path, YOU'LL KNOW!
function loadImageToSpriteHelper(path)
    image = gfx.image.new(path)
    if image == nil then
        print("#### Failed to load image at "..path.." ####")
        return nil
    end
    return image
end

-- Luas way of defining a class structure
local function customClass(base)
    local t = base and setmetatable({}, base) or {}
    t.__index = t -- look up keys in base class if not found in instance
    t.__class = t -- Inherited Class
    t.__base  = base -- Base Class

    function t.new(...)
      local o = setmetatable({}, t)
      if o.__init then
        if t == ... then -- we call as Class:new()
            o:__init(select(2, ...))
            return o
        else             -- we call as Class.new()
            o:__init(...)
            return o
        end
      end
      return o
    end
    return t
end

-- Base Object class
Object = customClass()

-- Tumbleweed class inherited from Object 
Obstacle = customClass(Object)

-- Subclass off of playdates sprite class so we can override update()
-- then when playdat.graphics.sprite.update (notice the . not :) all sprites
-- will call :update(), we can then impliment our own logic in here to run every frame
class('ObsSprite').extends(playdate.graphics.sprite)

-- PLACEHOLDER: until collision detection is worked out
local playerHit = false

function ObsSprite:update()
    print("I'm updating!!")
    print("My speed is: "..self.currentSpeed.." My zone "..self.zone)
    if playerHit == true then
        -- deduct health from player
        -- despawn object
    else
        -- what kind of object are we dealing with
        if self.zone == "right" then
            self:moveBy(-5, 0) -- toward player at their speed, TODO: use player speed stuff
            if self.x < 0 then
                print(self.name.." says goodbye~!")
                self:remove()
            end
        end
        if self.zone == "bottom" then
            self:moveBy(0, -5)
            if self.y < 0 then
                print(self.name.." says goodbye~!")
                self:remove()
            end
        end
    end
end

-- Factory for Obstacle which is a subclass of sprite with 
-- parameters unique to this subclass
-- Takes a table from rightSpawningObjects or bottomSpawningObjects table containing obstacle information
function createObstacle(obsInfo)
    local obs = ObsSprite()
    obs:setImage(loadImageToSpriteHelper(obsInfo.image))
    obs.name = obsInfo.name
    obs.currentSpeed = 0
    obs.speedModifier = 0
    obs.zone = obsInfo.zone
    return obs
end


-- PLACEHOLDER: update art assets when complete
bottomObsImage = loadImageToSpriteHelper("images/bobject_ph")
bottomObsSprite = gfx.sprite.new(bottomObsImage)

rightObsImage = loadImageToSpriteHelper("images/robject_ph")
rightObsSprite = gfx.sprite.new(rightObsImage)

-- TODO: sprite initilization for other objects go below (decorations, etc)

--                                           ##### END GLOBALS #####

rightSpawningObjects = {{name="pothole",image="images/bobject_ph",zone="right"}}
bottomSpawningObjects = {{name="tumbleweed",image="images/robject_ph",zone="bottom"}}

-- Spawns a new instance of a random obstacle on the right side 
function spawnObjectRight()
    local params = rightSpawningObjects[math.random( #rightSpawningObjects )]
    local object = createObstacle(params)
    local spawnLane = LANES[math.random( #LANES )] -- pick a random lane from our 3 lanes
    object:moveTo(SCREENWIDTH + 30, spawnLane) -- 30 pixels off screen right
    object:add()
    print("spawned right object "..object.name)
    return object
end

-- Spawns a new instance of a random obstacle on the bottom
function spawnObjectBottom()
    local params = bottomSpawningObjects[math.random( #bottomSpawningObjects )]
    local object = createObstacle(params)
    local randX = math.random(BSPAWN_START, BSPAWN_END)
    object:moveTo(randX, SCREENHEIGHT + 30) -- 30 pixels below screen
    object:add()
    print("spawned bottom object "..object.name)
    return object
end