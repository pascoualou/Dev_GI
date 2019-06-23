/*------------------------------------------------------------------------
File        : GL_C_SITEWEB.i
Purpose     : Table de correspondance données GI / site web annonce. Exemple : pour le type de lot "Chambre de bonne", Seloger attend "Appartement".
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_c_siteweb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy            as character  initial ? 
    field cdmsy            as character  initial ? 
    field chp_export       as character  initial ? 
    field correspondance   as character  initial ? 
    field dtcsy            as date       initial ? 
    field dtmsy            as date       initial ? 
    field hecsy            as integer    initial ? 
    field hemsy            as integer    initial ? 
    field nocorrespondance as integer    initial ? 
    field nositeweb        as integer    initial ? 
    field tpidt            as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
