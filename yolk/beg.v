import verq
import rand
import strconv

pub struct BegCommand {
	name    string   = 'beg'
	aliases []string
}

pub fn (cmd BegCommand) call(mut client verq.Client, message verq.Message, args []string) ! {
	mut ctx := unsafe { &Context(client.context) }

	amount := rand.u32_in_range(0, 1_000_000)!

	balance := ctx.balance_db.get(message.author.id) or {
		ctx.balance_db.set(message.author.id, '0')
		'0'
	}

	mut parsed_balance := strconv.parse_uint(balance, 10, 32)!
	parsed_balance += amount

	ctx.balance_db.set(message.author.id, '$parsed_balance')
	ctx.balance_db.save()!
	message.reply(client, 'you begged for \$$amount\\nyou now have \$${format_thousands(parsed_balance)}')!
}

