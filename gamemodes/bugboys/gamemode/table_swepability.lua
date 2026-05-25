--[[
	Swep Abilities base table
--]]

local swep_abilities = {
    {
        name = "abil_rope",
        print_name = "Rope",
        func = "func_rope",
        delay = 1,
        clip = 1,
        reload = 5,
        dont_show_ammo = false,
    },
    {
        name = "abil_deconstruct",
        print_name = "Deconstruct",
        func = "func_deconstruct",
        delay = 1,
        clip = 1,
        reload = 1,
        dont_show_ammo = true,
        dont_reload = true,
    }
}

local swep_abilities_count = #swep_abilities

function SwepabilityReference( abilstring )
    for i = 1, swep_abilities_count, 1 do
        if swep_abilities[ i ].name == abilstring then
            return swep_abilities[ i ]
        end
    end
end
