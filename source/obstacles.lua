-- Each of these tables contains information about each of the different obstacles 
-- Each obstacle will deduct 1 health from the player and despawn the obstacle on hit

tumbleweed = {name="tumbleweed",imageSprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
pothole = {name="pothole",imageSprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
-- vertical flip will determine if the cactus image sprite is pointing up or down on the road
cactus = {name="cactus",imageSprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil,verticalFlip=0}
ramp = {name="ramp",imageSprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
roadkill = {name="roadkill",imageSprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil}
-- style determines which image sprite to use for different types of cars on the road
car = {name="car",imageSprite=nil,currentSpeed=0,speedModifier=0,spawnLocation=nil,style=0}

-- TODO: sprite initilization for other objects go below