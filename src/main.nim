import gintro / [gtk, gobject]
import clam / [scan, settings]


proc sectionScan(boxMain: Box) =
  let
    boxScan = newBox(Orientation.horizontal, 5)
    labelScan = newLabel("Scan")
    # buttons
    btnQuickScan = newButton("Quick Scan")
    btnFullScan = newButton("Full Scan")
    btnCustomScan = newButton("Custom Scan")
    # icons
    # imgQuickScan = newImageFromIconName("gtk-find-and-replace", 3)
    imgQuickScan = newImageFromIconName("go-home", 3)
    imgFullScan = newImageFromIconName("system-search", 3)
    imgCustomScan = newImageFromIconName("folder-new", 3)
    # TODO online analysis + repu scan

  boxScan.setBorderWidth(3)
  btnQuickScan.connect("clicked", scan.quickScan)
  labelScan.setXalign(0.0)
  boxMain.add(labelScan)

  btnQuickScan.setImage(imgQuickScan)
  btnFullScan.setImage(imgFullScan)
  btnCustomScan.setImage(imgCustomScan)
  boxScan.packStart(btnQuickScan, false, true, 3)
  boxScan.packStart(btnFullScan, false, true, 3)
  boxScan.packStart(btnCustomScan, false, true, 3)
  boxMain.packStart(boxScan, false, true, 3)

proc sectionProtection(boxMain: Box) =
  let
    labelProtection = newLabel("Protection")
    boxProtection = newBox(Orientation.horizontal, 5)
    btnUpdate = newButton("Update")
    imgUpdate = newImageFromIconName("document-save-as", 3)
    # TODO netmon
    # TODO real time protection
    # TODO update settings?

  labelProtection.setXalign(0.0)
  boxMain.add(labelProtection)
  btnUpdate.setImage(imgUpdate)
  boxProtection.packStart(btnUpdate, false, true, 3)
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
    labelOptions = newLabel("Options")
    boxOptions = newBox(Orientation.horizontal, 5)
    btnSetScan = newButton("Scan Settings")
    btnSetSchedule = newButton("Schedule Scan")
    btnSetUpdate = newButton("Update Settings") # auto / manual update; proxy update (todo patch db)

    imgSetScan = newImageFromIconName("zoom-in", 3)
    imgSetUpdate = newImageFromIconName("view-sort-ascending", 3)

  labelOptions.setXalign(0.0)

  btnSetScan.connect("clicked", settings.stnScan)
  btnSetScan.setImage(imgSetScan)
  btnSetUpdate.connect("clicked", settings.stnUpdate)
  btnSetUpdate.setImage(imgSetUPdate)

  boxMain.add(labelOptions)
  boxOptions.packStart(btnSetScan, false, true, 3)
  boxOptions.packStart(btnSetSchedule, false, true, 3)
  boxOptions.packStart(btnSetUpdate, false, true, 3)
  boxMain.packStart(boxOptions, false, true, 3)

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