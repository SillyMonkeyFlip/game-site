var endingSprites:Array<String> = [
    "stages/satstat/ending/goodend",
    "stages/satstat/ending/badend"
];

var endingSpr:FunkinSprite;
var sawNoteMisses:Int = 0; // Создаем счетчик промахов специально для sawnote

// Отслеживаем промахи
function onPlayerMiss(e)
{
    // Если игрок промахнулся по sawnote, увеличиваем наш счетчик
    if(e.noteType == "sawnote")
    {
        sawNoteMisses++;
    }
}

function beatHit(curBeat:Int)
{
    switch(curBeat)
    {
        case 568:
            chooseEnding();
    }
}

function chooseEnding()
{
    endingSpr = new FunkinSprite();
    
    // Загружаем изображение, опираясь на наш новый счетчик sawNoteMisses
    endingSpr.loadGraphic(Paths.image(
        sawNoteMisses > 0
            ? endingSprites[1]
            : endingSprites[0]
    ));
    
    // Центрируем по середине экрана
    endingSpr.screenCenter();
    
    // Настройка камеры и скролла
    endingSpr.cameras = [camGame];
    endingSpr.scrollFactor.set();
    endingSpr.alpha = 0;
    
    // Если промахов по sawnote больше 0 - смещаем чуть выше
    if(sawNoteMisses > 0)
    {
        endingSpr.y -= 100;
    }
    
    add(endingSpr);
    
    // Масштабируем
    endingSpr.scale.set(0.8, 0.8);
    
    // Анимация появления
    FlxTween.tween(endingSpr, {alpha: 1}, 2, {
        ease: FlxEase.quadOut
    });
}