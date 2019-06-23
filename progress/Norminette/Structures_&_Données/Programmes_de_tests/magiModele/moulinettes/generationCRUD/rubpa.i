/*------------------------------------------------------------------------
File        : rubpa.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubpa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ascat as character  initial ? 
    field cdcsy as character  initial ? 
    field cdgen as character  initial ? 
    field cdrub as integer    initial ? 
    field cdsig as character  initial ? 
    field dtcsy as date       initial ? 
    field fg13m as logical    initial ? 
    field fganc as logical    initial ? 
    field fgcge as logical    initial ? 
    field fgcot as logical    initial ? 
    field fgimp as logical    initial ? 
    field fglib as logical    initial ? 
    field fgmnt as logical    initial ? 
    field fgnbr as logical    initial ? 
    field fgtau as logical    initial ? 
    field hecsy as integer    initial ? 
    field lbdiv as character  initial ? 
    field lbrub as character  initial ? 
    field nome1 as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
