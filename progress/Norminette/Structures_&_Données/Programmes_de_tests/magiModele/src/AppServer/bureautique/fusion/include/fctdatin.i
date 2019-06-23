/*-----------------------------------------------------------------------------
File        : fctdatin.i
Purpose     :
Author(s)   : KANTENA - 2018/10/24
Notes       :
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
    if pi > 0
    then return date(integer(pi modulo 10000 / 100), pi modulo 100, integer(pi / 10000)).
    return ?.
end function.
