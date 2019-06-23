/*------------------------------------------------------------------------
File        : cimoinv.i
Purpose     : inventaire immo
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCimoinv
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana           as logical    initial ? 
    field ana1-cd       as character  initial ? 
    field ana1-ori      as character  initial ? 
    field ana1deb       as character  initial ? 
    field ana1fin       as character  initial ? 
    field ana2-cd       as character  initial ? 
    field ana2-ori      as character  initial ? 
    field ana2deb       as character  initial ? 
    field ana2fin       as character  initial ? 
    field ana3-cd       as character  initial ? 
    field ana3-ori      as character  initial ? 
    field ana3deb       as character  initial ? 
    field ana3fin       as character  initial ? 
    field ana4-cd       as character  initial ? 
    field ana4-ori      as character  initial ? 
    field ana4deb       as character  initial ? 
    field ana4fin       as character  initial ? 
    field burdeb        as character  initial ? 
    field bureau-cle    as character  initial ? 
    field bureau-ori    as character  initial ? 
    field burfin        as character  initial ? 
    field cession-cle   as character  initial ? 
    field cours         as decimal    initial ?  decimals 8
    field cpt-cd        as character  initial ? 
    field cptdeb        as character  initial ? 
    field cptfin        as character  initial ? 
    field dacess        as date       initial ? 
    field dadepart      as date       initial ? 
    field datinv        as date       initial ? 
    field dev-cd        as character  initial ? 
    field edi           as logical    initial ? 
    field empl-cle      as character  initial ? 
    field empl-ori      as character  initial ? 
    field etab-cd       as integer    initial ? 
    field invdeb        as character  initial ? 
    field invest-cle    as character  initial ? 
    field invest-num    as character  initial ? 
    field invfin        as character  initial ? 
    field lib           as character  initial ? 
    field lib2          as character  initial ? 
    field libmat        as character  initial ? 
    field mat-num       as character  initial ? 
    field mat-ori       as character  initial ? 
    field modana        as logical    initial ? 
    field mt            as decimal    initial ?  decimals 2
    field mt-EURO       as decimal    initial ?  decimals 2
    field mtcpta        as decimal    initial ?  decimals 2
    field mtcpta-EURO   as decimal    initial ?  decimals 2
    field num-int       as integer    initial ? 
    field prixcess      as decimal    initial ?  decimals 2
    field prixcess-EURO as decimal    initial ?  decimals 2
    field qte           as decimal    initial ?  decimals 2
    field qtearep       as decimal    initial ?  decimals 2
    field qtecor        as decimal    initial ?  decimals 2
    field qteinut       as decimal    initial ?  decimals 2
    field recno         as integer    initial ? 
    field soc-cd        as integer    initial ? 
    field sscoll-emp    as character  initial ? 
    field sscoll-ori    as character  initial ? 
    field taxe-cd       as integer    initial ? 
    field tri           as character  initial ? 
    field tvacess       as decimal    initial ?  decimals 2
    field valide        as logical    initial ? 
    field valo          as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
