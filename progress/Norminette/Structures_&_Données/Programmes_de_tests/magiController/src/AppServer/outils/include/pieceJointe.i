/*------------------------------------------------------------------------
File        : pieceJointe.i
Description : dataset pieceJointe
Author(s)   : kantena - 2016/09/13
Notes       :
derniere revue: 2018/05/23 - phm: OK
----------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPieceJointe 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroPiece as integer
    field nomFichier   as character
    field urlFichier   as character
    field iOrder       as integer
index idxOrder is primary unique iOrder
.
