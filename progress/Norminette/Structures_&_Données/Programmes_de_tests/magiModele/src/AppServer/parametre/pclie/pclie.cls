/*------------------------------------------------------------------------
File        : pclie
Description : Objet générique paramétrage client lié à la table pclie.
Author(s)   : kantena  -  2017/09/29
Notes       :
  THEME-COURRIER: (zon01 = cTypeCorrepondanceEnCours, zon02 = cCodeDernierThemeUtilise), chxtheme.i
  NXTSSD: next numéro ssdos, est-ce encore utilisé ???  FctEvent.i
  DUBUD: client Options de duplication des budgets (/* Valeurs par défaut */ int01 = 1, int02 = 1, int03 = 1, zon09 = "2", int04 = 2 /* arrondi */, int05 = 1 /* centimes */), Lstdubud.i, pcldubud.p, dubudini.p
  PREXL01: parametre excel (zon01 = cNomColonne, zon02 = cTitreColonne, zon03 = cRubriques, zon04 = cDuree), selrqgen.i
  TRIMM: (zon01 = NmUsrUse, zon02 = CdSec, int01 = NoOrd), gestim01_srv.p
  TRLOT: (zon01 = NmUsrUse, zon02 = CdSec, int01 = NoOrd), immlot02_srv.p
  ISFPA: parametrage ISF (zon01 = "DpG": depot de garantie, zon02 = LbPrmUse-IO, zon03 = LstNoCptCol), AfDpGISF.p
  STAHODETAIL: paramétrage statistiques honoraires budgetaires(zon01 = STRING(typhon, "999"), zon02 = art-cle, zon03 = typfac), StaHon00.p, pclholoq.p
  HOLOQ: Paramètre hono loc par le quit activé (zon02 = art-cle, int01 = 840, int02 = 01)
  RBEXT: Anciennes rubriques EXTOURNABLES (zon01 = cdrub)
  TABHO, TABHOCOP: Paramètre tableau de bord honoraires (gerance, copro)
          (zon01 = typhon, zon02 = art-cle, zon03 = typefac-cle, int01 = nolib, int02 = profil-cd (21 ou 91), lbdiv = libhon), tabhon00.p
      TABHODETAIL: jointure TABHO, TABHOCOP par zon01 (zon01 = typhon)
      TABHORUB: (zon01 = typhon, zon02 = art-cle, zon03 = typefac-cle, zon04 = rub-cd, zon05 = ssrub-cd ou cdlib selon zon07 = "ANA" (tprub) ou autre, zon06 = cdFisc)
  TBCOR: table correspondance pour compta - lien TBCOR - TBCOR (zon01 = STRING(DtResUse-IN,"99/99/9999")-NoCttUse-IN, zon02 = "UL"-"01033", zon03 = "UL"-"01033", zon10 = STRING(TODAY), int01 = NoCttUse-IN, int02 = unite.noapp-ctrat.nocon, int03 = NoAppSlo-nobai), convmd00.p
  IMDIR: parametrage repertoire utilisateur immeuble (zon01 = NmUsrUse, zon02 = nomRepertoireDefaut), noreg00.p
  LBCLE: libelle des cles (zon01 = code, zon02 = libelle, Zon03 = CdActDef), genpclie.p, pcllbcle.p
  MEMID: (zon01 = user, zon02 = TpIdtEnc-IN, zon03 = STRING(NoIdtEnc-IN), zon04 = NoSesEnc), gesdossi_srv.p, gesinter_srv.p, visdolst_srv.p, visinter_srv.p, libprc10.i
  PACAT: chrono edition (int01 = sequence)
  EXDIR: parametrage repertoire utilisateur extraction (zon01 = user, zon02 = nomRepertoireDefaut)
  STFIC: répertoire de stockage des fichiers joints (zon01 = LbDirFic
  TIER2: Mise a jour des prélèvements automatiques  (mnt01), extavnat.p, pcltier2.p
  TBSBU: Paramétrage CABINET de l'édition du tableau de synthèse (comparatif budgétaire) (zon09, zon10 = "EXTRACPT") prmtbsbu.p, pcltbsbu.p
      TBSBURUB: (zon02 = cdTPECR, zon03 = rub-cd, zon04 = ssrub-cd, zon05 = LstFiscle, int01 = 1-0)
  SILOC: Edition comptes locataires (zon01 = sequence, zon02 = lbcol, zon03 = lscol), selcptlo.p
  SEL_COP_PV_AG:  sauvegarde de la sélection précédente de copropriétaires d'un immeuble
      (zon01 = STRING(NoCttUse)), int01 = norol, fgact)
  MDARC: Mode d'envoi par défaut des AR (), pclmdarc.p
  INSITU: (zon01 = cFluxInit, zon02 = cTraitementInit, zon03 = cLibelleFlux, int01 = sequence), is_gener.p,  is_param.w
          Paramètrage Mail: (zon01 = "0", zon02 = "0", zon03 = cExpediteur, zon04 = cDestinataire, zon05 = cSmtp)
  INSITU-RUB: (), is_param.w
  INSITU-HISTO: (zon01 = cFluxEncours, zon02 = cTraitementEnCours, zon03 = cLibelleFlux, int01 = sequence)
  BNP_MDM: (), mdmparam.w
  TRFAQUIT: transfert quittancement (), charg002.p
  DUPMDT: duplication de mandat(), dupimpor.p
  TITPA: Mise a jour du titre interbancaire de paiement (), pcldefco.p, pclprlco.p, pcltitpa.p, fparatip.w
  TRNTLOT: ordre affichage nature de role ------------------------------------------------------
  PGCOR: correspondances organismes sociaux pégase/MaGI (), adplsorg.p, pclpegaz.p, pclpgcor.p
  PZORG: (), adplsorg.p
  PAAUT: info authentification (), attass00.p
  DIFOR: Droit individuel Formation (paie), diform00.p, initdif.p, peracq00.p 
  RUBRIQUE: (), genficin.p
  MUTUE: parametrage client mutuelle (paie), mutuel00.p, mutuel01.p
  PREVO: parametrage client prevoyance (paie), prevoy00.p
  AUGPA: liste des rubrique pour calcul ajustement SMIC, prmrub00.p, sacpcv00.p, pclaugpa.p
  SCPCV: Salaire de référence et SMIC (Paie), sacpcv00.p
  CEN21: module century21 (), inicen21.p, pclcen21.p
  NTLOT: classement d'affichage pour les natures de lots (), inicen21.p, classnat.p
  PFBAI: categorie de bail (), inicen21.p, pclpfbai.p
      PFBA1
  PFBA1: categorie de habitation, commerce, entreprise, saisonnier, meublé (), inicen21.p
  CDORI: OrigineClient (), inicen21.p, pclcdori.p
  AFJPG: chemin complet programme affichage fichier JPG
  ANACP: Activation ou non des unités d'oeuvre (), pclanacp.p
  ANATX: Paramétrage Travaux - Corres Type travaux/Analytique (), pclanatx.p
  EDCRG: (), pclasmfe.p, pcldefma.p
  ASSGE: Assemblees generales (), pclassge.p
  RESOL: (), pclassge.p
  BAIPR: Paramétrage cabinet de la tache 'Bail proportionnel' (), pclbaipr.p
  BUDLO, BUDL1: budget locatif (), pclbudlo.p
  CDCAF: relations Résidence / CAF (), pclcdcaf.p
  CDESI: saisie du code ESI oui/non (), pclcdesi.p
  CDEVE: gestion des evenements (), pclcdeve.p
  CDUNI: Gestion des unités/libellés des unités d'oeuvre (), pclcduno.p
  CGACH: Paramétrage Mutations avec Charges à l'acheteur (), pclcgach.p
  RMBCO: Remboursement Copropriétaires (), pclcgach.p, pcldefco.p
  COSMO: Extraction Cosmo (), pclcosmo.p
  ACCRO:  (), pclcosmo.p, pclporta.p, gicron.p
  RUBDG: 
  HOSYN: honoraires de syndic (), pcldefco.p, pclhosyn.p
  CPSLO: (), pcldefco.p
  LBAPP: (), pcldefco.p
  TRXBU: (), pcldefco.p
  TPPER: Code periodicite des Charges de Copropriété (), pcldefco.p, pcltpper.p
  PRBUD: Modele de budget par defaut qui sera modifié a chaque changement de model afin de prendre toujours le dernier utilisé (), pcldefco.p
  TPARR: Mise a jour du type d'arrondi des appels de fonds (), pcldefco.p, pcltparr.p
  PRLCO: Mode de réglement coproprétaires (), pcldefco.p, pclprlco.p
  RGPMT: Regroupement rubriques (), pcldefco.p
  GRPHE: Graphe en secteurs (), pcldefco.p
  DOMDT: dossier mandat (), pcldefma.p
  DFASS: risques locatifs (), pcldfass.p
  DOLOC: Dossier Locataire (), pcldoloc.p
  DOMUT: Gestion des Dossier de Mutation (), pcldomut.p
  DTREN: Gestion des Droits Procédure de Renouvellement (), pcldtren.p
  RENOU: Gestion avec module "Procédure de Renouvellement" (), pclfgexp.p, pclrenou.p
      RENO1: parametrage des categories.
  ECSAB: Enquête charges CSAB (), pclecsab.p
  ODTRM: Mise a jour du code Gestion tr‚partition de terme (), pcledcrg.p, pclodtrm.p
  NVCRG: Edition Local ou Site Central des relevés proprio CRG (), pclnvcrg.p
  CLCRG: options du CRG (), pclnvcrg.p
  CRGDE: CRG Décalé (), pclnvcrg.p
  SVCRG: sauvegarde des anciennes valeurs (), pcledcrg.p
  EDIHO: edition de la comptabilisation des honoraires (), pclediho.p, honage00.p
  EDLSO: Interfaces pour EdlSoft (), pcledlso.p
  EQUIP: (), pclequip_srv.p
  EQUIPGI: lien avec ancien champ imble ou local (), pclequip_srv.p
  EXCPT: code Gestion de l'extra comptable dans les écritures de copro et reprise du solde(), pclexcpt.p
  FACAB: Facturation cabinet (), pclfacab.p
  FAVOR: Ne pas Faire apparaitre la barre des favoris (Par défaut visible), pclfavor.p
  FGEXP: Prolongation des baux après expiration (), pclfgexp.p
  FHONO: Forçage de l'option 'Edition factures honoraires' dans toutes les tâches Honoraires de gestion (), pclfhono.p
  FNAIM: Mise a jour des infos pour extraction FNAIM (), pclfnaim.p
  FOPOL: Formule de politesse(), pclfopol.p
  PRFRANX: Mise a jour des frais annexes de Gestion (), pclfranx.p
  FROFF: Parametre calcul des frais d'office (), pclfroff.p
  GAFAC: Mise a jour du calcul des garanties sur les factures entree/sortie locataire (), pclgafac.p
  GALER: Parametrage Gestion des alertes (), pclgaler.p 
  GERIE: Gestion RIE (), pclgerie.p
  GERNA: Parametre Gestion des trop perçus locataires (RNA) (), pclgerna.p
  GESDB: Mise a jour du code Gestion de la Rub. 760 dans le calcul de la CRDB (), pclgesdb.p
  GESTE: Extraction pour GESTEAM (), pclgeste.p
  GIPRT: Ouverture / Fermeture module GI - PRINT (), pclgiprt.p
  HISCG: Historique des cles de gerance (), pclhiscg.p
  hitac: (), pclhitac_srv.p
  HOLOQ: Honos locataire par le quittancement (), pclholoq.p
  IDBAT: Extraction idbat (), pclidbat.p
  INCHA: Mise a jour code integration des charges de copro. (), pclincha.p
  INDVS: Mise a jour des parametres par defaut de l'application "Indivisions successives" (), pclindvs.p
  ISF00: Parametre de l'intro et la formule de politesse pour les editions isf (), pclisf00.p,  pclisf01.p
  ISF01: Paramétrage de l'édition ISF (), pclisf01.p
  LBAPP: Gestion des libelles des appels de fond (), pcllbapp.p 
  MOBUL: Modules saisissables pour l'antériorité des bulletins (), pclmobul.p
  MOPAS: Parametrage client : Mot de passe (), pclmopas.p
  MTFAM: Parametrage Tri Famille/sous-famille (), pclmtfam.p
  MUTAG: Mutations de gérance faites par la copropriété (), pclmutag.p
  LBPIE: Gestion des pièces (), pclntpie.p   ????  NTPIE   ????
  OBSDF:  Choix de travailler avec un Observatoire par Defaut. => Non (Gestion Normale) / Oui (Observatoire 0), pclobsdf.p
  OPEDT: Lancement ecran Options d'édition des charges (), pclopedt.p
  STCMA: (), pclopgen.p
  OPGEN: paramètres généraux (zon01 = Mode d'affichage des listes de recherche (num/alpha)), pclopgen.p
  PAAAS: parametrage des attestation assedic (), pclpaaas.p
  PFMDT: Parametrage client: Type de mandat(), pclpfmdt.p
  PGCPT: Correspondance comptes comptables paie pégase/MaGI organismes sociaux(), pclpgcpt.p
  PORTA: Mise à jour des infos pour Exportation Portail Locatif (), pclporta.p
  AGFxx: xx=01-05, Gestion des parametres reporting AGF (), pclpragf.p
  PRBAI: Paramétrage prébail (), pclprbai.p
  PRLAU: Des prélèvements automatiques (), pclprlau.p
  PROVE: Module optionnel AGF Extraction Provexi (), pclprove.p
  PROVQ: Provisions comptables sur quittances et factures locataires (), pclprovq.p
  RBFRA: Rubriques à prendre en compte dans la base de calcul de la franchise (), pclrbfra.p
  REGIS: Gestion du registre des mandats (Loi Hoguet), pclregis.p
  RELOC: Paramétrage module optionnel AGF - (RE)LOCATIONS(), pclreloc.p
      RELOF
      RELOS: Signataires
  RELOH: liste des habilitations
  REVBA: Parametrage Révision à la baisse (), pclrevba.p
      RVCAC: code action révision RVCAC
  RFDOS: Paramètre client BUREAUTIQUE, Référencement dossier (), pclrfdos.p
  RFMAN: Refacturation manuelle des dépenses mandat: clé (), pclrfman.p 
  RGPRO: Régularisation des Provisions (), pclrgpro.p
  RUBML: libellés multiples autorisés pour une même rubrique loyer (), pclrubml.p
  SCASS: Parametre des Assemblees generales Porteurs de parts (), pclscass.p
  SEPA : bascule au mandat prelevt SEPA (obligatoire à partir de février 2014) (), pclsepa.p
  SIGLE: Code gestion des sigles (), pclsigle.p
  SIGTR: Paramètre client BUREAUTIQUE: Signalement automatique (), pclsigtr.p
  SIMUL: Gestion de l'archivage + édition lors de la simulation de la paie (), pclsimul.p
  SIPRO: situation professionnelle (), pclsipro.p
  STREQ: Parametrage client : Stockage des requetes (), pclstreq.p
  SVCTX: Répartition des services annexes (), pclsvctx.p
  TBRUB: Parametrage client: table de correspondance des  rubriques (), pcltbrub.p
  TFLOY: Tarif des Loyers Eurostudiome (), pcltfloy.p
  TIMEC: Mode de tarification timbres par défaut (), pcltimec.p
  TPBAC: Parametrage client : Bac imprimante (), pcltpbac.p
  TPBUR: Paramètre client BUREAUTIQUE: Dossier automatique (), pcltpbur.p
  TPIND: Type d'indexation de la revision du bail(), pcltpind.p
  TPTRA: type de traitement (), pcltptra.p
  TRCHL: critères de sélection des périodes de Charges Locatives à transférer (), pclrgpro.p, pcltrchl.p
  TRIAN: Lancement ecran Tri des rubriques analytiques (), pcltrian.p
  TXADD: code Taxe Additionnelle (), pcltxadd.p
  TXASS: Taux de calcul de l'assiette (), pcltxass.p
  TXEVO: Taux d'évolution annuel (), pcltxevo.p
  TXREI: Taux de réimputation (), pcltxrei.p
  XGARL: Module Optionnel: Extraction garantie loyer FNAIM (), pclxgarl.p
  NEWTIERS: activation/deactivation nouvelle gestion tiers (), actniter.p
  CORTVA20: GOSSELIN suite changement taux TVA on a recalculé à tort le HT pour conserver le TTC dans le quittancement à partir du 1er Janvier 2014, cortva20.p
      CORTVA20-04
  TXTVA7: Utilitaire de changement de la TVA 7% -> 10 % et/ou 19.6% -> 20% Pour un bail ou Pré-bail, txtva201.p
  TXTVA7: Utilitaire de changement de la TVA 5,5% -> 7%  Pour un bail ou Pré-bail, txtva701.p
  RQDIR: Sélection du type de requetes a lancer (), selreqgi.p, 
  RQDIR: Synthèse statistique par date d'affectation, synsta01.p
  RFLOC: Paramétrage Refacturation dépenses mandat au locataire (), prmmtrfl.p
  COMAG: commisions agence sur honoraires gerance (), comage00.p
  BARAG: honage00.p
  DRG00: Directions générales, gesdre00.p, gesdrg00.p, liedrg00.p
      DRGLI:
  EPISTOLA: Importation EPISTOLA, gesepi00.p
  RBQEN: Paramétrage des rubriques dans l'état quittancement et encaissements, faprqenc.w
  RBCRG: Paramétrage des rubriques et dépenses à éditer sur les CRG, farlvrub.w
  CEDCHQ: Parametrage chèques CEDRICOM, fparachq.w
  SANUM: , prcmsepa.i
  PACPS: compte de subrogation par défaut, tbbque2.i
  CONGE: , majsal.i
------------------------------------------------------------------------*/
using oerealm.magiToken.
using outils.outils.
block-level on error undo, throw.

class parametre.pclie.pclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}
    define public property giNumeroItem  as integer no-undo get. set.
    define public property isDbParameter as logical no-undo get. set.
    define public property rRowid        as rowid   no-undo get. set.
    define public property tppar     as character no-undo get. set.         // Code de paramètre
    define public property cddev     as character no-undo get. set.         // Code devise
    define public property fgact     as character no-undo get. set.         // Paramètre actif
    define public property int01     as int64     no-undo get. set.         // ?
    define public property int02     as int64     no-undo get. set.         // ?
    define public property int03     as int64     no-undo get. set.         // ?
    define public property int04     as int64     no-undo get. set.         // ?
    define public property int05     as int64     no-undo get. set.         // ?
    define public property lbdiv     as character no-undo get. set.         // Filler
    define public property lbdiv2    as character no-undo get. set.         // Filler
    define public property lbdiv3    as character no-undo get. set.         // Filler
    define public property mnt01     as decimal   no-undo get. set.         // Montant
    define public property mnt01-dev as decimal   no-undo get. set.         // Montant-devise
    define public property mnt02     as decimal   no-undo get. set.         // Montant
    define public property mnt02-dev as decimal   no-undo get. set.         // Montant-devise
    define public property mnt03     as decimal   no-undo get. set.         // Montant
    define public property mnt03-dev as decimal   no-undo get. set.         // Montant-devise
    define public property mnt04     as decimal   no-undo get. set.         // Montant
    define public property mnt04-dev as decimal   no-undo get. set.         // Montant-devise
    define public property mnt05     as decimal   no-undo get. set.         // Montant
    define public property mnt05-dev as decimal   no-undo get. set.         // Montant-devise
    define public property tau01     as decimal   no-undo get. set.         // Taux
    define public property tau02     as decimal   no-undo get. set.         // Taux
    define public property tau03     as decimal   no-undo get. set.         // Taux
    define public property tau04     as decimal   no-undo get. set.         // Taux
    define public property tau05     as decimal   no-undo get. set.         // Taux
    define public property zon01     as character no-undo get. set.         // Zone 1 du paramètrage
    define public property zon02     as character no-undo get. set.         // Zone 2 du paramètrage
    define public property zon03     as character no-undo get. set.         // Zone 3 du paramètrage
    define public property zon04     as character no-undo get. set.         // Zone 4 du paramètrage
    define public property zon05     as character no-undo get. set.         // Zone 5 du paramètrage
    define public property zon06     as character no-undo get. set.         // Zone 6 du paramètrage
    define public property zon07     as character no-undo get. set.         // Zone 7 du paramètrage
    define public property zon08     as character no-undo get. set.         // Zone 8 du paramètrage
    define public property zon09     as character no-undo get. set.         // Zone 9 du paramètrage
    define public property zon10     as character no-undo get. set.         // Zone 10 du paramètrage
    define public property cdcsy     as character no-undo get. private set. // Code utilisateur de generation du record
    define public property cdmsy     as character no-undo get. private set. // Code utilisateur de modification du record
    define public property dtcsy     as date      no-undo get. private set. // Date de generation du record
    define public property dtmsy     as date      no-undo get. private set. // Date de modification du record
    define public property hecsy     as integer   no-undo get. private set. // Heure de generation du record
    define public property hemsy     as integer   no-undo get. private set. // Heure de modification du record

    constructor public pclie():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
    end constructor.
    constructor public pclie(pcTppar as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        {application/include/glbsepar.i}
        reload(pcTppar).
    end constructor.
    constructor public pclie(pcTppar as character, pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTppar, pcZon01).
    end constructor.
    constructor public pclie(pcTppar as character, pcZon01 as character, pcZon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTppar, pcZon01, pcZon02).
    end constructor.
    constructor public pclie(pcTppar as character, pcZon01 as character, pcZon02 as character, pcZon03 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTppar, pcZon01, pcZon02, pcZon03).
    end constructor.
    constructor public pclie(pcTppar as character, pcZon01 as character, pcZon02 as character, pcZon03 as character, pcZon04 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTppar, pcZon01, pcZon02, pcZon03, pcZon04).
    end constructor.
    constructor public pclie(pcTppar as character, pcZon01 as character, pcZon02 as character, pcZon03 as character, plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTppar, pcZon01, pcZon02, pcZon03, plActif).
    end constructor.

    method public void reload(pcTppar as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.

        initProperty().
        this-object:tppar = pcTppar.
        for first pclie no-lock
            where pclie.tppar = pcTppar:
            assignTable2property(buffer pclie).
        end.
    end method.
    method public void reload(pcTppar as character, pcZon01 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.

        initProperty().
        assign
            this-object:tppar = pcTppar
            this-object:zon01 = pcZon01
        .
        for first pclie no-lock
            where pclie.tppar = pcTppar
              and pclie.zon01 = pcZon01:
            assignTable2property(buffer pclie).
        end.
    end method.
    method public void reloadDynamique(pcWhereClause as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        
        initProperty().

        buffer pclie:find-first(pcWhereClause , no-lock) no-error.
        if buffer pclie:available then assignTable2property(buffer pclie).
    end method.
    method public void reload(pcTppar as character, pcZon01 as character, pcZon02 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.

        initProperty().
        assign
            tppar = pcTppar
            zon01 = pcZon01
            zon02 = pcZon02
        .
        if pcZon01 = ?                   // index sur zon02
        then for first pclie no-lock
            where pclie.tppar = pcTppar
              and pclie.zon02 = pcZon02:
            assignTable2property(buffer pclie).
        end.
        else for first pclie no-lock
            where pclie.tppar = pcTppar
              and pclie.zon01 = pcZon01
              and pclie.zon02 = pcZon02:
            assignTable2property(buffer pclie).
        end.
    end method.
    method public void reload(pcTppar as character, pcZon01 as character, pcZon02 as character, pcZon03 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.

        initProperty().
        assign
            tppar = pcTppar
            zon01 = pcZon01
            zon02 = pcZon02
            zon03 = pcZon03
        .
        if pcZon01 = ? and pcZon02 = ?
        then for first pclie no-lock
            where pclie.tppar = pcTppar
              and pclie.zon03 = pcZon03:
            assignTable2property(buffer pclie).
        end.
        if pcZon01 = ?                          // index sur zon02
        then for first pclie no-lock
            where pclie.tppar = pcTppar
              and pclie.zon02 = pcZon02
              and pclie.zon03 = pcZon03:
            assignTable2property(buffer pclie).
        end.
        else for first pclie no-lock            // index sur zon01
            where pclie.tppar = pcTppar
              and pclie.zon01 = pcZon01
              and (if pcZon02 = ? then true else pclie.zon02 = pcZon02)
              and pclie.zon03 = pcZon03:
            assignTable2property(buffer pclie).
        end.
    end method.
    method public void reload(pcTppar as character, pcZon01 as character, pcZon02 as character, pcZon03 as character, pcZon04 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcWhereClause as character no-undo. 
        define buffer pclie for pclie.
        define query qrPclie for pclie.

        initProperty().
        assign
            tppar         = pcTppar
            zon01         = pcZon01
            zon02         = pcZon02
            zon03         = pcZon03
            zon04         = pcZon04
            vcWhereClause = substitute(' where pclie.tppar = "&1"&2&3&4&5', 
                                       pcTppar,
                                       if zon01 > "" then substitute(' and pclie.zon01 = "&1"', zon01) else '',
                                       if zon02 > "" then substitute(' and pclie.zon02 = "&1"', zon02) else '',
                                       if zon03 > "" then substitute(' and pclie.zon03 = "&1"', zon03) else '',
                                       if zon04 > "" then substitute(' and pclie.zon04 = "&1"', zon04) else '').
        query qrPclie:query-prepare("for each pclie no-lock" + vcWhereClause). 
        query qrPclie:query-open.
        get first qrPclie.
        if available pclie then assignTable2property(buffer pclie).
        close query qrPclie. 
        
    end method.    
    method public void reload(pcTppar as character, pcZon01 as character, pcZon02 as character, pcZon03 as character, plActif as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcActif as character no-undo.
        define buffer pclie for pclie.

        initProperty().
        assign
            tppar   = pcTppar
            zon01   = pcZon01
            zon02   = pcZon02
            zon03   = pcZon03
            fgact   = trim(string(plActif, 'YES/NO'))
            vcactif = fgact
        .
        if pcZon01 = ? and pcZon02 = ?
        then for first pclie no-lock
            where pclie.tppar = pcTppar
              and pclie.zon03 = pcZon03
              and pclie.fgact = vcactif:
            assignTable2property(buffer pclie).
        end.
        if pcZon01 = ?                          // index sur zon02
        then for first pclie no-lock
            where pclie.tppar = pcTppar
              and pclie.zon02 = pcZon02
              and pclie.zon03 = pcZon03
              and pclie.fgact = vcactif:
            assignTable2property(buffer pclie).
        end.
        else for first pclie no-lock            // index sur zon01
            where pclie.tppar = pcTppar
              and pclie.zon01 = pcZon01
              and (if pcZon02 = ? then true else pclie.zon02 = pcZon02)
              and pclie.zon03 = pcZon03
              and pclie.fgact = vcactif:
            assignTable2property(buffer pclie).
        end.
    end method.
    method public void initProperty():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            this-object:isDbParameter = false
            rRowid    = ?
            cdcsy     = ""
            cddev     = ""
            cdmsy     = ""
            dtcsy     = ?
            dtmsy     = ?
            fgact     = ""
            hecsy     = 0
            hemsy     = 0
            int01     = 0
            int02     = 0
            int03     = 0
            int04     = 0
            int05     = 0
            lbdiv     = ""
            lbdiv2    = ""
            lbdiv3    = ""
            mnt01     = 0
            mnt01-dev = 0
            mnt02     = 0
            mnt02-dev = 0
            mnt03     = 0
            mnt03-dev = 0
            mnt04     = 0
            mnt04-dev = 0
            mnt05     = 0
            mnt05-dev = 0
            tau01     = 0
            tau02     = 0
            tau03     = 0
            tau04     = 0
            tau05     = 0
            tppar     = ""
            zon01     = ""
            zon02     = ""
            zon03     = ""
            zon04     = ""
            zon05     = ""
            zon06     = ""
            zon07     = ""
            zon08     = ""
            zon09     = ""
            zon10     = ""
        .
    end method.
    method public void assignTable2property(buffer pclie for pclie):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            isDbParameter = true
            rRowid        = rowid(pclie)
            cdcsy     = pclie.cdcsy
            cddev     = pclie.cddev
            cdmsy     = pclie.cdmsy
            dtcsy     = pclie.dtcsy
            dtmsy     = pclie.dtmsy
            fgact     = pclie.fgact
            hecsy     = pclie.hecsy
            hemsy     = pclie.hemsy
            int01     = pclie.int01
            int02     = pclie.int02
            int03     = pclie.int03
            int04     = pclie.int04
            int05     = pclie.int05
            lbdiv     = pclie.lbdiv
            lbdiv2    = pclie.lbdiv2
            lbdiv3    = pclie.lbdiv3
            mnt01     = pclie.mnt01
            mnt01-dev = pclie.mnt01-dev
            mnt02     = pclie.mnt02
            mnt02-dev = pclie.mnt02-dev
            mnt03     = pclie.mnt03
            mnt03-dev = pclie.mnt03-dev
            mnt04     = pclie.mnt04
            mnt04-dev = pclie.mnt04-dev
            mnt05     = pclie.mnt05
            mnt05-dev = pclie.mnt05-dev
            tau01     = pclie.tau01
            tau02     = pclie.tau02
            tau03     = pclie.tau03
            tau04     = pclie.tau04
            tau05     = pclie.tau05
            tppar     = pclie.tppar
            zon01     = pclie.zon01
            zon02     = pclie.zon02
            zon03     = pclie.zon03
            zon04     = pclie.zon04
            zon05     = pclie.zon05
            zon06     = pclie.zon06
            zon07     = pclie.zon07
            zon08     = pclie.zon08
            zon09     = pclie.zon09
            zon10     = pclie.zon10
        .
    end method.
    method private void assignProperty2Table(buffer pclie for pclie):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
           pclie.cddev     = this-object:cddev
           pclie.fgact     = this-object:fgact
           pclie.int01     = this-object:int01
           pclie.int02     = this-object:int02
           pclie.int03     = this-object:int03
           pclie.int04     = this-object:int04
           pclie.int05     = this-object:int05
           pclie.lbdiv     = this-object:lbdiv
           pclie.lbdiv2    = this-object:lbdiv2
           pclie.lbdiv3    = this-object:lbdiv3
           pclie.mnt01     = this-object:mnt01
           pclie.mnt01-dev = this-object:mnt01-dev
           pclie.mnt02     = this-object:mnt02
           pclie.mnt02-dev = this-object:mnt02-dev
           pclie.mnt03     = this-object:mnt03
           pclie.mnt03-dev = this-object:mnt03-dev
           pclie.mnt04     = this-object:mnt04
           pclie.mnt04-dev = this-object:mnt04-dev
           pclie.mnt05     = this-object:mnt05
           pclie.mnt05-dev = this-object:mnt05-dev
           pclie.tau01     = this-object:tau01
           pclie.tau02     = this-object:tau02
           pclie.tau03     = this-object:tau03
           pclie.tau04     = this-object:tau04
           pclie.tau05     = this-object:tau05
           pclie.tppar     = this-object:tppar
           pclie.zon01     = this-object:zon01
           pclie.zon02     = this-object:zon02
           pclie.zon03     = this-object:zon03
           pclie.zon04     = this-object:zon04
           pclie.zon05     = this-object:zon05
           pclie.zon06     = this-object:zon06
           pclie.zon07     = this-object:zon07
           pclie.zon08     = this-object:zon08
           pclie.zon09     = this-object:zon09
           pclie.zon10     = this-object:zon10
        .
    end method.

    method public integer getComboParametre(pcNomCombo as character, pcWhere as character, pcIdent as character, pcField as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: pcwhere est le complément de la clause "where pclie.tppar='xxxxx'"
             par exemple 'and pclie.zon05 = "yyyy"'
    Notes  : Attention, pour l'instant qu'avec des buffer-field(pcField) et buffer-field(pcIdent) en character
    ------------------------------------------------------------------------------*/
        define variable vhQuery  as handle no-undo.
        define variable vhBuffer as handle no-undo.
        define buffer pclie for pclie.

        for last ttCombo where ttCombo.cNomCombo = pcNomCombo: giNumeroItem = ttCombo.iSeqId. end.
        vhBuffer = buffer pclie:handle.
        create query vhQuery.
        vhQuery:set-buffers(vhBuffer).
        vhQuery:query-prepare(substitute("for each pclie fields (&3 &4) no-lock where pclie.tppar = '&1' &2 by &3", tppar, pcWhere, pcField, pcIdent)). // attention, tppar = propriété objet
        vhQuery:query-open().
        repeat:
            vhQuery:get-next().
            if vhQuery:query-off-end then leave.
            createttCombo(pcNomCombo, string(vhBuffer:buffer-field(pcIdent):buffer-value()), trim(string(vhBuffer:buffer-field(pcField):buffer-value()))).
        end.
        vhQuery:query-close().
        delete object vhQuery.
        return giNumeroItem.
    end method.
    method public integer getComboParametre(pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.

        for last ttCombo where ttCombo.cNomCombo = pcNomCombo: giNumeroItem = ttCombo.iSeqId. end.
        for each pclie fields(zon01 zon02) no-lock
            where pclie.tppar = this-object:tppar
               by pclie.int01:
            createttCombo(pcNomCombo, pclie.zon01, trim(pclie.zon02)).
        end.
        return giNumeroItem.
    end method.
    method public void getttParam(table-handle phttParam):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhttBuffer as handle no-undo.
        define buffer pclie for pclie.

        vhttBuffer = phttParam:default-buffer-handle.
        for each pclie no-lock
            where pclie.tppar = this-object:tppar:
            vhttBuffer:buffer-create().
            outils:copyValidField(buffer pclie:handle, vhttBuffer).  // copy table physique vers temp-table
        end.
    end method.

    method public void createttCombo(pcNom as character, pcCode as character, pcLibelle as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttcombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = pcNom
            ttCombo.cCode     = trim(pcCode)
            ttCombo.cLibelle  = trim(pcLibelle)
        .
    end method.
    method public integer creationttCombo(pcNomCombo as character, pcCode as character, pcLibelle as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  : service
    ------------------------------------------------------------------------------*/
        for last ttCombo where ttCombo.cNomCombo = pcNomCombo: giNumeroItem = ttCombo.iSeqId. end.
        create ttCombo.
        assign
            giNumeroItem             = giNumeroItem + 1
            ttcombo.iSeqId           = giNumeroItem
            ttCombo.cNomCombo        = pcNomCombo
            ttCombo.cCode            = trim(pcCode)
            ttCombo.cLibelle         = trim(pcLibelle)
        .
    end method.

    method public void create():
        /*------------------------------------------------------------------------------
        Purpose: Create one record
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        if isDbParameter then return.

        do on error undo, return:
            create pclie.
            assignProperty2Table(buffer pclie).
            assign
                pclie.cdcsy = if valid-object(MagiToken:mtoken) then MagiToken:mToken:cUser else "ins"
                pclie.dtcsy = today
                pclie.hecsy = mtime
                pclie.cdmsy = pclie.cdcsy
                pclie.dtmsy = pclie.dtcsy
                pclie.hemsy = pclie.hecsy
            .
        end.
        assign
            this-object:cdcsy         = pclie.cdcsy 
            this-object:dtcsy         = pclie.dtcsy
            this-object:hecsy         = pclie.hecsy
            this-object:cdmsy         = pclie.cdmsy 
            this-object:dtmsy         = pclie.dtmsy
            this-object:hemsy         = pclie.hemsy
            this-object:isDbParameter = true
            this-object:rRowid        = rowid(pclie)
        .
    end method.

    method public void update():
        /*------------------------------------------------------------------------------
        Purpose: Update one record
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        if this-object:isDbParameter
        then for first pclie exclusive-lock
            where rowid(pclie) = this-object:rRowid: 
            assignProperty2Table(buffer pclie).
            assign
                pclie.cdmsy       = if valid-object(MagiToken:mtoken) then MagiToken:mToken:cUser else "ins"
                pclie.dtmsy       = today
                pclie.hemsy       = mtime
                this-object:cdmsy = pclie.cdmsy 
                this-object:dtmsy = pclie.dtmsy
                this-object:hemsy = pclie.hemsy
            .
        end.
    end method.

    method public void delete():
        /*------------------------------------------------------------------------------
        Purpose: delete a record
        Notes: volontairement pas de gestion d'erreur.
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        if this-object:isDbParameter
        then do transaction on error undo, return.
            for first pclie exclusive-lock
                where rowid(pclie) = this-object:rRowid:
                delete pclie.
            end.
            assign
                this-object:isDbParameter = false
                this-object:rRowid        = ?
            .
        end.
    end method.
    method public logical isOuvert():
        /*------------------------------------------------------------------------------
        Purpose: 
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:fgact = "yes".
    end method.

    destructor public pclie( ):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
    end destructor.

end class.
