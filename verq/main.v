module verq

import net.websocket as ws
import x.json2 as json
import log
import time

enum Opcode {
	dispatch      = 0
	heartbeat     = 1
	identity      = 2
	hello         = 10
	heartbeat_ack = 11
}

fn on_message(mut ws_client ws.Client, msg &ws.Message, mut client Client) ! {
	payload := msg.payload.bytestr()
	event := json.decode[GatewayEvent](payload)!
	if event.name != 'GUILD_CREATE' {
		log.info('<- $event')
	}

	opcode := unsafe { Opcode(event.opcode) }

	// todo: use ?int for event.sequence
	if opcode != .heartbeat_ack {
		client.last_sequence = event.sequence
	}

	match opcode {
		.hello {
			hello_data := json.decode[HelloData](event.raw_data.str())!
			
			spawn fn (mut client Client, heartbeat_interval int) ! {
				mut last_heartbeat := time.now()
				for {
					if time.now() - last_heartbeat >= time.millisecond * heartbeat_interval {
					// if time.now() - last_heartbeat >= time.millisecond * 5000 {
						last_heartbeat = time.now()

						heartbeat_event := GatewayEvent{
							opcode: int(Opcode.heartbeat)
							sequence: client.last_sequence
						}

						log.info('-> $heartbeat_event')
						client.ws_client.write_string(json.encode(heartbeat_event))!
					}
				}
			}(mut client, hello_data.heartbeat_interval)

			raw_identify_data := json.raw_decode(json.encode(client.identity_data()))!
			identity_event := GatewayEvent{
				opcode: int(Opcode.identity)
				raw_data: raw_identify_data
			}

			log.info('-> $identity_event')
			ws_client.write_string(json.encode(identity_event))!
		}
		.heartbeat_ack {
			log.info("Received heartbeat!")
		}
		.dispatch {
			if event.name == "READY" {
				if ready_fn := client.on_ready_fn {
					ready_fn()!
				}
			} else if event.name == "MESSAGE_CREATE" {
				message := json.decode[Message](event.raw_data.str())!
				client.message.try_push(message)
				if message_fn := client.on_message_fn {
					message_fn(mut client, message)!
				}
			} else {
				// println("unimpl dispatch ${event.name} $event")
			}
		}
		else {
			panic("unimpl $event")
		}
	}
}
