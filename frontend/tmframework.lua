-- Download Function
local function download(u,s)
  handle = http.get(u)
  if not handle then
      print("Failed to download.")
  else
      local data = handle.readAll()
      local f = fs.open(s, "w")
      handle.close()
      print("Writing Data.")
      f.write(data)
      f.close()
      return
  end
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

-- Prestart checking of libraries and configuration
local installpath = "/" -- note to self, make this autoajust for OSes
if not fs.exists("chacha.lua") then
  print("NOTICE: ChaCha20 not found, Downloading.")
  download("https://pastebin.com/raw/GPzf9JSa",installpath.."chacha.lua")
end
if not fs.exists("sha256.lua") then
  print("NOTICE: sha256 not found, Downloading.")
  download("https://pastebin.com/raw/6UV4qfNF",installpath.."sha256.lua")
end
if not fs.exists("progdor2.lua") then
  print("NOTICE: progdor2 not found, Downloading.")
  download("https://raw.githubusercontent.com/LDDestroier/CC/master/progdor2.lua",installpath.."progdor2.lua")
end

-- Loading libs
local sha256 = require("sha256")
local chacha = require("chacha")

-- Checking configuration
settings.load(installpath..".tmconfig")
if not settings.get("tm.uuid") then
  print("NOTICE: no uuid found, generating random UUID.")
  settings.set("tm.uuid", generateUuid())
end
if not settings.get("tm.key") then
  print("NOTICE: no key found, generating key.")
  print("Set new passphrase: ") settings.set("tm.key", sha256.digest(read()))
end
settings.save("/.tmconfig")


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

-- Main code
local function createBackup(path,key,name,progdorPath)
  settings.load(installpath..".tmconfig")
  shell.run(progdorPath.." -s "..path.." /tmp")
  print(key)
  local backup = {}
  backup.data = encrypt(fs.open("/tmp","r").readAll(), settings.get("tm.key"))
  backup.date = os.epoch("utc")
  backup.name = name
  backup.uuid = settings.get("tm.uuid")
  return backup
end

local function restoreBackup()
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


return { createBackup = createBackup, restoreBackup = restoreBackup, sendWS = sendWS, generateUuid = generateUuid }
