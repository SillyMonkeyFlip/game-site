var bgParts:Array<FlxSprite> = [];
var lion:Array<FlxSprite> = [];

var started:Bool = false;

var upsSprites:Array<FlxSprite> = [];
var upsGroup:FlxTypedGroup<FlxSprite>;
var greenActive:Bool = false;

var availableUps:Array<FlxSprite> = [];
var shownUps:Array<FlxSprite> = [];
var allUpsShown:Bool = false;

var bgLake:FlxSprite;

function postCreate()
{
    bgParts.push(walkbg);
    bgParts.push(bg1);
    bgParts.push(bgbridge);
    bgParts.push(bgbridge2);
    bgParts.push(green);

    for(spr in bgParts)
    {
        spr.alpha = 0;
    }

    bgParts[0].alpha = 1;
    bgParts[0].y -= 400;

    bgParts[1].y -= 200;
    bgParts[1].x -= 200;

    bgParts[2].y -= 200;
    bgParts[2].x -= 200;

    bgParts[3].y -= 200;
    bgParts[3].x -= 200;

    bgParts[4].y -= 200;
    bgParts[4].x -= 200;

    bgLake = new FlxSprite(0, 0);
    bgLake.loadGraphic(Paths.image('stages/satstat/bg_lake'));
    bgLake.scale.set(0.6, 0.6);
    bgLake.updateHitbox();
    bgLake.alpha = 0;
    bgLake.y -= 50;
    bgLake.x += 200; 
    
    insert(0, bgLake);

    lion.push(sl1);
    lion.push(sl2);
    lion.push(sl3);
    lion.push(sl4);

    for(spr in lion)
    {
        spr.alpha = 0;
        spr.y -= 200;
        spr.x -= 200;
    }

    upsGroup = new FlxTypedGroup<FlxSprite>();
    add(upsGroup);

    var upsNames:Array<String> = ["p1","p2","p3","p4","p5","p6"];
    for (name in upsNames)
    {
        var spr = new FlxSprite(0, 0);
        spr.loadGraphic(Paths.image('stages/satstat/ups/' + name));
        spr.alpha = 0;
        spr.x = (FlxG.width - 800) - 190;
        spr.y = (FlxG.height - 600) - 110;
        upsGroup.add(spr);
        upsSprites.push(spr);
    }

    var greenIdx = members.indexOf(bgParts[4]);
    if (greenIdx != -1)
    {
        remove(upsGroup);
        insert(greenIdx + 1, upsGroup);
    }

    resetUpsCycle();
}

function resetUpsCycle()
{
    availableUps = [];
    shownUps = [];
    
    for (spr in upsSprites)
    {
        availableUps.push(spr);
    }
    
    allUpsShown = false;
    hideAllUps();
}

function showNextRandomUps()
{
    if (upsSprites.length == 0) return;
    
    if (availableUps.length == 0)
    {
        resetUpsCycle();
        showNextRandomUps();
        return;
    }
    
    hideAllUps();
    
    var randIndex = FlxG.random.int(0, availableUps.length - 1);
    var selected = availableUps[randIndex];
    
    availableUps.remove(selected);
    shownUps.push(selected);
    
    selected.alpha = 1;
    
    trace('Показана картинка: ' + selected + ' (осталось: ' + availableUps.length + ')');
}

function hideAllUps()
{
    for (spr in upsSprites)
    {
        spr.alpha = 0;
    }
}

function forceResetUps()
{
    resetUpsCycle();
}

function beatHit(_)
{
    switch(_)
    {
        case 64:
            started = true;
            
        case 135:
            started = false;
            
        case 136:
            bgParts[0].alpha = 0;
            bgParts[1].alpha = 1;
            
        case 200:
            bgParts[1].alpha = 0;
            bgParts[2].alpha = 1;
            
        case 264:
            bgParts[2].alpha = 0;
            bgParts[3].alpha = 1;
            
        case 328:
            bgParts[1].alpha = 1;
            bgParts[3].alpha = 0;
            
        case 360:
            bgParts[1].alpha = 0;
            bgParts[2].alpha = 0;
            bgLake.alpha = 1;
            
        case 392:
            bgLake.alpha = 0;
            bgParts[2].alpha = 0;
            bgParts[4].alpha = 1;
            greenActive = true;
            resetUpsCycle();
            showNextRandomUps();
            
        case 456:
            lion[0].alpha = 1;
            
        case 459:
            lion[1].alpha = 1;
            
        case 460:
            lion[2].alpha = 1;
            
        case 461:
            lion[3].alpha = 1;
            
        case 464:
            for(spr in lion)
            {
                spr.alpha = 0;
            }
            bgParts[4].alpha = 0;
            bgParts[3].alpha = 1;
            greenActive = false;
            hideAllUps();
            
        case 567:
            for(spr in bgParts)
            {
                spr.alpha = 0;
            }
            bgLake.alpha = 0;
            greenActive = false;
            hideAllUps();
    }

    if (greenActive)
    {
        showNextRandomUps();
    }
}

function update(elapsed:Float)
{
    if (curBeat > 64)
    {
        bgParts[0].x += 0.1;
    }
}

function debugUps()
{
    
}