/*------------------------------------------------------------------------
File        : GL_C_EXPORTWEB.i
Purpose     : Dictionnaire entrée / sortie entre les sites web d'annonce et l'outil
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_c_exportweb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy                 as character  initial ? 
    field cdmsy                 as character  initial ? 
    field chp_export            as character  initial ? 
    field chp_type              as character  initial ? 
    field correspondance        as character  initial ? 
    field correspondance_filtre as character  initial ? 
    field correspondance_type   as character  initial ? 
    field dtcsy                 as date       initial ? 
    field dtmsy                 as date       initial ? 
    field fgisnullable          as logical    initial ? 
    field hecsy                 as integer    initial ? 
    field hemsy                 as integer    initial ? 
    field nocorrespondance      as integer    initial ? 
    field nositeweb             as integer    initial ? 
    field ordre                 as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
