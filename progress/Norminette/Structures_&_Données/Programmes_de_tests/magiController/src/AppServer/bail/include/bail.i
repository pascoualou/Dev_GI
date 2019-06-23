/*------------------------------------------------------------------------
File        : bail.i
Purpose     :
Author(s)   : SPo 20/01/2017
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBail
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat             as character initial ?
    field iNumeroContrat           as int64     initial ?
    field cLibelleTypeContrat      as character initial ?
    field cCodeNatureContrat       as character initial ?
    field cLibelleNatureContrat    as character initial ?
    field lBailInvestisseur        as logical   initial ?  /* Flag bail fournisseur de loyer  */
    field daDateSignature          as date
    field daDateDebut              as date                 /* Date effet du contrat   */
    field daDateFin                as date
    field daDateInitiale           as date                 /* Date effet initiale     */
    field daDateReelleFin          as date
    field daDateEntree             as date                 /* Date d'entrée du locataire */
    field daDateSortie             as date                 /* Date de sortie du locataire */
    field cMotifResiliation        as character initial ?
    field cLibelleMotifResiliation as character initial ?
    field daDateCreation           as date
    field cNumeroReel              as character initial ?  /* N° réel du contrat - Registre  */
    field cCodeExterne             as character initial ?  /* code client    */
    field cPeriodiciteQuitt        as character initial ?
    field iNombreMoisQuitt         as integer   initial ?  /* nombre de mois de l'avis déchéance */
    field iNumeroMoisDebut         as integer   initial ?  /* no de mois de départ du quitt (si Trim décalé) */
    field cTermeQuitt              as character initial ?
    field cLibelleTermeQuitt       as character initial ?  /* avance / échu */
    field dMontantLoyer            as decimal   initial ?
    field dMontantCharge           as decimal   initial ?
    field dMontantLoyerAnnuel      as decimal   initial ?
    field dMontantLoyerContractuel as decimal   initial ?
    field daDateDerniereRevision   as date
    field lresiliationTriennale    as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index primaire is unique primary cTypeContrat iNumeroContrat.

&if defined(nomTableEchanges)   = 0 &then &scoped-define nomTableEchanges ttEchangesBail
&endif
&if defined(serialNameEchanges) = 0 &then &scoped-define serialNameEchanges {&nomTableEchanges}
&endif
define temp-table {&nomTableEchanges} no-undo serialize-name '{&serialNameEchanges}'
    field cCode   as character initial ?
    field cValeur as character initial ?
.
