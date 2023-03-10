local SoundManager = require 'SoundManager'

local player1, player2, ball

function love.load()
    player1 = dofile 'player.lua'
    player2 = dofile 'player.lua'
    ball = dofile 'ball.lua'

    math.randomseed(os.time())

    love.graphics.setDefaultFilter("nearest", "nearest")

    player1.load(1)
    player2.load(2)
    ball.load(player1)
end

function love.update(dt)
    player1.update(dt)
    player2.update(dt)

    ball.update(dt)

    if ball.isMoving then
        if ball.isColliding(player1) then
            ball.collide(player1, -1)
        elseif ball.isColliding(player2) then
            ball.collide(player2, 1)
        end

        local winner = ball.checkWinner()

        if winner == 1 then
            print("Player 1 wins!")
            ball.load(player2)
            SoundManager.missBlipSound:play()
        elseif winner == 2 then
            print("Player 2 wins!")
            ball.load(player1)
            SoundManager.missBlipSound:play()
        end
    end
end

function love.draw()
    player1.draw()
    player2.draw()
    ball.draw()
end

function love.keypressed(key)
    if key == 'space' and not ball.isMoving then
        ball.isMoving = true
        local theta = math.random()*math.pi/6 - math.pi/12
        ball.direction.x = -math.cos(theta)
        ball.direction.y = math.sin(theta)
        SoundManager.padBlipSound:play()
    end
end