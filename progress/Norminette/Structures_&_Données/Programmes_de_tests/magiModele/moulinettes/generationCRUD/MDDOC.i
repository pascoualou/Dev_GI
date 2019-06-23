/*------------------------------------------------------------------------
File        : MDDOC.i
Purpose     : Modèle document
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMddoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTheme as character  initial ? 
    field cdcsy      as character  initial ? 
    field cddev      as character  initial ? 
    field cdmsy      as character  initial ? 
    field cdsdo      as character  initial ? 
    field cstype     as character  initial ? 
    field ctype      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtmsy      as date       initial ? 
    field eve-cdsdo  as character  initial ? 
    field fgdef      as logical    initial ? 
    field fggii      as logical    initial ? 
    field fgtie      as logical    initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field iRattBur   as integer    initial ? 
    field lbcom      as character  initial ? 
    field lbcrt      as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field lbdot      as character  initial ? 
    field noact      as integer    initial ? 
    field nodot      as integer    initial ? 
    field tpmod      as character  initial ? 
    field typdoc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
