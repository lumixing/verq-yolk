import verq
import log
import env
import kv

struct Context {
mut:
	balance_db kv.Database
	items_db   kv.Database
	commands   []Command
}

interface Command {
	name       string
	aliases    []string
	call(mut client verq.Client, message verq.Message, args []string) !
}

fn main() {
	env_map := env.read_file('.env')!
	mut client := verq.Client.new(env_map['DISCORD_SECRET'])!

	client.on_ready_fn = fn () ! {
		log.info('Ready!')
	}

	context := Context {
		balance_db: kv.load('balance.db')!
		items_db: kv.load('items.db')!
		commands: [
			BalanceCommand{}
			BegCommand{}
			TopCommand{}
			FishCommand{}
			InventoryCommand{}
		]
	}

	client.context = voidptr(&context)

	client.on_message_fn = fn(mut client verq.Client, message verq.Message) ! {
		if is_bot := message.author.bot {
			if is_bot {
				return
			}
		}

		if !message.content.starts_with(';') {
			return
		}

		mut args := message.content.split(' ')
		cmd := args[0][1..]
		args.delete(0)
		args = args.filter(it.len > 0)

		mut ctx := unsafe { &Context(client.context) }

		mut no_commands := true

		for command in ctx.commands {
			if command.name == cmd || cmd in command.aliases {
				command.call(mut client, message, args)!
				no_commands = false
			}
		}

		if no_commands {
			message.reply(client, 'invalid command')!
		}
	}

	client.connect()!
}

pub fn format_thousands(n i64) string {
	if n == 0 {
		return '0'
	}

	mut num := if n < 0 { -n } else { n }
	mut result := []string{}
	
	for num > 0 {
		section := num % 1000
		num /= 1000
		
		if result.len == 0 {
			result << section.str()
		} else {
			result << '${section:03}'
		}
	}

	mut final := if n < 0 { '-' } else { '' }
	
	for i := result.len - 1; i >= 0; i-- {
		if i < result.len - 1 {
			final += ","
		}
		final += result[i]
	}
	
	return final
}