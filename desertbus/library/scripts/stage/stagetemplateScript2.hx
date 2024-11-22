
var desertAssets:Array<Sprite> = [];
var sceneryAssets:Array<Array<Sprite>> = [[],[],[],[]];
var busAsset:Sprite = null;
var busAsset2:Sprite = null;

var parallaxmultiplier = 0.3;
var parallaxmultiplierCurr = 0.3;

var skySprite:Sprite = null;
var dayTimer = 0;
var dayAnims = ["sky1", "sky2", "sky3", "sky4"];
var currentTimeOfDay = 0;
var brightnessFilter = new HsbcColorFilter();
var brightnessValues = [0, -0.2, -0.9, -0.5];
var brighteningRate = 0;

var baseCamY = self.getCameraBounds().getY();
var camSineWaveY = 0;
var camSineRateY = 0.05;
var camSineSizeY = 3;

var busSpd = 4;
var plyrsFound = false;

var sceneryCont = Container.create();
self.getBackgroundBehindContainer().addChild(sceneryCont);
var busCont = Container.create();
self.getBackgroundBehindContainer().addChild(busCont);

function initialize(){
	generateDesertSprites();
	
    sceneryAssets[2].push(Sprite.create(self.getResource().getContent("desertbusstage")));
	sceneryCont.addChild(sceneryAssets[2][sceneryAssets[2].length - 1]);
	sceneryAssets[2][sceneryAssets[2].length - 1].currentAnimation = "scenery";
	sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame = 5;
	sceneryAssets[2][sceneryAssets[2].length - 1].x = 400;
	sceneryAssets[2][sceneryAssets[2].length - 1].y = 40;
}

function update(){
    if(!plyrsFound){
        var plyrs = match.getCharacters();
        for(i in 0...plyrs.length){
            plyrs[i].addFilter(brightnessFilter);
        }
        plyrsFound = true;
        return;
    }

    if(busAsset != null){
        busAsset.advance();
        moveDesert();
        camera.verticalShake(3, 2);
        //updateCamShake();
    }

    moveRoadPlyrs();

    updateDayTimer();
}

function moveRoadPlyrs(){
    var plyrs = match.getCharacters();
    for(i in 0...plyrs.length){
        if(plyrs[i].getY() >= 115 && plyrs[i].isOnFloor()){
            plyrs[i].moveAbsolute(-busSpd, 0);
            if(plyrs[i].getX() < 200 && plyrs[i].getX() > 0){
                plyrs[i].unattachFromFloor();
                plyrs[i].takeHit(new HitboxStats({damage: 12, angle: 75, baseKnockback: 70, knockbackGrowth: 100, owner: null, 
                    hitstop: -1, hitstun: -1, reversibleAngle: false}));
            }
        }
    }
}

function moveScenery(index){
	if(sceneryAssets[index].length > 0){
		var updatedArray = [];
		for(a in 0...sceneryAssets[index].length){
			sceneryAssets[index][a].x -= busSpd * parallaxmultiplierCurr;
			if(sceneryAssets[index][a].x < -800){
				sceneryAssets[index][a].removeFilter(brightnessFilter);
				sceneryAssets[index][a].dispose();
			}
			else{
				updatedArray.push(sceneryAssets[index][a]);
			}
		}
		sceneryAssets[index] = updatedArray;
	}
	spawnScenery(index);
}

function spawnScenery(layer){
	switch(layer){
		case 3:
		var rate = Random.getInt(0, 22);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				self.getForegroundFrontContainer().addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 800;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = 230;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleX = 1.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleY = 1.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
		case 2:
			var rate = Random.getInt(0, 35);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				sceneryCont.addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 800;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = Random.getInt(27, 55);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
		case 1:
			var rate = Random.getInt(0, 30);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				sceneryCont.addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 800;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = Random.getInt(11, -22);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleX = 0.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleY = 0.8;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
		case 0:
			var rate = Random.getInt(0, 25);
			if(rate == 0){
				sceneryAssets[layer].push(Sprite.create(self.getResource().getContent("desertbusstage")));
				sceneryCont.addChild(sceneryAssets[layer][sceneryAssets[layer].length - 1]);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentAnimation = "scenery";
				sceneryAssets[layer][sceneryAssets[layer].length - 1].currentFrame = 1;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].x = 800;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].y = Random.getInt(-28, -45);
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleX = 0.5;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].scaleY = 0.5;
				sceneryAssets[layer][sceneryAssets[layer].length - 1].addFilter(brightnessFilter);
			}
	}
}

function spawnNotableScenery(){
	var rate = Random.getInt(0, 8);
		if(rate == 0){
			sceneryAssets[2].push(Sprite.create(self.getResource().getContent("desertbusstage")));
			sceneryCont.addChild(sceneryAssets[2][sceneryAssets[2].length - 1]);
			sceneryAssets[2][sceneryAssets[2].length - 1].currentAnimation = "scenery";
			sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame = Random.getInt(2, 12);
			if(sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame == 8){
				busSpd = 4;
			}
			else if(sceneryAssets[2][sceneryAssets[2].length - 1].currentFrame == 3){
				busSpd = 6;
			}
			sceneryAssets[2][sceneryAssets[2].length - 1].x = 800;
			sceneryAssets[2][sceneryAssets[2].length - 1].y = Random.getInt(27, 55);
			sceneryAssets[2][sceneryAssets[2].length - 1].addFilter(brightnessFilter);
		}
}

function updateCamShake(){
    self.getCameraBounds().setY(baseCamY + Math.sin(camSineWaveY) * camSineSizeY);
	camSineWaveY += camSineRateY;
	if(camSineWaveY >= 2 * Math.PI){
		camSineWaveY = 0;
	}
}

function moveDesert(){
	parallaxmultiplierCurr = parallaxmultiplier;
	for(i in 0...desertAssets.length){
		desertAssets[i].x -= busSpd * parallaxmultiplierCurr;
		if(desertAssets[i].x < -740){
			desertAssets[i].x += 740;
            spawnNotableScenery();
		}
        moveScenery(i);
		parallaxmultiplierCurr += (1 - parallaxmultiplier) / 3;
	}
}

function updateDayTimer(){
	dayTimer++;
	if(skySprite.currentFrame != skySprite.totalFrames){
		if(brightnessFilter.brightness > brightnessValues[currentTimeOfDay] && brighteningRate < 0 || brightnessFilter.brightness < brightnessValues[currentTimeOfDay] && brighteningRate >= 0){
			brightnessFilter.brightness += brighteningRate;
		}
		skySprite.currentFrame += 1;
	}
	if(dayTimer >= 5000){
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

function generateDesertSprites(){
	skySprite = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getBackgroundContainers()[0].addChild(skySprite);
	skySprite.currentAnimation = dayAnims[currentTimeOfDay];
	skySprite.currentFrame = skySprite.totalFrames;
    brightnessFilter.brightness = brightnessValues[currentTimeOfDay];

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	sceneryCont.addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_plain3";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	sceneryCont.addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_plain2";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	sceneryCont.addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_plain1";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

	desertAssets.push(Sprite.create(self.getResource().getContent("desertbusstage")));
	sceneryCont.addChild(desertAssets[desertAssets.length - 1]);
	desertAssets[desertAssets.length - 1].currentAnimation = "desert_road";
	desertAssets[desertAssets.length - 1].addFilter(brightnessFilter);

    busAsset = Sprite.create(self.getResource().getContent("desertbusstage"));
	busCont.addChild(busAsset);
	busAsset.currentAnimation = "bus_stage";
    busAsset.addFilter(brightnessFilter);

    busAsset2 = Sprite.create(self.getResource().getContent("desertbusstage"));
	self.getForegroundFrontContainer().addChild(busAsset2);
	busAsset2.currentAnimation = "bus_stageFront";
    busAsset2.addFilter(brightnessFilter);
}