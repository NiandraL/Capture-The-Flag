ENT.Type = "point"

ENT.Team = TEAM_BLUECTF

function ENT:Initialize()
	local ent = ents.Create( "ctf_teamflag" );
	ent:SetKeyValue( "team", self.Team );
	ent:SetPos( self:GetPos() + Vector( 0, 0, 20 ) );
	ent:SetAngles( self:GetAngles() );
	ent:Spawn()
	
	self:Remove();
end

function ENT:KeyValue( key, value )

	if( key == "TeamNum" ) then
		local num = tonumber( value );
		
		if( num == 3 ) then
			num = TEAM_BLUECTF
		end
		
		self.Team = tonumber( num );
	end
	
end