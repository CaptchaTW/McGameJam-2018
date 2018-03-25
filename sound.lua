music = love.audio.newSource("cute1.mp3")
music1 = love.audio.newSource("poop2.mp3")
music2 = love.audio.newSource("poop3.mp3")
music3 = love.audio.newSource("cute4.mp3")
music4 = love.audio.newSource("cute5.mp3")
boom = love.audio.newSource("boom.wav")
jumpsound = love.audio.newSource("jump1.wav")
roll = love.audio.newSource("roll.mp3")
laser = love.audio.newSource("laser.mp3")
splatter = love.audio.newSource("splatter.mp3")
attack4 = love.audio.newSource("boss4attack.mp3")
eye = love.audio.newSource("openeye.mp3")
death = love.audio.newSource("death.mp3")
miss = love.audio.newSource("miss.mp3")
hit = love.audio.newSource("hitsound.mp3")
thingies = love.audio.newSource("thingies.mp3")




--music:setLooping(true)--need actual loop condition for new boss appears or smthing
--music:setPitch(love.math.random()) --for sound effects



slashsound = love.audio.newSource("zapsplat_warfare_sword_swing_fast_whoosh_metal_004.mp3")--need to add slashsound:play()  under slash_anim:gotoFrame(1) in game
