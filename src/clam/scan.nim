import gintro / gtk

# proc uiScan(scanW)

proc scan(path: string, b: Button, asRoot = false) =
  let
    scanDialog = newDialog()
    actionStop = scanDialog.addButton("Stop", 0)

  scanDialog.title = "Scanning"
  scanDialog.setDefaultSize(400, 100)
  scanDialog.showAll


proc quickScan*(b: Button) =
  let path = "$HOME"
  # TODO handle stop
  scan(path, b)

proc fullScan*(b: Button) =
  let path = "/"
  scan(path, b, asRoot = true)