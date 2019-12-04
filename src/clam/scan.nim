import gintro / gtk

# proc uiScan(scanW)

proc scan(path: string, b: Button, asRoot = false) =
  let
    scanDialog = newDialog()
    scanLabel = newLabel("Scanning") # TODO status here: preparing / scanning / completed
    boxButtons = newBox(Orientation.horizontal, 3)
    # scanned = newLabel("File scanned: ")
    # Threats = newLabel("Threats: ")
    scanProgress = newProgressBar()
    areaScan = scanDialog.getContentArea()
    btnStop = newButton("Stop")
    btnMinimize = newButton("Hide")
    # Image variables
    imgStop = newImageFromIconName("exit", 3) # if not compelted else dialog-yes
    imgMinimize = newImageFromIconName("go-down", 3)
    # TODO minimize button

  scanLabel.setXalign(0.0)

  # Set image for buttons
  btnStop.setImage(imgStop)
  btnMinimize.setImage(imgMinimize)

  boxButtons.packStart(btnMinimize, false, true, 3)
  boxButtons.packStart(btnStop, false, true, 3)

  areaScan.packStart(scanLabel, false, true, 3)
  areaScan.packStart(scanProgress, false, true, 9)
  areaScan.packStart(boxButtons, false, true, 0)
  
  scanDialog.title = "Scanning " & path # TODO Custom scan or something else; add completed to title
  scanDialog.setDefaultSize(400, 100)
  scanDialog.showAll


proc quickScan*(b: Button) =
  let path = "$HOME"
  # TODO handle stop
  scan(path, b)

proc fullScan*(b: Button) =
  let path = "/"
  scan(path, b, asRoot = true)