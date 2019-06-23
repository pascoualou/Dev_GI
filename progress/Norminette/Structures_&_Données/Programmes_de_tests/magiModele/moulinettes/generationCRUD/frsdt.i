/*------------------------------------------------------------------------
File        : frsdt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFrsdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field art-cle     as character  initial ? 
    field cdcle       as character  initial ? 
    field cdcsy       as character  initial ? 
    field cddev       as character  initial ? 
    field cdmsy       as character  initial ? 
    field cdrem       as integer    initial ? 
    field daech       as date       initial ? 
    field dafac       as date       initial ? 
    field divers      as character  initial ? 
    field dtcsy       as date       initial ? 
    field dtech1      as date       initial ? 
    field dtmsy       as date       initial ? 
    field etab-cd     as integer    initial ? 
    field fac-num     as integer    initial ? 
    field fam-cle     as character  initial ? 
    field fg-compta   as logical    initial ? 
    field fisc-cle    as integer    initial ? 
    field fperiod     as character  initial ? 
    field hecsy       as integer    initial ? 
    field hemsy       as integer    initial ? 
    field lbdiv       as character  initial ? 
    field lbdiv2      as character  initial ? 
    field lbdiv3      as character  initial ? 
    field lib-ecr     as character  initial ? 
    field mois-cpt    as integer    initial ? 
    field mt          as decimal    initial ?  decimals 2
    field mt-EURO     as decimal    initial ?  decimals 2
    field mtdev       as decimal    initial ?  decimals 2
    field nbech       as integer    initial ? 
    field nbitm       as decimal    initial ?  decimals 2
    field noexo       as integer    initial ? 
    field nomdt       as integer    initial ? 
    field noord       as integer    initial ? 
    field noper       as integer    initial ? 
    field puht        as decimal    initial ?  decimals 2
    field puht-EURO   as decimal    initial ?  decimals 2
    field rub-cd      as integer    initial ? 
    field sfam-cle    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field ssrub-cd    as integer    initial ? 
    field taxe-cd     as integer    initial ? 
    field totht       as decimal    initial ?  decimals 2
    field tottva      as decimal    initial ?  decimals 2
    field tpmdt       as character  initial ? 
    field txescpt     as decimal    initial ?  decimals 2
    field txremex     as decimal    initial ?  decimals 2
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
