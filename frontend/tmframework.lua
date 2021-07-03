-- Loading libs
local chacha = require("chacha")
local sha256 = require("sha256")

-- ChaCha20 stuff by Anavrins
local function gen_nonce(size)
  local n = {}
  for i = 1, size do n[#n+1] = math.random(0, 255) end
  return n
end

local function encrypt(msg, key)
  local nonce = gen_nonce(12)
  local ctx = chacha.crypt(msg, key, nonce)
  return { nonce, ctx }
end

local function decrypt(msg, key)
  local nonce = msg[1]
  local ctx = msg[2]
  return chacha.crypt(ctx, key, nonce)
end

-- UUID Generation
local function generateUuid()
    local chars = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
    local uuid = {[9]="-",[14]="-",[15]="4",[19]="-",[24]="-"}
    uuid[20] = chars[math.random (9,12)]
    for i = 1,36 do
        if(uuid[i]==nil)then
            uuid[i] = chars[math.random (16)]
        end
    end
    return table.concat(uuid)
end

-- Main code
local function createBackup(path,key,name,progdorPath)
  shell.run(progdorPath.." -s "..path.." /tmp")
  print(key)
  local data = encrypt(fs.open("/tmp","r").readAll(), key)
  local date = os.epoch("utc")
  return data, date, name
end

local function restoreBackup()
end

local function checkDep()
if not fs.exists("chacha.lua")
  print("NOTICE: ChaCha20 not found, Downloading.")
elseif not fs.exists("sha256.lua")
  print("NOTICE: sha256 not found, Downloading.")
elseif not fs.exists("progdor2.lua")
  print("NOTICE: progdor2 not found, Downloading.")
end
-- WSS stuff
local function sendWS(data, ip)
  print("ayo sending that shit bruv")
  local ws, err = http.websocket(ip)
  print(ws, err)
  if ws then
    print("I think it connected?")
    ws.send(data)
    ws.close()
  end
end


return { createBackup = createBackup, restoreBackup = restoreBackup, sendWS = sendWS, generateUuid = generateUuid}
