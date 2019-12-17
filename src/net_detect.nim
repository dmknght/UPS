import re
import os
import strutils


proc getNetIfaces(): seq[string] =
  let
    findInterface = re"([a-z0-9]+)\:"
    pathInterface = "/proc/net/dev"
    infInterface = readFile(pathInterface)

  echo "Gathering all network interfaces"
  return infInterface.findAll(findInterface)

# echo listInterfaces

let listInterfaces = getNetIfaces()
var listWlan: seq[string]

for i in listInterfaces.low .. listInterfaces.high:
  if "wlan" in listInterfaces[i]:
    listWlan.add(listInterfaces[i])

var netIface: string

if len(listWlan) != 1:
  echo "Can't get wireless network interface"
  netIface = readLine(stdin)

else:
  netIface = listWlan[0].replace(":", "")
  echo "Found wireless interface: " & netIface

echo "Turning monitor mode on"

discard execShellCmd("ip link set " & netIface & " down && iw " & netIface & " set monitor none && ip link set " & netIface & " up")

let newListIface = getNetIfaces()

var listMonInface: seq[string]

for i in newListIface.low .. newListIface.high:
  if newListIface[i] in listInterfaces:
   discard
  else:
    listMonInface.add(newListIface[i])

if len(listMonInface) != 1:
  echo "Can not detect monitor interface"

else:
  echo "The moitor interface is " & listMonInface[0]