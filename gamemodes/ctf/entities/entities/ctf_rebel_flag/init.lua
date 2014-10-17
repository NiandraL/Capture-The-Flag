ENT.Type = "point"

function ENT:Initialize()
	local ent = ents.Create( "ctf_teamflag" );
	ent:SetKeyValue( "team", TEAM_RED );
	ent:SetPos( self:GetPos() + Vector( 0, 0, 50 ) );
	ent:SetAngles( self:GetAngles() );
	ent:Spawn()
	
	SetGlobalEntity( "RedFlag", self.Entity );
	SetGlobalVector( "RedFlag_Pos", self.Entity:GetPos() );
	
	self:Remove();
end
