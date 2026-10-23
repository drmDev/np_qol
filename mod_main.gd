extends Node

const VERSION := "0.1.0"
const MOD_ID := "np_qol"
const GROUP := "np_qol_core"
const POLL_SEC := 0.1
const BATTLE_STATE := "res://game/states/battle_state.gd"
const PARTS := ["ui_skin.gd", "player_hud.gd"]
const DEFAULT_HUD_POS := Vector2(108, 244)

var base_dir := ""
var skin
var layer: CanvasLayer
var hud
var active := false
var phase := ""
var off_reason := ""

var _poll_ms := 0
var _battle_id := 0
var _info: Dictionary = {}

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

	hud = _sub("player_hud.gd").new()
	hud.name = "PlayerHud"
	hud.setup(skin)
	hud.position = Vector2(
		roundf((get_viewport().get_visible_rect().size.x - hud.size.x) * 0.5),
		DEFAULT_HUD_POS.y
	)
	hud.visible = false
	layer.add_child(hud)

	get_tree().node_added.connect(_on_node_added)


func _from_loader() -> bool:
	var p = get_parent()
	return p != null and p == get_node_or_null("/root/ModLoader")


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

	hud.show_info(_info)
	hud.visible = bool(st.get("is_battle_active"))
