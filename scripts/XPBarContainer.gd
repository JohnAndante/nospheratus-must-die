extends Control
class_name XPBarContainer

@onready var xp_bar: ProgressBar
var segments: Array[ColorRect] = []
var segment_count: int = 10

func _ready():
	# Encontrar a barra de XP original usando call_deferred para evitar conflitos
	call_deferred("setup_segments")

func setup_segments():
	# Encontrar a barra de XP original
	xp_bar = get_parent().get_node("XPBar")
	create_segments()

func create_segments():
	# Limpar segmentos existentes
	for segment in segments:
		if is_instance_valid(segment):
			segment.queue_free()
	segments.clear()

	# Criar segmentos visuais em cima da barra de XP
	for i in range(1, segment_count):  # Começamos do 1 para não criar linha no início
		var segment = ColorRect.new()
		segment.color = Color(0, 0, 0, 0.3)  # Cor escura semi-transparente para divisórias

		# Posicionar o segmento
		var segment_width = 2  # Largura da linha divisória
		var bar_width = xp_bar.size.x
		var segment_spacing = bar_width / segment_count

		segment.size = Vector2(segment_width, xp_bar.size.y)
		segment.position = Vector2(
			xp_bar.position.x + (i * segment_spacing) - (segment_width / 2.0),
			xp_bar.position.y
		)
		segment.z_index = 10  # Colocar acima da barra de XP

		get_parent().call_deferred("add_child", segment)
		segments.append(segment)

func update_xp_display(current_xp: int, xp_to_next: int):
	# Atualizar a barra de XP original
	if xp_bar:
		xp_bar.value = (float(current_xp) / xp_to_next) * 100

	# Calcular quantos segmentos devem estar "preenchidos"
	var progress = float(current_xp) / xp_to_next
	var filled_segments = int(progress * segment_count)

	# Colorir os segmentos baseado no progresso
	for i in range(segments.size()):
		if segments[i] and is_instance_valid(segments[i]):
			if i < filled_segments:
				segments[i].color = Color(1.0, 1.0, 0.6, 0.4)  # Dourado transparente para segmentos preenchidos
			else:
				segments[i].color = Color(0, 0, 0, 0.6)  # Preto mais opaco para segmentos vazios
