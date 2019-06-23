/*------------------------------------------------------------------------
File        : Factu.i
Purpose     : Chaine Travaux : Table des Factures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFactu
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field AdFac      as integer    initial ? 
    field CdCsy      as character  initial ? 
    field CdJou      as character  initial ? 
    field CdMsy      as character  initial ? 
    field CdTvE      as integer    initial ? 
    field CdTvP      as integer    initial ? 
    field DtCpt      as date       initial ? 
    field DtCsy      as date       initial ? 
    field DtEch      as date       initial ? 
    field DtFac      as date       initial ? 
    field DtMsy      as date       initial ? 
    field Echeancier as character  initial ? 
    field EsEmb      as decimal    initial ?  decimals 2
    field EsPor      as decimal    initial ?  decimals 2
    field FgBap      as logical    initial ? 
    field FgCpt      as logical    initial ? 
    field FgEsc      as logical    initial ? 
    field FgFac      as logical    initial ? 
    field FgMoisClot as logical    initial ? 
    field FgPaye     as logical    initial ? 
    field HeCsy      as integer    initial ? 
    field HeMsy      as integer    initial ? 
    field LbCom      as character  initial ? 
    field LbDiv1     as character  initial ? 
    field LbDiv2     as character  initial ? 
    field LbDiv3     as character  initial ? 
    field LbEcr      as character  initial ? 
    field MdReg      as integer    initial ? 
    field MdSig      as character  initial ? 
    field MtEmb      as decimal    initial ?  decimals 2
    field MtEsc      as decimal    initial ?  decimals 2
    field MtPor      as decimal    initial ?  decimals 2
    field MtRem      as decimal    initial ?  decimals 2
    field MtTtc      as decimal    initial ?  decimals 2
    field MtTva      as decimal    initial ?  decimals 2
    field nocon      as integer    initial ? 
    field NoCttF     as int64      initial ? 
    field NoExe      as integer    initial ? 
    field NoFac      as integer    initial ? 
    field NoFou      as integer    initial ? 
    field noidt-fac  as decimal    initial ?  decimals 2
    field NoPar      as integer    initial ? 
    field NoPer      as integer    initial ? 
    field NoPie      as integer    initial ? 
    field NoRef      as integer    initial ? 
    field NoReg      as character  initial ? 
    field NoTer      as integer    initial ? 
    field ref-fac    as character  initial ? 
    field sscoll-cle as character  initial ? 
    field tpcon      as character  initial ? 
    field tpcttF     as character  initial ? 
    field tpidt-fac  as character  initial ? 
    field TpPar      as character  initial ? 
    field TvEmb      as decimal    initial ?  decimals 2
    field TvEsc      as decimal    initial ?  decimals 2
    field TvEsE      as decimal    initial ?  decimals 2
    field TvEsP      as decimal    initial ?  decimals 2
    field TvPor      as decimal    initial ?  decimals 2
    field TvRem      as decimal    initial ?  decimals 2
    field TxEsc      as decimal    initial ?  decimals 2
    field TxRem      as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
