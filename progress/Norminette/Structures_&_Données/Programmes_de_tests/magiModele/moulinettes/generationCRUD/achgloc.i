/*------------------------------------------------------------------------
File        : achgloc.i
Purpose     : quote-part charges locatives
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAchgloc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cptg-cd  as character  initial ? 
    field dacrea   as date       initial ? 
    field datirage as date       initial ? 
    field etab-cd  as integer    initial ? 
    field lib      as character  initial ? 
    field mt       as decimal    initial ?  decimals 2
    field mt-EURO  as decimal    initial ?  decimals 2
    field noexo    as integer    initial ? 
    field Sens     as logical    initial ? 
    field soc-cd   as integer    initial ? 
    field sscpt-cd as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
