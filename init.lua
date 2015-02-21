-- Startup script for EasyESP

-- Check for recovery mode:
gpio.mode(8, gpio.INPUT)
recov = gpio.read(8)
if recov == 0 then
  print("Entering recovery mode.")
  dofile("recovery.lua")
else
  print("Entering normal EasyESP mode.")
  dofile("easyesp.lua")
end
