local square_size = ...

local distToChestX = 0
local distToChestY = 0
local distToChestZ = 0
local direction = 0

modem = peripheral.wrap("left")

local fuelSources = {
    ["minecraft:blaze_rod"] = 120,
    ["minecraft:coal"] =  80,
    ["minecraft:charcoal"] =  80,
    ["minecraft:coal_block"] = 720,
  }

local function right()
  turtle.turnRight()
  direction = (direction + 1) % 4
end

local function left()
  turtle.turnLeft()
  direction = (direction - 1) % 4
end

local function getFuelValue(i)
  local itemDetail = turtle.getItemDetail(i)
  if itemDetail ~= nil then
    local fuelValue = fuelSources[itemDetail.name]
    if fuelValue ~= nil then
      return fuelValue
    end
  end
  return 0
end

local function getStackFuelValue(i)
  local itemDetail = turtle.getItemDetail(i)
  if itemDetail ~= nil then
    local fuelValue = fuelSources[itemDetail.name]
    if fuelValue ~= nil then
      return fuelValue * itemDetail.count
    end
  end
  return 0
end

local function getFirstFuelAmount()
  local foundFuel = false
  local invIterator = 1
  while foundFuel == false or invIterator <= 16 do
    turtle.select(invIterator)
    local fuelValue = getFuelValue(invIterator)
    if fuelValue ~= 0 then
      return fuelValue
    end
    invIterator = invIterator + 1
  end
  return 0
end

local function doIReturn()
  local tank = turtle.getFuelLevel()
  if tank == "unlimited" then
    return "unlimited"
  end
  local fuelInInv = 0
  local spacesLeft = false
  for i=1,16 do
    fuelInInv = fuelInInv + getStackFuelValue(i)
    if turtle.getItemSpace(i) == 64 then
      spacesLeft = true
    end
  end
  local fuelLeft = tank + fuelInInv
  local farAway = distToChestX+distToChestY+distToChestZ >= fuelLeft
  local success, data = turtle.inspect()
  local atBedrock = false
  if success then
    atBedrock = data.name == "minecraft:bedrock"
  end
  return farAway or not spacesLeft or atBedrock
end

local function up()
  turtle.up()
  distToChestY = distToChestY - 1
end

local function down()
  turtle.down()
  distToChestY = distToChestY + 1
end

local function forward()
  turtle.forward()
  if direction == 0 then
    distToChestZ = distToChestZ + 1
  end
  if direction == 1 then
    distToChestX = distToChestX + 1
  end
  if direction == 2 then
    distToChestZ = distToChestZ - 1
  end
  if direction == 3 then
    distToChestX = distToChestX - 1
  end
end

local function returnTurtle()
  modem.transmit(1, 1, "Returning...")
  for _=1,distToChestY do
    up()
  end
  while direction ~= 3 do
    right()
  end
  for _=1,distToChestX do
    forward()
  end
  left()
  for _=1,distToChestZ do
    forward()
  end
  for i=1,16 do
    if getFuelValue(i) == 0 then
      turtle.drop()
    end
  end
end

local function dig(dir)
  if turtle.getFuelLevel() <= 1 then
    modem.transmit(1, 1, "Need fuel...")
    if getFirstFuelAmount() ~= 0 then
      modem.transmit(1, 1, "Found fuel!")
      turtle.refuel()
    else
      modem.transmit(1, 1, "Out of fuel, place fuel in inventory and press any key to continue...")
      os.pullEvent("key")
    end
  end
  if dir == "forward" then
    turtle.dig()
  elseif dir == "down" then
    turtle.digDown()
  end
end

local function excavate()
  modem.transmit(1, 1, "Excavating...")
  dig()
  forward()
  while not doIReturn() do
    for _=1,square_size-1 do
      for _=1,square_size-1 do
        dig("forward")
        forward()
      end
      local tmpDirection = "right"
      if direction == 0 then
        right()
      elseif direction == 2 then
        left()
        tmpDirection = "left"
      end
      dig("forward")
      forward()
      if tmpDirection == "right" then
        right()
      elseif tmpDirection == "left" then
        left()
      end
    end
    dig("down")
    down()
    while not direction == 0 do
      right()
    end
  end
  returnTurtle()
end

excavate()