-- Startup script for EasyESP

-- Check for recovery mode:
gpio.mode(3, gpio.INPUT)
recov = gpio.read(3)
if recov == 0 then
  print("Entering recovery mode.")
  dofile("recovery.lua")
else
  print("Entering normal EasyESP mode.")
  dofile("easyesp.lua")
end
