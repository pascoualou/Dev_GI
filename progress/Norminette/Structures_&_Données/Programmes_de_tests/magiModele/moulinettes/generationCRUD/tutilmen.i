/*------------------------------------------------------------------------
File        : tutilmen.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTutilmen
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdapp      as character  initial ? 
    field ident      as integer    initial ? 
    field ident_pere as integer    initial ? 
    field lbpth      as character  initial ? 
    field lbrun      as character  initial ? 
    field libelle    as character  initial ? 
    field mtcle      as character  initial ? 
    field nomen      as integer    initial ? 
    field nomes      as integer    initial ? 
    field noord      as integer    initial ? 
    field num-ordre  as integer    initial ? 
    field profil_u   as character  initial ? 
    field rang       as integer    initial ? 
    field tpecr      as character  initial ? 
    field tprun      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
