--[[
	Copyright (C) 2016, Ryan Skeldon
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
_addon.version = '0.1.0-dev.0'
_addon.name = 'Juggler'
_addon.author = 'psykad'
_addon.commands = {'juggler','jugs'}

require 'tables'
local texts = require('texts')
local res = require('resources')

local defaults = {}
defaults.pos = {}
defaults.pos.x = 0
defaults.pos.y = windower.get_windower_settings().y_res-17

defaults.bg = {}
defaults.bg.alpha = 255
defaults.bg.red = 0
defaults.bg.green = 0
defaults.bg.blue = 0
defaults.bg.visible = true

defaults.flags = {}
defaults.flags.right = false
defaults.flags.bottom = false
defaults.flags.bold = false
defaults.flags.italic = false

defaults.text = {}
defaults.text.size = 12
defaults.text.font = 'Consolas'
defaults.text.alpha = 255
defaults.text.red = 255
defaults.text.green = 255
defaults.text.blue = 255

local display = texts.new(defaults)

windower.register_event('load', 'login', function()
    display:visible(true)   
end)

windower.register_event('logout', 'unload', function()
    display:visible(false)
end)

windower.register_event('time change', function()
    local pet = get_pet()
    local output_text = ""

    -- Check if a pet exists.
    if pet ~= nil then
        local pet_abilities = get_pet_abilities()

        -- Charmed pets have no ready moves.
        if #pet_abilities == 0 then
            output_text = "No ready moves"
        else
            -- Iterate through available pet ready moves.
            for i =1,#pet_abilities do
                -- NOTE: Should this be adjustable, i.e. stacked vs inline display?
                output_text = output_text..'['..i..'] '..pet_abilities[i]

                if i < #pet_abilities then
                    output_text = output_text..'  '
                end
            end
        end     
    else 
        output_text = "No pet found"
    end

    display:text(output_text)
end)

windower.register_event('addon command', function(...)
	if #arg == 0 then return end
	
	local command = arg[1]

    if command == 'ready_move' then    
        -- Check for pet.
        local pet = get_pet()
        if pet == nil then
            print(_addon.name..' Error: No pet found.')
            return
        end

        -- Check for the index of the ready move.
        local move_index = tonumber(arg[2])
        if move_index == nil then
            print(_addon.name..' Error: No ready move index given.')
            return
        end
        
        -- Check if the index is valid for the current list of moves.
        local pet_abilities = get_pet_abilities()
        if move_index < 1 or move_index > #pet_abilities then
            print(_addon.name..' Error: '..move_index..' is not a valid index.')
            return
        end

        -- Execute the move.
        windower.send_command('input /ja "'..pet_moves[move_index]..'" <me>')
    end
end)

function get_pet()
    return windower.ffxi.get_mob_by_target('pet')
end

function get_pet_abilities()
    local abilities = windower.ffxi.get_abilities().job_abilities
    local pet_abilities = {}
    local move_index = 0

    -- Iterate through all current player abilities.
    for i=1,#abilities do
        local ability = res.job_abilities[tonumber(abilities[i])]

        -- Filter out everything but Monster abilities.
        if ability.type == 'Monster' then  
            move_index = move_index+1

            pet_abilities[move_index] = ability.en        
        end
    end

    return pet_abilities
end