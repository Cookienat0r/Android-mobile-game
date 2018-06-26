display.setStatusBar(display.HiddenStatusBar)
local w=display.contentWidth
local h=display.contentHeight

local physics = require "physics"
--physics.setDrawMode("hybrid")

-- Menu Screen
local titleScreenGroup
local titleScreen
local playBtn

--Game Screen
local background
local penguinSprite
local scoreCounter = 0
local fishGroup = display.newGroup()
local spawnFish
local onLocalCollision
local spawnSnowball
local hitSound = audio.loadSound("punch.mp3")
local catchSound = audio.loadSound("catch.mp3")
local mainAudio = audio.loadStream("backgroundMusic.mp3")


function showTitleScreen()
	physics.start()
	physics.setGravity(0, 9.8)
	audio.play(mainAudio, {loops = 0})
	titleScreen = display.newImage("snow.jpg")
	titleScreen.x = display.contentCenterX
	titleScreen.y = display.contentCenterY

	titleFish = display.newImage("fish2.png", w/2-200, h/2+100)
	titleFish.rotation = -35
	titleFish.xScale = 2
	titleFish.yScale = 2

	playBtn = display.newImage("playbutton.png", w/2, h/2)
	playBtn.xScale = 1
	playBtn.yScale = 1
	playBtn.name = "playbutton"
	playBtn:addEventListener("tap", loadGame)

	titleScreenGroup = display.newGroup()
	titleScreenGroup:insert(titleScreen)
	titleScreenGroup:insert(titleFish)
	titleScreenGroup:insert(playBtn)
end

function  loadGame(event)
	if event.target.name == "playbutton" then
		transition.to(titleScreenGroup,{time=1000, alpha=0, onComplete = initializeGameScreen})
		playBtn:removeEventListener("tap", loadGame)
	end
end

function initializeGameScreen()
	local background = display.newImage("snow.jpg")
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local function onBottomCollision(self, event)
		if (event.other == snowball) then
			if (event.phase=="began") then
				timer.performWithDelay(1, 
					function() 
						display.remove(event.other) 
					end)
				snowball = nil
			end
		end
	end
 
	local walls = {}
	local leftWall = display.newRect(0, h/2, 0, h)
		table.insert(walls, leftWall)
	local rightWall = display.newRect(w, h/2, 0, h)
		table.insert(walls, rightWall)
	local top = display.newRect(w/2, 0-50, w, 50)
		table.insert(walls, top)
	local bottom = display.newRect(w/2, h, w, 0)
		table.insert(walls, bottom)
		bottom.collision = onBottomCollision
		bottom:addEventListener("collision")
	for i = 1, 4 do
		physics.addBody(walls[i])
		walls[i].bodyType="static"
	end

	-------------------------------
	---- placing the platforms ----
	-------------------------------
	local platform1 = display.newRoundedRect((w/3)-(0.5*w/3), h-(h*0.07), w/3, h*0.11, 30) --bottom left
	local platform2 = display.newRoundedRect(((w/3)*2)-(0.5*w/3), h-(h*0.07), w/3, h*0.11, 30) --bottom middle
	local platform3 = display.newRoundedRect(((w/3)*3)-(0.5*w/3), h-(h*0.07), w/3, h*0.11, 30) --bottom right

	local platform4 = display.newRoundedRect((w/3)-(0.5*w/3), h-(h*0.73), w/3, h*0.11, 30)  --top left
	--local platform6 = display.newRoundedRect(((w/3)*2)-(0.5*w/3), h-(h*0.73), w/3, h*0.11, 30)  --top middle
	local platform5 = display.newRoundedRect(((w/3)*3)-(0.5*w/3), h-(h*0.73), w/3, h*0.11, 30)  --top right

	--local platform7 = display.newRoundedRect((w/3)-(0.5*w/3), h-(h*0.42), w/3, h*0.11, 30)  --middle left
	local platform9 = display.newRoundedRect(((w/3)*2)-(0.5*w/3), h-(h*0.42), w/3, h*0.11, 30)  --middle middle
	--local platform8 = display.newRoundedRect(((w/3)*3)-(0.5*w/3), h-(h*0.42), w/3, h*0.11, 30)  --middle right

	-------------------------------
	---- when objects collide -----
	-------------------------------
	function onLocalCollision(self, event)
		if (event.other == fish1) then
			if (event.phase=="began") then
				timer.performWithDelay(1, 
					function() 
						display.remove(event.other) 
					end)
				fish1 = nil
				scoreCounter = scoreCounter+1	-- increase score on collision with fish
				scoreText.text = "Fish:"..scoreCounter  
				audio.play(catchSound)
			end
		end	
		if (event.other == snowball) then
			if (event.phase=="began") then
				timer.performWithDelay(1,
					function()
						penguinDie()
					end)
				snowball = nil
				transition.to(penguinSprite, {time = 2000, onComplete = gameOverScreen})
				audio.play(hitSound)
			end
		end
	end

	-------------------------------
	----- placing the player ------
	-------------------------------
	penguinTable = {
		width = 64,
		height = 64,
		numFrames=12,
		sheetContentWidth=256,
		sheetContentHeight=192
	}
	local penguinSheet=graphics.newImageSheet("sprite-penguins-40b.png",penguinTable)
	sequenceData = {
		{
			name="runRight",
			frames={1,2,3,4},
			time=1000,
			loopDirection="forward",  -- bounce / forward
			loopCount=1	
		},
		{
			name="runLeft",
			frames={1,2,3,4},	
			time=1000,
			loopDirection="forward",  -- bounce / forward
			loopCount=1	
		},
		{
			name="jump",
			frames={5,6,7,1},
			time=800,
			loopDirection="forward",  -- bounce / forward
			loopCount=1
		},
		{
			name="die",
			frames={1,9,10,11,12},
			time=800,
			loopDirection="forward",  -- bounce / forward
			loopCount=1
		},
	}
	penguinSprite=display.newSprite(penguinSheet, sequenceData)
		penguinSprite.x = display.screenOriginX + w/6
		physics.addBody(penguinSprite, "dynamic", {density = 1, friction = 0, bounce = 0})
		penguinSprite.isFixedRotation = true
		penguinSprite.collision = onLocalCollision
		penguinSprite:addEventListener("collision")

	function penguinRunRight(event)
		penguinSprite:setSequence("runRight")
		penguinSprite.xScale = 1
		penguinSprite:play()
		penguinSprite:applyLinearImpulse(40, 0, penguinSprite.x, penguinSprite.y)
	end

	function penguinRunLeft(event)
		penguinSprite:setSequence("runLeft")
		penguinSprite.xScale = -1
		penguinSprite:play()
		penguinSprite:applyLinearImpulse(-40, 0, penguinSprite.x, penguinSprite.y)
	end

	function penguinJump(event)
		penguinSprite:setSequence("jump")
		penguinSprite:play()
		penguinSprite:applyLinearImpulse(0, -40, penguinSprite.x, penguinSprite.y)
	end

	function penguinDie(event)
		penguinSprite:setSequence("die")
		penguinSprite:play()
	end

	----------------------------------
	--------spawn fish --------------
	---------------------------------
	function spawnFish()
		if not (fish1) then
			fish1 = display.newImage("fish2.png")
			fish1.width = display.contentWidth * 0.1
			fish1.height = display.contentHeight * 0.15
			fish1.x = math.random(w) 				-- random width position
			fish1.y = math.random(50, 300)   		-- top of the screen
			physics.addBody(fish1, "static", {density=1})
		end
	end
	timer.performWithDelay(1000, spawnFish, 0)  -- fire every second. 0 or -1 for timer to loop forever

	---------------------------------
	--------spawn snowballs ---------
	---------------------------------
	function spawnSnowball()
		if not (snowball) then
			snowball = display.newImage("snowball.png")
			snowball.width = display.contentWidth * 0.06
			snowball.height = display.contentHeight * 0.1
			snowball.x = math.random(w)
			snowball.y = 0
			physics.addBody(snowball)
			transition.to(snowball, {time = math.random(2000, 4000), y=h+50})
		end
	end
	timer.performWithDelay(3500, spawnSnowball, 0)

	----------------------------------
	--------  Navigation ------------
	----------------------------------
	local runLeft = display.newRect((w/3)-(0.5*w/3), h-(h*0.40), 200, 200)
		runLeft:setFillColor(1,1,0)
		runLeft.alpha=0.1
		runLeft:addEventListener("tap", penguinRunLeft)
		
	local runRight = display.newRect(((w/3)*3)-(0.5*w/3), h-(h*0.40), 200, 200) 
		runRight:setFillColor(1,1,0)
		runRight.alpha=0.1
		runRight:addEventListener("tap", penguinRunRight)

	local jumpLeft = display.newRoundedRect((w/3)-(0.5*w/3), h-(h*0.85), 200, 100, 60)
		jumpLeft:setFillColor(1,1,0)
		jumpLeft.alpha=0.1
		jumpLeft:addEventListener("tap", penguinJump)

	local jumpRight = display.newRoundedRect(((w/3)*3)-(0.5*w/3), h-(h*0.85), 200, 100, 60)
		jumpRight:setFillColor(1,1,0)
		jumpRight.alpha=0.1
		jumpRight:addEventListener("tap", penguinJump)

	----------------------------------
	--------- show score ------------
	----------------------------------
	scoreText = display.newText("Fish:0", ((w/3)*3)-(0.5*w/3), h-(h*0.95), "manaspc.ttf", 23)
	scoreText:setTextColor(255, 255, 255, 255)

	-------------------------
	-------Adding physics--
	-------------------------
	local offsetRectParams = {halfWidth=w/2, halfHeight=(h*0.11)/2, x=0, y=0, angle=0}
	physics.addBody(platform1, "static", {density = 1, friction = 0.5, bounce = 0})
	physics.addBody(platform2, "static", {density = 1, friction = 0.5, bounce = 0, box = offsetRectParams})
	physics.addBody(platform3, "static", {density = 1, friction = 0.5, bounce = 0})
	physics.addBody(platform4, "static", {density = 1, friction = 0.5, bounce = 0})
	physics.addBody(platform5, "static", {density = 1, friction = 0.5, bounce = 0})
	physics.addBody(platform9, "static", {density = 1, friction = 0.5, bounce = 0})

end

function gameOverScreen(event)
	physics.pause()
	background = display.newImage("snow.jpg")
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	gameOverText=display.newText("uh-oh..Game Over", w/2, h/2, "manaspc.ttf", 40)
	-- playText = display.newText("Play Again", w/2, h/2+100, "manaspc.ttf", 40)
	-- playText.name = "playAgainButton"
	-- playText:addEventListener("tap", load)
end

function main()
	showTitleScreen()
end
main()
