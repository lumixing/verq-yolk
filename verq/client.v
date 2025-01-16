module verq

import net.websocket as ws
import x.json2 as json
import net.http
import log

type OnReadyFn = fn () !
type OnMessageFn = fn (mut client Client, message Message) !

pub struct Client {
	client_secret string
mut:
	ws_client     &ws.Client
	message       chan Message
	last_sequence int
pub mut:
	context       voidptr
	on_ready_fn   ?OnReadyFn
	on_message_fn ?OnMessageFn
}

pub fn Client.new(client_secret string) !Client {
	mut ws_client := ws.new_client('wss://gateway.discord.gg')!

	return Client {
		client_secret: client_secret
		ws_client: ws_client
	}
}

pub fn (mut client Client) connect() ! {
	client.ws_client.on_message_ref(on_message, client)
	client.ws_client.connect()!
	client.ws_client.listen()!
}

// change to Properties when x.json2 supports better custom keys
fn Client.properties() map[string]json.Any {
	mut props := map[string]json.Any{}

	props['\$os']      = 'linux'
	props['\$browser'] = 'verq'
	props['\$device']  = 'verq'

	return props
}

fn (client Client) identity_data() IdentityData {
	identity_data := IdentityData{
		token: client.client_secret
		properties: Client.properties()
		intents: 513
	}

	return identity_data
}

fn (client Client) request(method http.Method, path string, body string) !string {
	mut req := http.new_request(.post, 'https://discord.com/api$path', body)
	req.add_header(.authorization, 'Bot ${client.client_secret}')
	req.add_header(.content_type, 'application/json')
	res := req.do()!

	if res.status_code != 200 {
		log.error('Response is not OK: req: $req, res: $res')
	}

	return res.body
}
