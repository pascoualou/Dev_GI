/*------------------------------------------------------------------------
File        : tacheCrg.p
Purpose     : tache CRG
Author(s)   : OFA  2017/10/05
Notes       : a partir de adb/tach/prmobstd.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/codePeriode.i}
{preprocesseur/mode2Reglement.i}

&SCOPED-DEFINE TYPECRG-Standard         "00002"
&SCOPED-DEFINE TYPECRG-Libre            "00003"

using parametre.pclie.pclie.
using parametre.pclie.parametrageEditionCRG.
using parametre.syspg.syspg.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tache.i}
{tache/include/tacheCrg.i}
{parametre/cabinet/gerance/include/paramCrg.i}
{application/include/combo.i}
{application/include/error.i}
{cadb/include/expweb.i}  /* f_ctratactiv  f_ctrat_tiers_actif */

define variable giNumeroAhistCrgCree    as integer   no-undo init 0.

function debutPeriodeCrg returns logical
    (piPremierMoisDeLaPeriode as integer, piNombreMoisDansLaPeriode as integer) forward.

function existeEcritures returns logical private
    ( piNumeroMandat as integer ) forward.

function existeEcrituresMois returns logical private
    (piNumeroMandat as integer, pdaDateDebut as date, pdaDateFin as date  ) forward.


procedure creationHistoriqueCrg private:
    /*------------------------------------------------------------------------------
     Purpose: Création du "premier" (en principe) enregistrement de ahistcrg uniquement lors du passage de ??? à "libre".
              Dans ahistcrg ne sont présents que les crg issus du traitement en local
     Notes: ancienne procedure cre_ahistcrg_libre
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroSociete          as integer no-undo.
    define input parameter piNumeroMandat           as integer no-undo.
    define input parameter pcCompteMandant          as character no-undo.
    define input parameter plSilencieux             as logical no-undo.
    define output parameter pdaDateFinDernierCrg    as date no-undo init ?.

    define variable vdaDateDebutCrg            as date      no-undo.
    define variable vdaDateFinCrg              as date      no-undo.
    define variable vdaDatefin                 as date      no-undo.
    define variable vdaDateDebut               as date      no-undo.
    define variable vdaResponsableComptable    as date      no-undo.
    define variable cCodeRetour                as character no-undo.
    define variable cListePeriode              as character no-undo.
    define variable viNumeroCrg                as integer   no-undo.
    define variable vhproc                     as handle    no-undo.

    define buffer ietab         for ietab.
    define buffer tache         for tache.
    define buffer agest         for agest.
    define buffer suivtrf       for suivtrf.
    define buffer ahistcrg      for ahistcrg.
    define buffer vbahistcrg    for ahistcrg.

    //S'il y a déjà un historique de CRG, pas besoin d'en créer un nouveau
    if can-find(first ahistcrg no-lock
        where ahistcrg.soc-cd  = piNumeroSociete
        and ahistcrg.etab-cd = piNumeroMandat
        and ahistcrg.cpt-cd   = pcCompteMandant) then return.

    find first  ietab   no-lock
        where   ietab.soc-cd = piNumeroSociete
        and     ietab.etab-cd = piNumeroMandat
        no-error.

    find first  tache   no-lock
        where   tache.tpcon = "01030"
        and     tache.nocon = piNumeroMandat
        and     tache.tptac = "04008"
        no-error.


    /* Recherche des date du crg à traiter (selon la date du gestionnaire) */
    run mandat/outilMandat.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run chargePeriodesMandat in vhproc  (piNumeroMandat,
                                         mToken:daDateFinRespGerance,
                                         "",
                                         output cCodeRetour,
                                         output cListePeriode).
    run destroy in vhproc.

    if cCodeRetour = "000" then do:
        assign
            vdaDateDebutCrg = date(integer( substring(entry(1,cListePeriode,"@"), 3, 2)),     /** Mois **/
                                  integer( substring(entry(1,cListePeriode,"@"), 1, 2)),     /** jour **/
                                  integer( substring(entry(1,cListePeriode,"@"), 5, 4)))    /** Annee **/
            vdaDateFinCrg   = date(integer( substring(entry(2,cListePeriode,"@"), 3, 2)),     /** Mois **/
                                  integer( substring(entry(2,cListePeriode,"@"), 1, 2)),     /** jour **/
                                  integer( substring(entry(2,cListePeriode,"@"), 5, 4)))    /** Annee **/
            /* dernier crg site central traite = date de debut - 1 */
            vdaDatefin  = vdaDateDebutCrg - 1
            .
        for first  agest    no-lock
            where   agest.soc-cd = piNumeroSociete
            and     agest.gest-cle = ietab.gest-cle,
            first suivtrf no-lock
                where suivtrf.soc-cd = piNumeroSociete
                and suivtrf.cdtrait = "CPTE"
                and suivtrf.gest-cle = agest.gest-cle
                and suivtrf.moiscpt = integer(string(month(vdaDateDebutCrg - 1),"99")  + string(year(vdaDateDebutCrg - 1),"9999"))
                :
            vdaDatefin = suivtrf.jcretrf.
        end.
    end.
    else assign
            vdaDateDebutCrg = ?
            vdaDateFinCrg   = ?
            vdaDatefin = add-interval(mToken:daDateFinRespGerance,-1,"MONTH")
            .

    /* recherche si ahistcrg > date tout proprios confondus */
    find first ahistcrg no-lock
        where ahistcrg.soc-cd  = piNumeroSociete
        and   ahistcrg.etab-cd = piNumeroMandat
        and   ahistcrg.dtfin >= vdaDatefin
        use-index histcrg-dtfin
        no-error.
    if not available ahistcrg
    then
    do :
        /* Date de début */
        for last vbahistcrg no-lock
            where vbahistcrg.soc-cd  = piNumeroSociete
            and   vbahistcrg.etab-cd = piNumeroMandat
            and   vbahistcrg.dtfin < vdaDatefin
            use-index histcrg-dtfin
            :
            assign
                vdaDateDebut = vbahistcrg.dtfin + 1
                viNumeroCrg  = vbahistcrg.num-crg + 1
                .
        end.
    end.
    else
        assign
            vdaDateDebut = 1/1/1901
            viNumeroCrg = 1
            .

    create ahistcrg.
    assign
        ahistcrg.soc-cd         = piNumeroSociete
        ahistcrg.etab-cd        = piNumeroMandat
        ahistcrg.cpt-cd         = pcCompteMandant
        ahistcrg.num-crg        = viNumeroCrg /*1*/
        ahistcrg.dtdeb          = vdaDateDebut
        ahistcrg.dtfin          = vdaDatefin
        ahistcrg.fg-valid       = true
        ahistcrg.dacrea         = today
        ahistcrg.usrid          = "CRG LIBRE"
        ahistcrg.mt-crg         = 0
        /* Indicateur de creation de ahistcrg */
        giNumeroAhistCrgCree    = viNumeroCrg
        pdaDateFinDernierCrg    = vdaDatefin
        .
    run miseAJourEcritures(input piNumeroSociete,input piNumeroMandat, input vdaDatefin, input viNumeroCrg).

    /* Réajustement en fonction de ce qui se trouve dans ahistcrg */
    for last ahistcrg no-lock
       where ahistcrg.soc-cd  = piNumeroSociete
       and   ahistcrg.etab-cd = piNumeroMandat
       use-index histcrg-dtfin:
        pdaDateFinDernierCrg = max(vdaDatefin,ahistcrg.dtfin).
    end.


end procedure.

procedure initTacheCrg:
    /*------------------------------------------------------------------------------
     Purpose: Initialisation de la tâche CRG à partir des paramètres client
     Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as integer no-undo.
    define input parameter pcTypeTraitement as character no-undo.
    define output parameter table for ttTacheCrg.

    define variable vhproc as handle no-undo.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run getParamCrg in vhproc (output table ttParamCrg by-reference).
    run destroy in vhproc.

    for first ctrat no-lock                                             //recherche mandat
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
        and ctrat.nocon = piNumeroMandat,
        first  intnt no-lock
        where   intnt.tpidt = {&TYPEROLE-mandant}
        and     intnt.tpcon = ctrat.tpcon
        and     intnt.nocon = ctrat.nocon
        :

        create ttTacheCrg.
        buffer-copy ttParamCrg to ttTacheCrg
            assign
            ttTacheCrg.CRUD           = if pcTypeTraitement = "INITIALISATION" then 'R' else 'C'
            ttTacheCrg.cTypeContrat   =  {&TYPECONTRAT-mandat2Gerance}
            ttTacheCrg.iNumeroContrat = piNumeroMandat
            ttTacheCrg.cCodeTypeRole  = intnt.tpidt
            ttTacheCrg.iNumeroRole    = intnt.noidt
            ttTacheCrg.cTypeTache     = {&TYPETACHE-compteRenduGestion}
            ttTacheCrg.lIndivision    = (ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision})
            ttTacheCrg.daActivation   = ctrat.dtdeb
            .
    end.
end procedure.

procedure miseAJourCrgLibre private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.

    define variable cTypeCRG as character no-undo.
    define variable dTmp     as date      no-undo.

    define buffer csscpt for csscpt.

    /* Génération d'un "enregistrement de départ" pour chaque mandant du mandat */
    for each  csscpt no-lock
        where csscpt.soc-cd     = integer(mToken:cRefGerance)
        and   csscpt.etab-cd    = piNumeroMandat
        and   csscpt.sscoll-cle = "P"
        :
        run creationHistoriqueCrg(csscpt.soc-cd,csscpt.etab-cd,csscpt.cpt-cd,no,output dTmp).
    end.


end procedure.

procedure miseAJourEcritures private:
    /*------------------------------------------------------------------------------
     Purpose: Lors de l'initialisation des CRG libres, on crée un ahistcrg. Il faut donc initialiser
       également le numéro de CRG stocké dans les écritures afin de ne pas reprendre celles
       qui ont déjà été traitées dans le CRG précédent

     Notes: Ancienne procedure MajCecrln
    ------------------------------------------------------------------------------*/

    define input parameter piNumeroSociete  as integer no-undo.
    define input parameter piNumeroMandat   as integer no-undo.
    define input parameter pdaDateFin       as date      no-undo.
    define input parameter piNumeroCrg      as integer   no-undo.

    define buffer ietab   for ietab.
    define buffer iprd    for iprd.
    define buffer cecrln  for cecrln.
    define buffer bcecrln for cecrln.
    define buffer cecrsai for cecrsai.

    for first ietab no-lock
        where ietab.soc-cd = piNumeroSociete
        and   ietab.etab-cd = piNumeroMandat,
        each  iprd of ietab no-lock
        where iprd.dadebprd >= ietab.dadebex1
        and   iprd.dadebprd < pdaDateFin,
        each cecrln of iprd no-lock,
        first cecrsai no-lock
        where cecrsai.soc-cd    = cecrln.soc-cd
        and   cecrsai.etab-cd   = cecrln.mandat-cd
        and   cecrsai.jou-cd    = cecrln.jou-cd
        and   cecrsai.prd-cd    = cecrln.mandat-prd-cd
        and   cecrsai.prd-num   = cecrln.mandat-prd-num
        and   cecrsai.piece-int = cecrln.piece-int
        :
        if cecrsai.dadoss <= pdaDateFin then
            for first bcecrln exclusive-lock
                where rowid(bcecrln) = rowid(cecrln):
                bcecrln.num-crg = piNumeroCrg.
            end.
    end.


end procedure.

procedure miseAJourTableTache private:
    /*------------------------------------------------------------------------------
     Purpose: Mise à jour de la table tache à partir du dataset
     Notes:
         @param pcCrud Type de mise à jour CRUD
         @param ttTacheCrg buffer du dataset de la tache CRG
    ------------------------------------------------------------------------------*/

    define input parameter  pcCrud as character no-undo.
    define parameter buffer ttTacheCrg for ttTacheCrg.

    define variable vhTache as handle  no-undo.
    define variable vlErreur as logical no-undo.

    define buffer tache         for tache.
    define buffer vbtacheprov   for tache.
    define buffer ctrat         for ctrat.
    define buffer vbctrat       for ctrat.
    define buffer vbtache       for tache.
    define buffer vbttTache     for ttTache.
    define buffer intnt         for intnt.

    empty temp-table ttTache.
    create ttTache.
    assign
        ttTache.noita       = ttTacheCrg.iNumeroTache
        ttTache.tpcon       = ttTacheCrg.cTypeContrat
        ttTache.nocon       = ttTacheCrg.iNumeroContrat
        ttTache.tptac       = ttTacheCrg.cTypeTache
        ttTache.notac       = ttTacheCrg.iChronoTache
        ttTache.dtdeb       = ttTacheCrg.daActivation
        ttTache.ntges       = ttTacheCrg.cCodePresentationCrg
        ttTache.pdges       = ttTacheCrg.cCodePeriodicite
        ttTache.tpges       = string(ttTacheCrg.lPresentationDetailCalculHono,"00001/00002")
        /*ttTache.dcreg       = ttTacheCrg.cCodeMode2Traitement*/ //Obsolète
        ttTache.duree       = ttTacheCrg.iBordereauConcierge
        ttTache.pdreg       = string(ttTacheCrg.lRepartitionTerme,"00001/00002")
        ttTache.utreg       = ttTacheCrg.cCodeTypeEdition
        ttTache.dossier     = ttTacheCrg.cCodeScenarioParamRubCRG123
        ttTache.cdhon       = ttTacheCrg.cCodeTraitementAvisEcheance
        ttTache.etqenergie  = string(ttTacheCrg.lTriReleveQuittParBat,"00001/00002")
        ttTache.cdreg       = string(ttTacheCrg.iNumeroRoleGardien)
        ttTache.ntreg       = ttTacheCrg.cCodeMode2Reglement
        ttTache.tpmadisp    = ttTacheCrg.cCodeModeEnvoi
        ttTache.lbdiv2      = ttTacheCrg.cCodeEditionFacture
        ttTache.lbdiv3      = ttTacheCrg.cListeDocuments
        ttTache.lbdiv       = substitute("&1#&2#&3#&4#&5",string(ttTacheCrg.lCrgLibre,"00003/00002"), entry(2,ttTache.lbdiv,"#"), entry(3,ttTache.lbdiv,"#"), ttTacheCrg.cCodeLieuEditionDocument, string(ttTacheCrg.lEditionSituationLocataire,"00001/00002"))
        ttTache.tpfin       = ttTacheCrg.cCodeScenarioPresentation
        ttTache.mtreg       = integer(string(ttTacheCrg.lEditionHtTva,"00001/00002"))
        ttTache.fgsimplifie = ttTacheCrg.lCrgSimplifie
        ttTache.fgrev       = ttTacheCrg.lRecapitulatifAnnuel

        ttTache.CRUD        = pcCrud
        ttTache.dtTimestamp = ttTacheCrg.dtTimestamp
        ttTache.rRowid      = ttTacheCrg.rRowid
        .

    if pcCrud = "C"
    then for first ctrat no-lock
             where ctrat.tpcon = ttTacheCrg.cTypeContrat
               and ctrat.nocon = ttTacheCrg.iNumeroContrat:
        ttTache.dtfin = ctrat.dtfin.
    end.

    for last vbtacheprov no-lock
        where vbtacheprov.tpcon = ttTacheCrg.cTypeContrat
        and   vbtacheprov.nocon = ttTacheCrg.iNumeroContrat
        and   vbtacheprov.tptac = {&TYPETACHE-provisionPermanente}
        :
        create ttTache.
        buffer-copy vbtacheprov to ttTache
            assign
            ttTache.dtTimestamp = datetime(vbtacheprov.dtmsy, vbtacheprov.hemsy)
            ttTache.CRUD        = pcCrud
            ttTache.rRowid      = rowid(vbtacheprov)
            ttTache.mtreg       = ttTacheCrg.dMontantProvisionPermanente
            ttTache.lbdiv       = ttTacheCrg.cLibelleProvisionPermanente
            .
    end.
    /*--> Duplication de la tache CRG sur l'ensemble des taches CRG du mandant */
    /* SY 0217/0117 pour les autres mandat de même type (Location ou gestion classique) */
    for first vbctrat no-lock
        where vbctrat.tpcon = ttTacheCrg.cTypeContrat
          and vbctrat.nocon = ttTacheCrg.iNumeroContrat
      , first tache no-lock
        where tache.tptac = ttTacheCrg.cTypeTache
          and tache.tpcon = ttTacheCrg.cTypeContrat
          and tache.nocon = ttTacheCrg.iNumeroContrat
      , each intnt  no-lock
        where intnt.tpcon = tache.tpcon
          and intnt.tpidt = ttTacheCrg.cCodeTypeRole
          and intnt.noidt = ttTacheCrg.iNumeroRole
          and intnt.nocon ne tache.nocon
      , first ctrat no-lock
        where ctrat.tpcon  = intnt.tpcon
          and ctrat.nocon  = intnt.nocon
          and ctrat.fgfloy = (if available vbctrat then vbctrat.fgfloy else false)
      , last vbtache no-lock
        where vbtache.tpcon = intnt.tpcon
          and vbtache.nocon = intnt.nocon
          and vbtache.tptac = tache.tptac:
        create vbttTache.
        //Maj de vbtache à partir de tache
        buffer-copy vbtache to vbttTache
            assign
                vbttTache.dtTimestamp = datetime(vbtache.dtmsy, vbtache.hemsy)
                vbttTache.CRUD        = pcCrud
                vbttTache.rRowid      = rowid(vbtache)
                vbttTache.lbdiv       = tttache.lbdiv       /*CRG décalés#Jour début#Jour fin#Edition Micro/Site central#Edition situ loc*/
                vbttTache.lbdiv2      = tttache.lbdiv2      /*Edition factures honoraires*/
                vbttTache.lbdiv3      = tttache.lbdiv3      /*Liste des documents à éditer*/
                vbttTache.fgsimplifie = tttache.fgsimplifie /*CRG simplifié*/
                vbttTache.fgrev       = tttache.fgrev       /*Récapitulatif annuel*/
                vbttTache.tpmadisp    = tttache.tpmadisp    /*Mise à disposition des CRG sur GI-EXTRANET*/
        .
        /* Duplication des ahistcrg */
        if intnt.nocon <> ttTacheCrg.iNumeroContrat then run dupliqueHistoriqueCrg(ttTacheCrg.cCodeTypeRole, ttTacheCrg.iNumeroRole, intnt.nocon).
    end.

    /* METTRE A JOUR INTNT AVEC mode de reglement pour la tache compte rendu de gestion pour le lien Mandat-mandant. */
    for first intnt exclusive-lock
        where intnt.Tpcon = ttTacheCrg.cTypeContrat
          and intnt.nocon = ttTacheCrg.iNumeroContrat
          and intnt.tpidt = ttTacheCrg.cCodeTypeRole
          and intnt.Noidt = ttTacheCrg.iNumeroRole:
        if intnt.lbdiv > ""
        then entry(1, intnt.lbdiv, "@") = ttTacheCrg.cCodeMode2Reglement.
        else intnt.lbdiv = ttTacheCrg.cCodeMode2Reglement + "@".
    end.
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    if mError:erreur() then return.

    if not can-find(first cttac  no-lock
                        where cttac.tpcon = ttTacheCrg.cTypeContrat
                        and   cttac.nocon = ttTacheCrg.iNumeroContrat
                        and   cttac.tptac = ttTacheCrg.cTypeTache)
    then do:
        create cttac.
        assign
            cttac.tpcon = ttTacheCrg.cTypeContrat
            cttac.nocon = ttTacheCrg.iNumeroContrat
            cttac.tptac = ttTacheCrg.cTypeTache
            cttac.dtcsy = today
            cttac.hecsy = mtime
            cttac.cdcsy = mtoken:cUser
            .
    end.


end procedure.

procedure setTacheCrg:
    /*------------------------------------------------------------------------------
    Purpose: Update de la tâche CRG
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheCrg.
    define input parameter table for ttDocumentsCRG.
    define input parameter table for ttError.

    define variable vlCrgPartielFindAnnee   as logical   no-undo.
    define variable voParametresCRG         as class parametrageEditionCRG no-undo.

    define buffer ctrat         for ctrat.
    define buffer tache         for tache.
    define buffer pclie         for pclie.
    define buffer vbtacheHono   for tache.

    message "*******************************setTacheCrg".

    voParametresCRG = new parametrageEditionCRG().
    vlCrgPartielFindAnnee = voParametresCRG:isTrimesDecalePartielFinAnnee().
    delete object voParametresCRG.


    for first ttTacheCrg
        where lookup(ttTacheCrg.CRUD, "C,U,D") > 0:
        find first ctrat no-lock                                             //recherche mandat
            where ctrat.tpcon = ttTacheCrg.cTypeContrat
            and ctrat.nocon = ttTacheCrg.iNumeroContrat no-error.
        if not available ctrat
        then
        do:
            mError:createError({&error}, 100057).
            return.
        end.
        find last tache no-lock
            where tache.tpcon = ttTacheCrg.cTypeContrat
            and tache.nocon = ttTacheCrg.iNumeroContrat
            and tache.tptac = {&TYPETACHE-compteRenduGestion} no-error.
        if not available tache and lookup(ttTacheCrg.CRUD, "U,D") > 0
        then
        do:
            mError:createError({&error}, 1000398). //Tentative de modification d'une tâche inexistante
            return.
        end.

        //Maj de la liste des documents édités à partir de la table ttDocumentsCRG
        ttTacheCrg.cListeDocuments = "".
        for each ttDocumentsCRG
            where ttDocumentsCRG.lEditionMandat
            by ttDocumentsCRG.iNumeroOrdre:
            ttTacheCrg.cListeDocuments = ttTacheCrg.cListeDocuments + "," + ttDocumentsCRG.cCodeDocument.
        end.
        ttTacheCrg.cListeDocuments = trim(ttTacheCrg.cListeDocuments,",").

        run controleChangementPeriodicite(ttTacheCrg.iNumeroContrat, ttTacheCrg.cCodePeriodicite, tache.pdges).
        if mError:erreur() = yes then return.

        run controlesAvantValidation (buffer ctrat, buffer ttTacheCrg).
        if mError:erreur() = yes then return.

        /* Ajout SY le 20/01/2006 : alerte si trim décalés + param CRG partiel en fin d'année + Hono non mensuels */
        /* CRG Trim Déc. */
        if (ttTacheCrg.cCodePeriodicite = {&PERIODICITEGESTION-trimestrielFevAvril} or ttTacheCrg.cCodePeriodicite = {&PERIODICITEGESTION-trimestrielMarsMai}) and vlCrgPartielFindAnnee  = yes then
        do:
            /* rechercher la périodicité des Honoraires */
            find last vbtacheHono no-lock
                where vbtacheHono.tpcon = ttTacheCrg.cTypeContrat
                and   vbtacheHono.nocon = ttTacheCrg.iNumeroContrat
                and   vbtacheHono.tptac = {&TYPETACHE-Honoraires}
                no-error.
            if available vbtacheHono and vbtacheHono.pdges <> {&PERIODICITEHONORAIRES-mensuel} and vbtacheHono.pdges  <> "00000" then
                mError:createError({&information}, 109883). // Attention : Le CRG partiel de fin d'année sera édité sans les honoraires
            else
                mError:createError({&information}, 109882). // Un CRG sera édité partiellement en fin d'année
        end.

        //Si on était en CRG "standard" et qu'on passe en CRG "libre", il faut créer un enregistrement ahistcrg d'initialisation
        if ttTacheCrg.lCrgLibre and entry(1,tache.lbdiv,"#") ne {&TYPECRG-Libre} then run miseAJourCrgLibre(ttTacheCrg.iNumeroContrat).

        run miseAJourTableTache ("U", buffer ttTacheCrg).

    end.

end procedure.

procedure controleChangementPeriodicite private:
    /*------------------------------------------------------------------------------
     Purpose: Contrôle du changement de périodicité des CRG
     Notes:  On ne peut changer la p‚riodicit‚ du CRG que si
       - Le mandat n'a aucune ‚criture
     Ou sinon il faut que
       - mois de d‚but p‚riode en cours = mois cpta
           (sinon perte des mois entre d‚but de p‚riode et mois en cours)
       - mois de d‚but Nlle p‚riode     = mois cpta
           (sinon perte des mois entre mois en cours et Nlle p‚riode )
    ---------------------------------------------------------------------------
     Ajout SY le 20/01/2006 : CRG Spe MARNEZ
     Si ce mandat est mouvementé en Novembre ou en Décembre,
       la modification de la périodicité du CRG à « Trim. (Fév-Avr) »
       n’est possible que si le mois en cours en gérance n’est pas Janvier.
     Si ce mandat est mouvementé en Décembre, la modification de la périodicité
       du CRG à « Trim. (Mar-Mai) » n’est possible que si le mois en cours
       en gérance n’est pas Janvier ou  Février.

    ------------------------------------------------------------------------------*/

    define input parameter piNumeroMandat as integer no-undo.
    define input parameter pcAncienCodePeriodicite as character no-undo.
    define input parameter pcNouveauCodePeriodicite as character no-undo.

    define variable viNombreMoisDansLaPeriode as integer   no-undo.
    define variable viPremierMoisDeLaPeriode as integer   no-undo.
    define variable vcMoisComptableEnCours as character no-undo.
    define variable vlCrgPartielFindAnnee   as logical   no-undo.
    define variable voParametresCRG         as class parametrageEditionCRG no-undo.

    /* Pas encore d'‚critures comptables => tout est permis sauf si le CRG décalé existe et est à oui => périodicité mensuelle seulement permise*/
    if not existeEcritures(piNumeroMandat) then return.

    voParametresCRG = new parametrageEditionCRG().
    vlCrgPartielFindAnnee = voParametresCRG:isTrimesDecalePartielFinAnnee().
    delete object voParametresCRG.

    if pcAncienCodePeriodicite = "" or pcAncienCodePeriodicite = pcNouveauCodePeriodicite then
        return.
    else
    do:

        vcMoisComptableEnCours = string(month(mtoken:daDateFinRespGerance),"99") + "/" + string(year(mtoken:daDateFinRespGerance),"9999") .

        for first sys_pg no-lock
            where sys_pg.tppar = "O_PRD"
            and   sys_pg.cdpar = pcAncienCodePeriodicite:

            /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             | R‚cup‚ration des infos sur la P‚riodicit‚.    |
             | R‚cup‚ration Nb de Mois et 1er Mois P‚riode.  |
             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
            assign
                viNombreMoisDansLaPeriode = integer(sys_pg.zone6)
                viPremierMoisDeLaPeriode = integer(sys_pg.zone7)
                .
            /* Modification interdite : Vous ne pouvez changer la p‚riodicit‚ du CRG
               que lorsque le 1er mois de la p‚riode est ‚gal au mois comptable en cours */
            if viNombreMoisDansLaPeriode > 0 and viPremierMoisDeLaPeriode > 0
                and not debutPeriodeCrg (input viPremierMoisDeLaPeriode, input viNombreMoisDansLaPeriode) then
                    mError:createError({&error}, 1000392). //Modification interdite : Vous ne pouvez changer la périodicité du CRG que lorsque le 1er mois de la période est égal au mois comptable en cours
        end.
    end.

    for first sys_pg no-lock
        where sys_pg.tppar = "O_PRD"
        and   sys_pg.cdpar = pcNouveauCodePeriodicite:

        /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         | R‚cup‚ration des infos sur la P‚riodicit‚.    |
         | R‚cup‚ration Nb de Mois et 1er Mois P‚riode.  |
         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        assign
            viNombreMoisDansLaPeriode = integer(sys_pg.zone6)
            viPremierMoisDeLaPeriode = integer(sys_pg.zone7)
            .
        if viNombreMoisDansLaPeriode > 0 and viPremierMoisDeLaPeriode > 0
            and debutPeriodeCrg (input viPremierMoisDeLaPeriode, input viNombreMoisDansLaPeriode)
        then do:
            /*Modification interdite : Vous ne pouvez choisir qu'une périodicité qui commence avec le mois comptable en cours*/
            /*run GestMess in HdLibPrc(105997,"",105999,"",vcMoisComptableEnCours,"ERROR",output FgRepMes).
            CdRetour-OU = "01".*/
            mError:createErrorGestion({&error}, 105999, vcMoisComptableEnCours).
            return.
        end.

        /* Ajout SY le 20/01/2006 */
        /* rechercher si écriture comptables en novembre ou décembre */
        if month(mtoken:daDateFinRespGerance) = 01 and pcNouveauCodePeriodicite = {&PERIODICITEGESTION-trimestrielFevAvril} and vlCrgPartielFindAnnee = yes
            and existeEcrituresMois (piNumeroMandat, date(11, 01 , year(mToken:daDateFinRespGerance) - 1) , date(12, 31, year(mToken:daDateFinRespGerance) - 1))
        then do:
            /* Modification interdite : Avec le paramètre CRG partiel en fin d'année pour les trimestriels décalés%svous ne pouvez pas mettre ce mandat en %1 au mois de %2 */
            /*LbTmpPdt = LbMesTit + "|" + vcMoisComptableEnCours.
            run GestMess in HdLibPrc(105997,"",109913,"",LbTmpPdt,"ERROR",output FgRepMes).
            CdRetour-OU = "01".*/
            mError:createErrorGestion({&error}, 109913, vcMoisComptableEnCours).
            return.
        end.
        /* rechercher si écriture comptables en décembre */
        if month(mToken:daDateFinRespGerance) <= 2 and pcNouveauCodePeriodicite = {&PERIODICITEGESTION-trimestrielMarsMai} and vlCrgPartielFindAnnee = yes
            and existeEcrituresMois (piNumeroMandat, date(12, 01 , year(mToken:daDateFinRespGerance) - 1) , date(12, 31, year(mToken:daDateFinRespGerance) - 1) )
        then do:
            /* Modification interdite : Avec le paramètre CRG partiel en fin d'année pour les trimestriels décalés%svous ne pouvez pas mettre ce mandat en %1 au mois de %2 */
            /*LbTmpPdt = LbMesTit + "|" + vcMoisComptableEnCours.
            run GestMess in HdLibPrc(105997,"",109913,"",LbTmpPdt,"ERROR",output FgRepMes).
            CdRetour-OU = "01".*/
            mError:createErrorGestion({&error}, 109913, vcMoisComptableEnCours).
            return.
        end.
    end.

end procedure.

procedure getTacheCrg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    @param piNumeroMandat Numero de mandat
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat   as int64     no-undo.
    define output parameter table for ttTacheCrg.
    define output parameter table for ttDocumentsCRG.
    define output parameter table for ttCalendrierCrg.

    define variable vhTiers                 as handle    no-undo.
    define variable vcInformationsBancaires as character no-undo.
    define variable vcListeDocumentsCabinet as character no-undo.
    define variable viCompteur              as integer   no-undo.
    define variable voPclie                 as class pclie no-undo.

    define buffer tache         for tache.
    define buffer ctrat         for ctrat.
    define buffer intnt         for intnt.
    define buffer pclie         for pclie.
    define buffer vbtacheprov   for tache.

    message "********getTacheCrg - piNumeroMandat " piNumeroMandat.

    empty temp-table ttTacheCrg.

    for first tache no-lock
        where tache.tpcon =  {&TYPECONTRAT-mandat2Gerance}
        and tache.nocon = piNumeroMandat
        and tache.tptac = {&TYPETACHE-compteRenduGestion}
        and tache.notac = 1,
        first ctrat no-lock
            where ctrat.tpcon = tache.tpcon
            and ctrat.nocon = tache.nocon,
        first intnt no-lock
            where intnt.tpcon = tache.tpcon
            and intnt.nocon = tache.nocon
            and intnt.tpidt = {&TYPEROLE-mandant}
        :
        find first vbtacheprov no-lock
            where vbtacheprov.tpcon =  {&TYPECONTRAT-mandat2Gerance}
            and vbtacheprov.nocon = piNumeroMandat
            and vbtacheprov.tptac = {&TYPETACHE-provisionPermanente}
            no-error.
        create ttTacheCrg.
        assign
            ttTacheCrg.dtTimestamp                   = datetime(tache.dtmsy, tache.hemsy)
            ttTacheCrg.CRUD                          = 'R'
            ttTacheCrg.rRowid                        = rowid(tache)
            ttTacheCrg.iNumeroTache                  = tache.noita
            ttTacheCrg.cTypeContrat                  = tache.tpcon
            ttTacheCrg.iNumeroContrat                = tache.nocon
            ttTacheCrg.cCodeTypeRole                 = intnt.tpidt
            ttTacheCrg.iNumeroRole                   = intnt.noidt
            ttTacheCrg.cTypeTache                    = tache.tptac
            ttTacheCrg.iChronoTache                  = tache.notac
            ttTacheCrg.daActivation                  = tache.dtdeb
            ttTacheCrg.lIndivision                   = (ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision})
            ttTacheCrg.cCodePresentationCrg          = tache.ntges
            ttTacheCrg.cLibellePresentationCrg       = outilTraduction:getLibelleProgZone2("R_TAG", {&TYPETACHE-compteRenduGestion}, ttTacheCrg.cCodePresentationCrg)
            ttTacheCrg.cCodePeriodicite              = tache.pdges
            ttTacheCrg.cLibellePeriodicite           = outilTraduction:getLibelleProgZone2("R_TPR", {&TYPETACHE-compteRenduGestion}, ttTacheCrg.cCodePeriodicite)
            ttTacheCrg.lPresentationDetailCalculHono = tache.tpges = "00001"
            //ttTacheCrg.cCodeMode2Traitement             = tache.dcreg /*"MDTRT"*/ **Obsolète**
            ttTacheCrg.iBordereauConcierge           = tache.duree
            ttTacheCrg.lRepartitionTerme             = tache.pdreg = "00001"
            ttTacheCrg.cCodeTypeEdition              = tache.utreg
            ttTacheCrg.cLibelleTypeEdition           = outilTraduction:getLibelleParam("EDCRG", ttTacheCrg.cCodeTypeEdition)
            ttTacheCrg.cCodeScenarioParamRubCRG123   = tache.dossier
            //ttTacheCrg.cCodeModeEditionSpecifique    = tache.tphon /*"SPCRG"*/ **Obsolète**
            ttTacheCrg.lTriReleveQuittParBat         = tache.etqenergie = "00001"
            ttTacheCrg.cCodeTraitementAvisEcheance   = if tache.cdhon = "" then "00004" else tache.cdhon
            ttTacheCrg.cLibelleTraitementAvisEcheance = outilTraduction:getLibelleParam("TRTEC", ttTacheCrg.cCodeTraitementAvisEcheance)
            ttTacheCrg.iNumeroRoleGardien            = integer(tache.cdreg)
            ttTacheCrg.cNomGardien                   = outilformatage:getNomTiers({&TYPEROLE-GardienBordereauCrg},integer(tache.cdreg))
            ttTacheCrg.cCodeMode2Reglement           = tache.ntreg
            ttTacheCrg.cLibelleMode2Reglement        = outilTraduction:getLibelleProgZone2("R_MDC", {&TYPECONTRAT-mandat2Gerance}, ttTacheCrg.cCodeMode2Reglement)
            ttTacheCrg.cCodeModeEnvoi                = tache.tpmadisp
            ttTacheCrg.cLibelleModeEnvoi             = outilTraduction:getLibelleParam("MDNET", ttTacheCrg.cCodeModeEnvoi)
            ttTacheCrg.cCodeEditionFacture           = tache.lbdiv2
            ttTacheCrg.cLibelleEditionFacture        = outilTraduction:getLibelleParam("EDHON", ttTacheCrg.cCodeEditionFacture)
            ttTacheCrg.cListeDocuments               = tache.lbdiv3
            ttTacheCrg.cCodeLieuEditionDocument      = if num-entries(tache.lbdiv,"#") > 3 then entry(4,tache.lbdiv,"#") else ""
            ttTacheCrg.cLibelleLieuEditionDocument   = outilTraduction:getLibelleParam("LCCRG", ttTacheCrg.cCodeLieuEditionDocument)
            ttTacheCrg.lCrgLibre                     = entry(1,tache.lbdiv,"#") = {&TYPECRG-Libre}
            ttTacheCrg.lAccesCrgLibre                = can-find(first iparm no-lock
                                                                where iparm.tppar = "CRGL"
                                                                and   iparm.cdpar = "01") //Paramètre cabinet CRG libre ouvert
                                                       and not can-find(first  honmd   no-lock
                                                                        where  honmd.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                                                        and    honmd.nocon = ttTacheCrg.iNumeroContrat
                                                                        and    lookup(honmd.tphon,"13027,13020") > 0 ) // Pas d'honoraires UL sur le mandat


            ttTacheCrg.lEditionSituationLocataire    = num-entries(tache.lbdiv,"#") > 4 and entry(5,tache.lbdiv,"#") = "00001"
            ttTacheCrg.cCodeScenarioPresentation     = tache.tpfin
            ttTacheCrg.lEditionHtTva                = tache.mtreg = 00001
            ttTacheCrg.lCrgSimplifie                 = tache.fgsimplifie
            ttTacheCrg.lProvisionPermanente          = available vbtacheprov and vbtacheprov.mtreg ne 0
            ttTacheCrg.dMontantProvisionPermanente   = if available vbtacheprov then vbtacheprov.mtreg else 0
            ttTacheCrg.cLibelleProvisionPermanente   = if available vbtacheprov then vbtacheprov.lbdiv else ""
            ttTacheCrg.lRecapitulatifAnnuel          = tache.fgrev
            ttTacheCrg.lGiExtranetOuvert             = can-find(first aparm no-lock
                                                                where aparm.tppar       = "TWEB"
                                                                and   aparm.cdpar       = "PARAMGEN"
                                                                and   aparm.soc-cd      = 0
                                                                and   aparm.etab-cd     = 0
                                                                and   num-entries(aparm.zone2,"|") >= 4)
            .

        //Le tiers est-il activé sur GiExtranet ?
        for first roles no-lock
            where roles.tprol = ttTacheCrg.cCodeTypeRole
            and   roles.norol = ttTacheCrg.iNumeroRole:
            ttTacheCrg.lGiExtranetTiersActif = f_ctrat_tiers_actif(roles.notie, true).
        end.

        //Libellé du scénario de présentation
        for first aprmcrg no-lock
            where aprmcrg.soc-cd     = integer(mToken:cRefGerance)
              and aprmcrg.type-ligne = 'SCENARIO'
              and aprmcrg.scen-cle   = ttTacheCrg.cCodeScenarioPresentation:
            ttTacheCrg.cLibelleScenarioPresentation = aprmcrg.lib.
        end.

        //Je n'utilise pas l'objet pclie pour assigner le libellé du scénario 123 car c'est une requête très spécifique, qui ne sera utilisée que dans ce programme
        for first pclie no-lock
            where pclie.tppar = "RBCRG"
            and   pclie.zon01 = "SCEN"
            and   pclie.zon10 = ttTacheCrg.cCodeScenarioParamRubCRG123:
            ttTacheCrg.cLibelleScenarioParamRubCRG123 = pclie.lbdiv.
        end.

        /*Informations bancaires - Récupération quel que soit le mode de reglt afin de n'afficher le mode virement que si on a trouvé un iban*/
        run tiers/tiers.p persistent set vhTiers.
        run getTokenInstance in vhTiers(mToken:JSessionId).
        vcInformationsBancaires = dynamic-function("getInformationsBancairesTiers" in vhTiers ,
                                                      ttTacheCrg.cCodeTypeRole,
                                                      ttTacheCrg.iNumeroRole,
                                                      ttTacheCrg.cTypeContrat,
                                                      ttTacheCrg.iNumeroContrat,
                                                      ttTacheCrg.iNumeroTiers
                                                      ).
        run destroy in vhTiers.
        if num-entries(vcInformationsBancaires,"¤") > 3 then
        assign
            ttTacheCrg.cIban          = entry(1,vcInformationsBancaires,"¤")
            ttTacheCrg.cBic           = entry(2,vcInformationsBancaires,"¤")
            ttTacheCrg.cTitulaire     = entry(3,vcInformationsBancaires,"¤")
            ttTacheCrg.cDomiciliation = entry(4,vcInformationsBancaires,"¤")
            .

        //Calendrier des CRG
        /*if ttTacheCrg.lCrgLibre then
        do:*/ //On n'affichait le calendrier que pour les CRG libres dans l'ancienne version, maintenant on l'affiche sur tous les mandants
            empty temp-table ttCalendrierCRG.
            for each    ahistcrg no-lock
                where   ahistcrg.soc-cd = integer(mToken:cRefGerance)
                and     ahistcrg.etab-cd = ttTacheCrg.iNumeroContrat
                by ahistcrg.num-crg
                :
                /* Pour ne pas créer autant de périodes que d'indivisaires */
                if not can-find(first ttCalendrierCRG where ttCalendrierCRG.iNumeroCrg = ahistcrg.num-crg)
                then do:
                    create ttCalendrierCRG.
                    assign
                        ttCalendrierCRG.iNumeroCrg     = ahistcrg.num-crg
                        ttCalendrierCRG.daDateDebutCrg = ahistcrg.dtdeb
                        ttCalendrierCRG.daDateFinCrg   = ahistcrg.dtfin
                        .
                end.
            end.
        /*end.*/

        //Récupération de la liste des documents édités dans le paramétrage cabinet
        voPclie = new pclie("CLCRG").
        vcListeDocumentsCabinet = voPclie:zon04.
        delete object voPclie.

        //Récupération de la liste des documents du CRG
        for each sys_pr where sys_pr.tppar = "DCCRG"
            no-lock:
            create ttDocumentsCrg.
            assign
                ttDocumentsCrg.iNumeroContrat  = 0 //Cabinet
                ttDocumentsCrg.iNumeroOrdre    = 99999
                ttDocumentsCrg.cCodeDocument   = sys_pr.cdpar
                ttDocumentsCrg.cNomDocument    = outilTraduction:getLibelle(sys_pr.nome1)
                ttDocumentsCrg.lEditionCabinet = lookup(ttDocumentsCrg.cCodeDocument,vcListeDocumentsCabinet) > 0
                ttDocumentsCrg.lEditionMandat  = false
                .
        end.
        //Mise à jour de l'ordre de la liste des documents et du flag d'édition pour le mandat en cours
        do viCompteur = 1 to num-entries(ttTacheCrg.cListeDocuments):
            for first ttDocumentsCrg
                where ttDocumentsCrg.cCodeDocument = entry(viCompteur,ttTacheCrg.cListeDocuments):
                assign
                    ttDocumentsCrg.lEditionMandat = true
                    ttDocumentsCrg.iNumeroOrdre   = viCompteur
                    .
            end.
        end.
    end.

end procedure.

procedure initComboTacheCrg:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos de l'écran depuis la vue
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttcombo.

    run chargeCombo.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumero as integer no-undo.
    define variable vlretour as logical no-undo.
    define variable voSyspg  as class syspg no-undo.
    define variable voSyspr  as class syspr no-undo.
    define variable voPclie  as class pclie no-undo.

    voSyspg = new syspg().
    voSyspg:creationComboSysPgZonXX("R_TAG", "PRESENTATION",   "C", {&TYPETACHE-compteRenduGestion}, output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_MDC", "MODE2REGLEMENT", "C", {&TYPECONTRAT-mandat2Gerance},   output table ttCombo by-reference).
    voSyspg:creationComboSysPgZonXX("R_TPR", "PERIODICITE",    "C", {&TYPETACHE-compteRenduGestion}, output table ttCombo by-reference).


    voSyspr = new syspr().
    voSyspr:getComboParametre("EDCRG", "TYPEEDITIONCRG",     output table ttCombo by-reference).
    voSyspr:getComboParametre("TRTEC", "TRTAVISECHCRG",      output table ttCombo by-reference).
    voSyspr:getComboParametre("MDNET", "MODEENVOI",          output table ttCombo by-reference).
    voSyspr:getComboParametre("EDHON", "EDITIONFACTURESCRG", output table ttCombo by-reference).
    voSyspr:getComboParametre("LCCRG", "LIEUEDITIONCRG",     output table ttCombo by-reference).

    for last ttCombo: viNumero = ttCombo.iSeqId. end.
    for each aprmcrg no-lock
        where aprmcrg.soc-cd     = integer(mToken:cRefGerance)
          and aprmcrg.type-ligne = 'SCENARIO':
        create ttCombo.
        assign
            viNumero                 = viNumero + 1
            ttCombo.iSeqId           = viNumero
            ttCombo.cCode            = aprmcrg.scen-cle
            ttCombo.cLibelle         = aprmcrg.lib
            ttCombo.cNomCombo        = "SCENPRESENTATIONCRG"
        .
    end.

    voPclie = new pclie("RBCRG").
    voPclie:getComboParametre("SCENARIO123", "and pclie.zon01 = 'SCEN'", "zon10", "lbdiv", output table ttCombo by-reference).

    delete object voSyspr.
    delete object voSyspg.
    delete object voPclie.

end procedure.

function debutPeriodeCrg returns logical
    (piPremierMoisDeLaPeriode as integer, piNombreMoisDansLaPeriode as integer):
    /*------------------------------------------------------------------------------
     Purpose: Procedure de recherche si le mois comptable coïncide avec le mois de début de la période de CRG
     Notes:
    ------------------------------------------------------------------------------*/
    define variable viCompteur          as integer no-undo.
    define variable viFinPeriode        as integer no-undo.
    define variable viMoisPeriodeCrg    as integer no-undo.

    if piNombreMoisDansLaPeriode = 1 then return true.

    assign
        viMoisPeriodeCrg = piPremierMoisDeLaPeriode
        viFinPeriode = (12 / piNombreMoisDansLaPeriode).

    do viCompteur = 1 to viFinPeriode:
        if viMoisPeriodeCrg = month(mToken:daDateFinRespGerance) then return true.
        viMoisPeriodeCrg = viMoisPeriodeCrg + piNombreMoisDansLaPeriode.
    end.

    return false.

end function.

function existeEcritures returns logical private
    (piNumeroMandat as integer):
    /*------------------------------------------------------------------------------
     Purpose: recherche si un mandat a des écritures comptables ou extra-comptables
     Notes:
    ------------------------------------------------------------------------------*/

    if can-find(first cecrln no-lock
        where cecrln.soc-cd = integer(mtoken:cRefGerance)
        and   cecrln.etab-cd = piNumeroMandat )
    then return true.

    if can-find(first cexmln no-lock
        where cexmln.soc-cd = integer(mtoken:cRefGerance)
        and   cexmln.etab-cd = piNumeroMandat )
    then return true.

    if can-find(first cextln no-lock
        where cextln.soc-cd = integer(mtoken:cRefGerance)
        and   cextln.etab-cd = piNumeroMandat )
    then return true.

end function.

function existeEcrituresMois returns logical private
    (piNumeroMandat as integer, pdaDateDebut as date, pdaDateFin as date  ):
    /*------------------------------------------------------------------------------
     Purpose: recherche si un mandat a des écritures comptables ou extra-comptables sur une période
     Notes:
    ------------------------------------------------------------------------------*/
    define buffer ietab  for ietab.
    define buffer iprd   for iprd.

    for each ietab no-lock
        where ietab.soc-cd = integer(mtoken:cRefGerance)
        and ietab.etab-cd  = piNumeroMandat,
        each iprd no-lock
            where iprd.soc-cd = ietab.soc-cd
            and iprd.etab-cd = ietab.etab-cd
            and iprd.dadebprd <= pdaDateFin
            and iprd.dafinprd <= pdaDateFin
            and iprd.dadebprd >= pdaDateDebut
            and iprd.dafinprd >= pdaDateDebut:    //todo: boucle à revoir

        if can-find(first cecrln no-lock
            where cecrln.soc-cd = integer(mtoken:cRefGerance)
            and   cecrln.etab-cd = piNumeroMandat
            and   cecrln.prd-cd = iprd.prd-cd
            and   cecrln.prd-num = iprd.prd-num) then return true.

        if can-find(first cexmln no-lock
            where cexmln.soc-cd = integer(mtoken:cRefGerance)
            and   cexmln.etab-cd = piNumeroMandat
            and   cexmln.prd-cd = iprd.prd-cd
            and   cexmln.prd-num = iprd.prd-num) then return true.

        if can-find(first cextln no-lock
            where cextln.soc-cd = integer(mtoken:cRefGerance)
            and   cextln.etab-cd = piNumeroMandat
            and   cextln.prd-cd = iprd.prd-cd
            and   cextln.prd-num = iprd.prd-num) then return true.

    end.

end function.

procedure dupliqueHistoriqueCrg private:

    /*------------------------------------------------------------------------------
    Purpose: Duplication de la table d'historique des CRG
    Notes  :
    ------------------------------------------------------------------------------*/

    define input parameter piMandant as integer no-undo.
    define input parameter piMandatEncours as integer no-undo.
    define input parameter piMandatATraiter as integer no-undo.

    define variable viNumeroCrg as integer no-undo.

    define buffer ahistcrg      for ahistcrg.
    define buffer vbahistcrg    for ahistcrg.
    define buffer intnt         for intnt.

    /* Si on n'a pas créer de ahistcrg pour le mandant, on ne fait rien */
    if giNumeroAhistCrgCree = 0 then return.

    message "dupliqueHistoriqueCrg".

    /* Recherche du numero de crg sur le mandat a traiter */
    for each    ahistcrg  no-lock
        where   ahistcrg.soc-cd = integer(mToken:cRefGerance)
        and     ahistcrg.etab-cd = piMandatATraiter
        :
        if ahistcrg.num-crg > viNumeroCrg then viNumeroCrg = ahistcrg.num-crg.
    end.
    viNumeroCrg = viNumeroCrg + 1.

    /* positionnement sur l'enregistrement du mandat encours */
    for first  ahistcrg  no-lock
        where   ahistcrg.soc-cd = integer(mToken:cRefGerance)
        and     ahistcrg.etab-cd = piMandatEncours
        and     ahistcrg.cpt-cd = string(piMandant,"99999")
        and     ahistcrg.num-crg = giNumeroAhistCrgCree:

        /* balayage du mandant et des indivisaires du mandat à traiter */
        for each    intnt no-lock
            where   intnt.tpidt = {&TYPEROLE-mandant}
            and     intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
            and     intnt.nocon = piMandatATraiter
            :
            create vbahistcrg.
            buffer-copy ahistcrg to vbahistcrg
                assign
                vbahistcrg.num-crg = viNumeroCrg
                vbahistcrg.etab-cd = intnt.nocon
                vbahistcrg.cpt-cd  = string(intnt.noidt,"99999")
                .

        end.

        for each    intnt no-lock
            where   intnt.tpidt = {&TYPEROLE-coIndivisaire}
            and     intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
            and     intnt.nocon = piMandatATraiter
            :
            create vbahistcrg.
            buffer-copy ahistcrg to vbahistcrg
                assign
                vbahistcrg.num-crg = viNumeroCrg
                vbahistcrg.etab-cd = intnt.nocon
                vbahistcrg.cpt-cd  = string(intnt.noidt,"99999")
                .

        end.

        /* Maj du flag de creation */
        giNumeroAhistCrgCree = 0.

    end.

end procedure.

procedure controlesAvantValidation private:

    /*------------------------------------------------------------------------------
    Purpose: Contrôle des informations saisies par l'utilisateur avant de faire l'update
    Notes  :
    ------------------------------------------------------------------------------*/

    define parameter buffer ctrat      for ctrat.
    define parameter buffer ttTacheCrg for ttTacheCrg.

    define variable vcMessage               as character no-undo.
    define variable vcTypeCRGAutresMandats  as character no-undo.
    define variable AuManUse                as character no-undo. //TODO: voir comment on gère la création auto/manuelle des tâches

    define buffer intnt  for intnt.
    define buffer vbtache for tache.
    define buffer icron  for icron.

    /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     | PBP 16/12/2002 Edition CRG autres que Standard|
     | impossible si le paramétrage déclaration de   |
     | TVA non ouvert                                |
     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    if ttTacheCrg.cCodeTypeEdition <> "00001" then
    do:
        /* Modif SY le 25/01/2013 - fiche 0113/0191 : ce n'est pas la déclaration de TVA qui compte mais il faut que l'éclatement des encaissement soit activé dans le CRON */
        /*FIND FIRST iparam NO-LOCK NO-ERROR.
        IF NOT AVAILABLE iparam OR (AVAILABLE iparam AND iparam.install-tva = FALSE) THEN DO:*/
        if not can-find(first icron no-lock
                            where icron.soc-cd = integer(mToken:cRefGerance)
                            and   icron.type-cron = 2
                            and   icron.Code-cron = 3
                            and   icron.flag) then
        do:
            if AuManUse = "A" then return. //TODO
            /* NP 0313/0233 sauf pour 06505 et 06506 */
            if integer(mToken:cRefGerance) <> 6505 and integer(mToken:cRefGerance) <> 6506 then
            do:
                mError:createError({&error}, 1000393). //Sans le paramétrage <Eclatement des encaissements> dans les traitements planifiés, l'édition des CRG doit être Standard.%SVeuillez contacter la Gestion Intégrale pour activer ce traitement.
                return "false".
            end.
        end.

        if ttTacheCrg.cCodeTypeEdition = "00009" /** CRG 1-2-3 **/
            and ttTacheCrg.cCodeScenarioParamRubCRG123 = ""
        then
        do :
            if AuManUse = "A" then return. //TODO
            /*"Pour ce type d'édition, il faut choisir un scénario de paramétrage des rubriques."*/
            mError:createError({&error}, 110787).
            return "false".
        end.
    end.

    /* Ajout SY le 19/05/2009 - fiche 0409/0309 */
    /* modif SY le 02/07/2009 : bloquage si CRG simplifié uniquement */
    if ttTacheCrg.lCrgSimplifie and ttTacheCrg.lEditionSituationLocataire and ttTacheCrg.cCodePresentationCrg = "18006"
    then do:
        if AuManUse = "A" then return. //TODO
        mError:createError({&error}, 1000394). //L'option 'Editer la situation locataire sur le CRG' est incompatible avec les CRG Simplifiés en présentation sur Encaissement
        return "false".
    end.

    /* Si Type CRG <> type CRG autres mandats = demande confirmation */
    vcTypeCRGAutresMandats = "".
boucleMandats:
    for each intnt no-lock
        where intnt.tpcon = ttTacheCrg.cTypeContrat
        and   intnt.tpidt = ttTacheCrg.cCodeTypeRole
        and   intnt.noidt = ttTacheCrg.iNumeroRole
        and   intnt.nocon <> ttTacheCrg.iNumeroContrat,
        first vbtache no-lock
            where vbtache.tpcon = intnt.tpcon
            and   vbtache.nocon = intnt.nocon
            and   vbtache.tptac = ttTacheCrg.cTypeTache
        :
        if entry(1,vbtache.lbdiv,"#") <> string(ttTacheCrg.lCrgLibre,{&TYPECRG-Libre} + "/" + {&TYPECRG-Standard})
        then do:
            vcTypeCRGAutresMandats = entry(1,vbtache.lbdiv,"#").
            leave boucleMandats.
        end.
    end.

    //Vous passez ce mandat en CRG libre mais les autres mandats de ce mandant ne le sont pas. Voulez-vous passer ces autres mandats en CRL libre ?
    if vcTypeCRGAutresMandats = {&TYPECRG-Standard} and outils:questionnaire(1000395, table ttError by-reference) < 2 then return.
    //Vous passez ce mandat en CRG 'standard' mais les autres mandats de ce mandant sont en CRG libre. Voulez-vous passer ces autres mandats en CRL 'standard' ?
    else if vcTypeCRGAutresMandats = {&TYPECRG-Libre} and outils:questionnaire(1000396, table ttError by-reference) < 2 then return.

end procedure.

procedure creationAutoTache:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache crg
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
 
    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.    
    run initTacheCrg(piNumeroMandat, "creation", output table ttTacheCrg).
    if mError:erreur() then return.
    for first ttTacheCrg where ttTacheCrg.CRUD = "C":
        run controlesAvantValidation (buffer ctrat, buffer ttTacheCrg).
        if mError:erreur() = yes then return.
        run miseAJourTableTache ("C", buffer ttTacheCrg).
    end.
end procedure.
