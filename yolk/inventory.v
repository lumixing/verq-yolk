import verq
import x.json2 as json

pub struct InventoryCommand {
	name    string   = 'inventory'
	aliases []string = ['inv']
}

pub fn (cmd InventoryCommand) call(mut client verq.Client, message verq.Message, args []string) ! {
	mut ctx := unsafe { &Context(client.context) }

	inv_str := ctx.items_db.get(message.author.id) or { 
		ctx.items_db.set(message.author.id, '[]')
		ctx.items_db.save()!
		'[]'
	}

	raw_raw_inv := json.raw_decode(inv_str)!
	
	mut inv := []Item{}
	
	for raw_raw_item in raw_raw_inv as []json.Any {
		raw_item := json.decode[RawItem](json.encode(raw_raw_item))!
		inv << raw_item.to_item()!
	}

	mut inv_str_arr := []string{}

	for item_idx, item in inv {
		inv_str_arr << '${item_idx+1}\\\\. ${item.amount}x ${item.name} [$${item.value}]'
	}

	message.reply(client, inv_str_arr.join('\\n'))!
}

