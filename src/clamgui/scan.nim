import gintro / [gtk, gobject, glib]

# import strutils # Test only
import ../ clamcontrol / controller
# import osproc
# import streams


# proc scan(scanLabel: Label) =
#   let
#     path = "/home/dmknght/" # TODO edit here. Must be tuple or some shit
#     p = startProcess(command = "/usr/bin/clamscan", args = ["--no-summary", "-v", path])
#     msg = outputStream(p)
  
#   var line = ""
#   # let
#   #   # p = startProcess(command = "/usr/bin/clamscan", args = ["--no-summary", "-v", path])
#   #   msg = outputStream(p)
#   # var line = ""
#   # while msg.readLine(line):
#   #   scanLabel.setLabel(line)

#    # while p.running():
#   while msg.readLine(line):
#     scanLabel.setLabel(line)
#   #   scanDialog.queueDraw()
#   #   while eventsPending():
#   #     if not mainIteration():
#   #       echo line
#   #       scanLabel.setLabel(line)
#   #       scanDialog.queueDraw()
#   p.close()

# proc updateLabel(l: Label, t: string) =
#   l.setLabel(t)

# proc initScan(d: Dialog): bool =
#   queueDraw(d)
#   return SOURCE_CONTINUE

proc scanController(path: string, b: Button, asRoot = false) =
  let
    scanDialog = newDialog()
    scanLabel = newLabel("Preparing") # TODO status here: preparing / scanning / completed
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
    # p = startProcess(command = "/usr/bin/clamscan", args = ["--no-summary", "-v", path])
    # PROCESS RUN UNTIL IT STOP AND THE WINDOWS SHOW
    # pid = p.processID()
    # command = ["/usr/bin/clamscan", "--no-summary", "-v", path]
  
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
    var mydata = cast[cstring](src)
    echo mydata
  
  var
    procID: int
    stdInput: int
    stdOutput: int
    stdErr: int
  
  let scanResult = spawnAsyncWithPipes("/", ["/usr/bin/clamscan", "--no-summary", "-v", "--stdout", path], [], {doNotReapChild}, nil, nil, procID, stdInput, stdOutput, stdErr)

  let scanChannel = unixNew(stdOutput)
  let scanStream = ioAddWatch(scanChannel, 1, IOCondition.in, updateLabel, nil, nil)

  if not scanResult:
    scanLabel.setLabel("Scan failed")
  scanDialog.showAll
  

proc quickScan*(b: Button) =
  let path = "/home/dmknght/Templates/"
  # b.setLabel("Scanning Home") # TODO restore label
  # TODO handle stop
  scanController(path, b)

proc fullScan*(b: Button) =
  let path = "/"
  scanController(path, b, asRoot = true)