/*------------------------------------------------------------------------
File        : SUIVTRF.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSuivtrf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field accretour    as logical    initial ? 
    field cdretour     as character  initial ? 
    field CDTRAIT      as character  initial ? 
    field fgcache      as logical    initial ? 
    field fgdel        as logical    initial ? 
    field FGENCOURS    as logical    initial ? 
    field FGREGEN      as logical    initial ? 
    field gest-cle     as character  initial ? 
    field ihcretrf     as integer    initial ? 
    field ihtrait      as integer    initial ? 
    field JCRETRF      as date       initial ? 
    field JTRAIT       as date       initial ? 
    field lberr        as character  initial ? 
    field lbsuivtrf    as character  initial ? 
    field MOISCPT      as integer    initial ? 
    field nblig        as integer    initial ? 
    field NMFICHIER    as character  initial ? 
    field NOCHRODIS    as integer    initial ? 
    field nochrogen    as integer    initial ? 
    field nochroretour as integer    initial ? 
    field NOCHROTEL    as integer    initial ? 
    field nocr         as integer    initial ? 
    field Normsup      as character  initial ? 
    field sens         as character  initial ? 
    field soc-cd       as integer    initial ? 
    field SUPPORT      as character  initial ? 
    field usrid        as character  initial ? 
    field usridtrt     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
