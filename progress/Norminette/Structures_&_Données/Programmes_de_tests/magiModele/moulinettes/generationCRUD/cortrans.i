/*------------------------------------------------------------------------
File        : cortrans.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCortrans
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd      as character  initial ? 
    field ana2-cd      as character  initial ? 
    field ana3-cd      as character  initial ? 
    field ana4-cd      as character  initial ? 
    field cours        as decimal    initial ?  decimals 6
    field cpt-cd       as character  initial ? 
    field dacompta     as date       initial ? 
    field dadoss       as date       initial ? 
    field dev-cd       as character  initial ? 
    field doss-num     as integer    initial ? 
    field etab-cd      as integer    initial ? 
    field fg-compta    as logical    initial ? 
    field four-cle     as character  initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-dev       as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field mtprev       as decimal    initial ?  decimals 2
    field mtprev-dev   as decimal    initial ?  decimals 2
    field mtprev-EURO  as decimal    initial ?  decimals 2
    field piece-compta as integer    initial ? 
    field prest-cd     as integer    initial ? 
    field sel          as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field taxe-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
