import verq
import rand

pub struct FishCommand {
	name    string   = 'fish'
	aliases []string
}

struct Fish {
	name   string
	value  int
	amount int = 1

	rarity   FishRarity
	trait    FishTrait
	size     f32
	size_str string
}

fn Fish.new() Fish {
	rarity := FishRarity.new()
	trait := FishTrait.new()
	fish_data := FishData.new(rarity)
	// size_mod := rand.normal(mu: 1, sigma: 0.5) or { panic(err) }
	size_mod := rand.f32()
	size := fish_data.base_size * ((size_mod * 2) + 1)

	return Fish{
		name: fish_data.name
		value: int(f32(rarity.value() * trait.value()) * ((size_mod * 2) + 1))
		rarity: rarity
		trait: trait
		size: size
		size_str: Fish.size_name(f32(size_mod))
	}
}

fn Fish.size_name(base_size f32) string {
	return if base_size < 0.03 { "microscopic" }
	else if base_size < 0.15 { "tiny" }
	else if base_size < 0.3 { "small" }
	else if base_size < 0.7 { "average" }
	else if base_size < 0.85 { "large" }
	else if base_size < 0.97 { "huge" }
	else { "monumental" }
}

fn (fish Fish) string_name() string {
	mut elems := []string{}
	match fish.trait {
		.normal {}
		.enchanted { elems << '<a:enchanted:1330240539307802736> enchanted' }
		.ethereal { elems << '<a:ethereal:1330241775897415682> ethereal' }
	}
	if fish.rarity != .common { elems << '${fish.rarity}' }
	elems << '${fish.size_str}'
	elems << '${fish.name}'
	elems << '(${fish.size:.2}cm)'
	elems << '[$${fish.value}]'

	return elems.join(' ')
}

struct FishData {
	name      string
	base_size f32
}

fn FishData.new(rarity FishRarity) FishData {
	fish_data_arr := match rarity {
		.common { common_fish_data }
		.rare { rare_fish_data }
		.epic { epic_fish_data }
		.legendary { legendary_fish_data }
	}

	return rand.element(fish_data_arr) or { panic(err) }
}

const common_fish_data := [
	FishData{'cod', 30}
	FishData{'clownfish', 10}
	FishData{'sunfish', 12}
	FishData{'bluegill', 15}
]

const rare_fish_data := [
	FishData{'salmon', 70}
	FishData{'trout', 40}
	FishData{'bass', 50}
]

const epic_fish_data := [
	FishData{'tune', 150}
	FishData{'swordfish', 200}
]

const legendary_fish_data := [
	FishData{'shark', 127}
]

enum FishRarity {
	common
	rare
	epic
	legendary
}

fn FishRarity.new() FishRarity {
	rng := rand.f32()
	return if rng < 0.01 { .legendary }
	else if rng < 0.06 { .epic }
	else if rng < 0.21 { .rare }
	else { .common }
}

fn (rarity FishRarity) value() int {
	return match rarity {
		.common { 100 }
		.rare { 1000 }
		.epic { 10000 }
		.legendary { 100000 }
	}
}

enum FishTrait {
	normal
	enchanted
	ethereal
}

fn FishTrait.new() FishTrait {
	rng := rand.f32()
	return if rng < 0.01 { .ethereal }
	else if rng < 0.06 { .enchanted }
	else { .normal }
}

fn (trait FishTrait) value() int {
	return match trait {
		.normal { 1 }
		.enchanted { 15 }
		.ethereal { 100 }
	}
}

pub fn (cmd FishCommand) call(mut client verq.Client, message verq.Message, args []string) ! {
	mut ctx := unsafe { &Context(client.context) }

	mut fish_arr := []Fish{}
	for _ in 0..50 {
		fish := Fish.new()
		fish_arr << fish
	}

	fish_arr.sort(a.value < b.value)
	fish_names := fish_arr.map(it.string_name())

	message.reply(client, fish_names.join('\\n'))!
}

