#============================================================================
#VTS Enemy HP Bars
#By Ventwig
#Version 2.02 - Jul 15 2014
#For RPGMaker VX Ace
#=============================================================================
#=============================================================================
# Description:
# This script adds HP bars that display the name, mp, and states of 
# enemies, with longer bars for up to two bosses.
# Many other features are also included!
#===============================================================================
# Compatability:
#  Works with Neo Gauge Ultimate Ace (Recommended)
#===============================================================================
# Instructions: Put in materials, above main.
# Put below Neo Gauge Ultimate Ace if used
#===============================================================================
# Please give credit to Ventwig if you would like to use one of my scripts!
# Use it commericial or non-commercial, and feel free to tell me if you're using
# it commercially!
# You may edit my scripts, just don't claim as your own!
#===============================================================================
#Notetags
#===============================================================================
#<hide_hp>
#<show_mp>/<hide_mp>
#<boss_bar>
#<personal_y x>
#===============================================================================
#Mix and match the three notetags! They're pretty much self-explanatory.
#<hide_hp> stops hp from being shown
#<show_mp> shows an mp bar, if REVERSE_MP below is set to false.
#<hide_mp> hides the mp bar, if REVERSE_MP is true.
#          If reverse_mp is false, enemies have hidden mp by default. If true,
#          then they normally have mp shown. Please use the right one.
#<boss_bar> sets the enemy to a boss, using the long bar (A BOSS MUST BE THE
#           FIRST ENEMY IN THE TROOP OR ELSE EVERYTHING GOES WHACK)
#<personal_y x> set x to any number (positive or negative)
#            determines how much to raise/lower the info for that enemy
#            + numbers raise, and - numbers lower
#===============================================================================

module EHUD
 
  #Determines how much to raise/lower the info
  #Same as <personal_y x>, except this affects all enemies
  Y_MOVE = 0
  
  #Are you using Neo Guage Ultimate Ace?
  #Set true if yes, false if no
  NEO_ULTIMATE_ACE = false
 
  #Want to show mp for most enemies but don't want to bother putting all the
  #noteatags? Turn this to true and show_mp turns into hide_mp and will actually
  #HIDE the mp. MP then shows by default
  REVERSE_MP = false
  
  #Determines how to draw HP info
  #true shows the current HP amount, where as false only displays the bar
  DRAW_HP_NUMBERS = false
  
  #true displays the abbreviation for HP set in the "Vocab" section
  #of the database, false does not
  DRAW_HP_VOCAB = true
  
  #These settings make it compatible with my "Nova Battle Display" system!
  #Play around with the numbers, but I've provided recommended "Nova" settings
  #Change the X value of the bar. Def: 0  Nova:150
  BOSS_GAUGEX = 10
  #How long the boss gauge should be.  Def: 475  Nova:325
  BOSS_GAUGEW = 475
 
  #Determines whether or not the minions' HP will still be shown in a boss battle!
  #This is determined via a switch, so you can toggle per boss!
  #ON=HIDE OFF=SHOW
  #The thing about this switch, though, is that you have to toggle it MANUALLY
  #everytime you want to change it. So before a boss fight, turn it on.
  #After, turn it back off.
  #THIS DOES NOT HAVE TO BE USED WITH JUST BOSSES
  #Set to 0 if you don't want this.
  HIDE_MINIONS = 0
 
end
 

class RPG::BaseItem 
  def show_mp
    if @show_mp.nil?
      if EHUD::REVERSE_MP == false
        if @note =~ /<show_mp>/i
          @show_mp = true
        else
          @show_mp = false
        end
      else
        if @note =~ /<hide_mp>/i
          @show_mp= false
        else
          @show_mp = true
        end
      end
    end
    @show_mp
  end
  def hide_hp
    if @hide_hp.nil?
      if @note =~ /<hide_hp>/i
        @hide_hp = true
      else
        @hide_hp = false
      end
    end
    @hide_hp
  end
  def boss_bar
    if @boss_bar.nil?
      if @note =~ /<boss_bar>/i
        @boss_bar= true
      else
        @boss_bar = false
      end
    end
    @boss_bar
  end
  def personal_y
    if @personal_y.nil?
      if @note =~ /<personal_y (.*)>/i
        @personal_y= $1.to_i
      else
        @personal_y = 0 
      end
    end
    @personal_y
  end
end
 
class Game_Enemy < Game_Battler
  
  alias shaz_enemyhud_initialize initialize
  
  attr_accessor :old_hp
  attr_accessor :old_mp
  
  def initialize(index, enemy_id)
        shaz_enemyhud_initialize(index, enemy_id)
        @old_hp = mhp
        @old_mp = mmp
  end
  def boss_bar
     return enemy.boss_bar
  end
  def show_mp
     return enemy.show_mp
  end
  def hide_hp
     return enemy.hide_hp
  end
  def personal_y
     return enemy.personal_y
  end
end
 
class Window_Enemy_Hud < Window_Base
  def initialize
    super(0,0,545,400)
    self.opacity = 0
    self.arrows_visible = false
    self.z = 0
    @enemy = []  
    @boss_enemy = []
    troop_fix
    boss_check
    enemy_hud
    refresh
  end
  
if EHUD::NEO_ULTIMATE_ACE == false
  def draw_actor_mp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
  end
else
  def draw_actor_mp(actor, x, y, width = 124)
    gwidth = width * actor.mp / [actor.mmp, 1].max
    cg = neo_gauge_back_color
    c1, c2, c3 = cg[0], cg[1], cg[2]
    draw_neo_gauge(x + HPMP_GAUGE_X_PLUS, y + line_height - 8 +
      HPMP_GAUGE_Y_PLUS, width, HPMP_GAUGE_HEIGHT, c1, c2, c3)
    (1..3).each {|i| eval("c#{i} = MP_GCOLOR_#{i}")}
    draw_neo_gauge(x + HPMP_GAUGE_X_PLUS, y + line_height - 8 +
      HPMP_GAUGE_Y_PLUS, gwidth, HPMP_GAUGE_HEIGHT, c1, c2, c3, false, false,
      width, 40)
    change_color(system_color)
  end
end

if EHUD::NEO_ULTIMATE_ACE == false
  def draw_actor_hp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a) if EHUD::DRAW_HP_VOCAB == true
    change_color(hp_color(actor))
    draw_text(x+width/4*3, y, 100, line_height, actor.hp) if EHUD::DRAW_HP_NUMBERS == true
    change_color(system_color)
  end
else
  def draw_actor_hp(actor, x, y, width = 124)
    gwidth = width * actor.hp / actor.mhp
    cg = neo_gauge_back_color
    c1, c2, c3 = cg[0], cg[1], cg[2]
    draw_neo_gauge(x + HPMP_GAUGE_X_PLUS, y + line_height - 8 +
      HPMP_GAUGE_Y_PLUS, width, HPMP_GAUGE_HEIGHT, c1, c2, c3)
    (1..3).each {|i| eval("c#{i} = HP_GCOLOR_#{i}")}
    draw_neo_gauge(x + HPMP_GAUGE_X_PLUS, y + line_height - 8 +
      HPMP_GAUGE_Y_PLUS, gwidth, HPMP_GAUGE_HEIGHT, c1, c2, c3, false, false,
      width, 30)
      change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a) if EHUD::DRAW_HP_VOCAB == true
       change_color(hp_color(actor))
    draw_text(x+width/4*3, y, 100, line_height, actor.hp) if EHUD::DRAW_HP_NUMBERS == true
       change_color(system_color)
  end
end
 
  def troop_fix
    @etroop = $game_troop
    return if @etroop.alive_members.size <= 0
    for i in 0..@etroop.alive_members.size-1
      @enemy[i] = @etroop.alive_members[i]
    end
  end
  
  def enemy_hud
    troop_fix    
    for i in 0..@etroop.alive_members.size-1
      e = @enemy[i]
      if i <= 1 and e.boss_bar == true and e == @boss_enemy[i]
        draw_actor_name(e,EHUD::BOSS_GAUGEX,5+50*i)
        draw_actor_hp(e,EHUD::BOSS_GAUGEX,20+50*i,width=EHUD::BOSS_GAUGEW) unless e.hide_hp == true
        draw_actor_mp(e,EHUD::BOSS_GAUGEX,30+50*i,width=EHUD::BOSS_GAUGEW) unless e.show_mp == false
        draw_actor_icons(e,EHUD::BOSS_GAUGEX+200,5+50*i, width = 96) 
      elsif $game_switches[EHUD::HIDE_MINIONS] != true
        draw_actor_hp(e,e.screen_x-50,e.screen_y+EHUD::Y_MOVE-50+e.personal_y,width=96) unless e.hide_hp == true
        draw_actor_mp(e,e.screen_x-50,e.screen_y+EHUD::Y_MOVE-40+e.personal_y,width=96) unless e.show_mp == false
        draw_actor_icons(e,e.screen_x-50,e.screen_y+EHUD::Y_MOVE-70+e.personal_y,width=96) 
      end
    end
  end
   
  def refresh
    contents.clear
    enemy_hud
    boss_check if @boss_enemy !=nil
  end
  
  def boss_check
    if @enemy[0].boss_bar == true
      @boss_enemy[0] = @enemy[0]
      if @enemy[1] != nil
        if @enemy[1].boss_bar == true
          @boss_enemy[1] = @enemy[1]
        else
          @boss_enemy[1] = nil
        end
      end
    else
      @boss_enemy[0] = nil
      @boss_enemy[1]= nil
    end
  end

  
  def update
    refresh_okay = false
    $game_troop.alive_members.each do |enemy|
      if enemy.hp != enemy.old_hp || enemy.mp != enemy.old_mp
        refresh_okay = true
        enemy.old_hp = enemy.hp
        enemy.old_mp = enemy.mp
      end
    end
   
    if $game_troop.alive_members.size != @old_size
      refresh_okay = true
    end
   
    if refresh_okay
      refresh
    end
  end
end
 
class Scene_Battle < Scene_Base
  alias hpbars_create_all_windows create_all_windows
  def create_all_windows
    hpbars_create_all_windows
    create_enemy_hud_window
  end
  def create_enemy_hud_window
    @enemy_hud_window = Window_Enemy_Hud.new
  end
end
  #########################################################################
  #End Of Script                                                          #
  #########################################################################