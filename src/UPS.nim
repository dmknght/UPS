# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import strutils, re

proc convert_unix_addr(hex_addr: string): string = 
  # Little endian
  var
    ip_addr = hex_addr.split(":")[0]
    port_addr = hex_addr.split(":")[1]
  ip_addr = intToStr(parseHexInt(ip_addr[6 .. 7])) & "." & intToStr(parseHexInt(ip_addr[4 .. 5])) & "." & intToStr(parseHexInt(ip_addr[2 .. 3])) & "." & intToStr(parseHexInt(ip_addr[0 .. 1]))
  port_addr = intToStr(parseHexInt(port_addr))
  return ip_addr & ":" & port_addr

proc parse_proto() =
  const entry_path = "/proc/net/"
  var protocols = ["arp", "tcp", "udp"]
  let current_entry = entry_path & protocols[1]
  let mon_data = readFile(current_entry) # TODO vulnerable here
  for line in mon_data.split("\n")[1 .. len(mon_data.split("\n")) - 1]:
    let result = line.findAll(re"(\S+)")
    if len(result) > 1:
      var
        nid = result[0]
        local_addr = convert_unix_addr(result[1])
        remote_addr = convert_unix_addr(result[2])
        state = result[3]
        uid = result[7]
      echo local_addr & " -> " & remote_addr
parse_proto()
