/*------------------------------------------------------------------------
File        : Event.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEvent
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTheme as character  initial ? 
    field CdCsy      as character  initial ? 
    field CdEve      as character  initial ? 
    field CdMsy      as character  initial ? 
    field CdRee      as character  initial ? 
    field CdSta      as character  initial ? 
    field CdTrm      as character  initial ? 
    field couleur    as integer    initial ? 
    field DtCsy      as date       initial ? 
    field DtDeb      as date       initial ? 
    field DtMsy      as date       initial ? 
    field DtRDb      as date       initial ? 
    field DtRee      as date       initial ? 
    field DtRFi      as date       initial ? 
    field DtSui      as date       initial ? 
    field DtTrm      as date       initial ? 
    field FgAlt      as logical    initial ? 
    field FgCfd      as logical    initial ? 
    field FgDay      as logical    initial ? 
    field HeCsy      as integer    initial ? 
    field HeDeb      as integer    initial ? 
    field HeFin      as integer    initial ? 
    field HeMsy      as integer    initial ? 
    field HeRDb      as integer    initial ? 
    field HeRee      as integer    initial ? 
    field HeRFi      as integer    initial ? 
    field HeTrm      as integer    initial ? 
    field inotrtrev  as integer    initial ? 
    field lbact      as character  initial ? 
    field LbCom      as character  initial ? 
    field lbcour     as character  initial ? 
    field lbdes      as character  initial ? 
    field LbDiv1     as character  initial ? 
    field LbDiv2     as character  initial ? 
    field LbDiv3     as character  initial ? 
    field LbEmp      as character  initial ? 
    field lbeve      as character  initial ? 
    field LbMes      as character  initial ? 
    field lbnat      as character  initial ? 
    field LbObj      as character  initial ? 
    field lbrefimm   as character  initial ? 
    field lbrefnom   as character  initial ? 
    field LbRep      as character  initial ? 
    field lbrol      as character  initial ? 
    field lbtyp      as character  initial ? 
    field mesdes01   as character  initial ? 
    field mesdes02   as character  initial ? 
    field mesdes03   as character  initial ? 
    field NbTps      as integer    initial ? 
    field NoAct      as integer    initial ? 
    field NoCon      as int64      initial ? 
    field NoDerAct   as integer    initial ? 
    field NoDoc      as integer    initial ? 
    field NoEve      as int64      initial ? 
    field NoEveSsd   as int64      initial ? 
    field NoImm      as integer    initial ? 
    field NoInt      as int64      initial ? 
    field nolot      as character  initial ? 
    field nomod      as integer    initial ? 
    field NoOrd      as integer    initial ? 
    field NoPremEve  as integer    initial ? 
    field noRfC      as integer    initial ? 
    field noRfI      as integer    initial ? 
    field NoRol      as int64      initial ? 
    field NoSsd      as integer    initial ? 
    field NoTie      as int64      initial ? 
    field NtAct      as character  initial ? 
    field refdossier as character  initial ? 
    field TpCon      as character  initial ? 
    field TpDoc      as character  initial ? 
    field TpEve      as character  initial ? 
    field TpMod      as character  initial ? 
    field tpRfC      as character  initial ? 
    field TpRol      as character  initial ? 
    field TpSui      as character  initial ? 
    field tx-nodos   as integer    initial ? 
    field tx-noint   as int64      initial ? 
    field tx-nomdt   as integer    initial ? 
    field tx-notrt   as integer    initial ? 
    field tx-tpmdt   as character  initial ? 
    field tx-tptrt   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
