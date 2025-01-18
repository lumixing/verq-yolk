import verq

pub struct BalanceCommand {
	name    string   = 'balance'
	aliases []string = ['bal']
}

pub fn (cmd BalanceCommand) call(mut client verq.Client, message verq.Message, args []string) ! {
	mut ctx := unsafe { &Context(client.context) }

	mut user_id := message.author.id

	if args.len > 0 {
		first := args[0]
		if first.starts_with('<@') && first.ends_with('>') {
			user_id = first[2..first.len-1]
			println('$first -> $user_id')
		} else {
			message.reply(client, 'expected user mention as first argument!')!
			return
		}
	}

	balance := ctx.balance_db.get(user_id) or {
		ctx.balance_db.set(user_id, '0')
		ctx.balance_db.save()!
		'0'
	}

	content := if user_id == message.author.id {
		'you have \$$balance'
	} else {
		'<@$user_id> has \$$balance'
	}
	message.reply(client, content)!
}

