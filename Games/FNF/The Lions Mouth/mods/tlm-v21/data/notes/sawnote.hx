var damageAmount:Float = 0.1; // Урон при попадании
var missDamageAmount:Float = 0.3; // Увеличенный урон при промахе (намного больше)

/*
function onNoteCreation(e)
{
    if(e.noteType == "sawnote")
    {
        e.noteSprite = "game/notes/types/saw_note"
    }
}
*/

function onPlayerHit(e)
{
    if(e.noteType == "sawnote")
    {
        health -= damageAmount;
    }
}

function onPlayerMiss(e)
{
    if(e.noteType == "sawnote")
    {
        // Отменяем стандартный промах и удаляем ноту
        e.cancel(true);
        e.note.strumLine.deleteNote(e.note);
        
        // 1. Тряска экрана (интенсивность 0.005, длительность 0.2 сек)
        FlxG.camera.shake(0.05, 0.2);
        
        // 2. Вспышка красным цветом (0xFFFF0000 - код красного, длительность 0.3 сек)
        FlxG.camera.flash(0xFFFF0000, 0.3);
        
        // 3. Наносим сильный урон
        health -= missDamageAmount;
    }
}