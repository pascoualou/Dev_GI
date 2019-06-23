/*------------------------------------------------------------------------
File        : MAJ.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMaj
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CDENR     as character  initial ? 
    field datecomp  as date       initial ? 
    field gest-cle  as character  initial ? 
    field ihcremvt  as integer    initial ? 
    field ihmodmvt  as integer    initial ? 
    field ihtrf     as integer    initial ? 
    field JCREMVT   as date       initial ? 
    field JMODMVT   as date       initial ? 
    field JTRF      as date       initial ? 
    field mandat-cd as character  initial ? 
    field NMLOG     as character  initial ? 
    field NMTAB     as character  initial ? 
    field nomprog   as character  initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
