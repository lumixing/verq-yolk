import verq
import maps
import strconv

pub struct TopCommand {
	name    string   = 'top'
	aliases []string
}

struct Balance {
	user_id string
	balance u64
}

pub fn (cmd TopCommand) call(mut client verq.Client, message verq.Message, args []string) ! {
	mut ctx := unsafe { &Context(client.context) }

	mut balances := maps.to_array[string, string, Balance](ctx.balance_db.get_db(), fn (k string, v string) Balance {
		return Balance{k, strconv.parse_uint(v, 10, 32) or {0}}
	})

	balances.sort(b.balance < a.balance)

	message.reply(client, balances.map('${it.user_id}: ${it.balance}').join('\\n'))!
}

