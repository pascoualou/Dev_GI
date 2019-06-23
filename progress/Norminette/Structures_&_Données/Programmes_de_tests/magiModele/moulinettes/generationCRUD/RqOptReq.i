/*------------------------------------------------------------------------
File        : RqOptReq.i
Purpose     : Contient les options possibles avec les valeurs respectives possible pour chaque option, la valeur par défaut et le libellé de l'option (= libellé de la colonne dans le browse correspondant), ce, pour les requetes, champs, et extractions
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRqoptreq
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdopt  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbopt  as character  initial ? 
    field tpopt  as character  initial ? 
    field vldef  as character  initial ? 
    field vlopt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
