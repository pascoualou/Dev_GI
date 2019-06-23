/*------------------------------------------------------------------------
File        : ccptmvt.i
Purpose     : Fichier de mouvement de compte
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcptmvt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field mtcre       as decimal    initial ?  decimals 2
    field mtcre-EURO  as decimal    initial ?  decimals 2
    field mtcrep      as decimal    initial ?  decimals 2
    field mtcrep-EURO as decimal    initial ?  decimals 2
    field mtdeb       as decimal    initial ?  decimals 2
    field mtdeb-EURO  as decimal    initial ?  decimals 2
    field mtdebp      as decimal    initial ?  decimals 2
    field mtdebp-EURO as decimal    initial ?  decimals 2
    field prd-cd      as integer    initial ? 
    field prd-num     as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
