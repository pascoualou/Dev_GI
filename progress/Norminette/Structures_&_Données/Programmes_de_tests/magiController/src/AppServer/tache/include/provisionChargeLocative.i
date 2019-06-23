/*------------------------------------------------------------------------
File        : provisionChargeLocative.i
Purpose     : 
Author(s)   : SPo  -  2018/01/10
Notes       : à partir de TbTmpPro.i / table TbConPro 
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubriqueProvisionPeriode
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroInterne        as integer            initial ? /* Numero interne ligne                */
    field cTypeContrat          as character          initial ? /* code Type du contrat                */
    field iNumeroContrat        as int64              initial ? LABEL "noloc" /* Numero contrat bail locataire       */
    field cTypeMandat           as character          initial ? LABEL "tpctt"
    field iNumeroMandat         as integer            initial ? LABEL "nomdt"/* numéro mandat de gérance            */
    field iNumeroPeriode        as integer            initial ? LABEL "noexo" /* numéro période charges locatives    */
    field cNumeroCompte         as character          initial ? /* compte locataire (5 chiffres)       */
    field cTypeRubrique         as character          initial ? /* rubqt.prg06 : vide ou Q si saisie Qté/prix  / TOTAL si ligne total modifiable */
    field cNomCompletLocataire  as character          initial ? /* Nom locataire (formtiea)            */
    field daDateEntree          as date                         /* Date d'entree du locataire          */
    field daDateSortie          as date                         /* Date de sortie du locataire         */
    field cModeCalculTvaBail    as character          initial ? /* mode de calcul TVA du bail          */ /* SY 29/11/2017 ALLIANZ */
    field dTauxTVABail          as decimal            initial ? /* Taux de TVA du bail                 */ /* SY 29/11/2017 ALLIANZ */
    field iMoisQuittancement    as integer            initial ? /* Mois quittancement aquit.msqui      */    
    field iRubriqueProvision    as integer            initial ? LABEL "cdrub" /* no rubrique quittancement           */
    field cLibelleRubrique      as character          initial ?
    field lSoumisTVABail        as logical            initial ? /* flag rubrique soumise à TVA du bail */
    field dMontantQuittance     as decimal            initial ?
    field dMontantTVAQuittance  as decimal            initial ? /* Montant TVA calculé sur mtrub       */ /* SY 29/11/2017 ALLIANZ */    
    field dQuantiteRubrique     as decimal decimals 3 initial ?
    field dPrixUnitaireRubrique as decimal decimals 3 initial ?
    field dMontantReel          as decimal            initial ? label "mtree"
    field dMontantTVAReel       as decimal            initial ? /* Montant TVA calculé sur mtree       */ /* SY 29/11/2017 ALLIANZ */
    field lMontantModifiable    as logical            initial ? /* flag modification possible (ligne cumul rubrique)  */

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index idxcNoint is unique primary iNumeroInterne
    index IdxcContratRub cTypeContrat iNumeroContrat iNumeroPeriode iRubriqueProvision
.
