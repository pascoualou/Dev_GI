/*------------------------------------------------------------------------
File        : txbet.i
Purpose     : Table entete de la taxe sur bureaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTxbet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee     as integer    initial ? 
    field cdcsy     as character  initial ? 
    field cdmsy     as character  initial ? 
    field ctdec     as character  initial ? 
    field ctpai     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fgbur     as logical    initial ? 
    field fgcom     as logical    initial ? 
    field fgpkg     as logical    initial ? 
    field fgstk     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mtcom     as decimal    initial ?  decimals ?
    field mtcom-dev as decimal    initial ?  decimals ?
    field mtnbu     as decimal    initial ?  decimals ?
    field mtnbu-dev as decimal    initial ?  decimals ?
    field mtpkg     as decimal    initial ?  decimals ?
    field mtrbu     as decimal    initial ?  decimals ?
    field mtrbu-dev as decimal    initial ?  decimals ?
    field mtstk     as decimal    initial ?  decimals ?
    field mtstk-dev as decimal    initial ?  decimals ?
    field mttot     as decimal    initial ?  decimals ?
    field mttot-dev as decimal    initial ?  decimals ?
    field noimm     as integer    initial ? 
    field noman     as integer    initial ? 
    field sfcom     as decimal    initial ?  decimals ?
    field sfnbu     as decimal    initial ?  decimals ?
    field sfpkg     as decimal    initial ?  decimals 2
    field sfrbu     as decimal    initial ?  decimals ?
    field sfstk     as decimal    initial ?  decimals ?
    field tpzon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
