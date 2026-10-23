extends RefCounted
## UI skin for NP_QoL mod - loads game assets and custom icons

const PANEL_THEME := "res://assets/ui/themes/panel_container.tres"
const SECTION_THEME := "res://assets/ui/themes/inner_section_container.tres"
const HEADER_THEME := "res://assets/ui/themes/header_yellow_panel.tres"
const FONT_TEXT := "res://assets/ui/fonts/ChevyRay - Express.ttf"
const FALLBACK_FONTS := [
	"res://assets/ui/fonts/NotoSansJP-ExtraBold.ttf",
	"res://assets/ui/fonts/NotoSansKR-ExtraBold.ttf",
	"res://assets/ui/fonts/NotoSansSC-ExtraBold.ttf",
]
const SYSTEM_FALLBACKS := ["Leelawadee UI", "Tahoma", "Segoe UI", "Noto Sans Thai", "Noto Sans", "Arial Unicode MS", "Droid Sans Fallback"]
const ICON_LIVES := "res://assets/ui/textures/shop/lives_icon.png"

# Colors
const INK := Color("#263348")
const INK_SHADOW := Color("#ffffff")
const DIM := Color("#747d8c")

var panel: StyleBox
var section: StyleBox
var header: StyleBox
var font_text: Font
var icon_lives: Texture2D
var icon_badge: Texture2D
var icon_sun: Texture2D
var fallbacks: Array[Font] = []
var missing: Array[String] = []


func _init(base_dir: String = "") -> void:
	panel = _flat(Color("#f0f4f8"), Color("#52647a"))
	section = _style(SECTION_THEME, _flat(Color(0.86, 0.85, 0.82), Color(0.6, 0.6, 0.62)))
	header = _style(HEADER_THEME, _flat(Color(0.98, 0.8, 0.3), Color(0.35, 0.28, 0.1)))
	
	for p in FALLBACK_FONTS:
		if ResourceLoader.exists(p):
			var f = load(p)
			if f is Font:
				fallbacks.append(f)
	var sys := SystemFont.new()
	sys.font_names = PackedStringArray(SYSTEM_FALLBACKS)
	fallbacks.append(sys)

	var custom_font := SystemFont.new()
	custom_font.font_names = PackedStringArray(["Consolas"])
	custom_font.fallbacks = fallbacks
	font_text = custom_font

	icon_lives = _tex(ICON_LIVES)
	
	# Load custom icons from mod directory
	if base_dir != "":
		var badge_path := base_dir.path_join("assets/badge.png")
		var sun_path := base_dir.path_join("assets/sun.png")
		
		icon_badge = _external_texture(badge_path)
		icon_sun = _external_texture(sun_path)


func _style(theme_path: String, fallback: StyleBox) -> StyleBox:
	if ResourceLoader.exists(theme_path):
		var th = load(theme_path)
		if th is Theme and th.has_stylebox("panel", "PanelContainer"):
			return th.get_stylebox("panel", "PanelContainer")
	missing.append(theme_path)
	return fallback


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var t = load(path)
		if t is Texture2D:
			return t
	missing.append(path)
	return null


func _external_texture(path: String) -> Texture2D:
	var image := Image.new()
	var error: Error = image.load(path)

	if error != OK:
		push_warning(
			"NP_QoL: image load failed: %s (%s)"
			% [path, error_string(error)]
		)
		return null

	return ImageTexture.create_from_image(image)


static func _flat(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(3)
	s.set_content_margin_all(4)
	return s


## Body text in the game's description style (dark ink with a light shadow) for light panels.
static func ink(ci: CanvasItem, font: Font, pos: Vector2, text: String, size: int, col := INK,
		width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	ci.draw_string(font, pos + Vector2(0, 1), text, align, width, size, INK_SHADOW)
	ci.draw_string(font, pos, text, align, width, size, col)
