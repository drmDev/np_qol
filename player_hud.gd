extends "collapsible_panel.gd"
## Simple HUD showing player's HP, Wins, and Day during battle.
## Displays as a single line: [Heart] HP [value] | [Badge] Wins [value] | [Sun] Day [value]

const W := 160.0
const PAD := 5.0
const ROW := 10.0
const FS := 8

var info: Dictionary = {}


func setup(p_skin) -> void:
	size = Vector2(W, 30)
	super(p_skin)


func full_height() -> float:
	return HEAD_H + PAD + ROW + PAD


func header_text() -> String:
	return ""


func draw_header_text(r: Rect2) -> void:
	pass


func show_info(p_info: Dictionary) -> void:
	info = p_info
	_apply_size()
	queue_redraw()


static func _base(top: float) -> float:
	return top + ROW - 2.0


func draw_body() -> void:
	if info.is_empty():
		return
	
	var x := PAD + 2
	var y := HEAD_H + PAD
	var baseline := _base(y)
	var cursor_x := x
	var font: Font = skin.font_text

	var icon_size := 8.0
	var icon_gap := 3.0
	var label_gap := 3.0
	var group_gap := 8.0
	var separator := " | "

	var hp := str(info.get("my_hp", "?"))
	var wins := str(info.get("my_wins", "?"))
	var day := str(info.get("my_day", "?"))
	
	var hp_color := Color("#a34860")
	var wins_color := Color("#a36800")
	var day_color := Color("#c46516")

	# HP: Heart icon + value
	var heart: Texture2D = skin.icon_lives
	if heart != null:
		var icon_position := Vector2(cursor_x, y + (ROW - icon_size) * 0.5)
		draw_texture_rect(
			heart,
			Rect2(icon_position, Vector2(icon_size, icon_size)),
			false
		)
		cursor_x += icon_size + icon_gap

	skin.ink(self, font, Vector2(cursor_x, baseline), "HP", FS, skin.DIM)
	cursor_x += font.get_string_size("HP", HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x + label_gap

	skin.ink(self, font, Vector2(cursor_x, baseline), hp, FS, hp_color)
	cursor_x += font.get_string_size(hp, HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x + group_gap

	# Separator
	skin.ink(self, font, Vector2(cursor_x, baseline), separator, FS, skin.DIM)
	cursor_x += font.get_string_size(separator, HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x

	# Wins: Badge icon + value
	if skin.icon_badge != null:
		var icon_position := Vector2(cursor_x, y + (ROW - icon_size) * 0.5)
		draw_texture_rect(
			skin.icon_badge,
			Rect2(icon_position, Vector2(icon_size, icon_size)),
			false
		)
		cursor_x += icon_size + icon_gap
	
	skin.ink(self, font, Vector2(cursor_x, baseline), "Wins", FS, skin.DIM)
	cursor_x += font.get_string_size("Wins", HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x + label_gap

	skin.ink(self, font, Vector2(cursor_x, baseline), wins, FS, wins_color)
	cursor_x += font.get_string_size(wins, HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x + group_gap

	# Separator
	skin.ink(self, font, Vector2(cursor_x, baseline), separator, FS, skin.DIM)
	cursor_x += font.get_string_size(separator, HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x

	# Day: Sun icon + value
	if skin.icon_sun != null:
		var icon_position := Vector2(cursor_x, y + (ROW - icon_size) * 0.5)
		draw_texture_rect(
			skin.icon_sun,
			Rect2(icon_position, Vector2(icon_size, icon_size)),
			false
		)
		cursor_x += icon_size + icon_gap
	
	skin.ink(self, font, Vector2(cursor_x, baseline), "Day", FS, skin.DIM)
	cursor_x += font.get_string_size("Day", HORIZONTAL_ALIGNMENT_LEFT, -1, FS).x + label_gap

	skin.ink(self, font, Vector2(cursor_x, baseline), day, FS, day_color)
