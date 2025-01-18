import x.json2 as json

interface Item {
	name   string
	value  int
	amount int
	raw_item() !RawItem
}

pub struct RawItem {
	kind string
	data json.Any
}

fn (raw_item RawItem) to_item() !Item {
	return match raw_item.kind {
		"Fish" {
			fish := json.decode[Fish](json.encode(raw_item.data))!
			Item(fish)
		}
		else {
			error('unknown raw item kind: ${raw_item.kind} $raw_item')
		}
	}
}