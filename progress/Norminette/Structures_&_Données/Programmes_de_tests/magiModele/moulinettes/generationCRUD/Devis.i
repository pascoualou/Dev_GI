/*------------------------------------------------------------------------
File        : Devis.i
Purpose     : Chaine Travaux : Table des Devis
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDevis
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy     as character  initial ? 
    field CdMsy     as character  initial ? 
    field DtAsg     as date       initial ? 
    field DtCsy     as date       initial ? 
    field DtMsy     as date       initial ? 
    field DtRel     as date       initial ? 
    field FgAsg     as logical    initial ? 
    field HeCsy     as integer    initial ? 
    field HeMsy     as integer    initial ? 
    field LbCom     as character  initial ? 
    field LbDiv1    as character  initial ? 
    field LbDiv2    as character  initial ? 
    field LbDiv3    as character  initial ? 
    field MdDev     as character  initial ? 
    field MdSig     as character  initial ? 
    field nbrel     as integer    initial ? 
    field NoAsg     as integer    initial ? 
    field NoCttF    as int64      initial ? 
    field NoDev     as integer    initial ? 
    field NoFou     as integer    initial ? 
    field noidt-fac as decimal    initial ?  decimals 2
    field NoPar     as integer    initial ? 
    field NoRef     as integer    initial ? 
    field NoReg     as character  initial ? 
    field tpcttF    as character  initial ? 
    field tpidt-fac as character  initial ? 
    field TpPar     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
