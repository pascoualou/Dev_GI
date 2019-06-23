/*------------------------------------------------------------------------
File        : DiImm.i
Purpose     : Dispositions Légales sur l'Immeuble
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDiimm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field DiPrv  as date       initial ? 
    field DiRea  as date       initial ? 
    field dtcsy  as date       initial ? 
    field DtCtl  as date       initial ? 
    field dtmsy  as date       initial ? 
    field DtRch  as date       initial ? 
    field FgCtl  as logical    initial ? 
    field FgRch  as logical    initial ? 
    field FgSur  as logical    initial ? 
    field FgTrx  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field noimm  as integer    initial ? 
    field TpDis  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
