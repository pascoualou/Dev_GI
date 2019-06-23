/*------------------------------------------------------------------------
File        : SvDev.i
Purpose     : Chaine Travaux : Table du Suivi des Devis
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSvdev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle     as character  initial ? 
    field CdCsy     as character  initial ? 
    field CdMot     as character  initial ? 
    field CdMsy     as character  initial ? 
    field CdSta     as character  initial ? 
    field CdTva     as integer    initial ? 
    field DtCsy     as date       initial ? 
    field DtMsy     as date       initial ? 
    field FgVot     as logical    initial ? 
    field HeCsy     as integer    initial ? 
    field HeMsy     as integer    initial ? 
    field LbCom     as character  initial ? 
    field LbDiv1    as character  initial ? 
    field LbDiv2    as character  initial ? 
    field LbDiv3    as character  initial ? 
    field LbInt     as character  initial ? 
    field LbMot     as character  initial ? 
    field MdSig     as character  initial ? 
    field MtInt     as decimal    initial ?  decimals 3
    field NbJou     as integer    initial ? 
    field NoCpt     as integer    initial ? 
    field NoDev     as integer    initial ? 
    field noidt-fac as decimal    initial ?  decimals 2
    field NoInt     as int64      initial ? 
    field NoPar     as integer    initial ? 
    field NoRef     as integer    initial ? 
    field PxUni     as decimal    initial ?  decimals 4
    field QtInt     as decimal    initial ?  decimals 3
    field TpCpt     as character  initial ? 
    field tpidt-fac as character  initial ? 
    field TpPar     as character  initial ? 
    field TxRem     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
