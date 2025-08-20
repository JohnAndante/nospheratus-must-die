class_name TileMatrixManager

# Sistema de matrizes 2x2 para tiles
# 0 = terra (_), 1 = grama (#)

# Mapeamento direto: matriz 2x2 -> coordenada do tile
static var TILE_MATRICES = {
	# Terra e grama preenchidas
	[[0,0],[0,0]]: Vector2i(0, 0),  # Terra preenchida
	[[1,1],[1,1]]: Vector2i(5, 1),  # Grama preenchida

	# Divisões verticais (colunas)
	[[0,0],[1,1]]: Vector2i(5, 0),  # Topo terra, inferior grama
	[[1,1],[0,0]]: Vector2i(5, 2),  # Topo grama, inferior terra

	# Divisões horizontais (linhas)
	[[0,1],[0,1]]: Vector2i(4, 1),  # Esquerda terra, direita grama
	[[1,0],[1,0]]: Vector2i(6, 1),  # Esquerda grama, direita terra

	# Cantos de terra (3/4 terra)
	[[0,1],[1,1]]: Vector2i(2, 1),  # Canto superior esquerdo terra
	[[1,0],[1,1]]: Vector2i(3, 1),  # Canto superior direito terra
	[[1,1],[0,1]]: Vector2i(2, 2),  # Canto inferior esquerdo terra
	[[1,1],[1,0]]: Vector2i(3, 2),  # Canto inferior direito terra

	# Cantos de grama (3/4 grama)
	[[0,0],[0,1]]: Vector2i(4, 0),  # Canto inferior direito grama
	[[0,0],[1,0]]: Vector2i(6, 0),  # Canto inferior esquerdo grama
	[[0,1],[0,0]]: Vector2i(4, 2),  # Canto superior direito grama
	[[1,0],[0,0]]: Vector2i(6, 2),  # Canto superior esquerdo grama

	# Faixas diagonais
	[[0,1],[1,0]]: Vector2i(2, 0),  # Faixa grama / (na terra)
	[[1,0],[0,1]]: Vector2i(3, 0),  # Faixa grama \ (na terra)
	# Note: As faixas de terra na grama usam as mesmas coordenadas invertidas
	# Será tratado na função get_tile_from_neighbors
}

# Função principal: recebe os 4 vizinhos e retorna a coordenada do tile
static func get_tile_from_neighbors(top_left: bool, top_right: bool, bottom_left: bool, bottom_right: bool) -> Vector2i:
	# Converte bools para int (true = grama = 1, false = terra = 0)
	var matrix = [
		[1 if top_left else 0, 1 if top_right else 0],
		[1 if bottom_left else 0, 1 if bottom_right else 0]
	]

	# Busca a matriz no dicionário
	var tile_coord = TILE_MATRICES.get(matrix)
	if tile_coord:
		return tile_coord

	# Se não encontrou, verifica se é uma faixa de terra na grama
	# (inversão das faixas de grama na terra)
	if matrix == [[1,0],[0,1]]:  # Seria faixa grama \, mas em contexto de terra na grama
		return Vector2i(2, 3)  # Faixa terra /
	elif matrix == [[0,1],[1,0]]:  # Seria faixa grama /, mas em contexto de terra na grama
		return Vector2i(3, 3)  # Faixa terra \

	# Fallback - retorna grama padrão
	return Vector2i(5, 1)

# Função auxiliar para determinar se uma posição é grama baseada no ruído
static func is_grass_from_noise(noise_value: float) -> bool:
	# Converte ruído contínuo (-1 a 1) para discreto (1 a 4)
	var discrete_value = int((noise_value + 1.0) * 2.0) + 1  # Mapeia -1..1 para 1..5
	discrete_value = clamp(discrete_value, 1, 4)  # Garante que fica entre 1 e 4

	# 1 e 2 = terra (false), 3 e 4 = grama (true)
	return discrete_value >= 3

# Função para obter tile baseado em posição e noise
static func get_tile_from_position(world_pos: Vector2i, noise: FastNoiseLite, _detail_noise: FastNoiseLite = null) -> Vector2i:
	# Teste simples: verifica só o centro do tile para ter mais blocos puros
	var center_noise = noise.get_noise_2d(world_pos.x, world_pos.y)
	var is_grass = is_grass_from_noise(center_noise)

	# Se é grama, retorna grama pura. Se é terra, retorna terra pura
	if is_grass:
		return Vector2i(5, 1)  # Grama pura
	else:
		return Vector2i(0, 0)  # Terra pura
