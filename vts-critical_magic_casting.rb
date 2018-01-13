#============================================================================
#VTS-Critical Magic Casting
#By Ventwig
#Version 1.1 - Jun 1 2014
#For RPGMaker VX Ace
#=============================================================================
# Description:
# This "Critical Magic Casting" script gives your spellcasters a little bonus.
# through a custom formula, select spells will be able to evolve into a stronger
# one before casting, enabling the caster to use the new spell at no extra cost!
# Also includes specific critical rates based on both actor AND skill
#==============================================================================
# Compatability:
# No issues so far. It's pretty unlikely unless you're using a full-out battle
# changer like an ABS (though that might work)
#===============================================================================
# Instructions: Put in materials, above main. Simple notetags are required.
#==============================================================================
# Please give Credit to Ventwig if you would like to use one of my scripts!
# Use it commericial or non-commercial, and feel free to tell me if you're using
# it commercially!
# You may edit my scripts, just don't claim as your own!
#===============================================================================

#===============================================================================
# Notetags! 
#===============================================================================
# CMC = Critical Magic Cast
#
# <crit_skill x>
#================
# This is the base of it all and the only tag that's required to set up the 
# CMC. Put this tag into the notebox of the skill that should be used BEFORE
# the CMC. Replace the x with the skillid of the new skill.
#
# <crit_rate x>
#================
# This can be used inside the formula of the CMC rate. Default is 0, so
# it is not mandatory. It is used by default to increase/decrease the rate in
# which a CMC will occur. A negative number will decrease it. This affects
# all characters.
#
# <crit_act x,x,x>
# <act_rate x,x,x>
#================
# This determines actor AND skill specific rates. Used in skill noteboxes
# The first one determines which actors get specific rates.
# The second one determines said rates for those actors.
# They line up together, so if Eric is used in the first slot, his rate should
# also be in the first slot.
# This is added on top of the <crit_rate x> (unless you change the formula)
# You can add as many x-s as you want
# PLEASE NOTE: 
#  <crit_act> uses ACTOR IDs. That's the number beside the actor name! 
#
# <acrit_rate x>
#================
# This works like crit_rate, except it is placed inside the actor notebox.
#===============================================================================
 

#===============================================================================
#Changing the formula (on line 133)
#===============================================================================
# crit = 10 + rand(101) + a.acrit_rate + quest_skill.crit_rate + privat_rate
#
# This is the default formula to determine the chance for a CMC. You can work it
# around like any other math problem similar to the skill formula in the database.
# After the formula, if "crit" is equal to or greater than 100, a CMC will occur.

# Here are some major components:       
# [crit = ] leave this be. It is required for the script to work
# [15/number] this adds to the chance for a CMC. 
# [rand(101)] a random number between 0-100. The number you use is NOT included
# [a.luk/50] like in the skill formula. Be careful when using luck as it gets pretty
#            high at later levels (200+ for default thief class)
# [a.acrit_rate] accesses the notetag above with the same name. def 0
# [quest_skill.crit_rate] accesses the notetag above with the same name. def 0
# [a.cri*100] this isn't in the formula but incase you want it. This gets the
#              actor's critical hit rate. By default, it's 0.04 so multiply it
#              by 100 to make it worth something.
# [private_rate] refers to the note tags <crit_act> and <act_rate>
#                make sure to include this for those to work!
#===============================================================================
# If you're curious as to what levels you're getting each skill, place
# p(a.name)
# p(a.crit)
# under the formula. It will display the value of "crit" in the console
#==============================================================================

module VTS_CRITSKILL
  CRIT_TEXT = "Critical Magic Cast!" 
  #The text said when announcing the new change
end
#############################################################################

#===============================================================================
#DON'T TOUCH HERE!
#===============================================================================

module RPG
  class BaseItem 
    def crit_skill
      if @crit_skill.nil?
        if @note =~ /<crit_skill (.*)>/i
          @crit_skill= $1.to_i
        else
          @crit_skill = 0 
        end
      end
      @crit_skill
    end
    def crit_rate
      if @crit_rate.nil?
        if @note =~ /<crit_rate (.*)>/i
          @crit_rate= $1.to_i
        else
          @crit_rate = 0 
        end
      end
      @crit_rate
    end
    def crit_act
      if @crit_act.nil?
        if @note =~ /<crit_act (.*)>/i
          @crit_act = $1.split(",")
        else
          @crit_act =  []
        end
      end
      @crit_act
    end
    def act_rate
      if @act_rate.nil?
        if @note =~ /<act_rate (.*)>/i
          @act_rate = $1.split(",")
        else
          @act_rate =  []
        end
      end
      @act_rate
    end
  end
  
  class Actor
    def acrit_rate
      if @acrit_rate.nil?
        if @note =~ /<acrit_rate (.*)>/i
          @acrit_rate= $1.to_i
        else
          @acrit_rate = 0
        end
      end
      @acrit_rate
    end
  end
end

class Game_Action
  attr_accessor :old_skill
end

class Game_Actor < Game_Battler
  def acrit_rate
    return actor.acrit_rate
  end
  def actor_id
     return @actor_id
  end
end

class Game_Battler < Game_BattlerBase
  def crit_new_skill(a)
    return unless current_action.item.is_a?(RPG::Skill)
    quest_skill = current_action.item
    
    if a.actor? == true
      rate_index = quest_skill.crit_act.index(a.actor_id.to_s)
      if rate_index != nil
        private_rate = quest_skill.act_rate[rate_index].to_i
      else
        rate_index = 0
        private_rate = 0
      end
    else
      rate_index = 0
      private_rate = 0
    end
    
    if quest_skill.crit_skill != 0
      #====================F=O=R=M=U=L=A===================================
        crit = 10 + rand(101) + a.acrit_rate + quest_skill.crit_rate + private_rate
      #====================F=O=R=M=U=L=A=================================== 
        if crit >= 100
          current_action.set_skill(quest_skill.crit_skill)
          current_action.old_skill = quest_skill 
          current_action.item.mp_cost = current_action.old_skill.mp_cost
        end
    end
  end
end # Game_Battler

class Window_BattleLog < Window_Selectable
  alias vts_critskill_display_use_item display_use_item
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      if subject.current_action.old_skill != nil
        name = subject.name
        change_text = VTS_CRITSKILL::CRIT_TEXT
        skill_name = item.name + '!'
        use_name = subject.current_action.old_skill.message1
        old_skill_text = name + use_name
        add_text(old_skill_text)
        wait
        new_skill_text = change_text
        add_text(new_skill_text)
        wait
      end
    end    
    vts_critskill_display_use_item(subject, item)
    subject.current_action.old_skill = nil
  end
end

class Scene_Battle < Scene_Base
  alias scene_battle_use_crit_new use_item
  def use_item
    @subject.crit_new_skill(@subject)
    scene_battle_use_crit_new
  end
  
end # Scene_Battle
#End of Script