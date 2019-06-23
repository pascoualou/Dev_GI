/*------------------------------------------------------------------------
File        : detail.i
Purpose     : Table de détail des infos d'une paire "Code-Num".
Détail contrat avec Code contrat-Numéro contrat, ou d'un role avec code role-numéro role, etc....
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDetail
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy as character  initial ? 
    field cddet as character  initial ? 
    field cdmsy as character  initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field iddet as integer    initial ? 
    field ixd01 as character  initial ? 
    field ixd02 as character  initial ? 
    field ixd03 as character  initial ? 
    field nodet as int64      initial ? 
    field tbchr as character  initial ?             extent 50 
    field tbdat as date       initial ?             extent 50 
    field tbdec as decimal    initial ?  decimals 2 extent 50
    field tbint as int64      initial ?             extent 50 
    field tblog as logical    initial ?             extent 50
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
