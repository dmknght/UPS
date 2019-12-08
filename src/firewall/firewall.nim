import gintro / gtk

proc tableFirewall*(b: Button) =
  let
    fwDialog = newDialog()
    boxRules = newBox(Orientation.vertical, 3)
    fwArea = fwDialog.getContentArea()
    treeRules = newTreeView()
    

  discard