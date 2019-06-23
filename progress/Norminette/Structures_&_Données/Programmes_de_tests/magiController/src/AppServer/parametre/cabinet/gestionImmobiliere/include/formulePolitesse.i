/*------------------------------------------------------------------------
File        : formulePolitesse.i
Purpose     :
Author(s)   : DMI 20181017
Notes       : Forumule de politesse en synchro des AG
derniere revue:
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFormulePolitesse
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeFamille              as character initial ? label "zon01"
    field cCodeCivilite1            as character initial ? label "zon02"
    field cCodeCivilite2            as character initial ? label "zon03"
    field cFormulePolitesseSansCher as character initial ? label "zon04"
    field cFormulePolitesseAvecCher as character initial ? label "zon05"
    field dtTimestamp               as datetime
    field CRUD                      as character
    field rRowid                    as rowid
.