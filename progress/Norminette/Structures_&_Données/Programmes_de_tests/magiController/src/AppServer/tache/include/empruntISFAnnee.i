/*------------------------------------------------------------------------
File        : empruntISFAnnee.i
Purpose     : 
Author(s)   : DM 20180111
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEmpruntISFAnnee
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table ttEmpruntISFAnnee no-undo
    field cTypeContrat   as character initial ? label "tpcon"
    field iNumeroContrat as int64     initial ? label "nocon"
    field iNumeroTache   as int64     initial ?
    field iAnnee         as integer   initial ?
    field dCapitalDebut  as decimal   initial ?
    field dInteret       as decimal   initial ?
    field dRemboursement as decimal   initial ?
    field dCapitalFin    as decimal   initial ?
.
