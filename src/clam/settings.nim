import gintro / [gtk, gobject]

proc actionCancel(b: Button, d: Dialog) =
  d.destroy()

proc stnScan*(b: Button) =
  let
    setScanDialog = newDialog()
    boxOptions = newBox(Orientation.vertical, 3)
    boxButtons = newBox(Orientation.horizontal, 3)
    areaSetting = setScanDialog.getContentArea()
    btnDoPUA = newCheckButtonWithLabel("Scan for PUAs")
    btnDoByteCode = newCheckButtonWithLabel("Scan with bytecode signatures")
    btnDoRemoveInfected = newCheckButtonWithLabel("Auto remove infected files")
    btnDoMailFile = newCheckButtonWithLabel("Scan mail files")
    btnDoAlertEncrypted = newCheckButtonWithLabel("Alert encrypted archives and documents")
    btnHeuristicAlert = newCheckButtonWithLabel("Heuristic alerts")
    btnSave = newButton("Save settings")
    btnCancel = newButton("Cancel")
    imgSave = newImageFromIconName("dialog-ok", 3)
    imgCancel = newImageFromIconName("edit-clear", 3)

  boxOptions.packStart(btnDoRemoveInfected, false, true, 3)
  boxOptions.packStart(btnDoByteCode, false, true, 3)
  boxOptions.packStart(btnDoPUA, false, true, 3)
  boxOptions.packStart(btnDoMailFile, false, true, 3)
  boxOptions.packStart(btnHeuristicAlert, false, true, 3)
  boxOptions.packStart(btnDoAlertEncrypted, false, true, 3)

  btnSave.setImage(imgSave)
  btnCancel.setImage(imgCancel)

  btnCancel.connect("clicked", actionCancel, setScanDialog)

  boxButtons.packStart(btnSave, false, true, 3)
  boxButtons.packStart(btnCancel, false, true, 3)

  areaSetting.packStart(boxOptions, false, true, 3)
  areaSetting.packStart(boxButtons, false, true, 3)

  setScanDialog.title = "Scan Settings"
  setScanDialog.setDefaultSize(200, 100)
  setScanDialog.showAll

proc stnUpdate*(b: Button) =
  let
    updateDialog = newDialog()
    areaSetting = updateDialog.getContentArea()

    boxOptions = newBox(Orientation.vertical, 3)
    btnDoAutoUpdate = newCheckButtonWithLabel("Auto Update")
    btnDoProxy = newCheckButtonWithLabel("Use proxy")
    labelUpdate = newLabel("Auto update setting")
    labelProxy = newLabel("Proxy setting")

    boxButtons = newBox(Orientation.horizontal, 3)

    btnSave = newButton("Save settings")
    btnCancel = newButton("Cancel")
    imgSave = newImageFromIconName("gtk-ok", 3)
    imgCancel = newImageFromIconName("edit-clear", 3)

  labelUpdate.setXalign(0.0)
  labelProxy.setXalign(0.0)

  boxOptions.packStart(labelUpdate, false, true, 3)
  boxOptions.packStart(btnDoAutoUpdate, false, true, 3)
  boxOptions.packStart(labelProxy, false, true, 3)
  boxOptions.packStart(btnDoProxy, false, true, 3)
  areaSetting.packStart(boxOptions, false, true, 3)

  btnSave.setImage(imgSave)
  btnCancel.setImage(imgCancel)

  btnCancel.connect("clicked", actionCancel, updateDialog)

  boxButtons.packStart(btnSave, false, true, 3)
  boxButtons.packStart(btnCancel, false, true, 3)
  areaSetting.packStart(boxButtons, false, true, 3)

  updateDialog.title = "Update Settings"
  updateDialog.setDefaultSize(200, 100)
  updateDialog.showAll