// DESERT BUS MAIN SCRIPT
// ------------------------------------------------------------------------------------------------

var drivers:Array<Character> = [];
var driverLastPos = [];
var driverAirTimes = [];
var driverFloors:Array<LineSegmentStructure> = [];
var deactivatedPlayers:Array<Character> = [];
var nameplateText:Array<Sprite> = [];
var currentNamePlateID = 0;

var desertDistanceGained = 0;
// THIS SHOULD ROUGHLY BE EQUAL TO 8 HOURS IF THE PLAYER MOVES 7 PIXELS PER FRAME THE WHOLE TIME.
var distanceGoal = 12096000;
var cheatingDist = 25;
var goalReached = false;
var endcutsceneActive = false;
var endcutscene:Projectile = null;
var endingMusic:AudioClip = null;
var endingText:Array<Sprite> = null;
var playersHold = false;
var mileAdvance = 0;
var desertAssets:Array<Sprite> = [];
var sceneryAssets:Array<Array<Sprite>> = [[],[],[],[]];
var parallaxmultiplier = 0.3;
var parallaxmultiplierCurr = 0.3;
var nameplate:Sprite = null;
var spedometer:Sprite = null;
var map:Sprite = null;
var mapOpen = false;
var mapArrow:Sprite = null;
var spedometerValue = 1;
var swerveRate = 0.3;
var turnRate = 0.8;
var sceneryRange = 8;
var distanceMilestone = 0;
var distanceMilestoneMark = 0;

var spdLimit = 10;
var mileNumber:Sprite = null;
var mileValue = 0;
var mileBar:Sprite = null;
var mileCounters:Array<Sprite> = [];

var camSineWaveY = 0;
var camSineRateY = 0.03;
var camSineSizeY = 3;

var skySprite:Sprite = null;
var dayTimer = 0;
var dayAnims = ["sky1", "sky2", "sky3", "sky4"];
var currentTimeOfDay = 0;
var brightnessFilter = new HsbcColorFilter();
var brightnessValues = [0, -0.2, -0.9, -0.5];
var brighteningRate = 0;

var hiddenText:Array<Sprite> = null;
var hiddenTextCurrChar = 0;
var hiddenTextTimer = 0;
var hiddenTextRevealTime = 2;
var hiddenTextRevealAudioID = "textappear";

var spdlimitViolations = 0;
var idleTime = 0;
var timer = [0, 0, 0, 0];
var dirtTime = 0;
var mapChecks = 0;
var deaths = 0;

function initialize(){
	self.pause();

	generateDesertSprites();

	sceneryAssets[2].push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundEffectsContainer().addChild(sceneryAssets[2][sceneryAssets[2].length - 1]);
	sceneryAssets[2][sceneryAssets[2].length - 1].currentAnimation = "scenery";
	sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame = 5;
	sceneryAssets[2][sceneryAssets[2].length - 1].x = 150;
	sceneryAssets[2][sceneryAssets[2].length - 1].y = 40;

	match.addEventListener(MatchEvent.TICK_END, calculateDesertDistance, {persistent: true});
	match.addEventListener(AssistEvent.CUTIN, function(event:AssistEvent){
		event.data.assist.dispose();
	}, {persistent: true});

	distanceMilestone = distanceGoal / 5;
	distanceMilestoneMark = distanceMilestone;

	self.exports = {
		endcutsceneVerify: function(): Boolean{
			if(endcutsceneActive){
				return true;
			}
			else{
				return false;
			}
		},
		updateHiddenTextValues: function(revealTime:Int, currentCharacter:Int, revealAudio:String){
			if(revealTime != null){
				hiddenTextRevealTime = revealTime;
			}
			if(currentCharacter != null){
				hiddenTextCurrChar = currentCharacter;
			}
			if(revealAudio != null){
				hiddenTextRevealAudioID = revealAudio;
			}
		},
		generateText: generateText,
		hiddenTextReadCheck: function(): Boolean{
			if(hiddenText != null){
				return true;
			}
			else{
				return false;
			}
		},
		updatePlayersHold: function(on:Boolean){
			playersHold = on;
		},
		getDriverData: function(): Array<Character>{
			return drivers;
		},
		spawnStatData: function(wishData): Array<String>{
			generateText("" + timer[0] + "=", "font2", 8, 88, 81, 2, 0, camera.getForegroundContainer(), false);
			generateText("" + timer[1] + "=", "font2", 8, 136, 81, 2, 0, camera.getForegroundContainer(), false);
			generateText("" + timer[2] + "=", "font2", 8, 186, 81, 2, 0, camera.getForegroundContainer(), false);

			generateText("" + Math.floor(idleTime / 60), "font2", 8, 96, 107, 2, 0, camera.getForegroundContainer(), false);
			generateText("" + Math.floor(dirtTime / 60), "font2", 8, 98, 133, 2, 0, camera.getForegroundContainer(), false);
			generateText("" + spdlimitViolations, "font2", 8, 140, 158, 2, 0, camera.getForegroundContainer(), false);
			generateText("" + mapChecks, "font2", 8, 100, 183, 2, 0, camera.getForegroundContainer(), false);
			generateText("" + deaths, "font2", 8, 98, 209, 2, 0, camera.getForegroundContainer(), false);
			generateText("" + wishData, "font2", 8, 72, 235, 2, 0, camera.getForegroundContainer(), false);
		}
	}
}

function update(){
	if(drivers.length == 0){
		getDrivers();
	}
	if(deactivatedPlayers.length > 0){
		holdDeactivePlyrs();
	}
	if(playersHold){
		holdActivePlyrs();
	}

	updateDayTimer();
	updateCamShake();
	updateMap();
	if(hiddenText != null){
		updateHiddenText();
	}

	if(goalReached){
		if(desertDistanceGained >= distanceGoal + 4580 && !endcutsceneActive){
			onEndReached();
		}
	}
	else{
		updateTime();
	}
}

// RUNS AT END TICK, CHECKS EVERY PLAYER FOR BOUNDRY PUSH
function calculateDesertDistance(){
	if(endcutsceneActive){
		for(i in 0...drivers.length){
			if(drivers[i].getX() > 320){
				drivers[i].setX(320);
			}
			else if(drivers[i].getX() < -320){
				drivers[i].setX(-320);
			}
		}
		return;
	}
	var totalDistanceGained = 0;
	if(drivers.length == 0){
		return;
	}
	for(i in 0...drivers.length){
		drivers[i].setAssistCharge(0);
		driftCharacter(drivers[i], i);
		if(!drivers[i].isOnFloor()){
			if(driverAirTimes[i] >= 140){
				driverAirTimes[i] = 0;
				drivers[i].setXVelocity(0);
				drivers[i].toState(CState.FALL_SPECIAL);
			}
			else{
				driverAirTimes[i]++;
			}
		}
		else{
			driverAirTimes[i] = 0;
		}

		if(drivers[i].getX() > 0){
			var dist = drivers[i].getX();
			if(dist > cheatingDist || drivers[i].getState() == CState.CRASH_BOUNCE && dist > 4){
				distanceGoal += dist;
			}

			totalDistanceGained += dist;
			if(mileNumber != null){
				mileValue += dist;
				if(mileValue > 8000){
					updateMileCounter();
					mileValue -= 8000;
				}
				mileNumber.currentFrame = Math.round(mileValue / 8);
			}
			moveDesert(dist, drivers[i]);

			drivers[i].setX(0);

			if(currentNamePlateID != i){
				if(nameplateText.length > 0){
					for(i in 0...nameplateText.length){
						nameplateText[i].dispose();
					}
					nameplateText = generateText(drivers[i].getPlayerConfig().character.contentId, "font1", 8, 50, 16, 1, 10, 
					camera.getForegroundContainer(), false);
					currentNamePlateID = i;
				}
			}
		}
		driverLastPos[i] = drivers[i].getX();
	}
	if(totalDistanceGained == 0){
		idleTime += 1;
	}
	updateSpedometer(totalDistanceGained);

	if(desertDistanceGained >= distanceGoal && !goalReached){
		goalReached = true;
		goalEvent();
	}
}

// MOVES DESERT TERRAIN AND PLAYERS WHEN DESERT BOUNDRY IS PUSHED
function moveDesert(distance, driver){
	desertDistanceGained += distance;

	parallaxmultiplierCurr = parallaxmultiplier;
	for(i in 0...desertAssets.length){
		desertAssets[i].x -= distance * parallaxmultiplierCurr;
		if(desertAssets[i].x < -740){
			desertAssets[i].x += 740;
			spawnNotableScenery();
		}
		moveScenery(distance, i);
		parallaxmultiplierCurr += (1 - parallaxmultiplier) / 3;
	}

	// moves foes with terrain
	for(i in 0...drivers.length){
		if(drivers[i].getUid() != driver.getUid()){
			drivers[i].setX(drivers[i].getX() - driver.getX());
			driverLastPos[i] = drivers[i].getX();
		}
	}
}

// MOVES SCENERY WITH TERRAIN AND DISPOSES OLD SCENERY OUT OF VIEW, ALSO SPAWNS NEW SCENERY
// =================================================================
	// note: kinda hate how this is clearing deleted scenery by just replacing the og array with a new one, feel like that this isn't a 			very efficient solution computation-wise and potentially laggy in long-term gameplay.
// =================================================================
function moveScenery(distance, index){
	if(sceneryAssets[index].length > 0){
		var updatedArray = [];
		for(a in 0...sceneryAssets[index].length){
			sceneryAssets[index][a].x -= distance * parallaxmultiplierCurr;
			if(sceneryAssets[index][a].x < -440 && !goalReached){
				sceneryAssets[index][a].removeFilter(brightnessFilter);
				sceneryAssets[index][a].dispose();
			}
			else{
				updatedArray.push(sceneryAssets[index][a]);
			}
		}
		sceneryAssets[index] = updatedArray;
	}
	if(desertDistanceGained >= distanceMilestoneMark){
		distanceMilestoneMark += distanceMilestone;
		sceneryRange += 1;
	}
	spawnScenery(index);
}

// SPAWNS COMMON SCENERY ON ALL LAYERS
function spawnScenery(layer){
	if(goalReached){
		return;
	}
	switch(layer){
		case 3:
		var rate = Random.getInt(0, 22);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				self.getForegroundFrontContainer().addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 440;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = 230;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleX = 1.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleY = 1.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
		case 2:
			var rate = Random.getInt(0, 35);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				self.getBackgroundStructuresContainer().addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 440;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = Random.getInt(27, 55);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
		case 1:
			var rate = Random.getInt(0, 30);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				self.getBackgroundStructuresContainer().addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 440;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = Random.getInt(11, -22);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleX = 0.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleY = 0.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
		case 0:
			var rate = Random.getInt(0, 25);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				self.getBackgroundStructuresContainer().addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 440;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = Random.getInt(-28, -45);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleX = 0.5;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleY = 0.5;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
	}
}

// SPAWNS SPECIAL SCENERY, SUCH AS SIGNS AND BILLBOARDS
function spawnNotableScenery(){
	if(goalReached){
		return;
	}
	var rate = Random.getInt(0, 8);
		if(rate == 0){
			sceneryAssets[2].push(Sprite.create(self.getResource().getContent("desertbusstage")));
			self.getBackgroundEffectsContainer().addChild(sceneryAssets[2][sceneryAssets[2].length - 1]);
			sceneryAssets[2][sceneryAssets[2].length - 1].currentAnimation = "scenery";
			sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame = Random.getInt(2, sceneryRange);
			if(sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame == 8){
				spdLimit = 8.2;
			}
			else if(sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame == 3){
				spdLimit = 10;
			}
			sceneryAssets[2][sceneryAssets[2].length - 1].x = 440;
			sceneryAssets[2][sceneryAssets[2].length - 1].y = Random.getInt(27, 55);
			sceneryAssets[2][sceneryAssets[2].length - 1].addFilter(brightnessFilter);
		}
}

// UPDATES SPEDOMETER AND STOPS PLAYERS IF THEY GO OVER SPD LIMIT
function updateSpedometer(distance){
	if(distance == 0){
		spedometerValue = 0;
	}
	else if(distance < spedometerValue){
		spedometerValue -= 0.25 * distance / 10;
	}
	else{
		spedometerValue += 0.25 * distance / 10;
	}

	if(spedometerValue >= spdLimit){
		var temp = match.createVfx(new VfxStats({spriteContent: self.getResource().getContent("desertbusstage"), 
		animation: "hud_spdlimitwarning"}));
		camera.getForegroundContainer().addChild(temp.getSprite());
		for(i in 0...drivers.length){
			spdlimitViolations += 1;
			drivers[i].setXVelocity(0);
			drivers[i].toState(CState.CRASH_BOUNCE);
			spedometerValue = 0;
		}
	}

	spedometer.currentFrame = Math.round(spedometerValue);
}

// DRIFTS CHARACTERS DEPENDING ON THEIR DISTANCE FROM LAST POSITION
function driftCharacter(char:Character, index){
	if(char.getState() == CState.KO || char.getState() == CState.REVIVAL){
		return;
	}
	if(!char.isOnFloor()){
		if(driverFloors[index].getY() != 107){
			drivers[index].setY(drivers[index].getY() + -(driverFloors[index].getY() - 107));
		}
		driverFloors[index].setY(107);
	}

	if(driverFloors[index].getY() > 190 || driverFloors[index].getY() < 65){
		char.setX(driverLastPos[index]);
	}
	else if(driverFloors[index].getY() > 180 || driverFloors[index].getY() < 70){
		distancePenalty(index);
	}
	
	if(char.isOnFloor()){
		if(char.getHeldControls().UP){
			if(char.getPressedControls().UP){
				swerveRate = Random.getFloat(0.2, 0.4);
			}
			driverFloors[index].setY(driverFloors[index].getY() - turnRate * Math.abs(char.getX() - driverLastPos[index]) / 10);
		}
		else{
			driverFloors[index].setY(driverFloors[index].getY() + swerveRate * Math.abs(char.getX() - driverLastPos[index]) / 10);
		}
	}
}

function distancePenalty(index){
	dirtTime += 1;
	if(drivers[index].getX() != driverLastPos[index] && dirtTime % 6 == 0){
		AudioClip.play(GlobalSfx.SPOT_DODGE);
	}
	drivers[index].setX(driverLastPos[index] + Math.abs(drivers[index].getX() - driverLastPos[index]) / 4 * (drivers[index].getX() < driverLastPos[index] ? -1 : 1));
}

// UPDATES THE WHITE NUMBERS ON THE MILE COUNTER, UPDATES EVERYTIME THE ACTIVE COUNTER REACHES 0
function updateMileCounter(){
	if(mileCounters[0].currentFrame == mileCounters[0].totalFrames){
		if(mileCounters[1].currentFrame == mileCounters[1].totalFrames){
			if(mileCounters[2].currentFrame == mileCounters[2].totalFrames){
				mileCounters[3].advance();
			}
			mileCounters[2].advance();
		}
		mileCounters[1].advance();
	}
	mileCounters[0].advance();
}

function updateDayTimer(){
	dayTimer++;
	if(skySprite.currentFrame != skySprite.totalFrames){
		if(brightnessFilter.brightness > brightnessValues[currentTimeOfDay] && brighteningRate < 0 || brightnessFilter.brightness < brightnessValues[currentTimeOfDay] && brighteningRate >= 0){
			brightnessFilter.brightness += brighteningRate;
		}
		skySprite.currentFrame += 1;
	}
	if(dayTimer >= 100000){
		dayTimer = 0;
		if(currentTimeOfDay == dayAnims.length - 1){
			currentTimeOfDay = 0;
		}
		else{
			currentTimeOfDay++;
		}
		skySprite.currentAnimation = dayAnims[currentTimeOfDay];
		brighteningRate = 0.005 * (brightnessValues[currentTimeOfDay] < brightnessFilter.brightness ? -1 : 1);
	}
}

function updateMap(){
	for(i in 0...drivers.length){
		if(drivers[i].getPressedControls().ACTION && !goalReached){
			mapOpen = !mapOpen;
			if(mapOpen){
				mapChecks += 1;
				AudioClip.play(self.getResource().getContent("mapopen" + Random.getInt(1, 2)));
			}
			else{
				AudioClip.play(self.getResource().getContent("mapclose"));
			}
			break;
		}
	}

	if(mapOpen){
		if(map.currentFrame != map.totalFrames){
			map.currentFrame += 1;
		}
	}
	else{
		if(map.currentFrame != 1){
			map.currentFrame -= 1;
		}
	}
	mapArrow.advance();
	mapArrow.scaleX = (map.currentFrame - 1) / (map.totalFrames - 1);
	if(goalReached){
		mapArrow.x = 320 + 176 * (map.currentFrame - 1) / (map.totalFrames - 1);
	}
	else{
		var t = desertDistanceGained / distanceGoal;
		var easedT = 1 - Math.pow(1 - t, 4);
		mapArrow.x = 320 + (-174 + easedT * 350) * (map.currentFrame - 1) / (map.totalFrames - 1);
	}
}

// -----------------------------------------------------------------------------------

function getDrivers(){
	var possibleDrivers = match.getCharacters();
	for(i in 0...possibleDrivers.length){
		possibleDrivers[i].getDamageCounterContainer().alpha = 0;
		if(possibleDrivers[i].getPlayerConfig().cpu && possibleDrivers[i].getPlayerConfig().level > 0){
			deactivatedPlayers.push(possibleDrivers[i]);
		}
		else{
			possibleDrivers[i].addFilter(brightnessFilter);
			if(possibleDrivers[i].getCharacterStat("runSpeedCap") > 8){
				possibleDrivers[i].updateCharacterStats({runSpeedCap: 8});
			}
			drivers.push(possibleDrivers[i]);
			possibleDrivers[i].setLives(99);
			possibleDrivers[i].addEventListener(CharacterEvent.KNOCK_OUT, function(){
				driverFloors[i].setY(107);
				deaths += 1;
			}, {persistent: true});
			driverLastPos.push(0);
			driverAirTimes.push(0);
			driverFloors.push(match.createLineSegmentStructure([-500, 0, 5000, 0], 
			new StructureStats({structureType: StructureType.FLOOR})));
			driverFloors[driverFloors.length - 1].addToWhitelist(drivers[i]);
			driverFloors[driverFloors.length - 1].setY(107);
		}
	}
	nameplateText = generateText(drivers[0].getPlayerConfig().character.contentId, "font1", 8, 50, 16, 1, 10, camera.getForegroundContainer(), false);
}

function holdDeactivePlyrs(){
	for(i in 0...deactivatedPlayers.length){
		deactivatedPlayers[i].setX(-220);
		deactivatedPlayers[i].setY(-120);
		deactivatedPlayers[i].setState(CState.INTRO);
		deactivatedPlayers[i].playAnimation("stand");
		deactivatedPlayers[i].setScaleX(0);
		deactivatedPlayers[i].setScaleY(0);
		deactivatedPlayers[i].getDamageCounterContainer().alpha = 0;
	}
}

function holdActivePlyrs(){
	for(i in 0...drivers.length){
		drivers[i].setX(-220);
		drivers[i].setY(-120);
		drivers[i].setState(CState.INTRO);
		drivers[i].playAnimation("stand");
		drivers[i].setScaleX(0);
		drivers[i].setScaleY(0);
		drivers[i].getDamageCounterContainer().alpha = 0;
	}
}

function updateTime(){
	timer[3] += 1;
	if(timer[3] >= 60){
		timer[3] = 0;
		timer[2] += 1;
		if(timer[2] >= 60){
			timer[2] = 0;
			timer[1] += 1;
			if(timer[1] >= 60){
				timer[1] = 0;
				timer[0] += 1;
			}
		}
	}
	Engine.log(timer);
}

function updateCamShake(){
	self.getCameraBounds().setY(-185 + Math.sin(camSineWaveY) * camSineSizeY);
	camSineWaveY += camSineRateY;
	if(camSineWaveY >= 2 * Math.PI){
		camSineWaveY = 0;
	}
}

function generateText(textString:String, fontAnim, spacing, x, y, scale, scaleLimit, container:Container, isHiddenText:Boolean): Array{
	var arry = [];
	var lineStartX = 0;
	var scaleMulti = 1;
	var spacingMulti = 0;
	if(textString.length > scaleLimit){
		scaleMulti = scaleLimit / textString.length;
	}

	for(i in 0...textString.length){
		var temp = Sprite.create(self.getResource().getContent("desertbusstage"));
		container.addChild(temp);
		temp.currentAnimation = fontAnim;
		if(scaleLimit > 0){
			temp.x = x + ((spacing * scale) * spacingMulti) * scaleMulti;
			temp.scaleX = scale * scaleMulti;
		}
		else{
			temp.x = x + ((spacing * scale) * spacingMulti);
			temp.scaleX = scale;
		}
		temp.y = y;
		temp.scaleY = scale;
		if(isHiddenText){
			temp.visible = false;
		}
		spacingMulti += 1;

		switch(textString.toLowerCase().charAt(i)){
			default:
			temp.currentFrame = 30;
			case "a":
			temp.currentFrame = 1;
			case "b":
			temp.currentFrame = 2;
			case "c":
			temp.currentFrame = 3;
			case "d":
			temp.currentFrame = 4;
			case "e":
			temp.currentFrame = 5;
			case "f":
			temp.currentFrame = 6;
			case "g":
			temp.currentFrame = 7;
			case "h":
			temp.currentFrame = 8;
			case "i":
			temp.currentFrame = 9;
			case "j":
			temp.currentFrame = 10;
			case "k":
			temp.currentFrame = 11;
			case "l":
			temp.currentFrame = 12;
			case "m":
			temp.currentFrame = 13;
			case "n":
			temp.currentFrame = 14;
			case "o":
			temp.currentFrame = 15;
			case "p":
			temp.currentFrame = 16;
			case "q":
			temp.currentFrame = 17;
			case "r":
			temp.currentFrame = 18;
			case "s":
			temp.currentFrame = 19;
			case "t":
			temp.currentFrame = 20;
			case "u":
			temp.currentFrame = 21;
			case "v":
			temp.currentFrame = 22;
			case "w":
			temp.currentFrame = 23;
			case "x":
			temp.currentFrame = 24;
			case "y":
			temp.currentFrame = 25;
			case "z":
			temp.currentFrame = 26;
			case "?":
			temp.currentFrame = 27;
			case ".":
			temp.currentFrame = 28;
			case ",":
			temp.currentFrame = 29;
			case " ":
			temp.currentFrame = 30;
			case "/":
			temp.currentFrame = 30;
			y += 8.5 * scale;
			spacingMulti = 0;
			lineStartX = i + 1;
			case "=":
			temp.currentFrame = 30;
			y += 8.5 * scale;
			spacingMulti = 0;
			for(a in 0...arry.length){
				if(a >= lineStartX){
					if(scaleLimit){
						arry[a].x -= (((spacing * scale) * (arry.length - lineStartX)) / 2) * scaleMulti;
					}
					else{
						arry[a].x -= (((spacing * scale) * (arry.length - lineStartX)) / 2);
					}
				}
			}
			lineStartX = i + 1;
			case "0":
			temp.currentFrame = 31;
			case "1":
			temp.currentFrame = 32;
			case "2":
			temp.currentFrame = 33;
			case "3":
			temp.currentFrame = 34;
			case "4":
			temp.currentFrame = 35;
			case "5":
			temp.currentFrame = 36;
			case "6":
			temp.currentFrame = 37;
			case "7":
			temp.currentFrame = 38;
			case "8":
			temp.currentFrame = 39;
			case "9":
			temp.currentFrame = 40;
		}
	arry.push(temp);
	}
	if(isHiddenText){
		hiddenTextCurrChar = 0;
		hiddenText = arry;
	}
	return arry;
}

function updateHiddenText(){
	hiddenTextTimer += 1;
	if(hiddenTextTimer > hiddenTextRevealTime){
		hiddenTextTimer = 0;
		if(hiddenTextRevealAudioID != null){
			AudioClip.play(self.getResource().getContent(hiddenTextRevealAudioID), {volume: Random.getInt(3, 5)});
		}
		hiddenText[hiddenTextCurrChar].visible = true;
		hiddenTextCurrChar += 1;
		if(hiddenTextCurrChar == hiddenText.length){
			hiddenText = null;
			hiddenTextCurrChar = 0;
			hiddenTextTimer = 0;
		}
	}
}

function generateDesertSprites(){
	skySprite = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getBackgroundContainers()[0].addChild(skySprite);
	skySprite.currentAnimation = "sky1";
	skySprite.currentFrame = skySprite.totalFrames;

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundStructuresContainer().addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_plain3";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundStructuresContainer().addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_plain2";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundStructuresContainer().addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_plain1";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundStructuresContainer().addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_road";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

	nameplate = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getForegroundContainer().addChild(nameplate);
	nameplate.currentAnimation = "hud_nameplate";

	mileBar = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getForegroundContainer().addChild(mileBar);
	mileBar.currentAnimation = "hud_miles";

	var mask = new Mask(6, 8);
	mask.x = 555;
	mask.y = 345;
	camera.getForegroundContainer().addChild(mask);
	mileNumber = Sprite.create(self.getResource().getContent("desertbusstage"));
	mileNumber.x = 1;
	mileNumber.y = 8;
	mileNumber.currentAnimation = "mile_counter";
	var wrapper = Container.create();
	wrapper.addChild(mileNumber);
	wrapper.x = 0;
	wrapper.y = 0;
	mask.addChild(wrapper);

	mileCounters.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	camera.getForegroundContainer().addChild(mileCounters[mileCounters.length - 1]);
	mileCounters[mileCounters.length - 1].currentAnimation = "mile_counter2";
	mileCounters[mileCounters.length - 1].x = 549;
	mileCounters[mileCounters.length - 1].y = 346;

	mileCounters.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	camera.getForegroundContainer().addChild(mileCounters[mileCounters.length - 1]);
	mileCounters[mileCounters.length - 1].currentAnimation = "mile_counter2";
	mileCounters[mileCounters.length - 1].x = 544;
	mileCounters[mileCounters.length - 1].y = 346;

	mileCounters.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	camera.getForegroundContainer().addChild(mileCounters[mileCounters.length - 1]);
	mileCounters[mileCounters.length - 1].currentAnimation = "mile_counter2";
	mileCounters[mileCounters.length - 1].x = 539;
	mileCounters[mileCounters.length - 1].y = 346;

	mileCounters.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	camera.getForegroundContainer().addChild(mileCounters[mileCounters.length - 1]);
	mileCounters[mileCounters.length - 1].currentAnimation = "mile_counter2";
	mileCounters[mileCounters.length - 1].x = 534;
	mileCounters[mileCounters.length - 1].y = 346;

	spedometer = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getForegroundContainer().addChild(spedometer);
	spedometer.currentAnimation = "hud_spedometer";

	map = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getForegroundContainer().addChild(map);
	map.currentAnimation = "hud_map";

	mapArrow = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getForegroundContainer().addChild(mapArrow);
	mapArrow.currentAnimation = "hud_maparrow";
	mapArrow.scaleX = 0;
	mapArrow.y = 192;
	mapArrow.x = 146;
}

function onEndReached(){
	endcutsceneActive = true;
	endcutscene = match.createProjectile(self.getResource().getContent("endcutscene"), null);
	AudioClip.play(GlobalSfx.MENU_SELECT, {volume: 3, channel: "bgm"});
	nameplate.alpha = 0;
	mileBar.alpha = 0;
	mileNumber.alpha = 0;
	mileCounters[0].alpha = 0;
	mileCounters[1].alpha = 0;
	mileCounters[2].alpha = 0;
	mileCounters[3].alpha = 0;
	spedometer.alpha = 0;
	if(nameplateText.length > 0){
		for(i in 0...nameplateText.length){
			nameplateText[i].alpha = 0;
		}
	}
}

function goalEvent(){
	sceneryAssets[1].push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundStructuresContainer().addChild(sceneryAssets[1][sceneryAssets[1].length - 1]);
	sceneryAssets[1][sceneryAssets[1].length - 1].currentAnimation = "ending_scenery1";
	sceneryAssets[1][sceneryAssets[1].length - 1].x = 850;
	sceneryAssets[1][sceneryAssets[1].length - 1].y = 5;
	sceneryAssets[1][sceneryAssets[1].length - 1].addFilter(brightnessFilter);

	sceneryAssets[2].push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundStructuresContainer().addChild(sceneryAssets[2][sceneryAssets[2].length - 1]);
	sceneryAssets[2][sceneryAssets[2].length - 1].currentAnimation = "ending_scenery2";
	sceneryAssets[2][sceneryAssets[2].length - 1].x = 850;
	sceneryAssets[2][sceneryAssets[2].length - 1].y = 60;
	sceneryAssets[2][sceneryAssets[2].length - 1].addFilter(brightnessFilter);

	sceneryAssets[3].push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getBackgroundStructuresContainer().addChild(sceneryAssets[3][sceneryAssets[3].length - 1]);
	sceneryAssets[3][sceneryAssets[3].length - 1].currentAnimation = "ending_scenery3";
	sceneryAssets[3][sceneryAssets[3].length - 1].x = 850;
	sceneryAssets[3][sceneryAssets[3].length - 1].y = 0;
	sceneryAssets[3][sceneryAssets[3].length - 1].addFilter(brightnessFilter);

	sceneryAssets[3].push(Sprite.create(self.getResource().getContent("desertbusstage")));
	self.getForegroundFrontContainer().addChild(sceneryAssets[3][sceneryAssets[3].length - 1]);
	sceneryAssets[3][sceneryAssets[3].length - 1].currentAnimation = "ending_scenery4";
	sceneryAssets[3][sceneryAssets[3].length - 1].x = 850;
	sceneryAssets[3][sceneryAssets[3].length - 1].y = 0;
	sceneryAssets[3][sceneryAssets[3].length - 1].addFilter(brightnessFilter);

	mapOpen = false;
	map.alpha = 0;
}



function onTeardown(){
}
function onKill(){
}
function onStale(){
}
function afterPushState(){
}
function afterPopState(){
}
function afterFlushStates(){
}

