/*------------------------------------------------------------------------
File        : DtDev.i
Purpose     : Chaine Travaux : Table Détail d'un Devis
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDtdev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle  as character  initial ? 
    field CdCsy  as character  initial ? 
    field CdMot  as character  initial ? 
    field CdMsy  as character  initial ? 
    field CdSta  as character  initial ? 
    field DlInt  as character  initial ? 
    field DtCsy  as date       initial ? 
    field Dtdeb  as date       initial ? 
    field Dtfin  as date       initial ? 
    field DtMsy  as date       initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field LbInt  as character  initial ? 
    field LbMot  as character  initial ? 
    field NoCpt  as integer    initial ? 
    field NoCttF as int64      initial ? 
    field NoDev  as integer    initial ? 
    field NoInt  as int64      initial ? 
    field NoRef  as integer    initial ? 
    field QtInt  as decimal    initial ?  decimals 3
    field TpCpt  as character  initial ? 
    field tpcttF as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
