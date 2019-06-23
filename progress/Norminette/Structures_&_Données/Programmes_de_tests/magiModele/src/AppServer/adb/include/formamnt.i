/*------------------------------------------------------------------------
File        : formamnt.i
Purpose     : Procedure de formatage montant (arrondi/tronqué)
Author(s)   : SY - 2004/09/24, Kantena 2018/01/03
Notes       : reprise de adb/comm/formamnt.i. PrcForMnt transformé de procedure en fonction
              utilise par calrevlo.p (quit et event)
------------------------------------------------------------------------*/

function PrcForMnt returns decimal(pcTypeTroncature as character, pcTypeArrondi as character, pdeMontant as decimal):
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    if integer(pcTypeTroncature) = 1
    then case integer(pcTypeArrondi):
        when 1 then pdeMontant = truncate(pdeMontant, 2).               /* TRONQUER AUX CENTIMES  */
        when 2 then pdeMontant = truncate(pdeMontant, 0).               /* TRONQUER A L'UNITE     */
        when 3 then pdeMontant = truncate(pdeMontant / 10, 0) * 10.     /* TRONQUER A LA DIXAINE  */
        when 4 then pdeMontant = truncate(pdeMontant / 100, 0) * 100.   /* TRONQUER A LA CENTAINE */
        when 5 then pdeMontant = truncate(pdeMontant / 1000, 0) * 1000. /* TRONQUER AUX MILLIERS  */
        otherwise   pdeMontant = truncate(pdeMontant, 2).               /* TRONQUER AUX CENTIMES  */
    end case.
    else case integer(pcTypeArrondi):
        when 1 then pdeMontant = round(pdeMontant, 2).                  /* ARRONDIR AUX CENTIMES  */
        when 2 then pdeMontant = round(pdeMontant, 0).                  /* ARRONDIR A L'UNITE     */
        when 3 then pdeMontant = round(pdeMontant / 10, 0) * 10.        /* ARRONDIR A LA DIXAINE  */
        when 4 then pdeMontant = round(pdeMontant / 100, 0) * 100.      /* ARRONDIR A LA CENTAINE */
        when 5 then pdeMontant = round(pdeMontant / 1000, 0) * 1000.    /* ARRONDIR AUX MILLIERS  */
        otherwise   pdeMontant = round(pdeMontant, 2).                  /* ARRONDIR AUX CENTIMES  */
    end case.
    return pdeMontant.
end function.
