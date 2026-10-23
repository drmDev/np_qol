extends Node

const VERSION := "0.1.0"
const MOD_ID := "np_qol"
const GROUP := "np_qol_core"
const CFG_PATH := "user://np_qol.cfg"
const POLL_SEC := 0.1
const BATTLE_STATE := "res://game/states/battle_state.gd"
const PARTS := ["ui_skin.gd", "collapsible_panel.gd", "opponent_hud.gd"]
const DEFAULT_HUD_POS := Vector2(108, 244)

var base_dir := ""
var skin
var layer: CanvasLayer
var hud
var cfg := ConfigFile.new()
var active := false
var phase := ""
var off_reason := ""

var _poll_ms := 0
var _battle_id := 0
var _info: Dictionary = {}
<<<<<<< HEAD
=======
var _battle_result_shown := false    # track if we've shown victory/defeat for this battle
var _audio_player: AudioStreamPlayer
var _sudden_death_player: AudioStreamPlayer
var _defeat_sound_player: AudioStreamPlayer
var _pikachu_overlay: Control
>>>>>>> e94948e27a307bff6f1706443464846185193d95

var hooks: Array[String] = []
var _booted := false


func _init() -> void:
	base_dir = str(get_script().resource_path).get_base_dir()


func _sub(file: String):
	return load(base_dir.path_join(file))


func mod_init() -> void:
	hooks.append("mod_init")


func mod_ready() -> void:
	hooks.append("mod_ready")
	_boot()


func mod_bootstrap() -> void:
	hooks.append("mod_bootstrap")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not _from_loader():
		_boot()


func _exit_tree() -> void:
	if active:
		_save_cfg()
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)


func _boot() -> void:
	if _booted:
		return
	_booted = true
	for other in get_tree().get_nodes_in_group(GROUP):
		if other != self and is_instance_valid(other):
			print("NP_QoL: another copy is already running (%s) - this one stays idle" % other.get_path())
			return
	add_to_group(GROUP)
	cfg.load(CFG_PATH)
	_boot_overlay()
	print("NP_QoL %s loaded (%s)%s" % [VERSION, "Mod Loader" if _from_loader() else "autoload",
		"" if active else " - overlay off: " + off_reason])


func _boot_overlay() -> void:
	for f in PARTS:
		var s = _sub(f)
		if not (s is Script) or not s.can_instantiate():
			off_reason = "%s failed to load" % f
			push_warning("NP_QoL %s: %s - overlay disabled" % [VERSION, off_reason])
			return
	active = true

	skin = _sub("ui_skin.gd").new(base_dir)
	if not skin.missing.is_empty():
		push_warning("NP_QoL: game assets not found, using fallbacks: %s" % ", ".join(skin.missing))
	
	layer = CanvasLayer.new()
	layer.layer = 110
	layer.name = "NP_QoL_Layer"
	add_child(layer)

	hud = _sub("opponent_hud.gd").new()
	hud.name = "PlayerHud"
	hud.setup(skin)
	hud.position = _on_screen(cfg.get_value("ui", "hud_pos", DEFAULT_HUD_POS), DEFAULT_HUD_POS)
	hud.set_minimized(bool(cfg.get_value("ui", "hud_minimized", false)), false)
	hud.visible = false
	layer.add_child(hud)
	hud.minimized_changed.connect(func(_on): _save_cfg())
	hud.moved_by_drag.connect(_save_cfg)
<<<<<<< HEAD
=======
	
	# Setup victory fanfare audio player
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "VictoryFanfare"
	var fanfare_path := base_dir.path_join("assets/sounds/fanfareff.ogg")
	var fanfare_stream = AudioStreamOggVorbis.load_from_file(fanfare_path)
	if fanfare_stream != null:
		_audio_player.stream = fanfare_stream
		_audio_player.volume_db = 0.0
		print("MyBattleStats: Victory fanfare loaded successfully")
	else:
		push_warning("MyBattleStats: Failed to load fanfare from: %s" % fanfare_path)
	add_child(_audio_player)
	
	# Setup sudden death audio player
	_sudden_death_player = AudioStreamPlayer.new()
	_sudden_death_player.name = "SuddenDeathSound"
	var sd_path := base_dir.path_join("assets/sounds/over9000.ogg")
	var sd_stream = AudioStreamOggVorbis.load_from_file(sd_path)
	if sd_stream != null:
		_sudden_death_player.stream = sd_stream
		_sudden_death_player.volume_db = 0.0
		print("MyBattleStats: Sudden death sound loaded successfully")
	else:
		push_warning("MyBattleStats: Failed to load sudden death sound from: %s" % sd_path)
	add_child(_sudden_death_player)
	
	# Setup defeat sound player
	_defeat_sound_player = AudioStreamPlayer.new()
	_defeat_sound_player.name = "DefeatSound"
	var defeat_path := base_dir.path_join("assets/sounds/ohbanana.ogg")
	var defeat_stream = AudioStreamOggVorbis.load_from_file(defeat_path)
	if defeat_stream != null:
		_defeat_sound_player.stream = defeat_stream
		_defeat_sound_player.volume_db = 0.0
		print("MyBattleStats: Defeat sound loaded successfully")
	else:
		push_warning("MyBattleStats: Failed to load defeat sound from: %s" % defeat_path)
	add_child(_defeat_sound_player)
	
	# Setup shocked Pikachu overlay (hidden by default)
	_pikachu_overlay = Control.new()
	_pikachu_overlay.name = "PikachuOverlay"
	_pikachu_overlay.visible = false
	_pikachu_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pikachu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var pikachu_texture_rect = TextureRect.new()
	pikachu_texture_rect.name = "PikachuImage"
	pikachu_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pikachu_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pikachu_texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	pikachu_texture_rect.position = Vector2(-200, -200)  # Center offset
	pikachu_texture_rect.size = Vector2(400, 400)  # Large shocked Pikachu!
	
	var pikachu_path := base_dir.path_join("assets/surprisedPika.jpg")
	var pikachu_image := Image.new()
	if pikachu_image.load(pikachu_path) == OK:
		pikachu_texture_rect.texture = ImageTexture.create_from_image(pikachu_image)
	else:
		push_warning("MyBattleStats: Failed to load shocked Pikachu from: %s" % pikachu_path)
	
	_pikachu_overlay.add_child(pikachu_texture_rect)
	layer.add_child(_pikachu_overlay)
>>>>>>> e94948e27a307bff6f1706443464846185193d95

	get_tree().node_added.connect(_on_node_added)


func _from_loader() -> bool:
	var p = get_parent()
	return p != null and p == get_node_or_null("/root/ModLoader")


func _save_cfg() -> void:
	if not active:
		return
	cfg.set_value("ui", "hud_pos", hud.position)
	cfg.set_value("ui", "hud_minimized", hud.minimized)
	cfg.save(CFG_PATH)


static func _on_screen(pos, fallback: Vector2) -> Vector2:
	if not (pos is Vector2) or not Rect2(Vector2(-40, 0), Vector2(660, 345)).has_point(pos):
		return fallback
	return pos


func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if active and hud.moved:
			_save_cfg()


static func script_is(n, path: String) -> bool:
	if n == null or not is_instance_valid(n):
		return false
	var s = n.get_script()
	while s != null:
		if str(s.resource_path) == path:
			return true
		s = s.get_base_script()
	return false


func _on_node_added(n: Node) -> void:
	if n.has_signal("transition_requested") and n.has_method("request_transition"):
		if not n.transition_requested.is_connected(_on_transition):
			n.transition_requested.connect(_on_transition)


func _on_transition(target: String, _data: Dictionary) -> void:
	if target != "battle":
		return


func current_state():
	var main = get_tree().current_scene
	if main == null or not ("current_state" in main):
		return null
	var st = main.current_state
	return st if st != null and is_instance_valid(st) else null


func _process(_delta: float) -> void:
	if not active:
		return
	var now := Time.get_ticks_msec()
	if now - _poll_ms < int(POLL_SEC * 1000.0):
		return
	_poll_ms = now
	var st = current_state()
	phase = "battle" if script_is(st, BATTLE_STATE) else ""
	_tick_battle(st)


func _tick_battle(st) -> void:
	if phase != "battle":
		hud.visible = false
		return
	
	var my_run = st.get("_replay_p1_data")
	if my_run == null:
		hud.visible = false
		return
	
	if st.get_instance_id() != _battle_id or _info.is_empty():
		_battle_id = st.get_instance_id()
		_info = {}

	_info["my_hp"] = "?"
	_info["my_wins"] = "?"
	_info["my_day"] = "?"

	if my_run != null:
		for pair in [
			["my_hp", "lives"],
			["my_wins", "current_wins"],
			["my_day", "current_round"],
		]:
			var value = my_run.get(pair[1])
			if value != null:
				_info[pair[0]] = str(value)

<<<<<<< HEAD
	hud.show_info(_info)
	hud.visible = bool(st.get("is_battle_active"))
=======

## Animated Pikachu face that spawns randomly and flies off screen while growing
func show_pikachu(
		texture: Texture2D,
		normal_width: float = 180.0,
		duration: float = 1.8,
		growth: float = 4.0
) -> void:
	if texture == null or texture.get_width() <= 0:
		return

	var viewport := get_viewport()
	var screen_size := viewport.get_visible_rect().size
	if screen_size.x <= 0.0 or screen_size.y <= 0.0:
		return

	duration = maxf(duration, 0.05)
	growth = maxf(growth, 1.0)

	var overlay := CanvasLayer.new()
	overlay.layer = 100
	overlay.follow_viewport_enabled = false
	overlay.transform = Transform2D.IDENTITY
	viewport.add_child(overlay)
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS

	var face := Sprite2D.new()
	face.texture = texture
	face.centered = true
	overlay.add_child(face)

	# "Normal size" means this displayed width, preserving aspect ratio
	var start_scale := maxf(normal_width, 1.0) / float(texture.get_width())
	face.scale = Vector2.ONE * start_scale

	# Random center position; keep the whole starting image visible
	var half_size := texture.get_size() * start_scale * 0.5
	var margin := Vector2(
		minf(half_size.x, screen_size.x * 0.5),
		minf(half_size.y, screen_size.y * 0.5)
	)
	var start := Vector2(
		randf_range(margin.x, screen_size.x - margin.x),
		randf_range(margin.y, screen_size.y - margin.y)
	)
	face.position = start

	# Uniform random angle, independent of spawn position
	var angle := randf_range(0.0, TAU)
	var direction := Vector2(cos(angle), sin(angle))

	# Move far enough that even the enlarged image exits the viewport
	var final_radius := half_size.length() * growth
	var distance := screen_size.length() + final_radius + 32.0
	var finish := start + direction * distance

	var tween := face.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(face, "position", finish, duration)
	tween.tween_property(
		face, "scale", Vector2.ONE * start_scale * growth, duration
	)
	tween.chain().tween_callback(overlay.queue_free)


## Check battle result and trigger victory fanfare or defeat Pikachu
func _check_battle_result(battle_data) -> void:
	# Use player_health to determine victory/defeat (more reliable than is_dead flag)
	var player_hp := int(battle_data.player_health[0])  # Team 0 = player
	var enemy_hp := int(battle_data.player_health[1])   # Team 1 = enemy
	var is_sudden_death := bool(battle_data.is_sudden_death)
	
	print("MyBattleStats: Battle ended - Player HP: %d, Enemy HP: %d, Sudden Death: %s" % [player_hp, enemy_hp, is_sudden_death])
	
	# Check for sudden death and play special sound
	if is_sudden_death:
		print("MyBattleStats: SUDDEN DEATH! Playing over 9000 sound...")
		if _sudden_death_player != null and _sudden_death_player.stream != null:
			_sudden_death_player.play()
	
	if player_hp > 0 and enemy_hp <= 0:
		# Victory! Play Final Fantasy fanfare
		print("MyBattleStats: VICTORY! Playing fanfare...")
		if _audio_player != null and _audio_player.stream != null:
			_audio_player.play()
	elif player_hp <= 0 and enemy_hp > 0:
		# Defeat! Show shocked Pikachu with animation and sound
		print("MyBattleStats: DEFEAT! Showing shocked Pikachu with animation...")
		
		# Play defeat sound
		if _defeat_sound_player != null and _defeat_sound_player.stream != null:
			_defeat_sound_player.play()
		
		# Show animated Pikachu flying off screen
		if _pikachu_overlay != null:
			var pikachu_img = _pikachu_overlay.get_node("PikachuImage")
			if pikachu_img != null and pikachu_img.texture != null:
				show_pikachu(pikachu_img.texture, 180.0, 1.8, 4.0)
	elif player_hp <= 0 and enemy_hp <= 0:
		# Draw! Both teams dead - play fanfare
		print("MyBattleStats: DRAW! Both teams eliminated - Playing fanfare...")
		if _audio_player != null and _audio_player.stream != null:
			_audio_player.play()
	else:
		print("MyBattleStats: Unknown result - Player HP: %d, Enemy HP: %d" % [player_hp, enemy_hp])


## Static facts about the opponent for the HUD (from the battle's own copy of their run).
func opponent_info(p2, captured) -> Dictionary:
	var trainer = GameDatabase.get_trainer_by_id(str(p2.trainer_id))
	if trainer == null:
		trainer = GameDatabase.get_trainer_by_id("youngster_f")
	var trainer_name: String = str(trainer.name) if trainer != null else ""
	var shown := display_name_for(p2, trainer_name)
	return {
		"name": shown,                                       # what the game's VS screen shows
		"player": shown if shown != trainer_name else "",    # the ghost's username ("" = hidden / none)
		"trainer": trainer_name,                             # trainer class (Chef, Painter, ...)
		"mmr": mmr_text(captured if _same_opponent(captured, p2) else null),
		"round": int(p2.current_round),
		"wins": int(p2.current_wins),
		"lives": int(p2.lives),
		"lives_lost": int(p2.lives_lost),
		"second_chance": bool(p2.has_used_second_chance),
	}


## Units of a run by board slot (0-2 front row, 3-5 back row).
static func team_list(run) -> Array:
	var out: Array = []
	if run == null:
		return out
	for i in run.team.size():
		var m = run.team[i]
		if m != null and m.data != null:
			out.append({"slot": i, "name": str(m.data.name), "level": int(m.level), "shiny": bool(m.is_shiny)})
	return out


## The name the game itself shows in the battle intro (respects "hide usernames").
static func display_name_for(p2, trainer_name: String) -> String:
	var show := true
	if SettingsManager.has_method("is_hide_usernames_enabled"):
		show = not SettingsManager.is_hide_usernames_enabled()
	if show and UserManager.data and str(UserManager.data.display_name) != "":
		var n := str(p2.display_name)
		return n if n != "" else trainer_name
	return trainer_name


func _same_opponent(captured, p2) -> bool:
	return captured != null and is_instance_valid(captured) \
		and str(captured.display_name) == str(p2.display_name) \
		and str(captured.trainer_id) == str(p2.trainer_id) \
		and Time.get_ticks_msec() - _captured_at < 600000


static func mmr_text(opp) -> String:
	if opp == null:
		return ""
	var uid := str(opp.get("_matched_user_id"))
	var mmr := int(opp.get("_matched_opponent_mmr")) if opp.get("_matched_opponent_mmr") != null else -1
	if uid.begins_with("bot_"):
		return "Bot"
	if mmr < 0:
		return ""
	if opp.get("_matched_mmr_is_ranked") == false:
		return "MMR %d (casual)" % mmr
	return "MMR %d" % mmr


## Live numbers of YOUR side of the visual battle simulation (the one on screen): your team's
## damage (hits + burn / poison) and each of your units' damage so far (hits + its status share).
static func battle_snapshot(sim) -> Dictionary:
	if sim == null or sim.data == null:
		return {}
	var d = sim.data

	# Temporary diagnostic: log once when a friendly unit is available.
	if not sim.has_meta("my_stats_fields_logged"):
		for debug_unit in d.battle_units:
			if debug_unit == null or debug_unit.team_id != 0:
				continue

			sim.set_meta("my_stats_fields_logged", true)

			print("MyBattleStats: BATTLE DATA FIELDS")
			for property in d.get_property_list():
				print("MyBattleStats data field: ", property["name"])

			print("MyBattleStats: UNIT FIELDS")
			for property in debug_unit.get_property_list():
				print("MyBattleStats unit field: ", property["name"])

			var unit_script: Script = debug_unit.get_script()
			if unit_script != null:
				print("MyBattleStats unit script: ", unit_script.resource_path)

			break

	# burn / poison damage is pooled per team by the game: each unit gets the share of it that matches
	# its share of the burn + poison stacks your team applied
	var units := {}
	var stacks := 0.0
	for u in d.battle_units:
		if u == null or u.team_id != 0:
			continue
		var s: int = u.slot_index
		var r: Dictionary = units.get(s, {"damage": 0.0, "heal": 0.0, "shield": 0.0, "stacks": 0.0, "dead": true})
		r.damage = float(r.damage) + float(u.damage_dealt)
		r.heal = float(r.heal) + float(u.healing_done)
		r.shield = float(r.shield) + float(u.shield_granted)
		r.stacks = float(r.stacks) + float(u.burn_inflicted + u.poison_inflicted)
		r.dead = bool(r.dead) and bool(u.is_dead)
		units[s] = r
		stacks += float(u.burn_inflicted + u.poison_inflicted)
	var status_dmg := float(d.team_status_damage_dealt[0])
	for s in units:
		if stacks > 0.0:
			units[s].damage = float(units[s].damage) + status_dmg * float(units[s].stacks) / stacks
	
	# Calculate team-wide heal and shield totals by summing per-unit values
	var total_heal := 0.0
	var total_shield := 0.0
	for s in units:
		total_heal += float(units[s].get("heal", 0.0))
		total_shield += float(units[s].get("shield", 0.0))
	
	return {
		"time": float(d.time_elapsed),
		"damage": float(d.team_damage_dealt[0]) + float(d.team_status_damage_dealt[0]),
		"heal": total_heal,
		"shield": total_shield,
		"my_units": units,
		"over": bool(d.battle_over),
	}
>>>>>>> e94948e27a307bff6f1706443464846185193d95
