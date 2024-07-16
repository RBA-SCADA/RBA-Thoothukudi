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
  file1:write(anlagen_id..",SN:DG_LOG_IMC01,DG_LOG,0.0.0.0,2".."\n")
  -- log format ts, dg01Pac, dg02Pac, pvPac, pacLimit, gridConnSt, pacLimitSet, gridConnSet
  file1:write("TS,CASE,DG01_PAC,DG02_PAC,DG03_PAC,TOTAL_DG_PAC,PV_PAC,PAC_LIMIT,GRID_CONNECT,PAC_LIMIT_WRITE,GRID_CONNECT_WRITE".."\n")
 end
 file1:close()
 file = io.open(file,"a")
 now = socket.gettime()
 if file~=nil then
  file:write(string.sub(now, 1, 10)..","..msg.."\n")
 end
 file:close()
end

]]--

function logCsvZE(file, msg)
 file2 = io.open(file,"r")
 if file2 == nil then
  fileNameZE = filePath.."/"..anlagen_id.."_ZE_LOG_IM01_"..string.sub(now, 1, 10).."_4.csv"
  file = fileNameZE
  file2 = io.open(file,"a")
  file2:write(anlagen_id..",SN:ZE_LOG_IMC01,ZE_LOG,0.0.0.0,3".."\n")
  -- log format ts, dg01Pac, dg02Pac, pvPac, pacLimit, gridConnSt, pacLimitSet, gridConnSet
  file2:write("TS,CASE,ZE_PAC,PV_PAC,PAC_LIMIT,GRID_CONNECT,PAC_LIMIT_WRITE,GRID_CONNECT_WRITE".."\n")
 end
 file2:close()
 file = io.open(file,"a")
 now = socket.gettime()
 if file~=nil then
  file:write(string.sub(now, 1, 10)..","..msg.."\n")
 end
 file:close()
end
------------------------ Define Function End ----------------------------------
--[[--------------------- Total Inverter Online calculation start --------------
  local inv1_Pac = WR.read("SN:INV01", "COMMUNICATION_STATUS")
  local inv2_Pac = WR.read("SN:INV02", "COMMUNICATION_STATUS")
  local inv3_Pac = WR.read("SN:INV03", "COMMUNICATION_STATUS")
  local inv4_Pac = WR.read("SN:INV04", "COMMUNICATION_STATUS")
  local inv5_Pac = WR.read("SN:INV05", "COMMUNICATION_STATUS")
  local inv6_Pac = WR.read("SN:INV06", "COMMUNICATION_STATUS")
  local inv7_Pac = WR.read("SN:INV07", "COMMUNICATION_STATUS")
  local totalInvertersOnline = 0
  local totalInvertersOnline1 = 0
  if (inv1_Pac < 1) then totalInvertersOnline = totalInvertersOnline + 1 end
  if (inv2_Pac < 1) then totalInvertersOnline = totalInvertersOnline + 1 end
  if (inv3_Pac < 1) then totalInvertersOnline = totalInvertersOnline + 1 end
  if (inv4_Pac < 1) then totalInvertersOnline = totalInvertersOnline + 1 end
  if (inv5_Pac < 1) then totalInvertersOnline = totalInvertersOnline + 1 end
  if (inv6_Pac < 1) then totalInvertersOnline = totalInvertersOnline + 1 end
  WR.setProp("SN:INV01", "TOTAL_INV_ONLINE", totalInvertersOnline)
  WR.setProp("SN:INV02", "TOTAL_INV_ONLINE", totalInvertersOnline)
  WR.setProp("SN:INV03", "TOTAL_INV_ONLINE", totalInvertersOnline)
  WR.setProp("SN:INV04", "TOTAL_INV_ONLINE", totalInvertersOnline)
  WR.setProp("SN:INV05", "TOTAL_INV_ONLINE", totalInvertersOnline)
  WR.setProp("SN:INV06", "TOTAL_INV_ONLINE", totalInvertersOnline)
 if (inv7_Pac < 1) then
 local last = 50
 if (inv7_Pac < 1) then totalInvertersOnline1 = totalInvertersOnline + 1 end
 WR.setProp("SN:INV07", "TOTAL_INV_ONLINE", totalInvertersOnline1)
 else
 last = 0
 WR.setProp("SN:INV07", "TOTAL_INV_ONLINE", totalInvertersOnline)
 end
-------------------------------------------------------------------------------------]]--
-------------------------- Read Setpoints Start -------------------------------
if not(settings) then
 --print ("Inside file loading")
 settingsConfig = assert(io.open("/mnt/jffs2/solar/modbus/Settings.txt", "r"))
 settingsJson = settingsConfig:read("*all")
 settings = cjson.decode(settingsJson)
 settingsConfig:close()
 filePath = "/mnt/jffs2/dglog"
 --fileName = filePath.."/"..anlagen_id.."_DG_LOG_IM01_"..string.sub(now, 1, 10).."_3.csv"
 fileNameZE = filePath.."/"..anlagen_id.."_ZE_LOG_IM01_"..string.sub(now, 1, 10).."_4.csv"
 filePackts = now
 dgCtlDec = {}
 lastDev = "SN:INV05"
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
end
if not(settings.INVERTER[devS].dcCapacity and settings.INVERTER[devS].prRealRadSetpoint) then
 --print ("Data loading")
 settings.INVERTER[devS].dcCapacity = settings.INVERTER[devS].dcCapacity or settings.INVERTER.dcCapacity or 66.0
 settings.INVERTER[devS].prRealRadSetpoint = settings.INVERTER[devS].prRealRadSetpoint or settings.INVERTER.prRealRadSetpoint or 250.0
 settings.INVERTER[devS].prdcRealRadSetpoint = settings.INVERTER[devS].prdcRealRadSetpoint or settings.INVERTER.prdcRealRadSetpoint or 600.0
 settings.INVERTER[devS].Module_inseries = settings.INVERTER[devS].Module_inseries or settings.INVERTER.Module_inseries or 20.0
 settings.INVERTER[devS].Module_voc = settings.INVERTER[devS].Module_voc or settings.INVERTER.Module_voc or 45.82

 tuneStep = settings.PLANT.tuneStep or 1
 pacLimitResetCnt = 0
 
 --[[
 InvertersAcCapacity = settings.PLANT.InvertersAcCapacityS1 or 110
 zeMinLoad = settings.PLANT.zeMinLoad or 40
 zeCriticalLoad = settings.PLANT.zeCriticalLoad or 30
 zeThreshold = settings.PLANT.zeThreshold or 5

]]--

 dgCtlDev = dgCtlDev or {}
 dgCtlDev[dev] = dev
 CHECKDATATIME(dev, now, "PR_DAY")
end
--------------------------- Read setpoints End --------------------------------
------------------------- Pack CSV For Portal Start ---------------------------
if (now > (filePackts + 300)) then
 os.execute("cd "..filePath.."; for f in *.csv; do mv -- \"$f\" \"${f%}.unsent\"; done")
 --fileName = filePath.."/"..anlagen_id.."_DG_LOG_IM01_"..string.sub(now, 1, 10).."_3.csv"
 fileNameZE = filePath.."/"..anlagen_id.."_ZE_LOG_IM01_"..string.sub(now, 1, 10).."_4.csv"
 filePackts = now
end
-------------------------- Pack CSV For Portal End ----------------------------
---------------------- Reset DG & ZE case Start -------------------------------
if (dev == lastDev) then
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
local iac1 = WR.read(dev, "IAC1")
local iac2 = WR.read(dev, "IAC2")
local iac3 = WR.read(dev, "IAC3")
local uac1 = WR.read(dev, "UAC1")
local uac2 = WR.read(dev, "UAC2")
local uac3 = WR.read(dev, "UAC3")
local idc1 = WR.read(dev, "IDC1")
local idc2 = WR.read(dev, "IDC2")
local idc3 = WR.read(dev, "IDC3")
local idc4 = WR.read(dev, "IDC4")
local idc5 = WR.read(dev, "IDC5")
local idc6 = WR.read(dev, "IDC6")
local idc7 = WR.read(dev, "IDC7")
local idc8 = WR.read(dev, "IDC8")
local idc9 = WR.read(dev, "IDC9")
local udc1 = WR.read(dev, "UDC1")
local udc2 = WR.read(dev, "UDC2")
local udc3 = WR.read(dev, "UDC3")
local udc4 = WR.read(dev, "UDC4")
local udc5 = WR.read(dev, "UDC5")
local udc6 = WR.read(dev, "UDC6")
local udc7 = WR.read(dev, "UDC7")
local udc8 = WR.read(dev, "UDC8")
local udc9 = WR.read(dev, "UDC9")
local pac = WR.read(dev, "PAC")
local qac = WR.read(dev, "QAC")
local iac = (iac1 + iac2 + iac3)
local idc = (idc1 + idc2 + idc3 + idc4 + idc5 + idc6 + idc7 + idc8 + idc9)
local udc = ((udc1 + udc2 + udc3 + udc4 + udc5 + udc6 + udc7 + udc8 + udc9)/9)
local uac12 = (((uac1 + uac2) / 2) * 1.732)
local uac23 = (((uac2 + uac3) / 2) * 1.732)
local uac31 = (((uac3 + uac1) / 2) * 1.732)
local sac = math.sqrt(((pac * pac) + (qac * qac)))
WR.setProp(dev, "IAC",     iac)
WR.setProp(dev, "UAC12",   uac12)
WR.setProp(dev, "UAC23",   uac23)
WR.setProp(dev, "UAC31",   uac31)
WR.setProp(dev, "UACLN",   (uac1+uac2+uac3)/3)
WR.setProp(dev, "UAC",     (uac12+uac23+uac31)/3)
WR.setProp(dev, "IDC",     idc)
WR.setProp(dev, "UDC",     udc)
WR.setProp(dev, "SAC",     sac)
--local Inv_pac = WR.read(dev, "PAC")
--if is_nan(Inv_pac) then Inv_pac = 0 end
local Inv_pdc = WR.read(dev, "PDC")
if is_nan(Inv_pdc) then Inv_pdc = 0 end
if(Inv_pac == 0 and Inv_pdc == 0)then
 WR.setProp(dev, "EFFICIENCY", 0)
else
 WR.setProp(dev, "EFFICIENCY", ((pac/Inv_pdc)*100))
end
if is_nan(WR.read(dev, "EFFICIENCY")) then WR.setProp(dev, "EFFICIENCY", 0) end
----------------------- EFFICIENCY Calculation END ----------------------------
------------------------- Specific Yield Comparison of Inv Start -------------------------
local eaeDay = WR.read(dev, "EAE_DAY")
if is_nan(eaeDay) then eaeDay = 0 end
local Sy = WR.read(dev, "SPECIFIC_YIELD")
if is_nan(Sy) then Sy = 0 end
local invSyNow = ((eaeDay) / settings.INVERTER[devS].dcCapacity)
if ((is_nan(invSyNow)) or (invSyNow < 0) or (invSyNow > 10)) then
 invSyNow = Sy
end
WR.setProp(dev, "SPECIFIC_YIELD", invSyNow)
------------------------- Specific Yield Comparison of Inv End --------------------------
------------------------ Total Data Points Start -------------------------------
if (dev == lastDev) then
  local pvPac_T = 0
  local pvQac_T = 0
  local pvSac_T = 0
  local pvIac_T = 0
  local pvPdc_T = 0
  local pvUac_T = 0
  local pvFac_T = 0
  local pvPF_T = 0
  local pvEfficiency_T = 0
  local pvEae_T = 0
  local pvEaeday_T = 0
  for devV in pairs(dgCtlDev) do
   local invEae_T = WR.read(devV, "EAE")
   if not(is_nan(invEae_T)) then pvEae_T = pvEae_T + invEae_T end
   local invEaeday_T = WR.read(devV, "EAE_DAY")
   if not(is_nan(invEaeday_T)) then pvEaeday_T = pvEaeday_T + invEaeday_T end
   local invPac_T = WR.read(devV, "PAC")
   if not(is_nan(invPac_T)) then pvPac_T = pvPac_T + invPac_T end
   local invQac_T = WR.read(devV, "QAC")
   if not(is_nan(invQac_T)) then pvQac_T = pvQac_T + invQac_T end
   local invSac_T = WR.read(devV, "SAC")
   if not(is_nan(invSac_T)) then pvSac_T = pvSac_T + invSac_T end
   local invUac_T = WR.read(devV, "UAC")
   if not(is_nan(invUac_T)) then pvUac_T = pvUac_T + invUac_T end
   local invIac_T = WR.read(devV, "IAC")
   if not(is_nan(invIac_T)) then pvIac_T = pvIac_T + invIac_T end
   local invFac_T = WR.read(devV, "FAC")
   if not(is_nan(invFac_T)) then pvFac_T = pvFac_T + invFac_T end
   local invPF_T = WR.read(devV, "PF")
   if not(is_nan(invPF_T)) then pvPF_T = pvPF_T + invPF_T end
   local invPdc_T = WR.read(devV, "PDC")
   if not(is_nan(invPdc_T)) then pvPdc_T = pvPdc_T + invPdc_T end
   local invEfficiency_T = WR.read(devV, "EFFICIENCY")
   if not(is_nan(invEfficiency_T)) then pvEfficiency_T = pvEfficiency_T + invEfficiency_T end
  end
  for devV in pairs(dgCtlDev) do
   WR.setProp(devV, "TOTAL_EAE",         (pvEae_T))
   WR.setProp(devV, "TOTAL_EAE_DAY",     (pvEaeday_T))
   WR.setProp(devV, "TOTAL_PAC",         (pvPac_T))
   WR.setProp(devV, "TOTAL_QAC",         (pvQac_T))
   WR.setProp(devV, "TOTAL_IAC",         (pvIac_T))
   WR.setProp(devV, "TOTAL_SAC",         (pvSac_T))
   WR.setProp(devV, "TOTAL_UAC",         (pvUac_T / 8))
   WR.setProp(devV, "TOTAL_FAC",         (pvFac_T / 8))    ---------No of Inverters 4
   WR.setProp(devV, "TOTAL_PF",          (pvPF_T / 8))
   WR.setProp(devV, "TOTAL_PDC",         (pvPdc_T))
   WR.setProp(devV, "TOTAL_EFFICIENCY",  (pvEfficiency_T / 8))
  end
end
------------------------ Total Data Points END  --------------------------------
------------------------ Read Required Data Start -----------------------------
commStatus = commStatus or {}
commStatus[dev] = commStatus[dev] or {DayOn=WR.read(dev, "COMMUNICATION_DAY_ONLINE"), DayOff=WR.read(dev, "COMMUNICATION_DAY_OFFLINE"), HourOn=0, HourOff=0, ts=now}
if is_nan(commStatus[dev].DayOn) then commStatus[dev].DayOn = 0 end
if is_nan(commStatus[dev].DayOff) then commStatus[dev].DayOff = 0 end
startTime = startTime or {}
startTime[dev] = startTime[dev] or {ts=WR.read(dev, "PLANT_START_TIME")}
if is_nan(startTime[dev].ts) then startTime[dev].ts = 0 end
stopTime = stopTime or {}
stopTime[dev] = stopTime[dev] or {ts=WR.read(dev, "PLANT_STOP_TIME"), againStart=0}
if is_nan(stopTime[dev].ts) then stopTime[dev].ts = 0 end
if is_nan(stopTime[dev].againStart) then stopTime[dev].againStart = 0 end
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
local pac = WR.read(dev, "PAC")
local eae = WR.read(dev, "EAE")
local dgPacM = WR.read(dev, "DG_PAC")
local expGen1Now = 0
local expGen2Now = 0
local gridOut = 0
if is_nan(pac) then pac = 0 end
if is_nan(eae) then eae = 0 end
if is_nan(pr) then pr = 0 end
--if is_nan(pac) then pac = 0 end
if is_nan(prDay) then prDay = 0 end
if is_nan(dgPacM) then dgPacM = 0 end
------------------------ Read Required Data End -------------------------------
-------------------- Plant Operational Time Calculation Start ----------------
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
local operationaltime = WR.read(dev, "OPERATIONAL_TIME")
WR.setProp(dev, "OPERATIONAL_HOUR", (operationaltime/3600))  ---- convert seconds to hour
--------------------- Plant Operational Time Calculation End ------------------
------------------------ PR Calculation Start ---------------------------------
 local prDayNow = (((eaeDay) / settings.INVERTER[devS].dcCapacity) / radiationCum) * 100
 if((is_nan(prDayNow)) or (prDayNow < 0) or (prDayNow > 100)) then
  prDayNow = prDay
 end
 WR.setProp(dev, "PR_DAY", prDayNow)
if(radiation >= (settings.INVERTER[devS].prRealRadSetpoint)) then   -- if 250 & ABOVE
 local prNow = (((pac * 1000) / (settings.INVERTER[devS].dcCapacity) / radiation)) * 100
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

