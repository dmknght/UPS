import gintro / [gtk, gobject, gtksource]
import utils
import parsecfg
import os
import strutils


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
  defSettings.setSectionKey("Scan", "ScanByteCode", "1")
  defSettings.setSectionKey("Scan", "ScanPUA", "1")
  defSettings.setSectionKey("Scan", "ScanMailFiles", "1")

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
  if not fileExists(configFile):
    createDefaultSettings()
  clamSettings = loadConfig(configFile)


proc actionSave(b: Button, d: Dialog) =
  #[
    Save the settings to the file and close dialog
  ]#

  clamSettings.writeConfig(configFile)
  d.destroy()


proc updatePortSetting(b: SpinButton, setting: tuple[section, key: string]) =
  let buttonValue = b.getValueAsInt
  clamSettings.setSectionKey(setting.section, setting.key, intToStr(buttonValue))


proc actionClickSetting(b: CheckButton, setting: tuple[section, key: string]) =
  #[
    When a CheckButton is clicked (enable / disable an option), \
    the value of the option will be changed
  ]#

  if b.getActive():
    clamSettings.setSectionKey(setting.section, setting.key, "1")
  else:
    clamSettings.setSectionKey(setting.section, setting.key, "0")


proc initSetButtonCheck(b: CheckButton, section: string, label:string) =
  #[
    Set label for the button and generate value for settings automatically
  ]#
  b.setLabel(label)
  let key = label.replace(" ", "")
  if clamSettings.getSectionValue(section, key) == "1":
    b.setActive(true)
  b.connect("clicked", actionClickSetting, (section, key))


proc actionInitProxyAddr(b: CheckButton, setProxy: tuple[pAddr: View, pPort: SpinButton]) =
  #[
    Focus, unfocus field of address and port
  ]#

  if b.getActive():
    setProxy.pAddr.can_focus = true
    setProxy.pPort.setSensitive(true)
  else:
    setProxy.pAddr.can_focus = false
    setProxy.pPort.setSensitive(false)


proc actionSetProxy(b: CheckButton, args: tuple[header, key: string, pAddr: View, pPort: SpinButton]) =
  #[
    Change value of set proxy settings
    And focus / unfocus view fields
  ]#

  actionClickSetting(b, (args.header, args.key))
  actionInitProxyAddr(b, (args.pAddr, args.pPort))


proc setUpdate(b: Box) =
  #[
    Render the update tab in setting dialog
  ]#

  # BUG addr and port field is invisible because of system theme
  # TODO radio button to check: no proxy, system proxy, custom proxy
  # TODO radio button to select: No auto update, auto check update, auto apply update
  # TODO save values of addr
  let
    boxSettings = newBox(Orientation.vertical, 3)
    btnDoAutoUpdate = newCheckButton()
    btnDoProxy = newCheckButton()
    labelProxy = newLabel("Proxy Setting")

    addrBox = newBox(Orientation.vertical, 0)
    labelAddr = newLabel("Address")
    labelPort = newLabel("Port")
    setProxyAddr = newView()
    setProxyPort = newSpinButtonWithRange(1, 65535, 1)

  labelProxy.setXalign(0.0)
  labelAddr.setXalign(0.0)
  labelPort.setXalign(0.0)

  btnDoAutoUpdate.initSetButtonCheck("Update", "Auto Update")
  btnDoProxy.initSetButtonCheck("Update", "Use Proxy")
  btnDoProxy.connect("toggled", actionSetProxy, ("Update", "Use Proxy", setProxyAddr, setProxyPort))
  
  actionInitProxyAddr(btnDoProxy, (setProxyAddr, setProxyPort))

  boxSettings.packStart(btnDoAutoUpdate, false, true, 3)
  boxSettings.packStart(btnDoProxy, false, true, 3)

  # TODO init proxy addr and port value

  setProxyPort.connect("value-changed", updatePortSetting, ("Update", "Port"))

  addrBox.packStart(labelProxy, false, true, 3)
  addrBox.packStart(labelAddr, false, true, 3)
  addrBox.packStart(setProxyAddr, false, true, 6)
  addrBox.packStart(labelPort, false, true, 3)
  addrBox.packStart(setProxyPort, false, true, 6)

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

  # Init all buttons
  btnDoPUA.initSetButtonCheck("Scan", "Scan PUA")
  btnDoByteCode.initSetButtonCheck("Scan", "Scan Byte Code")
  btnDoRemoveInfected.initSetButtonCheck("Scan", "Auto Remove Infected")
  btnDoMailFile.initSetButtonCheck("Scan", "Scan Mail Files")
  btnDoAlertEncrypted.initSetButtonCheck("Scan", "Alert Encrypted Files")
  btnHeuristicAlert.initSetButtonCheck("Scan", "Alert Heuristic")

  # Add buttons to scan setting tab
  boxSettings.packStart(btnDoRemoveInfected, false, true, 3)
  boxSettings.packStart(btnDoByteCode, false, true, 3)
  boxSettings.packStart(btnDoPUA, false, true, 3)
  boxSettings.packStart(btnDoMailFile, false, true, 3)
  boxSettings.packStart(btnHeuristicAlert, false, true, 3)
  boxSettings.packStart(btnDoAlertEncrypted, false, true, 3)

  b.packStart(boxSettings, false, true, 3)


proc popSettings*(b: Button) =
  #[
    Render setting dialog
  ]#
  let
    setDialog = newDialog() # Create new dialog
    areaSet = setDialog.getContentArea() # Create object to control dialog
    setController = newNotebook() # Create setting menu with tabs

    boxSetScan = newBox(Orientation.vertical, 3)
    boxSetUpdate = newBox(Orientation.vertical, 3)

    boxButtons = newBox(Orientation.horizontal, 3)
    btnCancel = newButton("Cancel")
    btnApply = newButton("Apply")
    imgSave = newImageFromIconName("dialog-ok", 3)
    imgCancel = newImageFromIconName("edit-clear", 3)

  btnApply.setImage(imgSave)
  btnCancel.setImage(imgCancel)

  btnCancel.connect("clicked", utils.actionCancel, setDialog)
  btnApply.connect("clicked", actionSave, setDialog)

  boxButtons.packStart(btnApply, false, true, 3)
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
