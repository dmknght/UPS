# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import strutils, re

proc convert_unix_addr(hex_addr: string) = 
  let ip_addr, port_addr = hex_addr.split(":")
  echo ip_addr
  echo port_addr

proc parse_proto() =
  const entry_path = "/proc/net/"
  var protocols = ["arp", "tcp", "udp"]
  let current_entry = entry_path & protocols[1]
  let mon_data = readFile(current_entry)
  for line in mon_data.split("\n")[1 .. len(mon_data.split("\n")) - 1]:
    let result = line.findAll(re"(\S+)")
    if len(result) > 1:
      var
        nid = result[0]
        local_addr = result[1]
        remote_addr = result[2]
        state = result[3]
        uid = result[7]
      convert_unix_addr(local_addr)

parse_proto()
