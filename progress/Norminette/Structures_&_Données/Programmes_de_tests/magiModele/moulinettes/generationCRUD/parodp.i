/*------------------------------------------------------------------------
File        : parodp.i
Purpose     : Fichier parametres O.D. de PAIE
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParodp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd    as integer    initial ? 
    field file-name  as character  initial ? 
    field floppy-cle as character  initial ? 
    field jou-cd     as character  initial ? 
    field pos-deb    as integer    initial ? 
    field pos-fin    as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field type-cle   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
