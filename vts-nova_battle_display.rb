#============================================================================
#Nova Battle Display VTS
#By Ventwig
#Version 1.05 - January 1 2012
#For RPGMaker VX Ace
#=============================================================================
# Description:
# This script changes the display in-battle.
# The command windows are changed to a horizontal display, while faces and
# bars are displayed to the left. When that actor is selected, their bars
# grow, so you know where you're looking! The skill selection window
# is edited, too. See for yourself!
#==============================================================================
# Compatability:
#  Probably highly incompatible with things because of the amount of
#  things I re-wrote in the battle scene. Ask me for compatability patches!
#  Works with Jet's Sideview/efeberk's behind-view patch
#  Works with Neo Gauge Ultimate Ace
#===============================================================================
# Instructions: Put in materials, above main. Almost Plug and Play
#==============================================================================
# Please give Credit to Ventwig if you would like to use one of my scripts!
# Use it commericial or non-commercial, and feel free to tell me if you're using
# it commercially!
# You may edit my scripts, just don't claim as your own!
#===============================================================================
# NOTES:
# Recommended with Jet's Simple Sideview "Behind View" patch by efeberk
# The overall effect together is simple and amazing in my opinion.
# These are my recommended settings:
#	FIELD_POS = [175, 350]
#	FIELD_SPACING = [80, 0]
#############################################################################
#Customization
#############################################################################
module NEOBT_VTS
  #This is probably the biggest customization option.
  #Determines whether or not TP bars will be drawn. T/F
  USE_TP = true
end

#=============================================================================
# NO TOUCHEY! DA REST IS MAIIIIIIIIIIIIIIIIIIINNNEEEEE!
#=============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Battle Members
  #--------------------------------------------------------------------------
  def max_battle_members
    return 3
  end
end


class Window_BattleStatus < Window_Selectable  
  #--------------------------------------------------------------------------
  # * Starts Up The Window
  #--------------------------------------------------------------------------
  def initialize
    #Draws window
    super(0,0,545,500)
    self.z = 0
    self.opacity = 0
    @x, @y = 5, 50
    @party_size = $game_party.all_members.size
    battle_hud
    @long_index = self.index
  end
  #--------------------------------------------------------------------------
  # * Draws The HUD
  #--------------------------------------------------------------------------
  def battle_hud
    if $game_party.all_members.size >0
      @actor = $game_party.members[0]
      @actor_hp = @actor.hp
      @actor_mp = @actor.mp
      @actor_tp = @actor.tp
      draw_actor_face(@actor, @x+10, @y-10, enabled = true)
      draw_actor_icons(@actor, @x+15, @y-10+10)
      if self.index == 0
        if NEOBT_VTS::USE_TP == true
          draw_actor_tp(@actor, @x+80, @y-10+45,80)
        end
        draw_actor_hp(@actor, @x+20, @y-10+65,150)
        draw_actor_mp(@actor, @x+20, @y-10+80,150)
      else
        if NEOBT_VTS::USE_TP == true
          draw_actor_tp(@actor, @x+80, @y-10+45,50)
        end
        draw_actor_hp(@actor, @x+20, @y-10+65)
        draw_actor_mp(@actor, @x+20, @y-10+80)
      end
    end
    if $game_party.all_members.size >1
      @actor2 = $game_party.members[1]
      @actor2_hp = @actor2.hp
      @actor2_mp = @actor2.mp
      @actor2_tp = @actor2.tp
      draw_actor_face(@actor2, @x+10, @y-10+125, enabled = true)
      draw_actor_icons(@actor2, @x+15, @y-10+10+125)
      if self.index == 1
        if NEOBT_VTS::USE_TP == true
          draw_actor_tp(@actor2, @x+80, @y-10+45+125,80)
        end
        draw_actor_hp(@actor2, @x+20, @y-10+65+125,150)
        draw_actor_mp(@actor2, @x+20, @y-10+80+125,150)
      else
        if NEOBT_VTS::USE_TP == true
          draw_actor_tp(@actor2, @x+80, @y-10+45+125,50)
        end
        draw_actor_hp(@actor2, @x+20, @y-10+65+125)
        draw_actor_mp(@actor2, @x+20, @y-10+80+125)
      end
    end
    if $game_party.all_members.size >2
      @actor3 = $game_party.members[2]
      @actor3_hp = @actor3.hp
      @actor3_mp = @actor3.mp
      @actor3_tp = @actor3.tp
      draw_actor_face(@actor3, @x+10, @y-10+250, enabled = true)
      draw_actor_icons(@actor3, @x+15, @y-10+10+250)
      if self.index == 2
        if NEOBT_VTS::USE_TP == true
          draw_actor_tp(@actor3, @x+80, @y-10+45+250,80)
        end
        draw_actor_hp(@actor3, @x+20, @y-10+65+250,150)
        draw_actor_mp(@actor3, @x+20, @y-10+80+250,150)
      else
        if NEOBT_VTS::USE_TP == true
          draw_actor_tp(@actor3, @x+80, @y-10+45+250,50)
        end
        draw_actor_hp(@actor3, @x+20, @y-10+65+250)
        draw_actor_mp(@actor3, @x+20, @y-10+80+250)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Edits Sizing of the Selection Box
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new
    rect.width = 0#200
    rect.height = 0#100
    rect.x = 0#10
    rect.y = 0#40 + index / col_max * 125
    rect
  end
  
  
  #--------------------------------------------------------------------------
  # * Refresh/Redraw
  #--------------------------------------------------------------------------   
  def refresh
    contents.clear
    battle_hud
    @party_size = $game_party.all_members.size
    @long_index = self.index
  end    
  
  #--------------------------------------------------------------------------
  # * Updates (Tells when to refresh)
  #--------------------------------------------------------------------------
  def update
    super
    if @party_size != $game_party.all_members.size
      refresh
    end
    if @party_size > 0
      if $game_party.members[0].hp != @actor_hp  or $game_party.members[0].mp != @actor_mp or $game_party.members[0].tp != @actor_tp
        refresh
      end
    end
    if @party_size > 1
      if $game_party.members[1].hp != @actor2_hp or $game_party.members[1].mp != @actor2_mp or $game_party.members[1].tp != @actor2_tp 
        refresh
      end
    end  
    if @party_size > 2
      if $game_party.members[2].hp != @actor3_hp or $game_party.members[2].mp != @actor3_mp or $game_party.members[2].tp != @actor3_tp 
        refresh
      end
    end
    if self.index != @long_index
      refresh
    end
  end
end  

class Window_BattleActor < Window_BattleStatus
  #--------------------------------------------------------------------------
  # * Shows the Window
  #--------------------------------------------------------------------------
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.arrows_visible = false
      self.opacity = 255
      self.x = 0#-23+210
      self.y = 73
      self.z = 150
      self.width = Graphics.width/2
      self.height = Graphics.height - 70-50
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # * Draws the HUD
  #--------------------------------------------------------------------------
  def battle_hud
    if $game_party.all_members.size >0
      @actor = $game_party.members[0]
      @actor_hp = @actor.hp
      @actor_mp = @actor.mp
      @actor_tp = @actor.tp
      draw_actor_name(@actor, @x+10, @y-30)
      if self.index == 0
        draw_actor_hp(@actor, @x+20, @y-30+25,150)
        draw_actor_mp(@actor, @x+20, @y-30+40,150)
      else
        draw_actor_hp(@actor, @x+20, @y-30+25)
        draw_actor_mp(@actor, @x+20, @y-30+40)
      end
    end
    if $game_party.all_members.size >1
      @actor2 = $game_party.members[1]
      @actor2_hp = @actor2.hp
      @actor2_mp = @actor2.mp
      @actor2_tp = @actor2.tp
      draw_actor_name(@actor2, @x+10, @y-30+75)
      if self.index == 1
        draw_actor_hp(@actor2, @x+20, @y-30+25+75,150)
        draw_actor_mp(@actor2, @x+20, @y-30+40+75,150)
      else
        draw_actor_hp(@actor2, @x+20, @y-30+25+75)
        draw_actor_mp(@actor2, @x+20, @y-30+40+75)
      end
    end
    if $game_party.all_members.size >2
      @actor3 = $game_party.members[2]
      @actor3_hp = @actor3.hp
      @actor3_mp = @actor3.mp
      @actor3_tp = @actor3.tp
      draw_actor_name(@actor3, @x+10, @y-30+150)
      if self.index == 2
        draw_actor_hp(@actor3, @x+20, @y-30+25+150,150)
        draw_actor_mp(@actor3, @x+20, @y-30+40+150,150)
      else
        draw_actor_hp(@actor3, @x+20, @y-30+25+150)
        draw_actor_mp(@actor3, @x+20, @y-30+40+150)
      end
    end
  end
  def item_rect(index)
    rect = Rect.new
    rect.width = 0#200
    rect.height = 0#70
    rect.x = 0#10
    rect.y = 0#40 + index / col_max * 
    rect
  end
end

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Sets to 1 Row Per Column
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
end
class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Sets to 1 Row Per Column
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
end

class Window_BattleEnemy < Window_Selectable
  #--------------------------------------------------------------------------
  # * Shows the Window
  #--------------------------------------------------------------------------
  def show
    if @info_viewport
      width_remain = Graphics.width - width
      self.arrows_visible = false
      self.opacity = 255
      self.x = 0#-23+210
      self.y = 73
      self.z = 150
      self.width = Graphics.width/2
      self.height = Graphics.height - 70-50
      @info_viewport.rect.width = width_remain
      select(0)
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Sets to 1 Row Per Column
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
end


class Window_PartyHorzCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(window_width)
    @window_width = window_width
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::fight,  :fight)
    add_command(Vocab::escape, :escape, BattleManager.can_escape?)
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup
    clear_command_list
    make_command_list
    refresh
    select(0)
    activate
    open
  end
end
#====================================================================
#====================================================================
class Window_ActorHorzCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(window_width)
    @window_width = window_width
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    add_attack_command
    add_skill_commands
    add_guard_command
    add_item_command
  end
  #--------------------------------------------------------------------------
  # * Add Attack Command to List
  #--------------------------------------------------------------------------
  def add_attack_command
    add_command(Vocab::attack, :attack, @actor.attack_usable?)
  end
  #--------------------------------------------------------------------------
  # * Add Skill Command to List
  #--------------------------------------------------------------------------
  def add_skill_commands
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Add Guard Command to List
  #--------------------------------------------------------------------------
  def add_guard_command
    add_command(Vocab::guard, :guard, @actor.guard_usable?)
  end
  #--------------------------------------------------------------------------
  # * Add Item Command to List
  #--------------------------------------------------------------------------
  def add_item_command
    add_command(Vocab::item, :item)
  end
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(actor)
    @actor = actor
    clear_command_list
    make_command_list
    refresh
    select(0)
    activate
    open
  end
end

#====================================================================
#====================================================================
#====================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Get Maximum Number of Battle Members
  #--------------------------------------------------------------------------
  alias neobt_vts_status_create_status_window create_status_window
  def create_status_window
    neobt_vts_status_create_status_window
    create_info_viewport
    @status_window = Window_BattleStatus.new
    @status_window.x = 128
  end  
  
  #--------------------------------------------------------------------------
  # * Edits and Adds both viewports
  #--------------------------------------------------------------------------
  def create_info_viewport
    @info_viewport = Viewport.new
    @info_viewport.rect.y = Graphics.height - 48
    @info_viewport.rect.height = Graphics.height
    @info_viewport.z = 100
    @info_viewport.ox = 0
    
    @sinfo_viewport = Viewport.new
    @sinfo_viewport.rect.x = -150
    @sinfo_viewport.rect.y = -40
    @sinfo_viewport.rect.height = Graphics.height
    @sinfo_viewport.z = 100
    @sinfo_viewport.ox = 0
    @status_window.viewport = @sinfo_viewport
  end
  
  #--------------------------------------------------------------------------
  # * Removes The Viewport Movements
  #--------------------------------------------------------------------------
  def update_info_viewport
  end
  
  #--------------------------------------------------------------------------
  # * Edits Party Command Window
  #--------------------------------------------------------------------------
  def create_party_command_window
    @party_command_window = Window_PartyHorzCommand.new(Graphics.width)
    @party_command_window.x = 0
    @party_command_window.height = 48
    @party_command_window.y = Graphics.height - 48
    @party_command_window.width = @status_window.width
    @party_command_window.set_handler(:fight,  method(:command_fight))
    @party_command_window.set_handler(:escape, method(:command_escape))
    @party_command_window.unselect
  end
  
  #--------------------------------------------------------------------------
  # * Edits Actor Command Window
  #--------------------------------------------------------------------------
  def create_actor_command_window
    @actor_command_window = Window_ActorHorzCommand.new(Graphics.width)
    @actor_command_window.x = 0
    @actor_command_window.height = 48
    @actor_command_window.y = Graphics.height - 48
    @actor_command_window.width = @status_window.width
    @actor_command_window.set_handler(:attack, method(:command_attack))
    @actor_command_window.set_handler(:skill,  method(:command_skill))
    @actor_command_window.set_handler(:guard,  method(:command_guard))
    @actor_command_window.set_handler(:item,   method(:command_item))
    @actor_command_window.set_handler(:cancel, method(:prior_command))
  end
  
  #--------------------------------------------------------------------------
  # * Moves Skill Window
  #--------------------------------------------------------------------------
  alias neobt_vts_create_skill_window create_skill_window
  def create_skill_window
    neobt_vts_create_skill_window
    @skill_window.x = Graphics.width/2
    @skill_window.width = Graphics.width/2
  end
  #--------------------------------------------------------------------------
  # * Moves Item Window
  #--------------------------------------------------------------------------
  alias neobt_vts_create_item_window create_item_window
  def create_item_window
    neobt_vts_create_item_window
    @item_window.x = Graphics.width/2
    @item_window.width = Graphics.width/2
  end
  
end
  #########################################################################
  #End Of Script                                                          #
  #########################################################################