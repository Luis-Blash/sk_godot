class_name MapGenerator
extends RefCounted

# Genera el mapa de la mazmorra como datos puros (no toca nodos ni escenas).
# El DungeonManager le pide un mapa y luego instancia las salas.

# La sala de inicio siempre nace aqui.
const START := Vector2i(0, 0)

## Devuelve un { Vector2i: String } con las reglas del dungeon:
## 1 inicio, 1 jefe, `treasure_count` tesoros y el resto normales.
## `total_rooms` incluye inicio y jefe. Usa `rng` para ser reproducible.
static func generate(total_rooms: int, treasure_count: int, rng: RandomNumberGenerator) -> Dictionary:
	var cells: Array = _grow_cells(total_rooms, rng)

	# Todas arrancan como normales; luego marcamos los casos especiales.
	var map: Dictionary = {}
	for c in cells:
		map[c] = "normal"
	map[START] = "inicio"

	# El jefe va en la celda mas lejana del inicio (final del recorrido).
	var boss: Vector2i = _farthest_cell(cells)
	map[boss] = "jefe"

	# Los tesoros se reparten entre las celdas normales restantes.
	var candidates: Array = cells.duplicate()
	candidates.erase(START)
	candidates.erase(boss)
	_shuffle(candidates, rng)
	for i in min(treasure_count, candidates.size()):
		map[candidates[i]] = "tesoro"

	return map

## Hace crecer un blob conexo de celdas con un random walk hasta `total`.
static func _grow_cells(total: int, rng: RandomNumberGenerator) -> Array:
	var cells: Array = [START]
	var placed: Dictionary = {START: true}
	while cells.size() < total:
		# Elegimos una celda existente y le pegamos una vecina libre.
		var base: Vector2i = cells[rng.randi() % cells.size()]
		var dirs: Array = Directions.ALL.duplicate()
		_shuffle(dirs, rng)
		for d in dirs:
			var next: Vector2i = base + d
			if not placed.has(next):
				cells.append(next)
				placed[next] = true
				break
	return cells

## BFS desde el inicio para encontrar la celda mas lejana (en pasos).
static func _farthest_cell(cells: Array) -> Vector2i:
	var placed: Dictionary = {}
	for c in cells:
		placed[c] = true
	var dist: Dictionary = {START: 0}
	var queue: Array = [START]
	var farthest: Vector2i = START
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		for d in Directions.ALL:
			var nb: Vector2i = cur + d
			if placed.has(nb) and not dist.has(nb):
				dist[nb] = dist[cur] + 1
				if dist[nb] > dist[farthest]:
					farthest = nb
				queue.append(nb)
	return farthest

## Fisher-Yates con nuestro rng (Array.shuffle() usa el RNG global y romperia
## la reproducibilidad de la seed).
static func _shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j: int = rng.randi() % (i + 1)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
