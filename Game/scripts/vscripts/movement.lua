require('abilities/basic_attack_animations')
--Movement modifiers

-- Left movement

modifier_left = class({})

function modifier_left:OnCreated()
  if IsServer() then
    self:GetParent():SetForwardVector(Vector(-1,0,0))
    self:StartIntervalThink(1/32)
  end
end


function modifier_left:OnIntervalThink()
  local vec = self:GetParent():GetAbsOrigin()
  local x = vec[1] - (Laws.flMove * self:GetParent().movespeedFactor) 
  if self:GetParent():HasModifier("modifier_smash_stun") then
    self:Destroy()
    return
  end
  if self:GetParent():isOnPlatform() or self:GetParent():HasModifier("modifier_jump") then
    if self:GetParent().rotation and self:GetParent().rotation ~= 0  then
      --print(vec)
      vec = Vector(x,vec[2],vec[3] + (self:GetParent().rotation) * ((Laws.flMove * self:GetParent().movespeedFactor)/55))
      --print(vec)
      self:GetParent():SetAbsOrigin(vec)
    else
       vec = Vector(x,vec[2],vec[3])
      self:GetParent():SetAbsOrigin(vec)
    end
  else
    vec = Vector(x,vec[2],vec[3] - (Laws.flDropSpeed*0.5))
    self:GetParent():SetAbsOrigin(vec)
  end
  if not self:GetParent():HasModifier("modifier_animation") then
    StartAnimation(self:GetCaster(), {duration=-1, activity=ACT_DOTA_RUN, rate=1})
  end
end


function modifier_left:OnDestroy()
  if IsServer() then
    EndAnimation(self:GetParent())
    --self:GetParent():SetForwardVector(Vector(-1,0,0))
  end
end

modifier_right = class({})

function modifier_right:OnCreated()
  if IsServer() then
    self:GetParent():SetForwardVector(Vector(1,0,0))
    self:StartIntervalThink(1/32)
  end
end


function modifier_right:OnIntervalThink()
  local vec = self:GetParent():GetAbsOrigin()
  local x = vec[1] + (Laws.flMove * self:GetParent().movespeedFactor)
  if self:GetParent():HasModifier("modifier_smash_stun") then
    self:Destroy()
    return
  end
  if self:GetParent():isOnPlatform() or self:GetParent():HasModifier("modifier_jump") then
    if self:GetParent().rotation and self:GetParent().rotation ~= 0  then
      --print(vec)
      vec = Vector(x,vec[2],vec[3] - (self:GetParent().rotation) * ((Laws.flMove * self:GetParent().movespeedFactor)/55))
      --print(vec)
      self:GetParent():SetAbsOrigin(vec)
    else
       vec = Vector(x,vec[2],vec[3])
      self:GetParent():SetAbsOrigin(vec)
    end
  else
    vec = Vector(x,vec[2],vec[3] - (Laws.flDropSpeed*0.5))
    self:GetParent():SetAbsOrigin(vec)
  end
  if not self:GetParent():HasModifier("modifier_animation") then
    StartAnimation(self:GetCaster(), {duration=-1, activity=ACT_DOTA_RUN, rate=1})
  end

end


function modifier_right:OnDestroy()
  if IsServer() then
    EndAnimation(self:GetParent())
    --self:GetParent():SetForwardVector(Vector(1,0,0))
  end
end

modifier_jump = class({})


function modifier_jump:OnCreated()
  if IsServer() then
    if self:GetParent().jumps < 2 then
      self:GetParent().jumps = self:GetParent().jumps +1
      self:StartIntervalThink(1/32)
      if self:GetParent():HasModifier("modifier_jump_rune_buff") then
        self:GetParent():EmitSound("Hero_Zuus.Taunt.Jump")
      end
      
    end
  end
end


function modifier_jump:OnIntervalThink()
  -- handle lowest platform
  if self:GetParent():isUnderPlatform() and self:GetCaster():HasModifier("modifier_basic") then return end
  --  
  if not self.count then self.count = 0 end
  self.count = self.count + 1
  local vec = self:GetParent():GetAbsOrigin()
  local z = vec[3] + Laws.flJumpSpeed * self:GetParent().jumpfactor * math.pow(Laws.flJumpDeceleration, self.count)
  vec = Vector(vec[1],vec[2],z)
  self:GetParent():SetAbsOrigin(vec)
  --[[if not self:GetParent():HasModifier("modifier_animation") then
    StartAnimation(self:GetCaster(), {duration=Laws.flJumpDuration, activity=jumpAnimation[self:GetParent():GetUnitName()], rate=1})
  end]]
end
  

function modifier_jump:OnDestroy()
  if IsServer() then
    self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_drop",{})
  end
end

modifier_drop = class({})

function modifier_drop:OnDestroy()
  if IsServer() then
   EndAnimation(self:GetParent())
 end
end
function modifier_drop:OnCreated()
  if IsServer() then
    self:StartIntervalThink(0.05)
    
  end
end


function modifier_drop:OnIntervalThink()
  local vec = self:GetParent():GetAbsOrigin()
  local z = vec[3] - Laws.flDropSpeed
  vec = Vector(vec[1],vec[2],z)
  local bCanDrop = true
  local my_platform
  if not platform then return end
  for k,v in pairs(platform) do
    if not v:IsNull() then
      if v.unitsOnPlatform[self:GetParent()] then
        my_platform = v
        bCanDrop = v.canDropThrough
        break
      end
    end
  end
  for k,v in pairs(jumpModifiers) do
    if self:GetParent():HasModifier(k) then
      self:Destroy()
      return
    end
  end
  if not self:GetParent():isOnPlatform() or self:GetParent().bUnitUsedDrop and bCanDrop then 
    --[[if not self:GetParent():HasModifier("modifier_animation") then
      StartAnimation(self:GetCaster(), {duration=0.5, activity=ACT_DOTA_FLAIL, rate=1})
    end]]
    self:GetParent():SetAbsOrigin(vec)
  else
    self:GetParent().jumps = 0
    self:Destroy()
  end
end

jumpModifiers = {
  ["modifier_jump"] = true,
  ["modifier_mirana_leap_jump"] = true,
  ["modifier_earthshaker_jump"] = true,
  ["modifier_storm_ball_lightning"] = true,
  ["modifier_storm_side_grab"] = true,
}