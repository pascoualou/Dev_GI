/*------------------------------------------------------------------------
File        : ifouetab.i
Purpose     : fichier solde fournisseur
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfouetab
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field caec          as decimal    initial ?  decimals 2
    field caec-EURO     as decimal    initial ?  decimals 2
    field caep          as decimal    initial ?  decimals 2
    field caep-EURO     as decimal    initial ?  decimals 2
    field cde           as decimal    initial ?  decimals 2
    field cde-EURO      as decimal    initial ?  decimals 2
    field encour        as decimal    initial ?  decimals 2
    field encour-EURO   as decimal    initial ?  decimals 2
    field etab-cd       as integer    initial ? 
    field four-cle      as character  initial ? 
    field lfacture      as decimal    initial ?  decimals 2
    field lfacture-EURO as decimal    initial ?  decimals 2
    field risque        as decimal    initial ?  decimals 2
    field risque-EURO   as decimal    initial ?  decimals 2
    field soc-cd        as integer    initial ? 
    field solde         as decimal    initial ?  decimals 2
    field solde-EURO    as decimal    initial ?  decimals 2
    field trt           as decimal    initial ?  decimals 2
    field trt-EURO      as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
