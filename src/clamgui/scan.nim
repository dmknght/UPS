import gintro/[gtk, glib, gobject]
import osproc
import streams

import ../ clamcontrol / controller

var
  globalChan: Channel[string]
  watcherThread: system.Thread[tuple[path: string]]

proc watchProc(interval: tuple[path: string]) {.thread.}= 
  # let path = "/home/dmknght/" # TODO edit here
  let scanner = startProcess("/usr/bin/clamscan", args = @["--no-summary", "-v", interval.path])
  var
    numClean = 0
    numThreat = 0
    
  while scanner.peekExitCode == -1:
    try:
      # TODO get status file
      globalChan.send(scanner.outputStream.readLine())
    except system.IOError:
      globalChan.send("Scan completed")
      # return

proc recvCb(scanLabel: Label): bool = 
  let data = globalChan.tryRecv()
  if data[0]:
    scanLabel.setText(data[1])
  return SOURCE_CONTINUE

proc scanController(path: string, b: Button, asRoot = false) =
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
  
  scanDialog.title = "Scanning " & path # TODO Custom scan or something else; add completed to title
  scanDialog.setDefaultSize(400, 100)

  discard timeoutAdd(70, recvCb, scanLabel)
  globalChan.open()
  createThread(watcherThread, watchProc, (path,))
  scanDialog.showAll
  
# TODO check for db before scan
proc homeScan*(b: Button) =
  let path = "/home/dmknght/Templates/"
  # TODO handle stop
  scanController(path, b)

proc fullScan*(b: Button) =
  let path = "/"
  scanController(path, b, asRoot = true)