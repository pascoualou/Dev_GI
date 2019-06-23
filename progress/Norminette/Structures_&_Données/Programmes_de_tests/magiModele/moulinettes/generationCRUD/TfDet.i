/*------------------------------------------------------------------------
File        : TfDet.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTfdet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdAut  as integer    initial ? 
    field CdCsy  as character  initial ? 
    field CdLoy  as integer    initial ? 
    field CdMob  as integer    initial ? 
    field CdMsy  as character  initial ? 
    field CdPkE  as integer    initial ? 
    field CdPkS  as integer    initial ? 
    field CdPre  as integer    initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field DtRev  as date       initial ? 
    field EuCtt  as character  initial ? 
    field EuGes  as character  initial ? 
    field FgGes  as logical    initial ? 
    field FgRgt  as logical    initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field IdLot  as character  initial ? 
    field IdMdt  as character  initial ? 
    field IdPkg  as character  initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field LbEta  as character  initial ? 
    field LbNat  as character  initial ? 
    field LbPor  as character  initial ? 
    field MtAut  as decimal    initial ?  decimals 2
    field MtChg  as decimal    initial ?  decimals 2
    field MtDgL  as decimal    initial ?  decimals 2
    field MtDgM  as decimal    initial ?  decimals 2
    field MtDos  as decimal    initial ?  decimals 2
    field MtHon  as decimal    initial ?  decimals 2
    field MtLoy  as decimal    initial ?  decimals 2
    field MtMob  as decimal    initial ?  decimals 2
    field MtPkE  as decimal    initial ?  decimals 2
    field MtPkS  as decimal    initial ?  decimals 2
    field MtPre  as decimal    initial ?  decimals 2
    field MtQtt  as decimal    initial ?  decimals 2
    field NoImm  as integer    initial ? 
    field NoLot  as integer    initial ? 
    field NtPkg  as character  initial ? 
    field SfBal  as decimal    initial ?  decimals 2
    field SfCor  as decimal    initial ?  decimals 2
    field SfRee  as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
