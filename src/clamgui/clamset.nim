import gintro / [gtk, gobject, gtksource]
import ../ clamcontrol / controller

type
  clamSettings = object
    setProxy: bool

var userSettings = clamSettings(setProxy: false) # TODO template only. Edit with real settings

proc actionSetProxy(b: CheckButton, txtValues: tuple)=
  let (txtAddr, txtPort) = txtValues

  if userSettings.setProxy == false:
    userSettings.setProxy = true
    txtAddr.can_focus = true
    txtPort.can_focus = true
  else:
    userSettings.setProxy = false
    txtAddr.can_focus = false
    txtPort.can_focus = false

proc setUpdate(b: Box) =
  # TODO fix border of txtAddr and txtPort or change object
  let
    boxSettings = newBox(Orientation.vertical, 3)
    btnDoAutoUpdate = newCheckButtonWithLabel("Auto Update")
    btnDoProxy = newCheckButton()
    labelUpdate = newLabel("Auto update setting")
    labelProxy = newLabel("Proxy setting")

    addrBox = newBox(Orientation.vertical, 0)
    labelAddr = newLabel("Address")
    txtAddr = newView()
    labelPort = newLabel("Port")
    txtPort = newView()

  labelUpdate.setXalign(0.0)
  labelProxy.setXalign(0.0)

  btnDoProxy.label = "Use Proxy"
  btnDoProxy.connect("toggled", actionSetProxy, (txtAddr, txtPort))

  boxSettings.packStart(labelUpdate, false, true, 3)
  boxSettings.packStart(btnDoAutoUpdate, false, true, 3)
  boxSettings.packStart(labelProxy, false, true, 3)
  boxSettings.packStart(btnDoProxy, false, true, 3)

  labelAddr.setXalign(0.0)
  labelPort.setXalign(0.0)

  if userSettings.setProxy == false:
    txtAddr.can_focus = false
    txtPort.can_focus = false
  else:
    txtAddr.can_focus = true
    txtPort.can_focus = true

  addrBox.packStart(labelAddr, false, true, 0)
  addrBox.packStart(txtAddr, false, true, 6)
  addrBox.packStart(labelPort, false, true, 0)
  addrBox.packStart(txtPort, false, true, 6)

  b.packStart(boxSettings, false, true, 3)
  b.packStart(addrBox, false, true, 3)


proc setScan(b: Box) =
  let
    boxSettings = newBox(Orientation.vertical, 3)
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

  boxSettings.packStart(btnDoRemoveInfected, false, true, 3)
  boxSettings.packStart(btnDoByteCode, false, true, 3)
  boxSettings.packStart(btnDoPUA, false, true, 3)
  boxSettings.packStart(btnDoMailFile, false, true, 3)
  boxSettings.packStart(btnHeuristicAlert, false, true, 3)
  boxSettings.packStart(btnDoAlertEncrypted, false, true, 3)

  btnSave.setImage(imgSave)
  btnCancel.setImage(imgCancel)

  b.packStart(boxSettings, false, true, 3)


proc popSettings*(b: Button) =
  let
    setDialog = newDialog()
    areaSet = setDialog.getContentArea()
    setController = newNotebook()

    boxSetScan = newBox(Orientation.vertical, 3)
    boxSetUpdate = newBox(Orientation.vertical, 3)

    boxButtons = newBox(Orientation.horizontal, 3)
    btnCancel = newButton("Cancel")
    btnSave = newButton("Save")
    imgSave = newImageFromIconName("dialog-ok", 3)
    imgCancel = newImageFromIconName("edit-clear", 3)

  btnSave.setImage(imgSave)
  btnCancel.setImage(imgCancel)

  btnCancel.connect("clicked", controller.actionCancel, setDialog)

  boxButtons.packStart(btnSave, false, true, 3)
  boxButtons.packStart(btnCancel, false, true, 3)

  setDialog.setTitle("ClamAV Settings")

  setScan(boxSetScan)
  discard setController.appendPage(boxSetScan)
  setController.setTabLabelText(boxSetScan, "Scan Settings")

  setUpdate(boxSetUpdate)
  discard setController.appendPage(boxSetUpdate)
  setController.setTabLabelText(boxSetUpdate, "Update Settings")
  areaSet.packStart(setController, false, true, 3)
  areaSet.packStart(boxButtons, false, true, 3)

  setDialog.showAll

  