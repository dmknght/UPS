import gintro / gtk

proc stnScan*(b: Button) =
  let
    setScanDialog = newDialog()
    boxButtons = newBox(Orientation.vertical, 3)
    areaSetting = setScanDialog.getContentArea()
    btnDoPUA = newCheckButtonWithLabel("Scan for PUAs")
    btnDoRemoveInfected = newCheckButtonWithLabel("Auto remove infected files")
    btnDoMailFile = newCheckButtonWithLabel("Scan mail files")
    btnHeuristicAlert = newCheckButtonWithLabel("Heuristic alerts")

  setScanDialog.title = "Scan Settings"
  setScanDialog.setDefaultSize(200, 100)

  boxButtons.packStart(btnDoRemoveInfected, false, true, 3)
  boxButtons.packStart(btnDoPUA, false, true, 3)
  boxButtons.packStart(btnDoMailFile, false, true, 3)
  boxButtons.packStart(btnHeuristicAlert, false, true, 3)

  areaSetting.packStart(boxButtons, false, true, 3)

  setScanDialog.showAll