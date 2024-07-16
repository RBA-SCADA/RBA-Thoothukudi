local dev, good = ...
--print(dev)

devS = string.sub(dev, 8, -1)
--print("devS = ", devS)

require ("socket")
local now = socket.gettime()
local date = os.date("*t")
local hour = date.hour
local min = date.min
local sec = date.sec

------------------------- Read Function Start ---------------------------------

function CHECKDATATIME(dev, now, field)
 local midNight = (now - ((hour * 60 * 60) + (min * 60) + sec))
 local dataTime = WR.ts(dev, field)
 if (dataTime < midNight) then
  WR.setProp(dev, field, 0)
 else
  local data = WR.read(dev, field)
  WR.setProp(dev, field, data)
 end
end

------------------------- Read Function End -----------------------------------
if not(settings) then
 --print ("Inside file loading")
 settingsConfig = assert(io.open("/mnt/jffs2/solar/modbus/Settings.txt", "r"))
 settingsJson = settingsConfig:read("*all")
 settings = cjson.decode(settingsJson)
 CHECKDATATIME(dev, now, "SOLAR_RADIATION_CUM")
end

if WR.isOnline(dev) then
 WR.setProp(dev, "COMMUNICATION_STATUS", 0)
else
 WR.setProp(dev, "COMMUNICATION_STATUS", 1)
end

local FIOA_range = 50
local FIOA_Count = 65535
local Sen_sensitivity = 11
WR.setProp(dev, "Solar_Radiation",(((FIOA_range/FIOA_Count)*1000*WR.read(dev, "Solar_Radiation_Act"))/Sen_sensitivity))

local radiation =  WR.read(dev, "Solar_Radiation")
radCum = radCum or {}
radCum[dev] = radCum[dev] or {ts=now, day=WR.read(dev, "SOLAR_RADIATION_CUM")}
if is_nan(radiation) then radiation = 0 end
if (is_nan(radCum[dev].day)) then radCum[dev].day = 0 end

WR.setProp(dev, "Module_Temperature",  (((((WR.read(dev, "Cell_Temperature_Act")) - 4) * 4) - 42)))
--WR.setProp(dev, "Ambient_Temperature", (((((WR.read(dev, "Ambient_Temperature_Act")) - 4) * 4) - 42)))

------------------------ Check Midnight Start ---------------------------------

checkMidnight = checkMidnight or {}
checkMidnight[dev] = checkMidnight[dev] or {ts=now}
if (os.date("*t", checkMidnight[dev].ts).hour > os.date("*t", now).hour) then
 radCum[dev].day = 0
end
checkMidnight[dev].ts = now

------------------------ Check Midnight End -----------------------------------

------------------------- Radiation Day Start ---------------------------------

radCum[dev].day = radCum[dev].day + (((now-radCum[dev].ts) * radiation) / (60 * 60 * 1000))
radCum[dev].ts = now
WR.setProp(dev, "SOLAR_RADIATION_CUM", radCum[dev].day)

------------------------- Radiation Day End -----------------------------------

