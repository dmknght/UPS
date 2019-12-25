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
  #[
    Create some default settings that should be enabled
    Other settings will be added by init
    Other settings will be saved by enable and click save
  ]#

  var
    defSettings = newConfig() # type: Config
  defSettings.setSectionKey("Scan", "Scan Byte Code", "1")
  defSettings.setSectionKey("Scan", "Scan PUA", "1")
  defSettings.setSectionKey("Scan", "Scan Mail Files", "1")

  defSettings.writeConfig(configFile)


proc loadsettings*() =
  #[
    Check if setting folder is created
    1. If not: create folder and create setting file
    2. Load settings from file
  ]#

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
  #[
    When a CheckButton is clicked (enable / disable an option), \
    the value of the option will be changed
  ]#

  if b.getActive():
    clamSettings.setSectionKey(settings.section, settings.key, "1")
  else:
    clamSettings.setSectionKey(settings.section, settings.key, "0")


proc actionSave(b: Button, d: Dialog) =
  #[
    Save the settings to the file and close dialog
  ]#

  clamSettings.writeConfig(configFile)
  d.destroy()


proc initSetButtonCheck(b: CheckButton, s1: string, s2:string) =
  b.setLabel(s2)
  if clamSettings.getSectionValue(s1, s2) == "1":
    b.setActive(true)
  b.connect("clicked", actionClickSetting, (s1, s2))


proc actionInitProxyAddr(b: CheckButton, setProxy: tuple[pAddr, pPort: View]) =
  if b.getActive():
    setProxy.pAddr.can_focus = true
    setProxy.pPort.can_focus = true
  else:
    setProxy.pAddr.can_focus = false
    setProxy.pPort.can_focus = false


proc actionSetProxy(b: CheckButton, args: tuple[header, key: string, pAddr, pPort: View]) =
  actionClickSetting(b, (args.header, args.key))
  actionInitProxyAddr(b, (args.pAddr, args.pPort))


proc setUpdate(b: Box) =
  #[
    Render the update tab in setting dialog
  ]#

  # TODO fix border of txtAddr and txtPort or change object
  # TODO save values of addr
  let
    boxSettings = newBox(Orientation.vertical, 3)
    btnDoAutoUpdate = newCheckButton()
    btnDoProxy = newCheckButton()
    labelProxy = newLabel("Proxy setting")

    addrBox = newBox(Orientation.vertical, 0)
    labelAddr = newLabel("Address")
    labelPort = newLabel("Port")
    txtAddr = newView()
    txtPort = newView()

  labelProxy.setXalign(0.0)
  labelAddr.setXalign(0.0)
  labelPort.setXalign(0.0)

  btnDoAutoUpdate.initSetButtonCheck("Update", "Auto Update")
  btnDoProxy.initSetButtonCheck("Update", "Use Proxy")
  btnDoProxy.connect("toggled", actionSetProxy, ("Update", "Use Proxy", txtAddr, txtPort))
  
  actionInitProxyAddr(btnDoProxy, (txtAddr, txtPort))

  boxSettings.packStart(btnDoAutoUpdate, false, true, 3)
  boxSettings.packStart(btnDoProxy, false, true, 3)
  boxSettings.packStart(labelProxy, false, true, 3)

  addrBox.packStart(labelAddr, false, true, 0)
  addrBox.packStart(txtAddr, false, true, 6)
  addrBox.packStart(labelPort, false, true, 0)
  addrBox.packStart(txtPort, false, true, 6)

  b.packStart(boxSettings, false, true, 3)
  b.packStart(addrBox, false, true, 3)


proc setScan(b: Box) =
  #[
    Render scan settings in setting dialog
  ]#
  let
    boxSettings = newBox(Orientation.vertical, 3)
    btnDoPUA = newCheckButton()
    btnDoByteCode = newCheckButton()
    btnDoRemoveInfected = newCheckButton()
    btnDoMailFile = newCheckButton()
    btnDoAlertEncrypted = newCheckButton()
    btnHeuristicAlert = newCheckButton()

  btnDoPUA.initSetButtonCheck("Scan", "Scan PUA")
  btnDoByteCode.initSetButtonCheck("Scan", "Scan Byte Code")
  btnDoRemoveInfected.initSetButtonCheck("Scan", "Auto Remove Infected")
  btnDoMailFile.initSetButtonCheck("Scan", "Scan Mail Files")
  btnDoAlertEncrypted.initSetButtonCheck("Scan", "Alert Encrypted Files")
  btnHeuristicAlert.initSetButtonCheck("Scan", "Alert Heuristic")

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

  