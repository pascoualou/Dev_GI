/*------------------------------------------------------------------------
File        : PrmTv.i
Purpose     : Chaine Travaux : Parametrage des Travaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrmtv
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdPar   as character  initial ? 
    field FgArtOb as logical    initial ? 
    field FgDef   as logical    initial ? 
    field lbdiv   as character  initial ? 
    field lbdiv2  as character  initial ? 
    field lbdiv3  as character  initial ? 
    field LbPar   as character  initial ? 
    field Mtconc  as decimal    initial ?  decimals 2
    field MtCons  as decimal    initial ?  decimals 2
    field MtPar   as decimal    initial ?  decimals 2
    field Mtsynd  as decimal    initial ?  decimals 2
    field nbdevis as integer    initial ? 
    field NbPar   as integer    initial ? 
    field NoOrd   as integer    initial ? 
    field TpPar   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
