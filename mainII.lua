os.loadAPI("ocs/apis/sensor")
os.loadAPI("JSON")

local printer = peripheral.wrap("bottom")
local cableSide = "right"
local waitTime = 0.5
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
local timeDregCheck
local show_header = false

local dateTime = "00:00:00"
local serverTimeEnabled = true

function timeGet()
	if serverTimeEnabled then
		dateTime = http.get("http://localhost:8056/").readAll()
	end

	return dateTime
end

function startsWith(str, prefix)
	return string.sub(str, 1, #prefix) == prefix
  end
  

_print = print

function showDREGHeader()
	print("")
	print("DREG CHECK #"..tostring(dregI).." "..timeRN)
	dregI = dregI + 1
end

print = function(string)
	if string ~= "" and not startsWith(string, "DREG CHECK") then
		if not show_header then
			showDREGHeader()
			show_header = true
		end
	end

	_print(string)
	if prI >= 21 then
		if pageStarted then
			printer.setPageTitle("DREG INFO "..string.gsub(dateTime, "-", "."))
  			printer.endPage()
  			pageStarted = false
  		end

  		pageStarted = printer.newPage()

  		prI = 0
	end

	prI = prI + 1

	if not timeDregCheck then
		dateTime = string.sub(timeGet(), 1, -10)
		logFile = fs.open("disk/".."log_"..dateTime..".txt", "a")
	else
		logFile = fs.open("disk/".."log_"..dateTime..".txt", "a")
	end

	logFile.write(string.."\n")
	logFile.close()

	if pageStarted then
		printer.write(string)
		printer.setCursorPos(1, prI)
	end
end

function getInfo(file)
	fileInfo = fs.open("disk/"..file, "r")
	fileData = fileInfo.readAll()
	fileInfo.close()

	return tonumber(fileData)
end

local prev_sfkre = getInfo("3.dat")
local prev_reactivity = getInfo("2.dat")
local prev_period = getInfo("4.dat")
local prev_heat = getInfo("5.dat")
local prev_pp = getInfo("6.dat")

pageStarted = printer.newPage()

while true do
	show_header = false

	timeRN = timeGet()
	timeDregCheck = timeRN
	dateTime = string.sub(timeDregCheck, 1, -10)

	sfkre = getInfo("3.dat")
	reactivity = getInfo("2.dat")
	period = getInfo("4.dat")
	heat = getInfo("5.dat")
	pp = getInfo("6.dat")


	if period == nil then
		period = 1/0
	else
		period = math.floor(period)
	end

	if rs.testBundledInput(cableSide, colors.white) == true and not alreadyTGValveON then
		print("TG VALVE OPEN")
		print("INCREASING PRESSURE")

		if rs.testBundledInput(cableSide, colors.lime) == false then
			print("NO PP PVK")
			print("NO PP NVK")
			print("SP 0")
		end

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
		print("DECREASING CELLS")
		print("DECREASING CELLS AUTO")
		print("DECREASING CELLS AZ SUZ")
		print("PARAMETERS REGISTERED")

		alreadyAZON = true
		alreadyAZOFF = false
	elseif rs.testBundledInput(cableSide, colors.magenta) == false and not alreadyAZOFF then
		print("AZ SUZ")
		print("STOP DECREASING CELLS")
		print("STOP DECREASING CELLS AUTO")
		print("STOP DECREASING CELLS AZ SUZ")
		print("PARAMETERS REGISTERED")

		alreadyAZOFF = true
		alreadyAZON = false
	end

	if rs.testBundledInput(cableSide, colors.lime) == true and not alreadyPGON then
		print("STEAM GENERATION STARTED")
		print("PP(START)		"..tostring(pp))
		print("SP CHANGE")
		print("SP CHANGE AUTO")
		print("PARAMETERS REGISTERED")

		alreadyPGON = true
		alreadyPGOFF = false
	elseif rs.testBundledInput(cableSide, colors.lime) == false and not alreadyPGOFF then
		print("STEAM GENERATION STOPPED")
		print("PP 0")
		print("PARAMETERS REGISTERED")

		if sfkre > 0 then
			print(" --------- WARNING --------- ")
			print(" NO TO IN REACTOR ")
			print("	SFKRE > 0")
			print(" NO SG")
			print(" SP 0")
			print(" PARAMETERS REGISTERED ")
			print(" --------- WARNING --------- ")
		end

		alreadyPGOFF = true
		alreadyPGON = false
	end

	if rs.testBundledInput(cableSide, colors.pink) == true and not alreadyTransON then
		print("TG STARTED GENERATOR")
		print("PARAMETERS REGISTERED")

		alreadyTransON = true
		alreadyTransOFF = false
	elseif rs.testBundledInput(cableSide, colors.pink) == false and not alreadyTransOFF then
		print("TG STOPPED GENERATOR")
		print("PARAMETERS REGISTERED")

		alreadyTransOFF = true
		alreadyTransON = false
	end

	if rs.testBundledInput(cableSide, colors.cyan) == true and not alreadyAvtomatikaON then
		print("AUTO DECREASING POWER SUZ")
		print("AUTO DECREASING ON")
		print("AUTO AZ SUZ")
		print("AUTO AZ SUZ ON")

		alreadyAvtomatikaON = true
		alreadyAvtomatikaOFF = false
	elseif rs.testBundledInput(cableSide, colors.cyan) == false and not alreadyAvtomatikaOFF then
		print("AUTO DECREASING POWER SUZ")
		print("AUTO DECREASING OFF")
		print("AUTO AZ SUZ")
		print("AUTO AZ SUZ OFF")

		alreadyAvtomatikaOFF = true
		alreadyAvtomatikaON = false
	end

	if rs.testBundledInput(cableSide, colors.lightBlue) then
		print("DECREASING POWER")

		if selsin == 0 then
			print("SUZ NK")
			print("SUZ: "..tostring(selsin))
		else
			selsin = selsin - 1
			print("POWER DECREASED")
			print("SUZ: "..tostring(selsin))
		end

		print("PARAMETERS REGISTERED")
	elseif rs.testBundledInput(cableSide, colors.yellow) then
		print("INCREASING POWER")

		if selsin == selsinMAX then
			print("SUZ VK")
			print("SUZ: "..tostring(selsin))
		else
			selsin = selsin + 1
			print("POWER INCREASED")
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
			print("PRESSURE IN CIRCUIT #2:		"..tostring(contur2))
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
			contur1 = contur1 - 1
			print("PRESSURE IN CIRCUIT #1 CHANGED")
			print("PRESSURE IN CIRCUIT #1 DECREASED")
			print("PRESSURE IN CIRCUIT #1:		"..tostring(contur1))
			print("PARAMETERS REGISTERED")
		end
	end

	if rs.testBundledInput(cableSide, colors.purple) == true then
		print("ZRK #1 CHANGE")
		print("ZRK #1 CHANGE CIRCUIT #1")
	elseif rs.testBundledInput(cableSide, colors.blue) == true then
		print("ZRK #1 CHANGE")
		print("ZRK #1 CHANGE CIRCUIT #2")
	end

	if rs.testBundledInput(cableSide, colors.brown) == true then
		print("ZRK #2 CHANGE")
		print("ZRK #2 CHANGE CIRCUIT #1")
	elseif rs.testBundledInput(cableSide, colors.green) == true then
		print("ZRK #2 CHANGE")
		print("ZRK #2 CHANGE CIRCUIT #2")
	end

	if sfkre ~= prev_sfkre or prev_reactivity ~= reactivity or prev_period ~= period or prev_heat ~= heat or prev_pp ~= pp then
		prev_sfkre = sfkre
		prev_reactivity = reactivity
		prev_period = period
		prev_heat = heat
		prev_pp = pp

		print("SFKRE:           "..tostring(sfkre))

		if tostring(period) == "inf" or tostring(period) == "nan" then 
			print("PERIOD:          INF")
		else
			print("PERIOD:          "..tostring(period))
		end

		print("REACTIVITY:      "..tostring(reactivity))
	end

	if sfkre <= nominal then
		bolsheNominala = false
		bolsheNominalaV2raza = false
		bolsheNominalaV10raz = false
	end

	if period <= 30 and not tostring(period) == "inf" and not periodMenshe30 then
		periodMenshe30 = true

		print(" --------- WARNING --------- ")
		print("	PERIOD =< 30")
		print(" PERIOD "..tostring(period))
		print(" SFKRE INCREASING PP+REACT ")
		print(" PP INCREASING ")
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
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
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif sfkre > nominal and not bolsheNominala then
		bolsheNominala = true
		bolsheNominalaV2raza = false
		bolsheNominalaV10raz = false

		print("--------- WARNING --------- ")
		print("	SFKRE > DENOMINATION("..tostring(nominal)..")")
		print(" SFKRE "..tostring(sfkre))
		print(" PERIOD "..tostring(period))
		print(" SFKRE INCREASING SG+REACT")
		print(" PP INCREASING ")
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif sfkre >= nominal*2 and not bolsheNominalaV2raza then
		bolsheNominala = true
		bolsheNominalaV2raza = true
		bolsheNominalaV10raz = false

		print("--------- WARNING --------- ")
		print("	SFKRE > DENOMINATION("..tostring(nominal)..") * 2")
		print(" SFKRE "..tostring(sfkre))
		print(" PERIOD "..tostring(period))
		print(" SFKRE INCREASING SG+REACT")
		print(" PP INCREASING ")
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
		print(" REFIX CONTUR #1")
		print(" REFIX CONTUR #2")
		print(" *2 WARNING")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	elseif sfkre >= nominal*10 and not bolsheNominalaV10raz then
		bolsheNominala = true
		bolsheNominalaV2raza = true
		bolsheNominalaV10raz = true

		print("--------- WARNING --------- ")
		print("	SFKRE > DENOMINATION("..tostring(nominal)..") * 10")
		print(" SFKRE "..tostring(sfkre))
		print(" PERIOD "..tostring(period))
		print(" SFKRE INCREASING SG+REACT")
		print(" PP INCREASING ")
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
		print(" REFIX CONTUR #1")
		print(" REFIX CONTUR #2")
		print(" *2 WARNING")
		print(" *10 WARNING")
		print(" PARAMETERS REGISTERED ")
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
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
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
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
		print(" CRIT TEMP SIGNAL ACTIVATED (>6200) ")

		if rs.testBundledInput(cableSide, colors.cyan) == true then
			print("	AZ SUZ <= AUTO")
			print(" AZ SUZ ON")
			print(" AZ SUZ <= AUTO DONE")
		end

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
		print("	SP CHANGE")
		print(" SP CHANGE NOT AUTO")
		print(" STEAM PRESSURE INCREASING")
		print(" PARAMETERS REGISTERED ")
		print(" --------- WARNING --------- ")
	end

	sleep(waitTime)
end
