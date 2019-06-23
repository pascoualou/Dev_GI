/*------------------------------------------------------------------------
File        : extdppre.i
Purpose     : description table temporaire cree dans le programme d'extraction extdppre.p et utilise 
              ensuite pour extraction pdf, excel ou impression
Author(s)   : GGA 2018/01/26
Notes       : au moment de la reprise adb/ext/extdppre.p
------------------------------------------------------------------------*/

define temp-table ttExport no-undo 
    field cCle         as character format "x(2)"
    field cRubCd       as character format "x(3)"
    field cSsRubCd     as character format "x(3)"
    field cFisc        as character format "x(1)"
    field iPieceCompta as integer
    field iNoExo       as integer
    field cNoDoc       as character
    field cFourn       as character
    field cLbCle       as character
    field cLbRub       as character
    field iNoLot       as integer
    field lLoc         as logical
    field cTri         as character
    field daEcr        as date
    field cJouCd       as character
    field cLibEcr      as character extent 20
    field dMtTva       as decimal   format "->>>,>>>,>>9.99"
    field dMt          as decimal   format "->>>,>>>,>>9.99"
    field cRegrpDep    as character format "x(5)"
    field iLig         as integer
    field iPos         as integer
    field iNoMdt       as integer
    field daFin        as date
    field iAffairNum   as integer
    field dTxProrata   as decimal 
    field rRowAna      as rowid 
 //   index ana-tri tri
 //   index ana-i   nomdt cle rub-cd ssrub-cd datecr jou-cd piece-compta fisc regrp-dep lig pos
.

define temp-table ttImpression no-undo
    field cClass as character format "X(250)"
    field cRefer as character format "X(250)"
    field cLigne as character format "X(500)"
.
