import verq

pub struct BalanceCommand {
	name    string   = 'balance'
	aliases []string = ['bal']
}

pub fn (cmd BalanceCommand) call(mut client verq.Client, message verq.Message, args []string) ! {
	mut ctx := unsafe { &Context(client.context) }

	balance := ctx.balance_db.get(message.author.id) or {
		ctx.balance_db.set(message.author.id, '0')
		ctx.balance_db.save()!
		'0'
	}

	message.reply(client, 'you have \$$balance')!
}

