/*------------------------------------------------------------------------
File        : cexmsai.i
Purpose     : Entete Charges locatives mandat
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCexmsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field afps-appel-num as character  initial ? 
    field afps-etab-cd   as integer    initial ? 
    field afps-natjou-gi as character  initial ? 
    field annee          as integer    initial ? 
    field cours          as decimal    initial ?  decimals 8
    field dacompta       as date       initial ? 
    field dacrea         as date       initial ? 
    field daecr          as date       initial ? 
    field damod          as date       initial ? 
    field dev-cd         as character  initial ? 
    field etab-cd        as integer    initial ? 
    field fg-immeuble    as logical    initial ? 
    field ihcrea         as integer    initial ? 
    field ihmod          as integer    initial ? 
    field jou-cd         as character  initial ? 
    field mois           as integer    initial ? 
    field mtdev          as decimal    initial ?  decimals 2
    field natjou-cd      as integer    initial ? 
    field noimm          as integer    initial ? 
    field order-num      as integer    initial ? 
    field piece-compta   as integer    initial ? 
    field piece-int      as integer    initial ? 
    field prd-cd         as integer    initial ? 
    field prd-num        as integer    initial ? 
    field profil-cd      as integer    initial ? 
    field ref-num        as character  initial ? 
    field scen-cle       as character  initial ? 
    field situ           as logical    initial ? 
    field soc-cd         as integer    initial ? 
    field type-cle       as character  initial ? 
    field usrid          as character  initial ? 
    field usridmod       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
