/*------------------------------------------------------------------------
File        : iossai.i
Purpose     : Entete Ordre de service
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIossai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr-cd        as integer    initial ? 
    field adrfac        as character  initial ? 
    field adrmdt        as character  initial ? 
    field com-num       as integer    initial ? 
    field cours         as decimal    initial ?  decimals 9
    field cpfac         as character  initial ? 
    field cpmdt         as character  initial ? 
    field cpt-cd        as character  initial ? 
    field dacom         as date       initial ? 
    field daech         as date       initial ? 
    field dafac         as date       initial ? 
    field daliv         as date       initial ? 
    field dev-cd        as character  initial ? 
    field etab-cd       as integer    initial ? 
    field fac-num       as integer    initial ? 
    field fg-cpta-adb   as logical    initial ? 
    field fg-cpta-cab   as logical    initial ? 
    field fg-edifac     as logical    initial ? 
    field fg-lock       as logical    initial ? 
    field lib-ecr       as character  initial ? 
    field libadr-cd     as integer    initial ? 
    field libass-cd     as integer    initial ? 
    field libpaysfac-cd as character  initial ? 
    field libpaysmdt-cd as character  initial ? 
    field libraisfac-cd as integer    initial ? 
    field libraismdt-cd as integer    initial ? 
    field nomfac        as character  initial ? 
    field nommdt        as character  initial ? 
    field regl-cd       as integer    initial ? 
    field rep-cle       as character  initial ? 
    field scen-cle      as character  initial ? 
    field soc-cd        as integer    initial ? 
    field sscoll-cle    as character  initial ? 
    field totescpt      as decimal    initial ?  decimals 2
    field totht         as decimal    initial ?  decimals 2
    field tottva        as decimal    initial ?  decimals 2
    field txescpt       as integer    initial ? 
    field txremex       as integer    initial ? 
    field typefac-cle   as character  initial ? 
    field typenat-cd    as integer    initial ? 
    field vilfac        as character  initial ? 
    field vilmdt        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
