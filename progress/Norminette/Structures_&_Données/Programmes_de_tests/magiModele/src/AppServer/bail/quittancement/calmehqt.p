/*-----------------------------------------------------------------------------
File        : calmehqt.p
Purpose     : Module de calcul de la rubrique de quittancement 111 pour l'application de la majoration méhaignerie
Author(s)   : SY - 2004/05/04, Kantena - 2017/12/15
Notes       : reprise de adb/src/quit/calmehqt.p
derniere revue: 2018/08/14 - phm: OK

01 23/04/1996  SP    Ajout calcul du nbre de rubriques de la quit.
02 09/05/1996  SP    Correction calcul du nombre de rubriques
03 09/05/1996  LG    Correction probleme "erreur saisie 0":chaine vcListeRubrique à blanc.
04 21/05/1996  SP    Vérification si la tache Majoration mehaignerie à été prise en charge
05 18/06/1996  LG    Calcul du montant total quittancé par rapport à la période de quittancement.
06 26/03/1998  LG    Modif calcul montant majoré: * giCodePeriodeQuittancement et non diviser.
07 23/12/1998  SY    Gestion Fin MEHAIGNERIE
08 03/08/1999  AF    Mehaignerie sur 12 ans
09 19/10/1999  SY    AGF/ALLIANZ: Ajout Validation séparée des échus => Nlle variable GlMoiMEc = 1er mois modifiable des échus                         º
10 27/04/2001  SY    Fiche 1200/1353: Gauriau... Gestion du début de majoration meh à une date différente
                     du 1er du mois avec présentation calculs sur 2 rubriques
                         111.xx: palier de l'année
                         114.xx: Avoir (ou rappel ?) chgt palier
11 04/06/2002  SY    Fiche 0502/1190: AGF Correction pb perte rub 111 dans le dernie mois de MEH:
                     on ne peut arreter la MEH que s'il n'y a pas de quittance en attente de validation avant le mois où on cumule la 111 & la 101
12 30/08/2005  SY    0805/0142 Essai optimisation remplacement lectache par FIND (bof)
13 12/12/2006  SY    0905/0335: plusieurs libellés autorisés pour les rubriques loyer si param RUBML
                     ATTENTION: nouveaux param entrée/sortie pour majlocrb.p
14 21/05/2007  SY    0507/0155: correction erreur trt fin meh suite modifs fiche 0905/0335
15 08/08/2007  SY    0905/0335: regroupement avec event/calmehqt.p => NOUVEAUX PARAMETRES ENTREE/SORTIE
16 16/12/2008  SY    TrtFinMeh: Gestion date de fin d'application rub loyer si pas de multi-libellé uniquement
17 21/09/2009  SY    0909/0115: TrtFinMeh - Proc. renouvellement gestion no libellé rubrique 101: 01 ou 15
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/param2locataire.i}

// rubrique loyer
&scoped-define NoRub101 101
// rubrique de quittancement
&scoped-define NoRub111 111
// rubrique Avoir/Rappel majoration
&scoped-define NoRub114 114

using parametre.pclie.parametrageRubriqueLibelleMultiple.
{oerealm/include/instanciateTokenOnModel.i}          // Doit être positionnée juste après using

{crud/include/rubqt.i}
{tache/include/tache.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{outils/include/lancementProgramme.i}                // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm      as class collection no-undo.
define variable goCollectionContrat        as class collection no-undo.
define variable goRubriqueLibelleMultiple  as class parametrageRubriqueLibelleMultiple no-undo.
define variable ghProc                     as handle    no-undo.
define variable gcTypeBail                 as character no-undo.
define variable giNumeroBail               as integer   no-undo.
define variable giMoisModifiable           as integer   no-undo.
define variable giMoisEchu                 as integer   no-undo.
define variable giMoisQuittancement        as integer   no-undo.
define variable giNumeroQuittance          as integer   no-undo.
define variable gdaDebutPeriode            as date      no-undo.
define variable gdaFinPeriode              as date      no-undo.
define variable gdaDebutQuittancement      as date      no-undo.
define variable gdaFinQuittancement        as date      no-undo.
define variable giCodePeriodeQuittancement as integer   no-undo.
define variable glRepercussion             as logical   no-undo.
define variable giNombreJourQuittance      as integer   no-undo.
define variable giNombreJourPeriode        as integer   no-undo.
define variable gdeMontantPeriode          as decimal   no-undo.
define variable gdeMontantQuittance        as decimal   no-undo.
define variable giNombreRubrique           as integer   no-undo.
define variable gdeMontantRubrique         as decimal   no-undo.
define variable giNumeroLibelle            as integer   no-undo.
define variable gdeMontant                 as decimal   no-undo.
define variable ghProcRubqt                as handle    no-undo.
define variable ghProcDate                 as handle    no-undo.
define variable ghProcTache                as handle    no-undo.
define variable ghRelationTache            as handle    no-undo.

procedure lancementCalmehqt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter poCollectionContrat   as class collection no-undo.
    define input parameter poCollectionQuittance as class collection no-undo.
    define input parameter plRepercussion        as logical no-undo.
    define input-output parameter table for ttQtt.
    define input-output parameter table for ttRub.

    assign
        gcTypeBail                 = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroBail               = poCollectionContrat:getInt64("iNumeroContrat")
        giMoisModifiable           = poCollectionContrat:getInteger("iMoisModifiable")
        giMoisEchu                 = poCollectionContrat:getInteger("iMoisEchu")
        giMoisQuittancement        = poCollectionContrat:getInteger("iMoisQuittancement")
        giNumeroQuittance          = poCollectionQuittance:getInteger("iNumeroQuittance")
        gdaDebutPeriode            = poCollectionQuittance:getDate("daDebutPeriode")
        gdaFinPeriode              = poCollectionQuittance:getDate("daFinPeriode")
        gdaDebutQuittancement      = poCollectionQuittance:getDate("daDebutQuittancement")
        gdaFinQuittancement        = poCollectionQuittance:getDate("daFinQuittancement")
        giCodePeriodeQuittancement = poCollectionQuittance:getInteger("iCodePeriodeQuittancement")
        glRepercussion             = plRepercussion
        goCollectionContrat         = poCollectionContrat
        goCollectionHandlePgm      = new collection()
        goRubriqueLibelleMultiple  = new parametrageRubriqueLibelleMultiple()
        ghProcRubqt                = lancementPgm("crud/rubqt_CRUD.p", goCollectionHandlePgm)
        ghProcTache                = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm)
        ghProcDate                 = lancementPgm("application/l_prgdat.p", goCollectionHandlePgm)
        ghRelationTache            = lancementPgm("crud/cttac_CRUD.p", goCollectionHandlePgm)
    .

message "gga lancementCalmehqt " gcTypeBail "/" giNumeroBail "/" giNumeroQuittance "/" gdaDebutPeriode "/" gdaFinPeriode "/" gdaDebutQuittancement "/"
                             gdaFinQuittancement "/" giCodePeriodeQuittancement "/" glRepercussion "/" giMoisModifiable "/" giMoisEchu "/" giMoisQuittancement. 


    run calmehqtPrivate.
    delete object goRubriqueLibelleMultiple.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure calmehqtPrivate private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define variable viDureeMajoration     as integer   no-undo.
    define variable viBoucle              as integer   no-undo.
    define variable vcListeMajoration     as character no-undo.
    define variable vdaDebutMajoration    as date      no-undo.
    define variable vdaFinMajoration      as date      no-undo.
    define variable vdaFinMehaignerie     as date      no-undo.
    define variable vdeMontantRubrique    as decimal   no-undo.
    define variable vdeTotalRubrique      as decimal   no-undo.
    define variable vdeTotalMajoration    as decimal   no-undo.
    define variable viCodeDureeMajoration as integer   no-undo.
    define variable vcListeRubrique       as character no-undo.
    define variable viNombreEncours       as integer   no-undo.
    define variable viNombreQuittance     as integer   no-undo.
    define variable viNumeroPremiere      as integer   no-undo.    /* No 1ère quittance en cours dans equit */
    define variable vitoto1               as integer   no-undo.    /* msqtt 1ère quittance en cours dans equit ?????? */
    define variable viNumeroLibelle       as integer   no-undo.

    define buffer equit for equit.
    define buffer tache for tache.
    define buffer cttac for cttac.
    /* Recherche si TOUTES les quittances chargées */
    /* Parcours des quittances en cours du locataire */
    {&_proparse_ prolint-nowarn(use-index)}

    for each equit no-lock
        where equit.noLoc = giNumeroBail
        and ((equit.cdter = {&TERMEQUITTANCEMENT-avance} and equit.msqtt >= giMoisModifiable)
          or (equit.cdter = {&TERMEQUITTANCEMENT-echu} and equit.msqtt >= giMoisEchu))
        by equit.msqtt by equit.nomdt:
        assign
            viNombreEncours  = viNombreEncours + 1
            viNumeroPremiere = (if viNumeroPremiere = 0 then equit.noqtt else viNumeroPremiere)
            vitoto1          = (if vitoto1 = 0 then equit.msqtt else vitoto1)
        .
    end.
    /* Parcours des quittances Chargées du locataire */
    for each ttQtt
        where ttQtt.iNumeroLocataire = giNumeroBail:
        viNombreQuittance = viNombreQuittance + 1.
    end.
    /* Suppression de tous les enreg concernant la quittance dans ttRub pour la rubrique 111
       Majoration loyer et la rubrique 114 Avoir/Rappel majoration */
    for each ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and (ttRub.iNorubrique = {&NoRub111} or ttRub.iNorubrique = {&NoRub114}):
        assign
            gdeMontantQuittance = gdeMontantQuittance + ttRub.dMontantQuittance
            giNombreRubrique    = giNombreRubrique + 1
        .
        delete ttRub no-error.
    end.
    /* Mise a jour du total de la quittance déduction du total des rubriques supprimées */
    assign
        gdeMontantQuittance = - gdeMontantQuittance
        giNombreRubrique    = - giNombreRubrique
    .
    run majttQtt.
    
    /* Vérification PEC de la tache Majoration */
    find first cttac no-lock
        where cttac.tpcon = gcTypeBail
          and cttac.nocon = giNumeroBail
          and cttac.tptac = {&TYPETACHE-majorationMermaz} no-error.  /* Type tâche : majoration méhaignerie */
    if not available cttac then return.

    assign
        giNombreJourPeriode   = gdaFinPeriode       - gdaDebutPeriode       + 1    /* Calcul de la durée de la période de quittancement */
        giNombreJourQuittance = gdaFinQuittancement - gdaDebutQuittancement + 1    /* Calcul de la durée de la quittance date à date */
    .
    /* Récupération des données dans la table TACHE */
    find last tache no-lock
        where tache.tpcon = gcTypeBail
          and tache.nocon = giNumeroBail
          and tache.tptac = {&TYPETACHE-majorationMermaz} no-error.
    if available tache then do:
        assign
            vdaFinMehaignerie     = tache.dtfin      /* Date de fin de la majoration MEH */
            viCodeDureeMajoration = tache.duree
        .
        do viBoucle = 3 to num-entries(tache.lbdiv, '#'):
            vcListeMajoration = vcListeMajoration + '|' + entry(viBoucle, tache.lbdiv, '#').
        end.
        vcListeMajoration = trim(vcListeMajoration, '|').

        /* Gestion Fin de Méhaignerie
         ³ ATTENTION: toute modif est à reporter dans isFinMeh.p */
        if (gdaDebutPeriode <= vdaFinMehaignerie and vdaFinMehaignerie < gdaFinPeriode)
        or vdaFinMehaignerie < gdaDebutPeriode then do:
            
            /* Récupération du montant mensuel réactualisé de l'année en cours */
            gdeMontantPeriode = 0.
boucleMajoration:
            do viBoucle = 1 to num-entries(vcListeMajoration, '|'):
                if date(entry(1, entry(viBoucle, vcListeMajoration, '|'), '@')) < vdaFinMehaignerie
                then gdeMontantPeriode = decimal(entry(3, entry(viBoucle, vcListeMajoration, '|'), '@')).
                else leave boucleMajoration.
            end.
            assign
                vdeTotalMajoration = gdeMontantPeriode * giCodePeriodeQuittancement
                gdeMontantRubrique = vdeTotalMajoration
            .
            /* Traitement fin seulement si on est sur la 1ère quittance en cours (attente valid ou non)
               ET TOUTES LES Quittances chargées: Cumul de la rub 111 avec le loyer et supprimer la tache et les liens */
            if viNombreQuittance = viNombreEncours and giNumeroQuittance = viNumeroPremiere and giMoisQuittancement >= vitoto1
            then run trtFinMeh.
            else do:    /* Sinon, rub 111-01 en attendant que la quittance soit dans le mois de traitement */
                assign
                    giNumeroLibelle = 01
                    gdeMontant      = gdeMontantRubrique
                    vcListeRubrique = substitute("&1@&2@&3", string(giNumeroLibelle, "99"), string(gdeMontantPeriode, "->,>>>,>>9.99"), string(gdeMontantRubrique, "->,>>>,>>9.99"))
                .
                run majttRub({&NoRub111}, 01).
            end.
            return.   /* Traitement terminé */
        end.
        /* Traitement des périodes de majoration */
        do viBoucle = 1 to num-entries(vcListeMajoration, '|'):
            vdaDebutMajoration = date(entry(1, entry(viBoucle, vcListeMajoration, '|'), '@')).
            /* Calcul de la date de fin de la majoration */
            run cl2DatFin in ghProcDate(vdaDebutMajoration, 1, '00001', output vdaFinMajoration).
            assign
                vdaFinMajoration  = vdaFinMajoration - 1
                viDureeMajoration = vdaFinMajoration - vdaDebutMajoration + 1                              /* Durée de la majoration */
                gdeMontantPeriode = decimal(entry(3, entry(viBoucle, vcListeMajoration, '|'), '@')) /* Récupération du montant mensuel réactualisé */
            .
            /* Appel à la procédure de traitement */
            run trtPrMaj(vdaDebutMajoration, vdaFinMajoration, viDureeMajoration, gdeMontantPeriode, gdaDebutPeriode, gdaFinPeriode, output vdeMontantRubrique, output vdeTotalRubrique).
            /* Cas où on a plusieurs majorations dans la quittance. */
            assign
                gdeMontantRubrique = gdeMontantRubrique + vdeMontantRubrique
                vdeTotalMajoration = vdeTotalMajoration + vdeTotalRubrique
            .
            /* Récupération du code libellé pour pouvoir afficher le libellé des différentes majorations(1ère année, 2ième, ...) */
            if vdeMontantRubrique <> 0 then do:
                case viCodeDureeMajoration:
                    when 3  then giNumeroLibelle = 02 + (viBoucle - 1).
                    when 6  then giNumeroLibelle = 05 + (viBoucle - 1).
                    when 8  then giNumeroLibelle = 11 + (viBoucle - 1).
                    when 12 then giNumeroLibelle = 19 + (viBoucle - 1).
                end case.
                vcListeRubrique = substitute("&1#&2@&3@&4", vcListeRubrique, string(giNumeroLibelle, "99"), string(gdeMontantPeriode, "->,>>>,>>9.99"), string(vdeMontantRubrique, "->,>>>,>>9.99")).
            end.
        end.

        if vcListeRubrique > "" then do:
            assign
                vcListeRubrique    = substring(vcListeRubrique, 2)   /* retirer le premier '#' */
                gdeMontantRubrique = round(gdeMontantRubrique, 2)       /* ne garder que 2 décimales */
                /* montant mensuel réactualisé de l'année en cours */
                gdeMontantPeriode  = decimal(entry(2, entry(num-entries(vcListeRubrique, '#'), vcListeRubrique, '#'), '@'))
                /* Mise à jour de ttRub (montant de l'annee) pour la dernière entrée de la chaine vcListeRubrique */
                viNumeroLibelle    = integer(entry(1, entry(num-entries(vcListeRubrique, '#'), vcListeRubrique, '#'), '@'))
            .
            if num-entries(vcListeRubrique, '#') > 1 or gdeMontantRubrique <> (gdeMontantPeriode * giCodePeriodeQuittancement) then do:
                gdeMontant = gdeMontantPeriode * giCodePeriodeQuittancement.
                run majttRub({&NoRub111}, viNumeroLibelle).
                /* Mise à jour de ttRub (Avoir changement annee) */
                gdeMontant = gdeMontantRubrique - (gdeMontantPeriode * giCodePeriodeQuittancement).
                run majttRub({&NoRub114}, if gdeMontant < 0 then 51 else 01).
            end.
            else do:
                gdeMontant = gdeMontantRubrique.
                run majttRub({&NoRub111}, viNumeroLibelle).
            end.
        end.
    end.
end procedure.

procedure calDatExp private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define output parameter pdaFinBail as date no-undo.

    define variable viNombreMois as integer  no-undo.
    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.TpCon = gcTypeBail
          and ctrat.NoCon = giNumeroBail no-error.
    if not available ctrat then do:
        mError:createError({&error}, 104132, string(giNumeroBail)).
        return.
    end.
    pdaFinBail = ctrat.dtfin.
    /* Si renouvellement pas encore fait: allonger la date de fin application
       sinon MajLocRb.p supprime les rubriques sur les quittances futures */
    if pdaFinBail <= gdaFinPeriode then assign
        viNombreMois = if ctrat.cddur = '00001' then 12 * ctrat.nbdur else ctrat.nbdur
        pdaFinBail   = add-interval(pdaFinBail, viNombreMois, "months")    /* Calculer la prochaine Date d'Expiration */
        pdaFinBail   = date(month(pdaFinBail), 28, year(pdaFinBail)) + 4
        pdaFinBail   = pdaFinBail - day(pdaFinBail)                        /* A FIN DE MOIS */
    .
end procedure.

procedure trtPrMaj private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui traite les périodes de majoration
    Notes   :
    ---------------------------------------------------------------------------*/
    define input parameter  pdaDebutMajoration     as date     no-undo.
    define input parameter  pdaFinMajoration       as date     no-undo.
    define input parameter  piNombreJourMajoration as integer  no-undo.
    define input parameter  pdeMontantPeriode      as decimal  no-undo.
    define input parameter  pdaDebutPriode         as date     no-undo.
    define input parameter  pdaFinPriode           as date     no-undo.
    define output parameter pdeMontantRubrique     as decimal  no-undo.
    define output parameter pdeMontantMajoration   as decimal  no-undo.

    define variable viDureeContrat    as integer no-undo.
    define variable viDureeMajoration as integer no-undo.

    /* Calcul du montant quittancé concernant la période. (partie gauche de clasqt01) */
    if (pdaDebutMajoration < gdaDebutQuittancement) and (pdaFinMajoration > gdaFinQuittancement)
    then viDureeContrat = giNombreJourQuittance.
    else if (pdaDebutMajoration >= gdaDebutQuittancement) and (pdaDebutMajoration <= gdaFinQuittancement)
         and (pdaFinMajoration >= gdaFinQuittancement)
         then viDureeContrat = (gdaFinQuittancement - pdaDebutMajoration) + 1.
         else if (pdaFinMajoration >= gdaDebutQuittancement) and (pdaFinMajoration <= gdaFinQuittancement)
              and (pdaDebutMajoration <= gdaDebutQuittancement)
              then viDureeContrat = (pdaFinMajoration - gdaDebutQuittancement) + 1.
              else if (pdaDebutMajoration >= gdaDebutQuittancement) and (pdaFinMajoration <= gdaFinQuittancement)
                   then viDureeContrat = piNombreJourMajoration.
    /* Montant quittancé */
    pdeMontantRubrique = (viDureeContrat / giNombreJourPeriode) * (pdeMontantPeriode * giCodePeriodeQuittancement).
    /* Calcul du montant total quittancé concernant la période.(partie droite de clasqt01) */
    if (pdaDebutMajoration < pdaDebutPriode) and (pdaFinMajoration > pdaDebutPriode)
    then viDureeMajoration = giNombreJourQuittance.
    else if (pdaDebutMajoration >= pdaDebutPriode) and (pdaDebutMajoration <= gdaFinPeriode)
         and (pdaFinMajoration >= pdaFinPriode)
         then viDureeMajoration = (pdaFinPriode - pdaDebutMajoration) + 1.
         else if (pdaFinMajoration >= pdaDebutPriode) and (pdaFinMajoration <= pdaFinPriode)
              and (pdaDebutMajoration <= pdaDebutPriode)
              then viDureeMajoration = (pdaFinMajoration - pdaDebutPriode) + 1.
              else if (pdaDebutMajoration >= pdaDebutPriode) and (pdaFinMajoration <= pdaFinPriode)
                   then viDureeMajoration = piNombreJourMajoration.
    /* Montant total quittancé */
    pdeMontantMajoration = (viDureeMajoration / giNombreJourPeriode) * (gdeMontantPeriode * giCodePeriodeQuittancement).

end procedure.

procedure majttQtt private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met à jour le montant quittance pour la rubrique dans ttQtt
    Notes   : pas de for first, le scope de ttQtt est global.
    ---------------------------------------------------------------------------*/
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

procedure trtFinMeh private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui effectue le traitement de fin de Majoration Méhaignerie (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    Notes   :
        - Cumul montant loyer et majoration finale dans rub loyer 101 (si inexistante: la créer)
        - Supprimer la tache méhaignerie et le lien
         Pb Procédures de renouvellement: lors de la phase Congés, tant que les négociations sont en cours et que le locataire
         n'est pas sorti il ne doit plus y avoir de rubrique Loyer (101.01) mais une "indemnité d'occupation" (101.15)
    ---------------------------------------------------------------------------*/
    define variable vdaFinBail       as date    no-undo.
    define variable vdaDebutRubrique as date    no-undo.
    define variable vdaFinRubrique   as date    no-undo.
    define variable vdaDebutAppel    as date    no-undo.
    define variable vdaFinAppel      as date    no-undo.
    define buffer vbttrub for ttRub.
    define buffer rubqt   for rubqt.

    if gdeMontantRubrique = 0 then return.

    /* Recherche date d'expiration (Fin THEORIQUE) */
    run calDatExp (output vdaFinBail).
    if mError:erreur() then return.

    /* Calcul dates d'application */
    assign
        vdaDebutRubrique = gdaDebutPeriode
        vdaFinRubrique   = vdaFinBail
        /* Verification existence de la rubrique Loyer */
        giNumeroLibelle  = 01
    .
    /* Modif Sy le 21/09/2009: recherche si cumul fin MEH sur rub loyer ou indemnité occupation */
    find first ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = {&NoRub101}
          and ttRub.iNoLibelleRubrique = 15 no-error.
    if available ttRub then giNumeroLibelle = 15.
    /* Positionnement sur la Rubrique 101.01 ou .15 */
    find first rubqt no-lock
        where rubqt.cdrub = {&NoRub101}
          and rubqt.cdlib = giNumeroLibelle no-error.
    if not available rubQt then do:
        mError:createError({&error}, 104126, "{&NoRub101}").
        return.
    end.
    find first ttRub
        where ttRub.iNumeroLocataire = giNumeroBail
          and ttRub.iNoQuittance = giNumeroQuittance
          and ttRub.iNorubrique = {&NoRub101}
          and ttRub.iNoLibelleRubrique = giNumeroLibelle no-error.
    if not available ttRub then do:
        /* Création rubrique loyer */
        create ttRub.
        assign
            vdaDebutAppel = vdaDebutRubrique
            ttRub.iNumeroLocataire = giNumeroBail
            ttRub.iNoQuittance = giNumeroQuittance
            ttRub.iNorubrique = {&NoRub101}
            ttRub.iNoLibelleRubrique = giNumeroLibelle
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
            ttRub.iFamille = rubqt.cdfam
            ttRub.iSousFamille = rubqt.cdsfa
            ttRub.cCodeGenre = rubqt.CdGen
            ttRub.cCodeSigne = rubqt.CdSig
            ttRub.CdDet = "0"
            ttRub.dQuantite = 0
            ttRub.dPrixunitaire = 0
            ttRub.dMontantTotal = gdeMontantRubrique
            ttRub.dMontantQuittance = gdeMontantRubrique
            ttRub.daDebutApplication = vdaDebutRubrique
            ttRub.daFinApplication = vdaFinRubrique
            ttRub.iNoOrdreRubrique = 0
            giNombreRubrique = 1
        .
        if available ttQtt
        then assign
            vdaFinAppel = ttQtt.daFinPeriode   /* date de fin quittance corrigée */
            ttRub.iProrata = ttQtt.iProrata   /* cdpro */
            ttRub.iNumerateurProrata = ttQtt.iNumerateurProrata   /* nbnum */
            ttRub.iDenominateurProrata = ttQtt.iDenominateurProrata   /* nbden */
        .
    end.
    else assign
        vdaDebutAppel    = ttRub.daDebutApplication
        vdaFinAppel      = ttRub.daFinApplication
        giNumeroLibelle  = ttRub.iNoLibelleRubrique
        /* Modification rubrique Loyer */
        ttRub.dMontantTotal      = ttRub.dMontantTotal + gdeMontantRubrique
        ttRub.dMontantQuittance      = ttRub.dMontantQuittance + gdeMontantRubrique
        ttRub.daFinApplication      = vdaFinRubrique
        giNombreRubrique = 0
    .
    /* Modification du montant de la quittance et nb rub dans ttQtt */
    gdeMontantQuittance = gdeMontantRubrique.
    run majttQtt.
    /* Verification existence de la rubrique avec un autre libellé dans les quittances futures */
    /* Modification SY le 16/12/2008: si pas de multi-libellé uniquement */
    if not goRubriqueLibelleMultiple:isLibelleMultiple()
    then for first vbttrub
        where vbttRub.iNumeroLocataire = giNumeroBail
          and vbttRub.iNoQuittance <> giNumeroQuittance
          and vbttRub.iNorubrique = {&NoRub101}
          and vbttRub.iNoLibelleRubrique <> giNumeroLibelle:
        ttRub.daFinApplication = vbttRub.daDebutApplication - 1. /* Ajustement date de fin d'application */
    end.
    if glRepercussion then do:
        /* Lancement du module de répercussion sur les quittances futures */
        ghProc = lancementPgm("bail/quittancement/majlocrb.p", goCollectionHandlePgm).
        run trtMajlocrb in ghProc(
            giNumeroBail,
            giNumeroQuittance,
            {&NoRub101},
            giNumeroLibelle,
            vdaDebutAppel,
            vdaFinAppel,
            "",
            input-output table ttQtt,
            input-output table ttRub
        ).
        if not mError:erreur() then run supTblTch.              /* Suppression de la tâche MEH */
    end.
end procedure.

procedure supTblTch private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui Supprime une tache
    Notes   :
    ---------------------------------------------------------------------------*/
    /* Utilisation L_Cttac pour Suppression. */
    run suppressionCttac in ghRelationTache(gcTypeBail, giNumeroBail, {&TYPETACHE-majorationMermaz}).
    if mError:erreur() then return.

    /* recuperation du numero interne de la tache en cours */
    empty temp-table ttTache.
    run getTache in ghProcTache(gcTypeBail, giNumeroBail, {&TYPETACHE-majorationMermaz}, table ttTache by-reference).
    find first ttTache no-error.
    if not available ttTache then do: 
        mError:createError({&error}, 100351).
        return.
    end.
    ttTache.crud = "D".
    run setTache in ghProcTache(table ttTache by-reference).

end procedure.

procedure majttRub private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure de création/Modification d'une rubrique
    Notes   : Récupération des infos dans RUBQT pour la dernière entrée de la chaine vcListeRubrique
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroRubrique as integer no-undo.
    define input  parameter piNumeroLibelle  as integer no-undo.

    empty temp-table ttRubqt.
    run readRubqt in ghProcRubqt(piNumeroRubrique, piNumeroLibelle, table ttRubqt by-reference).
    for first ttRubqt:
        create ttRub.
        assign
            ttRub.iNumeroLocataire = giNumeroBail
            ttRub.iNoQuittance = giNumeroQuittance
            ttRub.iFamille = ttrubqt.cdFam
            ttRub.iSousFamille = ttrubqt.cdsFa
            ttRub.iNorubrique = piNumeroRubrique
            ttRub.iNoLibelleRubrique = piNumeroLibelle
            ttRub.cLibelleRubrique = outilTraduction:getLibelle(ttrubqt.cdlib)
            ttRub.cCodeGenre = ttrubqt.cdgen
            ttRub.cCodeSigne = ttrubqt.cdsig
            ttRub.cdDet = "0"
            ttRub.dQuantite = 0
            ttRub.dPrixunitaire = 0
            ttRub.dMontantTotal = gdeMontant  /* vdeTotalMajoration*/
            ttRub.iProrata = 0
            ttRub.iNumerateurProrata = 0
            ttRub.iDenominateurProrata = 0
            ttRub.dMontantQuittance = gdeMontant
            ttRub.daDebutApplication = gdaDebutQuittancement
            ttRub.daFinApplication = gdaFinQuittancement
            ttRub.iNoOrdreRubrique = 0
            /* Modification du montant de la quittance. Dans ttQtt.dMontantQuittance */
            gdeMontantQuittance = gdeMontantRubrique
            giNombreRubrique    = 1
        .
        run majttQtt.
    end.
end procedure.
