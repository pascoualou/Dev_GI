/*------------------------------------------------------------------------
File        : PrmAr.i
Purpose     : Chaine Travaux : Table Param Comptable Article
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrmar
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdArt  as character  initial ? 
    field CdCol  as character  initial ? 
    field CdCsy  as character  initial ? 
    field CdMsy  as character  initial ? 
    field CptCd  as character  initial ? 
    field DtCsy  as date       initial ? 
    field DtMsy  as date       initial ? 
    field FgDos  as logical    initial ? 
    field FgVen  as logical    initial ? 
    field HeCsy  as integer    initial ? 
    field HeMsy  as integer    initial ? 
    field LbCom  as character  initial ? 
    field LbDiv1 as character  initial ? 
    field LbDiv2 as character  initial ? 
    field LbDiv3 as character  initial ? 
    field NoFis  as character  initial ? 
    field NoRef  as integer    initial ? 
    field NoRub  as character  initial ? 
    field NoSsr  as character  initial ? 
    field TpCon  as character  initial ? 
    field TpUrg  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
