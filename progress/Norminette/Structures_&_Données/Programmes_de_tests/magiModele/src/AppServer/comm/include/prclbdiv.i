/*------------------------------------------------------------------------
File        : prclbdiv.i
Purpose     : Procedure pour lire ou mettre à jour des paramètres avec motcle=Valeur dans lbdiv 
Author(s)   : SY 25/02/2014  -  GGA 2017/11/13
Notes       : reprise comm\prclbdiv.i 
derniere revue  : 2018/04/10 - phm: OK
----------------------------------------------------------------------*/

function majParamLbdiv returns logical private(
    pcMotCle as character, pcSepValeur as character, pcSepParam as character, pcValParam as character, input-output pcLbdiv as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define variable vlMiseajour as logical   no-undo.
    define variable viPos       as integer   no-undo.
    define variable vcItem      as character no-undo.
    
    if not pcLbdiv matches substitute("*&1&2*", pcMotCle, pcSepValeur)
    then pcLbdiv = substitute("&1&2&3&4", pcLbdiv, if pcLbdiv > "" then pcSepParam else "", pcMotCle, pcSepValeur).
    do viPos = 1 to num-entries(pcLbdiv, pcSepParam):
        vcItem = entry(viPos, pcLbdiv, pcSepParam).
        if vcItem begins pcMotCle + pcSepValeur
        and entry(2, vcItem, pcSepValeur) <> pcValParam
        then assign
            entry(2, vcItem, pcSepValeur)     = pcValParam
            entry(viPos, pcLbdiv, pcSepParam) = vcItem
            vlMiseajour                       = true
        .
    end.
    return vlMiseajour.
end function.  
 
function getValeurParametre return character private (pcMotCle as character, pcSepValeur as character, pcSepParam as character, pcLbdiv as character):
    /*------------------------------------------------------------------------------
    Purpose: extrait la valeur pour un code situé dans une chaîne.
             ancienne procedure LecParamLbdiv
    Notes  : pcSepParam: sépare les différents "codes pcSepValeur valeur"
    ------------------------------------------------------------------------------*/
    define variable viPos  as integer   no-undo.
    define variable vcItem as character no-undo.

    do viPos = 1 to num-entries(pcLbdiv, pcSepParam):
        vcItem = entry(viPos, pcLbdiv, pcSepParam).
        if vcItem begins pcMotCle + pcSepValeur 
        then return entry(2 ,vcItem , pcSepValeur).
    end.

end function.
