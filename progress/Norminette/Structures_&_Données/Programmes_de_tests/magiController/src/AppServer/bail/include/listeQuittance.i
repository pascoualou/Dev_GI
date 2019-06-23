/*------------------------------------------------------------------------
File        : listeQuittance.i
Purpose     : Liste simplifiée des quittances (equit, aquit)
Author(s)   : SPo - 2018/07/31
Notes       :
derniere revue: 2018/08/01 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeQuittance 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeRole            as character initial ? label "tprol"
    field iNumeroLocataire     as integer   initial ? label "noloc"
    field iNoQuittance         as integer   initial ? label "noqtt"
    field iMoisTraitementQuitt as integer   initial ? label "msqtt"
    field daDebutQuittancement as date                label "dtdeb"
    field daFinQuittancement   as date                label "dtfin"
    field daDebutPeriode       as date                label "dtdpr"
    field daFinPeriode         as date                label "dtfpr"
    field iNombreRubrique      as integer   initial ? label "nbrub"
    field dMontantQuittance    as decimal   initial ? label "mtqtt"
    field cNomTable            as character initial ?                       // equit, aquit, pquit, daquit, equitrev

    field dtTimestamp          as datetime
    field CRUD                 as character
    field rRowid               as rowid
.
