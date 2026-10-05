import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;

var creditsData:Array<Dynamic> = [
    {
        name: "Smazone aka M13", 
        desc: "Remade coding, sprites, chart, icons", 
        url: "https://www.youtube.com/@astronomicaldeveloper"
    },
    {
        name: "AstroDev", 
        desc: "Did all the coding and sprite work and the chart", 
        url: "https://www.youtube.com/@astronomicaldeveloper"
    },
    {
        name: "Redus", 
        desc: "Made the icons, chainsaw notes, ending screens and main menu assets", 
        url: "https://www.youtube.com/@redustheimpo"
    },
    {
        name: "SancoTheFox", 
        desc: "Made The Lions Mouth", 
        url: "https://www.youtube.com/@sancothefox2816"
    }
];

var grpNames:FlxTypedGroup<FlxText>;
var descText:FlxText;
var titleText:FlxText;
var hintText:FlxText;

var curSelected:Int = 0;
var canInteract:Bool = false;

function create()
{
    if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        FlxG.sound.playMusic(Paths.music("ambience"));

    // Включаем видимость мышки
    FlxG.mouse.visible = true;

    titleText = new FlxText(0, 40, FlxG.width, "The Lions Mouth Credits", 64);
    titleText.alignment = "center";
    titleText.font = Paths.font("LD Slender Regular.ttf");
    titleText.borderStyle = FlxTextBorderStyle.OUTLINE;
    titleText.borderColor = 0xFF000000;
    titleText.borderSize = 4;
    titleText.color = 0xFFFFD700;
    add(titleText);

    grpNames = new FlxTypedGroup();
    add(grpNames);

    for (i in 0...creditsData.length)
    {
        var nameTxt = new FlxText(0, 200 + (i * 100), FlxG.width, creditsData[i].name, 54);
        nameTxt.alignment = "center";
        nameTxt.font = Paths.font("LD Slender Regular.ttf");
        nameTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
        nameTxt.borderColor = 0xFF000000;
        nameTxt.borderSize = 4;
        nameTxt.ID = i;
        grpNames.add(nameTxt);
    }

    descText = new FlxText(50, FlxG.height - 120, FlxG.width - 100, "", 36);
    descText.alignment = "center";
    descText.font = Paths.font("LD Slender Regular.ttf");
    descText.borderStyle = FlxTextBorderStyle.OUTLINE;
    descText.borderColor = 0xFF000000;
    descText.borderSize = 3;
    add(descText);

    hintText = new FlxText(5, FlxG.height - 30, FlxG.width, "Click / ENTER to open YouTube | Right-Click / Click Hint / ESC to go back", 20);
    hintText.alignment = "center";
    hintText.font = Paths.font("LD Slender Regular.ttf");
    add(hintText);

    for (i in 0...grpNames.members.length)
    {
        var item = grpNames.members[i];
        item.x -= 800;
        FlxTween.tween(item, {x: 0}, 1, {ease: FlxEase.expoOut, startDelay: i * 0.1});
    }

    FlxTween.tween(titleText, {y: titleText.y + 10}, 1, {
        ease: FlxEase.expoOut, 
        onComplete: function(_) {
            canInteract = true;
            changeSelection(0, true);
        }
    });
}

function update(elapsed:Float)
{
    if (!canInteract) return;

    // Логика мышки: наведение и клик по пунктам меню
    for (item in grpNames.members)
    {
        if (FlxG.mouse.overlaps(item))
        {
            if (curSelected != item.ID)
            {
                changeSelection(item.ID, true);
            }
            
            if (FlxG.mouse.justPressed)
            {
                FlxG.openURL(creditsData[curSelected].url);
            }
        }
    }

    // Управление с клавиатуры
    if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
        changeSelection(-1, false);
    
    if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
        changeSelection(1, false);

    if (FlxG.keys.justPressed.ENTER)
    {
        FlxG.openURL(creditsData[curSelected].url);
    }

    // Выход из меню (Клавиатура ESC/BACKSPACE или Правый клик мыши или клик по подсказке)
    if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE || FlxG.mouse.justPressedRight || (FlxG.mouse.overlaps(hintText) && FlxG.mouse.justPressed))
    {
        exitMenu();
    }
}

function changeSelection(change:Int, absolute:Bool = false)
{
    FlxG.sound.play(Paths.sound('scrollMenu'));

    if (absolute)
        curSelected = change;
    else
        curSelected += change;

    if (curSelected < 0)
        curSelected = creditsData.length - 1;
    if (curSelected >= creditsData.length)
        curSelected = 0;

    descText.alpha = 0;
    descText.text = creditsData[curSelected].desc;
    descText.y = FlxG.height - 100;
    FlxTween.tween(descText, {alpha: 1, y: FlxG.height - 120}, 0.3, {ease: FlxEase.cubeOut});

    for (item in grpNames.members)
    {
        if (item.ID == curSelected)
        {
            item.alpha = 1;
            item.color = 0xFFFFFF00;
            FlxTween.tween(item.scale, {x: 1.2, y: 1.2}, 0.2, {ease: FlxEase.backOut});
        }
        else
        {
            item.alpha = 0.5;
            item.color = 0xFFFFFFFF;
            FlxTween.tween(item.scale, {x: 1.0, y: 1.0}, 0.2, {ease: FlxEase.cubeOut});
        }
    }
}

function exitMenu()
{
    canInteract = false;
    FlxG.mouse.visible = false; // Прячем мышку при выходе
    FlxG.sound.play(Paths.sound('cancelMenu'));
    
    for (item in grpNames.members) {
        FlxTween.tween(item, {x: 800, alpha: 0}, 0.5, {ease: FlxEase.backIn});
    }
    FlxTween.tween(descText, {alpha: 0}, 0.5);
    FlxTween.tween(titleText, {y: -100, alpha: 0}, 0.5, {
        ease: FlxEase.backIn, 
        onComplete: function(_) {
            FlxG.switchState(new ModState("tlmMenu"));
        }
    });
}