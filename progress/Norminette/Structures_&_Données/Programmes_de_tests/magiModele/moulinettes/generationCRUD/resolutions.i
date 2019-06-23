/*------------------------------------------------------------------------
File        : resolutions.i
Purpose     : Résolutions des AG au cabinet et au mandat
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttResolutions
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cArticleLoi     as character  initial ? 
    field cCle            as character  initial ? 
    field cdcsy           as character  initial ? 
    field cdmsy           as character  initial ? 
    field cLibelle        as character  initial ? 
    field cPeriodicite    as character  initial ? 
    field cTexte          as character  initial ? 
    field cTypeContrat    as character  initial ? 
    field dtcsy           as date       initial ? 
    field dtmsy           as date       initial ? 
    field hecsy           as integer    initial ? 
    field hemsy           as integer    initial ? 
    field iAnneeDebut     as integer    initial ? 
    field iDerniereAG     as integer    initial ? 
    field iNombrePeriodes as integer    initial ? 
    field iNumeroContrat  as integer    initial ? 
    field iNumeroInterne  as integer    initial ? 
    field iOrdre          as integer    initial ? 
    field iProchaineAnnee as integer    initial ? 
    field iResolution     as integer    initial ? 
    field iSousResolution as integer    initial ? 
    field lbdiv           as character  initial ? 
    field lbdiv2          as character  initial ? 
    field lbdiv3          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
