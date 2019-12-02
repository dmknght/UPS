import gintro / gtk

proc stnScan*(b: Button) =
  let
    setScanDialog = newDialog()
    boxButtons = newBox(Orientation.vertical, 3)
    areaSetting = setScanDialog.getContentArea()
    btnDoPUA = newCheckButtonWithLabel("Scan for PUAs")
    btnDoByteCode = newCheckButtonWithLabel("Scan with bytecode signatures")
    btnDoRemoveInfected = newCheckButtonWithLabel("Auto remove infected files")
    btnDoMailFile = newCheckButtonWithLabel("Scan mail files")
    btnDoAlertEncrypted = newCheckButtonWithLabel("Alert encrypted archives and documents")
    btnHeuristicAlert = newCheckButtonWithLabel("Heuristic alerts")

  setScanDialog.title = "Scan Settings"
  setScanDialog.setDefaultSize(200, 100)

  boxButtons.packStart(btnDoRemoveInfected, false, true, 3)
  boxButtons.packStart(btnDoByteCode, false, true, 3)
  boxButtons.packStart(btnDoPUA, false, true, 3)
  boxButtons.packStart(btnDoMailFile, false, true, 3)
  boxButtons.packStart(btnHeuristicAlert, false, true, 3)
  boxButtons.packStart(btnDoAlertEncrypted, false, true, 3)

  areaSetting.packStart(boxButtons, false, true, 3)

  setScanDialog.showAll