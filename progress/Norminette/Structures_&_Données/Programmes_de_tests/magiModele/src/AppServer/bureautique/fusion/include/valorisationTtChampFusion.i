/*------------------------------------------------------------------------
File        : valorisationTtChampFusion.i
Description : Valorisation d'un champs de fusion
Author(s)   : RF - 2008/04/18, kantena - 2018/01/15
Notes       : issu de cretbchp.i, appelé par extract.p
08  25/01/2016  PL    0711/0069: Normalisation adresses sur 6 lignes 
----------------------------------------------------------------------*/

define temp-table ttChampFusion no-undo
    field cLibelle as character
    field cValeur as character
    field iNumeroMessage as integer
    index primaire is unique primary iNumeroMessage.

procedure valoriseChampFusion private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMessage as integer   no-undo.
    define input parameter pcLibelle as character no-undo.
    define input parameter pcValeur  as character no-undo.

    find first ttChampFusion
        where ttChampFusion.iNumeroMessage = piNumeroMessage no-error.
    if not available ttChampFusion
    then do:
        create ttChampFusion.
        ttChampFusion.iNumeroMessage = piNumeroMessage.
    end.
    assign
        ttChampFusion.cLibelle = pcLibelle 
        ttChampFusion.cValeur  = pcValeur
    .
end procedure.
