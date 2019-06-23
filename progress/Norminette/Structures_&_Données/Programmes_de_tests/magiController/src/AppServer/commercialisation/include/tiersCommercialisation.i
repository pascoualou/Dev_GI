/*-----------------------------------------------------------------------------
File       : tiersCommercialisation.i
Purpose    : Tiers associés à la fiche de commercialisation
Author(s)  : NPO  -  2017/04/21
Notes      :
derniere revue: 2018/05/23 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTiersCommercialisation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroFiche          as integer   initial ? label 'nofiche'
    field iNumeroHistorique     as integer   initial ? label 'nohisto'
    field cCodeTypeRoleFiche    as character initial ? label 'tprolefiche'
    field cLibelleTypeRoleFiche as character initial ?
    field iNumeroRoleFiche      as integer   initial ? label 'norolefiche'  // inutile pour l'instant
    field iTypeTiers            as integer   initial ? label 'tptiers'
    field cCodeTypeRole         as character initial ? label 'tprol'        // Tiers en gestion
    field iNumeroRole           as int64     initial ? label 'norol'        // Tiers en gestion
    field iCodeSociete          as integer   initial ? label 'soccd'        // Tiers Fournisseur
    field cCodeFournisseur      as character initial ? label 'four-cle'     // Tiers Fournisseur
    field cNom1                 as character initial ? label 'lnom1'        // Nom du tiers (1) ou raison sociale
    field cPrenom1              as character initial ? label 'lpre1'        // Prenom tiers 1
    field cCodeCivilite1        as character initial ? label 'cdcv1'        // Code civilite (1)
    field cLibelleCivilite1     as character initial ?                      // libellé civilité1
    field cNom2                 as character initial ? label 'lnom2'        // Nom du tiers (2) ou raison sociale
    field cPrenom2              as character initial ? label 'lpre2'        // Prenom tiers 2
    field cCodeCivilite2        as character initial ? label 'cdcv2'        // Code civilite (2)
    field cLibelleCivilite2     as character initial ?                      // libellé civilité1
    field cSiret                as character initial ?                      // Tiers Fournisseur
    field cCheminPhoto          as character initial ?                      // Chemin photo du tiers - fiche locat.
    field cJointure             as character initial ?                      // pour pouvoir gérer à la fois IFOUR et TIERS/ROLES

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
