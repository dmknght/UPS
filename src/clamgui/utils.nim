import gintro / gtk
import osproc

proc actionCancel*(b: Button, d: Dialog) =
  d.destroy()

proc actionHide*(b: Button, d: Dialog) =
  d.hide()

proc actionStop*(b: Button, p: Process) =
  p.kill()

