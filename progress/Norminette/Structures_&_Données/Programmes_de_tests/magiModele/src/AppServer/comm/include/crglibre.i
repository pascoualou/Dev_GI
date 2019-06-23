/*------------------------------------------------------------------------
File        : crglibre.i 
Purpose     : Edition relevés propriétaires + simulation CRG 
Author(s)   : DM - 2010/12/14, Kantena - GGA 2018/01/11
Notes       : reprise comm/crglibre.i
derniere revue: 2018/05/28 - phm: KO
        supprimer le code en commentaire, car non utilisé.
----------------------------------------------------------------------*/

function f_crglibre returns logical(piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer tache for tache.
    
    find first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-compteRenduGestion} no-error.
    return (available tache and entry(1, tache.lbdiv, "#") = "00003").
    
end function. 
/*
function f_libnat returns character(pcTypepar as character, pcCodepar as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : pas utilisé
    ------------------------------------------------------------------------------*/
    define buffer aparm for aparm.

    find first aparm no-lock
        where aparm.tppar = pcTypepar
          and aparm.cdpar = pcCodepar no-error.
    return (if available aparm then aparm.lib else "?.?.?").

end function.

function f_corr returns character(pcTypepar as character, pcAnalytique1 as character, pcAnalytique2 as character, pcAnalytique3 as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : pas utilisé
    ------------------------------------------------------------------------------*/
    define variable vcCode as character no-undo.
    define buffer aparm for aparm.
    /* recherche avec le code fiscalité */
    vcCode = substitute("&2&1&3&1", "¤", pcAnalytique1, pcAnalytique2). 
    find first aparm no-lock
        where aparm.tppar = pcTypepar
          and aparm.cdpar = vcCode + pcAnalytique3 + "¤" no-error.
    /* recherche sans le code fiscalité */
    if not available aparm
    then find first aparm no-lock
        where aparm.tppar = pcTypepar
          and aparm.cdpar begins vcCode no-error.
    return if available aparm then aparm.lib /* code Nature/Sous-nature ex : G00¤G05 */
                               else if pcTypepar = "CARDN" 
                                    then "Z01" /* Nature Divers */
                                    else if pcTypepar = "CARDS"
                                         then " " /* Sous-Nature blanc */
                                         else "?¤?".
end function.
*/
