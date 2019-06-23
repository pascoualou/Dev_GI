/*-----------------------------------------------------------------------------
File        : caltvaho.p
Purpose     : calcul de la tva sur honoraires cabinet au locataires par le quittancement (rub 8xx et 9xx)
Fiche       : \\neptune2\nfsdosg\doc_analyseetudes\Honoraires\HonoLoc_Quitt\HonoLoc_Quit_v3b.doc.
Author(s)   : PL - 2008/12/09, Kantena - 2017/12/21
Notes       : reprise de adb/src/quit/caltvaho.p
derniere revue: 2018/08/14 - phm: 

01  16/10/2009  SY    0309/0058: modifications pour nouvelles rub Hono loc ouvertes avec 20 libellés à vide
02  18/01/2010  SY    1108/0443: ICADE Recalcul total quittance en sortie
03  01/02/2010  SY    1108/0443: ICADE Gestion arrondi TVA à 2 décimales
04  24/02/2010  SY    1108/0443: ICADE pas de création de la rubrique TVA 9x si montant calculé à 0
05  15/11/2013  SY    1013/0167: Nouveaux taux TVA 10% et 20% changement des taux au 01/01/2014
                                 Nouveaux includes fctdacpt.i et fctTVAru.i   |
06  16/01/2014  SY    0114/0115: Nl include {DefTvaRu.i}
-----------------------------------------------------------------------------*/
{preprocesseur/mode2calcul.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}
{preprocesseur/param2locataire.i}

using parametre.syspr.syspr.
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageComptabilisationEchus.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
{oerealm/include/instanciateTokenOnModel.i} // Doit être positionnée juste après using

{crud/include/rubqt.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}

{adb/include/fctTVAru.i}                   // fonctions f_donnetauxtvarubqt, donneTauxTvaArticleDate, f_donnerubtva, f_isRubSoumiseTVABail
{bail/include/fctdacpt.i}                  // fonctions f_donnedacomptaqtt
{outils/include/lancementProgramme.i}      // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm      as class collection                          no-undo.
define variable goComptabilisationEchus    as class parametrageComptabilisationEchus    no-undo.
define variable goFournisseurLoyer         as class parametrageFournisseurLoyer         no-undo.
define variable goRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
define variable giNumeroBail          as int64    no-undo.
define variable giNumeroQuittance     as integer  no-undo.
define variable gdaDebutQuittancement as date     no-undo.
define variable gdaFinQuittancement   as date     no-undo.
define variable gdeMontantQuittance   as decimal  no-undo.
define variable ghProcRubqt           as handle   no-undo.
define variable giNombreRubrique      as integer  no-undo.

/* Table des rubriques de TVA sur honoraire */
define temp-table ttTvaHonoraire no-undo
    field cdrub as integer          /* rubrique tva */
    field cdlib as integer          /* no lib rubrique tva */
    field MtTot as decimal          /* Montant total rubrique */
    field vlmtq as decimal          /* Montant rubrique quittancé*/
    index Ix_TbTva01 is primary unique cdRub cdLib
.

function fReferenceSocieteCabinet returns integer(piReference as integer):
    /*------------------------------------------------------------------------------
    Purpose: donne la référence cabinet en fonction de la reference ABD
    Notes  : Cf tache/tacheHonoraire.p
    ------------------------------------------------------------------------------*/
    define buffer ifdparam for ifdparam.
    for first ifdparam no-lock where ifdparam.soc-dest = piReference:
        return ifdparam.soc-cd.
    end.
    return 0.
end function.

procedure lancementCaltvaho:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.
  
    assign
        giNumeroBail               = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroQuittance          = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutQuittancement      = poCollectionQuittance:getDate("daDebutQuittancement")
        gdaFinQuittancement        = poCollectionQuittance:getDate("daFinQuittancement")
        goCollectionHandlePgm      = new collection()     
        goComptabilisationEchus    = new parametrageComptabilisationEchus()
        goFournisseurLoyer         = new parametrageFournisseurLoyer()
        goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
    .
    ghProcRubqt = lancementPgm("crud/rubqt_CRUD.p", goCollectionHandlePgm).
    run caltvahoPrivate.
    delete object goComptabilisationEchus.
    delete object goFournisseurLoyer.
    delete object goRubriqueQuittHonoCabinet.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure caltvahoPrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    -------------------------------------------------------------------------------*/
    define variable vdeTauxTaxe     as decimal   no-undo.
    define variable viCodeCabinet   as integer   no-undo.
    /* COMPTABILISATION DES ECHUS DANS LE MOIS précédent */ /* SY 1013/0167 */
    define variable vlCompaEchu     as logical   no-undo.
    define variable vdaQuitancement as date      no-undo.
    define variable vcCodeArticle   as character no-undo.
    define buffer ctrat for ctrat.
    define buffer rubqt for rubqt.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = integer(truncate(giNumeroBail / 100000, 0)):
        // comptabilisation des echus dans le mois precedent
        vlCompaEchu = if not ctrat.fgfloy
                       then goComptabilisationEchus:isComtabilisationEchuMoisPrecedent()
                       else goFournisseurLoyer:isComptabilisationEchu().
    end.
    /* Recupération de la référence cabinet */
    viCodeCabinet = fReferenceSocieteCabinet(integer(mToken:cRefPrincipale)).
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        vdaQuitancement = f_donnedacomptaqtt(ttQtt.iMoisTraitementQuitt, ttQtt.cCodeTerme, vlCompaEchu).
    end.
    for each ttRub     /* Suppression des rubriques de la famille 9 */
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iFamille = 9:
        assign
            gdeMontantQuittance = gdeMontantQuittance + ttRub.dMontantQuittance
            giNombreRubrique    = giNombreRubrique + 1
        .
        delete ttRub no-error.
    end.
    /* Mise a jour du total de la quittance & déduction du total des rubriques supprimées */
    assign
        gdeMontantQuittance = - gdeMontantQuittance
        giNombreRubrique    = - giNombreRubrique
    .
    /* Maj du montant quittancé pour la rubrique si modif */
    if giNombreRubrique <> 0 then run majttQtt.
    /* Recherche des Rubriques de la famille 8 */
boucleRubrique:
    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iFamille = {&FamilleRubqt-HonoraireCabinet}:
        /* Recherche du taux de tva à appliquer */
        vcCodeArticle = goRubriqueQuittHonoCabinet:getCodeArticleProprietaire(ttRub.iNorubrique, ttRub.iNoLibelleRubrique).
        if vcCodeArticle = ? or vcCodeArticle = "" then next boucleRubrique.

        /* recherche de l'article et de son taux de tva */
        vdeTauxTaxe = donneTauxTvaArticleDate(viCodeCabinet, vcCodeArticle, vdaQuitancement).
        /* Recherche de la rubrique tva associée au taux */
// whole-index corrige par la creation dans la version d'un index sur cdfam  
        find first rubqt no-lock
            where rubqt.cdfam = {&FamilleRubqt-TVAHonoraire}
              and rubqt.cdlib = 1
              and rubqt.prg07 = "HL"
              and rubqt.prg04 = string(vdeTauxTaxe * 100) no-error.
        if not available rubqt then next boucleRubrique.

        /* A ce stade, on cumule à la rubrique de tva, avec création si inexistante */
        find first ttTvaHonoraire
            where ttTvaHonoraire.cdrub = rubqt.cdrub
              and ttTvaHonoraire.cdlib = rubqt.cdlib no-error.
        if not available ttTvaHonoraire then do:
            /* Création de la rubrique en table tempo */
            create ttTvaHonoraire.
            assign
                ttTvaHonoraire.cdrub = rubqt.cdrub
                ttTvaHonoraire.cdlib = rubqt.cdlib
            .
        end.
        /* cumul à la rubrique */
        assign
            ttTvaHonoraire.mttot = ttTvaHonoraire.mttot + round((ttRub.dMontantTotal * vdeTauxTaxe) / 100, 2)
            ttTvaHonoraire.vlmtq = ttTvaHonoraire.vlmtq + round((ttRub.dMontantQuittance * vdeTauxTaxe) / 100, 2)
        .
    end.
    /* balayage de la table temporaire pour création physique des rubriques de tva */
    for each ttTvaHonoraire
        where ttTvaHonoraire.vlmtq <> 0:               /* Ajout SY le 24/02/2010 */
        /* Affectation des variables de travail */
        run creRubTax(ttTvaHonoraire.cdrub, ttTvaHonoraire.cdlib, ttTvaHonoraire.mttot, ttTvaHonoraire.vlmtq).
    end.
    /* Ajout SY le 18/01/2010 : recalcul nbrub et mtqtt */
    run calMntQtt.
end procedure.

procedure creRubTax private:
    /*-------------------------------------------------------------------------
    Purpose : Création d'une rubrique taxe dans ttRub
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter piRubriqueTaxe    as integer no-undo.
    define input  parameter piCodeLibelleTaxe as integer no-undo.
    define input  parameter pdeMontantTaxe    as decimal no-undo.
    define input  parameter pdeTotal          as decimal no-undo.

    empty temp-table ttRubqt.
    run readRubqt in ghProcRubqt(piRubriqueTaxe, piCodeLibelleTaxe, table ttRubqt by-reference).
    for first ttRubqt:
        create ttRub.
        assign
            ttRub.iNumeroLocataire = giNumeroBail
            ttRub.iNoQuittance = giNumeroQuittance
            ttRub.iFamille = ttRubqt.cdFam
            ttRub.iSousFamille = ttRubqt.cdsfa
            ttRub.iNorubrique = piRubriqueTaxe
            ttRub.iNoLibelleRubrique = piCodeLibelleTaxe
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(ttRubqt.nome1)
            ttRub.cCodeGenre = ttRubqt.cdgen
            ttRub.cCodeSigne = ttRubqt.cdSig
            ttRub.CdDet = "0"
            ttRub.dQuantite = 0
            ttRub.dPrixunitaire = 0
            ttRub.dMontantTotal = pdeTotal
            ttRub.iProrata = 0
            ttRub.iNumerateurProrata = 0
            ttRub.iDenominateurProrata = 0
            ttRub.dMontantQuittance = pdeMontantTaxe
            ttRub.daDebutApplication = gdaDebutQuittancement
            ttRub.daFinApplication = gdaFinQuittancement
            ttRub.iNoOrdreRubrique = 0
            /* Modification du montant de la quittance dans ttQtt.dMontantQuittance   */
            gdeMontantQuittance = pdeMontantTaxe
            giNombreRubrique    = 1
        .
        run majttQtt.
    end.
end procedure.

procedure majttQtt private:
    /*-------------------------------------------------------------------------
    Purpose : met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   :
    -------------------------------------------------------------------------*/
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        assign
            ttQtt.dMontantQuittance = ttQtt.dMontantQuittance + gdeMontantQuittance
            ttQtt.iNombreRubrique = ttQtt.iNombreRubrique + giNombreRubrique
            ttQtt.CdMaj = 1
        .
    end.
end procedure.

procedure calMntQtt private:
    /*-------------------------------------------------------------------------
    Purpose :
    Notes   :
    -------------------------------------------------------------------------*/
    define variable vdeMontantQuittance as decimal  no-undo.
    define variable viNombreQuittance   as integer  no-undo.

    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance:
        assign
            vdeMontantQuittance = truncate(round(vdeMontantQuittance + ttRub.dMontantQuittance, 2), 2)
            viNombreQuittance   = viNombreQuittance + 1
        .
    end.
    /*--> Mise a Jour du Montant Total de la Quittance et nombre de rubriques */
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail
          and ttQtt.iNoQuittance = giNumeroQuittance:
        assign
            ttQtt.dMontantQuittance = vdeMontantQuittance
            ttQtt.iNombreRubrique = viNombreQuittance
        .
    end.
end procedure.
