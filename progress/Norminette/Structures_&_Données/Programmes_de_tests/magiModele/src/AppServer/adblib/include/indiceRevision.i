/*------------------------------------------------------------------------
File        : indiceRevision.i
Purpose     : 
Author(s)   : DM
Notes       :  
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttindiceRevision 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
field iCodeIndice    as integer   initial ? label "cdIrv"
field iAnnee         as integer   initial ? label "AnPer"
field iNumeroPeriode as integer   initial ? label "NoPer"
field dValeurIndice  as decimal   initial ? label "vlIrv"  
field dTauxRevision  as decimal   initial ? label "TxIrv"
field dtParutionJO   as date      initial ? label "DtPjo"
field cLibelleIndice as character initial ? label "lbcrt"
.
