/*------------------------------------------------------------------------
File        : listeMandat.i
Purpose     : 
Author(s)   : KANTENA - 2016/08/05
Notes       :
Derniere revue: 2018/04/10 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeMandat 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTypeContrat      as character initial ? label "tpcon"
    field cLibelleTypeContrat   as character initial ?
    field iNumeroContrat        as integer   initial ? label "nocon"
    field cCodeNatureContrat    as character initial ? label "ntcon"
    field cLibelleNatureContrat as character initial ?
    field iNumeroMandant        as integer   initial ?
    field cNomMandant           as character initial ?
    field cNomCompletMandant    as character initial ?
    field iNumeroImmeuble       as integer   initial ?
    field cCodePostal           as character initial ?
    field cVille                as character initial ?
    field cAdresse              as character initial ?
    field cLibelleAdresse       as character initial ?
    field lEnCoursCreation      as logical

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
