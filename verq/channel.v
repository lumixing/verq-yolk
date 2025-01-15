module verq

import x.json2 as json

pub struct Channel {
pub:
	id string
}

pub 
fn (channel Channel) create_message(client Client, content string) !Message {
	res := client.request(.post, '/channels/${channel.id}/messages', '{"content":"$content"}')!
	message := json.decode[Message](res)!

	return message
}
