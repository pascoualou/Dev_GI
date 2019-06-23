/*------------------------------------------------------------------------
File        : itrifou.i
Purpose     : 0608/0001 : Fournisseurs prioritaires (ex specif 205)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItrifou
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddomai  as character  initial ? 
    field cdsec    as character  initial ? 
    field etab-cd  as integer    initial ? 
    field four-cle as character  initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field ord-num  as integer    initial ? 
    field soc-cd   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
