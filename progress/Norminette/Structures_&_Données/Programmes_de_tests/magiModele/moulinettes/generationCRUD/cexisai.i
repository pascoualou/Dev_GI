/*------------------------------------------------------------------------
File        : cexisai.i
Purpose     : Entete Charges locatives par immeuble
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCexisai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee     as integer    initial ? 
    field cours     as decimal    initial ?  decimals 8
    field dacompta  as date       initial ? 
    field dacrea    as date       initial ? 
    field daecr     as date       initial ? 
    field damod     as date       initial ? 
    field dev-cd    as character  initial ? 
    field ihcrea    as integer    initial ? 
    field ihmod     as integer    initial ? 
    field jou-cd    as character  initial ? 
    field mois      as integer    initial ? 
    field noimm     as integer    initial ? 
    field order-num as integer    initial ? 
    field ref-num   as character  initial ? 
    field scen-cle  as character  initial ? 
    field situ      as logical    initial ? 
    field soc-cd    as integer    initial ? 
    field type-cle  as character  initial ? 
    field usrid     as character  initial ? 
    field usridmod  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
