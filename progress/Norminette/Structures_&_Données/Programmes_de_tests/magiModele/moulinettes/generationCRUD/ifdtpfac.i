/*------------------------------------------------------------------------
File        : ifdtpfac.i
Purpose     : Table des types de facturation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdtpfac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field fg-auto     as logical    initial ? 
    field FgRgtana    as logical    initial ? 
    field lib         as character  initial ? 
    field profil-cd   as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
