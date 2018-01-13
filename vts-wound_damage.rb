#============================================================================
#VTS Wound Damage
#By Ventwig
#Version 1.01 - Jul 17 2014
#For RPGMaker VX Ace
#=============================================================================
# Description:
# Attacks can deal "wound damage" on top of regular HP damage.
# Wound damage damages the target's Max HP, preventing them from fully
# recovering their HP, just like in Final Fantasy XIII-2.
# Certain items and skills assigned by the user can recover wounds.
#===============================================================================
# Instructions: Put in materials, above main. 
# Customization features below, as well as notetags
#==============================================================================
# Please give credit to Ventwig if you would like to use one of my scripts!
# Use it commericial or non-commercial, and feel free to tell me if you're using
# it commercially!
# You may edit my scripts, just don't claim as your own!
#===============================================================================

#===============================================================================
#Notetags
#===============================================================================
# All notetags go inside the skill notebox
#
# <wound_rate x>
#================
# This determines what percentage of HP damage will deal wound damage.
# If an attack were to deal 500 damage, and it had a wound rate of 50,
# then the attack will deal 500 damage, and the target's Max HP will be lowered
# by 250. 
# To heal wounds, use the same tag except on a healing skill. 
# If an actor were to heal 100 HP, and the wound rate is 200, then they will
# recover 100 HP and 200MHP up to the initial limit.
# Negative wound rates DO work. Use these to heal wounds while damaging,
# or inflict them through healing
#
# <wound_only>
#================
# Use this tag if you want the attack to only affect wound hp.
# The damage calculations are still done up in the formula box.
# wound_rate is ignored
# 
#=============================
# PLEASE NOTE:
# Wounds are only calculate based on HP damage and HP recovery.
# To deal wounds, the skill has to be set to HP Damage.
# To heal wounds, the skill has to be set to HP Recovery.
#=============================
# DAMAGE FORMULA:
# In the damage formula, mhp (both a.mhp and b.mhp) will refer
# to the target's current max hp. To affect the target's original max hp,
# use omhp, instead. The same is true for percent-based healing.
#
# To refer to an actor's current wound damage, use whp.
#===============================================================================
# CUSTOMIZATION
#===============================================================================
module VTS_WOUNDS
  #The default wound rate of any skill that does not have the <wound_rate x>
  #notetag described above
  DEFAULT_WOUND_RATE = 10
  
  #Set this to true if you want all wounds removed after the battle ends.
  #When wounds are recovered after battle, the lost HP is not.
  #Using this may run into some compatibility errors. Contact me for help.
  RECOVER_AFTER_BATTLE = true
  
  #The colors of the bar indicating current max HP.
  #Color #s set in windowskin
  #Defaults: 10 and 2
  WOUND_COLOR1 = 10
  WOUND_COLOR2 =  2
  
  #The BattleLog text when receiving or recovering wound damage
  #Leavs all %s as they are, but change anything else
  WOUND_DAMAGE_TEXT = "%s took %s Wound Damage!"
  WOUND_HEAL_TEXT = "%s recovered %s Wound Damage!"
end

#Customization end

module RPG
  class BaseItem 
    def wound_rate
      if @wound_rate.nil?
        if @note =~ /<wound_rate (.*)>/i
          @wound_rate= $1.to_i
        else
          @wound_rate = VTS_WOUNDS::DEFAULT_WOUND_RATE
        end
      end
      @wound_rate
    end
    def wound_only
      if @wound_only.nil?
        if @note =~ /<wound_only>/i
          @wound_only = true
        else
          @wound_only = false
        end
      end
      @wound_only
    end
  end
end
  
class Game_ActionResult
  attr_accessor :wound_damage 
  
  def hp_damage_text
    if @hp_drain > 0
      fmt = @battler.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      sprintf(fmt, @battler.name, Vocab::hp, @hp_drain)
    elsif @hp_damage > 0
      fmt = @battler.actor? ? Vocab::ActorDamage : Vocab::EnemyDamage
      sprintf(fmt, @battler.name, @hp_damage)
    elsif @hp_damage < 0
      fmt = @battler.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      sprintf(fmt, @battler.name, Vocab::hp, -hp_damage)
    elsif @wound_damage > 0 && @hp_damage == 0
      fmt = VTS_WOUNDS::WOUND_DAMAGE_TEXT
      sprintf(fmt, @battler.name, @wound_damage)
    elsif @wound_damage < 0 && @hp_damage == 0
      fmt = VTS_WOUNDS::WOUND_HEAL_TEXT
      sprintf(fmt, @battler.name, @wound_damage)
    else
      fmt = @battler.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
      sprintf(fmt, @battler.name)
    end
  end
  
  alias wound_make_damage make_damage
  def make_damage(value, item)
    wound_make_damage(value,item)
    if item.wound_only == true
      @wound_damage = @hp_damage
      @hp_damage = 0
    else
      @wound_damage = @hp_damage * item.wound_rate / 100
      @wound_damage = 0 if item.wound_rate == 0 or @hp_damage == 0
    end
  end
end

class Game_BattlerBase
  attr_accessor :whp
    
  def mhp;  param(0);   end               # MHP  Maximum Hit Points
  def omhp;  param_base(0);   end               # OMHP  Original Maximum Hit Points
  
  alias wound_initialize initialize
  def initialize
    wound_initialize
    @whp = 0
  end
  
  def mhp_rate
    mhp.to_f / omhp
  end
  
  def hp_rate
    @hp.to_f / omhp
  end
end

class Game_Battler < Game_BattlerBase
  alias execute_wound_damage execute_damage
  def execute_damage(user)
    check_wound
    execute_wound_damage(user)
  end
  
  def check_wound
    wound = @result.wound_damage
    wound = [@result.wound_damage,(self.omhp-self.mhp)*-1].max if wound < 0 and @result.hp_damage <= 0
    self.whp += wound
    add_param(0, wound*-1)
  end

  alias wound_item_test item_test
  def item_test(user, item)
    return true if item.damage.recover? && item.wound_only && mhp < omhp
    wound_item_test(user, item)
  end
  
  alias wound_battle_end on_battle_end
  def on_battle_end
    clear_param_plus if VTS_WOUNDS::RECOVER_AFTER_BATTLE == true
    wound_battle_end
  end
end

class Window_Base < Window
  def draw_actor_hp(actor, x, y, width = 124)
    draw_hp_gauge(x, y, width, actor.hp_rate, actor.mhp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp,
    hp_color(actor), normal_color)
  end
  
  def draw_hp_gauge(x, y, width, rate, rate2, color1, color2)
    fill_w2 = (width * rate2).to_i
    fill_w = (width * rate).to_i
    gauge_y = y + line_height - 8
    contents.fill_rect(x, gauge_y, width, 6, gauge_back_color)
    contents.gradient_fill_rect(x, gauge_y, fill_w2, 6, text_color(VTS_WOUNDS::WOUND_COLOR1), text_color(VTS_WOUNDS::WOUND_COLOR2))
    contents.gradient_fill_rect(x, gauge_y, fill_w, 6, color1, color2)
  end
end