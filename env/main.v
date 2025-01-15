module env

import os

pub fn read_file(path string) !map[string]string {
	mut m := map[string]string{}

	for line in os.read_lines(path)! {
		if line == '' || line.starts_with('#') {
			continue
		}

		elems := line.split('=')
		key := elems[0]
		value := elems[1]

		m[key] = value
	}

	return m
}
