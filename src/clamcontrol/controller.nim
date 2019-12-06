import gintro / gtk

proc actionCancel*(b: Button, d: Dialog) =
  d.destroy()

proc actionHide*(b: Button, d: Dialog) =
  d.hide()