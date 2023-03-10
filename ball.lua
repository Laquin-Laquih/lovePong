local GeneralVariables = require 'general'
local enums = require 'enums'
local SoundManager = require 'SoundManager'

local ball = {}

function ball.load(launcher)
    ball.launcher = launcher

    ball.speed = 500
    ball.direction = {x = 0, y = 0}

    ball.width = 24
    ball.height = 24
    ball.radius = 12

    if launcher.position == enums.Position.RIGHT then
        ball.x = launcher.x - ball.width
    else
        ball.x = launcher.x + launcher.width
    end

    ball.y = launcher.y + (launcher.height - ball.height) / 2

    ball.isMoving = false

    ball.collisionCounter = 0

    if GeneralVariables.drawMode == enums.DrawMode.IMAGES then
        ball.image = love.graphics.newImage('assets/sprites/ball.png')
        assert(ball.image:getWidth()*GeneralVariables.pixelScale == ball.width and ball.image:getHeight()*GeneralVariables.pixelScale == ball.height, "Ball image dimensions (" .. ball.image:getWidth() .. ", " .. ball.image:getHeight() .. ") don't match ball dimensions (" .. ball.width .. ", " .. ball.height .. ")")
    end

    ball.color = {1, 1, 1, 1}
end

function ball.update(dt)
    if ball.isMoving then
        ball.x = ball.x + dt*ball.speed*ball.direction.x
        ball.y = ball.y + dt*ball.speed*ball.direction.y

        if ball.y < 0 then
            ball.y = 0
            ball.direction.y = -ball.direction.y
            SoundManager.wallBlip:play()
        elseif ball.y > GeneralVariables.mapHeight - ball.height then
            ball.y = GeneralVariables.mapHeight - ball.height
            ball.direction.y = -ball.direction.y
            SoundManager.wallBlip:play()
        end
    else
        ball.y = ball.launcher.y + (ball.launcher.height - ball.height) / 2
    end
end

if GeneralVariables.drawMode == enums.DrawMode.IMAGES then
    function ball.draw()
        love.graphics.draw(ball.image, ball.x, ball.y, nil, GeneralVariables.pixelScale)
    end
elseif GeneralVariables.drawMode == enums.DrawMode.GEOMETRY then
    function ball.draw()
        love.graphics.setColor(ball.color)
        love.graphics.circle('fill', ball.x + ball.radius, ball.y + ball.radius, ball.radius)
    end
end

function ball.isColliding(launcher)
    return ball.x + ball.width > launcher.x and ball.x < launcher.x + launcher.width and
        ball.y + ball.height > launcher.y and ball.y < launcher.y + launcher.height
end

function ball.checkScorer()
    if ball.x < 0 then
        return enums.Position.RIGHT
    elseif ball.x > GeneralVariables.mapWidth then
        return enums.Position.LEFT
    else
        return 0
    end
end

function sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end

function ball.collide(player)
    if player.position == enums.Position.LEFT then
        directionSign = 1
    else
        directionSign = -1
    end

    ball.collisionCounter = ball.collisionCounter + 1
    if ball.collisionCounter % 10 == 0 and ball.speed < 800 then
        ball.speed = ball.speed + 50
        print(ball.speed)
    end

    ball.x = player.x + player.width * directionSign

    local theta, multiplier

    if ball.y < player.y then
        theta = -(math.random()*math.pi/4 + math.pi/12)
        multiplier = 1.3
        SoundManager.hitBlip:play()
    elseif ball.y + ball.height > player.y + player.height then
        theta = (math.random()*math.pi/4 + math.pi/12)
        multiplier = 1.3
        SoundManager.hitBlip:play()
    else
        theta = (math.random()*math.pi/4 - math.pi/8)
        multiplier = 1
        SoundManager.padBlip:play()
    end

    ball.direction.x = math.cos(theta) * directionSign * multiplier
    ball.direction.y = math.sin(theta)
end

function ball.launch()
    if ball.launcher.position == enums.Position.LEFT then
        directionSign = 1
    else
        directionSign = -1
    end

    ball.isMoving = true
    local theta = math.random()*math.pi/6 - math.pi/12
    ball.direction.x = math.cos(theta) * directionSign
    ball.direction.y = math.sin(theta)
    SoundManager.padBlip:play()
end

return ball