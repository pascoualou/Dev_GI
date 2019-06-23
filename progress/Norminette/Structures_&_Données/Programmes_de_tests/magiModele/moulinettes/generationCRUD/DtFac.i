/*------------------------------------------------------------------------
File        : DtFac.i
Purpose     : Chaine Travaux : Table Détail des Factures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDtfac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCle  as character  initial ? 
    field CdCol  as character  initial ? 
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field CdSta  as character  initial ? 
    field CdTva  as integer    initial ? 
    field CptCd  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field FgVen  as logical    initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field LbInt  as character  initial ? 
    field MtEsc  as decimal    initial ?  decimals 2
    field MtInt  as decimal    initial ?  decimals 3
    field MtRem  as decimal    initial ?  decimals 2
    field MtTva  as decimal    initial ?  decimals 2
    field NoCpt  as integer    initial ? 
    field NoCttF as int64      initial ? 
    field NoFac  as integer    initial ? 
    field NoFis  as character  initial ? 
    field NoInt  as int64      initial ? 
    field NoRef  as integer    initial ? 
    field NoRub  as character  initial ? 
    field NoSsr  as character  initial ? 
    field PxUni  as decimal    initial ?  decimals 4
    field QtInt  as decimal    initial ?  decimals 4
    field TpCpt  as character  initial ? 
    field tpcttF as character  initial ? 
    field TvEsc  as decimal    initial ?  decimals 2
    field TvRem  as decimal    initial ?  decimals 2
    field TxRem  as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
