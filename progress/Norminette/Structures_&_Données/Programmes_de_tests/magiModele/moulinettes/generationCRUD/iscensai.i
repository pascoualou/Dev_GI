/*------------------------------------------------------------------------
File        : iscensai.i
Purpose     : Entete saisie de scenarii de journal
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIscensai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field abo            as logical    initial ? 
    field bur-cd         as integer    initial ? 
    field dev-cd         as character  initial ? 
    field etab-cd        as integer    initial ? 
    field fperiod        as character  initial ? 
    field jou-cd         as character  initial ? 
    field lib            as character  initial ? 
    field lib-ecr        as character  initial ? 
    field lib1           as character  initial ? 
    field lib2           as character  initial ? 
    field mt             as decimal    initial ?  decimals 2
    field mt-EURO        as decimal    initial ?  decimals 2
    field natjou-cd      as integer    initial ? 
    field natscen-cd     as integer    initial ? 
    field profil-cd      as integer    initial ? 
    field ref-fac        as character  initial ? 
    field regl-cd        as integer    initial ? 
    field regl-jou-cd    as character  initial ? 
    field regl-mandat-cd as integer    initial ? 
    field scen-cle       as character  initial ? 
    field soc-cd         as integer    initial ? 
    field type-cle       as character  initial ? 
    field type-scen      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
