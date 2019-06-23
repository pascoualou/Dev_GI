/*------------------------------------------------------------------------
File        : tacheEmpruntISF.i
Purpose     : 
Author(s)   : DM 20180111
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheEmpruntISF
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo
    field cTypeContrat    as character initial ? label "tpcon"
    field iNumeroContrat  as int64     initial ? label "nocon"
    field iNumeroTache    as int64     initial ?
    field cNumeroEmprunt  as character initial ?
    field cLibelleEmprunt as character initial ?
    field daEmprunt       as date 
    field dCapitalInitial as decimal   initial ?
    field dSoldeFin1997   as decimal   initial ?
    field dCapitalDebut   as decimal   initial ?
    field dRemboursement  as decimal   initial ?
    field dCapitalFin     as decimal   initial ?    

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
