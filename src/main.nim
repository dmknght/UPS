import gintro / [gtk, gobject]

proc stop(w: Window) =
  mainQuit()

proc main =
  gtk.init()
  let mainBoard = newWindow()
  mainBoard.title = "Parrot ClamAV"

  let
    boxMain = newBox(Orientation.vertical, 5)
    boxScan = newBox(Orientation.horizontal, 5)
    btnQuickScan = newButton("Quick Scan")
    btnFullScan = newButton("Full Scan")
    btnCustomScan = newButton("Custom Scan")
    # TODO online analysis + repu scan

  boxScan.packStart(btnQuickScan, false, true, 3)
  boxScan.packStart(btnFullScan, false, true, 3)
  boxScan.packStart(btnCustomScan, false, true, 3)
  boxMain.packStart(boxScan, false, true, 3)

  let
    boxProtection = newBox(Orientation.horizontal, 5)
    btnUpdate = newButton("Update")
    # TODO real time protection
    # TODO update settings?

  boxProtection.packStart(btnUpdate, false, true, 3)
  boxMain.add(boxProtection)

  let
    boxHistory = newBox(Orientation.horizontal, 5)
    btnLog = newButton("Log")
    btnQuaratine = newButton("Quaratine")

  boxHistory.packStart(btnLog, false, true, 3)
  boxHistory.packSTart(btnQuaratine, false, true, 3)
  boxMain.add(boxHistory)

  let
    boxOptions = newBox(Orientation.horizontal, 5)
    btnSettings = newButton("Settings")
  
  boxOptions.packStart(btnSettings, false, true, 3)

  boxMain.packStart(boxOptions, false, true, 3)
  mainBoard.add(boxMain)

  mainBoard.showAll
  mainBoard.connect("destroy", stop) # TODO hide in icon tray
  gtk.main()

main()