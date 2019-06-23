/*------------------------------------------------------------------------
File        : gereEvenement.p (ancien gerevent.p)
Description : 
Author(s)   : kantena - 2018/05/
Notes       :
derniere revue: 2018/06/19 - phm: KO
        traiter le todo
        reprise non terminée
----------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}

define variable gcCode as character no-undo initial "01039,01030,01033,01003,01004,01059,01045".
    /* {glbgi_df.i} */

function donneLotsContrat returns character(pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcListeDesLots as character no-undo.
    define variable viNumeroMandat as integer   no-undo.
    define variable viNumeroUL     as integer   no-undo.
    define buffer intnt for intnt.
    define buffer local for local.
    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer dtlot for dtlot.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-titre2copro}
        then for each intnt no-lock   /* Mandat */
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-lot}
              and (if pcTypeContrat = {&TYPECONTRAT-titre2copro} then intnt.nbden = 0 else true)
          , each local no-lock
            where local.noloc = intnt.noidt:
            vcListeDesLots = vcListeDesLots + "," + string(local.nolot).
        end.
        when {&TYPECONTRAT-bail} then do:   /* Bail */
            assign 
                viNumeroMandat = truncate(piNumeroContrat / 100000, 0)
                viNumeroUL     = truncate((piNumeroContrat modulo 100000) / 100, 0)
            .
            for each unite no-lock
                where unite.nomdt = viNumeroMandat
                  and unite.noapp = viNumeroUL
                  and unite.noact = 0
              , each cpuni no-lock
                where cpuni.nomdt = unite.nomdt
                  and cpuni.noapp = unite.noapp
                  and cpuni.nocmp = unite.nocmp:
                vcListeDesLots = vcListeDesLots + "," + string(cpuni.nolot).
            end.
        end.
        when {&TYPEINTERVENTION-signalement}     or when {&TYPEINTERVENTION-demande2devis}
        or when {&TYPEINTERVENTION-reponseDevis} or when {&TYPEINTERVENTION-ordre2service}
        or when {&TYPEINTERVENTION-facture}
        then for each dtlot no-lock
            where dtlot.tptrt = pcTypeContrat 
              and dtlot.notrt = piNumeroContrat
          , first local no-lock
            where local.noloc = dtlot.noloc:
            vcListeDesLots = vcListeDesLots + "," + string(local.nolot).
        end.
    end case.
    return trim(vcListeDesLots, ",").
end function.

function rechercheTiers returns integer private(pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer vbRoles for roles.
    /* Recherche du numero de tiers */
    for first vbRoles no-lock
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = piNumeroRole:
        return vbRoles.notie.
    end.
    return 0.
end function.

procedure evenementCreer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service appelé par creationDocumentCourrier.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole         as character no-undo.
    define input parameter piNumeroRole       as int64     no-undo.
    define input parameter piAction           as integer   no-undo.
    define input parameter pcTypeDocument     as character no-undo.
    define input parameter piNumeroDocument   as int64     no-undo.
    define input parameter pcTypeContrat      as character no-undo.
    define input parameter piNumeroContrat    as integer   no-undo.
    define input parameter pcObjet            as character no-undo.
    define input parameter piRoleDestinataire as integer   no-undo.
    define input parameter tmp-cron           as logical   no-undo. // THK : initialement des shared variables tmp-cron
    define input-output parameter poCollection as class Collection no-undo.

    define variable viNumeroEvenement       as integer   no-undo.
    define variable viNumeroTiers           as integer   no-undo.
    define variable viNumeroImmeuble        as integer   no-undo.
    define variable vdaRealisationSuivante  as date      no-undo.
    define variable viEvenementReference    as integer   no-undo.
    define variable viEvenementCreer        as int64     no-undo.
    define variable vcTypeContratRef        as character no-undo.    /* Contrat de référence */
    define variable viNumeroContratRef      as integer   no-undo.
    define variable vcTypeContratOrigine    as character no-undo.    /* contrat à l'origine de l'évènement */
    define variable viNumeroContratOrigine  as integer   no-undo.
    define variable vcTypeContratBlocNote   as character no-undo initial {&TYPECONTRAT-blocNote}.
    define variable viNumeroContratBlocNote as integer   no-undo.
    define variable vcLibelleEvenement      as character no-undo.
    define variable viInterTravaux          as integer   no-undo. /* No intervention travaux à l'origine de l'évènement */
    define variable vcCodeThemeDocum        as character no-undo.
    define variable vcCodeThemeGenDos       as character no-undo.
    define variable viPourSprecifique       as integer   no-undo.
    define variable vdaDateEveRef           as date      no-undo.
    define variable viHeureEveRef           as integer   no-undo.
    define variable viTdebut                as int64     no-undo. /* DM 1016/0127 */

    define buffer tpeve   for tpeve.
    define buffer vbTpeve for tpeve.
    define buffer docum   for docum.
    define buffer inter   for inter.
    define buffer desev   for desev.
    define buffer prmtv   for prmtv.
    define buffer ordse   for ordse.
    define buffer dtord   for dtord.
    define buffer dtdev   for dtdev.
    define buffer signa   for signa.
    define buffer devis   for devis.
    define buffer intnt   for intnt.
    define buffer vbEvent for event.

    assign
        viEvenementReference   = poCollection:getInteger("EVENT-EVENTENCOURS")
        viEvenementCreer       = poCollection:getInt64("EVENEMENT_CREE")
        vcTypeContratOrigine   = pcTypeContrat
        viNumeroContratOrigine = piNumeroContrat
        viNumeroTiers          = rechercheTiers(pcTypeRole, piNumeroRole)
    .

/* MLog("Entrée dans Gerevent.p avec :"
        + "%s TpActSel = " + TpActSel 
        + "%s pcTypeRole = " + pcTypeRole 
        + "%s piNumeroRole = " + STRING(piNumeroRole)
        + "%s TpEveSel = " + TpEveSel    
        + "%s NoActSel = " + STRING(NoActSel)
        + "%s pcTypeDocument = " + pcTypeDocument
        + "%s piNumeroDocument = " + STRING(piNumeroDocument)
        + "%s TpConSel = " + TpConSel
        + "%s NoConSel = " + STRING(NoConSel)
        + "%s Objet/nomod/noevessd(LbObjSel) = " + LbObjSel
        + "%s Gestionnaire(NoRolPou) = " + STRING(NoRolPou)
        + "%s <EVENT-EVENTENCOURS> = " + STRING(NoEveRef)
        + "%s <EVENEMENT_CREE> = " + DonneParametre("EVENEMENT_CREE")
        ).
*/

    /* Recherche des identifiants */
    run rechercheIdentifiant(pcTypeContrat, piNumeroContrat, pcTypeRole, output vcTypeContratRef, output viNumeroContratRef, output viNumeroImmeuble).
/*
            MLog("CREER - après RechIdent :" 
                + "%s viNumeroTiers = " + STRING(viNumeroTiers)
                + "%s NoActSel = " + STRING(NoActSel)
                + "%s pcTypeRole = " + pcTypeRole
                + "%s EVENT-EVENTENCOURS = " + DonneParametre("EVENT-EVENTENCOURS")
                ).
*/
    if (viNumeroTiers = 0 or piAction = 0) and pcTypeRole <> "FOU" then return.
    /* Ajout SY le 20/02/2013 - fiche 0113/0091 : si "FOU" alors recherche du contrat Bloc-notes comme Contrat par défaut */
    if pcTypeRole = "FOU" then do:
        viNumeroContratBlocNote = 0.
        for first intnt no-lock 
            where intnt.tpidt = pcTypeRole
              and intnt.noidt = piNumeroRole
              and intnt.tpcon = vcTypeContratBlocNote:
            viNumeroContratBlocNote = intnt.nocon.
        end.
    end.
    case pcTypeDocument:
        when "DOCUM" then do:
            /* Date de réalisation */
            for first docum no-lock
                where docum.nodoc = piNumeroDocument:
                assign
                    vdaRealisationSuivante = docum.tbdat[3]
                    vcCodeThemeDocum       = docum.cCodeTheme
                .
            end.
            /* Recherche element courant */
            find first vbEvent exclusive-lock
                 where vbEvent.nodoc = piNumeroDocument
                   and vbEvent.tprol = pcTypeRole
                   and vbEvent.norol = piNumeroRole no-error.
        end.
        when "SSDOS" then do:
            assign 
                vcLibelleEvenement = ""
                viInterTravaux     = 0
            .
            if vcTypeContratOrigine >= {&TYPEINTERVENTION-signalement} and vcTypeContratOrigine <= {&TYPEINTERVENTION-facture} then do:
                case vcTypeContratOrigine:
                    when {&TYPEINTERVENTION-signalement} then do:
                        for first inter no-lock
                            where inter.nosig = viNumeroContratOrigine
                          , first signa no-lock 
                            where signa.nosig = inter.nosig:
                            assign
                                vcLibelleEvenement = inter.lbint
                                viInterTravaux     = inter.noint
                                vcCodeThemeDocum   = signa.lbdiv1
                            .
                        end.
                    end.
                    when {&TYPEINTERVENTION-demande2devis} then do:
                        for first dtdev no-lock
                            where dtdev.nodev = viNumeroContratOrigine
                          , first devis no-lock 
                            where devis.nodev = viNumeroContratOrigine
                          , first inter no-lock
                            where inter.noint = dtdev.noint:
                            assign
                                vcLibelleEvenement = inter.lbint
                                viInterTravaux     = inter.noint
                                vcCodeThemeDocum   = devis.lbdiv1
                            .
                        end.
                    end.
                    when {&TYPEINTERVENTION-ordre2service} then do:
                        for first dtord no-lock
                            where dtord.noord = viNumeroContratOrigine
                          , first ordse no-lock where ordse.noord = viNumeroContratOrigine
                          , first inter no-lock
                            where inter.noint = dtord.noint:
                            assign
                                vcLibelleEvenement = inter.lbint
                                viInterTravaux     = inter.noint
                                vcCodeThemeDocum   = ordse.lbdiv1
                            .
                        end.
                    end.
                end case.
            end.
            for first tpeve no-lock
                where tpeve.noact = piAction:
                /* Historiser les evenements précédents */
                assign
                    /* Date de realisation suivante */
                    vdaRealisationSuivante = if tpeve.utdel = "00002" then add-interval(today, tpeve.nbdel, "months") else (today + tpeve.nbdel)
                    vdaDateEveRef          = ?
                    viHeureEveRef          = 0
                .
                if viEvenementReference <> 0
                then for first vbEvent no-lock
                    where vbEvent.noeve = viEvenementReference:
                    assign
                        vdaDateEveRef = vbEvent.dtcsy
                        viHeureEveRef = vbEvent.hecsy
                    .
                end.
                mLogger:writeLog(9, substitute("HISTORISATION (EVENT-EVENTENCOURS): NoEveRef = &1 dtEveRef = &2 heEveRef = &3", viEvenementReference, vdaDateEveRef, viHeureEveRef)).

                for each vbTpeve no-lock
                    where vbTpeve.noord < tpeve.noord
                      and vbTpeve.cdsdo = tpeve.cdsdo
                  , first vbEvent exclusive-lock
                    where vbEvent.noact = vbTpeve.noact
                      and vbEvent.dtree = ?
                      and vbEvent.tprol = pcTypeRole
                      and vbEvent.norol = piNumeroRole
                      and vbEvent.tpcon = pcTypeContrat
                      and vbEvent.nocon = piNumeroContrat
                      and vbEvent.dtcsy = (if vdaDateEveRef <> ? then vdaDateEveRef else vbEvent.dtcsy) /* PL Ajout 24/11/2010 */
                      and vbEvent.hecsy = (if viHeureEveRef <> 0 then viHeureEveRef else vbEvent.hecsy) /* PL Ajout 24/11/2010 */:
                    /* Modif Sy le 15/12/2008 : Action terminÚe comme dans geseveob.p */
                    assign
                        vbEvent.cdsta = "00003"
                        vbEvent.dttrm = today
                        vbEvent.hetrm = time
                        vbEvent.cdtrm = mtoken:cUser
                        vbEvent.dtmsy = today
                        vbEvent.hemsy = time
                        vbEvent.cdmsy = mtoken:cUser
                    .
                    mLogger:writeLog(9, substitute(
                                        "CREER SSDOS: NoActSel = &1 tpeve.cdsdo = &2 event.noeve = &3 event.noact = &4 event.tprol = &5 event.norol = &6 event.tpcon = &7 event.nocon = &8",
                                        piAction, tpeve.cdsdo, vbEvent.noeve, vbEvent.noact, vbEvent.tpRol, vbEvent.norol, vbEvent.tpcon, vbEvent.nocon)).
                    mLogger:writeLog(9, substitute(
                                        "CREER SSDOS: event.notie = &1 event.noimm = &2 event.lbobj = &3 event.noint = &4 tpeve.noord = &5 vdaRealisationSuivante = &6",
                                        vbEvent.notie, vbEvent.noimm, vbEvent.lbobj, vbEvent.noint, vbTpeve.noord, vdaRealisationSuivante)).
                end.
            end.
            /* Recherche element courant */ 
            find first vbEvent exclusive-lock
                where vbEvent.nossd = piNumeroDocument
                  and vbEvent.tprol = pcTypeRole
                  and vbEvent.norol = piNumeroRole no-error.
            /* action */
            find first tpeve no-lock
                where tpeve.noact = piAction no-error.
        end.
    end case.
    if not available vbEvent then do:
        assign
//          vlAnomalie = false
            viTdebut = etime(true)
        .
boucle:
        repeat:
            find last vbEvent exclusive-lock no-error no-wait.
            if locked vbEvent then do:
                find last vbEvent no-lock no-error.
                if available vbEvent
                then mLogger:writeLog(9, substitute(outilTraduction:getLibelle(1000923),                        // 1000923 0 "Dernier event (&1) verrouillé, créé par &2 le &3 à &4"
                                         vbEvent.noeve, vbEvent.cdcsy, vbEvent.dtcs, string(vbEvent.hecsy,"HH:MM:SS"))).
                if etime - viTdebut >= 6000         /* au bout de 6 secondes --> message */
                and not tmp-cron then do:
                    // todo à reprendre
                    mError:createError({&error},
                            substitute(outilTraduction:getLibelle(1000924), // 1000924 0 "Le dernier évenement (N° &1) est verrouillé, créé par &2 le &3 à &4.&5OK pour continuer le traitement, ou annuler"
                            vbEvent.noeve, vbEvent.cdcsy, vbEvent.dtcs, string(vbEvent.hecsy, "HH:MM:SS"), chr(10))).
                    return.
                end.
                pause 1.
                next boucle.
            end.
            leave boucle.
        end.
        viNumeroEvenement = if available vbEvent then vbEvent.noeve + 1 else 1.
        // todo   NON. PAS D'ACCORD. CELA DOIT ETRE DU A UN TRIGGER.
        /* A SUPPRIMER
        /* pour être plus sûr du résultat car retourne 1 par moments chez Dauchez */
        if viNumeroEvenement = 1 then do:
            do viBoucle = 1 to 5:
                find last vbEvent no-lock no-error.
                viNumeroEvenement = if available vbEvent then vbEvent.noeve + 1 else 1.
                if viNumeroEvenement <> 1 then leave.
            end.
            /* S'il est encore à 1 on vérifie que le 1 n'existe pas déjà */
            if viNumeroEvenement = 1 then do:
                find first vbEvent no-lock
                    where vbEvent.noeve = 1 no-error.
                if available(vbEvent) then do:
                    message "Tentative de création de l'évènement n° 1 qui existe déjà."
                            + chr(10) + "Informations à transmettre à la GI :"
                            + chr(10) + "Programme = gerevent.p"
                            + chr(10) + "pcTypeRole = "       + string(pcTypeRole)
                            + chr(10) + "piNumeroRole = "     + string(piNumeroRole)
                            + chr(10) + "pcTypeContrat = "    + string(pcTypeContrat)
                            + chr(10) + "piNumeroContrat = "  + string(piNumeroContrat)
                            + chr(10) + "viNumeroTiers = "    + string(viNumeroTiers)
                            + chr(10) + "pcObjet = "          + string(pcObjet)
                            + chr(10) + "pcTypeDocument = "   + string(pcTypeDocument)
                            + chr(10) + "pcTypeAction = CREER"
                            + chr(10) + "piAction = "         + string(piAction)
                            + chr(10) + "viNumeroImmeuble = " + string(viNumeroImmeuble)
                            + chr(10) + chr(10) + chr(10) + "Le traitement va continuer."
                            view-as alert-box warning
                            title "Problème sur l'accès à la table 'event'..."
                    .
                    vlAnomalie = true.
                end.
            end.
        end.
        if not vlAnomalie then do:
        */
        create vbEvent.
        assign
            vbEvent.dtcsy = today
            vbEvent.hecsy = time
            vbEvent.cdcsy = mtoken:cUser
            vbEvent.noeve = viNumeroEvenement
            vbEvent.noact = piAction
            vbEvent.TpRol = pcTypeRole
            vbEvent.NoRol = piNumeroRole
            vbEvent.TpCon = pcTypeContrat
            vbEvent.NoCon = piNumeroContrat
            vbEvent.NoTie = viNumeroTiers
            vbEvent.NoImm = viNumeroImmeuble
            vbEvent.tpeve = "E"
            vbEvent.dtdeb = today
            vbEvent.hedeb = time
            vbEvent.hefin = time
        .
        /* Modif Sy le 20/02/2013 0113/0091 */
        if vbEvent.tprol = "FOU" and (vbEvent.tpcon = "" or vbEvent.nocon = 0) 
        then assign
            vbEvent.tpcon = vcTypeContratBlocNote 
            vbEvent.nocon = viNumeroContratBlocNote 
        .
        assign
            vbEvent.ntact = "00002"
            vbEvent.dtsui = vdaRealisationSuivante
            vbEvent.lbmes = ""
            vbEvent.lbrep = ""
            vbEvent.nbtps = 0
            vbEvent.cdsta = "00001"
            vbEvent.lbobj = entry(1, pcObjet, separ[1])
            vbEvent.tpmod = "00004"
            vbEvent.tpdoc = "00002"
            vbEvent.tpsui = "00001"
        .
        /* Modif Sy le 20/03/2008 : ajout no modele sous-dossier derriÞre le libellÚ pour stockage dans evenvbEventod */                    
        if num-entries(pcObjet, separ[1]) >= 2 then vbEvent.nomod = integer(entry(2, pcObjet, separ[1])).

        /* Modif Sy le 23/09/2010 : ajout no evenement associé au sous-dossier maitre derrière le (libellé + zone sous dossier) pour stockage dans vbEvent.noevessd (Version > 10.25) */   
// TODO   c'est quoi ce commentaire?? then find first ?
        if num-entries(pcObjet , separ[1]) >= 3 then 
                /* vbEvent.noevessd = INT( ENTRY(3 , LbObjSel , separ[1]) ).*/    /* pour version > V10.25 */

        find first prmtv no-lock
            where prmtv.tppar = "MDSUI"
              and prmtv.fgdef no-error.
        if available prmtv then vbEvent.tpsui = prmtv.cdpar.
        if available tpeve
        then assign            /* Ajout Sy le 03/11/2008 */ 
            vbEvent.lbobj = if vcLibelleEvenement > ""
                          then vcLibelleEvenement
                          else if tpeve.lbcom > "" then tpeve.lbcom else vbEvent.lbobj
            vbEvent.tpmod = entry(1, tpeve.lbdiv1, SEPAR[1])
        .
        case pcTypeDocument:
            when "DOCUM" then vbEvent.nodoc = piNumeroDocument.
            when "SSDOS" then vbEvent.nossd = piNumeroDocument.
        end case.
        /* Ajout Sy le 06/11/2008 : */
        vbEvent.noint = viInterTravaux.
/*                 MLog("CREATE Event : "
                    + "%s LbObjeve = " + string(LbObjeve)
                    + "%s event.noeve = " + string(vbEvent.noeve)
                    + "%s event.noact = " + string(vbEvent.noact)
                    + "%s event.TpRol = " + string(vbEvent.TpRol)
                    + "%s event.NoRol = " + string(vbEvent.NoRol)
                    + "%s event.TpCon = " + string(vbEvent.TpCon)
                    + "%s event.NoCon = " + string(vbEvent.NoCon)
                    + "%s event.NoTie = " + string(vbEvent.NoTie)
                    + "%s event.NoImm = " + string(vbEvent.NoImm)
                    + "%s event.lbobj = " + string(vbEvent.lbobj)
                    + "%s event.noint = " + string(vbEvent.noint)
                    + "%s <EVENEMENT_CREE> = " + DonneParametre("EVENEMENT_CREE")
                    ).
*/
        /* Creation du destinataire pour */
        if piRoleDestinataire = 0 then piRoleDestinataire = mtoken:iCollaborateur.

        /* Surcharge du pour si nécessaire */
        if viPourSprecifique <> 0 then piRoleDestinataire = viPourSprecifique. 
        if piRoleDestinataire <> 0 then do:
            create desev.
            assign
                desev.noeve = viNumeroEvenement
                desev.tprol = "00047"
                desev.norol = piRoleDestinataire
                desev.tpdes = "00001"
            .
//              MLog("CREATE desev (Pour) : " + string(NoRolPou) + " pour event no " + string(viNumeroEvenement) + " - viPourSprecifique = " + string(viPourSprecifique)).
        end.
        /* Créer les liens Intervenants - Taches pour les actions associées à une Tache Alerte */
        run creLienInt(piAction, viNumeroEvenement).
        /* Si pas déjà fait on sauvegarde l'evt créé */
        if viEvenementCreer = 0 then poCollection:set("EVENEMENT_CREE", vbEvent.noeve).
        /* end. fin if not(lAnomalie) */
    end.
//    if not vlAnomalie and available vbEvent then do:
    /* Gestion des "informations" sur l'évènement */
    assign
        vbEvent.norfi       = viNumeroImmeuble
        vbEvent.tprfc       = vcTypeContratRef
        vbEvent.norfc       = viNumeroContratRef
        vbEvent.nolot       = if vcTypeContratOrigine >= {&TYPEINTERVENTION-signalement} and vcTypeContratOrigine <= {&TYPEINTERVENTION-facture}
                            then donneLotsContrat(vcTypeContratOrigine, viNumeroContratOrigine)
                            else donneLotsContrat(pcTypeContrat, piNumeroContrat)
    /* ***** Faut-il vraiment modifier le thème de l'évènement si celui do document est modifié ??   A voir à l'usage */
    /* Si on vient de la génération de dossier ou des travaux , il faut "surcharger" le thème par celui
       de la génération de dossier ou celui des travaux */
        vcCodeThemeGenDos = ""
        vbEvent.cCodeTheme  = vcCodeThemeDocum
        vcCodeThemeGenDos = poCollection:getCharacter("CODE-THEME")
    .
/*                MLog ("CREATE Event : " + string(vbEvent.NoEve) + " - Role " + vbEvent.TpRol + "/" + string(vbEvent.NoRol) + " - Tpcon/nocon = " + vbEvent.TpCon + "/" + string(vbEvent.NoCon) + " Objet = " + LbObjSel                
                    + "%s TpActSel    = " + string(TpActSel) 
                    + "%s TpEveSel    = " + string(TpEveSel)
                    + "%s NoActSel    = " + string(NoActSel)
                    + "%s pcTypeDocument    = " + string(pcTypeDocument)
                    + "%s piNumeroDocument    = " + string(piNumeroDocument)
                    + "%s TpConSel    = " + string(TpConSel)
                    + "%s NoConSel    = " + string(NoConSel)
                    + "%s event.tprfc = " + string(vbEvent.tprfc)
                    + "%s event.norfc = " + string(vbEvent.norfc)
                    + "%s event.nolot = " + string(vbEvent.nolot)
                    + "%s <EVENEMENT_CREE> = " + DonneParametre("EVENEMENT_CREE")
                    ).
*/
    if vcCodeThemeGenDos > "" and vcCodeThemeDocum = "" then vcCodeThemeDocum = vcCodeThemeGenDos.
//    end.

end procedure.

procedure suppressionRole:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: "SUPPR-ROLE"
    todo   attention,  non utilisée ????
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeDocument   as character no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as integer   no-undo.

    define variable viTypeRole as integer no-undo.
    define buffer vbEvent for event.

    case pcTypeDocument:
        when "DOCUM" then for each vbEvent exclusive-lock
            where vbEvent.nodoc = piNumeroDocument
              and vbEvent.tprol = pcTypeRole
              and vbEvent.norol = piNumeroRole:
            run evenementSuppression(buffer vbEvent).        // todo   procédure renommée ???
        end.
        when "SSDOS" then for each vbEvent exclusive-lock
            where vbEvent.nossd = piNumeroDocument
              and vbEvent.tprol = pcTypeRole
              and vbEvent.norol = piNumeroRole:
            run evenementSuppression(buffer vbEvent).        // todo   procédure renommée ???
        end.
        when "" then do:
            viTypeRole = integer(pcTypeRole) no-error.
            if error-status:error or (viTypeRole > 0 and viTypeRole < 1000)
            then for each vbEvent exclusive-lock
                where vbEvent.tprol = pcTypeRole
                  and vbEvent.norol = piNumeroRole:
                run evenementSuppression(buffer vbEvent).    // todo   procédure renommée ???
            end.
            else if viTypeRole > 1000 and viTypeRole < 2000
            then for each vbEvent exclusive-lock
                where vbEvent.tpcon = pcTypeRole
                  and vbEvent.nocon = piNumeroRole:
                run evenementSuppression(buffer vbEvent).    // todo   procédure renommée ???
            end.
            else if viTypeRole = 2001
            then for each vbEvent exclusive-lock
                where vbEvent.noimm = piNumeroRole:
                run evenementSuppression(buffer vbEvent).    // todo   procédure renommée ???
            end.
        end.
    end case.

end procedure.

procedure supprimer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: "SUPPR"
    todo   attention,  non utilisée ????
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeDocument   as character no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as integer   no-undo.

    define variable viTypeRole as integer no-undo.
    define buffer vbEvent for event.

    case pcTypeDocument:
        when "DOCUM" then for each vbEvent exclusive-lock
            where vbEvent.nodoc = piNumeroDocument:
            run evenementSuppression.
        end.
        when "SSDOS" then for each vbEvent exclusive-lock
            where vbEvent.nossd = piNumeroDocument
              and vbEvent.tprol = pcTypeRole
              and vbEvent.norol = piNumeroRole:
            run evenementSuppression.
        end.
        when "" then do:
            viTypeRole = integer(pcTypeRole) no-error.
            if error-status:error or (viTypeRole > 0 and viTypeRole < 1000)
            then for each vbEvent exclusive-lock
                where vbEvent.tprol = pcTypeRole
                  and vbEvent.norol = piNumeroRole:
                run evenementSuppression.
            end.
            else if viTypeRole > 1000 and viTypeRole < 2000
            then for each vbEvent exclusive-lock
               where vbEvent.tpcon = pcTypeRole
                 and vbEvent.nocon = piNumeroRole:
                run evenementSuppression.
            end.
            else if viTypeRole = 2001
            then for each vbEvent exclusive-lock
                where vbEvent.noimm = piNumeroRole:
                run evenementSuppression.
            end.
        end.
    end case.
end procedure.

procedure evenementArchi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: "ARCHI"
    todo   attention,  non utilisée ????
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeDocument   as character no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as integer   no-undo.
 
    define buffer vbEvent for event.
 
    case pcTypeDocument:
        when "DOCUM" then for each vbEvent exclusive-lock
            where vbEvent.nodoc = piNumeroDocument:
            assign
                vbEvent.cdsta = "00002"
                vbEvent.dtree = today
                vbEvent.heree = time
                vbEvent.cdree = mtoken:cUser
                vbEvent.dtmsy = today
                vbEvent.hemsy = time
                vbEvent.cdmsy = mtoken:cUser
            .
/*
            MLog("ARCHI DOCUM : "
                + "%s piNumeroDocument = " + string(piNumeroDocument)
                + "%s event.noeve = " + string(vbEvent.noeve)
                + "%s event.noact = " + string(vbEvent.noact)
                + "%s event.TpRol = " + string(vbEvent.TpRol)
                + "%s event.NoRol = " + string(vbEvent.NoRol)
                + "%s event.TpCon = " + string(vbEvent.TpCon)
                + "%s event.NoCon = " + string(vbEvent.NoCon)
                + "%s event.NoTie = " + string(vbEvent.NoTie)
                + "%s event.NoImm = " + string(vbEvent.NoImm)
                + "%s event.lbobj = " + string(vbEvent.lbobj)
                + "%s event.noint = " + string(vbEvent.noint)
                ).
*/
        end.
        when "SSDOS" then for each vbEvent exclusive-lock
            where vbEvent.nossd = piNumeroDocument
              and vbEvent.tprol = pcTypeRole
              and vbEvent.norol = piNumeroRole:
            assign
                vbEvent.cdsta = "00002"
                vbEvent.dtree = today
                vbEvent.heree = time
                vbEvent.cdree = mtoken:cUser
                vbEvent.dtmsy = today
                vbEvent.hemsy = time
                vbEvent.cdmsy = mtoken:cUser
            .
/*          
               MLog("ARCHI SSDOS : "
                    + "%s piNumeroDocument = " + string(piNumeroDocument)
                    + "%s pcTypeRole = " + string(pcTypeRole)
                    + "%s piNumeroRole = " + string(piNumeroRole)
                    + "%s event.noeve = " + string(vbEvent.noeve)
                    + "%s event.noact = " + string(vbEvent.noact)
                    + "%s event.TpRol = " + string(vbEvent.TpRol)
                    + "%s event.NoRol = " + string(vbEvent.NoRol)
                    + "%s event.TpCon = " + string(vbEvent.TpCon)
                    + "%s event.NoCon = " + string(vbEvent.NoCon)
                    + "%s event.NoTie = " + string(vbEvent.NoTie)
                    + "%s event.NoImm = " + string(vbEvent.NoImm)
                    + "%s event.lbobj = " + string(vbEvent.lbobj)
                    + "%s event.noint = " + string(vbEvent.noint)
                        ).
*/
        end.
    end case.

end procedure.

procedure evenementContrat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: "MODCT"
    todo   attention,  non utilisée ????
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as integer   no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter pcTypeRole       as character no-undo.

    define variable vcTypeContratRef   as character no-undo.
    define variable viNumeroImmeuble   as integer   no-undo.
    define variable viNumeroContratRef as integer   no-undo.

    define buffer vbEvent for event.

    /* Modif Sy le 10/04/2008 : on ne touche plus aux infos identifiant (tpcon,nocon,noimm)       */
    /* si elles sont renseignées mais on met à jour les infos "référence" des évènements du document */
    for each vbEvent exclusive-lock
        where vbEvent.nodoc = piNumeroDocument:
        if lookup(pcTypeContrat, gcCode) > 0 
        then assign
            vbEvent.tprfc = pcTypeContrat
            vbEvent.norfc = piNumeroContrat
            vbEvent.nolot = DonneLotsContrat(pcTypeContrat, piNumeroContrat)
        . 
        if vbEvent.nocon = 0 then do:
            /* Recherche des identifiants */
            run rechercheIdentifiant(pcTypeContrat, piNumeroContrat, pcTypeRole, output vcTypeContratRef, output viNumeroContratRef, output viNumeroImmeuble).
            assign
                vbEvent.tpcon = pcTypeContrat
                vbEvent.nocon = piNumeroContrat
                vbEvent.noimm = viNumeroImmeuble
            .
        end. 
/*
        MLog("Modif Event - MODCT : "
            + "%s event.noeve = " + string(vbEvent.noeve)
            + "%s event.noact = " + string(vbEvent.noact)
            + "%s event.TpRol = " + string(vbEvent.TpRol)
            + "%s event.NoRol = " + string(vbEvent.NoRol)
            + "%s event.TpCon = " + string(vbEvent.TpCon)
            + "%s event.NoCon = " + string(vbEvent.NoCon)
            + "%s event.Tprfc = " + string(vbEvent.Tprfc)
            + "%s event.Norfc = " + string(vbEvent.Norfc)
            + "%s event.NoImm = " + string(vbEvent.NoImm)
            ).
*/
    end.

end procedure.

procedure evenementImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: "MODIM"
    todo   attention,  non utilisée ????
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter piNumeroImmeuble as int64     no-undo.

    define buffer vbEvent for event.
 
    for each vbEvent exclusive-lock
        where vbEvent.nodoc = piNumeroDocument:
        assign
            vbEvent.norfi = piNumeroImmeuble
            vbEvent.noimm = (if vbEvent.noimm = 0 then piNumeroImmeuble else vbEvent.noimm)
        .
    end.
end procedure.

procedure evenementTheme:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: "MODTM"
    todo   attention,  non utilisée ????
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeDocument   as character no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter pcCodeTheme       as character no-undo.

    define variable vcCodeThemeDocum  as character no-undo.
    define buffer docum for docum.
    define buffer vbEvent for event.

    if pcTypeDocument = "DOCUM" then do:
        /* ***** Faut-il vraiment modifier le thème de l'évènement si celui du document est modifié ??
                 A voir à l'usage */
        /* Si on vient de la génération de dossier, il faut "surcharger"
           le thème par celui de la génération de dossier */
        if pcCodeTheme > "" and vcCodeThemeDocum = "" then vcCodeThemeDocum = pcCodeTheme.
        find first docum no-lock
            where docum.nodoc = piNumeroDocument no-error.
        if available docum then vcCodeThemeDocum = docum.cCodeTheme.
        for each vbEvent exclusive-lock
            where vbEvent.nodoc = piNumeroDocument:
            vbEvent.cCodeTheme = vcCodeThemeDocum.
        end.
    end.

end procedure.

procedure evenementDate:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: "MODDATE"
    todo   attention,  non utilisée ????
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeDocument   as character no-undo.
    define input parameter piNumeroDocument as integer   no-undo.

    define variable vdaSui as date no-undo.
    define buffer docum   for docum.
    define buffer vbEvent for event.

    if pcTypeDocument = "DOCUM" then do:
        /* Date de réalisation */
        for first docum no-lock
            where docum.nodoc = piNumeroDocument:
            vdaSui = docum.tbdat[3].
        end.
        for each vbEvent exclusive-lock 
            where vbEvent.nodoc = piNumeroDocument:
            vbEvent.dtsui = vdaSui.
        end.
    end.
end procedure.

procedure rechercheIdentifiant private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat      as character no-undo.
    define input  parameter piNumeroContrat    as int64     no-undo.
    define input  parameter pcTypeRole         as character no-undo.
    define output parameter pcTypeContratRef   as character no-undo.
    define output parameter piNumeroContratRef as int64     no-undo.
    define output parameter piNumeroImmeuble   as integer   no-undo.

    define variable viNumeroMandat as integer no-undo.

    define buffer ctctt for ctctt.
    define buffer signa for signa.
    define buffer intnt for intnt.
    define buffer inter for inter.
    define buffer dtord for dtord.
    define buffer devis for devis.
    define buffer ordse for ordse.
    define buffer dtdev for dtdev.

    /* par défaut contrat de référence = contrat en entrée si dans liste autorisée (c.f. geseveob.p)  */
    if lookup(pcTypeContrat, gcCode) > 0 
    then assign
        pcTypeContratRef   = pcTypeContrat
        piNumeroContratRef = piNumeroContrat
    .
    /* Recherche du numero d'immeuble */
    case pcTypeContrat:
        when {&TYPECONTRAT-mutation} or when {&TYPECONTRAT-titre2copro} or when {&TYPECONTRAT-DossierMutation} then do:
            for first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat
              , first intnt no-lock 
                where intnt.tpcon = ctctt.tpct1
                  and intnt.nocon = ctctt.noct1
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                assign
                    viNumeroMandat   = ctctt.noct1
                    piNumeroImmeuble = intnt.noidt
                .
            end.
            /* Modif Sy le 26/03/2008: contrat de référence pour Vendeur = le Titre de copropriété */
            if pcTypeContrat = {&TYPECONTRAT-DossierMutation} and pcTypeRole = {&TYPEROLE-vendeur} and viNumeroMandat <> 0 
            then assign
                pcTypeContratRef   = {&TYPECONTRAT-titre2copro}
                piNumeroContratRef = viNumeroMandat * 100000 + integer(pcTypeRole)
            .
        end.
        when {&TYPEINTERVENTION-signalement} then for first inter no-lock
            where inter.nosig = piNumeroContrat
          , first signa no-lock 
            where signa.nosig = piNumeroContrat
          , first intnt no-lock
            where intnt.tpcon = inter.tpcon
              and intnt.nocon = inter.nocon
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            assign
                piNumeroImmeuble = intnt.noidt
                pcTypeContrat    = intnt.TpCon
                piNumeroContrat  = intnt.NoCon
            .
            /** 0306/0215 **/
            run rechercheContratReference(piNumeroContrat, signa.tpidt-fac, signa.noidt-fac, output pcTypeContratRef, output piNumeroContratRef).
        end.
        when {&TYPEINTERVENTION-demande2devis} then for first dtdev no-lock
            where dtdev.nodev = piNumeroContrat
          , first devis no-lock 
            where devis.nodev = piNumeroContrat
          , first inter no-lock 
            where inter.noint = dtdev.noint
          , first intnt no-lock
            where intnt.tpcon = inter.tpcon
              and intnt.nocon = inter.nocon
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            assign
                piNumeroImmeuble = intnt.noidt
                pcTypeContrat    = intnt.TpCon
                piNumeroContrat  = intnt.NoCon
            .
            /** 0306/0215 **/
            run rechercheContratReference(piNumeroContrat, devis.tpidt-fac, devis.noidt-fac, output pcTypeContratRef, output piNumeroContratRef).
        end.
        when {&TYPEINTERVENTION-ordre2service} then for first dtord no-lock
            where dtord.noord = piNumeroContrat
          , first ordse no-lock where ordse.noord = piNumeroContrat
          , first inter no-lock
            where inter.noint = dtord.noint
          , first intnt no-lock
            where intnt.tpcon = inter.tpcon
              and intnt.nocon = inter.nocon
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            assign
                piNumeroImmeuble = intnt.noidt
                pcTypeContrat    = intnt.TpCon
                piNumeroContrat  = intnt.NoCon
            .
            /** 0306/0215 **/
            run rechercheContratReference(piNumeroContrat, ordse.tpidt-fac, ordse.noidt-fac, output pcTypeContratRef, output piNumeroContratRef).
        end.
        otherwise for first intnt no-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            piNumeroImmeuble = intnt.noidt.
        end.
    end case.
end procedure.
 
procedure rechercheContratReference private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat     as integer   no-undo.
    define input  parameter pcTypeIdFacture    as character no-undo.
    define input  parameter piNumeroIdFacture  as int64     no-undo.
    define output parameter pcTypeContratRef   as character no-undo.
    define output parameter piNumeroContratRef as int64     no-undo.

    define buffer ctrat for ctrat.
    define buffer ctctt for ctctt.

    piNumeroContratRef = piNumeroIdFacture.
    case pcTypeIdFacture:
        when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance} then pcTypeContratRef = pcTypeIdFacture.
        when {&TYPEROLE-locataire} then pcTypeContratRef = {&TYPECONTRAT-bail}.
        when {&TYPEROLE-coproprietaire} then do:
            pcTypeContratRef = {&TYPECONTRAT-titre2copro}.
            for each ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-titre2copro}
                  and ctrat.tprol = {&TYPEROLE-coproprietaire}
                  and ctrat.norol = integer(piNumeroIdFacture)
              , first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.noct1 = piNumeroMandat
                  and ctctt.tpct2 = ctrat.tpcon
                  and ctctt.noct2 = ctrat.nocon:
                piNumeroContratRef = ctrat.nocon.
            end.
        end.
    end case.

end procedure.

procedure evenementSupprimer private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    todo   attention,  non utilisée car une partie de l'ancien code n'est pas repris ????
    ------------------------------------------------------------------------------*/
    define parameter buffer pbEvent for event.

    define buffer desev for desev.
    define buffer tbfic for tbfic.
    define buffer gadet for gadet.
    define buffer evtev for evtev.

    for each desev exclusive-lock
        where desev.noeve = pbEvent.noeve:
        delete desev.
    end.
    for each tbfic exclusive-lock
        where tbfic.tpidt = {&TYPECONTRAT-evenement}
          and tbfic.noidt = pbEvent.noeve:
        os-delete value(tbfic.lbdiv).    // todo  Est-ce bien ça ?
        delete tbfic.
    end.

    /* Ajout Sy le 07/12/2006 : suppression détail alertes */
    for each gadet exclusive-lock
        where gadet.tpctt = {&TYPECONTRAT-evenement}
          and gadet.noctt = pbEvent.noeve
          and gadet.tpct1 = pbEvent.tpcon
          and gadet.noct1 = pbEvent.nocon:
        // todo   whole-index !
        delete gadet.
    end.

    /* Ajout SY le 25/02/2013 */
    for each evtev exclusive-lock
        where evtev.noev1 = pbEvent.noeve:
        delete evtev.
    end.
    for each evtev exclusive-lock
        where evtev.noev2 = pbEvent.noeve:
        // todo   whole-index !
        delete evtev.
    end.
    delete pbEvent.

end procedure.

procedure CreLienInt private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de crÚation des liens intervenants-tache sur toutes les actions
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piAction          as integer no-undo.
    define input parameter piNumeroEvenement as integer no-undo.

    define variable vcCodeSousDomaine as character no-undo.
    define buffer tpeve for tpeve.
    define buffer ctrat for ctrat.
    define buffer gatac for gatac.
    define buffer intnt for intnt.
    define buffer desev for desev.

    find first tpeve no-lock
        where tpeve.noact = piAction no-error.
    if not available tpeve then return.
    vcCodeSousDomaine = tpeve.cdsdo.

    for each tpeve no-lock 
        where Tpeve.cdsdo = vcCodeSousDomaine:
        find first gatac no-lock
            where gatac.notac = tpeve.notac no-error.
        if not available gatac
        then find first gatac no-lock
            where gatac.crite = "50011"
              and gatac.tpctt = {&TYPECONTRAT-evenement} no-error. 
        if available gatac then do:
            /* Boucle destinataires ("pour") */
            for each desev no-lock
                where desev.noeve = piNumeroEvenement
                  and desev.tpdes = "00001":
                if mtoken:iGestionnaire <> 4
                then for each intnt no-lock                    /* Pour toutes les AGENCES du destinataire */
                    where intnt.tpcon = {&TYPECONTRAT-serviceGestion}
                      and intnt.tpidt = desev.tprol
                      and intnt.noidt = desev.norol
                  , first ctrat no-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon:
                    run creMajgaint(desev.tprol, desev.norol, intnt.nocon, buffer gatac).
                end.
                else run creMajgaint(desev.tprol, desev.norol, 0, buffer gatac).
            end.
        end.
    end.
end procedure.

procedure creMajGaint private:
    /*------------------------------------------------------------------------------
    Purpose: création et mise à jour d'un enregistrement "intervenants - gestion alertes"
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as integer   no-undo.
    define input parameter piNumeroAgence      as integer   no-undo.
    define parameter buffer gatac for gatac.

    define variable viProchainNumeroOrdre as integer   no-undo.
    define buffer gaint for gaint.

    if not can-find(first gaint no-lock
        where gaint.tpidt  = pcTypeIdentifiant
          and gaint.noidt  = piNumeroIdentifiant
          and gaint.agence = piNumeroAgence
          and gaint.notac  = gatac.notac) then do:
        /* Recherche prochain no d'ordre Uti-Tache */
        viProchainNumeroOrdre = 1.
        find last gaint no-lock 
            where gaint.tpidt  = pcTypeIdentifiant
              and gaint.noidt  = piNumeroIdentifiant
              and gaint.agence = piNumeroAgence
              and gaint.notac  = gatac.notac no-error.
        if available gaint then viProchainNumeroOrdre = gaint.noord + 1.
        create gaint.
        assign 
            gaint.tpidt  = pcTypeIdentifiant
            gaint.noidt  = piNumeroIdentifiant
            gaint.agence = piNumeroAgence
            gaint.notac  = gatac.notac
            gaint.noord  = viProchainNumeroOrdre
            gaint.cdper  = gatac.cdper
            gaint.nojou  = gatac.nojou
            gaint.smnum  = gatac.smnum
            gaint.smjou  = gatac.smjou
            gaint.delta  = gatac.delta
            gaint.cddur  = gatac.cddur
            gaint.deltm  = gatac.deltm
            gaint.hduree = gatac.hduree
            gaint.mduree = gatac.mduree
        .
    end.

end procedure.
