os.loadAPI("ocs/apis/sensor")

local sensor = sensor.wrap("top:white")
local printer = peripheral.wrap("bottom")
local coords = "-1,4,-3"
local cableSide = "right"
local waitTime = 1
local dregI = 1
local nominal = 244
local eulerNum = 2.71
local contur1MAX = 18
local contur2MAX = 10
local contur1 = tonumber(18)
local contur2 = tonumber(0)
local selsin = 0
local selsinMAX = 15

_print = print

print = function(string)
	logFile = fs.open("disk/log.txt", "a")
	logFile.write(string.."\n")
	logFile.close()
	_print(string)
end


function getSFKRE()
	return sensor.getTargetDetails(coords)["Heat"] + sensor.getTargetDetails(coords)["Output"] * 3.2
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

function getInfo()
	fileInfo = fs.open("disk/2.dat", "r")
	fileData = fileInfo.readAll()
	fileInfo.close()

	return tonumber(fileData)
end

function sendInfo(string)
	fileInfo = fs.open("disk/1.dat", "w")
	fileInfo.write(string)
	fileInfo.close()
end

while true do
	sendInfo(tostring(getSFKRE()))
	printer.newPage()

	print("DREG CHECK #"..tostring(dregI))
	printer.write("DREG CHECK #"..tostring(dregI))
	printer.setCursorPos(1, 2)

	if rs.testBundledInput(cableSide, colors.white) == true and not alreadyTGValveON then
		print("TG VALVE OPEN")
		print("INCREASING PRESSURE")

		alreadyTGValveON = true
		alreadyTGValveOFF = false
	elseif rs.testBundledInput(cableSide, colors.white) == false and not alreadyTGValveOFF then
		print("TG VALVE CLOSED")
		print("DECREASING PRESSURE")

		alreadyTGValveOFF = true
		alreadyTGValveON = false
	end

	if rs.testBundledInput(cableSide, colors.orange) == true and not alreadyNasosON then
		print("CN ON")
		print("CN INPUT ENABLED")
		print("CN OUTPUT ENABLED")

		alreadyNasosON = true
		alreadyNasosOFF = false
	elseif rs.testBundledInput(cableSide, colors.orange) == false and not alreadyNasosOFF then
		print("CN OFF")
		print("CN INPUT DISABLED")
		print("CN OUTPUT DISABLED")

		alreadyNasosOFF = true
		alreadyNasosON = false
	end

	if rs.testBundledInput(cableSide, colors.magenta) == true and not alreadyAZON then
		print("AZ SUZ")
		print("DECREASING CELLS KOL-VO")
		print("DECREASING CELLS AUTO")
		print("PARAMETERS REGISTERED")

		alreadyAZON = true
		alreadyAZOFF = false
	elseif rs.testBundledInput(cableSide, colors.magenta) == false and not alreadyAZOFF then
		print("AZ SUZ")
		print("STOP DECREASING CELLS KOL-VO")
		print("STOP DECREASING CELLS AUTO")
		print("PARAMETERS REGISTERED")

		alreadyAZOFF = true
		alreadyAZON = false
	end

	if rs.testBundledInput(cableSide, colors.lime) == true and not alreadyPGON then
		print("STEAM GENERATION STARTED")
		print("PP(START)		"..tostring(getPP()))
		print("PARAMETERS REGISTERED")

		alreadyPGON = true
		alreadyPGOFF = false
	elseif rs.testBundledInput(cableSide, colors.lime) == false and not alreadyPGOFF then
		print("STEAM GENERATION STOPPED")
		print("PP 0")
		print("PARAMETERS REGISTERED")

		if getSFKRE() > 0 then
			print(" --------- WARNING --------- ")
			print(" NO TO IN REACTOR ")
			print(" PARAMETERS REGISTERED ")
			print(" --------- WARNING --------- ")
		end

		alreadyPGOFF = true
		alreadyPGON = false
	end

	if rs.testBundledInput(cableSide, colors.pink) == true and not alreadyTransON then
		print("TG STARTED GENERATOR")
		print("SN ACTIVATED")
		print("SN AUTO(TG)")
		print("PARAMETERS REGISTERED")

		alreadyTransON = true
		alreadyTransOFF = false
	elseif rs.testBundledInput(cableSide, colors.pink) == false and not alreadyTransOFF then
		print("TG STOPPED GENERATOR")
		print("SN DISABLED")
		print("SN AUTO(NO STEAM TG)")
		print("PARAMETERS REGISTERED")

		alreadyTransOFF = true
		alreadyTransON = false
	end

	if rs.testBundledInput(cableSide, colors.lightBlue) then
		print("DECREASING POWER")

		if not selsin == 0 then
			selsin = selsin - 1
			print("POWER DECREASED")
			print("SUZ: "..tostring(selsin))
		else
			print("SUZ NK")
			print("SUZ: "..tostring(selsin))
		end

		print("PARAMETERS REGISTERED")
	elseif rs.testBundledInput(cableSide, colors.yellow) then
		print("INCREASING POWER")

		if not selsin == selsinMAX then
			selsin = selsin + 1
			print("POWER INCREASED")
			print("SUZ: "..tostring(selsin))
		else
			print("SUZ VK")
			print("SUZ: "..tostring(selsin))
		end

		print("PARAMETERS REGISTERED")
	end

	if rs.testBundledInput(cableSide, colors.gray) == true then
		if contur1MAX <= contur1 then
			print("PRESSURE IN CIRCUIT #1 EXCEEDED")
			print("PRESSURE IN CIRCUIT #1:		"..tostring(contur1))
			print("PARAMETERS REGISTERED")
		else
			contur1 = contur1 + 1
			print("PRESSURE IN CIRCUIT #1 CHANGED")
			print("PRESSURE IN CIRCUIT #1 INCREASED")
			print("PRESSURE IN CIRCUIT #1:		"..tostring(contur1))
			print("PARAMETERS REGISTERED")
		end

		if contur2 == 0 then
			print("LOW PRESSURE IN CIRCUIT #2")
			print("PRESSURE IN CIRCUIT #2:		"..tostring(contur2))
			print("PARAMETERS REGISTERED")
		else
			contur2 = contur2 - 1
			print("PRESSURE IN CIRCUIT #2 CHANGED")
			print("PRESSURE IN CIRCUIT #2 DECREASED")
			print("PRESSURE IN CIRCUIT #1:		"..tostring(contur2))
			print("PARAMETERS REGISTERED")
		end

	elseif rs.testBundledInput(cableSide, colors.lightGray) == true then
		if contur2MAX <= contur2 then
			print("PRESSURE IN CIRCUIT #2 EXCEEDED")
			print("PRESSURE IN CIRCUIT #2:		"..tostring(contur2))
			print("PARAMETERS REGISTERED")
		else
			contur2 = contur2 + 1
			print("PRESSURE IN CIRCUIT #2 CHANGED")
			print("PRESSURE IN CIRCUIT #2 INCREASED")
			print("PRESSURE IN CIRCUIT #2:		"..tostring(contur2))
			print("PARAMETERS REGISTERED")
		end

		if contur1 == 0 then
			print("LOW PRESSURE IN CIRCUIT #1")
			print("PRESSURE IN CIRCUIT #1:		"..tostring(contur1))
			print("PARAMETERS REGISTERED")
		else
			contur2 = contur2 - 1
			print("PRESSURE IN CIRCUIT #1 CHANGED")
			print("PRESSURE IN CIRCUIT #1 DECREASED")
			print("PRESSURE IN CIRCUIT #1:		"..tostring(contur1))
			print("PARAMETERS REGISTERED")
		end
	end

	sfkre = getSFKRE()
	reactivity = getInfo()
	period = math.floor(getPeriod(sfkre, reactivity))

	printer.write("SFKRE:       "..tostring(sfkre))
	printer.setCursorPos(1, 3)
	printer.write("PERIOD:      "..string.upper(tostring(period)))
	printer.setCursorPos(1, 4)
	printer.write("REACTIVITY:  "..tostring(reactivity))

	print("SFKRE:           "..tostring(getSFKRE()))

	if tostring(period) == "inf" or tostring(period) == "nan" then 
		print("PERIOD:          INF")
	else
		print("PERIOD:          "..tostring(period))
	end

	print("REACTIVITY:      "..tostring(reactivity))
	print("")

	if sfkre <= nominal then
		bolsheNominala = false
	end

	if period <= 30 and not tostring(period) == "inf" and not periodMenshe30 then
		periodMenshe30 = true

		print(" --------- WARNING --------- ")
		print("	PERIOD >= 30")
		print(" PERIOD "..tostring(period))
		print(" SFKRE INCREASING PP+REACT ")
		print(" PP INCREASING ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	else
		periodMenshe30 = false
	end

	if reactivity >= 100 and reactivity < 3000 and not reactivityBolshe100 then
		reactivityBolshe100 = true
		reactivityBolshe3000 = false
		reactivityBolshe6200 = false

		print(" --------- WARNING --------- ")
		print("	REACTIVITY >= 100")
		print(" REACTIVITY "..tostring(reactivity))
		print(" PERIOD REACTIVITY "..tostring(period))
		print(" SFKRE INCREASING SG+REACT ")
		print(" PP INCREASING ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif sfkre > nominal and not bolsheNominala then
		bolsheNominala = true

		print("--------- WARNING --------- ")
		print("	SFKRE > DENOMINATION("..tostring(nominal)..")")
		print(" SFKRE "..tostring(sfkre))
		print(" PERIOD "..tostring(period))
		print(" SFKRE INCREASING SG+REACT")
		print(" PP INCREASING ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif reactivity >= 3000 and reactivity < 6200 then
		reactivityBolshe100 = true
		reactivityBolshe3000 = true
		reactivityBolshe6200 = false

		print(" --------- WARNING --------- ")
		print("	REACTIVITY >= 3000")
		print(" REACTIVITY "..tostring(reactivity))
		print(" PERIOD REACTIVITY "..tostring(period))
		print(" SFKRE INCREASING SG+REACT ")
		print(" PP INCREASING ")
		print(" HIGH TEMP SIGNAL ACTIVATED (>3000) ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif reactivity >= 6200 then
		reactivityBolshe100 = true
		reactivityBolshe3000 = true
		reactivityBolshe6200 = true

		print(" --------- WARNING --------- ")
		print("	REACTIVITY >= 6200")
		print(" REACTIVITY "..tostring(reactivity))
		print(" PERIOD REACTIVITY "..tostring(period))
		print(" SFKRE INCREASING SG+REACT ")
		print(" PP INCREASING ")
		print(" CRIT TEMP SIGNAL ACTIVATED (>6200) ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	end

	dregI = dregI + 1
	printer.setPageTitle("DREG INFO")
  	printer.endPage()

	sleep(waitTime)
end
