/*-----------------------------------------------------------------------------
File        : isbaitva.i
Purpose     : Interface de chargement retournant si le bail est soumis à TVA.
Author(s)   : LG - 1998/09/23, Kantena - 2018/01/13
Notes       : vient de adb/src/cpta/isbaitva.p
              suppression du parametre cdsocUse-IN, pcCodeRetour, Transformation en Fonction
-----------------------------------------------------------------------------*/
function isbaitva returns character private(piNumeroBail as int64):
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    define buffer tache for tache.
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon = piNumeroBail
      , last tache no-lock
        where tache.tptac = {&TYPETACHE-TVABail}
          and tache.tpcon = ctrat.Tpcon
          and tache.nocon = ctrat.Nocon:
        return "0".
    end.
    return "1".
end function.
