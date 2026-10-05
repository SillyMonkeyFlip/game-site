var border:FlxSprite;
var barLeft:FlxSprite;
var barRight:FlxSprite;
var barTop:FlxSprite;
var barBottom:FlxSprite;

// Создаём отдельную камеру для рамки и полос
var borderCam:FlxCamera;

function create()
{
    // Размеры экрана
    var screenW:Int = FlxG.width;   // 1280
    var screenH:Int = FlxG.height;  // 720
    
    // Размеры для 4:3 (высота 720, ширина 960)
    var gameW:Int = 960;
    var gameH:Int = 720;
    var offsetX:Int = (screenW - gameW) / 2; // 160 пикселей черных полос по бокам
    
    // ---- СОЗДАЁМ КАМЕРУ ДЛЯ РАМКИ ----
    borderCam = new FlxCamera(0, 0, screenW, screenH);
    borderCam.bgColor = 0x00000000; // Прозрачный фон
    borderCam.scroll.x = 0;
    borderCam.scroll.y = 0;
    
    // Добавляем камеру в список камер (поверх всех остальных)
    FlxG.cameras.add(borderCam, false);
    
    // ---- СОЗДАЁМ ЧЁРНЫЕ ПОЛОСЫ ----
    
    // Левая полоса
    barLeft = new FlxSprite(0, 0);
    barLeft.makeGraphic(offsetX, screenH, 0xFF000000);
    barLeft.scrollFactor.set(0, 0);
    barLeft.cameras = [borderCam]; // Назначаем на новую камеру
    add(barLeft);
    
    // Правая полоса
    barRight = new FlxSprite(screenW - offsetX, 0);
    barRight.makeGraphic(offsetX, screenH, 0xFF000000);
    barRight.scrollFactor.set(0, 0);
    barRight.cameras = [borderCam]; // Назначаем на новую камеру
    add(barRight);
    
    // ---- СОЗДАЁМ ОБВОДКУ ВНУТРИ 4:3 ----
    
    border = new FlxSprite(offsetX, 0);
    border.loadGraphic(Paths.image("stages/satstat/obv"));
    
    if (border.graphic == null)
    {
        trace("❌ Картинка не найдена!");
        border.makeGraphic(gameW, gameH, 0xFFFF0000);
    }
    
    // Растягиваем под размер 4:3
    border.setGraphicSize(gameW, gameH);
    border.updateHitbox();
    border.scrollFactor.set(0, 0);
    border.cameras = [borderCam]; // Назначаем на новую камеру
    add(border);
}


