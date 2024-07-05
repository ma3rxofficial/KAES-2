os.loadAPI("ocs/apis/sensor")

local sensor = sensor.wrap("top:white")
local printer = peripheral.wrap("bottom")
local coords = "-1,4,-3"
local cableSide = "right"
local waitTime = 1
local dregI = 1
local prI = 0
local nominal = 244
local eulerNum = 2.71
local contur1MAX = 18
local contur2MAX = 10
local contur1 = tonumber(18)
local contur2 = tonumber(0)
local selsin = 0
local selsinMAX = 15
local pageStarted = false

_print = print

print = function(string)
	if prI >= 21 then
		if pageStarted then
			printer.setPageTitle("DREG INFO")
  			printer.endPage()
  			pageStarted = false
  		end

  		pageStarted = printer.newPage()

  		prI = 0
	end

	prI = prI + 1

	logFile = fs.open("disk/log.txt", "a")
	logFile.write(string.."\n")

	if pageStarted then
		printer.write(string)
		printer.setCursorPos(1, prI)
	end

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

pageStarted = printer.newPage()

while true do
	sendInfo(tostring(getSFKRE()))
	print("")
	print("DREG CHECK #"..tostring(dregI))

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
	heat = getHeat()

	print("SFKRE:           "..tostring(getSFKRE()))

	if tostring(period) == "inf" or tostring(period) == "nan" then 
		print("PERIOD:          INF")
	else
		print("PERIOD:          "..tostring(period))
	end

	print("REACTIVITY:      "..tostring(reactivity))

	if sfkre <= nominal then
		bolsheNominala = false
	end

	if period <= 30 and not tostring(period) == "inf" and not periodMenshe30 then
		periodMenshe30 = true

		print(" --------- WARNING --------- ")
		print("	PERIOD =< 30")
		print(" PERIOD "..tostring(period))
		print(" SFKRE INCREASING PP+REACT ")
		print(" PP INCREASING ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	else
		periodMenshe30 = false
	end

	if reactivity < 100 then
		reactivityBolshe100 = false
	end

	if heat < 100 then
		heatBolshe100 = false
	end

	if heat >= 100 and not heatBolshe100 then
		heatBolshe100 = true
		heatBolshe3000 = false
		heatBolshe6200 = false

		print(" --------- WARNING --------- ")
		print("	STEAM PRESSURE >= 100")
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
	elseif heat >= 3000 and not heatBolshe3000 then
		heatBolshe100 = true
		heatBolshe3000 = true
		heatBolshe6200 = false

		print(" --------- WARNING --------- ")
		print("	STEAM PRESSURE >= 3000")
		print(" REACTIVITY "..tostring(reactivity))
		print(" PERIOD REACTIVITY "..tostring(period))
		print(" SFKRE INCREASING SG+REACT ")
		print(" PP INCREASING ")
		print(" HIGH TEMP SIGNAL ACTIVATED (>3000) ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif heat >= 6200 and not heatBolshe6200 then
		heatBolshe100 = true
		heatBolshe3000 = true
		heatBolshe6200 = true

		print(" --------- WARNING --------- ")
		print("	STEAM PRESSURE >= 6200")
		print(" REACTIVITY "..tostring(reactivity))
		print(" PERIOD REACTIVITY "..tostring(period))
		print(" SFKRE INCREASING SG+REACT ")
		print(" PP INCREASING ")
		print(" CRIT TEMP SIGNAL ACTIVATED (>6200) ")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif reactivity >= 100 and not reactivityBolshe100 then
		reactivityBolshe100 = true

		print(" --------- WARNING --------- ")
		print("	REACTIVITY >= 100")
		print(" PERIOD REACTIVITY    "..tostring(period))
		print(" SFKRE    "..tostring(sfkre))
		print(" SFKRE INCREASING PP+REACT ")
		print(" PP INCREASING ")
		print(" STEAM PRESSURE INCREASING")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	end

	dregI = dregI + 1
	sleep(waitTime)
end
