bash_reflect=class({})
bash_reflect_op = class({})
modifier_bash_reflect = class({})
LinkLuaModifier("modifier_bash_reflect","abilities/bash_reflect.lua",LUA_MODIFIER_MOTION_NONE)

function bash_reflect:OnSpellStart()
  if self:GetCursorTarget() == self:GetCaster() then return end
  self:GetCaster():RemoveModifierByName("modifier_bash_reflect")
  self:GetCursorTarget():AddNewModifier(self:GetCaster(),self,"modifier_bash_reflect",{duration = self:GetSpecialValueFor("duration")})
  self:GetCursorTarget():EmitSound("DOTA_Item.LinkensSphere.Target")
end

function bash_reflect_op:OnSpellStart()
  if self:GetCursorTarget() == self:GetCaster() then return end
  self:GetCaster():RemoveModifierByName("modifier_bash_reflect")
  self:GetCursorTarget():AddNewModifier(self:GetCaster(),self,"modifier_bash_reflect",{duration = self:GetSpecialValueFor("duration")})
end

function bash_reflect:GetIntrinsicModifierName()
  return "modifier_bash_reflect"
end
function bash_reflect_op:GetIntrinsicModifierName()
  return "modifier_bash_reflect"
end

function modifier_bash_reflect:IsPurgable()
  return self:GetParent() ~= self:GetCaster()
end
function modifier_bash_reflect:IsHidden()
  return self:GetParent() == self:GetCaster()
end

function modifier_bash_reflect:OnRemoved()
  if IsServer() then
    if self:GetParent() ~= self:GetCaster() then
      self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_bash_reflect",{})
    end
  end
end

function modifier_bash_reflect:GetEffectName()
  if self:GetParent() ~= self:GetCaster() then
    return "particles/bash_reflect_shield.vpcf"
  end
end
function modifier_bash_reflect:GetEffectAttachType()
  if self:GetParent() ~= self:GetCaster() then
    return PATTACH_OVERHEAD_FOLLOW
  end
end



function ReflectBashes(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  local modifierName = filterTable["name_const"]
  local modifier
  if filterTable["duration"] <= 0 then return end
  if not parent:FindModifierByName("modifier_bash_reflect") then return end
  if caster:GetTeamNumber() == parent:GetTeamNumber() then return end
  if ability:GetAbilityName() == "bash_reflect_op" or ability:GetAbilityName() == "bash_reflect" then return end

  Timers:CreateTimer(function ()
    if not parent:FindModifierByName("modifier_bash_reflect") then return end
    local modifier = parent:FindModifierByName(modifierName)
    if not modifier:IsStunDebuff() then return end
    if bit.band(ability:GetBehavior(),DOTA_ABILITY_BEHAVIOR_PASSIVE) == DOTA_ABILITY_BEHAVIOR_PASSIVE then
      caster:AddNewModifier(parent,parent:FindModifierByName("modifier_bash_reflect"):GetAbility(),modifierName,{duration = filterTable["duration"] *parent:FindModifierByName("modifier_bash_reflect"):GetAbility():GetSpecialValueFor("duration_multiplier")})
      parent:EmitSound("Hero_Tiny.CraggyExterior.Stun")
      local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_craggy_hit.vpcf",PATTACH_POINT_FOLLOW,parent)
      ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
      ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
      ParticleManager:ReleaseParticleIndex(particle)
    end
  end, DoUniqueString('check_modifier'), FrameTime())
end





