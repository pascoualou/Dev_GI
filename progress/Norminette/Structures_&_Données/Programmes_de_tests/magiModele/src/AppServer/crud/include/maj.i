/*------------------------------------------------------------------------
File        : MAJ.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMaj
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdenr     as character initial ?
    field datecomp  as date
    field gest-cle  as character initial ?
    field ihcremvt  as integer   initial ?
    field ihmodmvt  as integer   initial ?
    field ihtrf     as integer   initial ?
    field jcremvt   as date
    field jmodmvt   as date
    field jtrf      as date
    field mandat-cd as character initial ?
    field nmlog     as character initial ?
    field nmtab     as character initial ?
    field nomprog   as character initial ?
    field soc-cd    as integer   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
