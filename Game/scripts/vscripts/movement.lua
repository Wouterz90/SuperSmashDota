require('abilities/basic_attack_animations')

modifier_left = class({})

function modifier_left:OnCreated()
  if IsServer() then
    self:GetParent():SetForwardVector(Vector(-1,0,0))
    Physics2D:SetStaticVelocity(self:GetParent(),"movement",Vec(-Laws.flMove,0))
    self:StartIntervalThink(FrameTime())
    --self:GetParent():SetStaticVelocity("left", Vector(-500,0,0))
  end
end

function modifier_left:OnIntervalThink()
  if not self:GetParent():HasModifier("modifier_animation") then
    StartAnimation(self:GetCaster(), {duration=-1, activity=ACT_DOTA_RUN, rate=1, priority=0})
  end
end

function modifier_left:OnDestroy()
  if IsServer() then
    Physics2D:SetStaticVelocity(self:GetParent(),"movement",Vec(0))
    if self:GetParent():FindModifierByName("modifier_animation") and bit.band(self:GetParent():FindModifierByName("modifier_animation"):GetStackCount(), 0x07FF) == ACT_DOTA_RUN then
      EndAnimation(self:GetParent(),0)
    end
  end
end

modifier_right = class({})

function modifier_right:OnCreated()
  if IsServer() then
    self:GetParent():SetForwardVector(Vector(1,0,0))
    Physics2D:SetStaticVelocity(self:GetParent(),"movement",Vec(Laws.flMove,0))
    self:StartIntervalThink(FrameTime())
    --self:GetParent():SetStaticVelocity("left", Vector(-500,0,0))
  end
end

function modifier_right:OnIntervalThink()
  if not self:GetParent():HasModifier("modifier_animation") then
    StartAnimation(self:GetCaster(), {duration=-1, activity=ACT_DOTA_RUN, rate=1, priority=0})
  end
end

function modifier_right:OnDestroy()
  if IsServer() then
    Physics2D:SetStaticVelocity(self:GetParent(),"movement",Vec(0))
    if self:GetParent():FindModifierByName("modifier_animation") and bit.band(self:GetParent():FindModifierByName("modifier_animation"):GetStackCount(), 0x07FF) == ACT_DOTA_RUN then
      EndAnimation(self:GetParent(),0)
    end
  end
end


modifier_jump = class({})

function modifier_jump:OnCreated()
  if IsServer() then
    self:GetParent().jumps = self:GetParent().jumps +1
    --self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin()+Vec(0,400))

    if self:GetParent():HasModifier("modifier_jump_rune_buff") then
      self:GetParent():EmitSound("Hero_Zuus.Taunt.Jump")
      Physics2D:AddPhysicsVelocity(self:GetParent(),Vec(0,30))
      return
    end

  Physics2D:AddPhysicsVelocity(self:GetParent(),Vec(0,20))
  end
end

function modifier_jump:OnRefresh()
  self:OnCreated()
end

function modifier_jump:OnIntervalThink()
  --self:GetParent():SetStaticVelocity("jump",self:GetParent():GetStaticVelocity("jump")*0.99*30)
end
  
function modifier_jump:OnDestroy()

  if IsServer() then
    --self:GetParent():SetStaticVelocity(self:GetName(), Vector(0,0,0))
  end
end

modifier_drop = class({})

function modifier_drop:OnDestroy()
  if IsServer() then

   --EndAnimation(self:GetParent())
   --self:GetParent():SetStaticVelocity("grav", Vector(0,0,-0))
 end
end
function modifier_drop:OnCreated()
  if IsServer() then
    Physics2D:AddPhysicsVelocity(self:GetParent(),Vec(0,-20))
    --self:GetParent():SetStaticVelocity("grav", Vector(0,0,-500))
    --self:StartIntervalThink(0.05)
  end
end


function modifier_drop:OnIntervalThink()
  local vec = self:GetParent():GetAbsOrigin()
  self.count = self.count + 1
  local z = vec[3] - Laws.flDropSpeed * math.pow(Laws.flDropAcceleration, self.count)
  vec = Vector(vec[1],vec[2],z)
  
  --self:GetParent():AddStaticVelocity("drop", Vector(0,0,-50))
  --self:GetParent():AddPhysicsVelocity(Vector(0,0,-50))
end
