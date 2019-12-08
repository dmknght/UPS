import gintro / [gtk, gobject]

import strutils # Test only
import ../ clamcontrol / controller
import osproc
import streams


proc scan(path: string, b: Button, asRoot = false) =
  let
    scanDialog = newDialog()
    boxButtons = newBox(Orientation.horizontal, 3)
    # scanned = newLabel("File scanned: ")
    # Threats = newLabel("Threats: ")
    scanProgress = newProgressBar()
    areaScan = scanDialog.getContentArea()
    btnStop = newButton("Stop")
    btnHide = newButton("Hide")
    # Image variables
    imgStop = newImageFromIconName("exit", 3) # if not compelted else dialog-yes
    imgMinimize = newImageFromIconName("go-down", 3)
    # TODO minimize button
    p = startProcess(command = "/usr/bin/clamscan", args = ["--no-summary", "-v", path])
    # PROCESS RUN UNTIL IT STOP AND THE WINDOWS SHOW
    # pid = p.processID()
  var
    scanLabel = newLabel("Preparing") # TODO status here: preparing / scanning / completed

  scanDialog.queueDraw()
  scanLabel.setXalign(0.0)

  # Set image for buttons
  btnStop.setImage(imgStop)
  btnStop.connect("clicked", controller.actionStop, p)
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
  
  # let
  #   # p = startProcess(command = "/usr/bin/clamscan", args = ["--no-summary", "-v", path])
  #   msg = outputStream(p)
  # var line = ""
  # while msg.readLine(line):
  #   scanLabel.setLabel(line)
  p.close()

  # btnStop.connect("clicked", controller.actionStop, p)
  scanDialog.showAll
  
  # let testValue = p.outputStream()
  # var line: string
  # while testValue.readLine(line):
  #   scanLabel.label = line


proc quickScan*(b: Button) =
  let path = "/home/dmknght/Templates/"
  # TODO handle stop
  scan(path, b)

proc fullScan*(b: Button) =
  let path = "/"
  scan(path, b, asRoot = true)