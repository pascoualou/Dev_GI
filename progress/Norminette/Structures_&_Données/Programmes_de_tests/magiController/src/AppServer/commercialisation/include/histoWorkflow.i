/*------------------------------------------------------------------------
File        : histoWorkflow.i
Purpose     : Gestion param�trage �tapes workflow fiche commercialisation
Author(s)   : SY  -  12/04/2017
Notes       :
derniere revue: 2018/05/23 - phm: KO
        revoir le nom des champs!! dtHorodatageMaj � l'air d'une date de cr�ation dans le code.
        si CRUD, en g�n�ral rRowid, dtTimestamp.
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHistoWorkflow
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroFiche        as integer   initial ? label 'nofiche'
    field iNumeroWorkflowPrec as integer   initial ? label 'noworkflow1'
    field iNumeroWorkflowSuiv as integer   initial ? label 'noworkflow2'
    field dtHorodatageMaj     as datetime
    field cSysUser            as character initial ?

    field CRUD as character
.
