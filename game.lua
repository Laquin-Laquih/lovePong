local game = {}

function game.load()
    game.states =
    {
        play = require 'playState',
        paused = require 'pausedState'
    }

    game.assertFunctions()

    game.switchState(game.states.play)
end

function game.update(dt)
    game.currentState.update(dt)
end

function game.draw()
    game.currentState.draw()
end

function game.keypressed(key)
    game.currentState.keypressed(key)
end

function game.switchState(state)
    game.currentState = state
    game.currentState.load()
end

function game.assertFunctions()
    for stateName, state in pairs(game.states) do
        assert(state.load ~= nil, stateName .. ".load is nil")
        assert(state.update ~= nil, stateName .. ".update is nil")
        assert(state.draw ~= nil, stateName .. ".draw is nil")
        assert(state.keypressed ~= nil, stateName .. ".keypressed is nil")
    end
end

return game