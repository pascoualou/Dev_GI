/*------------------------------------------------------------------------
File        : aful.i
Purpose     : lignes de detail charges AFUL
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAful
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana4-cd    as character  initial ? 
    field appel-num  as character  initial ? 
    field daeffet    as date       initial ? 
    field devetr-cd  as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fisc-cle   as integer    initial ? 
    field lib-ecr    as character  initial ? 
    field lig        as integer    initial ? 
    field mandat-cd  as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mtdev      as decimal    initial ?  decimals 2
    field mttva      as decimal    initial ?  decimals 2
    field mttva-dev  as decimal    initial ?  decimals 2
    field mttva-EURO as decimal    initial ?  decimals 2
    field natjou-gi  as character  initial ? 
    field pos        as integer    initial ? 
    field rub-cd     as integer    initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field ssrub-cd   as integer    initial ? 
    field taxe-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
