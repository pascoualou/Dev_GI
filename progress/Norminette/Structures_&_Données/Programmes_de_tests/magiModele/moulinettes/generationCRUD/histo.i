/*------------------------------------------------------------------------
File        : histo.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHisto
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdana     as character  initial ? 
    field cdcle     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdeta     as character  initial ? 
    field cdfbl     as integer    initial ? 
    field cdhon     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdtva     as character  initial ? 
    field cdven     as character  initial ? 
    field dtcpt     as integer    initial ? 
    field dtcsy     as date       initial ? 
    field dtecr     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fgaco     as logical    initial ? 
    field fgdas     as logical    initial ? 
    field fgpro     as logical    initial ? 
    field fgtva     as logical    initial ? 
    field fill1     as character  initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbecr     as character  initial ? 
    field mdecr     as character  initial ? 
    field mtecr     as decimal    initial ?  decimals 2
    field mtecr-dev as decimal    initial ?  decimals 2
    field mtinc     as decimal    initial ?  decimals 2
    field mtinc-dev as decimal    initial ?  decimals 2
    field mtint     as decimal    initial ?  decimals 2
    field mtint-dev as decimal    initial ?  decimals 2
    field mttva     as decimal    initial ?  decimals 2
    field mttva-dev as decimal    initial ?  decimals 2
    field mtven     as decimal    initial ?  decimals 2
    field mtven-dev as decimal    initial ?  decimals 2
    field nodoc     as integer    initial ? 
    field nofou     as integer    initial ? 
    field nolib     as integer    initial ? 
    field nolic     as integer    initial ? 
    field nolig     as integer    initial ? 
    field nopie     as integer    initial ? 
    field pcptc     as integer    initial ? 
    field pcpte     as integer    initial ? 
    field rlecr     as character  initial ? 
    field scptc     as integer    initial ? 
    field scpte     as integer    initial ? 
    field tpecr     as character  initial ? 
    field tpidt     as character  initial ? 
    field tptva     as character  initial ? 
    field ttden     as integer    initial ? 
    field ttnum     as integer    initial ? 
    field txtva     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
