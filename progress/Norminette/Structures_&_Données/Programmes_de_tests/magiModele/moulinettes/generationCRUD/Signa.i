/*------------------------------------------------------------------------
File        : Signa.i
Purpose     : Chaine Travaux : Table des Signalements
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSigna
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy     as character  initial ? 
    field CdMsy     as character  initial ? 
    field DtCsy     as date       initial ? 
    field DtMsy     as date       initial ? 
    field HeCsy     as integer    initial ? 
    field HeMsy     as integer    initial ? 
    field LbCom     as character  initial ? 
    field LbDiv1    as character  initial ? 
    field LbDiv2    as character  initial ? 
    field LbDiv3    as character  initial ? 
    field MdSig     as character  initial ? 
    field noidt-fac as decimal    initial ?  decimals 2
    field NoRef     as integer    initial ? 
    field NoSig     as integer    initial ? 
    field tpidt-fac as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
