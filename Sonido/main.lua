function love.load()
    player = {}
    player.x = 400
    player.y = 200
    player.speed = 5

    sounds = {}
    -- al final agregamos tipo de efecto
    sounds.blip = love.audio.newSource("sounds/blip.wav","static")
    sounds.music = love.audio.newSource("sounds/music.mp3","stream")
    sounds.music:setLooping(true)

    sounds.music:play()
end

function love.update(dt)
    
end

function love.draw()
    love.graphics.circle("fill",player.x,player.y,10)
end

function love.keypressed(key)
    if key == "space"then
        sounds.blip:play()
    end
    if key == "z" then
        sounds.music:stop()
    end
end