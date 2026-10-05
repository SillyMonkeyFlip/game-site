import funkin.menus.ModSwitchMenu;
import funkin.editors.EditorPicker;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;
import flixel.util.FlxTimer;
import flixel.text.FlxTextBorderStyle;

var introText:FlxText;
var canShowOptions:Bool = false;
var transitioning:Bool = false;

var cover:FunkinSprite;
var discNorm:FunkinSprite;
var doneTweenIn:Bool = false;
var canClick:Bool = false;

var creditsText:FlxText;
var optionsText:FlxText;

var menuSprGrp:Array<FunkinSprite> = [];
var menuTxtGrp:Array<FlxText> = [];

// Переменная для хранения таймера интро, чтобы его можно было отменить
var introTimer:FlxTimer;

function create()
{
    trace("dip");

    FlxG.sound.playMusic(Paths.music("ambience"));

    introText = new FlxText(0, 0, FlxG.width, "AstroDev and M13 Presents", 82);
    introText.font = Paths.font("LD Slender Regular.ttf");
    introText.alignment = "center";
    introText.screenCenter();
    introText.alpha = 0;
    introText.scale.set(0.8, 0.8);
    add(introText);

    makeMenu();

    FlxG.mouse.visible = true;

    FlxTween.tween(introText, {alpha: 1}, 1.5, {ease: FlxEase.cubeOut});
    FlxTween.tween(introText.scale, {x: 1, y: 1}, 4, {ease: FlxEase.expoOut});
    
    // Записываем таймер в переменную
    introTimer = new FlxTimer().start(2.5, function(tmr:FlxTimer)
    {
        FlxTween.tween(introText, {alpha: 0, y: introText.y - 50}, 1.5, {
            ease: FlxEase.backIn,
            onComplete: function(_)
            {
                canShowOptions = true;
            }
        });
    });
}

function update()
{
    // Пропускаем интро при нажатии на ENTER
    if(!canShowOptions && FlxG.keys.justPressed.ENTER)
    {
        if(introTimer != null) introTimer.cancel(); // Останавливаем таймер появления меню
        FlxTween.globalManager.cancelTweensOf(introText); // Сбрасываем активные твины текста
        FlxTween.globalManager.cancelTweensOf(introText.scale);
        
        introText.alpha = 0;
        introText.visible = false;
        canShowOptions = true; // Мгновенно разрешаем показ меню
    }

    if(FlxG.keys.justPressed.TAB)
    {
        openSubState(new ModSwitchMenu());
        persistentUpdate = !(persistentDraw = true);
    }

    if(FlxG.keys.justPressed.SEVEN)
    {
        openSubState(new EditorPicker());
        persistentUpdate = !(persistentDraw = true);
    }

    if(canShowOptions && !transitioning)
    {
        if(!doneTweenIn)
        {
            for(spr in menuSprGrp)
            {
                spr.y += 50;
                FlxTween.tween(spr, {alpha: 1, y: spr.y - 50}, 1.5, {ease: FlxEase.expoOut});
            }

            for(i in 0...menuTxtGrp.length)
            {
                var txt = menuTxtGrp[i];
                txt.x += 50;
                FlxTween.tween(txt, {alpha: 0.6, x: txt.x - 50}, 1.0, {
                    ease: FlxEase.expoOut, 
                    startDelay: 0.2 + (i * 0.1)
                });
            }

            doneTweenIn = true;
        }

        updateTextHover(creditsText);
        updateTextHover(optionsText);

        if(FlxG.mouse.overlaps(creditsText) && FlxG.mouse.justPressed)
            FlxG.switchState(new ModState("CustomCredits"));

        if(FlxG.mouse.overlaps(optionsText) && FlxG.mouse.justPressed)
            FlxG.switchState(new OptionsMenu());

        if(FlxG.mouse.overlaps(cover) && FlxG.mouse.justPressed && !canClick)
        {
            FlxTween.tween(cover, {x: cover.x - 600, angle: -45, alpha: 0}, 1.2, {
                ease: FlxEase.backIn, 
                onComplete: function(_) {
                    cover.visible = false;
                }
            });
            
            FlxTween.tween(discNorm, {x: discNorm.x + 200, angle: 360}, 1.5, {
                ease: FlxEase.elasticOut, 
                onComplete: function(_) {
                    canClick = true;
                }
            });
        }

        if(FlxG.mouse.overlaps(discNorm) && FlxG.mouse.justPressed && canClick)
        {
            transitioning = true;
            
            // Быстро скрываем текст меню
            for(txt in menuTxtGrp) FlxTween.tween(txt, {alpha: 0}, 0.4);
            
            // Эффектное увеличение пластинки во весь экран с закручиванием и исчезновением
            FlxTween.tween(discNorm.scale, {x: 5, y: 5}, 1.2, {ease: FlxEase.cubeIn});
            FlxTween.tween(discNorm, {angle: discNorm.angle + 1440, alpha: 0}, 1.2, {
                ease: FlxEase.cubeIn, 
                onComplete: function(_) {
                    // Переход срабатывает ровно в момент, когда пластинка заполнила экран и растворилась
                    FlxG.switchState(new ModState("preludeHard"));
                }
            });
        }
    }
}

function updateTextHover(txt:FlxText)
{
    if(FlxG.mouse.overlaps(txt))
    {
        txt.alpha = 1;
        txt.color = 0xFFFFFF00;
    }
    else
    {
        txt.alpha = 0.6;
        txt.color = 0xFFFFFFFF;
    }
}

function makeMenu()
{
    cover = new FunkinSprite(0, 0);
    cover.loadGraphic(Paths.image("menu/cover"));
    cover.scale.set(0.5, 0.5);
    cover.updateHitbox();
    
    cover.x = 200; 
    cover.y = (FlxG.height - cover.height) / 2;
    
    discNorm = new FunkinSprite(0, 0);
    discNorm.loadGraphic(Paths.image("menu/disc_norm"));
    discNorm.scale.set(0.5, 0.5);
    discNorm.updateHitbox();
    
    discNorm.x = cover.x + (cover.width - discNorm.width) / 2;
    discNorm.y = cover.y + (cover.height - discNorm.height) / 2;
    
    add(discNorm);
    add(cover);

    creditsText = new FlxText(750, 300, 0, "Credits", 64);
    creditsText.font = Paths.font("LD Slender Regular.ttf");
    creditsText.borderStyle = FlxTextBorderStyle.OUTLINE;
    creditsText.borderColor = 0xFF000000;
    creditsText.borderSize = 4;
    add(creditsText);

    optionsText = new FlxText(750, 400, 0, "Options", 64);
    optionsText.font = Paths.font("LD Slender Regular.ttf");
    optionsText.borderStyle = FlxTextBorderStyle.OUTLINE;
    optionsText.borderColor = 0xFF000000;
    optionsText.borderSize = 4;
    add(optionsText);

    creditsText.alpha = 0;
    optionsText.alpha = 0;
    discNorm.alpha = 0;
    cover.alpha = 0;

    menuSprGrp.push(discNorm);
    menuSprGrp.push(cover);
    menuTxtGrp.push(creditsText);
    menuTxtGrp.push(optionsText);
}