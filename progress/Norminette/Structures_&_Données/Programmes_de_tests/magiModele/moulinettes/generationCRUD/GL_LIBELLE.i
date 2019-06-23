/*------------------------------------------------------------------------
File        : GL_LIBELLE.i
Purpose     : Liste des libelles (listes déroulantes).
Tpidt :
-	1 : Attributs commerciaux
-	2 : Mode création
-	3 : Zone ALUR
-	4 : Workflow

Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_libelle
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy        as character  initial ? 
    field cdmsy        as character  initial ? 
    field dtcsy        as date       initial ? 
    field dtmsy        as date       initial ? 
    field hecsy        as integer    initial ? 
    field hemsy        as integer    initial ? 
    field libelleLibre as character  initial ? 
    field noidt        as integer    initial ? 
    field nolibelle    as integer    initial ? 
    field nomes        as integer    initial ? 
    field noordre      as integer    initial ? 
    field tpidt        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
