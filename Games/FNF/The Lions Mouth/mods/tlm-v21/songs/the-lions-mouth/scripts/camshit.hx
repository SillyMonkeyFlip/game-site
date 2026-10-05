var swaying:Bool = false;
var swayDir:Int = 1;

var gameTween:FlxTween;
var hudTween:FlxTween;

function postCreate()
{
    camGame.alpha = 0;
    camHUD.alpha = 0;
}

function beatHit(_)
{
    switch(_)
    {
        case 63:
            FlxTween.tween(camGame, {alpha: 1}, 0.5);
            FlxTween.tween(camHUD, {alpha: 1}, 0.5);

        // case 128: — удалено, HUD больше не гаснет

        case 360:
            swaying = true;
            swayDir = 1;
            swayCam();

        case 388:
            stopSway();

        // case 392: — удалено, HUD не скрывается

        case 422:
            camGame.alpha = 0;

        case 424:
            camGame.alpha = 1;

        case 532:
            FlxTween.tween(camGame, {alpha: 0}, 1);

        // case 564: — удалено, HUD не гаснет

        case 567:
            FlxTween.tween(camGame, {alpha: 1}, 1);

        case 580:
            FlxTween.tween(camGame, {alpha: 0}, 1);
    }
}

// stepHit теперь пуст, потому что все управление alpha для HUD удалено
function stepHit(_)
{
    // Ничего не делаем
}

function swayCam()
{
    if (!swaying) return;

    gameTween = FlxTween.tween(camGame, {angle: 3 * swayDir}, 1, {
        ease: FlxEase.sineInOut
    });

    hudTween = FlxTween.tween(camHUD, {angle: 3 * swayDir}, 1, {
        ease: FlxEase.sineInOut,
        onComplete: function(_)
        {
            if (!swaying) return;
            swayDir *= -1;
            swayCam();
        }
    });
}

function stopSway()
{
    swaying = false;

    if (gameTween != null)
        gameTween.cancel();

    if (hudTween != null)
        hudTween.cancel();

    FlxTween.tween(camGame, {angle: 0}, 0.25, {ease: FlxEase.quadOut});
    FlxTween.tween(camHUD, {angle: 0}, 0.25, {ease: FlxEase.quadOut});
}