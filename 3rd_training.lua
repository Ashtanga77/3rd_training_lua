-- http://tasvideos.org/EmulatorResources/VBA/LuaScriptingFunctions.html
-- https://github.com/TASVideos/mame-rr/wiki/Lua-scripting-functions

-- input
function make_input_set()
  return {
    up = false,
    down = false,
    left = false,
    right = false,
    LP = false,
    MP = false,
    HP = false,
    LK = false,
    MK = false,
    HK = false,
    start = false,
    coin = false
  }
end

function make_empty_joypad()
  local joy = {}
  joy["P1 Start"] = false
  joy["P1 Coin"] = false
  joy["P1 Up"] = false
  joy["P1 Down"] = false
  joy["P1 Left"] = false
  joy["P1 Right"] = false
  joy["P1 Weak Punch"] = false
  joy["P1 Medium Punch"] = false
  joy["P1 Strong Punch"] = false
  joy["P1 Weak Kick"] = false
  joy["P1 Medium Kick"] = false
  joy["P1 Strong Kick"] = false

  joy["P2 Start"] = false
  joy["P2 Coin"] = false
  joy["P2 Up"] = false
  joy["P2 Down"] = false
  joy["P2 Left"] = false
  joy["P2 Right"] = false
  joy["P2 Weak Punch"] = false
  joy["P2 Medium Punch"] = false
  joy["P2 Strong Punch"] = false
  joy["P2 Weak Kick"] = false
  joy["P2 Medium Kick"] = false
  joy["P2 Strong Kick"] = false

  return joy
end

frame_input = {
  P1 = {
    pressed = make_input_set(),
    released = make_input_set(),
    down = make_input_set()
  },
  P2 = {
    pressed = make_input_set(),
    released = make_input_set(),
    down = make_input_set()
  }
}

function update_input()
  local local_input = joypad.get()
  local P1 = {
    start = local_input["P1 Start"],
    coin = local_input["P1 Coin"],
    up = local_input["P1 Up"],
    down = local_input["P1 Down"],
    left = local_input["P1 Left"],
    right = local_input["P1 Right"],
    LP = local_input["P1 Weak Punch"],
    MP = local_input["P1 Medium Punch"],
    HP = local_input["P1 Strong Punch"],
    LK = local_input["P1 Weak Kick"],
    MK = local_input["P1 Medium Kick"],
    HK = local_input["P1 Strong Kick"]
  }
  local P2 = {
    start = local_input["P2 Start"],
    coin = local_input["P2 Coin"],
    up = local_input["P2 Up"],
    down = local_input["P2 Down"],
    left = local_input["P2 Left"],
    right = local_input["P2 Right"],
    LP = local_input["P2 Weak Punch"],
    MP = local_input["P2 Medium Punch"],
    HP = local_input["P2 Strong Punch"],
    LK = local_input["P2 Weak Kick"],
    MK = local_input["P2 Medium Kick"],
    HK = local_input["P2 Strong Kick"]
  }
  function update_player_input(_player, _input_name, _input)
    _player.pressed[_input_name] = false
    _player.released[_input_name] = false
    if _player.down[_input_name] == false and _input then _player.pressed[_input_name] = true end
    if _player.down[_input_name] == true and _input == false then _player.released[_input_name] = true end
    _player.down[_input_name] = _input
  end

  update_player_input(frame_input.P1, "start", P1.start)
  update_player_input(frame_input.P1, "coin", P1.coin)
  update_player_input(frame_input.P1, "up", P1.up)
  update_player_input(frame_input.P1, "down", P1.down)
  update_player_input(frame_input.P1, "left", P1.left)
  update_player_input(frame_input.P1, "right", P1.right)
  update_player_input(frame_input.P1, "LP", P1.LP)
  update_player_input(frame_input.P1, "MP", P1.MP)
  update_player_input(frame_input.P1, "HP", P1.HP)
  update_player_input(frame_input.P1, "LK", P1.LK)
  update_player_input(frame_input.P1, "MK", P1.MK)
  update_player_input(frame_input.P1, "HK", P1.HK)

  update_player_input(frame_input.P2, "start", P2.start)
  update_player_input(frame_input.P2, "coin", P2.coin)
  update_player_input(frame_input.P2, "up", P2.up)
  update_player_input(frame_input.P2, "down", P2.down)
  update_player_input(frame_input.P2, "left", P2.left)
  update_player_input(frame_input.P2, "right", P2.right)
  update_player_input(frame_input.P2, "LP", P2.LP)
  update_player_input(frame_input.P2, "MP", P2.MP)
  update_player_input(frame_input.P2, "HP", P2.HP)
  update_player_input(frame_input.P2, "LK", P2.LK)
  update_player_input(frame_input.P2, "MK", P2.MK)
  update_player_input(frame_input.P2, "HK", P2.HK)
end

function queue_input_sequence(_player, _sequence)
  if #_sequence == 0 then
    return
  end

  if pending_input_sequence ~= nil then
    return
  end

  local seq = {}
  seq.player = _player
  seq.sequence = copytable(_sequence)
  seq.current_frame = 1

  pending_input_sequence = seq
end

function process_pending_input_sequence()
  if pending_input_sequence == nil then
    return
  end

  local prefix = ""
  local player_data = nil
  if pending_input_sequence.player == 1 then
    prefix = "P1 "
    player_data = P1
  elseif pending_input_sequence.player == 2 then
    prefix = "P2 "
    player_data = P2
  end

  -- Charge moves memory locations
  -- P1
  -- 0x020259D8 H/Urien V/Oro V/Chun H/Q V/Remy
  -- 0x020259F4 (+1C) V/Urien H/Q H/Remy
  -- 0x02025A10 (+38) H/Oro H/Remy
  -- 0x02025A2C (+54) V/Urien V/Alex
  -- 0x02025A48 (+70) H/Alex

  -- P2
  -- 0x02025FF8
  -- 0x02026014
  -- 0x02026030
  -- 0x0202604C
  -- 0x02026068

  local charge_gauges = { { 0x020259D8, 0x020259F4, 0x02025A10, 0x02025A2C, 0x02025A48 }, { 0x02025FF8, 0x02026014, 0x02026030, 0x0202604C, 0x02026068 } }
  local character = player_data.character

  local s = ""
  local input = {}
  local current_frame_input = pending_input_sequence.sequence[pending_input_sequence.current_frame]
  for i = 1, #current_frame_input do
    local input_name = ""..prefix
    if current_frame_input[i] == "forward" then
      if player_data.facing_right then input_name = input_name.."Right" else input_name = input_name.."Left" end
    elseif current_frame_input[i] == "back" then
      if player_data.facing_right then input_name = input_name.."Left" else input_name = input_name.."Right" end
    elseif current_frame_input[i] == "up" then
      input_name = input_name.."Up"
    elseif current_frame_input[i] == "down" then
      input_name = input_name.."Down"
    elseif current_frame_input[i] == "LP" then
      input_name = input_name.."Weak Punch"
    elseif current_frame_input[i] == "MP" then
      input_name = input_name.."Medium Punch"
    elseif current_frame_input[i] == "HP" then
      input_name = input_name.."Strong Punch"
    elseif current_frame_input[i] == "LK" then
      input_name = input_name.."Weak Kick"
    elseif current_frame_input[i] == "MK" then
      input_name = input_name.."Medium Kick"
    elseif current_frame_input[i] == "HK" then
      input_name = input_name.."Strong Kick"
    elseif current_frame_input[i] == "h_charge" then
      if characters[player_data.character] == "urien" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][1], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][1]+1, 0xFF)
      elseif characters[player_data.character] == "oro" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][3], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][3]+1, 0xFF)
      elseif characters[player_data.character] == "chunli" then
      elseif characters[player_data.character] == "q" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][1], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][1]+1, 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][2], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][2]+1, 0xFF)
      elseif characters[player_data.character] == "remy" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][2], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][2]+1, 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][3], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][3]+1, 0xFF)
      elseif characters[player_data.character] == "alex" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][5], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][5]+1, 0xFF)
      end
    elseif current_frame_input[i] == "v_charge" then
      if characters[player_data.character] == "urien" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][2], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][2]+1, 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][4], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][4]+1, 0xFF)
      elseif characters[player_data.character] == "oro" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][1], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][1]+1, 0xFF)
      elseif characters[player_data.character] == "chunli" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][1], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][1]+1, 0xFF)
      elseif characters[player_data.character] == "q" then
      elseif characters[player_data.character] == "remy" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][1], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][1]+1, 0xFF)
      elseif characters[player_data.character] == "alex" then
        memory.writebyte(charge_gauges[pending_input_sequence.player][4], 0xFF)
        memory.writebyte(charge_gauges[pending_input_sequence.player][4]+1, 0xFF)
      end
    end
    input[input_name] = true
    s = s..input_name
  end
  joypad.set(input)

  --print(s)

  pending_input_sequence.current_frame = pending_input_sequence.current_frame + 1
  if pending_input_sequence.current_frame > #pending_input_sequence.sequence then
    pending_input_sequence = nil
  end
end

function clear_input_sequence()
  pending_input_sequence = nil
end

-- training settings
pose = {
  "normal",
  "crouching",
  "jumping",
  "highjumping",
}

stick_gesture = {
  "none",
  "forward",
  "back",
  "down",
  "up",
  "QCF",
  "QCB",
  "HCF",
  "HCB",
  "DPF",
  "DPB",
  "HCharge",
  "VCharge",
  "360",
  "DQCF",
  "720",
  "back dash",
  "forward dash",
  "Shun Goku Ratsu", -- Gouki hidden SA1
  "Kongou Kokuretsu Zan", -- Gouki hidden SA2
}

button_gesture =
{
  "none",
  "LP",
  "MP",
  "HP",
  "EXP",
  "LK",
  "MK",
  "HK",
  "EXK",
  "LP+LK",
  "MP+MK",
  "HP+HK",
}

function make_input_sequence(_stick, _button)
  local sequence = {}
  if      _stick == "none"    then sequence = { { } }
  elseif  _stick == "forward" then sequence = { { "forward" } }
  elseif  _stick == "back"    then sequence = { { "back" } }
  elseif  _stick == "down"    then sequence = { { "down" } }
  elseif  _stick == "up"      then sequence = { { "up" } }
  elseif  _stick == "QCF"     then sequence = { { "down" }, {"down", "forward"}, {"forward"} }
  elseif  _stick == "QCB"     then sequence = { { "down" }, {"down", "back"}, {"back"} }
  elseif  _stick == "HCF"     then sequence = { { "back" }, {"down", "back"}, {"down"}, {"down", "forward"}, {"forward"} }
  elseif  _stick == "HCB"     then sequence = { { "forward" }, {"down", "forward"}, {"down"}, {"down", "back"}, {"back"} }
  elseif  _stick == "DPF"     then sequence = { { "forward" }, {"down"}, {"down", "forward"} }
  elseif  _stick == "DPB"     then sequence = { { "back" }, {"down"}, {"down", "back"} }
  elseif  _stick == "HCharge" then sequence = { { "back", "h_charge" }, {"forward"} }
  elseif  _stick == "VCharge" then sequence = { { "down", "v_charge" }, {"up"} }
  elseif  _stick == "360"     then sequence = { { "forward" }, { "forward", "down" }, {"down"}, { "back", "down" }, { "back" }, { "up" } }
  elseif  _stick == "DQCF"    then sequence = { { "down" }, {"down", "forward"}, {"forward"}, { "down" }, {"down", "forward"}, {"forward"} }
  elseif  _stick == "720"     then sequence = { { "forward" }, { "forward", "down" }, {"down"}, { "back", "down" }, { "back" }, { "up" }, { "forward" }, { "forward", "down" }, {"down"}, { "back", "down" }, { "back" } }
  -- full moves special cases
  elseif  _stick == "back dash" then sequence = { { "back" }, {}, { "back" } }
    return sequence
  elseif  _stick == "forward dash" then sequence = { { "forward" }, {}, { "forward" } }
    return sequence
  elseif  _stick == "Shun Goku Ratsu" then sequence = { { "LP" }, {}, {}, { "LP" }, { "forward" }, {"LK"}, {}, { "HP" } }
    return sequence
  elseif  _stick == "Kongou Kokuretsu Zan" then sequence = { { "down" }, {}, { "down" }, {}, { "down", "LP", "MP", "HP" } }
    return sequence
  end

  if     _button == "none" then
  elseif _button == "EXP"  then
    table.insert(sequence[#sequence], "MP")
    table.insert(sequence[#sequence], "HP")
  elseif _button == "EXK"  then
    table.insert(sequence[#sequence], "MK")
    table.insert(sequence[#sequence], "HK")
  elseif _button == "LP+LK" then
    table.insert(sequence[#sequence], "LP")
    table.insert(sequence[#sequence], "LK")
  elseif _button == "MP+MK" then
    table.insert(sequence[#sequence], "MP")
    table.insert(sequence[#sequence], "MK")
  elseif _button == "HP+HK" then
    table.insert(sequence[#sequence], "HP")
    table.insert(sequence[#sequence], "HK")
  else
    table.insert(sequence[#sequence], _button)
  end

  return sequence
end

characters =
{
  "alex",
  "ryu",
  "yun",
  "dudley",
  "necro",
  "hugo",
  "ibuki",
  "elena",
  "oro",
  "yang",
  "ken",
  "sean",
  "urien",
  "gouki",
  "gill",
  "chunli",
  "makoto",
  "q",
  "twelve",
  "remy"
}

fast_recovery_mode =
{
  "never",
  "always",
}

blocking_style =
{
  "block",
  "parry",
  "red parry",
}

blocking_mode =
{
  "never",
  "always",
}


hit_type =
{
  "normal",
  "low",
  "overhead",
}

standing_state =
{
  "knockeddown",
  "standing",
  "crouched",
  "airborne",
}

-- menu
text_default_color = 0xF7FFF7FF
text_default_border_color = 0x101008FF
text_selected_color = 0xFF0000FF
text_disabled_color = 0x999999FF

function checkbox_menu_item(_name, _property_name, _default_value)
  if _default_value == nil then _default_value = false end
  local o = {}
  o.name = _name
  o.property_name = _property_name
  o.default_value = _default_value

  function o:draw(_x, _y, _selected)
    local c = text_default_color
    local prefix = ""
    local suffix = ""
    if _selected then
      c = text_selected_color
      prefix = "< "
      suffix = " >"
    end
    gui.text(_x, _y, prefix..self.name.." : "..tostring(training_settings[self.property_name])..suffix, c, text_default_border_color)
  end

  function o:left()
    training_settings[self.property_name] = not training_settings[self.property_name]
  end

  function o:right()
    training_settings[self.property_name] = not training_settings[self.property_name]
  end

  function o:cancel()
    training_settings[self.property_name] = self.default_value
  end

  return o
end

function list_menu_item(_name, _property_name, _list, _default_value)
  if _default_value == nil then _default_value = 1 end
  local o = {}
  o.name = _name
  o.property_name = _property_name
  o.list = _list
  o.default_value = _default_value

  function o:draw(_x, _y, _selected)
    local c = text_default_color
    local prefix = ""
    local suffix = ""
    if _selected then
      c = text_selected_color
      prefix = "< "
      suffix = " >"
    end
    gui.text(_x, _y, prefix..self.name.." : "..tostring(self.list[training_settings[self.property_name]])..suffix, c, text_default_border_color)
  end

  function o:left()
    training_settings[self.property_name] = training_settings[self.property_name] - 1
    if training_settings[self.property_name] == 0 then
      training_settings[self.property_name] = #self.list
    end
  end

  function o:right()
    training_settings[self.property_name] = training_settings[self.property_name] + 1
    if training_settings[self.property_name] > #self.list then
      training_settings[self.property_name] = 1
    end
  end

  function o:cancel()
    training_settings[self.property_name] = self.default_value
  end

  return o
end

function integer_menu_item(_name, _property_name, _min, _max, _loop, _default_value)
  if _default_value == nil then _default_value = _min end
  local o = {}
  o.name = _name
  o.property_name = _property_name
  o.min = _min
  o.max = _max
  o.loop = _loop
  o.default_value = _default_value

  function o:draw(_x, _y, _selected)
    local c = text_default_color
    local prefix = ""
    local suffix = ""
    if _selected then
      c = text_selected_color
      prefix = "< "
      suffix = " >"
    end
    gui.text(_x, _y, prefix..self.name.." : "..tostring(training_settings[self.property_name])..suffix, c, text_default_border_color)
  end

  function o:left()
    training_settings[self.property_name] = training_settings[self.property_name] - 1
    if training_settings[self.property_name] < self.min then
      if self.loop then
        training_settings[self.property_name] = self.max
      else
        training_settings[self.property_name] = self.min
      end
    end
  end

  function o:right()
    training_settings[self.property_name] = training_settings[self.property_name] + 1
    if training_settings[self.property_name] > self.max then
      if self.loop then
        training_settings[self.property_name] = self.min
      else
        training_settings[self.property_name] = self.max
      end
    end
  end

  function o:cancel()
    training_settings[self.property_name] = self.default_value
  end

  return o
end

training_settings = {
  swap_characters = false,
  pose = 1,
  blocking_style = 1,
  blocking_mode = 1,
  red_parry_hit_count = 1,
  counter_attack_stick = 1,
  counter_attack_button = 1,
  fast_recovery_mode = 1,
  infinite_time = true,
  infinite_life = true,
  infinite_meter = true,
  no_stun = true,
  display_input = true,
  display_debug_history = false,
}

menu = {
  {
    name = "Dummy Settings",
    entries = {
      list_menu_item("Pose", "pose", pose),
      list_menu_item("Blocking Style", "blocking_style", blocking_style),
      list_menu_item("Blocking", "blocking_mode", blocking_mode),
      integer_menu_item("Hits before Red Parry", "red_parry_hit_count", 1, 20, true),
      list_menu_item("Counter-Attack Move", "counter_attack_stick", stick_gesture),
      list_menu_item("Counter-Attack Button", "counter_attack_button", button_gesture),
      list_menu_item("Fast Recovery", "fast_recovery_mode", fast_recovery_mode),
    }
  },
  {
    name = "Training Settings",
    entries = {
      checkbox_menu_item("Infinite Time", "infinite_time"),
      checkbox_menu_item("Infinite Life", "infinite_life"),
      checkbox_menu_item("Infinite Meter", "infinite_meter"),
      checkbox_menu_item("No Stun", "no_stun"),
      checkbox_menu_item("Display Input", "display_input"),
    }
  },
  {
    name = "Debug Settings",
    entries = {
      checkbox_menu_item("Moves History", "display_debug_history"),
      checkbox_menu_item("Swap Characters", "swap_characters"),
    }
  },
}

-- save/load
training_data_file = "3rd_training_data.txt"
function save_training_data()
  f = io.open(training_data_file, "w")
  for key, value in pairs(training_settings) do
    f:write(key.."="..tostring(value).."\n")
  end
  f:close()
end

function load_training_data()
  f = io.open(training_data_file, "r")
  if f == nil then
    return
  end

  for line in f:lines() do
    local a1 = line:split("=")
    local key = nil
    local value = nil
    if #a1 > 0 then
      key = a1[1]
      value = a1[2]
    end

    if key ~= nil and value ~= nil then
      local type = type(training_settings[key])
      local v = nil
      if type == "boolean" then
        if value == "true" then v = true else v = false end
      elseif type == "number" then
        v = tonumber(value)
      end

      if v ~= nil then
        training_settings[key] = v
      end
    end
  end
  f:close()
end

-- swap inputs
function swap_inputs(_in_input_table, _out_input_table)
  function swap(_input)
    local carry = _in_input_table["P1 ".._input]
    _out_input_table["P1 ".._input] = nil

    --_out_input_table["P1 ".._input] = _in_input_table["P2 ".._input]
    _out_input_table["P2 ".._input] = carry
  end

  swap("Up")
  swap("Down")
  swap("Left")
  swap("Right")
  swap("Weak Punch")
  swap("Medium Punch")
  swap("Strong Punch")
  swap("Weak Kick")
  swap("Medium Kick")
  swap("Strong Kick")
end

-- game data
frame_number = 0
pending_input_sequence = nil
counterattack_sequence = nil
is_in_match = false
knockeddown = false
flying_after_knockdown = false
onground_after_knockdown = false
fastrecovery_countdown = -1

function make_player()
  return {
    character = -1,
    facing_right = false,
    is_attacking = false,
    is_attacking_ext = false, -- for target combos
    input_capacity = 0,
    standing_state = 1,
    pos_x = 0,
    pos_y = 0,
    action = 0,
    action_ext = 0,
    action_count = 0,
    hit_count = 0,
    block_count = 0,
    animation = 0,
    is_blocking = false,
    remaining_freeze_frames = 0,
  }
end
P1 = make_player()
P2 = make_player()

-- debug history

debug_history = {}
debug_history_max = 10

function debug_find_or_add_animation(_animation_id)
  local _a = nil
  for i = 1, #debug_history do
    if debug_history[i].id == _animation_id then
      _a = debug_history[i]
      -- move animation back up the list
      table.remove(debug_history, i)
      table.insert(debug_history, 1, _a)
      break
    end
  end
  if _a == nil then
    _a = {
      id = _animation_id,
    }
    table.insert(debug_history, 1, _a)
    if #debug_history > debug_history_max then
      table.remove(debug_history, debug_history_max)
    end
  end
  return _a
end

function debug_animation_begin(_animation_id)
  local _a = debug_find_or_add_animation(_animation_id)
  _a.current_frame_begin = frame_number
  _a.current_frame_end = nil
  _a.current_freezes = {}
  _a.current_act_begin = nil
  _a.current_acts = {}

  --print(frame_number.." - ".._animation_id.." - begin")
end
function debug_act(_animation_id)
  local _a = debug_find_or_add_animation(_animation_id)

  if _a.current_act_begin then
    debug_active_end(_animation_id)
  end
  _a.current_act_begin = frame_number
  _a.current_act_distance = { x = 0, y = -1000 }

  --print(frame_number.." - ".._animation_id.." - act")
end
function debug_hit(_animation_id, _dist_x, _dist_y)
  local _a = debug_find_or_add_animation(_animation_id)
  _a.current_act_distance = { x = _dist_x, y = _dist_y }

  --print(frame_number.." - ".._animation_id.." - hit ".._dist_x.." ".._dist_y)
end
function debug_freeze(_animation_id, _freeze_length)
  local _a = debug_find_or_add_animation(_animation_id)
  table.insert(_a.current_freezes, { frame = frame_number, length = _freeze_length })

  --print(frame_number.." - ".._animation_id.." - freeze ".._freeze_length)
end
function debug_active_end(_animation_id)
  local _a = debug_find_or_add_animation(_animation_id)
  if _a.current_act_begin and _a.current_acts then
    table.insert(_a.current_acts, { frame = _a.current_act_begin, length = frame_number - _a.current_act_begin })
    _a.current_act_begin = nil
  end
  --print(frame_number.." - ".._animation_id.." - active_end")
end
function debug_animation_end(_animation_id)
  local _a = debug_find_or_add_animation(_animation_id)
  _a.current_frame_end = frame_number

  if _a.current_act_begin then
    debug_active_end(_animation_id)
  end

  _a.length = _a.current_frame_end - _a.current_frame_begin
  for i = 1, #_a.current_freezes do
    _a.length = _a.length - _a.current_freezes[i].length
  end

  if _a.acts == nil then
    _a.acts = {}
  end

  for i = 1, #_a.current_acts do
    local _startup = _a.current_acts[i].frame - _a.current_frame_begin
    local _active = _a.current_acts[i].length
    for j = 1, #_a.current_freezes do
      if _a.current_acts[i].frame > _a.current_freezes[j].frame then _startup = _startup - _a.current_freezes[j].length end
      local _act_end_frame = _a.current_acts[i].frame + _a.current_acts[i].length
      if _act_end_frame > _a.current_freezes[j].frame then _active = _active - _a.current_freezes[j].length end
    end
    local _new_act = { startup = _startup, active = _active, dist_x = _a.current_act_distance.x, dist_y = _a.current_act_distance.y }
    if _a.acts[i] then
      _new_act.dist_x = math.max(_a.acts[i].dist_x, _new_act.dist_x)
      _new_act.dist_y = math.max(_a.acts[i].dist_y, _new_act.dist_y)
    end
    _a.acts[i] = _new_act
  end

  if #_a.acts == 0 then
    table.remove(debug_history, 1)
  end

  --print(frame_number.." - ".._animation_id.." - end")
end

-- program

debug_current_animation = false
debug_state_variables = false

function on_start()
  load_training_data()
end

function before_frame()

  update_input()

  local input = {}

  -- frame number
  frame_number = memory_read(0x02007F00, 4)

  -- is in match
  -- I believe the bytes that are expected to be 0xff means that a character has been locked, while the byte expected to be 0x02 is the current match state. 0x02 means that round has started and players can move
	local p1_locked = memory.readbyte(0x020154C6);
	local p2_locked = memory.readbyte(0x020154C8);
	local match_state = memory.readbyte(0x020154A7);
	is_in_match = ((p1_locked == 0xFF or p2_locked == 0xFF) and match_state == 0x02);

  -- character swap
  if is_in_match then
    local P1_disable_input_address = 0x02068C74
    if training_settings.swap_characters then
      swap_inputs(joypad.get(), input)
      memory.writebyte(P1_disable_input_address, 0x01)
    else
      memory.writebyte(P1_disable_input_address, 0x00)
    end
  end

  -- freeze game
  if is_menu_open then
    memory.writebyte(0x0201136F, 0xFF)
  else
    memory.writebyte(0x0201136F, 0x00)
  end

  -- timer
  if training_settings.infinite_time then
    memory.writebyte(0x02011377, 100)
  end

  -- player data
  P1.character = memory.readbyte(0x02011387)
  P1.facing_right = memory.readbyte(0x02068C77) > 0
  P1.is_attacking = memory.readbyte(0x02069094) > 0
  P1.is_attacking_ext = memory.readbyte(0x02069095) > 0
  P1.input_capacity = memory_read(0x020690D8, 2)
  P1.standing_state = memory.readbyte(0x02068F03)
  P1.pos_x = memory_read(0x02068CD0, 2)
  P1.pos_y = memory_read(0x02068CD4, 2)
  P1.action = memory_read(0x02068D19, 3)
  P1.action_ext = memory_read(0x02068D99, 3)
  P1.action_count = memory.readbyte(0x020690C5)
  P1.connected_action_count = memory.readbyte(0x02068DE7)
  P1.hit_count = memory.readbyte(0x02068DF5)
  P1.animation = bit.tohex(memory_read(0x02068E6E, 2),4)
  P1.remaining_freeze_frames = memory.readbyte(0x02068CB1)


  P2.character = memory.readbyte(0x02011388)
  P2.facing_right = memory.readbyte(0x0206910F) > 0
  P2.pos_x = memory_read(0x02069168, 2)
  P2.pos_y = memory_read(0x0206916C, 2)
  P2.is_blocking = memory.readbyte(0x020694D7) > 0
  P2.action = memory_read(0x020691B1, 3)

  --

  P1_has_just_attacked = P1_previous_is_attacking ~= nil and P1.is_attacking and not P1_previous_is_attacking
  if debug_state_variables and P1_has_just_attacked then print(frame_number.." - attacked") end

  P1_has_just_acted = P1_previous_action_count ~= nil and P1.action_count > P1_previous_action_count
  if debug_state_variables and P1_has_just_acted then print(frame_number.." - acted ("..P1_previous_action_count.." > "..P1.action_count..")") end

  P1_has_just_hit = P1_previous_hit_count ~= nil and P1.hit_count > P1_previous_hit_count
  if debug_state_variables and P1_has_just_hit then print(frame_number.." - hit ("..P1_previous_hit_count.." > "..P1.hit_count..")") end

  local _P1_blocked_count = P1.connected_action_count - P1.hit_count
  P1_has_just_been_blocked = P1_previous_blocked_count ~= nil and _P1_blocked_count > P1_previous_blocked_count
  if debug_state_variables and P1_has_just_been_blocked then print(frame_number.." - blocked ("..P1_previous_blocked_count.." > ".._P1_blocked_count..")") end

  P1_has_just_landed = P1_previous_standing_state ~= nil and P1_previous_standing_state >= 3 and P1.standing_state < 3
  if debug_state_variables and P1_has_just_landed then print(frame_number.." - landed ("..P1_previous_standing_state.." > "..P1.standing_state..")") end

  P1_has_animation_just_changed = P1_previous_animation ~= nil and P1_previous_animation ~= P1.animation
  if debug_state_variables and P1_has_animation_just_changed then print(frame_number.." - animation changed ("..P1_previous_animation.." > "..P1.animation..")") end

  -- debug history
  if P1_has_just_acted then
    debug_act(P1.animation)
  end

  if P1_has_just_hit or P1_has_just_been_blocked then
    local _distance_from_enemy = math.abs(P1.pos_x - P2.pos_x) - character_specific[characters[P1.character]].half_width
    local _vertical_distance_from_enemy = (P1.pos_y - P2.pos_y) - character_specific[characters[P1.character]].height
    debug_hit(P1.animation, _distance_from_enemy, _vertical_distance_from_enemy)
  end

  if P1_previous_is_attacking and not P1.is_attacking then
    debug_active_end(P1.animation)
  end

  -- life bars
  if training_settings.infinite_life then
    memory.writebyte(0x02068d0b, 160) -- p1
    memory.writebyte(0x020691a3, 160) -- p2
  end

  -- meter
  if training_settings.infinite_meter then
    -- 0x020695BF P1 meter count
    -- 0x020695BD P1 max meter count
    memory.writebyte(0x020695BF, memory.readbyte(0x020695BD))
    -- 0x020695EB P2 meter count
    -- 0x020695E9 P2 max meter count
    memory.writebyte(0x020695EB, memory.readbyte(0x020695E9))
  end

  -- stun
  if training_settings.no_stun then
    memory.writebyte(0x020695FD, 0); -- P1 Stun timer
		memory.writebyte(0x02069611, 0); -- P2 Stun timer
    memory.writebyte(0x020695FF, 0); -- p1 stun bar
    memory.writebyte(0x020695FF+1, 0); -- p1 stun bar
    memory.writebyte(0x020695FF+2, 0); -- p1 stun bar
    memory.writebyte(0x020695FF+3, 0); -- p1 stun bar
    memory.writebyte(0x02069613, 0); -- p2 stun bar
    memory.writebyte(0x02069613+1, 0); -- p2 stun bar
    memory.writebyte(0x02069613+2, 0); -- p2 stun bar
    memory.writebyte(0x02069613+3, 0); -- p2 stun bar
  end

  -- pose
  if is_in_match and not training_settings.swap_characters and not knockeddown and pending_input_sequence == nil then
    if training_settings.pose == 2 then
      input['P2 Down'] = true
    elseif training_settings.pose == 3 then
      input['P2 Up'] = true
    elseif training_settings.pose == 4 then
      if (frame_number % 2) == 0 then
        input['P2 Down'] = true
      else
        input['P2 Up'] = true
      end
    end
  end

  --
  function make_animation(_animation_id)

    local _moves = character_specific[characters[P1.character]].moves[_animation_id]

    -- normalize move data
    if _moves == nil then

      local _type = 1
      if P1.standing_state == 1 then -- STANDING
        _type = 1
      elseif P1.standing_state == 2 then --CROUCHED
        _type = 2
      elseif P1.standing_state >= 3 then --AIRBORNE
        _type = 3
      end
      _moves = {
        { startup = 2, active = 101, range = 114, vertical_range = 500, type = _type }
      }
    elseif #_moves == 0 then
      _moves = {_moves}
    end

    -- force default vars
    for i = 1,#_moves do
      if _moves[i].vertical_range == nil then
        _moves[i].vertical_range = 500
      end
    end

    local _animation = {}
    _animation.id = _animation_id
    _animation.moves = _moves
    _animation.start_frame = frame_number
    _animation.freeze_frames = {}
    _animation.current_move = 1

    function _animation.update()

      if _animation.current_move <= #_animation.moves and not _animation.moves[_animation.current_move].no_hit then
        local _freeze_length = 0
        for j = 1, #_animation.freeze_frames do
          _freeze_length = _freeze_length + _animation.freeze_frames[j].length
        end

        local _active_end = _animation.start_frame + _animation.moves[_animation.current_move].startup + _animation.moves[_animation.current_move].active + _freeze_length
        if frame_number > _active_end then
          _animation.current_move = _animation.current_move + 1
        end
      end

      while _animation.current_move <= #_animation.moves and _animation.moves[_animation.current_move].no_hit do
        _animation.current_move = _animation.current_move + 1
      end

      if P1_has_just_acted then
        _animation.current_move = _animation.current_move + 1
      end
    end

    function _animation.get_next_hit(_frame)
      if _frame == nil then _frame = frame_number end

      if #_animation.moves < _animation.current_move then
        return nil
      end

      if #_animation.moves < _animation.current_move then
        return nil
      end

      -- add freeze frames
      local _freeze_length = 0
      for j = 1, #_animation.freeze_frames do
        _freeze_length = _freeze_length + _animation.freeze_frames[j].length
      end

      local _active_begin = _animation.start_frame + _animation.moves[_animation.current_move].startup + _freeze_length
      local _active_end = _active_begin + _animation.moves[_animation.current_move].active

      return {
        start = _active_begin,
        stop = _active_end,
        range = _animation.moves[_animation.current_move].range,
        vertical_range = _animation.moves[_animation.current_move].vertical_range,
        type = _animation.moves[_animation.current_move].type,
      }
    end

    return _animation
  end

  local _debug_blocking = false

  -- current animation
  -- detects some of the self cancelled moves, but can't detect when a single hit move is cancelled during its active frames (i.e. ibuki's forward LK)
  local _self_cancelled = false
  if P1_has_just_attacked and current_animation and current_animation.id == P1.animation then
    local _passed_last_hit = true
    for i=1, #current_animation.moves do
      if current_animation.start_frame + current_animation.moves[i].startup >= frame_number then
        _passed_last_hit = false
      end
    end
    _self_cancelled = _passed_last_hit
  end

  local _is_landing_animation = P1_has_just_landed and character_specific[characters[P1.character]].moves[P1.animation] == nil

  if not _is_landing_animation and (P1_has_just_attacked or (current_animation and P1_has_animation_just_changed) or _self_cancelled) then
    if current_animation == nil or current_animation.id ~= P1.animation or _self_cancelled then
      local _new_animation = make_animation(P1.animation)
      if current_animation then
        for i=1, #current_animation.freeze_frames do
          local _freeze_frame = current_animation.freeze_frames[i]
          local _freeze_frame_stop = _freeze_frame.start + _freeze_frame.length
          if _new_animation.start_frame > _freeze_frame.start and _new_animation.start_frame < _freeze_frame_stop then
            _new_animation.start_frame = _freeze_frame_stop
          end
        end
      end

      if current_animation then debug_animation_end(current_animation.id) end
      current_animation = _new_animation
      if current_animation then debug_animation_begin(current_animation.id) end

      next_hit_frame = current_animation.start_frame
      if _debug_blocking then
        print("animation changed, seeking next hit from frame "..(next_hit_frame - current_animation.start_frame))
        local __next_hit = current_animation.get_next_hit(next_hit_frame)
        if __next_hit then
          print("    next hit at frame "..(__next_hit.start - current_animation.start_frame))
        end
      end
    end
  elseif current_animation
  and (
    (bit.band(P1.input_capacity, 0x0087) == 0x0087 or bit.band(P1.input_capacity, 0x0086) == 0x0086)
    or P1_has_just_landed
  )
  then
    debug_animation_end(current_animation.id)
    current_animation = nil
  end

  -- freeze_frames
  local _freeze_diff = 0
  if P1_previous_remaining_freeze_frames then _freeze_diff = P1.remaining_freeze_frames - P1_previous_remaining_freeze_frames end
  P1_previous_remaining_freeze_frames = P1.remaining_freeze_frames

  -- only add freeze frame diff in case it is increases without having reached zero (not sure it actually happens)
  if current_animation and _freeze_diff > 0 then
    table.insert(current_animation.freeze_frames, { start = frame_number, length = _freeze_diff})
    debug_freeze(current_animation.id, _freeze_diff)
  end

  -- animation update
  if current_animation then
    current_animation.update()
  end

  -- consecutive blocks
  P1_has_just_been_parried = false

  if current_animation and P1_has_just_been_blocked then
    if training_settings.blocking_style == 2 then
      P1_has_just_been_parried = true
    elseif training_settings.blocking_style == 3 and P1_consecutive_blocked == training_settings.red_parry_hit_count then
      P1_has_just_been_parried = true
    end
    P1_consecutive_blocked = P1_consecutive_blocked + 1
  elseif not current_animation then
    P1_consecutive_blocked = 0
  end

  if _debug_blocking then
    if P1_has_just_hit and current_animation then
      print("hit at frame "..frame_number - current_animation.start_frame)
    end
    if P1_has_just_been_parried and current_animation then
      print("parried at frame "..frame_number - current_animation.start_frame)
    elseif P1_has_just_been_blocked and current_animation then
      print("blocked at frame "..frame_number - current_animation.start_frame)
    end
  end

  if is_in_match
  and not training_settings.swap_characters
  and training_settings.blocking_mode ~= 1
  and pending_input_sequence == nil
  and current_animation ~= nil
  then

    if _debug_blocking then
      print ("frame "..(frame_number - current_animation.start_frame))
    end

    -- blocking
    local _next_hit = current_animation.get_next_hit(next_hit_frame)
    if _next_hit then

      local _distance_from_enemy = math.abs(P1.pos_x - P2.pos_x) - character_specific[characters[P1.character]].half_width
      local _vertical_distance_from_enemy = (P1.pos_y - P2.pos_y) - character_specific[characters[P1.character]].height

      local _is_within_range = _distance_from_enemy <= _next_hit.range and _vertical_distance_from_enemy <= _next_hit.vertical_range

      if _is_within_range then
        local _should_block = training_settings.blocking_style == 1 or (training_settings.blocking_style == 3 and training_settings.red_parry_hit_count ~= P1_consecutive_blocked)
        local _should_parry = training_settings.blocking_style == 2 or (training_settings.blocking_style == 3 and training_settings.red_parry_hit_count == P1_consecutive_blocked)

        if (P1_has_just_been_blocked or P1_has_just_hit) then
          next_hit_frame = _next_hit.stop + 1
          if _debug_blocking then
            print("hit connected: seeking next hit from frame "..(next_hit_frame - current_animation.start_frame))
            local __next_hit = current_animation.get_next_hit(next_hit_frame)
            if __next_hit then
              print("    next hit at frame "..(__next_hit.start - current_animation.start_frame))
            end
          end
        elseif frame_number >= _next_hit.stop then
          next_hit_frame = _next_hit.stop + 1
          if _debug_blocking then
            print("hit past active frames: seeking next hit from frame "..(next_hit_frame - current_animation.start_frame))
            local __next_hit = current_animation.get_next_hit(next_hit_frame)
            if __next_hit then
              print("    next hit at frame "..(__next_hit.start - current_animation.start_frame))
            end
          end
        end

        if _should_block then
          if _debug_blocking then
            if (frame_number == (_next_hit.start - 2)) then
              print("start block at frame "..(frame_number - current_animation.start_frame))
            end
          end

          if frame_number >= (_next_hit.start - 2) and frame_number < _next_hit.stop then
            if P2.facing_right then
              input['P2 Left'] = true
              input['P2 Right'] = false
            else
              input['P2 Right'] = true
              input['P2 Left'] = false
            end

            if _next_hit.type == 2 then
              input['P2 Down'] = true
            elseif _next_hit.type == 3 then
              input['P2 Down'] = false
            end
          end
        end

        if _should_parry then
          if _debug_blocking then
            if (frame_number == (_next_hit.start - 3)) then
              print("start parry at frame "..(frame_number - current_animation.start_frame))
            end
          end
          -- completely release crouch when trying to parry
          if frame_number >= (_next_hit.start - 3) and frame_number < _next_hit.stop then
            input['P2 Down'] = false
          end
          if frame_number >= (_next_hit.start - 2) and frame_number < _next_hit.stop then
            if _next_hit.type == 2 then
              input['P2 Down'] = true
            else
              if P2.facing_right then
                input['P2 Right'] = true
                input['P2 Left'] = false
              else
                input['P2 Left'] = true
                input['P2 Right'] = false
              end
            end
          end
        end
      end
    end
  end

  -- fast recovery
  if is_in_match then
    knockeddown = (
      (bit.rshift(P2.action, 16) == 0x06) -- first flag at 0x06 means we are knocked down. Last flag means knock down variants
      or (P2.action == 0x030001) -- throws
    )

    if knockeddown then
      --print(string.format("%X", P2.action).."."..P2.pos_y)
    end

    if knockeddown and (not flying_after_knockdown) and (not onground_after_knockdown) and (P2.pos_y > 0) then
      --print("frutu")
      flying_after_knockdown = true
    end

    if flying_after_knockdown and (not onground_after_knockdown) and (P2.pos_y == 0) then
      -- hugo makes a weird bounce for 1 frame, we wait for the second frame in order to skip that
      if fastrecovery_framesonground == 1 then
        fastrecovery_framesonground = 0
        --print("priti")
        flying_after_knockdown = false
        onground_after_knockdown = true
        fastrecovery_countdown = 0
      else
        fastrecovery_framesonground = fastrecovery_framesonground + 1
      end
    else
      fastrecovery_framesonground = 0
    end

    if fastrecovery_countdown == 0 then
      --print("prout")
      if training_settings.fast_recovery_mode == 2 then
        input['P2 Down'] = true
      end
      fastrecovery_countdown = -1
    else
      fastrecovery_countdown = fastrecovery_countdown - 1
    end

    if (not knockeddown) and onground_after_knockdown then
      --print("prat."..string.format("%X", P2.action))
      onground_after_knockdown = false
    end
  end

  -- counter attack
  if is_in_match and (training_settings.counter_attack_stick ~= 1 or training_settings.counter_attack_button ~= 1) then

    if P1_has_just_been_parried then
      --print(frame_number.." - setup ca")
      counte_attack_frame = frame_number + 16
      counterattack_sequence = make_input_sequence(stick_gesture[training_settings.counter_attack_stick], button_gesture[training_settings.counter_attack_button])
      P2_counter_ref_time = -1
    elseif P1_has_just_hit or P1_has_just_been_blocked then
      --print(frame_number.." - init ca")
      P2_counter_ref_time = memory.readbyte(0x0206928B)
      clear_input_sequence()
      counterattack_sequence = nil
    end

    if not counterattack_sequence then
      local _recovery_time = memory.readbyte(0x0206928B)
      if P2_counter_ref_time ~= -1 and _recovery_time ~= P2_counter_ref_time then
        --print(frame_number.." - setup ca")
        counte_attack_frame = frame_number + _recovery_time + 2
        counterattack_sequence = make_input_sequence(stick_gesture[training_settings.counter_attack_stick], button_gesture[training_settings.counter_attack_button])
        P2_counter_ref_time = -1
      end
    end


    if counterattack_sequence then
      local _frames_remaining = counte_attack_frame - frame_number
      --print(_frames_remaining)
      if _frames_remaining <= (#counterattack_sequence + 1) then
        --print(frame_number.." - queue ca")
        queue_input_sequence(2, counterattack_sequence)
        counterattack_sequence = nil
      end
    end
  end

  joypad.set(input)
  process_pending_input_sequence()

  -- previous frame stuff
  P1_previous_is_attacking = P1.is_attacking
  P1_previous_action_count = P1.action_count
  P1_previous_hit_count = P1.hit_count
  P1_previous_blocked_count = _P1_blocked_count
  P1_previous_standing_state = P1.standing_state
  P1_previous_animation = P1.animation
end

is_menu_open = false
main_menu_selected_index = 1
is_main_menu_selected = true
sub_menu_selected_index = 1

function on_gui()

  if is_in_match and training_settings.display_input then
    local i = joypad.get()
    draw_input(45, 190, i, "P1 ")
    draw_input(280, 190, i, "P2 ")
  end

  if is_in_match and training_settings.display_debug_history then
    local _debug_history_x = 45
    local _debug_history_y = 36
    local _line_height = 10
    for i = 1, #debug_history do
      local _a = debug_history[i]
      local _t = _a.id..": "
      if _a.length then _t = _t.."".._a.length.." " end
      if _a.acts then
        for j = 1, #_a.acts do
          _t = _t.."{".._a.acts[j].startup..",".._a.acts[j].active.." (".._a.acts[j].dist_x..",".._a.acts[j].dist_y..")} "
        end
      end
      gui.text(_debug_history_x, _debug_history_y + (i - 1) * _line_height, _t, text_disabled_color, text_default_border_color);
    end
  end

  if current_animation then
    last_valid_current_animation = current_animation
  end
  if debug_current_animation and last_valid_current_animation then
    local _x = 300
    local _y = 20
    local _line_height = 10
    gui.text(_x + 5 , _y + _line_height * 0 , "animation: "..last_valid_current_animation.id)
    local _freeze_frames = 0
    for i = 1, #last_valid_current_animation.freeze_frames do
      _freeze_frames = _freeze_frames + last_valid_current_animation.freeze_frames[i].length
    end
    gui.text(_x + 5 , _y + _line_height * 1 , "freeze_frames: ".._freeze_frames)

    local _next_hit = last_valid_current_animation.get_next_hit()
    if _next_hit then
      last_valid_next_hit = _next_hit
    end
    if last_valid_next_hit then
      gui.text(_x + 5 , _y + _line_height * 2 , "next_hit: "..(last_valid_next_hit.start - last_valid_current_animation.start_frame)..", "..(last_valid_next_hit.stop - last_valid_current_animation.start_frame))
    end
  end

  if is_in_match then
    if frame_input.P1.pressed.start then
      is_menu_open = (not is_menu_open)
    end
  else
    is_menu_open = false
  end

  if is_menu_open then

    if frame_input.P1.pressed.down then
      if is_main_menu_selected then
        is_main_menu_selected = false
        sub_menu_selected_index = 1
      else
        sub_menu_selected_index = sub_menu_selected_index + 1
        if sub_menu_selected_index > #menu[main_menu_selected_index].entries then
          is_main_menu_selected = true
        end
      end
    end

    if frame_input.P1.pressed.up then
      if is_main_menu_selected then
        is_main_menu_selected = false
        sub_menu_selected_index = #menu[main_menu_selected_index].entries
      else
        sub_menu_selected_index = sub_menu_selected_index - 1
        if sub_menu_selected_index == 0 then
          is_main_menu_selected = true
        end
      end
    end

    if frame_input.P1.pressed.left then
      if is_main_menu_selected then
        main_menu_selected_index = main_menu_selected_index - 1
        if main_menu_selected_index == 0 then
          main_menu_selected_index = #menu
        end
      else
        menu[main_menu_selected_index].entries[sub_menu_selected_index]:left()
        save_training_data()
      end
    end

    if frame_input.P1.pressed.right then
      if is_main_menu_selected then
        main_menu_selected_index = main_menu_selected_index + 1
        if main_menu_selected_index > #menu then
          main_menu_selected_index = 1
        end
      else
        menu[main_menu_selected_index].entries[sub_menu_selected_index]:right()
        save_training_data()
      end
    end

    if frame_input.P1.pressed.LK then
      if is_main_menu_selected then
      else
        menu[main_menu_selected_index].entries[sub_menu_selected_index]:cancel()
        save_training_data()
      end
    end

    -- screen size 383,223
    gui.box(43,40,340,180, 0x293139FF, 0x840000FF)
    --gui.box(0, 0, 383, 17, 0x000000AA, 0x000000AA)

    local _bar_x = 53
    local _bar_y = 46
    for i = 1, #menu do
      local _c = text_disabled_color
      local _t = menu[i].name
      if is_main_menu_selected and i == main_menu_selected_index then
        _t = "< ".._t.." >"
        _c = text_selected_color
      elseif i == main_menu_selected_index then
        _c = text_default_color
      end
      gui.text(_bar_x + (i - 1) * 100, _bar_y, _t, _c, text_default_border_color)
    end


    local _menu_x = 53
    local _menu_y = 63
    local _menu_y_interval = 10
    for i = 1, #menu[main_menu_selected_index].entries do
      menu[main_menu_selected_index].entries[i]:draw(_menu_x, _menu_y + _menu_y_interval * (i - 1), not is_main_menu_selected and sub_menu_selected_index == i)
    end

    gui.text(53, 168, "LK: Reset value to default", text_disabled_color, text_default_border_color)

  else
    gui.box(0,0,0,0,0,0) -- if we don't draw something, what we drawed from last frame won't be cleared
  end
end

-- toolbox
function to_bit(_bool)
  if _bool then
    return 1
  else
    return 0
  end
end

function memory_read(_address, _size, _reverse)
  if _reverse == nil then _reverse = true end
  local result = 0
  for i = 1, _size do
    if _reverse then
      result = result + bit.lshift(memory.readbyte(_address + (i - 1)), (_size - i) * 8)
    else
      result = result + bit.lshift(memory.readbyte(_address + (i - 1)), (i - 1) * 8)
    end
  end
  return result
end

function draw_input(_x, _y, _input, _prefix)
  local up = _input[_prefix.."Up"]
  local down = _input[_prefix.."Down"]
  local left = _input[_prefix.."Left"]
  local right = _input[_prefix.."Right"]
  local LP = _input[_prefix.."Weak Punch"]
  local MP = _input[_prefix.."Medium Punch"]
  local HP = _input[_prefix.."Strong Punch"]
  local LK = _input[_prefix.."Weak Kick"]
  local MK = _input[_prefix.."Medium Kick"]
  local HK = _input[_prefix.."Strong Kick"]
  local start = _input[_prefix.."Start"]
  local coin = _input[_prefix.."Coin"]
  function col(_value)
    if _value then return text_selected_color else return text_default_color end
  end

  gui.text(_x + 5 , _y + 0 , "^", col(up), text_default_border_color)
  gui.text(_x + 5 , _y + 10, "v", col(down), text_default_border_color)
  gui.text(_x + 0 , _y + 5, "<", col(left), text_default_border_color)
  gui.text(_x + 10, _y + 5, ">", col(right), text_default_border_color)

  gui.text(_x + 20, _y + 0, "LP", col(LP), text_default_border_color)
  gui.text(_x + 30, _y + 0, "MP", col(MP), text_default_border_color)
  gui.text(_x + 40, _y + 0, "HP", col(HP), text_default_border_color)
  gui.text(_x + 20, _y + 10, "LK", col(LK), text_default_border_color)
  gui.text(_x + 30, _y + 10, "MK", col(MK), text_default_border_color)
  gui.text(_x + 40, _y + 10, "HK", col(HK), text_default_border_color)

  gui.text(_x + 55, _y + 0, "S", col(start), text_default_border_color)
  gui.text(_x + 55, _y + 10, "C", col(coin), text_default_border_color)
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

-- registers
emu.registerstart(on_start)
emu.registerbefore(before_frame)
gui.register(on_gui)


-- character specific stuff
function make_character_specific()
  return {
    half_width = 40,
    height = 40,
    moves = {},
  }
end

character_specific = {}
for i = 1, #characters do
  character_specific[characters[i]] = make_character_specific()
end

-- Character Dimensions
character_specific.alex.half_width = 45
character_specific.chunli.half_width = 39
character_specific.dudley.half_width = 29
character_specific.elena.half_width = 44
character_specific.gouki.half_width = 33
character_specific.hugo.half_width = 43
character_specific.ibuki.half_width = 34
character_specific.ken.half_width = 30
character_specific.makoto.half_width = 42
character_specific.necro.half_width = 26
character_specific.oro.half_width = 40
character_specific.q.half_width = 25
character_specific.remy.half_width = 32
character_specific.ryu.half_width = 31
character_specific.sean.half_width = 29
character_specific.twelve.half_width = 33
character_specific.urien.half_width = 36
character_specific.yang.half_width = 41
character_specific.yun.half_width = 37

character_specific.alex.height = 104
character_specific.chunli.height = 97
character_specific.dudley.height = 109
character_specific.elena.height = 88
character_specific.gouki.height = 107
character_specific.hugo.height = 137
character_specific.ibuki.height = 92
character_specific.ken.height = 107
character_specific.makoto.height = 90
character_specific.necro.height = 89
character_specific.oro.height = 88
character_specific.q.height = 130
character_specific.remy.height = 114
character_specific.ryu.height = 101
character_specific.sean.height = 103
character_specific.twelve.height = 91
character_specific.urien.height = 121
character_specific.yang.height = 89
character_specific.yun.height = 89


-- Character Moves
debug_framedata = true

-- IBUKI
character_specific.ibuki.moves["f5b0"] = { startup = 2, active = 2, range = 84, type = 1 } -- LP
character_specific.ibuki.moves["f690"] = { startup = 6, active = 2, range = 84, type = 1 } -- MP
character_specific.ibuki.moves["f838"] = { -- back MP
  { startup = 6, active = 1, range = 64, type = 1 },
  { startup = 7, active = 5, range = 64, type = 1 },
}
character_specific.ibuki.moves["3a48"] = { -- target MP
  { startup = 6, active = 1, range = 64, type = 1 },
  { startup = 8, active = 7, range = 64, type = 1 },
}
character_specific.ibuki.moves["fc48"] = { -- HP
  { startup = 13, active = 8, range = 64, type = 1 },
  { startup = 18, active = 3, range = 84, type = 1 },
}
character_specific.ibuki.moves["fa10"] = { -- close HP
  { startup = 9, active = 1, range = 34, type = 1 },
  { startup = 10, active = 6, range = 34, type = 1 },
}
character_specific.ibuki.moves["0018"] = { startup = 4, active = 4, range = 65, type = 1 } -- LK
character_specific.ibuki.moves["01a8"] = { startup = 5, active = 4, range = 90, type = 1 } -- forward LK
character_specific.ibuki.moves["05d0"] = { startup = 5, active = 4, range = 49, type = 1 } -- MK
character_specific.ibuki.moves["36c8"] = { startup = 4, active = 4, range = 49, type = 1 } -- Target MK
character_specific.ibuki.moves["0398"] = { startup = 13, active = 2, range = 105, type = 1 } -- Back MK
character_specific.ibuki.moves["0748"] = { startup = 3, active = 3, range = 74, type = 3 } -- Forward MK
character_specific.ibuki.moves["30a0"] = { startup = 27, active = 3, range = 74, type = 3 } -- Target Forward MK
character_specific.ibuki.moves["0b10"] = { startup = 9, active = 3, range = 99, type = 1 } -- HK
character_specific.ibuki.moves["3828"] = { startup = 7, active = 3, range = 99, type = 1 } -- Target HK
character_specific.ibuki.moves["0d90"] = { startup = 12, active = 1, range = 104, type = 1 } -- Forward HK
character_specific.ibuki.moves["0920"] = { -- Close HK
  { startup = 5, active = 1, range = 34, type = 1 },
  { startup = 7, active = 6, range = 34, type = 1 },
}
character_specific.ibuki.moves["1058"] = { startup = 3, active = 3, range = 67, type = 1 } -- Cr LP
character_specific.ibuki.moves["1118"] = { startup = 9, active = 7, range = 104, type = 1 } -- Cr MP
character_specific.ibuki.moves["12a8"] = { startup = 8, active = 3, range = 59, type = 1 } -- Cr HP
character_specific.ibuki.moves["14e0"] = { startup = 5, active = 3, range = 75, type = 2 } -- Cr LK
character_specific.ibuki.moves["15f0"] = { startup = 6, active = 5, range = 105, type = 2 } -- Cr MK
character_specific.ibuki.moves["19c0"] = { startup = 10, active = 2, range = 94, type = 2 } -- Cr HK
character_specific.ibuki.moves["1c10"] = { startup = 3, active = 100, range = 79, vertical_range = -66, type = 3 } -- Neutral Air LP
character_specific.ibuki.moves["1d10"] = { startup = 5, active = 7, range = 79, vertical_range = -56, type = 3 } -- Neutral Air MP
character_specific.ibuki.moves["1ee8"] = { startup = 11, active = 5, range = 79, vertical_range = -46, type = 3 } -- Neutral Air HP
character_specific.ibuki.moves["20f0"] = { startup = 4, active = 100, range = 86, vertical_range = -41, type = 3 } -- Neutral Air LK
character_specific.ibuki.moves["2210"] = { startup = 5, active = 7, range = 86, vertical_range = -41, type = 3 } -- Neutral Air MK
character_specific.ibuki.moves["2330"] = { startup = 10, active = 3, range = 89, vertical_range = -46, type = 3 } -- Neutral Air HK

character_specific.ibuki.moves["2450"] = { startup = 3, active = 19, range = 84, vertical_range = -38, type = 3 } -- Air LP
character_specific.ibuki.moves["25b0"] = { startup = 6, active = 13, range = 84, vertical_range = -38, type = 3 } -- Air MP
character_specific.ibuki.moves["1ee8"] = { startup = 11, active = 5, range = 94, type = 3 } -- Air HP
character_specific.ibuki.moves["2748"] = { startup = 3, active = 100, range = 54, type = 3 } -- Air LK
character_specific.ibuki.moves["2878"] = { startup = 7, active = 13, range = 94, type = 3 } -- Air MK
character_specific.ibuki.moves["29a8"] = character_specific.ibuki.moves["2330"] -- Air HK

character_specific.ibuki.moves["7ca0"] = { -- L Hien
  { startup = 22, active = 3, range = 50, type = 3 },
  { startup = 25, active = 8, range = 50, type = 3 },
}
character_specific.ibuki.moves["8100"] = { -- M Hien
  { startup = 25, active = 3, range = 50, type = 3 },
  { startup = 28, active = 8, range = 50, type = 3 },
}
character_specific.ibuki.moves["8560"] = { -- H Hien
  { startup = 28, active = 4, range = 50, type = 3 },
  { startup = 32, active = 8, range = 50, type = 3 },
}
character_specific.ibuki.moves["89c0"] = { -- EX Hien
  { startup = 26, active = 4, range = 50, type = 3 },
  { startup = 30, active = 8, range = 50, type = 3 },
}

character_specific.ibuki.moves["9910"] = { -- L Tsumuji
  { startup = 11, active = 1, range = 105, type = 1 },
  { startup = 26, active = 1, range = 105, type = 1 },
}
character_specific.ibuki.moves["a768"] = { startup = 10, active = 2, range = 105, type = 2 } -- L Tsumuji Kara
character_specific.ibuki.moves["9de8"] = { -- M Tsumuji
  { startup = 13, active = 1, range = 105, type = 1 },
  { startup = 29, active = 2, range = 105, type = 1 },
}
character_specific.ibuki.moves["a428"] = { -- H Tsumuji
  { startup = 14, active = 1, range = 105, type = 1 },
  { startup = 28, active = 2, range = 105, type = 1 },
}
character_specific.ibuki.moves["f980"] = { startup = 6, active = 1, range = 105, type = 1 } -- H Tsumuji Kara
character_specific.ibuki.moves["fc60"] = { startup = 9, active = 2, range = 110, type = 2 } -- H Tsumuji Kara

character_specific.ibuki.moves["e490"] = { startup = 7, active = 1, range = 105, type = 1 } -- Ex Tsumuji (1)
character_specific.ibuki.moves["e6f8"] = { -- Ex Tsumuji Kara (2-3 up)
  { startup = 4, active = 1, range = 90, type = 1 },
  { startup = 14, active = 2, range = 90, type = 1 },
}
character_specific.ibuki.moves["e988"] = { startup = 5, active = 1, range = 110, type = 1 } -- Ex Tsumuji Kara (4 up)
character_specific.ibuki.moves["e810"] = { -- Ex Tsumuji Kara (2-3 down)
  { startup = 9, active = 2, range = 110, type = 2 },
  { startup = 26, active = 2, range = 110, type = 2 },
}
character_specific.ibuki.moves["eb60"] = { startup = 9, active = 2, range = 110, type = 2 } -- Ex Tsumuji Kara (4 down)

character_specific.ibuki.moves["f320"] = { no_hit = true } -- L Kasumi Gake
character_specific.ibuki.moves["f540"] = { no_hit = true } -- L Kasumi Gake
character_specific.ibuki.moves["f760"] = { no_hit = true } -- L Kasumi Gake

character_specific.ibuki.moves["7120"] = { -- L Kazekiri
  { startup = 4, active = 1, range = 50, type = 1 },
  { startup = 5, active = 1, range = 50, type = 1 },
  { startup = 6, active = 10, range = 75, type = 1 },
}
character_specific.ibuki.moves["7370"] = { -- M Kazekiri
  { startup = 6, active = 1, range = 50, type = 1 },
  { startup = 7, active = 1, range = 50, type = 1 },
  { startup = 8, active = 8, range = 75, type = 1 },
}
character_specific.ibuki.moves["75f0"] = { -- H Kazekiri
  { startup = 8, active = 1, range = 50, type = 1 },
  { startup = 9, active = 1, range = 50, type = 1 },
  { startup = 10, active = 2, range = 75, type = 1 },
  { startup = 12, active = 7, range = 75, type = 1 },
}
character_specific.ibuki.moves["7888"] = { -- Ex Kazekiri
  { startup = 4, active = 1, range = 50, type = 1 },
  { startup = 5, active = 1, range = 50, type = 1 },
  { startup = 6, active = 2, range = 75, type = 1 },
  { startup = 8, active = 7, range = 75, type = 1 },
}

-- URIEN
character_specific.urien.moves["d774"] = { startup = 4, active = 2, range = 78, type = 1 } -- LP
character_specific.urien.moves["d864"] = { startup = 5, active = 5, range = 89, type = 1 } -- MP
character_specific.urien.moves["fa84"] = { startup = 7, active = 5, range = 89, type = 1 } -- Target MP
character_specific.urien.moves["d994"] = { startup = 9, active = 5, range = 83, type = 1 } -- Forward MP
character_specific.urien.moves["daa4"] = { startup = 10, active = 4, range = 81, type = 1 } -- HP
character_specific.urien.moves["dc1c"] = { startup = 14, active = 1, range = 76, type = 3 } -- Forward HP
character_specific.urien.moves["fbb4"] = { startup = 10, active = 1, range = 76, type = 3 } -- Target HP
character_specific.urien.moves["dcfc"] = { startup = 5, active = 2, range = 65, type = 1 } -- LK
character_specific.urien.moves["ddac"] = { startup = 8, active = 2, range = 107, type = 1 } -- MK
character_specific.urien.moves["df0c"] = { startup = 16, active = 5, range = 107, type = 1 } -- Forward MK
character_specific.urien.moves["df0c"] = { -- HK
  { startup = 17, active = 3, range = 80, vertical_range= -121, type = 3 },
  { startup = 20, active = 3, range = 105, type = 3 }
}

character_specific.urien.moves["e4ac"] = { startup = 4, active = 2, range = 70, type = 1 } -- Cr LP
character_specific.urien.moves["e65c"] = { startup = 11, active = 4, range = 65, type = 1 } -- Cr MP
character_specific.urien.moves["e72c"] = { -- Cr HP
  { startup = 9, active = 1, range = 50, type = 1 },
  { startup = 10, active = 2, range = 50, type = 1 }
}
character_specific.urien.moves["eaf4"] = { startup = 5, active = 3, range = 90, type = 2 } -- Cr LK
character_specific.urien.moves["ebc4"] = { startup = 5, active = 3, range = 105, type = 2 } -- Cr MK
character_specific.urien.moves["ec84"] = { startup = 12, active = 3, range = 110, type = 2 } -- Cr HK

character_specific.urien.moves["ee14"] = { startup = 4, active = 40, range = 50, vertical_range = -75, type = 3 } -- Air LP
character_specific.urien.moves["eeb4"] = { startup = 6, active = 4, range = 85, vertical_range = -80, type = 3 } -- Air MP
character_specific.urien.moves["ef94"] = { startup = 7, active = 6, range = 70, vertical_range = -70, type = 3 } -- Air HP
character_specific.urien.moves["f074"] = { startup = 4, active = 10, range = 40, vertical_range = -65, type = 3 } -- Air LP
character_specific.urien.moves["f114"] = { startup = 6, active = 4, range = 90, vertical_range = -90, type = 3 } -- Air MP
character_specific.urien.moves["f1f4"] = { startup = 10, active = 3, range = 100, vertical_range = -60, type = 3 } -- Air HP

character_specific.urien.moves["6c1c"] = { startup = 7, active = 10, range = 20, type = 1 } -- L Chariot Tackle
character_specific.urien.moves["6dfc"] = { startup = 10, active = 12, range = 20, type = 1 } -- M Chariot Tackle
character_specific.urien.moves["6fec"] = { startup = 13, active = 15, range = 20, type = 1 } -- H Chariot Tackle
character_specific.urien.moves["720c"] = { -- EX Chariot Tackle
  { startup = 6, active = 24, range = 20, type = 1 },
  { startup = 30, active = 10, range = 20, type = 1 },
}

character_specific.urien.moves["4cbc"] = { startup = 24, active = 12, range = 20, vertical_range=-100, type = 3 } -- L VCharge K


-- ALEX
character_specific.alex.moves["a444"] = { startup = 4, active = 3, range = 69, type = 1 } -- LP
character_specific.alex.moves["b224"] = { startup = 16, active = 5, range = 94, type = 1 } -- HK
character_specific.alex.moves["b714"] = { startup = 13, active = 5, range = 94, type = 1 } -- Cr HP
character_specific.alex.moves["5e54"] = { -- Flash Chop (Ex) (does not correspond to the frame data. I don't know why, maybe it's split in several animations)
  { startup = 4, active = 2, range = 94, type = 1 },
  { startup = 8, active = 2, range = 94, type = 1 },
}
