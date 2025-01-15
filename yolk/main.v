import verq
import log
import env

fn main() {
	env_map := env.read_file(".env")!
	mut client := verq.Client.new(env_map['DISCORD_SECRET'])!

	client.on_ready_fn = fn () ! {
		log.info("Ready!")
	}

	client.on_message_fn = fn(mut client verq.Client, message verq.Message) ! {
		if message.content == ';ping' {
			message.reply(client, 'pong!')!
		}
	}

	client.connect()!
}
