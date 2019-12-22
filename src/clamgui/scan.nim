import gintro / [gtk, gobject, glib]

import ../ clamcontrol / controller


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


  proc updateLabel(src: ptr IOChannel00, cond: IOCondition, data: pointer): gboolean {.cdecl.} =
    # var mydata = cast[cstring](src)
    # echo "scannin"
    # echo mydata
    echo cast[cstring](src)
  
  var
    procID: int
    stdInput: int
    stdOutput: int
    stdErr: int
  
  let scanResult = spawnAsyncWithPipes("/", ["/usr/bin/clamscan", "--no-summary", "-v", path], [], {doNotReapChild}, nil, nil, procID, stdInput, stdOutput, stdErr)

  let scanChannel = unixNew(stdOutput)
  discard ioAddWatch(scanChannel, 1, IOCondition.in, updateLabel, nil, nil)

  if not scanResult:
    scanLabel.setLabel("Scan failed")
  scanDialog.showAll
  

proc homeScan*(b: Button) =
  let path = "/home/dmknght/Templates/"
  # TODO handle stop
  scanController(path, b)

proc fullScan*(b: Button) =
  let path = "/"
  scanController(path, b, asRoot = true)