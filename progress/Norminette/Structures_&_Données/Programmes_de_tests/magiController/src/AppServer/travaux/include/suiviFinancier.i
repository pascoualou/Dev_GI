/*------------------------------------------------------------------------
File        : suiviFinancier.i
Purpose     : 
Author(s)   : OF  -  2016/23/11
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttListeSuiviFinancierClient no-undo /*Ancienne table TbTmpScl*/
    field iNumeroCoproprietaire         as integer
    field cNomCoproprietaire            as character
    field dMontantTotalAppele           as decimal /** dSommeAppelEmis + dMontantAppelManuel **/
    field dMontantEncaissement          as decimal
    field dMontantEncaissementLettre    as decimal  /* 0306/0215 - Séparation lettrés / non lettrés */
    field dMontantEncaissementNonLettre as decimal
    field dMontantResteDu               as decimal
    field lAnomalie                     as logical /** 0508/0072 : = true si mtres <> du solde du copro **/
    field dMontantAppelReconstitue      as decimal /** Appels de fonds manuels **/
    field dMontantAppelEmis             as decimal /** Appels émis GI **/
    field dSommeAppelEmis               as decimal /** Somme des apbco ( quand il n'y en a pas dosrp ) + Somme des CPHB + Les OD ventilées en apbco **/
    field dMontantAppelCloture          as decimal /** Appels de cloture **/
    field dMontantOdSansDetail          as decimal /** OD sans ventilation en apbco **/
    field dMontantOdAvecDetail          as decimal /** OD avec ventilation en apbco **/
    field dMontantTresorerie            as decimal /** Trésorerie **/
    field dMontantCompensation          as decimal /** Compensation **/
    field dMontantODTresorerie          as decimal /** ODT **/
    field dMontantAutre                 as decimal /** **/
    field dMontantAchat                 as decimal /** Pièces d"achats **/
    field dSoldeChb                     as decimal /** Solde du compte chb sur le dossier **/
index primaire iNumeroCoproprietaire
.
/** Suivi financier client : détail au niveau du copro.**/
define temp-table ttDetailSuiviFinancierClient no-undo  /*Ancienne table TbTmpDetCop */
    field iNumeroEntete             as integer
    field iNumeroLigne              as integer
    field cNumeroCoproprietaire     as character
    field cNomCoproprietaire        as character
    field cMontantAppel             as character
    field cMontantAppelManuel       as character
    field cMontantAppelEmis         as character
    field cMontantEncaisse          as character
    field cMontantRestant           as character
    field cCodeCle                  as character
    field cNumeroLot                as character
    index idxNolgn iNumeroEntete iNumeroLigne   // Attention, ne pas enlever l'index, sert dans un for last !!!               
.
/** Suivi financier client : Liste des écritures du copro quand le solde du copro est différent du reste/du **/
define temp-table ttListeEcriture no-undo       /*ancienne table TbTmpEcr, like cecrln*/
    field iNumeroSociete        as integer      /*cecrln.soc-cd*/
    field iNumeroMandat         as integer      /*cecrln.etab-cd*/
    field cCodeJournal          as character    /*cecrln.jou-cd*/
    field iNumeroExercice       as integer      /*cecrln.prd-cd*/
    field iNumeroPeriode        as integer      /*cecrln.prd-num*/
    field iNumeroMandatEntete   as integer      /*cecrln.mandat-cd*/
    field iNumeroExerciceEntete as integer      /*cecrln.mandat-prd-cd*/
    field iNumeroPeriodeEntete  as integer      /*cecrln.mandat-prd-num*/
    field iNumeroPieceInterne   as integer      /*cecrln.piece-int*/
    field iNumeroLigne          as integer      /*cecrln.lig*/
    field lSensMontant          as logical      /*cecrln.sens*/
    field dMontant              as decimal      /*cecrln.mt*/
    field daDateComptable       as date         /*cecrln.dacompta*/
    field cLibelle              as character    /*cecrln.lib*/
    field cNumeroDocument       as character    /*cecrln.ref-num*/
    field cLettre               as character    /*cecrln.lettre*/
    index primaire iNumeroSociete iNumeroMandat
.
define temp-table ttDetailAppelTravauxParLot no-undo /*ancienne table TbTmpApbco*/
    field iNumeroMandat         as integer    /*apbco.nomdt*/ 
    field iNumeroCopro          as integer    /*apbco.nocop*/
    field iNumeroBudget         as integer    /*apbco.nobud*/
    field cTypeAppel            as character  /*apbco.tpapp*/
    field cTypeBudget           as character  /*apbco.tpbud*/
    field iNumeroAppel          as integer    /*apbco.noapp*/
    field iNumeroLot            as integer    /*apbco.nolot*/
    field dMontantLot           as decimal    /*apbco.mtlot*/
    field cLienPieceComptable   as character  /*apbco.lbdiv2*/
    field cTypeTravaux          as character  /*apbco.typapptrx*/          
    field daDateAppel           as date       /*apbco.dtapp*/
    field dMontantTotal         as decimal    /*apbco.mttot*/
    field iNumeroImmeuble       as integer    /*apbco.noimm*/
    field iNumeroOrdre          as integer    /*apbco.noord*/
    index primaire iNumeroMandat iNumeroCopro cTypeBudget iNumeroBudget cTypeAppel iNumeroAppel
.
/*--> Table du suivi travaux */
define temp-table ttListeSuiviFinancierTravaux no-undo /*Ancienne table TbTmpStr*/
    field iCodeFournisseur      as integer     serialize-hidden // ajouté pour des raisons de performance
    field cCodeTypeTravaux      as character   /** 0306/0215 **/
    field cLibelleTypeTravaux   as character   /** 0306/0215 **/
    field cLibelleTri           as character
    field cNomFournisseur       as character
    field dMontantReponseDevis  as decimal
    field cLibelleReponseDevis  as character
    field dMontantOrdre2Service as decimal
    field cLibelleOrdre2Service as character
    field dMontantFacture       as decimal
    field cLibelleFacture       as character
    field dMontantAppelEmis     as decimal /** Appels Emis **/
    field cLibelleAppelEmis     as character
    field dMontantAppelManuel   as decimal /** Appels manuels **/
    field cLibelleAppelManuel   as character
    field dMontantEncaissement  as decimal
    field cLibelleEncaissement  as character
    field dMontantRegle         as decimal
    field cLibelleRegle         as character
    field dMontantResteDu       as decimal
    field cLibelleResteDu       as character
    field dMontantTotalAppel    as decimal /** Totalité des appels de fonds tous fournisseurs confondus **/
    index primaire iCodeFournisseur cCodeTypeTravaux
.
