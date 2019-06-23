/*------------------------------------------------------------------------
File        : tmprub.i
Purpose     : 
Author(s)   : kantena  -  2017/11/27 
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRub
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field noloc    as int64
    field noRefQtt as integer      /* Ajout SY le 29/08/2012 (table daquit) = 0 pour equit/aquit/pquit */
    field noqtt    as integer
    field cdfam    as integer
    field cdsfa    as integer
    field norub    as integer   initial ? label "cdrub"
    field nolib    as integer   initial ? label "cdlib"
    field nome1    as integer   initial ?
    field lbrub    as character
    field cdgen    as character
    field cdsig    as character
    field cddet    as character
    field vlqte    as decimal   initial ?
    field vlpun    as decimal   initial ?
    field mttot    as decimal   initial ?
    field cdpro    as integer   initial ?
    field vlnum    as integer   initial ?
    field vlden    as integer   initial ?
    field vlmtq    as decimal   initial ?
    field dtdap    as date      initial ?
    field dtfap    as date      initial ?
    field chfil    as character
    field nolig    as integer
    index primaire is primary noloc noqtt norub nolib
    /*
    index Ix_TmRub02 noloc noqtt cdfam norub nolib
    index Ix_TmRub03 noloc noqtt norub nolib
    */
.