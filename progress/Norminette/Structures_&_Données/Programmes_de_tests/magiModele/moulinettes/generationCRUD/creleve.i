/*------------------------------------------------------------------------
File        : creleve.i
Purpose     : Fichier releve de factures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCreleve
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acompte    as logical    initial ? 
    field adr-cd     as integer    initial ? 
    field centra     as logical    initial ? 
    field cli-cle    as character  initial ? 
    field cours      as decimal    initial ?  decimals 4
    field cpt-cd     as character  initial ? 
    field daech      as date       initial ? 
    field dafac      as date       initial ? 
    field dareleve   as date       initial ? 
    field dev-cd     as character  initial ? 
    field edi        as logical    initial ? 
    field etab-cd    as integer    initial ? 
    field fac-num    as integer    initial ? 
    field jou-cd     as character  initial ? 
    field libadr-cd  as integer    initial ? 
    field libpaie-cd as integer    initial ? 
    field lig        as integer    initial ? 
    field mtttc      as decimal    initial ?  decimals 2
    field mtttc-EURO as decimal    initial ?  decimals 2
    field order-num  as integer    initial ? 
    field piece-int  as integer    initial ? 
    field prd-cd     as integer    initial ? 
    field prd-num    as integer    initial ? 
    field regl-cd    as integer    initial ? 
    field releve-num as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field type       as logical    initial ? 
    field valid      as logical    initial ? 
    field zone-tri   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
