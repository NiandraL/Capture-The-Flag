
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "player_extensions_sh.lua" );
AddCSLuaFile( "cl_deathnotice.lua" );
AddCSLuaFile( "cl_postprocess.lua" );
AddCSLuaFile( "cl_scores.lua" );
AddCSLuaFile( "skin.lua" );

include( "shared.lua" )
include( "utility.lua" )

-- content to download from server
resource.AddFile("materials/ctf/flag.png")

function GM:OnPreRoundStart( num )

	game.CleanUpMap()
	
	UTIL_SpawnAllPlayers()

end

function GM:SetTeamFlag( team, flag )

	if( flag and flag:IsValid() ) then
		SetGlobalEntity( "flag_" .. tostring( team ), flag );
	end
	
end

function GM:CanStartRound()
	if #team.GetPlayers( TEAM_BLUECTF ) + #team.GetPlayers( TEAM_RED ) >= 2 then return true end
	return false
end






function GM:PlayerCanPickupWeapon(ply, wep)
	if #ply:GetWeapons() >= 4 then
		return false
	end

	return true
end



function GM:PlayerSpawn( pl ) 
	
	self.BaseClass:PlayerSpawn( pl )	

end

hook.Add("KeyPress", "DoubleJump", function(pl, k)
	if not pl or not pl:IsValid() or k~=2 then
		return
	end
		
	if not pl.Jumps or pl:IsOnGround() then
		pl.Jumps=0
	end
	
	if pl.Jumps==2 then return end
	
	pl.Jumps = pl.Jumps + 1
	if pl.Jumps==2 then
		local ang = pl:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * pl:GetVelocity() -- Nullify current velocity
		vel = vel + Vector(0, 0, 300) -- Add vertical force
		
		local spd = pl:GetMaxSpeed()
		
		if pl:KeyDown(IN_FORWARD) then
			vel = vel + forward * spd
		elseif pl:KeyDown(IN_BACK) then
			vel = vel - forward * spd
		end
		
		if pl:KeyDown(IN_MOVERIGHT) then
			vel = vel + right * spd
		elseif pl:KeyDown(IN_MOVELEFT) then
			vel = vel - right * spd
		end
		
		pl:SetVelocity(vel)
	end
end)
		
function GM:PlayerShouldTakeDamage( victim, attacker )
	
	if( victim.Protected ) then
		return false
	end
	
	return self.BaseClass:PlayerShouldTakeDamage( victim, attacker );
	
end

function GM:PlayerDisconnected( pl )

	local enemy = TEAM_RED;
	
	if( pl:Team() == TEAM_RED ) then
		enemy = TEAM_BLUECTF
	end
	
	local flag = GetGlobalEntity( "flag_" .. tostring( enemy ) );
	
	if( flag and flag:IsValid() ) then
		local carrier = flag:GetNetworkedEntity( "carrier" );
		
		if( carrier and carrier:IsValid() and carrier == pl ) then
			flag:FlagDropped( carrier );
		end
	end
	
	self.BaseClass:PlayerDisconnected( pl );
end

function GM:DoPlayerDeath( pl, attacker, dmginfo ) 

	local team = pl:Team();
	local enemy_flag = nil;
	local enemy_team = TEAM_RED;
	
	if( team == TEAM_RED ) then
		enemy_flag = GetGlobalEntity( "flag_1" );
		enemy_team = TEAM_BLUECTF
	else
		enemy_flag = GetGlobalEntity( "flag_2" );
	end
	
	if( enemy_flag and enemy_flag:IsValid() and enemy_flag:GetNetworkedBool( "stolen" ) ) then
		local carrier = enemy_flag:GetNetworkedEntity( "carrier" );
		
		if( carrier and carrier:IsValid() and carrier == pl ) then
			enemy_flag:FlagDropped( pl );
		end
	end
	
	pl:SetNetworkedFloat( "respawnTime", CurTime() + GAMEMODE.MinimumDeathLength );
	
	
	
	self.BaseClass:DoPlayerDeath( pl, attacker, dmginfo );
end

function GM:HandleWin( red, blue )

	local winningTeam = TEAM_RED;
	
	if( blue > red ) then
		winningTeam = TEAM_BLUECTF
	end
	
	for k, v in pairs( player.GetAll() ) do
		if( v:Team() == winningTeam ) then
			v:SendLua( "LocalPlayer():EmitSound( \"Game.YourTeamWon\" )");
		else
			v:SendLua( "LocalPlayer():EmitSound( \"Game.YourTeamLost\" )");
		end
	end
	
	PrintMessage( HUD_PRINTCENTER, team.GetName( winningTeam ) .. " win" );
end

function GM:EndOfGame( bGamemodeVote )

	SetGlobalBool( "interval", true );
	
	local red_score = team.GetScore( TEAM_RED );
	local blue_score = team.GetScore( TEAM_BLUECTF );
	
	if( red_score == blue_score ) then
		BroadcastLua( "LocalPlayer():EmitSound( \"Game.Stalemate\" )");
		PrintMessage( HUD_PRINTCENTER, "Game draw!" );
	else
		GAMEMODE:HandleWin( red_score, blue_score );
	end

	self.BaseClass:EndOfGame( bGamemodeVote );

end

function GM:AddFlagMessage( player, team, vteam, action )

	local rp = RecipientFilter();
	rp:AddAllPlayers();

	umsg.Start( "PlayerFlagAction", rp );
		umsg.Entity( player );
		umsg.Short( team );
		umsg.Short( vteam );
		umsg.String( action );
	umsg.End();
	
end

