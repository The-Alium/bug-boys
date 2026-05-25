ENT.Type      = "brush"
ENT.Base      = "base_anim"
ENT.PrintName = ""


if not SERVER then return end

------------------------------------------------------------------------------------------------
--all server from now on
------------------------------------------------------------------------------------------------

function ENT:StartTouch( entity )
    if GetGamePhase() ~= "SetupGame" then return end

    if entity.BBTeam == TEAM_RED and entity:IsValidPlyBug() then
        entity:Break()
    end
end
