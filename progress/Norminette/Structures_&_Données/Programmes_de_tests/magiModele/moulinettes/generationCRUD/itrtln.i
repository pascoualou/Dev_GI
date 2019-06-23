/*------------------------------------------------------------------------
File        : itrtln.i
Purpose     : parametrage des etats par traitement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItrtln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field arch       as character  initial ? 
    field choix      as character  initial ? 
    field div1       as character  initial ? 
    field div2       as character  initial ? 
    field div3       as character  initial ? 
    field div4       as character  initial ? 
    field div5       as character  initial ? 
    field divers     as character  initial ? 
    field edit-cd    as character  initial ? 
    field etat-cd    as integer    initial ? 
    field expe-cd    as character  initial ? 
    field fdpage     as character  initial ? 
    field fg-oblig   as logical    initial ? 
    field lib        as integer    initial ? 
    field logo       as character  initial ? 
    field nbex       as integer    initial ? 
    field nobac      as character  initial ? 
    field preimp     as character  initial ? 
    field rectoverso as character  initial ? 
    field soc-cd     as integer    initial ? 
    field trt-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
