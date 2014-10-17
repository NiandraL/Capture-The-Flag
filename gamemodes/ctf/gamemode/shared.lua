include( "player_extensions_sh.lua" );

DeriveGamemode( "fretta13" )
IncludePlayerClasses()

ctf_scorelimit = CreateConVar( "ctf_scorelimit", "5", FCVAR_GAMEDLL + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE );

GM.Name 	= "Capture the Flag"
GM.Author 	= "SteveUK (Fixed by Niandra Lades)"
GM.Email 	= "stephen.swires@gmail.com"
GM.Website 	= "http://s-swires.org"
GM.Help		= "Capture the enemy flag and return it to your base\n\n\n\nHow it works:\nYou take the enemy flag and take it to your base, but your flag must be at your base for the capture to work. If the overlay on your HUD has a red cross over it, it means someone has taken it and you must find it. Once you touch your team's dropped flag it is instantly returned to base.\n\nCreated by SteveUK. Effects by CapsAdmin and ZpankR"

GM.TeamBased = true
GM.AllowAutoTeam = true
GM.AllowSpectating = true
GM.SecondsBetweenTeamSwitches = 5
GM.GameLength = 60 * 10
GM.RoundLimit = 1
GM.RoundLength = 60 * 10
GM.NoPlayerDamage = false
GM.NoPlayerSelfDamage = false		// Allow players to hurt themselves?
GM.NoPlayerTeamDamage = true		// Allow team-members to hurt each other?
GM.NoPlayerPlayerDamage = false 	// Allow players to hurt each other?
GM.NoNonPlayerPlayerDamage = false 	// Allow damage from non players (physics, fire etc)
GM.MaximumDeathLength = 5			// Player will repspawn if death length > this (can be 0 to disable)
GM.MinimumDeathLength = 5			// Player has to be dead for at least this long
GM.ForceJoinBalancedTeams = true	// Players won't be allowed to join a team if it has more players than another team
GM.AutomaticTeamBalance = true   // Teams will be periodically balanced 
GM.SelectClass = false
GM.TeamScoreLimit = 5
GM.NoAutomaticSpawning = false		// Players don't spawn automatically when they die, some other system spawns them
GM.RoundBased = true				// Round based, like CS
GM.RoundEndsWhenOneTeamAlive = false
GM.RealisticFallDamage = false
GM.AddFragsToTeamScore = false
GM.ValidSpectatorModes = { OBS_MODE_CHASE, OBS_MODE_IN_EYE }

TEAM_BLUECTF 		= 1
TEAM_REDCTF 		= 2

function GetMapName()
	return game.GetMap();
end


/*---------------------------------------------------------
   Name: gamemode:CreateTeams()
   Desc: Note - HAS to be shared.
---------------------------------------------------------*/
function GM:CreateTeams()

	if ( !GAMEMODE.TeamBased ) then return end
	
		team.SetUp( TEAM_BLUECTF, "Team Blue", Color( 80, 150, 255 ), true )
		team.SetSpawnPoint( TEAM_BLUECTF, { "info_player_deathmatch", "info_player_combine", "info_player_counterterrorist", "info_player_allies","ctf_combine_player_spawn" }, true )
		team.SetClass( TEAM_BLUECTF, { "Default" } )
		
		team.SetUp( TEAM_REDCTF, "Team Red", Color( 255, 80, 80 ), true )
		team.SetSpawnPoint( TEAM_REDCTF, { "info_player_deathmatch", "info_player_rebels", "info_player_terrorist", "info_player_axis", "ctf_rebel_player_spawn" }, true )
		team.SetClass( TEAM_REDCTF, { "Default" } )
		
		team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 200, 200, 200 ), true )
		team.SetSpawnPoint( TEAM_SPECTATOR, "info_player_start", "point_viewcontrol" )
		team.SetClass( TEAM_SPECTATOR, { "Spectator" } )
	end
	

MAP = {}
function GM:Initialize()
	
	self.BaseClass:Initialize()

	if( CLIENT ) then
		GAMEMODE:InitializeClient();
	end
	
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo ) 

	if( hitgroup == HITGROUP_HEAD ) then
		dmginfo:ScaleDamage( 5 );
	elseif( hitgroup == HITGROUP_CHEST ) then
		dmginfo:ScaleDamage( 1.7 );
	elseif( hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM ) then
		dmginfo:ScaleDamage( 0.25 );
	elseif( hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG ) then
		dmginfo:ScaleDamage( 0.33 );
	else
		dmginfo:ScaleDamage( 1 );
	end
	
end

function GM:InitPostEntity( )

	GAMEMODE:LoadMapInfo();
		
	if( MAP and MAP.CustomTeamSetup ) then
		GAMEMODE:CreateTeams(); -- again
	end
	
	MAP:SpawnEntities();
	
	self.BaseClass:InitPostEntity();
	
end

function GM:LoadMapInfo()
	local Folder = string.Replace( GAMEMODE.Folder, "gamemodes/", "" );
	
	if( SERVER ) then
		AddCSLuaFile( Folder .. "/gamemode/maps/default_map.lua" );
		AddCSLuaFile( Folder .. "/gamemode/maps/" .. GetMapName() );	
	end
	
	include( Folder .. "/gamemode/maps/default_map.lua" );
	
	if( file.Exists( "../" .. GAMEMODE.Folder .. "/gamemode/maps/" .. GetMapName() .. ".lua", "GAME" ) ) then
		include( Folder .. "/gamemode/maps/" .. GetMapName() .. ".lua" );
	end
	
	Msg( "Loaded map info for " .. GetMapName() .. " (" .. MAP.FriendlyName .. ")\n" ); 
	
	if( MAP.RemoveItems and SERVER ) then
		timer.Simple( 1.5, MAP.RemoveEntByClass, MAP, "weapon_*" );
		timer.Simple( 1.5, MAP.RemoveEntByClass, MAP, "item_*" );
		timer.Simple( 1.5, MAP.RemoveEntByClass, MAP, "ammo_*" );
	end
end

function GM:Think()
	
	if( CLIENT ) then
		
		local red_flag = GetGlobalEntity( "flag_2" );
		local blue_flag = GetGlobalEntity( "flag_1" );
		
		if( IsValid( red_flag ) and IsValid( blue_flag ) ) then
			local r_carrier = red_flag:GetNetworkedEntity( "carrier" );
			local b_carrier = blue_flag:GetNetworkedEntity( "carrier" );
			
			if( red_flag:GetNetworkedBool( "stolen" ) == true and IsValid( r_carrier ) ) then
				r_carrier:TeamDynamicLight( TEAM_REDCTF )			
			end

			if( blue_flag:GetNetworkedBool( "stolen" ) == true and IsValid( b_carrier ) ) then
				b_carrier:TeamDynamicLight( TEAM_BLUECTF )
			end			
		end
	end
	
	for k, v in pairs( player.GetAll() ) do
		v:Think();
	end
end

