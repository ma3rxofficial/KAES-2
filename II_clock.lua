local monitor = peripheral.wrap("bottom")
monitor.clear()
monitor.setCursorPos(1, 1)
monitor.setTextScale(2)
monitor.setTextColor(colors.cyan)
monitor.write("test")


while true do
  time = http.get("http://localhost:8056").readAll()
  print(string.sub(time, 12))
  monitor.setCursorPos(1, 1)
  monitor.write(string.sub(time, 12))
  
  monitor.setCursorPos(8, 2)
  monitor.write("#3")
  sleep(1)
end
