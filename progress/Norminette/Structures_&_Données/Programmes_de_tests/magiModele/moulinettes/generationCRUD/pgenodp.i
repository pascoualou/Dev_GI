/*------------------------------------------------------------------------
File        : pgenodp.i
Purpose     : Fichier de generation des O.D  de Paie
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPgenodp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd    as character  initial ? 
    field ana2-cd    as character  initial ? 
    field ana3-cd    as character  initial ? 
    field ana4-cd    as character  initial ? 
    field analytique as logical    initial ? 
    field cpt-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field lib        as character  initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
