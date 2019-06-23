/*------------------------------------------------------------------------
File        : cincpt.i
Purpose     : comptes comptables
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCincpt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field calcul-cle     as character  initial ? 
    field cpt-cre        as character  initial ? 
    field cpt-credep     as character  initial ? 
    field cpt-deb        as character  initial ? 
    field cpt-debdep     as character  initial ? 
    field cpt-dep        as character  initial ? 
    field cpt-drg        as character  initial ? 
    field cpt-drgcre     as character  initial ? 
    field cpt-drgdeb     as character  initial ? 
    field cpt-ori        as character  initial ? 
    field duree          as decimal    initial ?  decimals 2
    field etab-cd        as integer    initial ? 
    field fis-calcul-cle as character  initial ? 
    field fis-duree      as decimal    initial ?  decimals 2
    field fisc-cre       as integer    initial ? 
    field fisc-deb       as integer    initial ? 
    field rub-cre        as integer    initial ? 
    field rub-deb        as integer    initial ? 
    field soc-cd         as integer    initial ? 
    field sscoll-cre     as character  initial ? 
    field sscoll-deb     as character  initial ? 
    field ssrub-cre      as integer    initial ? 
    field ssrub-deb      as integer    initial ? 
    field type-invest    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
