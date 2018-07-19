rattletrap_tower_cog = class({})

--------------------------------------------------------------------------------

function rattletrap_tower_cog:CastFilterResultLocation(vLocation)
	
	local caster = self:GetCaster()			
	local search_radius = self:GetSpecialValueFor("search_radius")
	local unit_name = "npc_dota_rattletrap_tower_cog"
	
	local search_table = FindUnitsInRadius( caster:GetTeamNumber(), vLocation, nil, search_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false ) 
	
	if #search_table > 0 then
		for i,v in ipairs(search_table) do		
			if v:GetUnitName() == unit_name then					
				return UF_FAIL_CUSTOM			
			end		
		end	
	end
	
	return UF_SUCCESS
	
end

--------------------------------------------------------------------------------

function rattletrap_tower_cog:GetCustomCastErrorLocation(vLocation)
	return "#dota_hud_error_cant_place_near_mine"
end

--------------------------------------------------------------------------------

function rattletrap_tower_cog:OnSpellStart()	
	
	local caster = self:GetCaster()	
	local target_location = self:GetCursorPosition()	
	local level = self:GetLevel()		
	local unit_name = "npc_dota_rattletrap_tower_cog"
	local unit_duration = self:GetSpecialValueFor("duration")
	local max_damage = self:GetSpecialValueFor("max_damage")
	local min_damage = self:GetSpecialValueFor("min_damage")		
	
	local unit = CreateUnitByName(unit_name, target_location, true, caster, caster, caster:GetTeam())	
	local cog_invulnerability = unit:FindAbilityByName("rattletrap_tower_cog_passive")
	local cog_splash = unit:FindAbilityByName("rattletrap_tower_cog_passive2")
		
	cog_invulnerability:SetLevel(1)
	cog_splash:SetLevel(level)	
	
	unit:AddNewModifier(unit, nil, "modifier_kill", {duration = unit_duration})
	unit:SetBaseDamageMax(max_damage)
	unit:SetBaseDamageMin(min_damage)
	
end

--------------------------------------------------------------------------------

function tower_cog_on_orb_impact(event)
    
        local caster = event.caster
        local target = event.target
        local ability = event.ability
        local radius = ability:GetSpecialValueFor("splash_radius")
        local splash_damage = ability:GetSpecialValueFor("splash_modifier")        
            
        -- Finding the units in radius
        local splash_radius = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin() , nil, radius , DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false) 
        
        -- Initializing the damage table
        local damage_table = {}
        damage_table.attacker = caster
        damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
        damage_table.damage = caster:GetAttackDamage() * splash_damage

        --loop for doing the splash damage while ignoring the original target
        for i,v in ipairs(splash_radius) do
             if v ~= target then 
                damage_table.victim = v
                ApplyDamage(damage_table)
            end
        end        
end
