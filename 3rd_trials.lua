require("src/startup")

print("-----------------------------")
print("  3rd_trials.lua - "..script_version.."")
print("  Trials script for "..game_name.."")
print("  Last tested Fightcade version: "..fc_version.."")
print("  project url: https://github.com/Grouflon/3rd_training_lua")
print("-----------------------------")
print("This is a proof of concept which has only a handful of Hugo combos")
print("Command List:")
print("- Lua Hotkey 1 (alt+1) Go up the combo list")
print("- Lua Hotkey 2 (alt+2) Go down the combo list")
print("")

require("src/tools")
require("src/memory_adresses")
require("src/framedata")
require("src/gamestate")

moves =
{
  {
    name = "Light Punch",
    hits = { "3fe0" },
    command = "5LP"
  },
  {
    name = "Crouching Light Punch",
    hits = { "4e00" },
    command = "2LP"
  },
  {
    name = "Air Heavy Kick",
    hits = { "5790" },
    command = "5HK"
  },
  {
    name = "Light Clap",
    hits = { "efcc" },
    command = "214LP"
  },
  {
    name = "Heavy Clap",
    hits = { "f3ac" },
    command = "214HP"
  },
  {
    name = "EX Clap",
    hits = { 'f59c', 'f59c', 'f59c' },
    command = "214PP"
  },
  {
    name = "Hammer Mountain",
    hits = { '1294', '15cc', '15cc', '15cc', '15cc' },
    command = "236236P"
  },
  {
    name = "Light Ultra Throw",
    hits = { '06b4' },
    command = "63214LP"
  },
  {
    name = "Light Back Breaker",
    hits = { '096c' },
    command = "63214LP"
  },
  {
    name = "Medium Back Breaker",
    hits = { '0ab4' },
    command = "63214MP"
  },
}

combos = {
  {
    hits = {'3fe0', '3fe0', '3fe0'}
  },
  {
    hits = {'f3ac', 'efcc', '1294', '15cc', '15cc', '15cc', '15cc'}
  },
  {
    hits = {'4e00', '4e00', '1294', '15cc', '15cc', '15cc', '15cc'}
  },
  {
    hits = {'3fe0', '4e00', '1294', '15cc', '15cc', '15cc', '15cc'}
  },
  {
    hits = {'06b4', 'efcc', '096c'}
  },
  {
    hits = {'f59c', 'f59c', 'f59c', '0ab4'}
  },
  {
    hits = {'5790', '1294', '15cc', '15cc', '15cc', '15cc'}
  },
}

function generate_move_lookup_table(_moves)
  local _lookup_table = {}
  for _i, _move in ipairs(_moves) do
    for __, _hit in ipairs(_move.hits) do
      _lookup_table[_hit] = _i
    end
  end
  return _lookup_table
end
animation_to_move = generate_move_lookup_table(moves)

function reset_combo_watch(_combo_watch)
  _combo_watch.is_started = false
  _combo_watch.hits = {}
end

function build_combo_steps(_combo)
  local _combo_steps = {
    steps = {},
    hit_to_step = {},
  }

  local _hit_id = 1
  while _hit_id <= #_combo.hits do
    local _hit = _combo.hits[_hit_id]
    table.insert(_combo_steps.steps, _hit)

    local _move = find_move_from_hit(_hit)
    if _move ~= nil then
      for _i = 1, #_move.hits do
        table.insert(_combo_steps.hit_to_step, #_combo_steps.steps)
        _hit_id = _hit_id + 1
      end
    else
      table.insert(_combo_steps.hit_to_step, #_combo_steps.steps)
      _hit_id = _hit_id + 1
    end
  end

  --print(_combo)
  --print(_combo_steps)

  return _combo_steps
end

function find_move_from_hit(_hit)
  local _move_id = animation_to_move[_hit]
  if _move_id == nil then
    return nil
  end
  return moves[_move_id]
end

combo_watch = {}
reset_combo_watch(combo_watch)

target_combo_id = 1
combo_steps = build_combo_steps(combos[target_combo_id])

-- EMU

function on_start()
  savestate.load(savestate.create("data/"..rom_name.."/savestates/trials.fs"))
end

function before_frame()

  -- READ GAME STATE
  gamestate_read()

  -- WRITE GAME STATE
  local _write_game_vars_settings =
  {
    infinite_time = true,
    music_volume = 0,
  }
  write_game_vars(_write_game_vars_settings)

  for i = 1, #player_objects do
    local _player_obj = player_objects[i]

    -- LIFE
    if is_in_match and not is_menu_open then
      local _life = memory.readbyte(_player_obj.base + 0x9F)
      local _life_refill_delay = 1
      if _player_obj.is_idle and _player_obj.idle_time > _life_refill_delay then
        local _refill_rate = 6
        _life = math.min(_life + _refill_rate, 160)
      end
      memory.writebyte(_player_obj.base + 0x9F, _life)
      _player_obj.life = _life
    end

    -- METER
    if is_in_match and not is_menu_open and not _player_obj.is_in_timed_sa and _player_obj.is_idle then
      local _is_timed_sa = character_specific[_player_obj.char_str].timed_sa[_player_obj.selected_sa]
      local _previous_meter_count = memory.readbyte(_player_obj.meter_addr[2])
      local _previous_meter_count_slave = memory.readbyte(_player_obj.meter_addr[1])
      if _previous_meter_count ~= _player_obj.max_meter_count and _previous_meter_count_slave ~= _player_obj.max_meter_count then
        local _gauge_value = 0
        if _is_timed_sa then
          _gauge_value = _player_obj.max_meter_gauge
        end
        memory.writebyte(_player_obj.gauge_addr, _gauge_value)
        memory.writebyte(_player_obj.meter_addr[2], _player_obj.max_meter_count)
        memory.writebyte(_player_obj.meter_update_flag, 0x01)
      end
    end

    -- STUN
    if _player_obj.is_idle then
      memory.writebyte(_player_obj.stun_timer_addr, 0);
      memory.writedword(_player_obj.stun_bar_addr, 0);
    end
  end

  -- COMBO CHECK
  if hotkey1_pressed then
    target_combo_id = target_combo_id - 1
    target_combo_id = (((target_combo_id - 1) + #combos) % #combos) + 1
    combo_steps = build_combo_steps(combos[target_combo_id])
    reset_combo_watch(combo_watch)
  elseif hotkey2_pressed then
    target_combo_id = target_combo_id + 1
    target_combo_id = (((target_combo_id - 1) + #combos) % #combos) + 1
    combo_steps = build_combo_steps(combos[target_combo_id])
    reset_combo_watch(combo_watch)
  end

  local _attacker = player_objects[1]
  local _defender = player_objects[2]

  if combo_watch.is_started then
    local _combo_dropped = (_defender.has_just_been_hit and not _defender.is_being_thrown and _attacker.previous_combo >= _attacker.combo)
    _combo_dropped = _combo_dropped or _attacker.previous_combo > _attacker.combo
    _combo_dropped = _combo_dropped or (_attacker.has_just_ended_recovery and _attacker.combo == 0)

    if _combo_dropped or _defender.is_idle or _defender.is_wakingup or _defender.is_in_air_recovery then
      --print(string.format("%d, %d, %d, %d", to_bit(_combo_dropped), to_bit(_defender.is_idle), to_bit(_defender.is_wakingup), to_bit(_defender.is_in_air_recovery)))
      combo_watch.is_started = false
      print(combo_watch.hits)
    end
  end

  if _defender.has_just_been_hit then
    if not combo_watch.is_started then
      reset_combo_watch(combo_watch)
      combo_watch.is_started = true
    end
    table.insert(combo_watch.hits, _attacker.animation)
  end
end

function on_gui()

  local _x = 50
  local _y = 35
  local _combo = combos[target_combo_id]

  local _max_hit = 0
  for _i = 1, #combo_watch.hits do
    if combo_watch.hits[_i] == _combo.hits[_i] then
      _max_hit = _max_hit + 1
    else
      break
    end
  end

  local _previous_step = 0
  for _i = 1, #combo_steps.hit_to_step do
    local _step_id = combo_steps.hit_to_step[_i]
    if _step_id ~= _previous_step then
      _previous_step = _step_id
      local _step = combo_steps.steps[_step_id]
      local _s = _step
      local _move = find_move_from_hit(_step)
      if _move ~= nil then
        _s = string.format("%s - %s", _move.name, _move.command)
      end
      local _color = 0xFFFFFFFF
      if _i <= _max_hit then
        _color = 0xFF0000FF
      end

      gui.text(_x, _y, _s, _color)
      _y = _y + 9
    end
  end

  gui.box(0,0,0,0,0,0) -- if we don't draw something, what we drawed from last frame won't be cleared

  hotkey1_pressed = false
  hotkey2_pressed = false
  hotkey3_pressed = false
  hotkey4_pressed = false
end

emu.registerstart(on_start)
emu.registerbefore(before_frame)
gui.register(on_gui)


function hotkey1()
  hotkey1_pressed = true
end
function hotkey2()
  hotkey2_pressed = true
end
function hotkey3()
  hotkey3_pressed = true
end
function hotkey4()
  hotkey4_pressed = true
end

input.registerhotkey(1, hotkey1)
input.registerhotkey(2, hotkey2)
input.registerhotkey(3, hotkey3)
input.registerhotkey(4, hotkey4)