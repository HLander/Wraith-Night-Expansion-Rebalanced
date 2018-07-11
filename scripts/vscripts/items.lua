
function IntellectTomeUsed( event )
    local picker = event.caster
    local tome = event.ability
    local statBonus = event.bonus_stat
    --casterUnit:SetBaseIntellect( casterUnit:GetBaseIntellect() + 1 )
    --casterUnit:ModifyIntellect(statBonus)
    if picker:IsRealHero() == false then
    	picker = picker:GetPlayerOwner():GetAssignedHero()
    end
    if picker:HasModifier("tome_intelect_modifier") == false then
        tome:ApplyDataDrivenModifier( picker, picker, "tome_intelect_modifier", nil)
        picker:SetModifierStackCount("tome_intelect_modifier", picker, statBonus)
    else
        picker:SetModifierStackCount("tome_intelect_modifier", picker, (picker:GetModifierStackCount("tome_intelect_modifier", picker) + statBonus))
    end
end

function StrengthTomeUsed( event )
    local picker = event.caster
    local tome = event.ability
    local statBonus = event.bonus_stat
    --casterUnit:SetBaseStrength( casterUnit:GetBaseStrenght() + 1 )
    --casterUnit:ModifyStrength(statBonus)
    if picker:IsRealHero() == false then
    	picker = picker:GetPlayerOwner():GetAssignedHero()
    end


    if picker:HasModifier("tome_strenght_modifier") == false then
        tome:ApplyDataDrivenModifier( picker, picker, "tome_strenght_modifier", nil)
        picker:SetModifierStackCount("tome_strenght_modifier", picker, statBonus)
    else
        picker:SetModifierStackCount("tome_strenght_modifier", picker, (picker:GetModifierStackCount("tome_strenght_modifier", picker) + statBonus))
    end
    --SetModifierStackCount(string modifierName, handle b, int modifierCount) 
    --GetModifierStackCount(string modifierName, handle b) 
end

function AgilityTomeUsed( event )
    local picker = event.caster
    local tome = event.ability
    local statBonus = event.bonus_stat
    --casterUnit:SetBaseStrength( casterUnit:GetBaseStrenght() + 1 )
    --casterUnit:ModifyStrength(statBonus)
    if picker:IsRealHero() == false then
        picker = picker:GetPlayerOwner():GetAssignedHero()
    end


    if picker:HasModifier("tome_agility_modifier") == false then
        tome:ApplyDataDrivenModifier( picker, picker, "tome_agility_modifier", nil)
        picker:SetModifierStackCount("tome_agility_modifier", picker, statBonus)
    else
        picker:SetModifierStackCount("tome_agility_modifier", picker, (picker:GetModifierStackCount("tome_agility_modifier", picker) + statBonus))
    end
    --SetModifierStackCount(string modifierName, handle b, int modifierCount) 
    --GetModifierStackCount(string modifierName, handle b) 
end

function modifier_item_bfury_datadriven_on_created(keys)
    if not keys.caster:IsRangedAttacker() then
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_bfury_datadriven_cleave", {duration = -1})
    end
end

function modifier_item_bfury_datadriven_on_destroy(keys)
    if not keys.caster:IsRangedAttacker() then
        keys.caster:RemoveModifierByName("modifier_item_bfury_datadriven_cleave")
    end
end

function modifier_item_skadi_datadriven_on_orb_impact2(keys)
    if keys.caster:IsRangedAttacker() then
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        local radius_small = 100
        local radius_medium = 225
        local target_exists = false
        local splash_damage_small = 100 / 100
        local splash_damage_medium = 25 / 100
            
        -- Finding the units for each radius
        local splash_radius_small = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin() , nil, radius_small , DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false) 
        local splash_radius_medium = FindUnitsInRadius(caster:GetTeam() , target:GetAbsOrigin() , nil, radius_medium, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

        -- Initializing the damage table
        local damage_table = {}
        damage_table.attacker = caster
        damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
        damage_table.damage = caster:GetAttackDamage() * splash_damage_small

        --loop for doing the splash damage while ignoring the original target
        for i,v in ipairs(splash_radius_small) do
             if v ~= target then 
                damage_table.victim = v
                ApplyDamage(damage_table)
            end
        end
        --loop for doing the medium splash damage
        for i,v in ipairs(splash_radius_medium) do
            if v ~= target then
                --loop for checking if the found target is in the splash_radius_small
                for c,k in ipairs(splash_radius_small) do
                    if v == k then
                        target_exists = true
                        break
                    end
                end
                --if the target isn't in the splash_radius_small then do attack damage * splash_damage_medium
                if not target_exists then
                    damage_table.damage = caster:GetAttackDamage() * splash_damage_medium
                    damage_table.victim = v
                    ApplyDamage(damage_table)
                --resets the target check   
                else
                    target_exists = false
                end
            end
        end
    end
end

function modifier_item_vladmir_datadriven_lifesteal_aura_on_attack_landed(keys)
    if keys.target.GetInvulnCount == nil and not keys.target:IsMechanical() then
        keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_item_vladmir_datadriven_lifesteal_aura_lifesteal", {duration = 0.03})
    end
end

function modifier_item_bfury_datadriven_on_interval_think(keys)
    if not keys.caster:IsRangedAttacker() and not keys.caster:HasModifier("modifier_item_bfury_datadriven_cleave") then
        for i=0, 5, 1 do
            local current_item = keys.caster:GetItemInSlot(i)
            if current_item ~= nil then
                if current_item:GetName() == "item_bfury_datadriven" then
                    keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_bfury_datadriven_cleave", {duration = -1})
                end
            end
        end
    end
end

function modifier_item_bfury_datadriven_cleave_on_interval_think(keys)
    if keys.caster:IsRangedAttacker() then
        while keys.caster:HasModifier("modifier_item_bfury_datadriven_cleave") do
            keys.caster:RemoveModifierByName("modifier_item_bfury_datadriven_cleave")
        end
    end
end

function FiendsGripStopSound( keys )
    local target = keys.target
    local sound = keys.sound

    StopSoundEvent(sound, target)
end

function ManaDrain( keys )  
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local mana_drain = ability:GetLevelSpecialValueFor("fiend_grip_mana_drain", (ability:GetLevel() -1)) / 100

    local max_mana_drain = target:GetMaxMana() * mana_drain
    local current_mana = target:GetMana()

    -- Calculates the amount of mana to be given to the caster
    if current_mana >= max_mana_drain then
        caster:GiveMana(max_mana_drain)
    else
        caster:GiveMana(current_mana)
    end

    target:ReduceMana(max_mana_drain)
end

function FiendsGripInvisCheck( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifier = keys.modifier

    if target:IsInvisible() then
        ability:ApplyDataDrivenModifier(caster, target, modifier, {})
    end
end

function Devour( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    -- Ability variables
    local target_hp = target:GetHealth()
    local health_per_second = ability:GetLevelSpecialValueFor("health_per_second", ability_level)
    local modifier = keys.modifier
    local modifier_duration = target_hp/health_per_second

    -- Apply the modifier and kill the target
    ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = modifier_duration})
    target:Kill(ability, caster)

    -- Setting up the table for allowed devour targets
    local devour_table = {}
    local doom_empty1 = keys.doom_empty1
    local doom_empty2 = keys.doom_empty2

    -- Insert the names of the units that you want to be valid targets for ability stealing
    table.insert(devour_table, "npc_dota_creature_buff_witch") -- Red Hellbear
    table.insert(devour_table, "npc_dota_creature_troll_healer") -- Small wolf
    table.insert(devour_table, "npc_dota_creature_basic_zombie_exploding") -- Big centaur
    table.insert(devour_table, "npc_dota_creature_spiderling")
    table.insert(devour_table, "npc_dota_splitter_a")
    table.insert(devour_table, "npc_dota_splitter_b")
    table.insert(devour_table, "npc_dota_creature_lycan")
    table.insert(devour_table, "npc_dota_creature_venoraptor")
    table.insert(devour_table, "npc_dota_creature_centaur_normal")
    table.insert(devour_table, "npc_dota_creature_centaur_small")
    table.insert(devour_table, "npc_dota_creature_shadow_fiend")
    table.insert(devour_table, "npc_dota_creature_abaddon")
    table.insert(devour_table, "npc_dota_creature_weaver")
    table.insert(devour_table, "npc_dota_creature_thistle_crawler")
    table.insert(devour_table, "npc_dota_creature_tiny")
    table.insert(devour_table, "npc_dota_creature_poison_dragon")
    table.insert(devour_table, "npc_dota_creature_metal_dragon")
    table.insert(devour_table, "npc_dota_creature_twin_dragon")
    table.insert(devour_table, "npc_dota_creature_spiderling")

    -- Checks if the killed unit is in the table for allowed targets
    for _,v in ipairs(devour_table) do
        if target:GetUnitName() == v then
            -- Get the first two abilities
            local ability1 = target:GetAbilityByIndex(0)
            local ability2 = target:GetAbilityByIndex(1)

            -- If we already devoured a target and stole an ability from before then clear it
            if caster.devour_ability1 then
                caster:SwapAbilities(doom_empty1, caster.devour_ability1, true, false)
                caster:RemoveAbility(caster.devour_ability1)
            end

            if caster.devour_ability2 then
                caster:SwapAbilities(doom_empty2, caster.devour_ability2, true, false) 
                caster:RemoveAbility(caster.devour_ability2)
            end

            -- Checks if the ability actually exist on the target
            if ability1 then
                -- Get the name and add it to the caster
                local ability1_name = ability1:GetAbilityName()
                caster:AddAbility(ability1_name)

                -- Make the stolen ability active, level it up and save it in the caster handle for later checks
                caster:SwapAbilities(doom_empty1, ability1_name, false, true)
                caster.devour_ability1 = ability1_name
                caster:FindAbilityByName(ability1_name):SetLevel(ability1:GetLevel())
            end

            -- Checks if the ability actually exist on the target
            if ability2 then
                -- Get the name and add it to the caster
                local ability2_name = ability2:GetAbilityName()
                caster:AddAbility(ability2_name)

                -- Make the stolen ability active, level it up and save it in the caster handle for later checks
                caster:SwapAbilities(doom_empty2, ability2_name, false, true)
                caster.devour_ability2 = ability2_name
                caster:FindAbilityByName(ability2_name):SetLevel(ability2:GetLevel())
            end
        end
    end
end

--Awards the bonus gold to the modifier owner only if the modifier owner is alive
function DevourGold( keys )
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", ability_level)

    -- Give the gold only if the target is alive
    if target:IsAlive() then
        target:ModifyGold(bonus_gold, false, 0)
    end
end

--Disallows eating another unit while Devour is in progress
function DevourCheck( keys )
    local caster = keys.caster
    local modifier = keys.modifier
    local player = caster:GetPlayerOwner()
    local pID = caster:GetPlayerOwnerID()

    if caster:HasModifier(modifier) then
        caster:Stop()

        -- Play Error Sound
        EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", player)

        -- This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
        FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Can't Devour While Mouth is Full" } )
    end
end

function item_blink_datadriven_on_spell_start(keys)
    ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
    
    ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, keys.caster)
    keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
    
    local origin_point = keys.caster:GetAbsOrigin()
    local target_point = keys.target_points[1]
    local difference_vector = target_point - origin_point
    
    if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
        target_point = origin_point + (target_point - origin_point):Normalized() * keys.BlinkRangeClamp
    end
    
    keys.caster:SetAbsOrigin(target_point)
    FindClearSpaceForUnit(keys.caster, target_point, false)
    
    ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, keys.caster)
end

--[[Called when a unit with Blink Dagger in their inventory takes damage.  Puts the Blink Dagger on a brief cooldown
    if the damage is nonzero (after reductions) and originated from any player or Roshan.
    Additional parameters: keys.BlinkDamageCooldown and keys.Damage
    Known Bugs: keys.Damage contains the damage before reductions, whereas we want to compare the damage to 0 after reductions.]]
function modifier_item_blink_datadriven_damage_cooldown_on_take_damage(keys)
    local attacker_name = keys.attacker:GetName()

    if keys.Damage > 0 and (attacker_name == "npc_dota_roshan") then  --If the damage was dealt by neutrals or lane creeps, essentially.
        if keys.ability:GetCooldownTimeRemaining() < keys.BlinkDamageCooldown then
            keys.ability:StartCooldown(keys.BlinkDamageCooldown)
        end
    end
end

function sand_storm_remove_sound( keys )
    local sound_name = "Ability.SandKing_SandStorm.loop"
    StopSoundEvent( sound_name, keys.caster )
end

function concussive_shot_seek_target( keys )
    -- Variables
    local caster = keys.caster
    local ability = keys.ability
    local particle_name = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf"
    local radius = ability:GetLevelSpecialValueFor( "launch_radius", ability:GetLevel() - 1 )
    local speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
    local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_HERO
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS 
    
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam,
        targetType, targetFlag, FIND_CLOSEST, false
    )
    
    -- Seek out target
    for k, v in pairs( units ) do
        local projTable = {
            EffectName = particle_name,
            Ability = ability,
            Target = v,
            Source = caster,
            bDodgeable = true,
            bProvidesVision = true,
            vSpawnOrigin = caster:GetAbsOrigin(),
            iMoveSpeed = speed,
            iVisionRadius = radius,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
        }
        ProjectileManager:CreateTrackingProjectile( projTable )
        break
    end
end

function concussive_shot_post_vision( keys )
    local target = keys.target:GetAbsOrigin()
    local ability = keys.ability
    local radius = ability:GetLevelSpecialValueFor( "launch_radius", ability:GetLevel() - 1 )
    local duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )

    -- Create node
    ability:CreateVisibilityNode( target, radius, duration )
end

function mystic_flare_start( keys )
    -- Variables
    local ability = keys.ability
    local caster = keys.caster
    local current_instance = 0
    local dummyModifierName = "modifier_mystic_flare_dummy_vfx_datadriven"
    local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
    local interval = ability:GetLevelSpecialValueFor( "damage_interval", ability:GetLevel() - 1 )
    local max_instances = math.floor( duration / interval )
    local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
    local target = keys.target_points[1]
    local total_damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
    local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
    local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_HERO
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    local damageType = ability:GetAbilityDamageType() -- DAMAGE_TYPE_MAGICAL
    local soundTarget = "Hero_SkywrathMage.MysticFlare.Target"
    
    -- Create for VFX particles on ground
    local dummy = CreateUnitByName( "npc_dummy_blank", target, false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
    
    -- Referencing total damage done per interval
    local damage_per_interval = total_damage / max_instances
    
    -- Deal damage per interval equally
    Timers:CreateTimer( function()
            local units = FindUnitsInRadius(
                caster:GetTeamNumber(), target, caster, radius, targetTeam,
                targetType, targetFlag, FIND_ANY_ORDER, false
            )
            if #units > 0 then
                local damage_per_hero = damage_per_interval / #units
                for k, v in pairs( units ) do
                    -- Apply damage
                    local damageTable = {
                        victim = v,
                        attacker = caster,
                        damage = damage_per_hero,
                        damage_type = damageType
                    }
                    ApplyDamage( damageTable )
                    
                    -- Fire sound
                    StartSoundEvent( soundTarget, v )
                end
            end
            
            current_instance = current_instance + 1
            
            -- Check if maximum instances reached
            if current_instance >= max_instances then
                dummy:Destroy()
                return nil
            else
                return interval
            end
        end
    )
end

function ManaDrain2( keys )

    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local mana_drain = ability:GetLevelSpecialValueFor("mana_damage", (ability:GetLevel() -1))

    target:ReduceMana(mana_drain)
end

function arcane_bolt_init( keys )
    local caster = keys.caster
    local intelligence = keys.caster:GetIntellect()
    if caster.arcane_bolt_list_head == nil then
        caster.arcane_bolt_list_tail = {}
        caster.arcane_bolt_list_head = { next = caster.arcane_bolt_list_tail, value = intelligence }
    else
        local tmp = {}
        caster.arcane_bolt_list_tail.next = tmp
        caster.arcane_bolt_list_tail.value = intelligence
        caster.arcane_bolt_list_tail = tmp
    end
end

function arcane_bolt_hit( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local radius = ability:GetLevelSpecialValueFor( "bolt_vision", ability:GetLevel() - 1 )
    local duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
    local multiplier = ability:GetLevelSpecialValueFor( "int_multiplier", ability:GetLevel() - 1 )
    local intelligence = math.max( 0, caster.arcane_bolt_list_head.value )
    local damageType = ability:GetAbilityDamageType() -- DAMAGE_TYPE_MAGICAL
    
    -- Update linked head node
    if caster.arcane_bolt_list_head ~= caster.arcane_bolt_list_tail then
        caster.arcane_bolt_list_head = caster.arcane_bolt_list_head.next
    else
        caster.arcane_bolt_list_head = nil
    end
    
    -- Deal damage
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = intelligence * multiplier,
        damage_type = damageType,
    }
    ApplyDamage( damageTable )
    
    -- Provide visibility
    ability:CreateVisibilityNode( target:GetAbsOrigin(), radius, duration )
end

function PoisonTouchStun( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local ability_level = ability:GetLevel() - 1
    local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
    local should_stun = ability:GetLevelSpecialValueFor("should_stun", ability_level)

    if should_stun == 1 then
        target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
    end
end

function SanityEclipseDamage( keys )
    
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local od_int = caster:GetIntellect()
    local target_int = 1
    local mana = target:GetMana()
    local dmg_multiplier = ability:GetLevelSpecialValueFor("damage_multiplier", (ability:GetLevel() -1))
    local threshold = ability:GetLevelSpecialValueFor("int_threshold", (ability:GetLevel() -1))

    local damage_table = {} 

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    --if od's int is lower than targets int then keep do nothing and keep targets mana as it is
    if od_int < target_int then
        target:SetMana(mana)
        --if the int difference is below or equal to threshold, burn 75% current mana and apply int difference * damage_modifier in magic damage
        elseif 
            (od_int - target_int) < threshold or (od_int - target_int) == threshold then
        target:SetMana(mana*0.25)
        damage_table.damage = (od_int - target_int) * dmg_multiplier
        ApplyDamage(damage_table)
        --if the int difference is bigger than than threshold then deal damage
        elseif  (od_int - target_int) > threshold then
            damage_table.damage = (od_int - target_int) * dmg_multiplier
            ApplyDamage(damage_table)
    end
end

function modifier_item_skadi_datadriven_on_orb_impact(keys)
    if keys.target.GetInvulnCount == nil then
        if keys.caster:IsRangedAttacker() then
            local caster = keys.caster
            local target = keys.target
            local ability = keys.ability
            local radius_small = 100
            local radius_medium = 200
            local radius_big = 300
            local target_exists = false
            local splash_damage_small = 100 / 100
            local splash_damage_medium = 75 / 100
            local splash_damage_big = 50 / 100
            
            -- Finding the units for each radius
            local splash_radius_small = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin() , nil, radius_small , DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false) 
            local splash_radius_medium = FindUnitsInRadius(caster:GetTeam() , target:GetAbsOrigin() , nil, radius_medium, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
            local splash_radius_big = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin() , nil, radius_big, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

            -- Initializing the damage table
            local damage_table = {}
            damage_table.attacker = caster
            damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
            damage_table.damage = caster:GetAttackDamage() * splash_damage_small

            --loop for doing the splash damage while ignoring the original target
            for i,v in ipairs(splash_radius_small) do
                if v ~= target then 
                    damage_table.victim = v
                    ApplyDamage(damage_table)
                end
            end
            --loop for doing the medium splash damage
            for i,v in ipairs(splash_radius_medium) do
                if v ~= target then
                    --loop for checking if the found target is in the splash_radius_small
                    for c,k in ipairs(splash_radius_small) do
                        if v == k then
                            target_exists = true
                            break
                        end
                    end
                    --if the target isn't in the splash_radius_small then do attack damage * splash_damage_medium
                    if not target_exists then
                        damage_table.damage = caster:GetAttackDamage() * splash_damage_medium
                        damage_table.victim = v
                        ApplyDamage(damage_table)
                    --resets the target check   
                    else
                        target_exists = false
                    end
                end
            end
            --loop for doing the damage if targets are found in the splash_damage_big but not in the splash_damage_medium
            for i,v in ipairs(splash_radius_big) do
                if v ~= target then
                    --loop for checking if the found target is in the splash_radius_medium
                    for c,k in ipairs(splash_radius_medium) do              
                        if v == k then
                            target_exists = true
                            break
                        end
                    end
                    if not target_exists then
                        damage_table.damage = caster:GetAttackDamage() * splash_damage_big
                        damage_table.victim = v
                        ApplyDamage(damage_table)
                    else
                        target_exists = false
                    end
                end
            end
            keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_skadi_datadriven_cold_attack", {duration = keys.ColdDurationMelee})
        else  --The caster is melee.
            keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_skadi_datadriven_cold_attack", {duration = keys.ColdDurationMelee})
        end
    end
end

function IntToDamage( keys )

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local int_caster = caster:GetIntellect()
    local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) 
    

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.ability = ability
    damage_table.victim = target

    damage_table.damage = int_caster * int_damage / 100

    ApplyDamage(damage_table)
end

function FleshHeap( keys )
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapModifier = "modifier_flesh_heap_bonus_datadriven"
    local fleshHeapStackModifier = "modifier_flesh_heap_aura_datadriven"
    local assists = caster:GetAssists()
    local kills = caster:GetKills()

    for i = 1, (assists + kills) do
        ability:ApplyDataDrivenModifier(caster, caster, fleshHeapModifier, {})
        print("Current number: " .. i)
    end

    caster:SetModifierStackCount(fleshHeapStackModifier, ability, (assists + kills))
end

--Increases the stack count of Flesh Heap.
function StackCountIncrease( keys )
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapStackModifier = "modifier_flesh_heap_aura_datadriven"
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

    caster:SetModifierStackCount(fleshHeapStackModifier, ability, (currentStacks + 1))
end

--Adjusts the strength provided by the modifiers on ability upgrade
function FleshHeapAdjust( keys )
    local caster = keys.caster
    local ability = keys.ability
    local fleshHeapModifier = "modifier_flesh_heap_bonus_datadriven"
    local fleshHeapStackModifier = "modifier_flesh_heap_aura_datadriven"
    local currentStacks = caster:GetModifierStackCount(fleshHeapStackModifier, ability)

    -- Remove the old modifiers
    for i = 1, currentStacks do
        caster:RemoveModifierByName(fleshHeapModifier)
    end

    -- Add the same amount of new ones
    for i = 1, currentStacks do
        ability:ApplyDataDrivenModifier(caster, caster, fleshHeapModifier, {}) 
    end
end

function ScorchedEarthCheck( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifier = keys.modifier

    if target:GetOwner() == caster or target == caster then
        ability:ApplyDataDrivenModifier(caster, target, modifier, {})
    end
end

-- Stops the sound from playing
function StopSound( keys )
    local target = keys.target
    local sound = keys.sound

    StopSoundEvent(sound, target)
end

function modifier_poison_sting_debuff_datadriven_on_created(keys)
    if keys.target:HasModifier("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed") then
        keys.target:SetModifierStackCount("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed", nil, 0)
    end
end

function modifier_poison_sting_debuff_datadriven_on_destroy(keys)
    if keys.target:HasModifier("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed") then
        keys.target:SetModifierStackCount("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed", nil, 11)
        
        --Once we become able to determine the caster of a modifier, we can modify the code below to determine the correct
        --the movement speed slow from the current level of Poison Sting.
        --[[local poison_sting_ability = keys.attacker.venomancer_plague_ward_parent:FindAbilityByName("venomancer_poison_sting_datadriven")
        if poison_sting_ability == nil then
            poison_sting_ability = keys.attacker.venomancer_plague_ward_parent:FindAbilityByName("venomancer_poison_sting")
        end
    
        if poison_sting_ability ~= nil then
            local poison_sting_level = poison_sting_ability:GetLevel()
            
            if poison_sting_level > 0 then
                
                keys.target:SetModifierStackCount("modifier_plague_ward_datadriven_poison_sting_debuff_movement_speed", nil, math.abs(poison_sting_ability:GetLevelSpecialValueFor("movement_speed", poison_sting_level - 1)))
            end
        end]]
    end
end

function item_dagon_datadriven_on_spell_start(keys)
    local dagon_level = keys.ability:GetLevel()
    
    local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
    ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
    local particle_effect_intensity = 300 + (100 * dagon_level)  --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.
    ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
    
    keys.caster:EmitSound("DOTA_Item.Dagon.Activate")
    keys.target:EmitSound("DOTA_Item.Dagon5.Target")
        
    ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.Damage, damage_type = DAMAGE_TYPE_MAGICAL,})
end

function ReapersScythe( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
    local damage_per_health = ability:GetLevelSpecialValueFor("damage_per_health", (ability:GetLevel() - 1))
    local respawn_time = ability:GetLevelSpecialValueFor("respawn_constant", (ability:GetLevel() - 1))

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.victim = target
    damage_table.ability = ability
    damage_table.damage_type = ability:GetAbilityDamageType()
    damage_table.damage = target_missing_hp * damage_per_health

    ApplyDamage(damage_table)
end

function Thinker_StoreCaster( event )
    local ability   = event.ability
    local caster    = event.caster
    local thinker   = event.target

    thinker.dream_coil_caster   = caster
    ability.dream_coil_thinker  = thinker
end

function Thinker_ApplyModifierToEnemy( event )
    local ability   = event.ability
    local thinker   = ability.dream_coil_thinker
    local enemy     = event.target

    ability:ApplyDataDrivenModifier( thinker, enemy, event.modifier_name, {} )
end

function CheckCoilBreak( event )
    local thinker   = event.caster
    local enemy     = event.target

    local dist  = (enemy:GetAbsOrigin() - thinker:GetAbsOrigin()):Length2D()
    if dist > event.coil_break_radius then
        -- Link has been broken
        local ability   = event.ability
        local caster    = thinker.dream_coil_caster

        ability:ApplyDataDrivenModifier( caster, enemy, event.coil_break_modifier, {} )

        -- Remove this modifier
        enemy:RemoveModifierByNameAndCaster( event.coil_tether_modifier, thinker )
    end
end

function Void( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local modifier = keys.modifier

    local duration_day = ability:GetLevelSpecialValueFor("duration_day", (ability:GetLevel() - 1))
    local duration_night = ability:GetLevelSpecialValueFor("duration_night", (ability:GetLevel() - 1))

    if GameRules:IsDaytime() then
        ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration_day})
    else
        ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration_night})
    end
end

function FrostArmorParticle( event )
    local target = event.target
    local location = target:GetAbsOrigin()
    local particleName = "particles/units/heroes/hero_lich/lich_frost_armor.vpcf"

    -- Particle. Need to wait one frame for the older particle to be destroyed
    Timers:CreateTimer(0.01, function()
        target.FrostArmorParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(target.FrostArmorParticle, 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(target.FrostArmorParticle, 1, Vector(1,0,0))

        ParticleManager:SetParticleControlEnt(target.FrostArmorParticle, 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
    end)
end

function DoomPurge( keys )
    local target = keys.target

    -- Purge
    local RemovePositiveBuffs = true
    local RemoveDebuffs = false
    local BuffsCreatedThisFrameOnly = false
    local RemoveStuns = false
    local RemoveExceptions = false
    target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end

--[[The deny check is run every frame, if the target is within deny range then apply the deniable state for the
    duration of 2 frames]]
function DoomDenyCheck( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    local deny_pct = ability:GetLevelSpecialValueFor("deniable_pct", ability_level)
    local modifier = keys.modifier

    local target_hp = target:GetHealth()
    local target_max_hp = target:GetMaxHealth()
    local target_hp_pct = (target_hp / target_max_hp) * 100

    if target_hp_pct <= deny_pct then
        ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = 0.06})
    end
end

-- Stops the sound from playing
function StopSound( keys )
    local target = keys.target
    local sound = keys.sound

    StopSoundEvent(sound, target)
end

function HeartstopperAura( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local target_max_hp = target:GetMaxHealth() / 100
    local aura_damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() - 1))
    local aura_damage_interval = ability:GetLevelSpecialValueFor("aura_damage_interval", (ability:GetLevel() - 1))

    -- Shows the debuff on the target's modifier bar only if Necrophos is visible
    local visibility_modifier = keys.visibility_modifier
    if target:CanEntityBeSeenByMyTeam(caster) then
        ability:ApplyDataDrivenModifier(caster, target, visibility_modifier, {})
    else
        target:RemoveModifierByName(visibility_modifier)
    end

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.victim = target
    damage_table.damage_type = DAMAGE_TYPE_MAGICAL
    damage_table.ability = ability
    damage_table.damage = target_max_hp * -aura_damage * aura_damage_interval
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS -- Doesnt trigger abilities and items that get disabled by damage

    ApplyDamage(damage_table)
end

function heat_seeking_missile_seek_targets( keys )
    -- Variables
    local caster = keys.caster
    local ability = keys.ability
    local particleName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
    local modifierDudName = "modifier_heat_seeking_missile_dud"
    local projectileSpeed = 900
    local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
    local max_targets = ability:GetLevelSpecialValueFor( "targets", ability:GetLevel() - 1 )
    local targetTeam = ability:GetAbilityTargetTeam()
    local targetType = ability:GetAbilityTargetType()
    local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    local projectileDodgable = false
    local projectileProvidesVision = false
    
    -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam, targetType, targetFlag, FIND_CLOSEST, false
    )
    
    -- Seek out target
    local count = 0
    for k, v in pairs( units ) do
        if count < max_targets then
            local projTable = {
                Target = v,
                Source = caster,
                Ability = ability,
                EffectName = particleName,
                bDodgeable = projectileDodgable,
                bProvidesVision = projectileProvidesVision,
                iMoveSpeed = projectileSpeed, 
                vSpawnOrigin = caster:GetAbsOrigin()
            }
            ProjectileManager:CreateTrackingProjectile( projTable )
            count = count + 1
        else
            break
        end
    end
    
    -- If no unit is found, fire dud
    if count == 0 then
        ability:ApplyDataDrivenModifier( caster, caster, modifierDudName, {} )
    end
end

function MirrorImage( event )
    local caster = event.caster
    local player = caster:GetPlayerID()
    local ability = event.ability
    local unit_name = caster:GetUnitName()
    local images_count = ability:GetLevelSpecialValueFor( "images_count", ability:GetLevel() - 1 )
    local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
    local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_percent_outgoing_melee", ability:GetLevel() - 1 )
    local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_percent_incoming_melee", ability:GetLevel() - 1 )

    local casterOrigin = caster:GetAbsOrigin()
    local casterAngles = caster:GetAngles()

    -- Stop any actions of the caster otherwise its obvious which unit is real
    caster:Stop()

    -- Initialize the illusion table to keep track of the units created by the spell
    if not caster.mirror_image_illusions then
        caster.mirror_image_illusions = {}
    end

    -- Kill the old images
    for k,v in pairs(caster.mirror_image_illusions) do
        if v and IsValidEntity(v) then 
            v:ForceKill(false)
        end
    end

    -- Start a clean illusion table
    caster.mirror_image_illusions = {}

    -- Setup a table of potential spawn positions
    local vRandomSpawnPos = {
        Vector( 72, 0, 0 ),     -- North
        Vector( 0, 72, 0 ),     -- East
        Vector( -72, 0, 0 ),    -- South
        Vector( 0, -72, 0 ),    -- West
    }

    for i=#vRandomSpawnPos, 2, -1 do    -- Simply shuffle them
        local j = RandomInt( 1, i )
        vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
    end

    -- Insert the center position and make sure that at least one of the units will be spawned on there.
    table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )

    -- At first, move the main hero to one of the random spawn positions.
    FindClearSpaceForUnit( caster, casterOrigin + table.remove( vRandomSpawnPos, 1 ), true )

    -- Spawn illusions
    for i=1, images_count do

        local origin = casterOrigin + table.remove( vRandomSpawnPos, 1 )

        -- handle_UnitOwner needs to be nil, else it will crash the game.
        local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
        illusion:SetPlayerID(caster:GetPlayerID())
        illusion:SetControllableByPlayer(player, true)

        illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
        
        -- Level Up the unit to the casters level
        local casterLevel = caster:GetLevel()
        for i=1,casterLevel-1 do
            illusion:HeroLevelUp(false)
        end

        -- Set the skill points to 0 and learn the skills of the caster
        illusion:SetAbilityPoints(0)
        for abilitySlot=0,15 do
            local ability = caster:GetAbilityByIndex(abilitySlot)
            if ability ~= nil then 
                local abilityLevel = ability:GetLevel()
                local abilityName = ability:GetAbilityName()
                local illusionAbility = illusion:FindAbilityByName(abilityName)
                illusionAbility:SetLevel(abilityLevel)
            end
        end

        -- Recreate the items of the caster
        for itemSlot=0,5 do
            local item = caster:GetItemInSlot(itemSlot)
            if item ~= nil then
                local itemName = item:GetName()
                local newItem = CreateItem(itemName, illusion, illusion)
                illusion:AddItem(newItem)
            end
        end

        -- Set the unit as an illusion
        -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
        illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
        
        -- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
        illusion:MakeIllusion()
        -- Set the illusion hp to be the same as the caster
        illusion:SetHealth(caster:GetHealth())

        -- Add the illusion created to a table within the caster handle, to remove the illusions on the next cast if necessary
        table.insert(caster.mirror_image_illusions, illusion)
    end
end

function ManaBreak( keys )
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    local manaBurn = ability:GetLevelSpecialValueFor("mana_per_hit", (ability:GetLevel() - 1))
    local manaDamage = ability:GetLevelSpecialValueFor("damage_per_burn", (ability:GetLevel() - 1))

    local damageTable = {}
    damageTable.attacker = caster
    damageTable.victim = target
    damageTable.damage_type = ability:GetAbilityDamageType()
    damageTable.ability = ability

    -- If the target is not magic immune then reduce the mana and deal damage
    if not target:IsMagicImmune() then
        -- Checking the mana of the target and calculating the damage
        if(target:GetMana() >= manaBurn) then
            damageTable.damage = manaBurn * manaDamage
            target:ReduceMana(manaBurn)
        else
            damageTable.damage = target:GetMana() * manaDamage
            target:ReduceMana(manaBurn)
        end

        ApplyDamage(damageTable)
    end
end

function modifier_item_assault_datadriven_enemy_aura_on_interval_think(keys)
    local is_emitter_visible = keys.target:CanEntityBeSeenByMyTeam(keys.caster)
    
    if is_emitter_visible and not keys.target:HasModifier("modifier_item_assault_datadriven_enemy_aura_visible") then
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_assault_datadriven_enemy_aura_visible", {duration = -1})
    elseif not is_emitter_visible and keys.target:HasModifier("modifier_item_assault_datadriven_enemy_aura_visible") then
        keys.target:RemoveModifierByNameAndCaster("modifier_item_assault_datadriven_enemy_aura_visible", keys.caster)
    end
end

--[[ ============================================================================================================
    Called when the debuff aura modifier is removed.  Removes the associated visible modifier, if applicable.
================================================================================================================= ]]
function modifier_item_assault_datadriven_enemy_aura_on_destroy(keys)
    keys.target:RemoveModifierByNameAndCaster("modifier_item_assault_datadriven_enemy_aura_visible", keys.caster)
end

--[[ ============================================================================================================
    Called when Mekansm is cast.  Heals nearby units if they have not been healed by a Mekansm recently.
    Additional parameters: keys.HealAmount and keys.HealRadius
================================================================================================================= ]]
function item_mekansm_datadriven_on_spell_start(keys)   
    keys.caster:EmitSound("DOTA_Item.Mekansm.Activate")
    ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

    local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.HealRadius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
    for i, nearby_ally in ipairs(nearby_allied_units) do  --Restore health and play a particle effect for every found ally.
        if not nearby_ally:HasModifier("modifier_item_mekansm_datadriven_heal_debuff") then
            nearby_ally:Heal(keys.HealAmount, keys.caster)
        end
        
        nearby_ally:EmitSound("DOTA_Item.Mekansm.Target")
        ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, nearby_ally)
        
        keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_mekansm_datadriven_heal_armor", nil)
        keys.ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_item_mekansm_datadriven_heal_debuff", nil)
    end
end

function item_arcane_boots_datadriven_on_spell_start(keys)  
    keys.caster:EmitSound("DOTA_Item.ArcaneBoots.Activate")
    ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

    local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.ReplenishRadius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
    for i, individual_unit in ipairs(nearby_allied_units) do  --Restore mana and play a particle effect for every found ally.
        individual_unit:GiveMana(keys.ReplenishAmount)
        ParticleManager:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
    end
end

function Reflection( event )
    print("Reflection Start")

    ----- Conjure Image  of the target -----
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local unit_name = target:GetUnitName()
    local origin = target:GetAbsOrigin() + RandomVector(100)
    local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
    local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )

    -- handle_UnitOwner needs to be nil, else it will crash the game.
    local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
    --illusion:SetPlayerID(caster:GetPlayerID())
    
    --Level Up the unit to the targets level
    local targetLevel = target:GetLevel()
    for i=1,targetLevel-1 do
    --illusion:HeroLevelUp(false)
    end

    -- Set the skill points to 0 and learn the skills of the target
    --illusion:SetAbilityPoints(0)
    for abilitySlot=0,15 do
        local ability = target:GetAbilityByIndex(abilitySlot)
        if ability ~= nil then 
            local abilityLevel = ability:GetLevel()
            local abilityName = ability:GetAbilityName()
            local illusionAbility = illusion:FindAbilityByName(abilityName)
            illusionAbility:SetLevel(abilityLevel)
        end
    end

    -- Recreate the items of the target
    --for itemSlot=0,5 do
    --    local item = target:GetItemInSlot(itemSlot)
    --    if item ~= nil then
    --        local itemName = item:GetName()
    --        local newItem = CreateItem(itemName, illusion, illusion)
    --        illusion:AddItem(newItem)
    --    end
    --end

    -- Set the unit as an illusion
    -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
    illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = 0 })
    
    -- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
    illusion:MakeIllusion()

    -- Apply Invulnerability modifier
    ability:ApplyDataDrivenModifier(caster, illusion, "modifier_reflection_invulnerability", nil)

    -- Force Illusion to attack Target
    illusion:SetForceAttackTarget(target)

    -- Emit the sound, so the destroy sound is played after it dies
    --illusion:EmitSound("Hero_Terrorblade.Reflection")
end

--[[Shows the Cast Particle, which for TB is originated between each weapon, in here both bodies are linked because not every hero has 2 weapon attach points]]
function ReflectionCast( event )

    local caster = event.caster
    local target = event.target
    local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

    local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
    ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
    
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

function Sunder( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local hit_point_minimum_pct = ability:GetLevelSpecialValueFor( "hit_point_minimum_pct", ability:GetLevel() - 1 ) * 0.01
    local caster_maxHealth = caster:GetMaxHealth()
    local target_maxHealth = target:GetMaxHealth()
    local casterHP_percent = caster:GetHealth() / caster_maxHealth
    local targetHP_percent = target:GetHealth() / target_maxHealth

    -- Swap the HP of the caster
    if targetHP_percent <= hit_point_minimum_pct then
        caster:SetHealth(caster_maxHealth * hit_point_minimum_pct)
    else
        caster:SetHealth(caster_maxHealth * targetHP_percent)
    end

    -- Swap the HP of the target
    if casterHP_percent <= hit_point_minimum_pct then
        target:SetHealth(target_maxHealth * hit_point_minimum_pct)
    else
        target:SetHealth(target_maxHealth * casterHP_percent)
    end

    -- Show the particle caster-> target
    local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"  
    local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, target )

    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

    -- Show the particle target-> caster
    local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"  
    local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

function HeartstopperAura( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local target_max_hp = target:GetMaxHealth() / 100
    local aura_damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() - 1))
    local aura_damage_interval = ability:GetLevelSpecialValueFor("aura_damage_interval", (ability:GetLevel() - 1))

    -- Shows the debuff on the target's modifier bar only if Necrophos is visible
    local visibility_modifier = keys.visibility_modifier
    if target:CanEntityBeSeenByMyTeam(caster) then
        ability:ApplyDataDrivenModifier(caster, target, visibility_modifier, {})
    else
        target:RemoveModifierByName(visibility_modifier)
    end

    local damage_table = {}

    damage_table.attacker = caster
    damage_table.victim = target
    damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
    damage_table.ability = ability
    damage_table.damage = target_max_hp * -aura_damage * aura_damage_interval
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS -- Doesnt trigger abilities and items that get disabled by damage

    ApplyDamage(damage_table)
end

function mana_burn_function( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local current_mana = target:GetMana()
    local multiplier = keys.ability:GetLevelSpecialValueFor( "float_multiplier", keys.ability:GetLevel() - 1 )
    local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
    local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"
    local damageType = keys.ability:GetAbilityDamageType()
    
    -- Calculation
    local mana_to_burn = math.min( current_mana, multiplier )
    local life_time = 2.0
    local digits = string.len( math.floor( mana_to_burn ) ) + 1
    
    -- Fail check
    if target:IsMagicImmune() then
        mana_to_burn = 0
    end
    
    -- Apply effect of ability
    target:ReduceMana( mana_to_burn )
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = mana_to_burn,
        damage_type = damageType
    }
    ApplyDamage( damageTable )
    
    -- Show VFX
    local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
    ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
    ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
    local burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )
    
    -- Create timer to properly destroy particles
    Timers:CreateTimer( life_time, function()
            ParticleManager:DestroyParticle( numberIndex, false )
            ParticleManager:DestroyParticle( burnIndex, false)
            return nil
        end
    )
end

function spiked_carapace_init( keys )
    keys.caster.carapaced_units = {}
end

function spiked_carapace_reflect( keys )
    -- Variables
    local caster = keys.caster
    local attacker = keys.attacker
    local damageTaken = keys.DamageTaken
    local ability = keys.ability
        
    local damage_table = {}

    damage_table.attacker = caster
    damage_table.damage_type = DAMAGE_TYPE_PURE
    damage_table.ability = ability
    damage_table.victim = attacker

    damage_table.damage = damageTaken

    
    -- Check if it's not already been hit
    if not caster.carapaced_units[ attacker:entindex() ] and not attacker:IsMagicImmune() then
        ApplyDamage(damage_table)
        --attacker:SetHealth( attacker:GetHealth() - damageTaken )
        keys.ability:ApplyDataDrivenModifier( caster, attacker, "modifier_spiked_carapaced_stun_datadriven", { } )
        caster:SetHealth( caster:GetHealth() + damageTaken )
        caster.carapaced_units[ attacker:entindex() ] = attacker
    end
end

function modifier_item_heart_datadriven_regen_on_take_damage(keys)
    if keys.caster:IsRangedAttacker() then
        keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
    else  --If the caster is melee.
        keys.ability:StartCooldown(keys.CooldownMelee)
    end
    
    if keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then
        keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
    end
end

--[[ ============================================================================================================
    Called regularly while one or more Heart of Tarrasques are in the unit's inventory.  Heals them if the item is
    off cooldown, and displays an icon on the caster's modifier bar.
    Additional parameters: keys.HealthRegenPercentPerSecond and keys.HealInterval
================================================================================================================= ]]
function modifier_item_heart_datadriven_regen_on_interval_think(keys)
    if keys.ability:IsCooldownReady() and keys.caster:IsRealHero() then
        keys.caster:Heal(keys.caster:GetMaxHealth() * (keys.HealthRegenPercentPerSecond / 100) * keys.HealInterval, keys.caster)
        if not keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then
            keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_heart_datadriven_regen_visible", {duration = -1})
        end
    elseif keys.caster:HasModifier("modifier_item_heart_datadriven_regen_visible") then  --This is mostly a failsafe.
        keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
    end
end

--[[ ============================================================================================================
    Called when Heart of Tarrasque is dropped or sold or something.  Removes the visible modifier from the modifier bar.
================================================================================================================= ]]
function modifier_item_heart_datadriven_regen_on_destroy(keys)
    keys.caster:RemoveModifierByNameAndCaster("modifier_item_heart_datadriven_regen_visible", keys.caster)
end

function DarkRitual( event )
    local caster = event.caster
    local target = event.target
    local heroes = event.target_entities
    local ability = event.ability

    -- Mana to give 
    local target_health = target:GetHealth()
    local rate = ability:GetLevelSpecialValueFor( "health_conversion" , ability:GetLevel() - 1 ) * 0.01
    local mana_gain = target_health * rate

    caster:GiveMana( mana_gain )

    -- Purple particle with eye
    local particleName = "particles/msg_fx/msg_xp.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)

    local digits = 0
    if mana_gain ~= nil then
        digits = #tostring(mana_gain)
    end

    ParticleManager:SetParticleControl(particle, 1, Vector(9, mana_gain, 6))
    ParticleManager:SetParticleControl(particle, 2, Vector(1, digits+1, 0))
    ParticleManager:SetParticleControl(particle, 3, Vector(170, 0, 250))
end