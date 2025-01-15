module verq

import time
import x.json2 as json

pub struct Message {
pub:
	content    string
	timestamp  time.Time
	id         string
	channel_id string
	author     User
}

pub fn (message Message) reply(client Client, content string) !Message {
	body := '{"content":"$content", "message_reference": {"message_id": "${message.id}", "fail_if_not_exists": false}}'
	res := client.request(.post, '/channels/${message.channel_id}/messages', body)!
	message_reply := json.decode[Message](res)!

	return message_reply
}
