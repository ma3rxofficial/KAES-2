os.loadAPI("ocs/apis/sensor")

local sensor = sensor.wrap("top:white")
local coords = "-1,4,-3"
local eulerNum = 2.71

function getSFKRE()
	return sensor.getTargetDetails(coords)["Heat"] + sensor.getTargetDetails(coords)["Output"] * 3.2
end

function sendInfo(string, file)
	fileInfo = fs.open("disk/"..file, "w")
	fileInfo.write(string)
	fileInfo.close()
end

function getInfo(file)
	fileInfo = fs.open("disk/"..file, "r")
	fileData = fileInfo.readAll()
	fileInfo.close()

	return fileData
end


function getPeriod(N, r)
	return N*eulerNum/r
end

function getHeat()
	return sensor.getTargetDetails(coords)["Heat"]
end

function getPP()
	return sensor.getTargetDetails(coords)["Output"] * 3.2
end

function infoDisk()
	while true do
		sfkre = getSFKRE()
		reactivity = getInfo("2.dat")
		period = getPeriod(sfkre, tonumber(reactivity))
		heat = getHeat()
		pp = getPP()

		print("DISK 1 -> [SFKRE "..tostring(sfkre).."]")
		print("DISK 2 -> [REACTIVITY "..tostring(reactivity).."]")
		print("DISK 3 -> [PERIOD "..string.upper(tostring(period)).."]")
		print("DISK 4 -> [S-PRESSURE "..tostring(heat).."]")
		print("DISK 5 -> [S-GENERATOR "..tostring(pp).."]")
		print("---------------------------------------------------")

		sendInfo(tostring(sfkre), "3.dat")
		sendInfo(tostring(period), "4.dat")
		sendInfo(tostring(heat), "5.dat")
		sendInfo(tostring(pp), "6.dat")

		sleep(0)
	end
end

function calculatingReactivity()
	while true do
		sfkre1 = getSFKRE()
		sleep(1)
		sfkre2 = getSFKRE()

		sendInfo(tostring(-(sfkre1 - sfkre2)), "2.dat")
	end
end

parallel.waitForAny(calculatingReactivity, infoDisk)
