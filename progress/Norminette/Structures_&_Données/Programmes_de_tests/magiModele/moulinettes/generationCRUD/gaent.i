/*------------------------------------------------------------------------
File        : gaent.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGaent
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field agence     as integer    initial ? 
    field cdcsy      as character  initial ? 
    field cdmsy      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtemi      as date       initial ? 
    field dtemi-remp as date       initial ? 
    field dtemi-resp as date       initial ? 
    field dtfin      as date       initial ? 
    field dtlim      as date       initial ? 
    field dtmsy      as date       initial ? 
    field fgemi      as logical    initial ? 
    field fgemi-remp as logical    initial ? 
    field fgemi-resp as logical    initial ? 
    field fgman      as logical    initial ? 
    field fgman-remp as logical    initial ? 
    field hecsy      as integer    initial ? 
    field heemi      as integer    initial ? 
    field heemi-remp as integer    initial ? 
    field heemi-resp as integer    initial ? 
    field hemsy      as integer    initial ? 
    field hrale      as character  initial ? 
    field hrdeb      as character  initial ? 
    field hrfin      as character  initial ? 
    field lbcom      as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field nbtot      as integer    initial ? 
    field nbtrt      as integer    initial ? 
    field noidt      as int64      initial ? 
    field nolig      as integer    initial ? 
    field noord      as integer    initial ? 
    field noremp     as integer    initial ? 
    field noresp     as integer    initial ? 
    field norol      as integer    initial ? 
    field notac      as integer    initial ? 
    field tpidt      as character  initial ? 
    field tpremp     as character  initial ? 
    field tpresp     as character  initial ? 
    field tprol      as character  initial ? 
    field txtrt      as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
