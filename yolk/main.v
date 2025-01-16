import verq
import log
import env
import kv
import rand
import strconv

struct Context {
mut:
	balance_db kv.Database
}

fn main() {
	env_map := env.read_file('.env')!
	mut client := verq.Client.new(env_map['DISCORD_SECRET'])!

	client.on_ready_fn = fn () ! {
		log.info('Ready!')
	}

	context := Context {
		balance_db: kv.load('balance.db')!
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

		match cmd {
			'balance', 'bal' {
				balance := ctx.balance_db.get(message.author.id) or {
					ctx.balance_db.set(message.author.id, '0')
					ctx.balance_db.save()!
					'0'
				}

				message.reply(client, 'you have \$$balance')!
			}
			'beg' {
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
			else {
				message.reply(client, 'unknown command!')!
			}
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