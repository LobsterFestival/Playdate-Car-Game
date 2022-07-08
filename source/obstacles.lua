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

-- init function
-- with this we can now do something like
-- CODE: local Tumbleweed = Obstacle:new("Tumbleweed",bottomObsSprite,"bottom")
function Obstacle:__init(name,sprite,zone)
    self.name = name or ""
    self.sprite = sprite
    self.currentSpeed = 0
    self.speedModifier = 0
    self.zone = zone
end

-- PLACEHOLDER: update art assets when complete
class('ObsSprite').extends(playdate.graphics.sprite)

function ObsSprite:update()
    print("ObsSprite updating...")
end

function ObsSprite:update()
    print("I'm updating!!")
end


bottomObsImage = loadImageToSpriteHelper("images/bobject_ph")
bottomObsSprite = gfx.sprite.new(bottomObsImage)

rightObsImage = loadImageToSpriteHelper("images/robject_ph")
rightObsSprite = gfx.sprite.new(rightObsImage)


testSprite = ObsSprite()
testSprite:setImage(rightObsImage)
testSprite:add()

-- TODO: sprite initilization for other objects go below (decorations, etc)

--                                           ##### END GLOBALS #####

rightSpawningObjects = {{name="pothole",sprite=rightObsSprite,zone="right"}}
bottomSpawningObjects = {{name="tumbleweed",sprite=bottomObsSprite,zone="bottom"}}

-- Spawns a new instance of a random obstacle on the right side 
function spawnObjectRight()
    local params = rightSpawningObjects[math.random( #rightSpawningObjects )]
    local object = Obstacle:new(params.name,params.sprite,params.zone)
    local spawnLane = LANES[math.random( #LANES )] -- pick a random lane from our 3 lanes
    object.sprite:moveTo(SCREENWIDTH + 30, spawnLane) -- 30 pixels off screen right
    object.sprite:add()
    print("spawned right object "..object.name)
    return object
end

-- Spawns a new instance of a random obstacle on the bottom
function spawnObjectBottom()
    local params = bottomSpawningObjects[math.random( #bottomSpawningObjects )]
    local object = Obstacle:new(params.name,params.sprite,params.zone)
    local randX = math.random(BSPAWN_START, BSPAWN_END)
    object.sprite:moveTo(randX, SCREENHEIGHT + 30) -- 30 pixels below screen
    object.sprite:add()
    print("spawned bottom object "..object.name)
    return object
end