/*------------------------------------------------------------------------
File        : itypemvt.i
Purpose     : Type de mouvement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItypemvt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field auto       as logical    initial ? 
    field etab-cd    as integer    initial ? 
    field laffair    as logical    initial ? 
    field lbarre     as logical    initial ? 
    field lbonapaye  as logical    initial ? 
    field lconsol    as logical    initial ? 
    field lcpt       as logical    initial ? 
    field ldalivr    as logical    initial ? 
    field ldossier   as logical    initial ? 
    field lib        as character  initial ? 
    field libope-cd  as character  initial ? 
    field lregl      as logical    initial ? 
    field lsscoll    as logical    initial ? 
    field natjou-cd  as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field type-cle   as character  initial ? 
    field typenat-cd as integer    initial ? 
    field vir        as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
