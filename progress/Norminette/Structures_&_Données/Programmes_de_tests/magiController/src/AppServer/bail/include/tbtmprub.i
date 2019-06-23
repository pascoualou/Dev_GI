/*------------------------------------------------------------------------
File        : tbtmprub.i
Purpose     : Détail des rubriques par quittance
Author(s)   :
Notes       : reprise ancien include tbtmpqtt.i : table tmrub
              NE PAS RAJOUTER D'INITIALISATION DES CHAMPS, laisser les valeurs par defaut de progress
              
derniere revue: 2018/07/28 - phm:
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRub
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroLocataire             as int64     label "noloc"
    field iNoQuittanceAssociee         as integer   label "norefqtt"      //= 0 pour equit/aquit/pquit */
    field iNoQuittance                 as integer   label "noqtt"
    field iFamille                     as integer   label "cdfam"
    field iSousFamille                 as integer   label "cdsfa"
    field iNorubrique                  as integer   label "norub"
    field iNoLibelleRubrique           as integer   label "nolib"
    field cLibelleRubrique             as character label "lbrub"
    field cCodeGenre                   as character label "cdgen"
    field cCodeSigne                   as character label "cdsig"
    field cddet                        as character label "cddet"         //code detail à priori inutilisé ???
    field dQuantite                    as decimal   label "vlqte"
    field dPrixunitaire                as decimal   label "vlpun"
    field dMontantTotal                as decimal   label "mttot"
    field iProrata                     as integer   label "cdpro"
    field iNumerateurProrata           as integer   label "vlnum"
    field iDenominateurProrata         as integer   label "vlden"
    field dMontantQuittance            as decimal   label "vlmtq"
    field daDebutApplication           as date      label "dtdap"
    field daFinApplication             as date      label "dtfap"
    field daDebutApplicationPrecedente as character label "chfil"
    field iNoOrdreRubrique             as integer   label "nolig"

    field lModificationAutorisee  as logical
    field lSuppressionAutorisee   as logical
    field lLienRubrique           as logical
    field lSaisieQuantitePrixUnit as logical
    field lSaisieDateFin          as logical
    field lSaisieProrata          as logical
    field cLibelleGenre           as character
    field cLibelleSigne           as character
    field cNegatif                as logical

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    // index Ix_TmRub01 is unique primary noloc norefqtt noqtt norub nolib
    // index Ix_TmRub02 noloc noqtt cdfam norub nolib
    // index Ix_TmRub03 noloc noqtt norub nolib
.
