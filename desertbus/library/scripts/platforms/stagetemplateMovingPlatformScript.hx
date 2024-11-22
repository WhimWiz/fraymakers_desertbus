// Script for Stage Template moving platform beneath the stage

var supremefish:Sprite = null;
var supremefishSineWave = 0;
var supremefishSineRate = 0.05;
var supremefishSineSize = 4;
var bgWave:Vfx = null;

var drivers:Array<Character> = null;
var choiceArrow:Sprite = null;
var choice = 1;
var choiceTexts = ["POWER", "MONEY", "FAME"];
var choiceXPos = [180, 320, 460];
var additionalText = [];

function initialize(){
	drivers = stage.exports.getDriverData();
	camera.getForegroundContainer().addChild(self.getSprite());
}

function update(){
	if(self.getAnimation() == "endcutscene" && self.getCurrentFrame() < 255 && self.getCurrentFrame() % 2 == 0){
        match.freezeScreen(1, [camera, self, stage]);
    }

    if(self.getAnimation() == "endcutscene2_loop"){
		updateArrow();
	}

	if(self.getAnimation() == "endcutscene3" && self.getCurrentFrame() >= 370 && bgWave != null && bgWave.getSprite().alpha > 0){
		bgWave.getSprite().alpha -= 0.05;
		if(bgWave.getSprite().alpha <= 0){
			bgWave.dispose();
			bgWave = null;
		}
	}

	if(self.getAnimation() == "endcutscene4" && self.getCurrentFrame() > self.getTotalFrames() - 3 && drivers.length > 0){
		for(i in 0...drivers.length){
			if(drivers[i].getPressedControls().ATTACK){
				stage.exports.updatePlayersHold(false);
				for(a in 0...drivers.length){
					drivers[i].setLives(1);
					drivers[i].setY(1000);
				}
				break;
			}
		}
	}

    if(supremefish != null){
        updateFish();
    }
}

function updateArrow(){
	if(drivers != null){
		for(i in 0...drivers.length){
			if(drivers[i].getPressedControls().LEFT){
				choice -= 1;
				if(choice < 0){
					choice = choiceXPos.length - 1;
				}
				AudioClip.play(GlobalSfx.MENU_COSTUME_DOWN);
				choiceArrow.x = choiceXPos[choice];
			}
			else if(drivers[i].getPressedControls().RIGHT){
				choice += 1;
				if(choice >= choiceXPos.length){
					choice = 0;
				}
				choiceArrow.x = choiceXPos[choice];
				AudioClip.play(GlobalSfx.MENU_COSTUME_UP);
			}
			else if(drivers[i].getPressedControls().ATTACK){
				AudioClip.play(GlobalSfx.MENU_SELECT);
				self.playAnimation("endcutscene3");
				break;
			}
		}
	}
}

function spawnFish(){
	supremefish = Sprite.create(self.getResource().getContent("desertbusstage"));
	camera.getForegroundContainer().addChild(supremefish);
	supremefish.currentAnimation = "ending_supremefish_idle";
    supremefish.alpha = 0;
    supremefish.x = 320;
    supremefish.y = 185;
    AudioClip.play(self.getResource().getContent("warp"));
}

function updateFish(){
	if(supremefish.alpha < 1){
		supremefish.alpha += 0.01;
	}
    if(self.getAnimation() != "endcutscene3" && bgWave.getSprite().alpha < 1){
		bgWave.getSprite().alpha += 0.005;
	}
	supremefish.y = 185 + Math.sin(supremefishSineWave) * supremefishSineSize;
	supremefishSineWave += supremefishSineRate;
	if(supremefishSineWave >= 2 * Math.PI){
		supremefishSineWave = 0;
	}

	if(supremefish.currentAnimation == "ending_supremefish_power"){
		supremefish.advance();
		if(supremefish.currentFrame == supremefish.totalFrames){
			supremefish.currentAnimation = "ending_supremefish_idle";
		}
	}
	else if(supremefish.currentAnimation == "ending_supremefish_exit" && supremefish.currentFrame != supremefish.totalFrames){
		supremefish.advance();
	}
}

function onTeardown(){
	
}
