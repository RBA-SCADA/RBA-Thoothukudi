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
local datw = os.date ("%u")
--print("datw=", datw)

------------------------ Define Function Start --------------------------------

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

-- function to log events in file
function logEvent(file, msg)
 file = io.open(file,"a")
 now = socket.gettime()
 if file~=nil then
  file:write(os.date("%a %b %d %Y %X",currTime)..":"..string.sub(now*1000, 11, 13).." "..msg.."\n")
 end
 file:close()
end

--[[--
function logCsv(file, msg)
 file1 = io.open(file,"r")
 if file1 == nil then
  fileName = filePath.."/"..anlagen_id.."_DG_LOG_IM01_"..string.sub(now, 1, 10).."_3.csv"
  file = fileName
  file1 = io.open(file,"a")
  file1:write(anlagen_id..",SN:DG_LOG_IMC01,DG_LOG,0.0.0.0,3".."\n")
  -- log format ts, dg01Pac, dg02Pac, pvPac, pacLimit, gridConnSt, pacLimitSet, gridConnSet
  file1:write("TS,CASE,DG01_PAC,PV_PAC,PAC_LIMIT,GRID_CONNECT,PAC_LIMIT_WRITE,GRID_CONNECT_WRITE".."\n")
 end
 file1:close()

 file = io.open(file,"a")
 now = socket.gettime()
 if file~=nil then
  file:write(string.sub(now, 1, 10)..","..msg.."\n")
 end
 file:close()
end
--]]--

 function logCsvZE(file, msg)
 file2 = io.open(file,"r")
 if file2 == nil then
  fileNameZE = filePath.."/"..anlagen_id.."_ZE_LOG_IM_"..string.sub(now, 1, 10).."_3.csv"
  file = fileNameZE
  file2 = io.open(file,"a")
  file2:write(anlagen_id..",SN:ZE_LOG_IM_,ZE_LOG,0.0.0.0,5".."\n")
  --log format ts, dg01Pac, dg02Pac, pvPac, pacLimit, gridConnSt, cmdEnableSt, pacLimitSet, gridConnSet, cmdEnableSet
  file2:write("TS,CASE,ZE_PAC,ZE01_PF,DG01_PAC,DG01_PAC,PV_PAC,PAC_LIMIT,GRID_CONNECT,CMD_ENABLE_WRITE,PAC_LIMIT_WRITE,CMD_ENABLE".."\n")
 end
 file2:close()

 file = io.open(file,"a")
 now = socket.gettime()
 if file~=nil then
  file:write(string.sub(now, 1, 10)..","..msg.."\n")
 end
 file:close()
end


--[[
function logCsvQAC(file, msg)
 file3 = io.open(file,"r")
 if file3 == nil then
  fileNameQAC = filePath.."/"..anlagen_id.."_QAC_LOG_IM02_"..string.sub(now, 1, 10).."_4.csv"
  file = fileNameQAC
  file3 = io.open(file,"a")
  file3:write(anlagen_id..",SN:QAC_LOG_IMC02,QAC_LOG,0.0.0.0,4".."\n")
  -- log format ts, dg01Pac, dg02Pac, pvPac, pacLimit, gridConnSt, pacLimitSet, gridConnSet
  file3:write("TS,CASE,ZE_QAC,PV_QAC,QAC_LIMIT,GRID_CONNECT,QAC_LIMIT_WRITE,GRID_CONNECT_WRITE".."\n")
 end
 file3:close()

 file = io.open(file,"a")
 now = socket.gettime()
 if file~=nil then
  file:write(string.sub(now, 1, 10)..","..msg.."\n")
 end
 file:close()
end
--]]--
------------------------ Define Function End ----------------------------------

-------------------------- Read Setpoints Start -------------------------------

if not(settings) then
 --print ("Inside file loading")
 settingsConfig = assert(io.open("/mnt/jffs2/solar/modbus/Settings.txt", "r"))
 settingsJson = settingsConfig:read("*all")
 settings = cjson.decode(settingsJson)
 settingsConfig:close()
 filePath = "/mnt/jffs2/dglog"
 --fileName = filePath.."/"..anlagen_id.."_DG_LOG_IM01_"..string.sub(now, 1, 10).."_2.csv"
 fileNameZE = filePath.."/"..anlagen_id.."_ZE_LOG_IM_"..string.sub(now, 1, 10).."_3.csv"
 --fileNameQAC = filePath.."/"..anlagen_id.."_QAC_LOG_IM02_"..string.sub(now, 1, 10).."_4.csv"
 filePackts = now
 dgCtlDev = {}
 lastDev = "SN:INV08"
 caseReset = 5
 --case1DG = caseReset
 --case2DG = caseReset
 --case3DG = caseReset
 --case4DG = caseReset
 --case5DG = caseReset
 --case6DG = caseReset
 --case7DG = caseReset
 --case8DG = caseReset
 case1ZE = caseReset
 case2ZE = caseReset
 case3ZE = caseReset
 case4ZE = caseReset
 case5ZE = caseReset
 --case1ZEQ = caseReset
 --case2ZEQ = caseReset
 --case3ZEQ = caseReset
 --case4ZEQ = caseReset
 --case5ZEQ = caseReset
end

if not(settings.INVERTER[devS].dcCapacity and settings.INVERTER[devS].prRealRadSetpoint and settings.INVERTER[devS].prdcRealRadSetpoint and settings.INVERTER[devS].Module_inseries and settings.INVERTER[devS].Module_voc) then
 --print ("Data loading")
 settings.INVERTER[devS].dcCapacity = settings.INVERTER[devS].dcCapacity or settings.INVERTER.dcCapacity or 66.0
 settings.INVERTER[devS].prRealRadSetpoint = settings.INVERTER[devS].prRealRadSetpoint or settings.INVERTER.prRealRadSetpoint or 250.0
 settings.INVERTER[devS].prdcRealRadSetpoint = settings.INVERTER[devS].prdcRealRadSetpoint or settings.INVERTER.prdcRealRadSetpoint or 600.0
 settings.INVERTER[devS].Module_inseries = settings.INVERTER[devS].Module_inseries or settings.INVERTER.Module_inseries or 20.0
 settings.INVERTER[devS].Module_voc = settings.INVERTER[devS].Module_voc or settings.INVERTER.Module_voc or 45.82

 --[[--
 settings.PLANT.dg01Capacity = settings.PLANT.dg01Capacity or 400
 settings.PLANT.dg01MinLoad = settings.PLANT.dg01MinLoad or 30.0
 settings.PLANT.dg01ForceTune = settings.PLANT.dg01ForceTune or 2
 settings.PLANT.dg01CriticalLoad = settings.PLANT.dg01CriticalLoad or 10.0
 dg01MinLoad = (settings.PLANT.dg01Capacity * settings.PLANT.dg01MinLoad) / 100
 dg01CrititicalLoad = (settings.PLANT.dg01Capacity * settings.PLANT.dg01CriticalLoad) / 100
 dg01ForceTuneDown = (dg01MinLoad - ((settings.PLANT.dg01Capacity * settings.PLANT.dg01ForceTune) / 100))
 dg01ForceTuneUp = (dg01MinLoad + ((settings.PLANT.dg01Capacity * settings.PLANT.dg01ForceTune) / 100))
 dg01Threshold = (settings.PLANT.dg01Capacity * settings.PLANT.dg01Threshold) / 100 or 1

 tuneStep = settings.PLANT.tuneStep or 1
 pacLimitResetCnt = 0

 --invAcCapacityS1 = settings.PLANT.invAcCapacityS1 or 20
 --]]--
 totalInvertersAcCapacity = settings.PLANT.totalInvertersAcCapacity or 3
 zeMinLoad = settings.PLANT.zeMinLoad or 10
 zeCriticalLoad = settings.PLANT.zeCriticalLoad or 9
 zeThreshold = settings.PLANT.zeThreshold or 5
 tuneStep = settings.PLANT.tuneStep or 1
 pacLimitResetCnt = 0
--[[
 zeQMinLoad = settings.PLANT.zeQMinLoad or 1
 zeQCriticalLoad = settings.PLANT.zeQCriticalLoad or 3
 zeQThreshold = settings.PLANT.zeQThreshold or 3
 qacGRSetCmd = settings.PLANT.qacGRSetCmd or 5
 qacDecConstCmd = settings.PLANT.qacDecConstCmd or 1
 qacIncConstCmd = settings.PLANT.qacIncConstCmd or 1
 qacMaxSetCmd = settings.PLANT.qacMaxSetCmd1 or 66
--]]--
 dgCtlDev = dgCtlDev or {}
 dgCtlDev[dev] = dev
 CHECKDATATIME(dev, now, "PR_DAY")
end

--------------------------- Read setpoints End --------------------------------

------------------------- Pack CSV For Portal Start ---------------------------

if (now > (filePackts + 300)) then
 os.execute("cd "..filePath.."; for f in *.csv; do mv -- \"$f\" \"${f%}.unsent\"; done")
 --fileName = filePath.."/"..anlagen_id.."_DG_LOG_IM01_"..string.sub(now, 1, 10).."_2.csv"
 fileNameZE = filePath.."/"..anlagen_id.."_ZE_LOG_IM_"..string.sub(now, 1, 10).."_3.csv"
 --fileNameQAC = filePath.."/"..anlagen_id.."_QAC_LOG_IM02_"..string.sub(now, 1, 10).."_4.csv"
 filePackts = now
end

-------------------------- Pack CSV For Portal End ----------------------------

---------------------- Reset DG & ZE case Start -------------------------------

if (dev == lastDev) then
-- case1DG = caseReset
-- case2DG = caseReset
-- case3DG = caseReset
-- case4DG = caseReset
-- case5DG = caseReset
-- case6DG = caseReset
-- case7DG = caseReset
-- case8DG = caseReset

 case1ZE = caseReset
 case2ZE = caseReset
 case3ZE = caseReset
 case4ZE = caseReset
 case5ZE = caseReset

 --case1ZEQ = caseReset
 --case2ZEQ = caseReset
 --case3ZEQ = caseReset
 --case4ZEQ = caseReset
 --case5ZEQ = caseReset
end

----------------------- Reset DG & ZE case End --------------------------------

---------------------- COMMUNICATION STATUS Start -----------------------------

if WR.isOnline(dev) then
 WR.setProp(dev, "COMMUNICATION_STATUS", 0)
else
 WR.setProp(dev, "COMMUNICATION_STATUS", 1)
end

---------------------- COMMUNICATION STATUS End -------------------------------

------------------------ Factor Calculation Start------------------------------

local pac = WR.read(dev, "PAC")
local uac1 = WR.read(dev, "UAC1")
local uac2 = WR.read(dev, "UAC2")
local uac3 = WR.read(dev, "UAC3")
local uac12 = WR.read(dev, "UAC12")
local uac23 = WR.read(dev, "UAC23")
local uac31 = WR.read(dev, "UAC31")
local udc1 = WR.read(dev, "UDC1")
local udc2 = WR.read(dev, "UDC2")
local udc3 = WR.read(dev, "UDC3")
local udc4 = WR.read(dev, "UDC4")
local udc5 = WR.read(dev, "UDC5")
local udc6 = WR.read(dev, "UDC6")
local eae = WR.read(dev, "AC_ENERGY")
--local eae2 = WR.read(dev, "EAE2")
--local eae3 = WR.read(dev, "EAE3")
--local eae4 = WR.read(dev, "EAE4")
--local eae5 = WR.read(dev, "EAE5")
--local eae6 = WR.read(dev, "EAE6")
--local eae1_day = WR.read(dev, "EAE1_DAY")
--local eae2_day = WR.read(dev, "EAE2_DAY")
--local eae3_day = WR.read(dev, "EAE3_DAY")
local eaedaykwh = WR.read(dev, "EAE_DAY_kWh")
local eaedayMwh = WR.read(dev, "EAE_DAY_MWh")
local eaedaykvah = WR.read(dev, "EAE_DAY_kVAh")
local eaedaymvah = WR.read(dev, "EAE_DAY_MVAh")

local eaekwh = WR.read(dev, "EAE_kWh")
local eaeMwh = WR.read(dev, "EAE_MWh")
local eaeGwh = WR.read(dev, "EAE_GWh")
local eaekvah = WR.read(dev, "EAE_kVAh")
local eaemvah = WR.read(dev, "EAE_MVAh")
local eaeGvah = WR.read(dev, "EAE_GVAh")
local uac = ((uac12+uac23+uac31)/3)
local udc = ((udc1 + udc2 + udc3)/3)
local pac1 = pac / 3
local pac2 = pac / 3
local pac3 = pac / 3
local uacln = ((uac1+uac2+uac3)/3)
--local eae = (eae1 + eae2 + eae3)
--local eae_day = (eae1_day + eae2_day + eae3_day )
WR.setProp(dev, "EAE1", eae)
local eae1 = WR.read(dev, "EAE1")
if eae1 ~= 0 then WR.setProp(dev, "EAE1_DAY", eae1) end
local pvPac = 0
   for devV in pairs(dgCtlDev) do
    local invPac = WR.read(devV, "PAC")
    if not(is_nan(invPac)) then pvPac = pvPac + invPac end
          WR.setProp(dev, "TOTALS2PAC", pvPac)
   end
WR.setProp(dev, "UAC",       uac)
WR.setProp(dev, "UDC",       udc)
WR.setProp(dev, "PAC1",      pac1)
WR.setProp(dev, "PAC2",      pac2)
WR.setProp(dev, "PAC3",      pac3)
WR.setProp(dev, "UACLN",     uacln)
--WR.setProp(dev, "EAE",       eae)
--WR.setProp(dev, "EAE_DAY",   eae_day)
WR.setProp(dev, "TOTAL_EAE", ((eaekwh/1000)+eaeMwh+(eaeGwh*1000)))
WR.setProp(dev, "TOTAL_EAE_DAY", ((eaedaykwh/1000)+eaedayMwh))
WR.setProp(dev, "TOTAL_EAE_MVAh", ((eaekvah/1000)+eaemvah+(eaeGvah*1000)))
WR.setProp(dev, "TOTAL_EAE_DAY_MVAh", ((eaedaykvah/1000)+eaedaymvah))

------------------------ Factor Calculation END --------------------------------


------------------- Inverter Datapoint Calculation Start ----------------------

local totaleae = WR.read(dev, "TOTAL_EAE")
local totaleaeday = WR.read(dev, "TOTAL_EAE_DAY")
local igbtTemp1 = WR.read(dev, "IGBT_TEMP_M1")
local igbtTemp2 = WR.read(dev, "IGBT_TEMP_M2")
local igbtTemp3 = WR.read(dev, "IGBT_TEMP_M3")
local igbtTemp4 = WR.read(dev, "IGBT_TEMP_M4")

local igbtTemp = ((igbtTemp1 + igbtTemp2 + igbtTemp3 + igbtTemp4) / 4)
WR.setProp(dev, "IGBT_TEMP", igbtTemp)
WR.setProp(dev, "IGBT_TEMP_MAX", igbtTemp)
WR.setProp(dev, "EAE_YDAY", (totaleae - totaleaeday))
--local sac = math.sqrt(((pac * pac) + (qac * qac)))
--WR.setProp(dev, "SAC", sac)
--local pdc = ((idc * udc) / 1000)
--WR.setProp(dev, "PDC", pdc)

local cuf = (totaleaeday) / (20 * 24)
if is_nan(cuf) then cuf = 0 end
WR.setProp(dev, "CUF", cuf)

local Sy = WR.read(dev, "SPECIFIC_YIELD")
if is_nan(Sy) then Sy = 0 end

local invSyNow = ((totaleaeday/1000) / settings.INVERTER[devS].dcCapacity)
if ((is_nan(invSyNow)) or (invSyNow < 0) or (invSyNow > 10)) then
 invSyNow = Sy
end

------------------- Inverter Datapoint Calculation End ------------------------


------------------------ Read Required Data Start -----------------------------

startTime = startTime or {}
startTime[dev] = startTime[dev] or {ts=WR.read(dev, "START_TIME")}
if is_nan(startTime[dev].ts) then startTime[dev].ts = 0 end
stopTime = stopTime or {}
stopTime[dev] = stopTime[dev] or {ts=WR.read(dev, "STOP_TIME"), againStart=0}
if is_nan(stopTime[dev].ts) then stopTime[dev].ts = 0 end
if is_nan(stopTime[dev].againStart) then stopTime[dev].againStart = 0 end
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

local radiationCum = WR.read(dev, "SOLAR_RADIATION_CUM")
local radiation = WR.read(dev, "RADIATION")
local prDay = WR.read(dev, "PR_DAY")
if is_nan(prDay) then prDay = 0 end
local pr = WR.read(dev, "PR")
if is_nan(pr) then pr = 0 end
local eaeDay = WR.read(dev, "EAE_DAY")
local udc = WR.read(dev, "UDC")
if is_nan(udc) then udc = 0 end

------------------------ Read Required Data End -------------------------------

------------------------ EFFICIENCY Calculation Start -------------------------

local Inv_pac = WR.read(dev, "PAC")
if is_nan(Inv_pac) then Inv_pac = 0 end
local Inv_pdc = WR.read(dev, "PDC")
if is_nan(Inv_pdc) then Inv_pdc = 0 end

if(Inv_pac == 0 and Inv_pdc == 0)then
 WR.setProp(dev, "EFFICIENCY", 0)
else
 WR.setProp(dev, "EFFICIENCY", ((Inv_pac/Inv_pdc)*100))
end
if is_nan(WR.read(dev, "EFFICIENCY")) then WR.setProp(dev, "EFFICIENCY", 0) end

----------------------- EFFICIENCY Calculation END ----------------------------
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


----------------- Inverter Start & Stop Time Calculation Start ----------------

if (pac > 0) then
if (startTime[dev].ts == 0) then
 startTime[dev].ts = (now)
end
stopTime[dev].againStart = 1
elseif ((pac <= 0) and (startTime[dev].ts ~= 0) and ((stopTime[dev].againStart == 1) or (stopTime[dev].ts == 0))) then
stopTime[dev].ts = (now)
stopTime[dev].againStart = 0
end
WR.setProp(dev, "START_TIME", startTime[dev].ts)
WR.setProp(dev, "STOP_TIME", stopTime[dev].ts)

--[[
if (pac > 0) then
 if (startTime[dev].ts == 0) then
  startTime[dev].ts = ((hour * 60 * 60) + (min * 60) + sec)
 end
 stopTime[dev].againStart = 1
elseif ((pac <= 0) and (startTime[dev].ts ~= 0) and ((stopTime[dev].againStart == 1) or (stopTime[dev].ts == 0))) then
 stopTime[dev].ts = ((hour * 60 * 60) + (min * 60) + sec)
 stopTime[dev].againStart = 0
end
WR.setProp(dev, "START_TIME", startTime[dev].ts)
WR.setProp(dev, "STOP_TIME", stopTime[dev].ts)
--]]
----------------- Inverter Start & Stop Time Calculation End ------------------

------------------------ PR Calculation Start ---------------------------------

if(radiation >= (settings.INVERTER[devS].prRealRadSetpoint)) then   --if 250 & ABOVE
 local prDayNow = (((eaeDay) / settings.INVERTER[devS].dcCapacity) / radiationCum) * 100
 if((is_nan(prDayNow)) or (prDayNow < 0) or (prDayNow > 100)) then
  prDayNow = prDay
 end
 WR.setProp(dev, "PR_DAY", prDayNow)
else
 WR.setProp(dev, "PR_DAY", 0/0)
end

if(radiation >= (settings.INVERTER[devS].prRealRadSetpoint)) then   -- if 250 & ABOVE
 local prNow = (((Inv_pac *1000) / (settings.INVERTER[devS].dcCapacity) / radiation)) * 100
 if((is_nan(prNow)) or (prNow < 0) or (prNow > 100)) then
   prNow = pr
 end
 WR.setProp(dev, "PR", prNow)
else
 WR.setProp(dev, "PR", 0/0)
end

if(radiation >= (settings.INVERTER[devS].prdcRealRadSetpoint)) then -- if 600 & ABOVE
 local prdc = (udc / ((settings.INVERTER[devS].Module_inseries) * (settings.INVERTER[devS].Module_voc)))*100
 if is_nan(prdc) then prdc = 0 end
  WR.setProp(dev, "PR_DC", prdc)
else
 WR.setProp(dev, "PR_DC", 0/0)
end

------------------------ PR Calculation End -----------------------------------



