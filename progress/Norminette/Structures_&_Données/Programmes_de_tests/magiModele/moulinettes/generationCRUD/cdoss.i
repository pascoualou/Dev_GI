/*------------------------------------------------------------------------
File        : cdoss.i
Purpose     : Fichier dossier
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCdoss
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd     as character  initial ? 
    field ana2-cd     as character  initial ? 
    field ana3-cd     as character  initial ? 
    field ana4-cd     as character  initial ? 
    field coll-cle    as character  initial ? 
    field cpt-cd      as character  initial ? 
    field daclo       as date       initial ? 
    field dacre       as date       initial ? 
    field etab-cd     as integer    initial ? 
    field lib         as character  initial ? 
    field mtprev      as decimal    initial ?  decimals 2
    field mtprev-EURO as decimal    initial ?  decimals 2
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
