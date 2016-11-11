music = Sound("Resources/music/tcl_1.ogg")
music_num = 1 -- soundtrack
music:Play(true)
music:setVolume(0.4)

game_screen = 0	-- title screen display
movespeed = 1 -- global movespeed
time = 0
inst1 = 1 -- instructions display
kx = 0 -- x key state
kz = 0 -- z key state
t1 = 860 -- tails x pos
t1s = 0	-- tails status
ex = 1280 -- egg x pos
ey = 640 -- egg y pos
eys = 0 -- egg y speed
eh = 0 --egg hurt
ani = 0 --animation duration
hurt = 0 -- sanic hurt status
h = 0 -- health out of 3
score = 0

scene = Scene(Scene.SCENE_2D)
scene:getDefaultCamera():setOrthoSize(1280, 720)

title = SceneImage("Resources/pics/title.png")
scene:addChild(title)

scoreLabel = SceneLabel(""..score, 64)
scoreLabel:Translate(480,-280,0)
scoreLabel:setColor(0, 0, 0, 1)

hSet = SpriteSet("Resources/sprites/health.sprites", Services.ResourceManager:getGlobalPool())
health = {}    -- new array
	for i=0, 2 do
		health[i] = SceneSprite(hSet)
		health[i]:setSpriteByName("health")
		health[i]:setSpriteStateByName("1", 0, false)
		health[i]:Translate(-540+i*200,-280,0)
	end

-- init background tiles and movement
tile = {}    -- new array
	for i=0, 5 do
		tile[i] = SceneImage("Resources/pics/tile.png")
	end
	for i=0, 2 do
		tile[2*i]:Translate(640*i-320,170,0)
	end
	for i=0, 2 do
		tile[2*i+1]:Translate(640*i-320,-170,0)
	end
	
tilemove = {}
	for i=0, 5 do
		tilemove[i] = 0
	end
	for i=0, 2 do
		tilemove[2*i] = tilemove[2*i] + 640*i
		tilemove[2*i+1] = tilemove[2*i+1] + 640*i
	end

-- init sanic
spriteSet = SpriteSet("Resources/sprites/sanic.sprites", Services.ResourceManager:getGlobalPool())
sanic = SceneSprite(spriteSet)
sanic:Translate(-240,0,0)
sanic:setSpriteByName("sanic")
sanic:setSpriteStateByName("title", 0, false)
scene:addEntity(sanic)

-- init tails
tailsSet = SpriteSet("Resources/sprites/tails.sprites", Services.ResourceManager:getGlobalPool())
tails = SceneSprite(tailsSet)
tails:Translate(t1,240,0)
tails:setSpriteByName("tails")
tails:setSpriteStateByName("stand", 0, false)

-- init eggguy
eggSet = SpriteSet("Resources/sprites/egg.sprites", Services.ResourceManager:getGlobalPool())
egg = SceneSprite(eggSet)
egg:Translate(ex,ey,0)
egg:setSpriteByName("egg")
egg:setSpriteStateByName("walk", 0, false)

-- init instructions
inst = SceneImage("Resources/pics/inst.png")
inst:Translate(0,220,0)

-- win/lose
lose = SceneImage("Resources/pics/lose.png")
lose:Translate(0,240,0)
win = SceneImage("Resources/pics/win.png")
win:Translate(0,240,0)
winSet = SpriteSet("Resources/sprites/win.sprites", Services.ResourceManager:getGlobalPool())
winsanic = SceneSprite(winSet)
winsanic:setSpriteByName("winsanic")
winsanic:setSpriteStateByName("party", 0, false)
chili = SceneSprite(winSet)
chili:setSpriteByName("chili")
chili:setSpriteStateByName("chilidog", 0, false)
chili:Translate(240,0,0)
winsanic:Translate(-240,0,0)

function onKeyDown(key)
	-- if in title screen
	if game_screen == 0 then
		-- switch song on/off
		if key == KEY_x then
			if music_num == 1 then
				music:Stop()
				music_num = 4;
			elseif music_num == 4 then
				music_num = 1;
				music = Sound("Resources/music/tcl_1.ogg")
				music:Play(true)
				music:setVolume(0.4)
			end
		
		-- start the game screen
		elseif key == KEY_z then
			game_screen = 1
			for i=0, 5 do
				scene:addEntity(tile[i])
			end
			scene:removeEntity(title)
			scene:removeEntity(sanic)
			scene:addEntity(egg)
			scene:addEntity(sanic)
			scene:addEntity(tails)
			scene:addEntity(inst)
			scene:addEntity(scoreLabel)
			for i=0, 2 do
				scene:addEntity(health[i])
			end
			sanic:setSpriteStateByName("walk", 0, false)
		end
		
	-- if game started
	elseif game_screen == 1 then
		if key == KEY_x then
			kx = 1
		elseif key == KEY_z then
			kz = 1
		end
		if kx == 1 and kz == 1 then
			sanic:setSpriteStateByName("wave", 0, false)
			movespeed = 0
			state = 2
		elseif kx == 0 and kz == 1 then
			sanic:setSpriteStateByName("stand", 0, false)
			movespeed = 0
			state = 1
		end
	end
end

function onKeyUp(key)
	if game_screen == 1 then
		if key == KEY_z then
			kz = 0
		elseif key == KEY_x then
			kx = 0
		end
		if kx == 0 and kz == 1 then
			sanic:setSpriteStateByName("stand", 0, false)
			movespeed = 0
			state = 1
		elseif kx == 0 and kz == 0 then
			sanic:setSpriteStateByName("walk", 0, false)
			movespeed = 1
			state = 0
		elseif kx == 1 and kz == 0 then
			sanic:setSpriteStateByName("walk", 0, false)
			movespeed = 1
			state = 0
		end
	end
end

function Update(elapsed)
	if game_screen == 1 then
		time = time + elapsed
		if time > 5 and inst1 == 1 then	-- remove instructions
			scene:removeEntity(inst)
			inst1 = 0
		end
		local move = movespeed*-1
		for i=0,5 do
			tile[i]:Translate(move,0,0)
			tilemove[i] = tilemove[i] + move
			if tilemove[i] < -640 then
				tile[i]:Translate(1920,0,0)
				tilemove[i] = tilemove[i]+1920
			end
		end
		
		--egg movement
		if ex < 800 and eh == 0 then
			eys = -0.6
		end
		egg:Translate(move,eys,0)
		ex = ex + move
		ey = ey + eys
		if ex > -360 and ex < -120 and ey > -120 and ey < 120 and eh == 0 then --on collision
			eh = 1
			eys = 0
			egg:setSpriteStateByName("hurt", 0, false)
			hurt = 1
			score = score + 1
			scoreLabel:setText(""..score)
		end
		-- reset egg
		if ex < -680 then
			egg:setSpriteStateByName("walk", 0, false)
			local rand2 = math.random()
			egg:setPosition(800+400*rand2,640,0)
			eh = 0
			ex = 960
			ey = 640
		end
		
		
		-- tails movement
		tails:Translate(move,0,0)
		t1 = t1 + move
		if t1 > -160 and t1 < 80 then
			tails:setSpriteStateByName("wave", 0, false)
			if state == 2 then 
				t1s = 1
			end
		elseif t1 < -160 then
			if t1s == 1 then
				tails:setSpriteStateByName("happy", 0, false)
				t1s = 2
				score = score + 1
				scoreLabel:setText(""..score)
			elseif t1s == 0 then
				tails:setSpriteStateByName("sad", 0, false)
				if t1 > -170 and ani == 0 then
					hurt = 1
				end
			end
			--reset tails
			local rand = math.random()
			if t1 < -680 then
				tails:setSpriteStateByName("stand", 0, false)
				t1 = 800+400*rand
				tails:setPosition(t1,240,0)
				t1s = 0
			end
		end
		
		-- hurt biz
		if hurt == 1 and ani == 0 then
			sanic:setSpriteStateByName("hurt", 0, false)
			ani = elapsed + ani
			health[h]:setSpriteStateByName("2", 0, false)
			h = h + 1
			if h == 3 then
				game_screen = 2
				scene:removeEntity(tails)
				scene:removeEntity(egg)
				sanic:setSpriteStateByName("stand", 0, false)
				scene:addEntity(lose)
				music:Stop()
			end
		elseif hurt == 1 and ani > 0 and ani < 2 then
			ani = elapsed + ani
		elseif hurt == 1 and ani >= 2  then --end animation
			sanic:setSpriteStateByName("walk", 0, false)
			ani = 0
			hurt = 0
		end
		if score == 3 then
			game_screen = 3
			scene:removeEntity(sanic)
			scene:removeEntity(tails)
			scene:removeEntity(egg)
			scene:addEntity(win)
			scene:addEntity(winsanic)
			scene:addEntity(chili)
		end
	end
end