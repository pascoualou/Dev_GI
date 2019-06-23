/*------------------------------------------------------------------------
File        : workflow.i
Purpose     : Gestion paramétrage étapes workflow fiche commercialisation
Author(s)   : SY  -  12/04/2017
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttWorkflow
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iOrdre                  as integer   initial ?
    field iNumeroWorkflowEnCours  as integer   initial ? label 'noworkflow1'
    field iNumeroWorkflowSuivant  as integer   initial ? label 'noworkflow2'
    field cLibelleWorkflowEnCours as character initial ?
    field cLibelleWorkflowSuivant as character initial ?
    field lPassageGestionnaire    as logical   initial ? label 'fggestion'
    field lPassagecommercial      as logical   initial ? label 'fgcommercial'
    field lPassagelogiciel        as logical   initial ? label 'fglogiciel'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index idx01 iOrdre iNumeroWorkflowEnCours iNumeroWorkflowSuivant
.
