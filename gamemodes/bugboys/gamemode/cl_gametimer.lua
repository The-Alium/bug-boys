--[[
	Client Game Time Display
--]]

local curgametime = "00:00"

local time2sound = {
    [ "00:05" ] = "vo/announcer_begins_5sec.wav",
    [ "00:04" ] = "vo/announcer_begins_4sec.wav",
    [ "00:03" ] = "vo/announcer_begins_3sec.wav",
    [ "00:02" ] = "vo/announcer_begins_2sec.wav",
    [ "00:01" ] = "vo/announcer_begins_1sec.wav",
}

local GetShieldHealth = GetShieldHealth
local LocalPlayer = LocalPlayer
local draw = draw

local TEAM_RED = TEAM_RED
local TEAM_BLUE = TEAM_BLUE
local TEAM_SPEC = TEAM_SPEC

local SHIELD_HP = SHIELD_HP

local function GameTimerUpdate( num )
    curgametime = num:ReadString()

    -- local dosounds = GetGlobalBool("CL_PlayTimerCountSounds")
    -- if dosounds ~= true then return end

    local snd = time2sound[ curgametime ]
    if snd ~= nil then
        surface.PlaySound( snd )
    end

    if curgametime == "00:05" then
        -- surface.PlaySound( "vo/announcer_begins_5sec.wav" )
        surface.PlaySound( "buttons/button3.wav" )
    elseif curgametime == "00:04" then
        -- surface.PlaySound( "vo/announcer_begins_4sec.wav" )
        surface.PlaySound( "buttons/button3.wav" )
    elseif curgametime == "00:03" then
        -- surface.PlaySound( "vo/announcer_begins_3sec.wav" )
        surface.PlaySound( "buttons/button3.wav" )
    elseif curgametime == "00:02" then
        -- surface.PlaySound( "vo/announcer_begins_2sec.wav" )
        surface.PlaySound( "buttons/button3.wav" )
    elseif curgametime == "00:01" then
        -- surface.PlaySound( "vo/announcer_begins_1sec.wav" )
        surface.PlaySound( "buttons/button3.wav" )
    end
end

usermessage.Hook( "GameTimerUpdate", GameTimerUpdate )

local color_white = color_white
local red_color = Color( 239, 69, 82, 255 )
local blue_color = Color( 97, 187, 211, 255 )
local color_black = Color( 0, 0, 0, 255 )
local color_green = Color( 0, 255, 0, 255 )
local color_red = Color( 255, 0, 0, 255 )

local game_time = {
    pos = { 0, 25 },
    color = color_white

}


game_time.font = "DermaLarge"
game_time.xalign = TEXT_ALIGN_CENTER -- Horizontal Alignment
game_time.yalign = TEXT_ALIGN_CENTER -- Vertical Alignment

local color1 = Color( 50, 50, 50, 255 )
local GetGlobalBool = GetGlobalBool

hook.Add( "HUDPaint", "TimeHud", function()
    -- draw.SimpleText(curgametime, "DermaLarge", 10, ScrH() - 100, Color(255,255,255,255))

    local screen_width = ScrW()
    local screen_width_half = screen_width * 0.5

    -- the grey box behind the time display text
    draw.RoundedBox( 20, screen_width_half - 50, 0, 100, 45, color1 )

    game_time.pos[ 1 ] = screen_width_half
    game_time.text = curgametime

    draw.Text( game_time )

    -- this should be fixed cause it spams overtime
    if GetGlobalBool( "CL_DrawOvertime" ) then
        surface.PlaySound( "vo/announcer_overtime.wav" )
        draw.SimpleText( "OVERTIME", "SmallerFont", (screen_width_half) + 200, 140, color_white )
    end

    --[[
	local redscore = team.GetScore( TEAM_RED )
	draw.SimpleTextOutlined( redscore .. "/" .. GetMaxScore() .. "    -", "TargetID", screen_width/2 - 80, 25, Color(255, 190, 190, 255), 1, 1, 1, Color(0, 0, 0, 255))

	local bluescore = team.GetScore( TEAM_BLUE )
	draw.SimpleTextOutlined( "-    " .. bluescore ..  "/" .. GetMaxScore(), "TargetID", screen_width/2 + 80, 25, Color(190, 190, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
	--]]

    --[[
	if phase == "BegunGame" or phase == "EndGame" then
		local reddeaths = GetHowManyDeaths( TEAM_RED )
		if reddeaths == 1 then
			draw.SimpleTextOutlined( reddeaths .. "  death    ", "TargetID", screen_width/2 - 80, 25, Color(255, 190, 190, 255), 1, 1, 1, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined( reddeaths .. "  deaths    ", "TargetID", screen_width/2 - 80, 25, Color(255, 190, 190, 255), 1, 1, 1, Color(0, 0, 0, 255))
		end

		local bluedeaths = GetHowManyDeaths( TEAM_BLUE )
		if bluedeaths == 1 then
			draw.SimpleTextOutlined( "    " .. bluedeaths ..  " death", "TargetID", screen_width/2 + 80, 25, Color(190, 190, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined( "    " .. bluedeaths ..  " deaths", "TargetID", screen_width/2 + 80, 25, Color(190, 190, 255, 255), 1, 1, 1, Color(0, 0, 0, 255))
		end
	end
	--]]

    --show bug brain health
    local phase = GetGamePhase()
    if phase == "BegunGame" or phase == "EndGame" then
        --red bug brain health
        local red_hp = GetBrainHealth( TEAM_RED )
        local red_ratio = ((red_hp / BRAIN_HP) * 100)

        surface.SetDrawColor( 100, 100, 100, 255 )
        surface.DrawRect( screen_width_half - 170, 15, 110, 25 )

        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawRect( screen_width_half - 165, 20, 100, 15 )

        surface.SetDrawColor( 239, 69, 82, 255 )
        surface.DrawRect( screen_width_half - 165, 20, red_ratio, 15 )

        draw.SimpleTextOutlined( red_hp .. "  hp", "TargetID", screen_width_half - 115, 8, red_color, 1, 1, 1, color_black )

        local red_hp_shield = GetShieldHealth( TEAM_RED )
        local red_ratio_shield = ((red_hp_shield / SHIELD_HP) * 100)

        surface.SetDrawColor( 200, 200, 200, 255 )
        surface.DrawRect( screen_width_half - 165, 25, red_ratio_shield, 5 )

        --blue bug brain health
        local blue_hp = GetBrainHealth( TEAM_BLUE )
        local blue_ratio = ((blue_hp / BRAIN_HP) * 100)

        surface.SetDrawColor( 100, 100, 100, 255 )
        surface.DrawRect( screen_width_half + 60, 15, 110, 25 )

        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawRect( screen_width_half + 65, 20, 100, 15 )

        surface.SetDrawColor( 97, 187, 211, 255 )
        surface.DrawRect( screen_width_half + 65, 20, blue_ratio * 1, 15 )

        draw.SimpleTextOutlined( blue_hp .. "  hp", "TargetID", screen_width_half + 115, 8, blue_color, 1, 1, 1, color_black )

        local blue_hp_shield = GetShieldHealth( TEAM_BLUE )
        local blue_ratio_shield = ((blue_hp_shield / SHIELD_HP) * 100)

        surface.SetDrawColor( 200, 255, 200, 150 )
        surface.DrawRect( screen_width_half + 65, 25, blue_ratio_shield, 5 )
    end

    if phase == "NoPlayers" then
        if (GetGlobalBool( "Pub_Mode", false ) == true) then
            draw.SimpleTextOutlined( "WAITING FOR PLAYERS", "TargetID", screen_width_half, 55, color_white, 1, 1, 1, color_black, TEXT_ALIGN_CENTER )
        else
            draw.SimpleTextOutlined( "WAITING FOR PLAYERS TO READY-UP", "TargetID", screen_width_half, 55, color_white, 1, 1, 1, color_black, TEXT_ALIGN_CENTER )
        end
    elseif phase == "PreGame" then
        draw.SimpleTextOutlined( "GAME STARTING...", "TargetID", screen_width_half, 55, color_white, 1, 1, 1, color_black, TEXT_ALIGN_CENTER )
    elseif phase == "SetupGame" then
        draw.SimpleTextOutlined( "SETUP YOUR DEFENSES", "TargetID", screen_width_half, 55, color_white, 1, 1, 1, color_black, TEXT_ALIGN_CENTER )
    elseif phase == "BegunGame" then
        draw.SimpleTextOutlined( "KILL THE ENEMY BUG BRAINnot ", "TargetID", screen_width_half, 55, color_white, 1, 1, 1, color_black, TEXT_ALIGN_CENTER )
    elseif phase == "EndGame" then
        draw.SimpleTextOutlined( "A TEAM WONnot ", "TargetID", screen_width_half, 55, color_white, 1, 1, 1, color_black, TEXT_ALIGN_CENTER )
    end

    --old method for team score
    --[[
	local red = Color(255, 200, 200, 255)
	local blue = Color(200, 200, 255, 255)

	local redscore = team.GetScore( TEAM_RED )
	local bluescore = team.GetScore( TEAM_BLUE )

	if bluescore < 10 then
		bluescore = (0 .. tostring(bluescore))
	end
	if redscore < 10 then
		redscore = (0 .. tostring(redscore))
	end

	if phase == "BegunGame" then
		draw.SimpleTextOutlined(redscore, "CustomBBFont_A", 35, 0, red, 3, 3, 3, Color(0, 0, 0, 255))
		draw.SimpleTextOutlined("Red Score", "TargetID", 60, 110, red, 3, 3, 3, Color(0, 0, 0, 255))


		draw.SimpleTextOutlined(bluescore, "CustomBBFont_A", screen_width-160, 0, blue, 3, 3, 3, Color(0, 0, 0, 255))
		draw.SimpleTextOutlined("Blue Score", "TargetID", screen_width-135, 110, blue, 3, 3, 3, Color(0, 0, 0, 255))
	end
	--]]

    local pl = LocalPlayer()
    local team_id = pl:Team()

    if phase == "EndGame" then
        if GetWinningTeam() == TEAM_RED or GetWinningTeam() == TEAM_BLUE then
            if GetWinningTeam() == TEAM_BLUE then
                draw.SimpleTextOutlined( "Blue team winsnot ", "CustomBBFont_A", 100, 100, blue_color, 3, 3, 3, color_black )
            elseif GetWinningTeam() == TEAM_RED then
                draw.SimpleTextOutlined( "Red team winsnot ", "CustomBBFont_A", 100, 100, red_color, 3, 3, 3, color_black )
            end

            -- --play a winning or losing sound
            -- if GetWinningTeam() == plyteam then
            --     --winning sound
            -- else
            --     --losing sound
            -- end
        else
            draw.SimpleTextOutlined( "It's a draw...", "CustomBBFont_A", 100, 100, color_white, 3, 3, 3, color_black )
        end
    end

    --help info

    -- if phase == "NoPlayers" or phase == "PreGame" then
    --     -- draw.SimpleTextOutlined("(Press F2 to switch teams or ready up)", "TargetID", 400, 15, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT)
    --     -- draw.SimpleTextOutlined("(type not votekick to kick someone)", "TargetID", 200, 15, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT)
    -- else
    --     -- draw.SimpleTextOutlined("(Press F2 to switch teams)", "TargetID", 400, 15, Color(255, 255, 255, 255), 1, 1, 1, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT)
    -- end

    --ready up
    if phase == "NoPlayers" or phase == "PreGame" then
        if team_id == TEAM_SPEC then
            draw.SimpleTextOutlined( "(Press F2 to join a team)", "TargetID", 400, 15, color_white, 1, 1, 1, color_black )
            return
        end

        if GetGlobalBool( "Pub_Mode", false ) ~= true then
            draw.SimpleTextOutlined( pl:Nick() .. " : ", "CustomBBFont_B", screen_width - 400, 10, color_white, 3, 3, 3, color_black )
            if pl:GetIfReady() then
                draw.SimpleTextOutlined( "Ready", "CustomBBFont_C", screen_width - 400, 50, color_green, 3, 3, 3, color_black )
            else
                draw.SimpleTextOutlined( "Not Ready", "CustomBBFont_C", screen_width - 400, 50, color_red, 3, 3, 3, color_black )
                draw.SimpleTextOutlined( "(Press F2 to ready up in the menu)", "TargetID", screen_width - 270, 130, color_white, 1, 1, 1, color_black )
            end
        end
    end
end )
