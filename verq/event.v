module verq

import x.json2 as json

struct GatewayEvent {
	opcode   int      @[json: op]
	raw_data json.Any @[json: d]
	sequence int      @[json: s]
	name     string   @[json: t]
}

type Data =
	HelloData |
	ReadyData |
	IdentityData

struct HelloData {
	heartbeat_interval int
}

struct ReadyData {
	version int @[json: v]
	user    User
}

struct IdentityData {
	token      string
	properties json.Any
	intents    int
}
