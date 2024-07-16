local dev, good = ...
--print(dev)

devS = string.sub(dev, 4, -1)
--print("devS = ", devS)

require ("socket")
local now = socket.gettime()
local date = os.date("*t")
local hour = date.hour
local min = date.min
local sec = date.sec

------------------------ Read Setpoints Start ---------------------------------

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
 settingsConfig:close()
end

if not(settings.PLANT.dcCapacity and settings.PLANT.prAlarmSetpoint and settings.PLANT.prAlarmRadSetpoint and settings.PLANT.prAlarmTimeSetpoint and settings.PLANT.prRealRadSetpoint and settings.PLANT.prMinRadSetpoint and settings.PLANT.gridVoltSetpoint) then
 --print ("Data loading")
 settings.PLANT.dcCapacity = settings.PLANT.dcCapacity or 53510
 settings.PLANT.acCapacity = settings.PLANT.acCapacity or 53510
 settings.PLANT.prAlarmSetpoint = settings.PLANT.prAlarmSetpoint or 75
 settings.PLANT.prAlarmRadSetpoint = settings.PLANT.prAlarmRadSetpoint or 500
 settings.PLANT.prAlarmTimeSetpoint = settings.PLANT.prAlarmTimeSetpoint or 300
 settings.PLANT.prRealRadSetpoint = settings.PLANT.prRealRadSetpoint or 100
 settings.PLANT.prMinRadSetpoint = settings.PLANT.prMinRadSetpoint or 500
 settings.PLANT.gridVoltSetpoint = settings.PLANT.gridVoltSetpoint or 100

 CHECKDATATIME(dev, now, "EAEN_DAY")
 CHECKDATATIME(dev, now, "PLANT_START_TIME")
 CHECKDATATIME(dev, now, "PLANT_STOP_TIME")
 CHECKDATATIME(dev, now, "OPERATIONAL_TIME")
 CHECKDATATIME(dev, now, "GRID_ON")
 CHECKDATATIME(dev, now, "GRID_OFF")
 CHECKDATATIME(dev, now, "PR_MIN")
 CHECKDATATIME(dev, now, "PR_DAY")
 CHECKDATATIME(dev, now, "PAC_MAX_TIME")
 CHECKDATATIME(dev, now, "PR_YDAY")
 CHECKDATATIME(dev, now, "CUF_YDAY")
 CHECKDATATIME(dev, now, "RADIATION_YDAY")
 CHECKDATATIME(dev, now, "PAC_MAX_YDAY")
end

--print ("dcCapacity = ", settings.PLANT.dcCapacity)
--print ("prAlarmSetpoint = ", settings.PLANT.prAlarmSetpoint)
--print ("prAlarmRadSetpoint = ", settings.PLANT.prAlarmRadSetpoint)
--print ("prAlarmTimeSetpoint = ", settings.PLANT.prAlarmTimeSetpoint)
--print ("prRealRadSetpoint = ", settings.PLANT.prRealRadSetpoint)
--print ("prMinRadSetpoint = ", settings.PLANT.prMinRadSetpoint)
--print ("gridVoltSetpoint = ", settings.PLANT.gridVoltSetpoint)

------------------------ Read Setpoints End -----------------------------------

------------------------ Read Required Data Start -----------------------------

local radiation = WR.read(dev, "RADIATION")
local radiationDay = WR.read(dev, "SOLAR_RADIATION_CUM")
local pac = WR.read(dev, "PAC")
if is_nan(pac) then pac = 0 end
local pacMax = WR.read(dev, "PAC_MAX")
local pr = WR.read(dev, "PR")
if is_nan(pr) then pr = 0 end
local prMin = WR.read(dev, "PR_MIN")
if is_nan(prMin) then prMin = 0 end
local prDay = WR.read(dev, "PR_DAY")
if is_nan(prDay) then prDay = 0 end
local cuf = WR.read(dev, "CUF")
if is_nan(cuf) then cuf = 0 end
local pacn = pac / (settings.PLANT.dcCapacity / 1000)
if is_nan(pacn) then pacn = 0 end
local eai = WR.read(dev, "EAI")
local eae = WR.read(dev, "EAE")
local eaiDay = WR.read(dev, "EAI_DAY")
local eae1 = WR.read(dev, "EAE")
if eae1 > 100 then WR.setProp(dev, "EAE_DAY", eae1) end
local eaeDay = WR.read(dev, "EAE_DAY")
if not(pacOld) then pacOld = WR.read(dev, "PAC_MAX") end
startTime = startTime or {}
startTime[dev] = startTime[dev] or {ts=WR.read(dev, "PLANT_START_TIME")}
if is_nan(startTime[dev].ts) then startTime[dev].ts = 0 end
stopTime = stopTime or {}
startTime1 = startTime1 or {}
startTime1[dev] = startTime1[dev] or {ts=WR.read(dev, "PLANT_SUNRISE_TIME")}
if is_nan(startTime1[dev].ts) then startTime1[dev].ts = 0 end
stopTime[dev] = stopTime[dev] or {ts=WR.read(dev, "PLANT_STOP_TIME"), againStart=0}
if is_nan(stopTime[dev].ts) then stopTime[dev].ts = 0 end
if is_nan(stopTime[dev].againStart) then stopTime[dev].againStart = 0 end
stopTime1 = stopTime1 or {}
stopTime1[dev] = stopTime1[dev] or {ts=WR.read(dev, "PLANT_SUNSET_TIME"), againStart=0}
if is_nan(stopTime1[dev].ts) then stopTime1[dev].ts = 0 end
if is_nan(stopTime1[dev].againStart) then stopTime1[dev].againStart = 0 end
gridAvailability = gridAvailability or {}
gridAvailability[dev] = gridAvailability[dev] or {ts=now, tson=WR.read(dev, "GRID_ON"), tsoff=WR.read(dev, "GRID_OFF")}
if is_nan(gridAvailability[dev].tson) then gridAvailability[dev].tson = 0 end
if is_nan(gridAvailability[dev].tsoff) then gridAvailability[dev].tsoff = 0 end
opTime = opTime or {}
opTime[dev] = opTime[dev] or {ts=now, tson=WR.read(dev, "OPERATIONAL_TIME")}
if is_nan(opTime[dev].tson) then opTime[dev].tson = 0 end
WR.setProp(dev, "PAC_MAX_TIME", WR.read(dev, "PAC_MAX_TIME"))
WR.setProp(dev, "EAE_YDAY", WR.read(dev, "EAE_YDAYC"))
WR.setProp(dev, "PR_YDAY", WR.read(dev, "PR_YDAY"))
WR.setProp(dev, "CUF_YDAY", WR.read(dev, "CUF_YDAY"))
WR.setProp(dev, "RADIATION_YDAY", WR.read(dev, "RADIATION_YDAY"))
WR.setProp(dev, "PAC_MAX_YDAY", WR.read(dev, "PAC_MAX_YDAY"))

------------------------ Read Required Data End -------------------------------

checkMidnight = checkMidnight or {}
checkMidnight[dev] = checkMidnight[dev] or {ts=now}
if (os.date("*t", checkMidnight[dev].ts).hour > os.date("*t", now).hour) then
 startTime[dev].ts = 0
 stopTime[dev].ts = 0
 startTime1[dev].ts = 0
 stopTime1[dev].ts = 0
 gridAvailability[dev].tson = 0
 gridAvailability[dev].tsoff = 0
 opTime[dev].tson = 0
 pacOld = 0
 prMin = 0
 WR.setProp(dev, "PAC_MAX_TIME", 0)
end
checkMidnight[dev].ts = now

if ((os.date("*t", checkMidnight[dev].ts).hour == 23) and (os.date("*t", now).min >= 55)) then
 WR.setProp(dev, "PR_YDAY", prDay)
 WR.setProp(dev, "CUF_YDAY", cuf)
 WR.setProp(dev, "RADIATION_YDAY", radiationDay)
 WR.setProp(dev, "PAC_MAX_YDAY", pacMax)
end

------------------------ Check Midnight End -----------------------------------

---------------------- COMMUNICATION STATUS Start -----------------------------

if WR.isOnline(dev) then
 WR.setProp(dev, "COMMUNICATION_STATUS", 0)
else
 WR.setProp(dev, "COMMUNICATION_STATUS", 1)
end

local commChannel = 0
for d in WR.devices() do
 --print("d = ",d)
 if not(WR.isOnline(d)) then
  commChannel = commChannel + 1
  if (commChannel > 1) then commChannel = 1 end
 end
 --print("commChannel = ",commChannel)
end
file = io.open("/ram/"..masterid..".temp","w+")
if file ~= nil then
 file:write(commChannel)
end
file:close()
os.remove("/ram/"..masterid.."")
os.rename("/ram/"..masterid..".temp","/ram/"..masterid.."")

---------------------- COMMUNICATION STATUS End -------------------------------

--------------------PAC MAX Time Calculation Start ----------------------------

if (pac >= pacOld) then
 pacOld = pac
 WR.setProp(dev, "PAC_MAX_TIME", (now + 19800))
end

--------------------PAC MAX Time Calculation End ------------------------------

------------------------ EM IAC UAC Calculation start -------------------------

WR.setProp(dev, "UAC",((WR.read(dev, "UAC12") + WR.read(dev, "UAC23") + WR.read(dev, "UAC31")) / 3))
WR.setProp(dev, "IAC",((WR.read(dev, "IAC1") + WR.read(dev, "IAC2") + WR.read(dev, "IAC3")) / 3))

------------------------ EM IAC UAC Calculation END --------------------------

--------------------- Plant Operational Time Calculation Start ----------------

if (radiation > 2) then
 opTime[dev].tson = opTime[dev].tson + (now - opTime[dev].ts)
 if (startTime[dev].ts == 0) then
  startTime[dev].ts = ((hour * 60 * 60) + (min * 60) + sec)
 end
 stopTime[dev].againStart = 1
elseif ((pac <= 0) and  (startTime[dev].ts ~= 0) and ((stopTime[dev].againStart == 1) or (stopTime[dev].ts == 0))) then
 stopTime[dev].ts = ((hour * 60 * 60) + (min * 60) + sec)
 stopTime[dev].againStart = 0
end
opTime[dev].ts = now
WR.setProp(dev, "PLANT_START_TIME", startTime[dev].ts)
WR.setProp(dev, "PLANT_STOP_TIME", stopTime[dev].ts)
WR.setProp(dev, "OPERATIONAL_TIME", opTime[dev].tson)

--------------------- Plant Operational Time Calculation End ------------------


----------------------- Grid Availability Start -------------------------------

local gridFail = 0
local uac12 = WR.read(dev, "UAC12")
local uac23 = WR.read(dev, "UAC23")
local uac31 = WR.read(dev, "UAC31")
if is_nan(uac12) then uac12 = 0 end
if is_nan(uac23) then uac23 = 0 end
if is_nan(uac31) then uac31 = 0 end
local uac = ((uac12 + uac23 + uac31) / 3)
if (uac >= settings.PLANT.gridVoltSetpoint) then
 gridAvailability[dev].tson = gridAvailability[dev].tson + (now - gridAvailability[dev].ts)
 gridfail = 0
else
 gridAvailability[dev].tsoff = gridAvailability[dev].tsoff + (now - gridAvailability[dev].ts)
 gridFail = 1
end
gridAvailability[dev].ts = now
WR.setProp(dev, "GRID_ON", gridAvailability[dev].tson)
WR.setProp(dev, "GRID_OFF", gridAvailability[dev].tsoff)
WR.setProp(dev, "GRID_AVAILABILITY", ((gridAvailability[dev].tson) / (gridAvailability[dev].tson + gridAvailability[dev].tsoff) * 100))
WR.setProp(dev, "GRID_FAIL", gridFail)

----------------------- Grid Availability End ---------------------------------
--------------------- Sunrise & Sunset Time Calculation Start ----------------
if (radiation > 20) then
 if (startTime1[dev].ts == 0) then
  startTime1[dev].ts = ((hour * 60 * 60) + (min * 60) + sec)
 end
 stopTime1[dev].againStart = 1
elseif ((radiation <= 20) and  (startTime1[dev].ts ~= 0) and ((stopTime1[dev].againStart == 1) or (stopTime1[dev].ts == 0))) then
 stopTime1[dev].ts = ((hour * 60 * 60) + (min * 60) + sec)
 stopTime1[dev].againStart = 0
end
WR.setProp(dev, "PLANT_SUNRISE_TIME", startTime1[dev].ts)
WR.setProp(dev, "PLANT_SUNSET_TIME", stopTime1[dev].ts)


--------------------- Sunrise & Sunset Time Calculation End ------------------
------------------------ CUF Calculation Start --------------------------------

local cuf = ((eaeDay) / (settings.PLANT.acCapacity * 24)) * 100
if is_nan(cuf) then cuf = 0 end
WR.setProp(dev, "CUF", cuf)

------------------------ CUF Calculation End ----------------------------------

------------------------- Plant Net Energy Start ------------------------------

WR.setProp(dev, "EAN", (eae - eai))
WR.setProp(dev, "EAN_DAY", (eaeDay - eaiDay))

------------------------- Plant Net Energy End --------------------------------

----------------------- Normailised Energy Start ------------------------------

WR.setProp(dev, "EAEN_DAY", (eaeDay / (settings.PLANT.dcCapacity / 1000)))

----------------------- Normailised Energy End --------------------------------
------------------------ PR Calculation Start ---------------------------------

plantAlarm = plantAlarm or {}
plantAlarm[dev] = plantAlarm[dev] or {tsp=now}

--print("now = ",now)
--print("plantAlarm["..dev.."].tsp = ",plantAlarm[dev].tsp)

local prNow = 0
local prAlarm = 0
if ((radiation > settings.PLANT.prRealRadSetpoint) and (pac >= 0)) then
prNow = (((pac * 1000) / settings.PLANT.dcCapacity) / (radiation)) * 100
 if is_nan(prNow) then prNow = 0 end
 if (prNow > 100) then prNow = pr end
 if ((pr < settings.PLANT.prAlarmSetpoint) and (radiation > settings.PLANT.prAlarmRadSetpoint)) then
  prAlarm = 1
 end
end
if (prAlarm == 1) then
 if ((now-plantAlarm[dev].tsp) < settings.PLANT.prAlarmTimeSetpoint) then prAlarm = 0 end
 else
 plantAlarm[dev].tsp = now
 prAlarm = 0
end
local prDayNow = 0
if (radiationDay > 0.2) then
 prDayNow = (((eaeDay) / settings.PLANT.dcCapacity) / radiationDay) * 100
 else
 prDayNow = prDay
end
if is_nan(prDayNow) then prDayNow = prDay end
 if ((radiation > settings.PLANT.prMinRadSetpoint) and ((pr < prMin) or (prMin == 0))) then
 prMin = pr
end

 WR.setProp(dev, "PR", prNow)
 WR.setProp(dev, "PR_MAX", prNow)
 WR.setProp(dev, "PR_MIN", prMin)
 WR.setProp(dev, "PR_ALARM", prAlarm)
 WR.setProp(dev, "PR_DAY", prDayNow)

------------------------ PR Calculation End -----------------------------------

