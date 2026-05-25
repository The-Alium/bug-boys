include( "shared.lua" )
include( "table_puck.lua" )
include( "table_ent.lua" )
include( "table_swep.lua" )
include( "table_craft.lua" )
include( "table_swepability.lua" )
include( "shared_settings.lua" )
include( "meta_player.lua" )
include( "meta_ent.lua" )
include( "meta_puck_grab.lua" )
include( "meta_puck_rope.lua" )
include( "meta_puck_weld.lua" )
include( "meta_puck_craft.lua" )

include( "cl_teammenu.lua" )
include( "cl_classmenu.lua" )
include( "cl_gametimer.lua" )
include( "cl_sounds.lua" )
include( "cl_deathnotice.lua" )
include( "cl_keypress.lua" )
include( "cl_quickmenu.lua" )
include( "cl_typecommands.lua" )
include( "cl_respawntimer.lua" )
include( "cl_scoreboard.lua" )
include( "cl_buildingghost.lua" )
include( "cl_helpmenu.lua" )

surface.CreateFont( "CustomBBFont_A", {
    font = "Arial",
    size = 120,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
} )

surface.CreateFont( "CustomBBFont_B", {
    font = "Arial",
    size = 40,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
} )

surface.CreateFont( "CustomBBFont_C", {
    font = "Arial",
    size = 70,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
} )

local GM = GM

local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
local draw = draw

local IsValid = IsValid

do

    local allowed_to_draw = {
        [ "CHudHealth" ] = true,
        [ "CHudBattery" ] = true,
        [ "CHudAmmo" ] = true,
        [ "CHudSecondaryAmmo" ] = true,
        [ "CHudWeaponSelection" ] = true,
    }

    function GM:HUDShouldDraw( name )
        return not allowed_to_draw[ name ]
    end

end

surface.CreateFont( "TheDefaultSettings", {
    font = "Arial",
    size = 120,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
} )

surface.CreateFont( "SmallerFont", {
    font = "Arial",
    size = 60,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
} )

surface.CreateFont( "NewSmallerFont", {
    font = "Arial",
    size = 40,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
} )

do

    ---@type TraceResult
    local trace_result = {}

    ---@type Entity[]
    local filter = {}

    ---@type Trace
    local trace_up = {
        mask = MASK_SOLID_BRUSHONLY,
        output = trace_result,
        filter = filter,
    }


    ---@type TraceResult
    local trace2_result = {}

    ---@type Trace
    local trace2 = {
        output = trace2_result,
        filter = filter,
    }

    local view = {}

    function GM:CalcView( pl, origin, angles, fov )
        --[[
    	-- Set the chase distance --
    	if (pl:KeyDown(IN_SPEED)) then
    		-- Zoom out
    		pl.ZoomDist = math.min(250, pl.ZoomDist + 200*FrameTime())

    	elseif (pl:KeyDown(IN_DUCK)) then
    		-- Zoom in
    		pl.ZoomDist = math.max(0, pl.ZoomDist - 200*FrameTime())
    	end
    	--]]

        -- Prevent camera from noclipping with world
        local Puck = pl:GetNWEntity( "Puck" )
        if not Puck:IsValid() then return end

        filter[ 1 ] = pl
        filter[ 2 ] = Puck
        filter[ 3 ] = nil

        local PuckStats = PuckReference( Puck:GetClass() )
        pl.ZoomDist = PuckStats.cam_dist

        trace_up.start = Puck:GetPos()
        trace_up.endpos = trace_up.start + (angles:Up() * PuckStats.cam_height)
        util.TraceLine( trace_up )

        -- set up another trace from the top hit position of Uptrace
        trace2.start = trace_result.HitPos
        trace2.endpos = trace2.start - (pl:GetAimVector() * pl.ZoomDist)
        util.TraceLine( trace2 )

        view.origin = trace2_result.HitPos + (trace2_result.HitNormal * 2)
        view.angles = angles

        --if somethings in the way of the trace view, disregard it unless its the world
        -- if trace2_result.HitNonWorld then
        --     local entity_class = trace2_result.Entity:GetClass()
        --     if entity_class ~= "structure_turret_vehicle" then
        --         -- and entity_class ~= "structure_destroyer"
        --         -- and entity_class ~= "structure_boat" then

        --         --local norm_dist = (Puck:GetPos() - pl:GetAimVector()* -pl.ZoomDist)
        --         --local subtraction = (trace2_result.HitPos - Puck:GetPos())

        --         --local dif = norm_dist - subtraction




        --         while true do
        --             local ReTrace = util.QuickTrace( trace_result.HitPos, pl:GetAimVector() * -pl.ZoomDist, filter )
        --             filter[ 3 ] = ReTrace.Entity

        --             -- trace2_result

        --             if (ReTrace.HitWorld) then
        --                 view.origin = ReTrace.HitPos + (ReTrace.HitNormal * 2)
        --                 break
        --                 -- elseif not (ReTrace.Hit) then
        --             else
        --                 view.origin = (trace_result.HitPos + pl:GetAimVector() * -pl.ZoomDist)
        --                 break
        --             end
        --         end

        --         --view.origin = (Puck:GetPos() + pl:GetAimVector()* -pl.ZoomDist)
        --     end
        -- end

        -- We're not actually here..
        pl.FakePos = view.origin

        --Make view higher up--
        --view.origin = origin+(angles:Up()*20)

        return view
    end

end

local keys = {}

function GM:KeyPress( pl, key )
    if pl ~= LocalPlayer() then return end

    keys[ key ] = true
end

function GM:KeyRelease( pl, key )
    if pl ~= LocalPlayer() then return end

    keys[ key ] = false
end

local buttons = {}

function GM:PlayerButtonDown( pl, button )
    if pl ~= LocalPlayer() then return end

    buttons[ button ] = true
end

function GM:PlayerButtonUp( pl, button )
    if pl ~= LocalPlayer() then return end

    buttons[ button ] = false
end

local color_black_100 = Color( 255, 255, 255, 100 )
local color_black = Color( 0, 0, 0, 255 )
local color_white = color_white
local color50 = Color( 50, 50, 50, 255 )
local color_dark_red = Color( 100, 0, 0, 255 )
local color_dark_blue = Color( 0, 0, 100, 255 )
local color_200 = Color( 200, 200, 200, 255 )
local color_50_180 = Color( 50, 50, 50, 180 )
local color_pink = Color( 255, 100, 100, 255 )
local color_dark_pink = Color( 200, 100, 100, 255 )
local purple = Color( 220, 180, 255, 255 )

local function DrawDamageMark( ent, mark, color )
    local PosScr = ent:GetPos():ToScreen()
    draw.SimpleTextOutlined( "X", "TargetID", PosScr.x, PosScr.y, color_white, 1, 1, 1, color_black )
end

---@type TraceResult
local trace_result = {}

---@type Trace
local trace = {
    mask = MASK_SOLID - CONTENTS_GRATE,
    output = trace_result,
}

function GM:HUDPaint()
    local pl = LocalPlayer()
    local team_id = pl:Team()

    for _, ent in ents.Iterator() do
        if ent:GetClass() == "ent_damagemarker_red" then
            DrawDamageMark( ent )
        end
    end

    local screen_width, screen_height = ScrW(), ScrH()
    local screen_width_half, screen_height_half = screen_width * 0.5, screen_height * 0.5


    --[[
    	Names on pucks
    --]]

    --[[
	---- Names ----
	-- Player names --
	for k,v in pairs(player.GetAll()) do
		local Puck = v:GetNetPuck()
		local trstart = pl.FakePos
		if team_id == TEAM_SPEC then
			trstart = pl:GetPos()
		end

		-- Make sure our Puck is valid before we do anything
		if (IsValid(Puck)) then
			-- Make a traceline
			trace.start = trstart
			trace.endpos = Puck:GetPos()
			trace.filter = pl

			util.TraceLine(trace)

			if (trace_result.HitNonWorld) and trace_result.Entity:IsValidPuck() and trace_result.Entity:GetOwner() ~= pl then
				local Pos = Puck:GetPos() + Vector(0, 0,10)
				local PosScr = Pos:ToScreen()

				local distance = pl:EyePos():Distance( Puck:GetPos() )
					PosScr.y = (PosScr.y - ( math.log(distance)*4) - 30) --*4

				local teamcolor = Color(200, 200, 200, 255)
				if v:Team() == TEAM_RED then
					teamcolor = Color(255, 170, 170, 255)
				elseif v:Team() == TEAM_BLUE then
					teamcolor = Color(170, 170, 255, 255)
				end

				local dorender = true
				if distance > MAX_NAME_RENDER_DISTANCE then
					dorender = false
				end

				if dorender == true then
					-- Draw their names above their Pucks
					draw.SimpleTextOutlined(v:Name() .. " - "  .. v:GetTokens(), "Default", PosScr.x, PosScr.y, teamcolor, 1, 1, 1, Color(0, 0, 0, 255))
				end
			end
		end
	end
	--]]

    local trstart

    if team_id == TEAM_SPEC then
        trstart = pl:GetPos()
    else
        trstart = pl.FakePos
    end

    -- Make a traceline
    if trstart ~= nil then
        trace.start = trstart
        trace.endpos = trstart + (pl:GetAimVector() * 8000)
        trace.filter = pl

        util.TraceLine( trace )

        local hitent = trace_result.Entity
        if hitent ~= nil and hitent:IsValid() then
            local hitent_team = hitent:GetEntTeamForClient()

            -- if looking at a built structure
            if CheckIfInEntTable( hitent ) and not hitent:IsProjectile() and hitent:GetClass() ~= "ent_intermediary_structure" then
                local color = color_white

                local plural = ""

                if hitent:GetClass() == "structure_token" then
                    color = purple

                    if hitent:GetAmountDisplay() > 1 then
                        plural = "s"
                    end
                end

                local craftname = ConvertToCraftNameFromEntName_Craft( hitent:GetClass() )
                local craftref = TableReference_Craft( craftname )
                local hp = hitent:Health()

                if craftref ~= nil then
                    draw.SimpleTextOutlined( craftref.print_name .. plural, "TargetID", screen_width_half, screen_height_half - 100, color, 1, 1, 1, color_black )
                end

                --if its a general structure someone built
                if hitent:GetClass() ~= "structure_token" then
                    draw.SimpleTextOutlined( hp .. " hp", "TargetID", screen_width_half, screen_height_half - 80, color, 1, 1, 1, color_black )

                    if craftref.display_grabbable == true then
                        local green = Color( 71, 255, 120, 255 )
                        draw.SimpleTextOutlined( "Grabbable", "TargetID", screen_width_half, screen_height_half - 60, green, 1, 1, 1, color_black )
                    end

                    if hitent:GetClass() == "structure_quickport" then
                        local Puck = pl:GetNetPuck()
                        if IsValid( Puck ) then
                            local entref = EntReference( craftref.ent )

                            local distance = Puck:GetPos():Distance( hitent:GetPos() )
                            if distance < entref.radius then
                                draw.SimpleTextOutlined( "(In range)", "TargetID", screen_width_half, screen_height_half - 40, color, 1, 1, 1, color_black )
                            end
                        end
                    end

                    if craftref.on_zap_description ~= nil and hitent_team == team_id then
                        draw.SimpleTextOutlined( string.format( "On Zap:   ( %s )", craftref.on_zap_description ), "TargetID", 400, screen_height - 80, color, 1, 1, 1, color_black, TEXT_ALIGN_LEFT )
                    elseif hitent_team == GetOppositeTeam( team_id ) then
                        draw.SimpleTextOutlined( "On Zap:   ( Melee attack )", "TargetID", 400, screen_height - 80, color, 1, 1, 1, color_black, TEXT_ALIGN_LEFT )
                    end

                    -- for teleporters with entangled ents across the map, show their positon on the hud
                    if craftref.has_partner == true and IsValid( hitent:GetPartnerEnt() ) then
                        local partner = hitent:GetPartnerEnt()
                        local pos = partner:GetPos()
                        local pos_scr = pos:ToScreen()

                        draw.SimpleTextOutlined( craftref.partner_display, "TargetID", pos_scr.x, pos_scr.y, color, 1, 1, 1, color_black )
                    end
                else
                    draw.SimpleTextOutlined( hitent:GetAmountDisplay(), "TargetID", screen_width_half, screen_height_half - 80, color, 1, 1, 1, color_black )
                end
            elseif hitent:GetClass() == "ent_intermediary_structure" then
                local craftname = hitent:GetCraftForClient()

                local craftref = TableReference_Craft( craftname )
                local full_time = nil

                if craftref ~= nil then
                    draw.SimpleTextOutlined( craftref.print_name, "TargetID", screen_width_half, screen_height_half - 100, color_white, 1, 1, 1, color_black )
                    draw.SimpleTextOutlined( "Constructing...", "TargetID", screen_width_half, screen_height_half - 80, color_white, 1, 1, 1, color_black )

                    full_time = craftref.craft_time
                end

                --say what it does on zap
                draw.SimpleTextOutlined( "On Zap:   ( Cancel )", "TargetID", 400, screen_height - 80, color_white, 1, 1, 1, color_black, TEXT_ALIGN_LEFT )

                --show a bar that displays how long until its finished constructing
                local complete_time = hitent:GetCompleteTime()
                if complete_time ~= nil then
                    local cur_time = CurTime()
                    local display = RoundNum( (complete_time - cur_time), 1 )

                    if full_time ~= nil then
                        local difference = (full_time - (complete_time - cur_time))
                        -- draw.RoundedBox(0, screen_width/2, screen_height/2, full_time*4, 15, health_color_bg)
                        -- draw.RoundedBox(0, screen_width/2, screen_height/2, difference*4, 15, health_color)

                        local ratio = ((difference / full_time) * 100)

                        draw.RoundedBox( 0, screen_width_half - 55, screen_height_half - 65, 110, 25, Color( 100, 100, 100, 255 ) )
                        draw.RoundedBox( 0, screen_width_half - 50, screen_height_half - 60, 100, 15, color_black )
                        draw.RoundedBox( 0, screen_width_half - 50, screen_height_half - 60, ratio * 1, 15, Color( 255, 255, 255, 255 ) )

                        draw.SimpleTextOutlined( display, "TargetID", screen_width_half, screen_height_half - 30, color_white, 1, 1, 1, color_black )
                    end

                end

                --if looking at a player bug
            elseif hitent:IsValidPlyBug() then
                local name = hitent.Owner:Nick()
                local hp = hitent:Health()
                local tokens = hitent.Owner:GetTokens()

                draw.SimpleTextOutlined( name, "TargetID", screen_width_half, screen_height_half - 100, color_white, 1, 1, 1, color_black )
                draw.SimpleTextOutlined( hp .. " hp", "TargetID", screen_width_half, screen_height_half - 80, color_white, 1, 1, 1, color_black )
                draw.SimpleTextOutlined( tokens .. " tokens", "TargetID", screen_width_half, screen_height_half - 60, purple, 1, 1, 1, color_black )

            end
        end
    end

    -- dont render any of this stuff if the player doesnt durrently have a puck
    if pl:HasNetPuck() ~= true then return end

    --[[
    	HUD ability info
    --]]
    local Puck = pl:GetNetPuck()
    local Puckref = Puck:GetRef()

    local team_color

    if team_id == TEAM_RED then
        team_color = Color( 239, 69, 82, 255 )
    elseif team_id == TEAM_BLUE then
        team_color = Color( 97, 187, 211, 255 )
    else
        team_color = color_white
    end

    --]]
    --E key hud display
    draw.RoundedBox( 0, 0, screen_height - 200, 85, 45, color50 )        --background box
    draw.RoundedBox( 0, 85, screen_height - 195, 190, 35, color_50_180 ) --2nd background box
    draw.SimpleText( "'USE KEY'", "Trebuchet18", 40, screen_height - 195, team_color, TEXT_ALIGN_CENTER )

    local e_text = "Grab"
    if Puckref.override_e ~= nil then
        e_text = Puckref.override_e
    end

    draw.SimpleText( e_text, "DermaLarge", 100, screen_height - 195, color_200 )

    --]]
    --Shift key hud display
    draw.RoundedBox( 0, 0, screen_height - 150, 85, 45, color50 )        --background box
    draw.RoundedBox( 0, 85, screen_height - 145, 190, 35, color_50_180 ) --2nd background box
    draw.SimpleText( "'RUN KEY'", "Trebuchet18", 40, screen_height - 145, team_color, TEXT_ALIGN_CENTER )

    local shift_text = "Construct"
    if Puckref.override_shift ~= nil then
        shift_text = Puckref.override_shift
    end

    draw.SimpleText( shift_text, "DermaLarge", 100, screen_height - 145, color_200 )

    --if it has the crafting ray, draw the box which says what you will convert the thing to
    if Puckref.override_shift == nil then
        local craft = pl:GetCraft()
        local craftref = TableReference_Craft( craft )

        draw.RoundedBox( 0, 275, screen_height - 140, 140, 25, Color( 50, 50, 50, 110 ) )
        draw.SimpleText( string.format( "- %s", craftref.print_name ), "Trebuchet18", 280, screen_height - 135, color_white, TEXT_ALIGN_LEFT )
    end

    --]]
    --Ctrl key hud display
    draw.RoundedBox( 0, 0, screen_height - 100, 85, 45, color50 )       --background box
    draw.RoundedBox( 0, 85, screen_height - 95, 190, 35, color_50_180 ) --2nd background box
    draw.SimpleText( "'DUCK KEY'", "Trebuchet18", 40, screen_height - 95, team_color, TEXT_ALIGN_CENTER )

    if Puckref.override_alt == nil then
        draw.SimpleText( "Zap", "DermaLarge", 100, screen_height - 95, color_200 )
    else
        draw.SimpleText( Puckref.override_alt, "DermaLarge", 100, screen_height - 95, color_200 )
    end

    --]]
    --Control key hud display
    if Puckref.override_ctrl_off ~= true then
        draw.RoundedBox( 0, 0, screen_height - 50, 85, 45, color50 )        --background box
        draw.RoundedBox( 0, 85, screen_height - 45, 190, 35, color_50_180 ) --2nd background box
        draw.SimpleText( "'DUCK KEY'", "Trebuchet18", 40, screen_height - 45, team_color, TEXT_ALIGN_CENTER )

        local ctrl_text = "Fuse to Friend"
        if Puckref.override_ctrl ~= nil then
            ctrl_text = Puckref.override_ctrl
        end

        draw.SimpleText( ctrl_text, "DermaLarge", 100, screen_height - 45, color_200 )
    end

    --[[
		--]]
    --Alt key hud display
    draw.RoundedBox( 0, 0, screen_height - 50, 85, 45, color50 )        --background box
    draw.RoundedBox( 0, 85, screen_height - 45, 190, 35, color_50_180 ) --2nd background box
    draw.SimpleText( "'ALT'", "Trebuchet18", 40, screen_height - 45, color_white, TEXT_ALIGN_CENTER )

    if Puckref.override_alt == nil then
        draw.SimpleText( "Zap", "DermaLarge", 100, screen_height - 45, color_200 )
    else
        draw.SimpleText( Puckref.override_alt, "DermaLarge", 100, screen_height - 45, color_200 )
    end

    --]]
    --Control key hud display
    if Puckref.override_ctrl_off ~= true then
        draw.RoundedBox( 0, 0, screen_height - 100, 85, 45, color50 )       --background box
        draw.RoundedBox( 0, 85, screen_height - 95, 190, 35, color_50_180 ) --2nd background box
        draw.SimpleText( "'CTRL'", "Trebuchet18", 40, screen_height - 95, color_white, TEXT_ALIGN_CENTER )

        local ctrl_text = "Fuse to Friend"
        if Puckref.override_ctrl ~= nil then
            ctrl_text = Puckref.override_ctrl
        end

        draw.SimpleText( ctrl_text, "DermaLarge", 100, screen_height - 95, color_200 )
    end

    --]]

    local wep = pl:GetActiveWeapon()
    if wep ~= NULL then
        local swepref = wep:GetRef()

        --]]
        --Primary key hud display
        local primname = swepref.primary_print_name
        draw.RoundedBox( 0, screen_width - 85, screen_height - 235, 85, 45, color50 )        --background box
        draw.RoundedBox( 0, screen_width - 275, screen_height - 230, 190, 35, color_50_180 ) --2nd background box
        draw.SimpleText( "'PRIMARY'", "Trebuchet18", screen_width - 40, screen_height - 228, team_color, TEXT_ALIGN_CENTER )

        local AmmoPrimary = wep:Clip1()
        draw.SimpleText( tostring( AmmoPrimary ), "DermaLarge", screen_width - 250, screen_height - 228, (AmmoPrimary == 0) and color_pink or color_white, TEXT_ALIGN_CENTER )
        draw.SimpleText( primname, "DermaLarge", screen_width - 100, screen_height - 228, (AmmoPrimary == 0) and color_dark_pink or color_200, TEXT_ALIGN_RIGHT )

        if pl:GetGainedDamage() ~= 0 then
            local gain = pl:GetGainedDamage()
            draw.SimpleTextOutlined( "+" .. gain .. " dmg", "TargetID", screen_width - 100, screen_height - 250, color_white, 1, 1, 1, color_black )
        end

        --]]
        --Secondary key hud display
        local secname = swepref.secondary_print_name
        if secname ~= nil then
            draw.RoundedBox( 0, screen_width - 85, screen_height - 185, 85, 45, color50 )        --background box
            draw.RoundedBox( 0, screen_width - 275, screen_height - 180, 190, 35, color_50_180 ) --2nd background box
            draw.SimpleText( "'SECONDARY'", "Trebuchet18", screen_width - 40, screen_height - 178, team_color, TEXT_ALIGN_CENTER )

            local AmmoSecondary = wep:Clip2()
            draw.SimpleText( tostring( AmmoSecondary ), "DermaLarge", screen_width - 250, screen_height - 178, (AmmoSecondary == 0) and color_pink or color_white, TEXT_ALIGN_CENTER )
            draw.SimpleText( secname, "DermaLarge", screen_width - 100, screen_height - 178, (AmmoSecondary == 0) and color_dark_pink or color_200, TEXT_ALIGN_RIGHT )
        end

        --]]
        --Thirdary key hud display
        local third = pl:GetSwepAbility()
        if string.byte( third, 1, 1 ) ~= nil then
            local third_ref = SwepabilityReference( third )

            draw.RoundedBox( 0, screen_width - 85, screen_height - 135, 85, 45, color50 )        --background box
            draw.RoundedBox( 0, screen_width - 275, screen_height - 130, 190, 35, color_50_180 ) --2nd background box
            draw.SimpleText( "'RELOAD KEY'", "Trebuchet18", screen_width - 40, screen_height - 128, color_white, TEXT_ALIGN_CENTER )

            local AmmoThirdary = ""

            if third_ref.dont_show_ammo ~= true then
                AmmoThirdary = wep:Clip3()
            end

            if AmmoThirdary == 0 then
                draw.SimpleText( tostring( AmmoThirdary ), "DermaLarge", screen_width - 250, screen_height - 128, color_pink, TEXT_ALIGN_CENTER )
                draw.SimpleText( third_ref.print_name, "DermaLarge", screen_width - 100, screen_height - 128, color_dark_pink, TEXT_ALIGN_RIGHT )
            else
                draw.SimpleText( AmmoThirdary, "DermaLarge", screen_width - 250, screen_height - 128, color_white, TEXT_ALIGN_CENTER )
                draw.SimpleText( third_ref.print_name, "DermaLarge", screen_width - 100, screen_height - 128, color_200, TEXT_ALIGN_RIGHT )
            end
        end

    end

    local heldent = pl:GetHeldEnt()
    if heldent ~= 0 then
        local entref = EntReference( heldent )

        draw.RoundedBox( 0, screen_width - 85, screen_height - 320, 85, 20, color50 )
        draw.SimpleText( "INVENTORY:", "Trebuchet18", screen_width - 40, screen_height - 320, color_white, TEXT_ALIGN_CENTER )

        draw.RoundedBox( 0, screen_width - 140, screen_height - 300, 140, 20, color_50_180 )
        draw.SimpleText( entref.print_name, "Trebuchet18", screen_width - 70, screen_height - 300, Color( 100, 200, 100, 255 ), TEXT_ALIGN_CENTER )
    end

    --[[
        Quick menu display
    --]]

    if team_id ~= TEAM_SPEC then
        draw.RoundedBox( 0, 180, screen_height - 35, 125, 35, color50 )
        draw.SimpleText( "'Q' - Quick Menu", "Trebuchet18", 240, screen_height - 30, team_color, TEXT_ALIGN_CENTER )
    end

    --highlight keys as theyre pressed

    if keys[ 1 ] == true then
        --white highlight box
        draw.RoundedBox( 0, screen_width - 85, screen_height - 235, 85, 45, color_black_100 )
    end

    if keys[ 2048 ] == true then
        --white highlight box
        draw.RoundedBox( 0, screen_width - 85, screen_height - 185, 85, 45, color_black_100 )
    end

    if keys[ 8192 ] == true then
        --white highlight box
        draw.RoundedBox( 0, screen_width - 85, screen_height - 135, 85, 45, color_black_100 )
    end

    if keys[ 32 ] == true then
        --white highlight box
        draw.RoundedBox( 0, 0, screen_height - 200, 85, 45, color_black_100 )
    end

    if keys[ 131072 ] == true then
        --white highlight box
        draw.RoundedBox( 0, 0, screen_height - 150, 85, 45, color_black_100 )
    end

    -- if keys[ 262144 ] == true then
    --white highlight box
    -- draw.RoundedBox(0, 0, screen_height-100, 85, 45, Color(255,255,255,100))
    -- end

    if keys[ 4 ] == true then
        --white highlight box
        draw.RoundedBox( 0, 0, screen_height - 100, 85, 45, color_black_100 )
    end

    if buttons[ 27 ] == true then
        --white highlight box
        draw.RoundedBox( 0, 180, screen_height - 35, 125, 35, color_black_100 )
    end

    --old way
    --[[
	local Ability_A = pl:GetAbilityInfo("Primary")

	if Ability_A.name ~= "none" then

		draw.RoundedBox(0, 0, screen_height-185, 85, 45, Color(50,50,50,255))			--background box

		draw.RoundedBox(0, 85, screen_height-180, 190, 35, Color(50,50,50,180))			--2nd background box

		draw.SimpleText("'PRIMARY'", "Trebuchet18", 40, screen_height - 178, Color(255,255,255,255), TEXT_ALIGN_CENTER)

		local ref = AbilReference( Ability_A.name )

		--draw in red if its in cooldown (cant be used)
		if (Ability_A.cooldown) == true then
			draw.SimpleText( ConvertToPrintName(Ability_A.name), "DermaLarge", 100, screen_height - 178, Color(255,100,100,255))
		else
			draw.SimpleText( ConvertToPrintName(Ability_A.name), "DermaLarge", 100, screen_height - 178, Color(200,200,200,255))
		end

		--change display settings depending on if its single charge or multi charge.
		if ref.charges > 1 then
			--draw in red if they have 0 charges left
			if Ability_A.charges == 0 then
				draw.SimpleText( Ability_A.charges, "DermaLarge", 250, screen_height - 178, Color(255,100,100,255), TEXT_ALIGN_CENTER)
			else
				draw.SimpleText( Ability_A.charges, "DermaLarge", 250, screen_height - 178, Color(255,255,255,255), TEXT_ALIGN_CENTER)
			end
		else
			draw.SimpleText( Ability_A.time, "DermaLarge", 250, screen_height - 178, Color(255,100,100,255), TEXT_ALIGN_CENTER)
		end

	end



	local Ability_B = pl:GetAbilityInfo("Secondary")

	if Ability_B.name ~= "none" then

		draw.RoundedBox(0, 0, screen_height-235, 85, 45, Color(50,50,50,255))			--background box

		draw.RoundedBox(0, 85, screen_height-230, 190, 35, Color(50,50,50,180))			--2nd background box

		draw.SimpleText("'ALT'", "Trebuchet18", 40, screen_height - 228, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		if (Ability_B.cooldown) == true then
			draw.SimpleText( ConvertToPrintName(Ability_B.name), "DermaLarge", 100, screen_height - 228, Color(255,100,100,255))
			draw.SimpleText( Ability_B.time, "DermaLarge", 250, screen_height - 228, Color(255,100,100,255), TEXT_ALIGN_CENTER)
		else
			draw.SimpleText( ConvertToPrintName(Ability_B.name), "DermaLarge", 100, screen_height - 228, Color(200,200,200,255))
		end
	end


	local Ability_C = pl:GetAbilityInfo("c")

	if Ability_C.name ~= "none" then

		draw.RoundedBox(0, 0, screen_height-285, 85, 45, Color(50,50,50,255))			--background box

		draw.RoundedBox(0, 85, screen_height-280, 190, 35, Color(50,50,50,180))			--2nd background box

		draw.SimpleText("'IN_WALK'", "Trebuchet18", 40, screen_height - 278, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		if (Ability_C.cooldown) == true then
			draw.SimpleText( ConvertToPrintName(Ability_C.name), "DermaLarge", 100, screen_height - 278, Color(255,100,100,255))
			draw.SimpleText( Ability_C.time, "DermaLarge", 250, screen_height - 278, Color(255,100,100,255), TEXT_ALIGN_CENTER)
		else
			draw.SimpleText( ConvertToPrintName(Ability_C.name), "DermaLarge", 100, screen_height - 278, Color(200,200,200,255))
		end
	end
	--]]

    draw.RoundedBox( 10, (screen_width_half) - 3, (screen_height_half) - 3, 6, 6, Color( 0, 0, 0, 75 ) )

    if not IsValid( Puck ) then return end

    draw.RoundedBox( 0, screen_width - 420, screen_height - 50, 420, 50, color50 )                                                     --background box
    draw.RoundedBox( 0, screen_width - 405, screen_height - 35, 400, 25, (team_id == TEAM_RED) and color_dark_red or color_dark_blue ) --background health bar

    local health = math.max( 0, Puck:Health() )
    draw.RoundedBox( 0, screen_width - 405, screen_height - 35, ((health / Puck:GetMaxHealth()) * 100) * 4, 25, team_color ) --changing health bar
    draw.SimpleText( tostring( health ), "DermaLarge", screen_width - 405, screen_height - 38, color_white )                 --health number text

end
