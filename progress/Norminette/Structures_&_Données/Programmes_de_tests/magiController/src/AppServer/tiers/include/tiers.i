/*------------------------------------------------------------------------
File        : tiers.i
Purpose     :
Author(s)   : KANTENA - 2016/08/04
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTiers
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTiers              as int64     initial ? label 'notie'
    field iNumeroRole               as int64     initial ? label 'norol'
    field cCodeTypeRole             as character initial ? label 'tprol'     /* Nature du tiers - role fiche locat.*/
    field iTypeTiers                as integer   initial ?                   /* Type du tiers - fiche locat.*/
    field cNom1                     as character initial ? label 'lnom1'
    field cNom2                     as character initial ? label 'lnom2'
    field cCodeCivilite1            as character initial ? label 'cdcv1'
    field cLibelleCivilite1         as character initial ?
    field cCodeCivilite2            as character initial ? label 'cdcv2'
    field cLibelleCivilite2         as character initial ?
    field cCodeFamille              as character initial ? label 'cdfat'     /* Code famille de tiers */
    field cLibelleFamille           as character initial ?
    field cCodeSousFamille          as character initial ? label 'cdsft'     /* Code sous-famille de tiers */
    field cLibelleSousFamille       as character initial ?
    field daDateNaissance1          as date      initial ? label 'dtna1'
    field daDateNaissance2          as date      initial ? label 'dtna2'
    field cPrenom1                  as character initial ? label 'lpre1'
    field cPrenom2                  as character initial ? label 'lpre2'
    field cLieuNaissance1           as character initial ? label 'lina1'
    field cLieuNaissance2           as character initial ? label 'lina2'
    field cNomJeuneFille1           as character initial ? label 'lnjf1'
    field cNomJeuneFille2           as character initial ? label 'lnjf2'
    field cLibelleProfession1       as character initial ? label 'lprf1'
    field cLibelleProfession2       as character initial ? label 'lprf2'
    field cCodeSituation            as character initial ? label 'cdst1'
    field cLibelleSituation         as character initial ?           /* libell� code situation */
    field cNomContact               as character initial ?           /* Contact Nom du tiers */
    field cPrenomContact            as character initial ?           /* Prenom Contact */
    field cLibelleProfessionContact as character initial ?           /* Profession Contact */
    field cCheminPhoto              as character initial ?           /* Chemin photo du tiers - role fiche locat.*/
    field iNumeroHisto              as integer   initial ?           /* Numero d'historique de fiche de commercialisation */ // nath

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttListeTiers no-undo
    field iNumeroTiers        as int64     initial ? label 'notie'
    field cCodeTypeRole       as character initial ?
    field iNumeroRole         as int64     initial ?
    field cLibelleCivilite    as character initial ?
    field cNomTiers           as character initial ?               /* Nom du tiers lbrol */
    field cLibelleTypeRole    as character initial ?               /* Libell� r�le lbtyp */
    field iNumeroLienAdresse  as integer   initial ?               /* Num�ro Lien Adresse nolie */
    field cAdresseTiers       as character initial ?               /* Adresse adrol */
    field cCodePostalTiers    as character initial ?               /* Code postal cprol */
    field cVilleTiers         as character initial ?               /* Ville virol */
    field cPaysTiers          as character initial ?               /* Pays pyrol */
    field cTelephoneTiers     as character initial ?               /* T�l�phone tlrol */
    field cEmailTiers         as character initial ?               /* Email emrol */
    field iNumeroImmeuble     as integer   initial ?               /* Num�ro d'immeuble noimm */
    field cNomImmeuble        as character initial ?               /* Nom de l'immeuble lbimm */
    field cTypeContrat        as character initial ?               /* Type de contrat tpctt */
    field iNumeroContrat      as integer   initial ?               /* Num�ro de Contrat noctt */
    field cLibelleContrat     as character initial ?               /* Libell� du contrat lbctt */
    field cLibelleSituation   as character initial ?               /* Libell� Situation du tiers iftie */
    field cCodeExterneMpwRol  as character initial ?               /* Code externe manpower Roles - MANPOWER cdext-rol */
    field cCodeExterneMpwCtt  as character initial ?               /* Code externe manpower Contrat - MANPOWER cdext-ctt */
    field cCodeTypRoleDefaut  as character initial ?               /* Type de role par d�faut du tiers tprol-tiers */
    field iNumeroRoleDefaut   as integer   initial ?               /* Num�ro de role par d�faut du tiers norol-tiers */
    field lFgActif            as logical   initial true            /* Fournisseur actif fgactif DM 0615/0237 */
    field cCodeReference      as character initial ?               /* Fournisseur R�f�renc� refer-cd DM 0615/0237  */
    field lWebFgOuvert        as logical   initial true            /* Ouverture de l'acc�s web like web-fgouvert */
    field daWebdateouverture  as date                              /* Date d'ouverture de l'acc�s web par le tiers like web-dateouverture */
    field cDomiciliation      as character initial ?               /* Domiciliation bancaire */
    field cTitulaire          as character initial ?
    field cIBAN               as character initial ?
    field cBIC                as character initial ?
    field cCodeFamille        as character initial ? label 'cdfat' /* Code famille de tiers */
    field cCodeSituation      as character initial ? label 'cdst1' /* Code situation (1) */
    field cLibelleProfession1 as character initial ? label 'lprf1' /* Profession (1) */

    index NoId1 iNumeroRole cCodeTypeRole cTypeContrat iNumeroContrat iNumeroTiers
    index NoId2 is primary cNomTiers iNumeroRole cCodeTypeRole cTypeContrat iNumeroContrat iNumeroTiers
    index NoId3 iNumeroTiers
.
/* LITIE (Liens Tiers-Individu) */
define temp-table ttLitie no-undo
    field iNumeroTiers    as int64     initial ? label 'notie'     /* Numero de tiers */
    field iNumeroIndividu as int64     initial ? label 'noind'     /* Numero de l'individu */
    field iNumeroPosition as integer   initial ? label 'nopos'     /* Position dans le tiers */
    field cLibelleDivers  as character initial ? label 'lbdiv'     /* Libell� divers */
    field cLibelleDivers2 as character initial ? label 'lbdiv2'    /* Libell� divers 2 */
    field cLibelleDivers3 as character initial ? label 'lbdiv3'    /* Libell� divers 3 */

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
