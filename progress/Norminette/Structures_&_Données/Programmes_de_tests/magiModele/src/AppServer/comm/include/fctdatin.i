/*-----------------------------------------------------------------------------
File        : fctdatin.i
Purpose     :
Author(s)   : KANTENA - 2018/10/24
Notes       :
derniere revue: 2018/08/17 - phm: OK
-----------------------------------------------------------------------------*/

function date2Integer return integer(pda as date):
    /*-------------------------------------------------------------------------*
    Purpose: Fonction de conversion Date -> Integer
    Notes :
    *-------------------------------------------------------------------------*/
    if pda = ? then return 0.
    return year(pda) * 10000 + month(pda) * 100 + day(pda).
end function.

function integer2Date return date(pi as integer):
    /*-------------------------------------------------------------------------*
    Purpose: Fonction de conversion Integer -> Date
    Notes : Pas la peine d'utiliser truncate, car mois < 50 et jour < 50!
    *-------------------------------------------------------------------------*/
    define variable vdaDate as date no-undo.
    if pi > 0 then do:
        vdaDate = date(integer(pi modulo 10000 / 100), pi modulo 100, integer(pi / 10000)) no-error.
        if error-status:error then do: error-status:error = false. return ?. end.
        return vdaDate.
    end.
    return ?.
end function.
