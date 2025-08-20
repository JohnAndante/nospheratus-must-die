extends TileMapLayer

# Carrega o novo sistema de matrizes
const TileMatrixManager = preload("res://scripts/TileMatrixManager.gd")

@onready var player = get_node("/root/Main/Player")

# Configurações do mundo
@export var chunk_size: int = 16 # Tamanho de cada chunk em tiles
@export var view_distance: int = 3 # Distância de renderização em chunks

# Geração de ruído para o terreno
var noise = FastNoiseLite.new()
var detail_noise = FastNoiseLite.new()  # Ruído para detalhes
var loaded_chunks = {}

func _ready():
	print("ProceduralGround: _ready() iniciado")

	# Configuração do ruído principal
	noise.seed = randi()
	noise.fractal_octaves = 4
	noise.frequency = 0.08
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

	# Configuração do ruído de detalhes
	detail_noise.seed = randi() + 1000
	detail_noise.fractal_octaves = 2
	detail_noise.frequency = 0.25
	detail_noise.fractal_lacunarity = 2.0
	detail_noise.fractal_gain = 0.3

	print("ProceduralGround: Ruídos configurados")
	print("ProceduralGround: _ready() concluído")

func _process(_delta):
	if not is_instance_valid(player):
		if player == null:
			player = get_node_or_null("/root/Main/Player")
		return

	# Atualiza os chunks com base na posição do jogador
	update_chunks()

func update_chunks():
	if chunk_size <= 0:
		print("Erro: chunk_size é 0 ou negativo: ", chunk_size)
		return

	var player_world_pos = local_to_map(player.global_position)
	var player_chunk_pos = Vector2i(player_world_pos.x / chunk_size, player_world_pos.y / chunk_size)

	for x in range(player_chunk_pos.x - view_distance, player_chunk_pos.x + view_distance + 1):
		for y in range(player_chunk_pos.y - view_distance, player_chunk_pos.y + view_distance + 1):
			var chunk_pos = Vector2i(x, y)
			if not loaded_chunks.has(chunk_pos):
				generate_chunk(chunk_pos)
				loaded_chunks[chunk_pos] = true

func generate_chunk(chunk_pos: Vector2i):
	# Primeira passada: geração básica com blocos puros
	for x in range(chunk_size):
		for y in range(chunk_size):
			var world_pos = chunk_pos * chunk_size + Vector2i(x, y)
			var tile_coord = TileMatrixManager.get_tile_from_position(world_pos, noise, detail_noise)
			set_cell(world_pos, 0, tile_coord)

	# Segunda passada: pós-processamento para transições nas divisas
	for x in range(chunk_size):
		for y in range(chunk_size):
			var world_pos = chunk_pos * chunk_size + Vector2i(x, y)
			add_border_transitions(world_pos)

func add_border_transitions(world_pos: Vector2i):
	# Verifica o tile atual
	var current_tile = get_cell_atlas_coords(world_pos)

	# Se não é um bloco puro, não precisa processar
	if current_tile != Vector2i(0, 0) and current_tile != Vector2i(5, 1):
		return

	# MUDANÇA: Só aplica transição se o tile atual DEVERIA ser diferente
	# baseado na matriz 2x2, mas mantém blocos que deveriam ser puros
	var matrix_tile = calculate_transition_tile(world_pos)

	# Se a matriz indica que deveria ser o mesmo bloco puro, não muda nada
	if matrix_tile == current_tile:
		return

	# Só aplica a transição se a matriz realmente indica uma transição
	if matrix_tile != Vector2i(0, 0) and matrix_tile != Vector2i(5, 1):
		set_cell(world_pos, 0, matrix_tile)

func calculate_transition_tile(world_pos: Vector2i) -> Vector2i:
	# Usa o sistema de matriz 2x2 original para gerar a transição perfeita
	var tl_noise = noise.get_noise_2d(world_pos.x - 0.5, world_pos.y - 0.5)
	var tr_noise = noise.get_noise_2d(world_pos.x + 0.5, world_pos.y - 0.5)
	var bl_noise = noise.get_noise_2d(world_pos.x - 0.5, world_pos.y + 0.5)
	var br_noise = noise.get_noise_2d(world_pos.x + 0.5, world_pos.y + 0.5)

	var tl_grass = TileMatrixManager.is_grass_from_noise(tl_noise)
	var tr_grass = TileMatrixManager.is_grass_from_noise(tr_noise)
	var bl_grass = TileMatrixManager.is_grass_from_noise(bl_noise)
	var br_grass = TileMatrixManager.is_grass_from_noise(br_noise)

	return TileMatrixManager.get_tile_from_neighbors(tl_grass, tr_grass, bl_grass, br_grass)
