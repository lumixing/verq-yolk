module kv

import x.json2 as json
import os

// todo: make db generic (json2decoder2 doesnt work for maps for some reason)
pub struct Database {
	path string
mut:
	db map[string]string
}

pub fn load(path string) !Database {
	if !os.is_file(path) {
		return Database{path, {}}
	}

	return Database{path, json.decode[map[string]string](os.read_file(path)!)!}
}

pub fn (mut db Database) set(key string, value string) {
	db.db[key] = value
}

pub fn (db Database) get(key string) !string {
	if key !in db.db {
		return error('Key "$key" not found in database "${db.path}"')
	}

	return db.db[key]
}

pub fn (mut db Database) delete(key string) ! {
	if key !in db.db {
		return error('Key "$key" not found in database "${db.path}"')
	}

	db.db.delete(key)
}

pub fn (db Database) save() ! {
	os.write_file(db.path, json.encode(db.db))!
}

pub fn (db Database) get_db() map[string]string {
	return db.db
}
