import gintro / gtk

# proc uiScan(scanW)

proc scan(path: string, b: Button, asRoot = false) =
  let
    labelScan = "Scanning"
    btnStop = newButton("Stop")
    scanDialog = newDialog()
  scanDialog.title = "Scanning"
  scanDialog.setDefaultSize(200, 200)
  scanDialog.add(btnSTop)
  # scanDialog.add(labelScan)
  scanDialog.showAll



proc quickScan*(b: Button) =
  let path = "$HOME"
  # TODO handle stop
  scan(path, b)

proc fullScan*(b: Button) =
  let path = "/"
  scan(path, b, asRoot = true)