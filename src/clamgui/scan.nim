import gintro/[gtk, glib, gobject]
import osproc
import streams
import strutils

import utils

type
  Scanner = object
    stdChannel: Channel[string]
    scanPath: string # TODO edit here for custom scan
    scanTitle: string
    mainThread: system.Thread[tuple[objScan: ref Scanner]]
    options: seq[string]
    # TODO is root

var
  objHomeScan: ref Scanner = new(Scanner)
  objFullScan: ref Scanner = new(Scanner)
  globalChannel: Channel[string]


proc procScanner(argv: tuple[objScan: ref Scanner]) {.gcsafe.} =
  # TODO craft options and pass args
  let scanner = startProcess("/usr/bin/clamscan", args = @["--no-summary", "-v", "-r", argv.objScan.scanPath])
  var
    numScan = 0
    numClean = 0
    numInfect = 0
    
  while scanner.peekExitCode == -1:
    try:
      let scanResult = scanner.outputStream.readLine()
      if scanResult.split(" ")[0] == "Scanning":
        numScan += 1
        # argv.objScan.stdChannel.send("Scanning " & scanResult.split("/")[^1])
        globalChannel.send("Scanning " & scanResult.split("/")[^1])
      elif scanResult.split(" ")[^1] == "OK":
        numClean += 1 
      elif scanResult.split(" ")[^1] == "FOUND":
        numInfect += 1 
        # TODO malware type = scanResult.split(" ")[^2]
    except system.IOError:
      let msg = "Scan completed!\nScanned: " & intToStr(numScan) & " Clean: " & intToStr(numClean) & " Found: " & intToStr(numInfect)
      # argv.objScan.stdChannel.send(msg)
      globalChannel.send(msg)


# proc scanPipe(argv: tuple[scanLabel: Label, objScanner: ref Scanner]): bool = 
proc scanPipe(scanLabel: Label): bool = 
  # let data = argv.objScanner.stdChannel.tryRecv()
  let data = globalChannel.tryRecv()
  if data[0]:
    # argv.scanLabel.setText(data[1])
    scanLabel.setText(data[1])
  return SOURCE_CONTINUE


proc createScan(b: Button, scanObj: ref Scanner) =
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
  scanLabel.setLineWrap(true)
  scanLabel.setMaxWidthChars(30)
  
  # Set image for buttons
  btnStop.setImage(imgStop)
  # btnStop.connect("clicked", controller.actionStop, p)
  # TODO bug when process is completed. Close is above
  # TODO cancel or do something close windoww
  btnHide.setImage(imgMinimize)
  btnHide.connect("clicked", utils.actionHide, scanDialog)

  boxButtons.packStart(btnHide, false, true, 3)
  boxButtons.packStart(btnStop, false, true, 3)

  areaScan.packStart(scanLabel, false, true, 3)
  areaScan.packStart(scanProgress, false, true, 9)
  areaScan.packStart(boxButtons, false, true, 0)
  
  scanDialog.title = scanObj.scanTitle
  scanDialog.setDefaultSize(400, 100)

  discard timeoutAdd(5, scanPipe, scanLabel)
  # TODO handle multiple channels
  # scanObj.stdChannel.open()
  globalChannel.open()
  if not objHomeScan.mainThread.running():
    createThread(scanObj.mainThread, procScanner, (scanObj,))
  else:
    discard # echo "It is running in background"
  scanDialog.showAll


proc homeScan*(b: Button) =
  # TODO get environment path
  # let
  #   path = glib.getHomeDir() & "/Templates" # TODO edit here
  #   title = "Scanning " & path

  #   threadHomeScan = Scanner(
  #     isRunning: false,
  #     stdChannel: Channel[string],
  #     path: glib.getHomeDir() & "/Templates",
  #     title: "Scanning " & path,
  #     mainThread: system.Thread[tuple[path: string]],
  #     options: seq[string]
  #   )
  # # TODO handle stop
  objHomeScan.scanPath = glib.getHomeDir() & "/Templates"
  objHomeScan.scanTitle = "Scanning " & objHomeScan.scanPath
  createScan(b, objHomeScan)


proc fullScan*(b: Button) =
  objFullScan.scanPath = glib.getHomeDir() & "/Documents"
  objFullScan.scanTitle = "Scanning " & objFullScan.scanPath
  createScan(b, objFullScan) # TODO edit obj here


proc customScan*(b: Button) =
  let
    path = "/home"
    # TODO edit path to list of files / folders
    title = "Custom Scan"
  createScan(b, objHomeScan) # TODO edit obj here
