import gintro / [gtk, gobject]

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
    # TODO online analysis + repu scan

  labelScan.setXalign(0.0)
  boxMain.add(labelScan)
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
    btnSettings = newButton("Settings")
  
  labelOptions.setXalign(0.0)
  boxMain.add(labelOptions)
  boxOptions.packStart(btnSettings, false, true, 3)

  boxMain.packStart(boxOptions, false, true, 3)
  mainBoard.add(boxMain)

  mainBoard.showAll
  mainBoard.connect("destroy", stop) # TODO hide in icon tray
  gtk.main()

main()