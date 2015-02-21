-- Main EasyESP script

-- Connect to an AP:
function connectToAP(cfg)
  print("Connecting to SSID '" .. cfg.ssid .. "'.")
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.config(cfg)
  --print("Connected! IP is " .. wifi.ap.getip())
end

-- Read AP cfg from file:
function readAPCfg(filename)
  file.open(filename, "r")
  cfg = {}
  cfg.ssid = string.sub(file.readline(), 1, -2)
  cfg.pass = string.sub(file.readline(), 1, -2)
  file.close()
  return cfg
end

cfg = readAPCfg("creds.cfg")
connectToAP(cfg)
