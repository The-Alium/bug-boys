---@class Entity
local PuckEnt = FindMetaTable( "Entity" )


function PuckEnt:Craft( location, get_angles )
    local owner = self:GetOwner()
    if owner == nil or not (owner:IsValid() and owner:IsPlayer()) then return end

    ---@cast owner Player


    --theres a limit to the amount of structures than can be built in the game during warmup
    --just so people dont spam the server with them and lag it out
    local phase = GetGamePhase()
    if phase == "PreGame" or phase == "NoPlayers" then
        local count = 0
        for k, ent in pairs( ents.GetAll() ) do
            if CheckIfInEntTable( ent ) and not ent:IsProjectile() and ent:GetClass() ~= "structure_bugbrain"
                and ent:GetClass() ~= "structure_bugbrain_shield" then
                -- print( ent:GetClass() )
                count = count + 1
            end
        end

        if count >= PREGAME_STRUCTURE_LIMIT then
            owner:ChatPrint( "Pregame structure limitation reached.  Can't build." )
            return
        end
    end

    local craft = owner:GetCraft()
    local craftref = TableReference_Craft( craft )

    --first check if they have enough money for it and such
    if owner:GetTokens() < craftref.crystals_required then
        owner:ChatPrint( "You don't have enough tokens to construct that structure.  It costs " .. craftref.crystals_required )
        owner:PlayLocalSound( "Sound_Failed" )
        self.CraftTimer = CurTime() + 1
        return
    end

    --make sure the player is near this location
    local distance = self:GetPos():Distance( location )
    if distance > 600 then
        owner:ChatPrint( "You are too far from that position" )
        owner:PlayLocalSound( "Sound_Failed" )
        self.CraftTimer = CurTime() + 1
        return
    end

    --create a beam effect
    local function BeamEffect( startpt, endpt )
        local effectdata = EffectData()
        effectdata:SetOrigin( endpt )
        effectdata:SetStart( startpt )
        effectdata:SetAttachment( 1 )
        effectdata:SetEntity( self )
        util.Effect( "ToolTracer", effectdata )
    end


    local function CreateEnt( pos, ang )
        --Trace stuff
        local Aim = owner:EyeAngles()
        local trpos = self:GetPos() + (Aim:Up() * (self.Ref.cam_height - 1))
        local ang = owner:GetAimVector()

        local tracedata = {}
        tracedata.start = trpos
        tracedata.endpos = trpos + (ang * 400)
        tracedata.filter = { self, owner }
        local trace = util.TraceLine( tracedata )

        local hitent = trace.Entity
        local normalz = trace.HitNormal[ 3 ]
        local nrml = trace.HitNormal

        BeamEffect( self:GetPos(), trace.HitPos )


        local obj = ents.Create( "ent_intermediary_structure" )
        local objref = EntReference( obj:GetClass() )
        obj:SetPos( pos )
        obj.Creator = owner
        obj.BBTeam = self.BBTeam
        obj.Craft = craft
        obj.CraftRef = craftref


        local ang_tbl =
        {
            { name = "1", ang = 90 },
            { name = "2", ang = 0 },
            { name = "3", ang = -90 },
            { name = "4", ang = 180 }
        }

        local function GetClosestAng()
            local eyeangles = owner:EyeAngles()
            local decided_ang = nil
            local prev_dif = 1000
            for _, thing in pairs( ang_tbl ) do
                local dif = 0
                local eyeangles_y = eyeangles.y
                if eyeangles.y < -135 then
                    eyeangles_y = 225
                end

                if eyeangles_y > thing.ang then
                    dif = eyeangles_y - thing.ang
                else
                    dif = thing.ang - eyeangles_y
                end

                if dif < prev_dif then
                    decided_ang = thing.name
                    prev_dif = dif
                end
            end

            return decided_ang
        end

        --new way which locks at 90 degrees
        if craftref.sets_angles == true then
            --for the ramp
            if IsValid( hitent ) and (hitent:GetClass() == "structure_wall" or hitent:GetClass() == "ent_intermediary_structure") and normalz == 0 then
                obj:SetPos( (hitent:GetPos() - Vector( 0, 0, 96 )) + (nrml * 240) )

                local nrml_ang = nrml:Angle()
                local newang = Angle( nrml_ang[ 1 ], nrml_ang[ 2 ] - 90, nrml_ang[ 3 ] )
                obj:SetAngles( newang )

            else
                local closest = GetClosestAng()
                local setnum = nil
                for _, thing in pairs( ang_tbl ) do
                    if thing.name == closest then
                        setnum = thing.ang
                        break
                    end
                end

                local newang = Angle( 0, setnum + 90, 0 )
                obj:SetAngles( newang )
            end
        end

        if craftref.special_ang ~= nil then
            -- print("SETTING ANG")
            obj:SetAngles( craftref.special_ang )
        end

        obj:Spawn()
    end



    local function BeginConstruction()
        owner:EmitSound( TEST_SOUND )

        owner:SubtractTokens( craftref.crystals_required )

        CreateEnt( location )
    end


    BeginConstruction()
end

--This is the old obsolete way

--onlytoken is a boolean that makes the function only craft tokens if its true
function PuckEnt:DoCraft( onlytoken )
    local owner = self:GetOwner()
    if owner == nil or not (owner:IsValid() and owner:IsPlayer()) then return end

    ---@cast owner Player

    --draw a ghost of the building for the player to place it more easily
    if (owner:KeyDown( IN_SPEED )) then
        --[[

		--Trace stuff
		local Aim = owner:EyeAngles()
		local pos = self:GetPos() + (Aim:Up() * ( self.Ref.cam_height - 1))
		local ang = owner:GetAimVector()

		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang * self.Ref.craft_dist)
		tracedata.filter = self, owner
		local trace = util.TraceLine(tracedata)

		local hitent = trace.Entity
		local normalz = trace.HitNormal[3]


		local showing = false

		if trace.HitWorld and normalz > .8 then
			owner:SetShowGhost( true )
			 showing = true

		elseif trace.HitNonWorld and normalz > 0 then
			if hitent:GetClass() == "structure_wall" then
				owner:SetShowGhost( true )
				showing = true
			end
		end

		if showing == false then
			owner:SetShowGhost( false )
		end

	else
		owner:SetShowGhost( false )

	--]]
        owner:SetShowGhost( true )

    else
        owner:SetShowGhost( false )

    end

    --when the player releases the key, the structure starts to build
    -- if (owner:KeyDown(IN_SPEED)) then
    if (owner:KeyReleased( IN_SPEED )) then
        owner:BBChatPrint( "RELEASED SHIFT" )

        owner:SetShowGhost( false )

        if (self.CraftTimer < CurTime()) then

            local craft = owner:GetCraft()
            local craftref = TableReference_Craft( craft )

            if onlytoken == true then
                craft = "craft_token"
                craftref = TableReference_Craft( craft )
            end

            --first check if they have enough money for it and such
            if owner:GetTokens() < craftref.crystals_required then
                owner:ChatPrint( "You don't have enough tokens to construct that structure.  It costs " .. craftref.crystals_required )
                owner:PlayLocalSound( "Sound_Failed" )
                self.CraftTimer = CurTime() + 1
                return
            end

            --Trace stuff
            local Aim = owner:EyeAngles()
            local pos = self:GetPos() + (Aim:Up() * (self.Ref.cam_height - 1))
            local ang = owner:GetAimVector()

            local tracedata = {}
            tracedata.start = pos
            tracedata.endpos = pos + (ang * self.Ref.craft_dist)
            tracedata.filter = self, owner
            local trace = util.TraceLine( tracedata )

            local hitent = trace.Entity
            local normalz = trace.HitNormal[ 3 ]


            --create a beam effect
            local function BeamEffect( startpt, endpt )
                local effectdata = EffectData()
                effectdata:SetOrigin( endpt )
                effectdata:SetStart( startpt )
                effectdata:SetAttachment( 1 )
                effectdata:SetEntity( self )
                util.Effect( "ToolTracer", effectdata )
            end


            local function CreateEnt( pos, ang )
                local obj = ents.Create( "ent_intermediary_structure" )
                local objref = EntReference( obj:GetClass() )
                obj:SetPos( pos )
                obj.Creator = owner
                obj.BBTeam = self.BBTeam
                obj.Craft = craft
                --[[
					if self.BBTeam == TEAM_RED then
						obj:SetMaterial( objref.special_mat_red )
					elseif self.BBTeam == TEAM_BLUE then
						obj:SetMaterial( objref.special_mat_blue )
					end
					--]]

                local eyeangles = owner:EyeAngles()
                local newang = Angle( 0, eyeangles.y + 90, 0 )
                -- local finalang = newang:Forward()

                if craftref.sets_angles == true then
                    -- print("SETTING ANG")
                    obj:SetAngles( newang )
                end

                if craftref.special_ang ~= nil then
                    -- print("SETTING ANG")
                    obj:SetAngles( craftref.special_ang )
                end

                obj:Spawn()
            end


            local function VerifyCanBuildThis()
                --players can only build 1 of teleport entrance/exit
                if craft == "craft_teleport_entrance" or craft == "craft_teleport_exit" then
                    for k, allent in pairs( ents.GetAll() ) do
                        if allent.Creator == owner and allent:GetClass() == craftref.ent then

                            owner:ChatPrint( "You can only build 1 " .. craftref.print_name )
                            owner:PlayLocalSound( "Sound_Failed" )

                            return false
                        elseif allent.Creator == owner and allent:GetClass() == "ent_intermediary_structure" and allent.Ent == craftref.ent then

                            owner:ChatPrint( "You can only build 1 " .. craftref.print_name )
                            owner:PlayLocalSound( "Sound_Failed" )

                            return false
                        end
                    end
                end

                return true
            end


            local function BeginConstruction()
                if VerifyCanBuildThis() then
                    owner:EmitSound( TEST_SOUND )
                    BeamEffect( self:GetPos(), trace.HitPos )

                    owner:SubtractTokens( craftref.crystals_required )

                    CreateEnt( trace.HitPos )
                end
            end


            --create the construction entity and subtract the player's tokens
            -- print( normalz )
            if trace.HitWorld and normalz > .8 then
                BeginConstruction()
            elseif trace.HitNonWorld and normalz > 0 then
                if hitent:GetClass() == "structure_wall" then
                    BeginConstruction()
                end
            end

        end
    end
end
