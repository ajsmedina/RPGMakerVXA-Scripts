#============================================================================
#VTS-Equippable Skill Seals
#By Ventwig
#Version 1 - Jun 21 2014
#For RPGMaker VX Ace
#=============================================================================
# Description:
# Equipping "seals" to actors allows them to learn new skills based on their
# level. One primary seal and two secondary seals may be equipped. 
# Different combinations of primary-secondary seals will teach different skills.
# Actors can equip the same seals, and skills will be removed after unequipping
# its respective seal. Switches are used to lock/unlock seals.
#===============================================================================
# Instructions: Put in materials, above main. 
# Requires set-up to make seals teach skills
# "Seal Skills" must all go under their own unique "skill type"
# New skill types can be added under "Terms" in the database, and a skill
# may be assigned a new skill type on its own database page.
#==============================================================================
# Please give Credit to Ventwig if you would like to use one of my scripts!
# Use it commericial or non-commercial, and feel free to tell me if you're using
# it commercially!
# You may edit my scripts, just don't claim as your own!
#===============================================================================
#Customization Below!
#===============================================================================
module SEALS #Do not Touch
  
  #Seal Creation
  #[Seal Name, Switch to Unlock, Help Text]
  #Keep the "LIST[x] =" part in ascending order, and add more lines as needed
  #The x in LIST[x] refers to the "seal id"
  #Seal Name and Help Text in quotations
  LIST = [] #Do not touch
  LIST[0] = ["-Empty-",0,"No Seal Equipped."]
  LIST[1] = ["Alpha",1,"Teaches various Slash Skills."]
  LIST[2] = ["Beta",2,"The seal of fire."]
  LIST[3] = ["Phi",3,"Contains the secrets of healing arts."]
  LIST[4] = ["Tau",4,"Provides mana boosts."]
  
  #The Name of the menu command to call the seal window. In quotations.
  #(Def: "Seal")
  MENU_COMMAND = "Seal"
  
  #The skill type of all seal skills (its database ID)
  #This is necessary for displaying all seal skills in the seal window
  #(Def: 3)
  SKILL_TYPE = 3
  
  #The Command to remove a currently equipped skill. In quotations.
  #(Def: "Remove")
  COMMAND_REMOVE = "Remove"
  #The help text for the above command. In quotations
  #(Def: "Unequip Seal")
  REMOVE_TEXT = "Unequip Seal"
  #The symbol before a seal name in the slot selection screen to specify
  #the slot is a secondary slot. Can leave blank, if desire. In quotations.
  #(Def: "-> ")
  INDENT = "-> "
  
  #GO TO LINE 267 TO ASSIGN SKILLS TAUGHT FROM SEALS
  #The actual line number varies based on how many different
  #seals you added
end

class Game_Actor < Game_Battler
  attr_accessor :seal_primary
  attr_accessor :seal_secondary
  attr_accessor :seal_secondary2
  
  alias seal_actor_initialize initialize
  def initialize(actor_id)
    seal_actor_initialize(actor_id) 
    @seal_primary = 0
    @seal_secondary = 0
    @seal_secondary2 = 0
  end
end

class Window_SealActor < Window_Base
  def initialize(actor)
    @actor=actor
    super(0,0,224,160)
    create_actor_info
  end
  def create_actor_info
    draw_actor_name(@actor,0,0)
    draw_actor_level(@actor,100,0)
    draw_actor_face(@actor,0,30, enabled = true)
  end
  def refresh
    contents.clear
    create_actor_info
  end
end

class Window_SealInfo < Window_Base
  def initialize
    super(224,0,320,60)
    @text = ""
    seal_words
  end
  def seal_words
    draw_text(0,0,300,40,@text)
  end
  def refresh
    contents.clear
    seal_words
  end
  def change_text(text)
    @text = text
  end
end

class Window_SealCommand < Window_Command
  def initialize(actor)
    @actor = actor
    super(224,60)
    self.height = 100
  end
  def col_max
    return 1
  end
  def make_command_list
    add_command(SEALS::LIST[@actor.seal_primary][0],   :primary)
    add_command(SEALS::INDENT + SEALS::LIST[@actor.seal_secondary][0], :secondary)
    add_command(SEALS::INDENT + SEALS::LIST[@actor.seal_secondary2][0], :secondary2)
  end
end

class Window_SealEquip < Window_Command
  def initialize
    super(384,60)
    self.height = 100
  end
  def col_max
    return 1
  end
  def make_command_list
    add_command(SEALS::COMMAND_REMOVE, :remove)
    for i in 1..SEALS::LIST.size-1
      add_command(SEALS::LIST[i][0],    SEALS::LIST[i][0].to_sym)   if $game_switches[SEALS::LIST[i][1]]
    end
  end
end


class Window_SealSkillList < Window_SkillList
  def col_max
    return 3
  end
  
  def enable?(item)
    return true
  end
  
  def draw_skill_cost(rect, skill)
  end
  def update_help
  end
end


class Window_MenuCommand < Window_Command
  alias seal_make_command_list make_command_list
  def make_command_list
    seal_make_command_list
    add_seal_command
  end
  def add_seal_command
    add_command(SEALS::MENU_COMMAND, :seals)
  end
end
  
class Scene_Menu < Scene_MenuBase
  alias seal_command_window create_command_window
  def create_command_window
    seal_command_window
    @command_window.set_handler(:seals,    method(:command_personal))
  end
  def command_seals
    SceneManager.call(Scene_Seals)
  end
  alias seal_on_personal_ok on_personal_ok
  def on_personal_ok
    seal_on_personal_ok
    case @command_window.current_symbol
    when :seals
      SceneManager.call(Scene_Seals)
    end
  end
end

class Scene_Seals < Scene_MenuBase
  def start
    super
    create_windows
    create_seal_window
    create_equip_window
    activate_seal_window
  end
  def create_windows
    @actor_window = Window_SealActor.new(@actor)
    @info_window = Window_SealInfo.new
    @skill_window = Window_SealSkillList.new(0,160,544,256)
    @skill_window.stype_id = SEALS::SKILL_TYPE
    @skill_window.actor = @actor
  end
  def create_seal_window
    @seal_window = Window_SealCommand.new(@actor)
    @seal_window.set_handler(:primary,    method(:command_change))
    @seal_window.set_handler(:secondary, method(:command_change))
    @seal_window.set_handler(:secondary2,    method(:command_change))
  end
  def create_equip_window
    @equip_window = Window_SealEquip.new
    @equip_window.set_handler(:remove,    method(:command_change2))
    for i in 1..SEALS::LIST.size-1
      @equip_window.set_handler(SEALS::LIST[i][0].to_sym, method(:command_change2))
    end
    activate_seal_window
  end
  def destroy_windows
    @actor_window.dispose
    @info_window.dispose
    @skill_window.dispose
    @seal_window.dispose
    @equip_window.dispose
  end
  def command_change
    case @seal_window.current_symbol
    when :primary
      @change = 1
    when :secondary
      @change = 2
    when :secondary2
      @change = 3
    end
    activate_equip_window
  end
  def command_change2
    for i in 1..SEALS::LIST.size-1
      case @equip_window.current_symbol
        when SEALS::LIST[i][0].to_sym
          @change2 = i
      end
    end
    
    case @equip_window.current_symbol
      when :remove
        @change2 = 0
    end
    change_seal
  end
  def change_seal
    @actor.seal_primary = @change2       if @change == 1
    @actor.seal_secondary = @change2     if @change == 2
    @actor.seal_secondary2 = @change2    if @change == 3
    puts @change2
    change_skills
    @seal_window.refresh
    @skill_window.refresh
    activate_seal_window
  end
  def change_skills
    #==========================================================================
    #ASSIGN SKILLS HERE!
    #==========================================================================
    #MAIN SKILLS
    #Skills Taught by equipping one seal anywhere
    #skill_main(skill id, minimum level, seal id)
    #============
    skill_main(5,1,1)
    skill_main(13,1,2)
    skill_main(10,1,3)
    #============
    #COMBINATION SKILLS
    #Skills taught based on the primary seal and one secondary seal
    #skill_comb(skill id, minimum level, seal id, seal id)
    #============
    skill_comb(8,1,1,2)
    skill_comb(9,1,3,2)
  end
  
  def skill_main(skill_id,level,seal_id)
    if @actor.seal_primary == seal_id or @actor.seal_secondary == seal_id or @actor.seal_secondary2 == seal_id
      if @actor.level >= level
        @actor.learn_skill(skill_id)
      else
        @actor.forget_skill(skill_id)
      end
    else
      @actor.forget_skill(skill_id)
    end
  end
  
  def skill_comb(skill_id,level,seal_id,seal_id2)
    if @actor.seal_primary == seal_id 
      if @actor.seal_secondary == seal_id2 or @actor.seal_secondary2 == seal_id2
        if @actor.level >= level
          @actor.learn_skill(skill_id)
        else
          @actor.forget_skill(skill_id)
        end
      else
        @actor.forget_skill(skill_id)
      end
    elsif @actor.seal_secondary == seal_id or @actor.seal_secondary2 == seal_id
      if @actor.seal_primary == seal_id2
        if @actor.level >= level
          @actor.learn_skill(skill_id)
        else
          @actor.forget_skill(skill_id)
        end
      else
        @actor.forget_skill(skill_id)
      end
    else
      @actor.forget_skill(skill_id)
    end
  end
    
  def activate_equip_window
    @seal_window.deactivate
    @equip_window.activate
  end
  def activate_seal_window
    @seal_window.activate
    @equip_window.deactivate
  end
  def change_info_text
    if @seal_window.active == true
        case @seal_window.current_symbol
          when :primary
            i = @actor.seal_primary
            @info_window.change_text(SEALS::LIST[i][2])
          when :secondary
            i = @actor.seal_secondary
            @info_window.change_text(SEALS::LIST[i][2])
          when :secondary2
            i = @actor.seal_secondary2
            @info_window.change_text(SEALS::LIST[i][2])
        end
      @info_window.refresh
    end
    if @equip_window.active == true
      for i in 1..SEALS::LIST.size-1
        case @equip_window.current_symbol
          when SEALS::LIST[i][0].to_sym
            @info_window.change_text(SEALS::LIST[i][2])
        end
      end
      case @equip_window.current_symbol
        when :remove
          @info_window.change_text(SEALS::REMOVE_TEXT)
      end
      @info_window.refresh
    end
  end
  def refresh_all
    destroy_windows
    create_windows
    create_seal_window
    create_equip_window
    activate_seal_window
  end
  def update
    super
    if Input.trigger?(:B)
      SceneManager.return if @seal_window.active
      activate_seal_window if @equip_window.active
    end
    if Input.trigger?(:R)
      next_actor
      refresh_all
    end
    if Input.trigger?(:L)
      prev_actor
      refresh_all
    end
    change_info_text
  end
end