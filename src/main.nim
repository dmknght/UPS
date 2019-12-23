import gintro / [gtk, gobject]
import clamgui / [scan, settings]
# import firewall / firewall


proc sectionScan(boxMain: Box) =
  let
    boxScan = newBox(Orientation.horizontal, 5)
    labelScan = newLabel("Scan")
    # buttons
    btnHomeScan = newButton("Home Scan")
    btnFullScan = newButton("Full Scan")
    btnCustomScan = newButton("Custom Scan")
    # icons
    # imgHomeScan = newImageFromIconName("gtk-find-and-replace", 3)
    imgHomeScan = newImageFromIconName("go-home", 3)
    imgFullScan = newImageFromIconName("system-search", 3)
    imgCustomScan = newImageFromIconName("folder-new", 3)
    # TODO online analysis + repu scan

  boxScan.setBorderWidth(3)
  labelScan.setXalign(0.0)
  boxMain.add(labelScan)

  # Setup button Home Scan
  btnHomeScan.setImage(imgHomeScan)
  btnHomeScan.setTooltipText("Scan your home folder")
  btnHomeScan.connect("clicked", scan.homeScan)

  # Setup button Full scan
  btnFullScan.setImage(imgFullScan)
  btnFullScan.setTooltipText("Scan the whole computer")
  btnFullScan.connect("clicked", scan.fullScan)

  # Setup button Custom Scan
  btnCustomScan.setImage(imgCustomScan)
  btnCustomScan.setTooltipText("Scan selected files / folders")
  # TODO display path selection

  # Add buttons to the scan box
  boxScan.packStart(btnHomeScan, false, true, 3)
  boxScan.packStart(btnFullScan, false, true, 3)
  boxScan.packStart(btnCustomScan, false, true, 3)

  # Add scan box to main box
  boxMain.packStart(boxScan, false, true, 3)

proc sectionProtection(boxMain: Box) =
  let
    labelProtection = newLabel("Protection")
    boxProtection = newBox(Orientation.horizontal, 5)
    btnUpdate = newButton("Update")
    imgUpdate = newImageFromIconName("document-save-as", 3)

    # btnFirewall = newButton("Firewall")
    # imgFirewall = newImageFromIconName()
    # TODO netmon
    # TODO real time protection
    # TODO update settings?

  labelProtection.setXalign(0.0)

  boxMain.add(labelProtection)
  btnUpdate.setImage(imgUpdate)
  btnUpdate.setTooltipText("Update virus signatures")
  # btnFirewall.setTooltipText("Set connection policies")
  # btnFirewall.connect("clicked", firewall.tableFirewall)

  boxProtection.packStart(btnUpdate, false, true, 3)
  # boxProtection.packStart(btnFirewall, false, true, 3)
  boxMain.add(boxProtection)

proc sectionHistory(boxMain: Box) =
  let
    labelHistory = newLabel("History")
    boxHistory = newBox(Orientation.horizontal, 5)
    btnLog = newButton("Scan logs")
    btnQuaratine = newButton("Quaratine")
    imgLog = newImageFromIconName("view-list-compact-symbolic", 3)

  btnLog.setImage(imgLog)
  
  labelHistory.setXalign(0.0)
  boxMain.add(labelHistory)
  boxHistory.packStart(btnLog, false, true, 3)
  boxHistory.packSTart(btnQuaratine, false, true, 3)
  boxMain.add(boxHistory)

proc sectionSettings(boxMain: Box) = 
  let
    labelSettings = newLabel("Settings")
    boxSettings = newBox(Orientation.horizontal, 5)
    btnSetScan = newButton("Scan Settings")
    btnSetSchedule = newButton("Schedule Scan")
    btnSetUpdate = newButton("Update Settings") # auto / manual update; proxy update (todo patch db)

    imgSetScan = newImageFromIconName("zoom-in", 3)
    imgSetUpdate = newImageFromIconName("view-sort-ascending", 3)

  labelSettings.setXalign(0.0)

  btnSetScan.connect("clicked", settings.stnScan)
  btnSetScan.setImage(imgSetScan)
  btnSetUpdate.connect("clicked", settings.stnUpdate)
  btnSetUpdate.setImage(imgSetUPdate)

  boxMain.add(labelSettings)
  boxSettings.packStart(btnSetScan, false, true, 3)
  boxSettings.packStart(btnSetSchedule, false, true, 3)
  boxSettings.packStart(btnSetUpdate, false, true, 3)
  boxMain.packStart(boxSettings, false, true, 3)

proc stop(w: Window) =
  mainQuit()

proc main =
  gtk.init()
  let
    mainBoard = newWindow()
    boxMain = newBox(Orientation.vertical, 5)
  
  mainBoard.title = "Parrot ClamAV"

  sectionScan(boxMain)
  sectionProtection(boxMain)
  sectionHistory(boxMain)
  sectionSettings(boxMain)

  mainBoard.add(boxMain)
  mainBoard.setBorderWidth(3)

  mainBoard.showAll
  mainBoard.connect("destroy", stop) # TODO hide in icon tray
  gtk.main()

main()