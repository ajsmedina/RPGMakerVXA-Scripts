#============================================================================
#VTS Reserves Assist
#By Ventwig
#Version 1.02 - Jun 24 2014
#For RPGMaker VX Ace
#=============================================================================
# Description:
# When the player chooses to do a normal attack, there is a chance that a 
# character currently out of battle will butt in and, instead, cast their own
# skill. Actors can have a selection of skills, and the current skill that
# will be used is based off of a variable, so that stronger skills can be 
# used as assists later on in the game
# Compatible with Mr.Bubble's party guests script
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
# All notetags go inside the actor notebox
# If the actor will be used as a party guest, then these notetags
# MUST be used. Defaults do not work for guest characters.
#
# <assist_skills x, x, x, x>
# <assist_var x>
#================
# The first notetag determines which skills the actor can use to assist. 
# Only one will be used at a time, and which one is based upon a variable.
# Add as many x-es as you like, but make sure to put a space after the comma!
# The variable is assigned by the second notetag, x being the variable id.
# A variable equalling to zero means that the first skill in the list is chosen.
# =1 means the second in the list. Please keep this in mind.
#
# <assist_text "xxxxxx">
# <assist_message "xxxx","xxxxx","xxxxx">
#================
# The first notetage indicates the first line the actor will say when assisting.
# This is the same regardless of which skill is used. The user's name will be
# added automatically.
# The second notetag indicates the second line used for each skill. This follows
# the same index as the assist_skills notetag above. This quote
# is said right after the assist_text quote
# 
# <no_assist>
#================
# Place this inside an actor's notetag and they'll never assist.
# Normally, an actor will use the default settings if no notetags are assigned.
# However, if this notetag is used, then the actor will never assist.
#===============================================================================

module VTS_RESERVES #Do not touch
#================
# CUSTOMIZATION
#================
  
  #Switch ID. Turn this switch ON to disable assisting
  DISABLE_ASSIST = 0
  
  #Default Settings. These are the assist settings if no notetags
  #are applied.
  DEFAULT_SKILL = 1
  DEFAULT_TEXT = "'I'll fight, too!'"
  DEFAULT_MESSAGE = "'Here we go!'"
  
  #Percentage in which assists occur 
  #Does not work alonside ASSIST_VARRATE
  ASSIST_RATE = 50
  
  #Variable to determine assist rate. Set to -1 if you do not want
  #to use. Whatever # the assigned variable is, that is the percentage
  ASSIST_VARRATE = -1
  
  #Add to the assist rate based on amount of reserve members
  ASSIST_ADD = true
  #Percent to add
  ASSIST_ADD_AMOUNT = 5
  
#================
# BELOW HERE IS CODE
#================
  
end


module RPG
  class Actor
    def assist_skills
      if @assist_skills.nil?
        if @note =~ /<assist_skills (.*)>/i
          @assist_skills= $1.split(",")
        else
          @assist_skills = [VTS_RESERVES::DEFAULT_SKILL]
        end
      end
      @assist_skills
    end
    def assist_var
      if @assist_var.nil?
        if @note =~ /<assist_var (.*)>/i
          @assist_var= $1.to_i
        else
          @assist_var = 0
        end
      end
      @assist_var
    end
    def assist_text
      if @assist_text.nil?
        if @note =~ /<assist_text (.*)>/i
          @assist_text = $1
        else
          @assist_text = VTS_RESERVES::DEFAULT_TEXT
        end
      end
      @assist_text
    end
    def assist_message
      if @assist_message.nil?
        if @note =~ /<assist_message (.*)>/i
          @assist_message= $1.split(",")
        else
          @assist_message = [VTS_RESERVES::DEFAULT_MESSAGE]
        end
      end
      @assist_message
    end
    def no_assist
      if @no_assist.nil?
        if @note =~ /<no_assist>/i
          @no_assist = true
        else
          @no_assist = false
        end
      end
      @no_assist
    end
  end
end

class Game_Action
  attr_accessor :reserves_old_skill
  attr_accessor :assist_id
end

class Game_Actor < Game_Battler
  def assist_skills
    return actor.assist_skills
  end
  def assist_var
    return actor.assist_var
  end
  def assist_text
    return actor.assist_text
  end
  def assist_message
    return actor.assist_message
  end
  def no_assist
    return actor.no_assist
  end
  def actor_id
     return @actor_id
  end
end

class Game_Battler < Game_BattlerBase
  def reserve_assist_action(a)
    return unless current_action.item.is_a?(RPG::Skill)
    curr_skill = current_action.item
    
    if curr_skill == $data_skills[1]
      if a.actor? == true
        j = rand(101)
       # puts(j)
       
        if VTS_RESERVES::ASSIST_VARRATE == -1
          w = VTS_RESERVES::ASSIST_RATE
          if VTS_RESERVES::ASSIST_ADD == true
            x = $game_party.all_members.size-$game_party.battle_members.size
            y = x*VTS_RESERVES::ASSIST_ADD_AMOUNT
            w += y
          end
        else
          w = $game_variables[VTS_RESERVES::ASSIST_VARRATE]
          if VTS_RESERVES::ASSIST_ADD == true
            x = $game_party.all_members.size-$game_party.battle_members.size
            y = x*VTS_RESERVES::ASSIST_ADD_AMOUNT
            w += y
          end
        end
            
        #puts(w)
        if j < w
          b = $game_party.battle_members.size
          if $imported["BubsPartyGuests"] == true
            c = $game_party.guests.size 
          else
            c = 0
          end
          d = $game_party.all_members.size
          puts(b)
          puts(c)
          puts(d)
          if d > b
            h = rand(d+c-b)+b
            puts(h)
            if h >= d
              k = $game_party.guests[h-d]
            else
              k = $game_party.all_members[h]
            end
            puts(k.name)
            puts("-")
            if k.no_assist == false
              if $game_variables[k.assist_var] > k.assist_skills.size-1
                assist_skill = k.assist_skills[k.assist_skills.size-1].to_i
              else
                assist_skill = k.assist_skills[$game_variables[k.assist_var]].to_i
              end
              current_action.set_skill(assist_skill)
              current_action.reserves_old_skill = curr_skill
              current_action.item.mp_cost = curr_skill.mp_cost
              current_action.assist_id = k
              
              if current_action.item.for_friend? == true and current_action.item.for_one? == true
                current_action.decide_random_target
              end
           #   puts(current_action.assist_id)
              return
            end
          end
        end
      end
    end
    current_action.assist_id = 0
  end
  alias reserves_assist_original_make_damage_value make_damage_value
  def make_damage_value(user, item)
    if item.is_a?(RPG::Skill) and user.actor? == true
      if user.current_action.reserves_old_skill != nil
        user.current_action.reserves_old_skill = nil
        user = user.current_action.assist_id
      # puts(">" + user.name)
      end
    end
    reserves_assist_original_make_damage_value(user, item)
  end
end # Game_Battler

class Window_BattleLog < Window_Selectable
  alias vts_reserves_assist_display_use_item display_use_item
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      if subject.current_action.reserves_old_skill != nil
        name = subject.name
        rm = subject.current_action.assist_id
     #   rm = $game_party.all_members[p]
        change_text = rm.assist_text
        pre_text = rm.name + ": "
        if $game_variables[rm.assist_var] > rm.assist_skills.size-1
          new_text = rm.assist_message[rm.assist_skills.size-1]
        else
          new_text = rm.assist_message[$game_variables[rm.assist_var]]
        end
        skill_name = item.name + '!'
        use_name = subject.current_action.reserves_old_skill.message1
        old_skill_text = name + use_name
        add_text(old_skill_text)
        wait
        add_text(pre_text + change_text)
        wait
        add_text(pre_text + new_text)
        return
      end
    end
  vts_reserves_assist_display_use_item(subject, item)
  subject.current_action.reserves_old_skill = nil
  end
end

class Scene_Battle < Scene_Base
  alias scene_battle_use_reserve_new use_item
  def use_item
    @subject.reserve_assist_action(@subject) unless $game_switches[VTS_RESERVES::DISABLE_ASSIST] == true
    scene_battle_use_reserve_new
  end
end # Scene_Battle
#End of Script