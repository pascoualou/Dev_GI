/*------------------------------------------------------------------------
File        : acdbar.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAcdbar
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num as integer    initial ? 
    field cptg-cd    as character  initial ? 
    field datecr     as date       initial ? 
    field datrt      as date       initial ? 
    field devetr-cd  as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fg-soumis  as logical    initial ? 
    field fg-traite  as logical    initial ? 
    field index-cd   as integer    initial ? 
    field lib1       as character  initial ? 
    field lib2       as character  initial ? 
    field lstappel   as character  initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mtdev      as decimal    initial ?  decimals 2
    field natjou-gi  as integer    initial ? 
    field par1       as character  initial ? 
    field ref-num    as character  initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field sscpt-cd   as character  initial ? 
    field tpcb-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
