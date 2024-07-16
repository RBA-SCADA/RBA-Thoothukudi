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
local alphaFact = WR.read(dev, "ALPHA_PR")
if is_nan(alphaFact) then alphaFact = 1 end
local prMin = WR.read(dev, "PR_MIN")
if is_nan(prMin) then prMin = 0 end
local prDay = WR.read(dev, "PR_DAY")
if is_nan(prDay) then prDay = 0 end
local cuf = WR.read(dev, "CUF")
if is_nan(cuf) then cuf = 0 end
local pacn = pac / (settings.PLANT.dcCapacity / 1000)
if is_nan(pacn) then pacn = 0 end
local eae1 = WR.read(dev, "EAE")
if eae1 > 0 then WR.setProp(dev, "EAE_DAY", eae1) end
local eai = WR.read(dev, "EAI")
local eae = WR.read(dev, "EAE")
local eaiDay = WR.read(dev, "EAI_DAY")
local eaeDay = WR.read(dev, "EAE_DAY")
if not(pacOld) then pacOld = WR.read(dev, "PAC_MAX") end
startTime = startTime or {}
startTime[dev] = startTime[dev] or {ts=WR.read(dev, "PLANT_START_TIME")}
if is_nan(startTime[dev].ts) then startTime[dev].ts = 0 end
startTime1 = startTime1 or {}
startTime1[dev] = startTime1[dev] or {ts=WR.read(dev, "PLANT_SUNRISE_TIME")}
if is_nan(startTime1[dev].ts) then startTime1[dev].ts = 0 end
stopTime = stopTime or {}
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

if (pac > 0) then
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

------------------------ CUF Calculation Start --------------------------------

local cuf = ((eaeDay) / ((settings.PLANT.acCapacity / 1000) * 24)) * 100
if is_nan(cuf) then cuf = 0 end
WR.setProp(dev, "CUF", cuf)

------------------------ CUF Calculation End ----------------------------------

------------------------ Co2  Calculation Start --------------------------------

local co2 = ((eaeDay * 1000) * 0.000782)
if is_nan(co2) then c02 = 0 end
WR.setProp(dev, "CO2_REDUCTION", co2)

------------------------ co2 Calculation End ----------------------------------

------------------------ Diesel  Calculation Start --------------------------------

local diesel = ((eaeDay * 1000) * 0.099)
if is_nan(diesel) then diesel = 0 end
WR.setProp(dev, "DIESEL_REDUCTION", co2)

------------------------ DIESEL Calculation End ----------------------------------

------------------------ trees  Calculation Start --------------------------------

local trees = ((co2 * 9.44)/56)
if is_nan(trees) then trees = 0 end
WR.setProp(dev, "TREES_PLANTED", trees)

------------------------ trees Calculation End ----------------------------------



------------------------- Plant Net Energy Start ------------------------------

WR.setProp(dev, "EAN", (eae - eai))
WR.setProp(dev, "EAN_DAY", (eaeDay - eaiDay))

------------------------- Plant Net Energy End --------------------------------
--------------------- Sunrise & Sunset Time Calculation Start ----------------

if (radiation > 20) then
 if (startTime1[dev].ts == 0) then
  startTime1[dev].ts = (now + 19800)
 end
 stopTime1[dev].againStart = 1
elseif ((radiation <= 20) and  (startTime1[dev].ts ~= 0) and ((stopTime1[dev].againStart == 1) or (stopTime1[dev].ts == 0))) then
 stopTime1[dev].ts = (now + 19800)
 stopTime1[dev].againStart = 0
end
WR.setProp(dev, "PLANT_SUNRISE_TIME", startTime1[dev].ts)
WR.setProp(dev, "PLANT_SUNSET_TIME", stopTime1[dev].ts)

local sunriseTime = WR.read(dev, "PLANT_SUNRISE_TIME")

WR.setProp(dev, "PLANT_SUNRISE_TIME_CALC", sunriseTime)       
       
--------------------- Sunrise & Sunset Time Calculation End ------------------

----------------------- Normailised Energy Start ------------------------------

WR.setProp(dev, "EAEN_DAY", (eaeDay / (settings.PLANT.dcCapacity / 1000)))

----------------------- Normailised Energy End --------------------------------
--[[
------------------------ PR Calculation Start ---------------------------------

plantAlarm = plantAlarm or {}
plantAlarm[dev] = plantAlarm[dev] or {tsp=now}

--print("now = ",now)
--print("plantAlarm["..dev.."].tsp = ",plantAlarm[dev].tsp)

local prNow = 0
local prAlarm = 0
if ((radiation > settings.PLANT.prRealRadSetpoint) and (pac >= 0)) then
 prNow = (((pac * 1000) / settings.EM[devS].dcCapacity) / (radiation / 1000)) * 100
 if is_nan(prNow) then prNow = 0 end
 if (prNow > 100) then prNow = 100 end
 if ((pr < settings.PLANT.prAlarmSetpoint) and (radiation > settings.PLANT.prAlarmRadSetpoint)) then
  prAlarm = 1
 end
end
if (prAlarm == 1) then
 if ((now-plantAlarm[dev].tsp) < settings.PLANT.prAlarmTimeSetpoint) then prAlarm  = 0 end
else
 plantAlarm[dev].tsp = now
 prAlarm = 0
end
local prDayNow = ((((eaeDay) * 1000) / settings.EM[devS].dcCapacity) / radiationDay) * 100
if is_nan(prDayNow) then prDayNow = prDay end
if (prDayNow > 100) then prDayNow = 100 end
if ((radiation > settings.EM.prMinRadSetpoint) and ((pr < prMin) or (prMin == 0))) then
 prMin = pr
end
WR.setProp(dev, "PR", prNow)
WR.setProp(dev, "PR_MAX", pr)
WR.setProp(dev, "PR_MIN", prMin)
WR.setProp(dev, "PR_Alarm", prAlarm)
WR.setProp(dev, "PR_DAY", prDayNow)

------------------------ PR Calculation End -----------------------------------

----------------------- Check Midnight Start ---------------------------------

checkMidnight = checkMidnight or {}
checkMidnight[dev] = checkMidnight[dev] or {ts=now}
if (os.date("*t", checkMidnight[dev].ts).hour > os.date("*t", now).hour) then
startTime[dev].ts = 0
stopTime[dev].ts = 0
opTime[dev].tson = 0
end
checkMidnight[dev].ts = now

checkMidnight = checkMidnight or {}
checkMidnight[dev] = checkMidnight[dev] or {ts=now}
if (os.date("*t", checkMidnight[dev].ts).hour > os.date("*t", now).hour) then
prDay = 0
expGen1Cum[dev].day = 0
expGen2Cum[dev].day = 0
genLossCum[dev].day = 0
eaeDayNoRad[dev].day = 0
eaeDayNoRad[dev].last = 0
startTime[dev].ts = 0
stopTime[dev].ts = 0
gridAvailability[dev].tson = 0
gridAvailability[dev].tsoff = 0
opTime[dev].tson = 0
WR.setProp(dev, "PAC_MAX_TIME", 0)
commStatus[dev].HourOn = 0
commStatus[dev].HourOff = 0
commStatus[dev].DayOn = 0
commStatus[dev].DayOff = 0
runningHour[dev].devHourOn = 0
runningHour[dev].devHourOff = 0
WR.setProp(dev, "PR_DAY", prDay)
WR.setProp(dev, "EXP_GEN_CUM_1", expGen1Cum[dev].day)
WR.setProp(dev, "EXP_GEN_CUM_2", expGen2Cum[dev].day)
WR.setProp(dev, "GEN_LOSS_CUM", genLossCum[dev].day)
WR.setProp(dev, "EAE_DAY_NO_RAD", eaeDayNoRad[dev].day)
end
checkMidnight[dev].ts = now

if (os.date("*t", checkMidnight[dev].ts).hour < os.date("*t", now).hour) then
commStatus[dev].HourOn = 0
commStatus[dev].HourOff = 0
end
checkMidnight[dev].ts = now

--if ((os.date("*t", now).hour == 23) and (os.date("*t", now).min > 55)) then
if (((os.date("*t", now).hour == 23) and (os.date("*t", now).min > 55)) or ((os.date("*t", now).hour == 0) and (os.date("*t", now).min < 30))) then
WR.setProp(dev, "PLANT_START_TIME", 0)
WR.setProp(dev, "PLANT_STOP_TIME", 0)
WR.setProp(dev, "OPERATIONAL_TIME", 0)
--WR.setProp(dev, "EXP_GEN_CUM_1", 0)
--WR.setProp(dev, "EXP_GEN_CUM_2", 0)
WR.setProp(dev, "TOTAL_EAE_DAY", 0)
WR.setProp(dev, "SPECIFIC_YIELD", 0)
WR.setProp(dev, "TOTAL_SPECIFIC_YIELD", 0)
WR.setProp(dev, "PLANT_LOAD_DAY", 0)
WR.setProp(dev, "PR_DAY", 0)
WR.setProp(dev, "GEN_LOSS_CUM", 0)
end
------------------------ Check Midnight End -----------------------------------

------------------------ GEN LOSS Calculation Start ---------------------------

eaeDayNoRad = eaeDayNoRad or {}
eaeDayNoRad[dev] = eaeDayNoRad[dev] or {day=WR.read(dev, "EAE_DAY_NO_RAD"), last=eaeDay}
if (is_nan(eaeDayNoRad[dev].day)) then eaeDayNoRad[dev].day = 0 end

if is_nan(radiation) then
 radiation = 0
 eaeDayNoRad[dev].day = eaeDayNoRad[dev].day + (eaeDay - eaeDayNoRad[dev].last)
end
eaeDayNoRad[dev].last = eaeDay
WR.setProp(dev, "EAE_DAY_NO_RAD", eaeDayNoRad[dev].day)

expGen1Now = ((((settings.PLANT.dcCapacity * radiation) / 1000) * 0.8) * alphaFact)
expGen1Cum = expGen1Cum or {}
expGen1Cum[dev] = expGen1Cum[dev] or {ts=now, day=WR.read(dev, "EXP_GEN_CUM_1")}
if (is_nan(expGen1Cum[dev].day)) then expGen1Cum[dev].day = 0 end

expGen1Cum[dev].day = expGen1Cum[dev].day + (((now-expGen1Cum[dev].ts) * expGen1Now) / (60 * 60))
expGen1Cum[dev].ts = now
WR.setProp(dev, "EXP_GEN_CUM_1", expGen1Cum[dev].day)
WR.setProp(dev, "EXP_GEN", expGen1Now)

expGen2Now = ((((settings.PLANT.dcCapacity * radiation) / 1000) * 0.8) * alphaFact)
expGen2Cum = expGen2Cum or {}
expGen2Cum[dev] = expGen2Cum[dev] or {ts=now, day=WR.read(dev, "EXP_GEN_CUM_2")}
if (is_nan(expGen2Cum[dev].day)) then expGen2Cum[dev].day = 0 end

genLossCum = genLossCum or {}
genLossCum[dev] = genLossCum[dev] or {ts=now, day=WR.read(dev, "GEN_LOSS_CUM")}
if (is_nan(genLossCum[dev].day)) then genLossCum[dev].day = 0 end

local expGen80 = 0
local genLoss = 0

local paclimit1 = 0 --WR.read(dev, "PAC_LIMIT1")
local paclimit2 = 0 --WR.read(dev, "PAC_LIMIT2")

if ((radiation > 25)) then
 expGen80 = (((settings.PLANT.dcCapacity * radiation) / 1000) * 0.8)
 genLoss = (expGen80 - (pac * 1000))
 gridOut = 1
 if (genLoss < 0) then genLoss = 0 end

 genLossCum[dev].day = genLossCum[dev].day + (((now-genLossCum[dev].ts) * genLoss) / (60 * 60))

 expGen2Now = 0
end

genLossCum[dev].ts = now
WR.setProp(dev, "GEN_LOSS_CUM", genLossCum[dev].day)
WR.setProp(dev, "GEN_LOSS", genLoss)
WR.setProp(dev, "EXP_GEN80", expGen80)

expGen2Cum[dev].day = expGen2Cum[dev].day + (((now-expGen2Cum[dev].ts) * expGen2Now) / (60 * 60))
expGen2Cum[dev].ts = now
WR.setProp(dev, "EXP_GEN_CUM_2", expGen2Cum[dev].day)

------------------------ GEN LOSS Calculation End ---------------------------

--]]

