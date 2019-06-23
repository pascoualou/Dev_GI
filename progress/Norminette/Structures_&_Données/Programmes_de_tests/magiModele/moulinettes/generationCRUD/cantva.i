/*------------------------------------------------------------------------
File        : cantva.i
Purpose     : TVA sur encaissement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCantva
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acpte            as logical    initial ? 
    field coll-cle         as character  initial ? 
    field cpt-cd           as character  initial ? 
    field cpt-tva          as character  initial ? 
    field dacompta         as date       initial ? 
    field daech            as date       initial ? 
    field debit            as logical    initial ? 
    field ecrln-jou-cd     as character  initial ? 
    field ecrln-lig        as integer    initial ? 
    field ecrln-piece-int  as integer    initial ? 
    field ecrln-prd-cd     as integer    initial ? 
    field ecrln-prd-num    as integer    initial ? 
    field edi              as logical    initial ? 
    field eff              as logical    initial ? 
    field etab-cd          as integer    initial ? 
    field fg-prorata       as logical    initial ? 
    field fg-reg           as logical    initial ? 
    field jou-cd           as character  initial ? 
    field lig              as integer    initial ? 
    field mtht             as decimal    initial ?  decimals 2
    field mtht-EURO        as decimal    initial ?  decimals 2
    field mthtanc          as decimal    initial ?  decimals 2
    field mthtanc-EURO     as decimal    initial ?  decimals 2
    field mthtdev          as decimal    initial ?  decimals 2
    field mthtinit         as decimal    initial ?  decimals 2
    field mthtinit-EURO    as decimal    initial ?  decimals 2
    field mtttc-reste      as decimal    initial ?  decimals 2
    field mtttc-reste-EURO as decimal    initial ?  decimals 2
    field mttva            as decimal    initial ?  decimals 2
    field mttva-EURO       as decimal    initial ?  decimals 2
    field mttvaanc         as decimal    initial ?  decimals 2
    field mttvaanc-EURO    as decimal    initial ?  decimals 2
    field mttvadev         as decimal    initial ?  decimals 2
    field mttvainit        as decimal    initial ?  decimals 2
    field mttvainit-EURO   as decimal    initial ?  decimals 2
    field natjou-cd        as integer    initial ? 
    field natjou-ori       as integer    initial ? 
    field noord            as integer    initial ? 
    field piece-compta     as integer    initial ? 
    field piece-int        as integer    initial ? 
    field prd-cd           as integer    initial ? 
    field prd-num          as integer    initial ? 
    field ref-num          as character  initial ? 
    field regul            as logical    initial ? 
    field regul-old        as logical    initial ? 
    field sens             as logical    initial ? 
    field soc-cd           as integer    initial ? 
    field sscoll-cle       as character  initial ? 
    field taxe-cd          as integer    initial ? 
    field taxeinit         as integer    initial ? 
    field valid            as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
