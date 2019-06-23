/*------------------------------------------------------------------------
File        : siteWeb.i
Purpose     :
Author(s)   : KANTENA - 2016/08/10 
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSiteWeb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroSiteWeb        as integer   initial ?
    field iNumeroFiche          as integer   initial ?
    field lActif                as logical   initial ?
    field cIdentifiantAgence    as character initial ?
    field cCorrespondance       as character initial ?
    field cFiltreChamps         as character initial ?
    field cCsvNom               as character initial ?
    field cCsvDelimiter         as character initial ?
    field cZipNom               as character initial ?
    field cTabComplement        as character initial ? extent 3
    field lEnvoiUniqueFiche     as logical   initial ?
    field cUrlExportUnique      as character initial ?
    field iIdMessageUpd         as integer   initial ?
    field cParamFTP             as character initial ? extent 3
    field cIdentifiantFiche     as character initial ?
    field cColonnePhoto         as character initial ?
    field cRepertoireCourantFTP as character initial ?
    field cCheminLogo           as character initial ?
    field cNomSiteWeb           as character initial ? 

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
define temp-table ttFichierSiteWeb no-undo
    field iIdFichier            as integer   initial ?
    field cNumeroSiteWeb        as character extent 10
    field iNbSiteWeb            as integer
.
