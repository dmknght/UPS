import gintro/[gtk, glib, gobject]
import osproc
import streams
import strutils

import ../ clamcontrol / controller

var
  globalChan: Channel[string]
  watcherThread: system.Thread[tuple[path: string]]

# TODO handle multiple threads

proc watchProc(interval: tuple[path: string]) {.thread.} =
  let scanner = startProcess("/usr/bin/clamscan", args = @["--no-summary", "-v", interval.path])
  var
    numScan = 0
    numClean = 0
    numInfect = 0
    
  while scanner.peekExitCode == -1:
    try:
      let scanResult = scanner.outputStream.readLine()
      if scanResult.split(" ")[0] == "Scanning":
        numScan += 1
        globalChan.send(scanResult)
      elif scanResult.split(" ")[^1] == "OK":
        numClean += 1 
      elif scanResult.split(" ")[^1] == "FOUND":
        numInfect += 1 
        # TODO malware type = scanResult.split(" ")[^2]
    except system.IOError:
      let msg = "Scan completed!\nScanned: " & intToStr(numScan) & " Clean: " & intToStr(numClean) & " Found: " & intToStr(numInfect)
      globalChan.send(msg)

proc recvCb(scanLabel: Label): bool = 
  let data = globalChan.tryRecv()
  if data[0]:
    scanLabel.setText(data[1])
  return SOURCE_CONTINUE

proc createScan(path: string, title: string, b: Button, asRoot = false) =
  let
    scanDialog = newDialog()
    scanLabel = newLabel("Preparing")
    boxButtons = newBox(Orientation.horizontal, 3)
    scanProgress = newProgressBar()
    areaScan = scanDialog.getContentArea()
    btnStop = newButton("Stop")
    btnHide = newButton("Hide")
    # Image variables
    imgStop = newImageFromIconName("exit", 3) # if not compelted else dialog-yes
    imgMinimize = newImageFromIconName("go-down", 3)

  
  scanLabel.setXalign(0.0)
  
  # Set image for buttons
  btnStop.setImage(imgStop)
  # btnStop.connect("clicked", controller.actionStop, p)
  # TODO bug when process is completed. Close is above
  # TODO cancel or do something close windoww
  btnHide.setImage(imgMinimize)
  btnHide.connect("clicked", controller.actionHide, scanDialog)

  boxButtons.packStart(btnHide, false, true, 3)
  boxButtons.packStart(btnStop, false, true, 3)

  areaScan.packStart(scanLabel, false, true, 3)
  areaScan.packStart(scanProgress, false, true, 9)
  areaScan.packStart(boxButtons, false, true, 0)
  
  scanDialog.title = title
  scanDialog.setDefaultSize(400, 100)

  discard timeoutAdd(70, recvCb, scanLabel)
  # TODO handle multiple channels
  globalChan.open()
  createThread(watcherThread, watchProc, (path,))
  scanDialog.showAll
  
proc homeScan*(b: Button) =
  # TODO get environment path
  let
    path = glib.getHomeDir()
    title = "Scanning " & path
  # TODO handle stop
  createScan(path, title, b)

proc fullScan*(b: Button) =
  let
    path = "/"
    title = "Scanning System"
  createScan(path, title, b, asRoot = true)

proc customScan*(b: Button) =
  let
    path = "/home"
    # TODO edit path to list of files / folders
    title = "Custom Scan"
  createScan(path, title, b, asRoot = false)