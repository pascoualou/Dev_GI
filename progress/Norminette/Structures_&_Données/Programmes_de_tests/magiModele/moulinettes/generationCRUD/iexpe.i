/*------------------------------------------------------------------------
File        : iexpe.i
Purpose     : parametrage des expeditions
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIexpe
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field avecAR-cd  as character  initial ? 
    field colis-cd   as character  initial ? 
    field div1       as character  initial ? 
    field div2       as character  initial ? 
    field div3       as character  initial ? 
    field div4       as character  initial ? 
    field div5       as character  initial ? 
    field expe-cd    as character  initial ? 
    field facon-cd   as character  initial ? 
    field fg-avecAR  as logical    initial ? 
    field fg-colis   as logical    initial ? 
    field fg-collage as logical    initial ? 
    field fg-collee  as logical    initial ? 
    field fg-envtip  as logical    initial ? 
    field fg-misenv  as logical    initial ? 
    field fg-sansAR  as logical    initial ? 
    field fg-timbre  as logical    initial ? 
    field lib        as character  initial ? 
    field sansAR-cd  as character  initial ? 
    field serv-cd    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
