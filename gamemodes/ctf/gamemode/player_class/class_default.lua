local CLASS = {}
 
CLASS.DisplayName			= "Default Class"
CLASS.WalkSpeed 			= 300
CLASS.CrouchedWalkSpeed 	= 0.8
CLASS.RunSpeed				= 400
CLASS.DuckSpeed				= 0.6
CLASS.JumpPower				= 250
CLASS.DrawTeamRing			= true
CLASS.DrawViewModel			= true
CLASS.CanUseFlashlight      = true
CLASS.MaxHealth				= 100
CLASS.StartHealth			= 100
CLASS.StartArmor			= 0
CLASS.RespawnTime           = 0 // 0 means use the default spawn time chosen by gamemode
CLASS.DropWeaponOnDie		= true
CLASS.TeammateNoCollide 	= true
CLASS.AvoidPlayers			= true // Automatically avoid players that we're no colliding
CLASS.Selectable			= false // When false, this disables all the team checking

local CTFList = {
	"weapon_xm1014",
	"weapon_usp",
	"weapon_tmp",
	"weapon_sg552",
	"weapon_sg550",
	"weapon_scout",
	"weapon_mac10",
	"weapon_m249",
	"weapon_m4a1",
	"weapon_m3super90",
	"weapon_g3sg1",
	"weapon_awp",
	"weapon_aug",
	"weapon_ak47"
}

local Secondaryist = {
	"weapon_357",
	"weapon_deagle",
	"weapon_fiveseven",
	"weapon_p228",
	"weapon_usp"
}

function CLASS:OnSpawn( pl )
	
	pl:SetupHands()
	
		pl:ChatPrint("Spawn protection enabled!")
		pl:Give(table.Random(CTFList))
		pl:Give(table.Random(Secondaryist))
		pl:Give("weapon_knife")
		
		local color = team.GetColor( pl:Team() );
		pl:SetColor( Color(color.r, color.g, color.b, 180));
		
		timer.Simple(5, function()
			pl:GodDisable()
			pl:ChatPrint("Spawn protection disabled!")
		end)	
	
end
 
function CLASS:OnDeath( pl, attacker, dmginfo )	
end
 
player_class.Register( "Default", CLASS )