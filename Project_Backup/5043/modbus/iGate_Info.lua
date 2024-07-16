local dev, good = ...
--print(dev)

devS = string.sub(dev, 8, -1)
--print("devS = ", devS)

------------------------ Read Setpoints Start ---------------------------------

if not(settings) then
 --print ("Inside file loading")
 settingsConfig = assert(io.open("/mnt/jffs2/solar/modbus/Settings.txt", "r"))
 settingsJson = settingsConfig:read("*all")
 settings = cjson.decode(settingsJson)
 settingsConfig:close()
end

if not(settings.RTU.cpuAlarmSetpoint and settings.RTU.ramAlarmSetpoint) then
 --print ("Data loading")
 settings.RTU.cpuAlarmSetpoint = settings.RTU.cpuAlarmSetpoint or 60
 settings.RTU.ramAlarmSetpoint = settings.RTU.ramAlarmSetpoint or 60
end

--print ("cpuAlarmSetpoint = ", settings.RTU.cpuAlarmSetpoint)
--print ("ramAlarmSetpoint = ", settings.RTU.ramAlarmSetpoint)

------------------------ Read Setpoints End -----------------------------------

------------------------ Read Required Data Start -----------------------------

require ("socket")
-- get a temporary file name
n = os.tmpname ()
-- execute a command
os.execute ("grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' > " .. n)
os.execute ([[head -4 /proc/meminfo | awk '{print $2}' | awk 'BEGIN {FS = "\n" ; RS = ""} {usage=100 - (($2+$3+$4) / ($1)) * 100} END {print usage}' >> ]] ..n)
os.execute ("df -h | sed 's/%//' | awk 'FNR==3 {print $5}' >> " ..n)

iGateInfo = iGateInfo or {}
local i=0
-- display output
for line in io.lines (n) do
 iGateInfo[i] = tonumber(line)
 i=i+1
end
-- remove temporary file
os.remove (n)

------------------------ Read Required Data End -------------------------------

---------------------- COMMUNICATION STATUS Start -----------------------------

if WR.isOnline(dev) then
 WR.setProp(dev, "COMMUNICATION_STATUS", 0)
else
 WR.setProp(dev, "COMMUNICATION_STATUS", 1)
end

---------------------- COMMUNICATION STATUS End -------------------------------

-------------------- iGate Info Calculation Start -----------------------------

WR.setProp(dev, "CPU_LOAD", iGateInfo[0])
local cpuOverload = 0
if (iGateInfo[0] > settings.RTU.cpuAlarmSetpoint) then cpuOverload = 1 end
WR.setProp(dev, "CPU_OVERLOAD", cpuOverload)

WR.setProp(dev, "RAM_LOAD", iGateInfo[1])
local ramOverload = 0
if (iGateInfo[1] > settings.RTU.ramAlarmSetpoint) then ramOverload = 1 end
WR.setProp(dev, "RAM_OVERLOAD", ramOverload)

WR.setProp(dev, "FLASH_LOAD", iGateInfo[2])

-------------------- iGate Info Calculation End -------------------------------

--[[--------------------- Channel Status Start ----------------------------------

function ChannelStatus(dev, channel, masterId)
 local file = io.open("/ram/"..masterId.."","r")
 local status = tonumber(file:read("*a"))
 file:close()
 if status ~= nil then
  WR.setProp(dev, channel, status)
 end
end

ChannelStatus(dev, "CHANNEL1_STATUS", "1")
ChannelStatus(dev, "CHANNEL2_STATUS", "2")
ChannelStatus(dev, "CHANNEL3_STATUS", "3")

----------------------- Channel Status End ----------------------------------]]--
