/*------------------------------------------------------------------------
File        : DosRp.i
Purpose     : Chaine Travaux : Table des repartitions Achat / Vente
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDosrp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field MtEmi  as character  initial ? 
    field NoCon  as integer    initial ? 
    field NoCop  as integer    initial ? 
    field NoDos  as integer    initial ? 
    field NoLot  as integer    initial ? 
    field NoRef  as integer    initial ? 
    field PoRep  as integer    initial ? 
    field TpCon  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
