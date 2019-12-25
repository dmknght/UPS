import gintro / [gtk, gobject, gtksource]
import utils
import parsecfg
import os


var clamSettings: Config
let
  mainFolder = getHomeDir() & ".secenter"
  historyFolder = mainFolder & "/history"
  quaratineFolder = mainFolder & "/quaratine"
  configFile = mainFolder & "/settings.conf"

# TODO 1 save button for multiple save settings
# TODO global or local var for folders and files of config?

proc createDefaultSettings() =
  var
    defSettings = newConfig() # type: Config
  defSettings.setSectionKey("Scan", "ScanByteCode", "1")
  defSettings.setSectionKey("Scan", "ScanPUA", "1")
  defSettings.setSectionKey("Scan", "ScanMail", "1")

  defSettings.writeConfig(configFile)


proc loadsettings*() =
  let mainFolder = getHomeDir() & ".secenter"

  if not existsDir(mainFolder):
    createDir(mainFolder)
    createDir(historyFolder)
    createDir(quaratineFolder)
    # TODO handle both no setting and load setting in 1 place and it can access with both functions
    # TODO handle restore default config buttons
    createDefaultSettings()
  clamSettings = loadConfig(configFile)


proc actionClickSetting(b: CheckButton, settings: tuple[section, key: string]) =
  if b.getActive():
    clamSettings.setSectionKey(settings.section, settings.key, "1")
  else:
    clamSettings.setSectionKey(settings.section, settings.key, "0")


proc actionSave(b: Button, d: Dialog) =
  clamSettings.writeConfig(configFile)
  d.destroy()


proc initSetButtonCheck(b: CheckButton, s1: string, s2:string) =
  if clamSettings.getSectionValue(s1, s2) == "1":
    b.setActive()
  b.connect("clicked", actionClickSetting, (s1, s2))


proc actionSetProxy(b: CheckButton, setProxy: tuple[pAddr, pPort: View])=

  if clamSettings.getSectionValue("Update", "UseProxy") == "0":
    clamSettings.setSectionKey("Update", "UseProxy", "1")
    setProxy.pAddr.can_focus = true
    setProxy.pPort.can_focus = true
  else:
    clamSettings.setSectionKey("Update", "UseProxy", "0")
    setProxy.pAddr.can_focus = false
    setProxy.pPort.can_focus = false


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

  btnDoAutoUpdate.initSetButtonCheck("Update", "AutoUpdate")
  
  if clamSettings.getSectionValue("Update", "UseProxy") == "0":
    txtAddr.can_focus = false
    txtPort.can_focus = false
  else:
    btnDoProxy.setActive(true)
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

  btnDoPUA.initSetButtonCheck("Scan", "ScanPUA")
  btnDoByteCode.initSetButtonCheck("Scan", "ScanByteCode")
  btnDoRemoveInfected.initSetButtonCheck("Scan", "AutoRemove")
  btnDoMailFile.initSetButtonCheck("Scan", "ScanMail")
  btnDoAlertEncrypted.initSetButtonCheck("Scan", "AlertEncrypted")
  btnHeuristicAlert.initSetButtonCheck("Scan", "AlertHeuristic")

  boxSettings.packStart(btnDoRemoveInfected, false, true, 3)
  boxSettings.packStart(btnDoByteCode, false, true, 3)
  boxSettings.packStart(btnDoPUA, false, true, 3)
  boxSettings.packStart(btnDoMailFile, false, true, 3)
  boxSettings.packStart(btnHeuristicAlert, false, true, 3)
  boxSettings.packStart(btnDoAlertEncrypted, false, true, 3)

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

  btnCancel.connect("clicked", utils.actionCancel, setDialog)
  btnSave.connect("clicked", actionSave, setDialog)

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

  