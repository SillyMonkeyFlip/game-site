import funkin.game.PlayState;

var guardianDuoX:Float;
var dipsyDuoX:Float;

var loopingIt:Bool = false;
var loop:Int = 0;
var dipsyOrigin:Float;

// Переменные для покачивания персонажа
var walkChar:Character;        // strumLines.members[1].characters[0]
var walkCharOrigY:Float;       // исходная Y-позиция

function postCreate()
{
    strumLines.members[1].characters[1].visible = false;
    strumLines.members[1].characters[2].visible = false;
    strumLines.members[1].characters[3].visible = false;
    strumLines.members[1].characters[4].visible = false;

    strumLines.members[0].characters[0].visible = false;
    strumLines.members[0].characters[1].visible = false;
    strumLines.members[0].characters[2].visible = false;
    strumLines.members[0].characters[3].visible = false;

    defaultDisplayRating = false;
    defaultDisplayCombo = false;
    minDigitDisplay = -1;

    // Сохраняем персонажа, который будет качаться (с самого начала видимый)
    walkChar = strumLines.members[1].characters[0];
    walkCharOrigY = walkChar.y;   // запоминаем его исходное положение

    //player.cpu = true;
}

function update(elapsed:Float)
{
    if (walkChar != null && walkChar.visible && curBeat >= 64 && curBeat < 136)
    {
        var beatTime:Float = Conductor.songPosition / (Conductor.stepCrochet * 4);
        var offset:Float = Math.sin(beatTime * Math.PI) * 12; // амплитуда 12
        walkChar.y = walkCharOrigY + offset;
    }
    else if (walkChar != null && !walkChar.visible)
    {
        walkChar.y = walkCharOrigY;
    }
}

function beatHit(_)
{
    switch(_)
    {
        case 135:
            strumLines.members[0].characters[0].visible = true;
        case 136:
            strumLines.members[1].characters[1].visible = true;
            strumLines.members[1].characters[0].visible = false;
        case 200:
            strumLines.members[0].characters[0].visible = false;
            strumLines.members[1].characters[1].visible = false;
            strumLines.members[1].characters[2].visible = true;
            strumLines.members[0].characters[1].visible = true;
            strumLines.members[1].characters[2].x -= 60;
            strumLines.members[0].characters[1].x += 60;
        case 264:
            strumLines.members[1].characters[2].visible = false;
            strumLines.members[0].characters[1].visible = false;
            strumLines.members[1].characters[3].visible = true;
            strumLines.members[0].characters[2].visible = true;
            strumLines.members[1].characters[3].x -= 375;
            strumLines.members[0].characters[2].x += 275;
            strumLines.members[0].characters[2].x += 65;
            strumLines.members[0].characters[2].y -= 150;
        case 328:
            strumLines.members[0].characters[0].visible = true;
            strumLines.members[1].characters[1].visible = true;
            strumLines.members[1].characters[3].visible = false;
            strumLines.members[0].characters[2].visible = false;
        case 359:
            strumLines.members[1].characters[3].x += 225;
            strumLines.members[0].characters[2].x -= 275;
            strumLines.members[0].characters[2].x += 65;
            strumLines.members[0].characters[2].y += 50;
            guardianDuoX = strumLines.members[1].characters[3].x;
            dipsyDuoX = strumLines.members[0].characters[2].x;
            strumLines.members[1].characters[3].x += 1200;
            strumLines.members[0].characters[2].x -= 1200;
        case 360:
            strumLines.members[0].characters[0].visible = false;
            strumLines.members[1].characters[1].visible = false;
            strumLines.members[1].characters[3].visible = true;
            strumLines.members[0].characters[2].visible = true;
            FlxTween.tween(strumLines.members[1].characters[3], {x: guardianDuoX}, 1, {ease: FlxEase.backOut});
            FlxTween.tween(strumLines.members[0].characters[2], {x: dipsyDuoX}, 1, {ease: FlxEase.backOut});
        case 392:
            strumLines.members[1].characters[3].visible = false;
            strumLines.members[0].characters[2].visible = false;
            strumLines.members[0].characters[3].visible = true;
            strumLines.members[0].characters[3].color = FlxColor.GREEN;
            strumLines.members[0].characters[3].scale.set(0.7,0.7);
            dipsyOrigin = strumLines.members[0].characters[3].x;
            loopingIt = true;
        case 456:
            loopingIt = false;
        case 464:
            strumLines.members[0].characters[3].x = dipsyOrigin;
            strumLines.members[0].characters[3].color = FlxColor.WHITE;
            strumLines.members[1].characters[4].visible = true;
            strumLines.members[0].characters[3].scale.set(0.4,0.4);
            strumLines.members[1].characters[4].x -= 345;
            strumLines.members[1].characters[4].y += 100;
            strumLines.members[0].characters[3].x += 275;
            strumLines.members[0].characters[3].x += 65;
            strumLines.members[0].characters[3].y -= 100;
        case 567:
            strumLines.members[0].characters[3].visible = false;
            strumLines.members[1].characters[4].visible = false;
    }

    if(loopingIt)
    {
        strumLines.members[0].characters[3].x += 275;

        loop += 1;

        if(loop >= 3)
        {
            loop = 0;
            strumLines.members[0].characters[3].x = dipsyOrigin;
        }
    }
}