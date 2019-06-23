/*------------------------------------------------------------------------
File        : tacheDossierLocataire.i
Purpose     : table tache Dossier Locataire
Author(s)   : npo  -  18/10/2017
Notes       : Baux Lot 1
derniere revue: 2018/03/20 - phm
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheDossierLocataire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache     as int64     initial ? label "noita"
    field cTypeContrat     as character initial ? label "tpcon"
    field iNumeroContrat   as int64     initial ? label "nocon"
    field cTypeTache       as character initial ? label "tptac"
    field iChronoTache     as integer   initial ? label "notac"
    field daLettre         as date                label "dtdeb"
    field daRelance        as date                label "dtfin"
    field iNumeroPiece     as integer   initial ?
    field cLibellePiece    as character initial ?        /*cdreg*/
    field cFlagObligatoire as character initial ? 
    field cFlagRemise      as character initial ?        /*ntreg*/
    field daDateRemise     as date                       /*pdreg*/
    field dtTimestamp      as datetime
    field CRUD             as character
    field rRowid           as rowid
.
