distToChest = 0
direction = 0

function up ()
	turtle.up()
	distToChest = distToChest - 1
end

function down ()
	turtle.down()
	distToChest = distToChest + 1
end

function forward ()
	turtle.forward()
	if direction == 0 or direction == 1 then
		distToChest = distToChest + 1
	else
		distToChest = distToChest - 1
	end
end

function right ()
	turtle.turnRight()
	direction = (direction + 1) % 4
end

function left ()
	turtle.turnLeft()
	direction = (direction - 1) % 4
end


function doIReturn ()
	tank = turtle.getFuelLevel()
	if  tank == "unlimited" then
		return "unlimited"
	end
	fuelSources = {
  	["minecraft:blaze_rod"] = 120,  
  	["minecraft:coal"] =  80, 
  	["minecraft:charcoal"] =  80, 
  	["minecraft:coal_block"] = 720,  
  } 

  fuelInInv = 0
  for i=1,16 do
  	itemDetail = turtle.getItemDetail(i)
  	if itemDetail ~= nil then
	  	fuelValue = fuelSources[itemDetail.name]

	  	if fuelValue ~= nil then
	  		fuelInInv = fuelInInv + (itemDetail.count * fuelValue)
	  	else
	  		print(itemDetail.name, " is not in the fuelSources table.")
	  	end
	  end
  end
	fuelLeft = tank + fuelInInv
	return fuelLeft
end

print(doIReturn())

-- Knows how far it can go away from chest
-- Potentially knows direction

-- Needs to check inventory to see if there is enough space or needs to empty
-- Also needs to mine
