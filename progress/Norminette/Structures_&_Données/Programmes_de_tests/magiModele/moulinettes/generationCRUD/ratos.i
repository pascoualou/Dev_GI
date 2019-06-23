/*------------------------------------------------------------------------
File        : ratos.i
Purpose     : Chaine Travaux : Table de rattachement des Ordres de Service
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRatos
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdenr  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nocon  as integer    initial ? 
    field NoCttF as int64      initial ? 
    field NoFou  as integer    initial ? 
    field NoOrd  as integer    initial ? 
    field norat  as integer    initial ? 
    field tpcon  as character  initial ? 
    field tpcttF as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
