/*------------------------------------------------------------------------
File        : datean2.i
Description : Retourne la date de fin d'exercice s'il est cloturé
Author(s)   : GGA - 2018/08/10  
Notes       : reprise comm/datean2.i
  ----------------------------------------------------------------------*/
  
function f_daFinClot returns date private (piNumeroSociete as integer, piNumeroMandat as integer, pdaDate as date):
    /*------------------------------------------------------------------------------
    Purpose: Retourne la date de fin d'exercice s'il est cloturé
    Notes: 
    ------------------------------------------------------------------------------*/
    define buffer iprd   for iprd.
    define buffer vbiprd for iprd.
    define buffer ietab  for ietab.

    for first ietab no-lock
        where ietab.soc-cd  = piNumeroSociete
          and ietab.etab-cd = piNumeroMandat
      , first iprd no-lock
        where iprd.soc-cd    = piNumeroSociete
          and iprd.etab-cd   = piNumeroMandat
          and iprd.dadebprd <= pdaDate
          and iprd.dafinprd >= pdaDate
      , last vbiprd no-lock
        where vbiprd.soc-cd  = piNumeroSociete
          and vbiprd.etab-cd = piNumeroMandat
          and vbiprd.prd-cd  = iprd.prd-cd:
        if vbiprd.dafinprd <= (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1) - 1 then return vbiprd.dafinprd.
    end.
    return ?.

end function.
