/*------------------------------------------------------------------------
File        : versement.i
Purpose     : 
Author(s)   : LGI/  -  2017/01/13 
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttRepertoireScan no-undo
    field iIdentifiantGed  as int64
    field cNomDossier      as character initial ? label "nom-doss"
    field cLibelleDossier  as character initial ? label "lib-doss"
    field cCheminDossier   as character initial ? label "chemin-doss"
    field cCheminCorbeille as character initial ? label "chemin-corb"

    field CRUD        as character initial "R"
    field rRowid      as rowid
    field dtTimestamp as datetime
.
define temp-table ttRepertoireScanUtilisateur no-undo
    field cNomDossier      as character           label "nom-doss" serialize-hidden
    field cCodeUtilisateur as character initial ? label "ident_u"
    field cNomUtilisateur  as character initial ?
    field lAutorise        as logical   initial ?

    field CRUD as character initial "R" // dtTimestamp  pas controlé à ce niveau
.
define temp-table ttFichierScan no-undo
    field iIdentifiantGed as int64 
    field cNomDossier     as character
    field cNomFichier     as character
    field cContenuFichier as clob 
.
define temp-table ttParamVersement no-undo
    field cCodePlanClassement as character initial ?
    field lGiExtranet         as logical   initial ?
    field daRecherche         as date      initial ?
    field cFormatDate         as character initial ?
    field cCheminFileWatcher  as character initial ?
.
define temp-table ttAttributChamps no-undo
    field id-fich      as int64     initial ? serialize-hidden
    field iPosition    as integer   initial ?
    field cNomChamp    as character initial ? 
    field lObligatoire as logical   initial ?
    field lVisible     as logical   initial ?
    index idx1 is primary iPosition  
    index idx2            cNomChamp
.
define temp-table ttFichierVerse no-undo
    field id-fich            as int64     serialize-name "iIdentifiantGed"
    field cNomDossier        as character
    field cNomFichier        as character
    field cCheminFichier     as character
    field daDateModification as date
    field cContenuFichier    as clob
.
