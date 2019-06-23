/*------------------------------------------------------------------------
File        : ifdcptage.i
Purpose     : Paramétrage des comptes par agence dans la facturation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdcptage
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdage       as character  initial ? 
    field CdCle       as character  initial ? 
    field cpt-ht      as character  initial ? 
    field cpt-tva     as character  initial ? 
    field etab-cd     as integer    initial ? 
    field FgRgt       as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field soc-dest    as integer    initial ? 
    field taxe-cd     as integer    initial ? 
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
