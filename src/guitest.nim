import gintro/[gtk, glib, gobject, gio], os, osproc, streams

var globalChan: Channel[string]
var watcherThread: system.Thread[void]

proc watchProc() = 
  let a = startProcess("/usr/bin/ping", args = @["google.com"]) 
  while true:
    globalChan.send(a.outputStream.readLine() & "\n")

proc recvCb(w: Widget): bool = 
  let text = TextView(w)
  let data = globalChan.tryRecv()
  if data[0]:
    text.buffer.insertAtCursor(data[1], len(data[1]))
  
  return SOURCE_CONTINUE

proc appActivate(app: Application) =
  let builder = newBuilder()
  discard builder.addFromFile("guitest.glade")

  let window = builder.getApplicationWindow("window")
  window.setApplication(app)

  var text = builder.getTextView("text1")

  discard timeoutAdd(500, recvCb, text)

  globalChan.open()
  createThread(watcherThread, watchProc)
  
  showAll(window)

proc main =
  let app = newApplication("org.gtk.example")
  connect(app, "activate", appActivate)
  discard run(app)

main()