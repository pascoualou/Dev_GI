/*------------------------------------------------------------------------
File        : quittancement.i
Purpose     : 
Author(s)   : Kantena  -  2017/11/20
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttQuittancement 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat             as character /* code Type du contrat          */
    field iNumeroContrat           as int64     /* Numero du contrat             */
    field iNumeroMandant           as integer   /* Numero du mandant             */
    field cNomProprietaire         as character /* Nom du proprietaire           */
    field iNumeroQuittance         as integer   /* Numéro de quittance           */
    field daFinApplicationMax      as date      /* Date de fin d'application max */
    field daDateEntree             as date      /* Date d'entrée du locataire    */
    field daDateSortie             as date      /* Date de sortie du locataire   */
    field daDateDebut              as date      /* Date de debut                 */
    field daDatefin                as date      /* Date de fin                   */
    field daDateEmission           as date      /* Date d'emmission              */
    field daDateResiliation        as date      /* Date de résiliation           */
    field daDateRenouvellement     as date      /* Date de renouvellement        */
    field daDateSignature          as date      /* Date de signature             */
    field cCodeModeReglement       as character /* Code du mode de règlement     */
    field cCodeRUM                 as character /* Code RUM                      */
    field cComp-cptg-cd            as character
    field cComp-sscpt-cd           as character
    field cMoisPrelevement         as character
    field cCodePeriodicite         as character /* Code Periodicite              */
    field cCodeTerme               as character /* Code terme                    */
    field cCodeEdition             as character
    field cIBAN-BICUse             as character
    field iNombreMoisAvance        as integer
    field iComp-Etab-cd            as integer
    field iNombreQuittanceHisto    as integer
    field iNumeroMPrelSEPA         as integer
    field dMontantLoyer            as decimal   /* Loyers        */
    field dMontantCharge           as decimal   /* Charges       */
    field dMontantDivers           as decimal   /* Divers        */
    field dMontantAdministratif    as decimal   /* Administratif */
    field dMontantImpot            as decimal   /* Impots, taxes */
    field dMontantHonoraire        as decimal   /* Honraire locataires */
    field dMontantTva              as decimal   /* Tva sur honoraires  */
    field dMontantTotal            as decimal
    field lpquit                   as logical initial ?
    field lequit                   as logical initial ?
    field laquit                   as logical initial ?
    field lSEPA                    as logical initial ?
    field lBailFournisseurLoyer    as logical initial ?
    field lDepotGarantie           as logical initial ?
    field lQuittanceAvance         as logical initial ?  /* Quittance envoyee en avance   */
    field lQuittanceEmise          as logical initial ?
    field lPrelevementSEPA         as logical initial ?
    field lPrelevementAuto         as logical initial ?
    field lPrelevementMens         as logical initial ?
    field lFournisseurLoyer        as logical initial ?
    field lHistoriqueFacturation   as logical initial ?  /* Accès à la vue historique  */
    field lAfacturer               as logical initial ?  /* Accès à la vue A facturer  */
    field lParametre               as logical initial ?  /* Accès à la vue A parameter */

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
