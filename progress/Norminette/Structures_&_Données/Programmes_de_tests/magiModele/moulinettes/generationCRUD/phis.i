/*------------------------------------------------------------------------
File        : phis.i
Purpose     : Fichier indexation des ecritures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPhis
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field aa-cpt     as integer    initial ? 
    field aa-ech     as integer    initial ? 
    field aa-ecr     as integer    initial ? 
    field aff        as character  initial ? 
    field agio       as character  initial ? 
    field banque     as character  initial ? 
    field c_enreg    as character  initial ? 
    field c_enreg2   as character  initial ? 
    field c_etat     as character  initial ? 
    field cpt-cd     as character  initial ? 
    field cpt-ctp    as character  initial ? 
    field cpt-treso  as character  initial ? 
    field divers     as character  initial ? 
    field document   as character  initial ? 
    field gi-ttyid   as character  initial ? 
    field imputation as character  initial ? 
    field inst       as character  initial ? 
    field jj-ech     as integer    initial ? 
    field jj-ecr     as integer    initial ? 
    field lib        as character  initial ? 
    field match      as character  initial ? 
    field mm-cpt     as integer    initial ? 
    field mm-ech     as integer    initial ? 
    field mm-ecr     as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field nat        as character  initial ? 
    field no_encais  as character  initial ? 
    field no_mt      as character  initial ? 
    field reference  as character  initial ? 
    field regl-cd    as character  initial ? 
    field rep-cle    as character  initial ? 
    field rupt       as character  initial ? 
    field signe      as character  initial ? 
    field triage     as character  initial ? 
    field txcomm     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
