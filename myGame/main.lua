-- Inicializador
function love.load()
    -- configurando texto
    fontSize = 36
    font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)

    gameState = "corriendo" -- o "pausa", "menu", etc.

    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 0)

    camera = require 'libraries/camera'
    cam = camera()

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest") -- elimina el filtro blur

    sti = require 'libraries/sti'
    gameMap = sti('maps/testMap.lua')

    sounds = {}
    -- al final agregamos tipo de efecto
    sounds.blip = love.audio.newSource("sounds/blip.wav", "static")
    sounds.music = love.audio.newSource("sounds/music.mp3", "stream")
    sounds.music:setLooping(true) -- Para que se repita al finalizar
    sounds.music:play()

    player = {}
    player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10) -- el ultimo parametro es esquinas
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 200
    player.speed = 300
    player.spriteSheet = love.graphics.newImage('assets/player-sheet.png')
    -- Carga el sprite para hacer la animacion 12 X 18 el tamaño 
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    -- Posicion o columna, despues cual posicion se encuentra, y despues cuantos segundo va a durar
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.down

    background = love.graphics.newImage('assets/background.png')

    walls = {} -- agregar todas las paredes
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers['Walls'].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

end

-- Ciclo del juego
function love.update(dt)
    if gameState == "corriendo" then

        local isMoving = false
        local vx = 0
        local vy = 0

        if love.keyboard.isDown("right") then
            vx = player.speed
            player.anim = player.animations.right
            isMoving = true
        end
        if love.keyboard.isDown("left") then
            vx = player.speed * -1
            player.anim = player.animations.left
            isMoving = true
        end
        if love.keyboard.isDown("up") then
            vy = player.speed * -1
            player.anim = player.animations.up
            isMoving = true
        end
        if love.keyboard.isDown("down") then
            vy = player.speed
            player.anim = player.animations.down
            isMoving = true
        end

        player.collider:setLinearVelocity(vx, vy)

        if isMoving == false then
            player.anim:gotoFrame(2)
        end

        world:update(dt) -- agregar mundo con fisicas
        player.x = player.collider:getX()
        player.y = player.collider:getY()

        player.anim:update(dt)
        cam:lookAt(player.x, player.y) -- Esto es lo que hace que siga al personaje

        -- Agregar limites en el movimiento del mapa
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()

        if cam.x < w / 2 then
            cam.x = w / 2
        end

        if cam.y < h / 2 then
            cam.y = h / 2
        end

        local mapW = gameMap.width * gameMap.tilewidth
        local mapH = gameMap.height * gameMap.tileheight

        -- Right border
        if cam.x > (mapW - w / 2) then
            cam.x = (mapW - w / 2)
        end
        -- -- Bottom border
        if cam.y > (mapH - h / 2) then
            cam.y = (mapH - h / 2)
        end
   

    end
end

-- Dibujar
function love.draw()
    if   gameState == "corriendo" then
    cam:attach() -- marca el punto donde comienza a dibujar
    -- gameMap:draw()
    gameMap:drawLayer(gameMap.layers["Piso"]) -- Dibujar capa por capa
    -- Se mejora para agregar la central del personaje, como es 
    -- 12px por 18px el centro seria 6 x 9
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
    gameMap:drawLayer(gameMap.layers["Arboles"])
    -- world:draw()
    cam:detach() -- se detiene el seguimiento

    -- Dibujar en pantalla sin el movimiento
    love.graphics.print("Hola", 10, 10)
    else
        love.graphics.print("Pausa",love.graphics.getWidth()/2 - 72, love.graphics.getHeight()/2)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "return" then -- return en lugar de enter
        if  gameState == "corriendo" then
            gameState = "pausa"
            sounds.music:stop()
        else
            gameState = "corriendo"
            sounds.music:play()
        end
    end
end
