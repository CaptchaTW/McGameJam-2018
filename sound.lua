music = love.audio.newSource("cute1.mp3")
music1 = love.audio.newSource("poop2.mp3")
boom = love.audio.newSource("boom.mp3")
music2 = love.audio.newSource("poop3.mp3")
jumpsound = love.audio.newSource("jump1.wav")



--music:setLooping(true)--need actual loop condition for new boss appears or smthing
--music:setPitch(love.math.random()) --for sound effects



slashsound = love.audio.newSource("zapsplat_warfare_sword_swing_fast_whoosh_metal_004.mp3")--need to add slashsound:play()  under slash_anim:gotoFrame(1) in game
