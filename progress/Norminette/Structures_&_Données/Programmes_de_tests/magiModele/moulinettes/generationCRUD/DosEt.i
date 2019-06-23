/*------------------------------------------------------------------------
File        : DosEt.i
Purpose     : Chaine Travaux : Entete appel de fond travaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDoset
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy      as character  initial ? 
    field CdMsy      as character  initial ? 
    field CdTva      as integer    initial ? 
    field DtCsy      as date       initial ? 
    field DtMsy      as date       initial ? 
    field HeCsy      as integer    initial ? 
    field HeMsy      as integer    initial ? 
    field LbCom      as character  initial ? 
    field LbDiv1     as character  initial ? 
    field LbDiv2     as character  initial ? 
    field LbDiv3     as character  initial ? 
    field LbInt      as character  initial ? 
    field MtApp      as decimal    initial ?  decimals 3
    field MtNet      as decimal    initial ?  decimals 3
    field MtTva      as decimal    initial ?  decimals 2
    field NbApp      as integer    initial ? 
    field NoCon      as integer    initial ? 
    field NoDos      as integer    initial ? 
    field NoFou      as integer    initial ? 
    field NoIdt      as integer    initial ? 
    field NoInt      as int64      initial ? 
    field NoOrd      as integer    initial ? 
    field NoRef      as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field TpApp      as character  initial ? 
    field TpCon      as character  initial ? 
    field TpSur      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
