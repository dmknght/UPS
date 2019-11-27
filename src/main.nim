import gintro / [gtk, gobject]
import clam / scan

proc stop(w: Window) =
  mainQuit()

proc main =
  gtk.init()
  let
    mainBoard = newWindow()
    boxMain = newBox(Orientation.vertical, 5)
  
  mainBoard.title = "Parrot ClamAV"

  let
    boxScan = newBox(Orientation.horizontal, 5)
    labelScan = newLabel("Scan")
    btnQuickScan = newButton("Quick Scan")
    btnFullScan = newButton("Full Scan")
    btnCustomScan = newButton("Custom Scan")
    # btnTest = newButton()
    # TODO online analysis + repu scan

  boxScan.setBorderWidth(3)
  btnQuickScan.connect("clicked", scan.quickScan)
  # btnQuickScan.setIconName("icons/search.png")
  labelScan.setXalign(0.0)
  boxMain.add(labelScan)
  # boxScan.packStart(btnTest, false, true, 3)
  boxScan.packStart(btnQuickScan, false, true, 3)
  boxScan.packStart(btnFullScan, false, true, 3)
  boxScan.packStart(btnCustomScan, false, true, 3)
  boxMain.packStart(boxScan, false, true, 3)

  let
    labelProtection = newLabel("Protection")
    boxProtection = newBox(Orientation.horizontal, 5)
    btnUpdate = newButton("Update")
    # TODO real time protection
    # TODO update settings?

  labelProtection.setXalign(0.0)
  boxMain.add(labelProtection)
  boxProtection.packStart(btnUpdate, false, true, 3)
  boxMain.add(boxProtection)

  let
    labelHistory = newLabel("History")
    boxHistory = newBox(Orientation.horizontal, 5)
    btnLog = newButton("Scan logs")
    btnQuaratine = newButton("Quaratine")

  labelHistory.setXalign(0.0)
  boxMain.add(labelHistory)
  boxHistory.packStart(btnLog, false, true, 3)
  boxHistory.packSTart(btnQuaratine, false, true, 3)
  boxMain.add(boxHistory)

  let
    labelOptions = newLabel("Options")
    boxOptions = newBox(Orientation.horizontal, 5)
    btnSetScan = newButton("Scan Settings")
    btnSetSchedule = newButton("Schedule Scan")
    btnSetUpdate = newButton("Update Settings") # auto / manual update; proxy update (todo patch db)
  
  labelOptions.setXalign(0.0)
  boxMain.add(labelOptions)
  boxOptions.packStart(btnSetScan, false, true, 3)
  boxOptions.packStart(btnSetSchedule, false, true, 3)
  boxOptions.packStart(btnSetUpdate, false, true, 3)

  boxMain.packStart(boxOptions, false, true, 3)
  mainBoard.add(boxMain)
  mainBoard.setBorderWidth(3)

  mainBoard.showAll
  mainBoard.connect("destroy", stop) # TODO hide in icon tray
  gtk.main()

main()