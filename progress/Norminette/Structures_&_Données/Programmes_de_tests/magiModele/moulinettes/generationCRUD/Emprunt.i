/*------------------------------------------------------------------------
File        : Emprunt.i
Purpose     : Emprunts : Table Emprunts
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEmprunt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdArr     as character  initial ? 
    field CdCsy     as character  initial ? 
    field CdDur     as character  initial ? 
    field CdMsy     as character  initial ? 
    field CdPre     as character  initial ? 
    field CdRee     as character  initial ? 
    field DtCsy     as date       initial ? 
    field DtDeb     as date       initial ? 
    field DtFin     as date       initial ? 
    field DtMsy     as date       initial ? 
    field DtRee     as date       initial ? 
    field DtSig     as date       initial ? 
    field HeCsy     as integer    initial ? 
    field HeMsy     as integer    initial ? 
    field LbCom     as character  initial ? 
    field LbDiv1    as character  initial ? 
    field LbDiv2    as character  initial ? 
    field LbDiv3    as character  initial ? 
    field Lbemp     as character  initial ? 
    field LiSig     as character  initial ? 
    field LoRep     as integer    initial ? 
    field NbDur     as integer    initial ? 
    field NbEch     as integer    initial ? 
    field NoBlc     as integer    initial ? 
    field NoCon     as integer    initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field NoEmp     as integer    initial ? 
    field NoHon     as decimal    initial ?  decimals 3
    field NoRef     as integer    initial ? 
    field TpArr     as character  initial ? 
    field TpCon     as character  initial ? 
    field TpEmp     as character  initial ? 
    field TpHon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
