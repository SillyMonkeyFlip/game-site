import flixel.text.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG; // Не забудь убедиться, что FlxG импортирован
import flixel.util.FlxTimer;

var epicText:FlxText;
var np:FlxText;
var page:Int = 0;
var pageDeets:Array<String> = ["data/preludeinfo/prelude.txt","data/preludeinfo/sawnotes.txt"];
var mechSpr:FunkinSprite;
var isTransitioning:Bool = false; // Блокировка ввода во время анимации

function create()
{
    // Включаем видимость курсора мыши, чтобы игрок понимал, куда кликает
    FlxG.mouse.visible = true;

    // Фон или затемнение для атмосферы
    var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    bg.alpha = 0.6;
    add(bg);

    epicText = new FlxText(50, 100, FlxG.width - 100, "", 28);
    epicText.font = Paths.font("LD Slender Regular.ttf");
    epicText.borderStyle = FlxTextBorderStyle.OUTLINE;
    epicText.borderSize = 2;
    add(epicText);

    mechSpr = new FunkinSprite(FlxG.width - 400, 200);
    mechSpr.loadGraphic(Paths.image("game/notes/sawnote"));
    mechSpr.alpha = 0;
    add(mechSpr);

    np = new FlxText(0, FlxG.height - 80, FlxG.width, "A - PREV | D - NEXT", 32);
    np.alignment = "center";
    np.font = Paths.font("LD Slender Regular.ttf");
    np.color = 0xFFFFFFFF;
    add(np);

    loadPage(0, true);
}

function update(elapsed:Float)
{
    if (isTransitioning) return;

    // Объединяем проверки для клавиатуры и мыши
    var pressNext:Bool = FlxG.keys.justPressed.D;
    var pressPrev:Bool = FlxG.keys.justPressed.A;

    // Проверяем клик мышью по зоне текста (нижние 80 пикселей экрана)
    if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(np))
    {
        // Если кликнули правее центра экрана — это NEXT, если левее — PREV
        if (FlxG.mouse.x >= FlxG.width / 2) {
            pressNext = true;
        } else {
            pressPrev = true;
        }
    }

    if (pressNext)
    {
        if (page < pageDeets.length) {
            page++;
            loadPage(page, false);
        }
    }

    if (pressPrev)
    {
        if (page > 0) {
            page--;
            loadPage(page, false);
        }
    }
}

function loadPage(p:Int, isInitial:Bool)
{
    isTransitioning = true;
    
    // Анимация ухода старого текста
    FlxTween.tween(epicText, {alpha: 0, x: -50}, 0.3, {ease: FlxEase.cubeIn});

    // Логика переключения
    new FlxTimer().start(0.3, function(tmr) {
        if(p < pageDeets.length) {
            epicText.text = Assets.getText(Paths.file(pageDeets[p]));
            
            // Анимация появления нового текста
            epicText.x = 100;
            FlxTween.tween(epicText, {alpha: 1, x: 50}, 0.4, {ease: FlxEase.cubeOut});

            // Эффект картинки
            if(p == 1) {
                mechSpr.alpha = 0;
                FlxTween.tween(mechSpr, {alpha: 1, y: 220}, 0.5, {ease: FlxEase.backOut});
            } else {
                FlxTween.tween(mechSpr, {alpha: 0, y: 200}, 0.3);
            }
            isTransitioning = false;
        } 
        else {
            // Переход к песне
            FlxG.sound.play(Paths.sound('confirmMenu'));
            PlayState.loadSong("the-lions-mouth", "hard", false, false);
            FlxG.switchState(new PlayState());
        }
    });

    // Подсветка кнопок (желтый цвет при нажатии)
    np.color = 0xFFFFD700;
    FlxTween.color(np, 0.3, 0xFFFFD700, 0xFFFFFFFF);
}