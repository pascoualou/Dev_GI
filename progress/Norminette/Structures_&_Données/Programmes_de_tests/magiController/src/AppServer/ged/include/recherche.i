/*------------------------------------------------------------------------
File        : recherche.i
Purpose     : 
Author(s)   : LGI/  -  2017/03/15 
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDocumentGED
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iIdentifiantGed            as int64               label "id-fich"
    field cIdentifiantGidemat        as character           label "resid"
    field iNumeroTypeDocument        as integer             label "typdoc-cd"
    field cObjet                     as character           label "libobj"
    field daDateDuDoc                as date                label "dadoc" 
    field daDateCreation             as date                label "dacre"
    field cLibelleTypeRole           as character           label "lbrol"    
    field iNumeroRole                as int64               label "NoRol"
    field iNumeroMandat              as integer             label "nomdt"
    field cNumeroCompte              as character           label "cnumcpt"
    field cLibelleTypeDocument       as character           label "libtypdoc"
    field iCodeTypeRole              as integer             label "tprol"
    field iNumeroTiers               as int64               label "NoTie"
    field cCodeTypeContrat           as character           label "TpCtt"
    field iNumeroContrat             as int64               label "NoCtt"
    field cLibelleRoleContrat        as character           label "cLibContrat"
    field cCodeNatureDocument        as character           label "cdnat"
    field iNumeroDossier             as integer             label "nodoss"
    field iNumeroImmeuble            as integer             label "noimm"
    field iNumeroLot                 as integer             label "nolot" 
    field cMotCle                    as character           label "cdivers1"
    field cCodeThemeGed              as character           label "theme-cd"
    field cLibelleThemeGed           as character           label "cLibThemeGed"
    field lPublie                    as logical             label "web-fgmadisp"
    field cObjetGiExtranet           as character           label "web-libobjet"
    field cCodeThemeGiExtranet       as character           label "web-theme-cd"
    field cStatutTransfert           as character           label "statut-cd"
    field cNomFichier                as character           label "nmfichier"
    field lNonPubliable              as logical             label "fg-corbeille"
    field lVisibiliteCS              as logical             label "web-fg-cs"
    field lVisibiliteLocataire       as logical             label "web-fg-loc"
    field lVisibiliteProprietaire    as logical             label "web-fg-prop"
    field lVisibiliteCoproprietaire  as logical             label "web-fg-copr"
    field lVisibiliteEmployeImmeuble as logical             label "web-fg-ei"
    field iCodeReferenceSociete      as integer             label "iReference"
    field cDescriptif                as character           label "libdesc"
    field iNumeroContratFournisseur  as integer             label "noctrat"
    field iNumeroOrdre               as integer   initial ? label "noord" 
    field cLibelleTiers              as character           label "libcpt"
    field cTypeIdentifiant           as character initial ? label "tpidt"
    field iNumeroIdentifiant         as int64     initial ? label "noidt"
    field cLibelleContratFournisseur as character
    field cLibelleImmeuble           as character
    field cLibelleLot                as character
    field cLibelleMandat             as character
    field cLibelleDossierTravaux     as character

    field rRowid      as rowid
    field CRUD        as character initial "R"
    field dtTimestamp as datetime
.
