#============================================================================
#Pause Menu Features
#By Ventwig
#Version 1.3 - April 10 2012
#For RPGMaker VX Ace
#============================================================================
# This simple scirpt was a request by JayPB08, then I decided I'd let everyone
# have it :)
# Thanks apoclaydon for pointing out a mistake where the icon didn't change!
#=============================================================================
# Description:
# This code draws a gold window, and a playtime window (which counts up)
# Right under the command window. They're two seperate windows to look nicer,
# and you can disable one if you'd like :)
# You can also draw icons, too!
# And in v 1.3, I added a Gold Window Extension!
#==============================================================================
# Compatability:
#  alias-es Scene_Menu Start
#  Creates two new methods in Scene_Menu
#  Works with Spike's Monentary System! OMG!
#===============================================================================
# Instructions: Put in materials, above main.Plug'N'Play
#==============================================================================
# Please give Credit to Ventwig if you would like to use one of my scripts!
# Use it commericial or non-commercial, and feel free to tell me if you're using
# it commercially!
# You may edit my scripts, just don't claim as your own!
#===============================================================================
module VENTWIG #Do not touch
  
##################################################################
#Customization! Yay!
##################################################################

  #Disables (hides) the name/time window.
  #No point in this script if both are true...
  #True and False, default is both false.
  DISABLE_NAME = false
  DISABLE_TIME = false
  
  #Sets where to draw the window(s)
  #Either under the command menu, or over the gold hud
  #True = Under the command
  #False = Over Gold
  #Default false
  UNDER_COMMAND = false
  
  #Chooses whether or not an icon will be drawn in the windows.
  DRAW_ICON = true
  
  #Chooses whether or not to replace the gold window with a
  #new icon-gold window. This is seperate to extend compatibility.
  #Like Spike's Monentary System
  DRAW_GICON = true
  
  #The index of the icon. 
  #Def NAME = 131 TIME = 280 GOLE = 361
  NAME_ICON = 231
  TIME_ICON = 280
  GOLD_ICON = 361
  
  
#########################################################################
#End Of configuration. Touch anything below and it'll delete system32   #
#########################################################################
end

class Window_MenuMapName < Window_Base
  def initialize
    super(0,100,160,50)
    if VENTWIG::DRAW_ICON == true
      draw_text(30,0,120,25,$game_map.display_name)
      draw_icon(VENTWIG::NAME_ICON,0,0,enabled = true)
    else
      draw_text(0,0,160,25,$game_map.display_name)
    end
  end
end

class Window_MenuPlaytime < Window_Base
  def initialize
    super(0,100,160,50)
    if VENTWIG::DRAW_ICON == true
      draw_text(30,0,160,25,$game_system.playtime_s)
      draw_icon(VENTWIG::TIME_ICON,0,0,enabled = true)
    else
      draw_text(0,0,160,25,$game_system.playtime_s)
    end
  end
  def update
    contents.clear
    if VENTWIG::DRAW_ICON == true
      draw_text(30,0,160,25,$game_system.playtime_s)
      draw_icon(VENTWIG::TIME_ICON,0,0,enabled = true)
    else
      draw_text(0,0,160,25,$game_system.playtime_s)
    end
  end
end

class Scene_Menu < Scene_MenuBase
  alias ventwig_map_name_menu_start start
  def start
    ventwig_map_name_menu_start
    if VENTWIG::DISABLE_NAME == false
      create_map_name_window
    end
    if VENTWIG::DISABLE_TIME == false
      create_playtime_window
    end
  end
  def create_map_name_window
    if VENTWIG::UNDER_COMMAND == true
      @namemap_window = Window_MenuMapName.new
      @namemap_window.x = 0
      @namemap_window.y = @command_window.height
      @namemap_window.width = @command_window.width
      @namemap_window.height = 50
    end
    if VENTWIG::UNDER_COMMAND == false
      if VENTWIG::DISABLE_TIME == false
        @namemap_window = Window_MenuMapName.new
        @namemap_window.x = 0
        @namemap_window.y = @gold_window.y - 100
        @namemap_window.width = @command_window.width
        @namemap_window.height = 50
      end
      if VENTWIG::DISABLE_TIME == true
        @namemap_window = Window_MenuMapName.new
        @namemap_window.x = 0
        @namemap_window.y = @gold_window.y - 50
        @namemap_window.width = @command_window.width
        @namemap_window.height = 50
      end
    end
  end
  def create_playtime_window
    if VENTWIG::UNDER_COMMAND == true
      if VENTWIG::DISABLE_NAME == false
        @playtime_window = Window_MenuPlaytime.new
        @playtime_window.x = 0
        @playtime_window.y = @namemap_window.y + @namemap_window.height
        @playtime_window.width = @command_window.width
        @playtime_window.height = 50
      end
      if VENTWIG::DISABLE_NAME == true
        @playtime_window = Window_MenuPlaytime.new
        @playtime_window.x = 0
        @playtime_window.y = @command_window.height
        @playtime_window.width = @command_window.width
        @playtime_window.height = 50
      end
    end
    if VENTWIG::UNDER_COMMAND == false
      if VENTWIG::DISABLE_NAME == false
        @playtime_window = Window_MenuPlaytime.new
        @playtime_window.x = 0
        @playtime_window.y = @namemap_window.y + @namemap_window.height
        @playtime_window.width = @command_window.width
        @playtime_window.height = 50
      end
      if VENTWIG::DISABLE_NAME == true
        @playtime_window = Window_MenuPlaytime.new
        @playtime_window.x = 0
        @playtime_window.y = @gold_window.y - 50
        @playtime_window.width = @command_window.width
        @playtime_window.height = 50
      end
    end
  end
end

if VENTWIG::DRAW_GICON == true
  class Window_Gold < Window_Base
    alias ventwig_window_gold_icon_show_update refresh
    def refresh
      ventwig_window_gold_icon_show_update
      contents.clear
      draw_icon(VENTWIG::GOLD_ICON,0,0)
      draw_text(self.width - 25 - 10 *value.to_s.size, 0, contents.width - 8, self.height / 2, value)
    end
  end
end