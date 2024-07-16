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

if not(settings.SMU[devS].dcCapacity and settings.SMU[devS].prAlarmSetpoint and settings.SMU[devS].prAlarmRadSetpoint and settings.SMU[devS].prAlarmTimeSetpoint and settings.SMU[devS].prRealRadSetpoint and settings.SMU[devS].prMinRadSetpoint and settings.SMU[devS].alarmRadSetpoint and settings.SMU[devS].alarmTimeSetpoint) then
--print ("Data loading")
 settings.SMU[devS].dcCapacity = settings.SMU[devS].dcCapacity or settings.SMU.dcCapacity or 134.2
 settings.SMU[devS].prAlarmSetpoint = settings.SMU[devS].prAlarmSetpoint or settings.SMU.prAlarmSetpoint or 75
 settings.SMU[devS].prAlarmRadSetpoint = settings.SMU[devS].prAlarmRadSetpoint or settings.SMU.prAlarmRadSetpoint or 500
 settings.SMU[devS].prAlarmTimeSetpoint = settings.SMU[devS].prAlarmTimeSetpoint or settings.SMU.prAlarmTimeSetpoint or 300
 settings.SMU[devS].prRealRadSetpoint = settings.SMU[devS].prRealRadSetpoint or settings.SMU.prRealRadSetpoint or 100
 settings.SMU[devS].prMinRadSetpoint = settings.SMU[devS].prMinRadSetpoint or settings.SMU.prMinRadSetpoint or 500
 settings.SMU[devS].alarmRadSetpoint = settings.SMU[devS].alarmRadSetpoint or settings.SMU.alarmRadSetpoint or 500
 settings.SMU[devS].alarmTimeSetpoint = settings.SMU[devS].alarmTimeSetpoint or settings.SMU.alarmTimeSetpoint or 900
 settings.SMU[devS].overVoltageSetpoint = settings.SMU[devS].overVoltageSetpoint or settings.SMU.overVoltageSetpoint or 800
 settings.SMU[devS].overTempSetpoint = settings.SMU[devS].overTempSetpoint or settings.SMU.overTempSetpoint or 65
 settings.SMU[devS].openAlarmSetpoint = settings.SMU[devS].openAlarmSetpoint or settings.SMU.openAlarmSetpoint or 70
 settings.SMU[devS].unbalanceAlarmSetpoint = settings.SMU[devS].unbalanceAlarmSetpoint or settings.SMU.unbalanceAlarmSetpoint or 1
 settings.SMU[devS].cId1 = settings.SMU[devS].cId1 or settings.SMU.cId1 or 4
 settings.SMU[devS].cId2 = settings.SMU[devS].cId2 or settings.SMU.cId2 or 4
 settings.SMU[devS].cId3 = settings.SMU[devS].cId3 or settings.SMU.cId3 or 4
 settings.SMU[devS].cId4 = settings.SMU[devS].cId4 or settings.SMU.cId4 or 4
 settings.SMU[devS].cId5 = settings.SMU[devS].cId5 or settings.SMU.cId5 or 4
 settings.SMU[devS].cId6 = settings.SMU[devS].cId6 or settings.SMU.cId6 or 2
 settings.SMU[devS].cId7 = settings.SMU[devS].cId7 or settings.SMU.cId7 or 4
 settings.SMU[devS].cId8 = settings.SMU[devS].cId8 or settings.SMU.cId8 or 4
 settings.SMU[devS].cId9 = settings.SMU[devS].cId9 or settings.SMU.cId9 or 4
 settings.SMU[devS].cId10 = settings.SMU[devS].cId10 or settings.SMU.cId10 or 4
 settings.SMU[devS].cId11 = settings.SMU[devS].cId11 or settings.SMU.cId11 or 4
 settings.SMU[devS].cId12 = settings.SMU[devS].cId12 or settings.SMU.cId12 or 2

 CHECKDATATIME(dev, now, "E_DAY")
 CHECKDATATIME(dev, now, "PR_MIN")
 CHECKDATATIME(dev, now, "PR_DAY")
 CHECKDATATIME(dev, now, "COMMUNICATION_DAY_ONLINE")
 CHECKDATATIME(dev, now, "COMMUNICATION_DAY_OFFLINE")
end

--print ("dcCapacity = ", settings.SMU[devS].dcCapacity)
--print ("prAlarmSetpoint = ", settings.SMU[devS].prAlarmSetpoint)
--print ("prAlarmRadSetpoint = ", settings.SMU[devS].prAlarmRadSetpoint)
--print ("prRealRadSetpoint = ", settings.SMU[devS].prRealRadSetpoint)
--print ("prMinRadSetpoint = ", settings.SMU[devS].prMinRadSetpoint)
--print ("alarmRadSetpoint = ", settings.SMU[devS].alarmRadSetpoint)
--print ("alarmTimeSetpoint = ", settings.SMU[devS].alarmTimeSetpoint)
--print ("overVoltageSetpoint = ", settings.SMU[devS].overVoltageSetpoint)
--print ("overTempSetpoint = ", settings.SMU[devS].overTempSetpoint)
--print ("openAlarmSetpoint = ", settings.SMU[devS].openAlarmSetpoint)
--print ("unbalanceAlarmSetpoint = ", settings.SMU[devS].unbalanceAlarmSetpoint)
--print ("cId1 = ", settings.SMU[devS].cId1)
--print ("cId2 = ", settings.SMU[devS].cId2)
--print ("cId3 = ", settings.SMU[devS].cId3)
--print ("cId4 = ", settings.SMU[devS].cId4)
--print ("cId5 = ", settings.SMU[devS].cId5)
--print ("cId6 = ", settings.SMU[devS].cId6)

------------------------ Read Setpoints End -----------------------------------

------------------------ Read Required Data Start -----------------------------

local radiation = 0 --WR.read(dev, "RADIATION")
local radiationCum = WR.read(dev, "RADIATION_CUM")
local pr = WR.read(dev, "PR")
if is_nan(pr) then pr = 0 end
local prMin = WR.read(dev, "PR_MIN")
if is_nan(prMin) then prMin = 0 end
local prDay = WR.read(dev, "PR_DAY")
if is_nan(prDay) then prDay = 0 end
commStatus = commStatus or {}
commStatus[dev] = commStatus[dev] or {DayOn=WR.read(dev, "COMMUNICATION_DAY_ONLINE"), DayOff=WR.read(dev, "COMMUNICATION_DAY_OFFLINE"), HourOn=0, HourOff=0, ts=now}
if is_nan(commStatus[dev].DayOn) then commStatus[dev].DayOn = 0 end
if is_nan(commStatus[dev].DayOff) then commStatus[dev].DayOff = 0 end
smuDailyEnergies = smuDailyEnergies or {}
smuDailyEnergies[dev] = smuDailyEnergies[dev] or {ts=now, en=WR.read(dev, "E_DAY")}
if (is_nan(smuDailyEnergies[dev].en)) then smuDailyEnergies[dev].en = 0 end

------------------------ Read Required Data End -------------------------------

------------------------ Check Midnight Start ---------------------------------

checkMidnight = checkMidnight or {}
checkMidnight[dev] = checkMidnight[dev] or {ts=now}
if (os.date("*t", checkMidnight[dev].ts).hour > os.date("*t", now).hour) then
 commStatus[dev].DayOn = 0
 commStatus[dev].DayOff = 0
 prMin = 0
end
if (os.date("*t", checkMidnight[dev].ts).hour < os.date("*t", now).hour) then
 commStatus[dev].HourOn = 0
 commStatus[dev].HourOff = 0
end
checkMidnight[dev].ts = now

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

if ((now-commStatus[dev].ts) >= 15) then
 --print("commStatus["..dev.."].commDayOnline = ", commStatus[dev].commDayOnline)
 --print("commStatus["..dev.."].commDayOffline = ", commStatus[dev].commDayOffline)
 --print("commStatus["..dev.."].commHourOnline = ", commStatus[dev].commHourOnline)
 --print("commStatus["..dev.."].commHourOffline = ", commStatus[dev].commHourOffline)
 --print("commStatus["..dev.."].ts = ", commStatus[dev].ts)
 if good then
  commStatus[dev].DayOn = commStatus[dev].DayOn + 1
  commStatus[dev].HourOn = commStatus[dev].HourOn + 1
 else
  commStatus[dev].DayOff = commStatus[dev].DayOff + 1
  commStatus[dev].HourOff = commStatus[dev].HourOff + 1
 end
 commStatus[dev].ts = now
 WR.setProp(dev, "COMMUNICATION_DAY_ONLINE", commStatus[dev].DayOn)
 WR.setProp(dev, "COMMUNICATION_DAY_OFFLINE", commStatus[dev].DayOff)
 WR.setProp(dev, "COMMUNICATION_DAY", (((commStatus[dev].DayOn) / (commStatus[dev].DayOn + commStatus[dev].DayOff)) * 100))
 WR.setProp(dev, "COMMUNICATION_HOUR", (((commStatus[dev].HourOn) / (commStatus[dev].HourOn + commStatus[dev].HourOff)) * 100))
end

---------------------- COMMUNICATION STATUS End -------------------------------

----------------------- DC Power Calculation Start ----------------------------

local idc1 = WR.read(dev, "IDC1")
local idc2 = WR.read(dev, "IDC2")
local idc3 = WR.read(dev, "IDC3")
local idc4 = WR.read(dev, "IDC4")
local idc5 = WR.read(dev, "IDC5")
local idc6 = WR.read(dev, "IDC6")
local idc7 = WR.read(dev, "IDC7")
local idc8 = WR.read(dev, "IDC8")
local idc9 = WR.read(dev, "IDC9")
local idc10 = WR.read(dev, "IDC10")
local idc11 = WR.read(dev, "IDC11")
local idc12 = WR.read(dev, "IDC12")
local udc   = WR.read(dev, "UDC")

-- calculate Total Value of DC Current ----

local pdc = ((idc1 + idc2 + idc3 + idc4 + idc5 + idc6 + idc7 + idc8 + idc9 + idc10 + idc11 + idc12) * udc) / 1000

WR.setProp(dev, "PDC", pdc)

----------------------- DC Power Calculation End ------------------------------

------------------------ DC Energy Start --------------------------------------

if (os.date("*t", smuDailyEnergies[dev].ts).hour > os.date("*t", now).hour) then
 smuDailyEnergies[dev].en = 0
end
if is_nan(pdc) then pdc = 0 end
smuDailyEnergies[dev].en = smuDailyEnergies[dev].en + (((now-smuDailyEnergies[dev].ts) * pdc) / (60*60))
smuDailyEnergies[dev].ts = now
WR.setProp(dev, "E_DAY", smuDailyEnergies[dev].en)

------------------------ DC Energy End ----------------------------------------

------------------------- Overvoltage Alarm Start -----------------------------

local udcAlarm = 0
if udc > settings.SMU[devS].overVoltageSetpoint then udcAlarm = 1 end

------------------------- Overvoltage Alarm End -------------------------------

-------------------------- Overtemp Alarm Start -------------------------------

local temp = WR.read(dev, "TEMP1")
local tmpAlarm = 0
if temp > settings.SMU[devS].overTempSetpoint then tmpAlarm = 1 end

-------------------------- Overtemp Alarm End ---------------------------------

------------------- Logic for SMU string current comparison Start -------------

-- read all 6 current values:
local IDCavgs = {idc1, idc2, idc3, idc4, idc5, idc6, idc7, idc8, idc9, idc10, idc11, idc12}
local cId = {settings.SMU[devS].cId1, settings.SMU[devS].cId2, settings.SMU[devS].cId3, settings.SMU[devS].cId4, settings.SMU[devS].cId5, settings.SMU[devS].cId6, settings.SMU[devS].cId7, settings.SMU[devS].cId8, settings.SMU[devS].cId9, settings.SMU[devS].cId10, settings.SMU[devS].cId11, settings.SMU[devS].cId12}
local wgt_sd = {wgt1, wgt2, wgt3, wgt4, wgt5, wgt6, wgt7, wgt8, wgt9, wgt10, wgt11, wgt12}
local total = (idc1 + idc2 + idc3 + idc4 + idc5 + idc6 + idc6 + idc7 + idc9 + idc10 + idc11 + idc12)

-- calc the weighted avg:
local wgtavg = 0
local cnt = 0
local wgtmax = 0

for i=1,12,1 do
 if IDCavgs[i] ~= nil and IDCavgs[i] ~= (0/0) and cId[i] > 0 then
  -- calc weighted current:
  wgt_sd[i] = (IDCavgs[i] * (4/cId[i]))
  -- add to mean summing variable
  wgtavg = wgtavg + wgt_sd[i]
  -- count this value:
  cnt  = cnt  + 1
  -- detect max weighted current:
  if wgt_sd[i] > wgtmax then wgtmax = wgt_sd[i] end
 end
end

-- calc mean from sum:
if cnt > 0 then wgtavg = wgtavg/cnt end

-- this is for String open/Fuse Failure Alarm:
local wgtmax0_7 = (settings.SMU[devS].openAlarmSetpoint / 100) * wgtmax
-- for standard deviation:
local sd = 0
cnt = 0
local openAlarm = 0
local idcAlarm = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

for i=1,12,1 do
 if IDCavgs[i] ~= nil and IDCavgs[i] ~= (0/0) and cId[i] > 0 then
  -- add squares off deviance from mean:
  sd = sd + math.pow((wgtavg-wgt_sd[i]),2)
  cnt = cnt + 1
  -- detect deviance of 30% from weighted mean:
  if wgt_sd[i] < wgtmax0_7 then
   idcAlarm[i] = 1
   openAlarm = 1
  end
 end
end

-- calculate SD from Variance:
if cnt > 0 then
 sd = sd/cnt
 sd = math.sqrt(sd)
end

local ubAlarm = 0
-- detect String Unbalanced/ Fuse Failure alarm:
if sd > settings.SMU[devS].unbalanceAlarmSetpoint then ubAlarm = 1 end

------------------- Logic for SMU string current comparison End -------------

--------------------- Alarm Persistent for 15 min Start -----------------------

smuAlarm = smuAlarm or {}
smuAlarm[dev] = smuAlarm[dev] or {tsv=now, tst=now, tsu=now, tso=now, tsp=now}

--print("now = ",now)
--print("smuAlarm["..dev.."].tsv = ",smuAlarm[dev].tsv)
--print("smuAlarm["..dev.."].tst = ",smuAlarm[dev].tst)
--print("smuAlarm["..dev.."].tsu = ",smuAlarm[dev].tsu)
--print("smuAlarm["..dev.."].tso = ",smuAlarm[dev].tso)
--print("smuAlarm["..dev.."].tsp = ",smuAlarm[dev].tsp)

--if (radiation > settings.SMU[devS].alarmRadSetpoint) then
 if (udcAlarm == 1) then
  if ((now-smuAlarm[dev].tsv) < settings.SMU[devS].alarmTimeSetpoint) then udcAlarm = 0 end
 else
  smuAlarm[dev].tsv = now
  udcAlarm = 0
 end
 if (tmpAlarm == 1) then
  if ((now-smuAlarm[dev].tst) < settings.SMU[devS].alarmTimeSetpoint) then tmpAlarm = 0 end
 else
  smuAlarm[dev].tst = now
  tmpAlarm = 0
 end
 if (ubAlarm == 1) then
  if ((now-smuAlarm[dev].tsu) < settings.SMU[devS].alarmTimeSetpoint) then ubAlarm = 0 end
 else
  smuAlarm[dev].tsu = now
  ubAlarm = 0
 end
 if (openAlarm == 1) then
  if ((now-smuAlarm[dev].tso) < settings.SMU[devS].alarmTimeSetpoint) then openAlarm = 0 end
 else
  smuAlarm[dev].tso = now
  openAlarm = 0
 end
--else
--udcAlarm = 0
--smuAlarm[dev].tsv = now
--tmpAlarm = 0
--smuAlarm[dev].tst = now
--ubAlarm = 0
--smuAlarm[dev].tsu = now
--openAlarm = 0
--smuAlarm[dev].tso = now
--end

if openAlarm == 1 then
 WR.setProp(dev, "IDC1_Alarm", idcAlarm[1])
 WR.setProp(dev, "IDC2_Alarm", idcAlarm[2])
 WR.setProp(dev, "IDC3_Alarm", idcAlarm[3])
 WR.setProp(dev, "IDC4_Alarm", idcAlarm[4])
 WR.setProp(dev, "IDC5_Alarm", idcAlarm[5])
 WR.setProp(dev, "IDC6_Alarm", idcAlarm[6])
 WR.setProp(dev, "IDC7_Alarm", idcAlarm[7])
 WR.setProp(dev, "IDC8_Alarm", idcAlarm[8])
 WR.setProp(dev, "IDC9_Alarm", idcAlarm[9])
 WR.setProp(dev, "IDC10_Alarm", idcAlarm[10])
 WR.setProp(dev, "IDC11_Alarm", idcAlarm[11])
 WR.setProp(dev, "IDC12_Alarm", idcAlarm[12])
else
 WR.setProp(dev, "IDC1_Alarm", 0)
 WR.setProp(dev, "IDC2_Alarm", 0)
 WR.setProp(dev, "IDC3_Alarm", 0)
 WR.setProp(dev, "IDC4_Alarm", 0)
 WR.setProp(dev, "IDC5_Alarm", 0)
 WR.setProp(dev, "IDC6_Alarm", 0)
 WR.setProp(dev, "IDC7_Alarm", 0)
 WR.setProp(dev, "IDC8_Alarm", 0)
 WR.setProp(dev, "IDC9_Alarm", 0)
 WR.setProp(dev, "IDC10_Alarm", 0)
 WR.setProp(dev, "IDC11_Alarm", 0)
 WR.setProp(dev, "IDC12_Alarm", 0)
end

WR.setProp(dev, "OVERVOLT",        udcAlarm)
WR.setProp(dev, "OVERVOLT_Alarm",  udcAlarm)
WR.setProp(dev, "OVERTEMP",        tmpAlarm)
WR.setProp(dev, "OVERTEMP_Alarm",  tmpAlarm)
WR.setProp(dev, "UNBALANCE",       ubAlarm)
WR.setProp(dev, "UNBALANCE_Alarm", ubAlarm)
WR.setProp(dev, "OPEN",            openAlarm)
WR.setProp(dev, "OPEN_Alarm",      openAlarm)

--------------------- Alarm Persistent for 15 min End -------------------------

----------------------- Logic for SMU Alarm Start------------------------------

local spd = WR.read(dev, "SPD")
local outdss = WR.read(dev, "OUTDSS")

if (outdss == 0 or udcAlarm == 1 or tmpAlarm == 1 or openAlarm == 1 or spd == 1 or ubAlarm == 1) then
 WR.setProp(dev, "SMU_Alarm", 1)
else
 WR.setProp(dev, "SMU_Alarm", 0)
end

----------------------- Logic for SMU Alarm Start------------------------------

