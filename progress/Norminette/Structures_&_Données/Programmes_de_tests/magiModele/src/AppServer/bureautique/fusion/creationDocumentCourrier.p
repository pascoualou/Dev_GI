/*------------------------------------------------------------------------
File        : creationDocumentCourrier.p (ancien credocum.p)
Description : procédures et fonctions de création de documents pour le courrier.
Author(s)   : kantena - 2018/05/
Notes       :
derniere revue: 2018/08/17 - phm:
        cf  creationCorrespondance.i pour d'autres points.
----------------------------------------------------------------------*/
using parametre.pclie.parametrageTypeCentre.
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2tache.i}
{preprocesseur/typeAccord2Reglement.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
define variable ghProcEvent as handle  no-undo.
define variable giAction    as integer no-undo.

{adb/commun/service.i}
{adb/commun/gestionSignataire.i}                         // procedure donneSignataire
{bureautique/fusion/include/creationCorrespondance.i}    // diverses fonctions frm...

procedure creationDocumentCourrier:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service appelé par courrier.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat      as character no-undo.
    define input parameter piNumeroContrat    as integer   no-undo.
    define input parameter piModele           as integer   no-undo.
    define input parameter piGestionnaire     as integer   no-undo.
    define input parameter piNumeroTraitement as integer   no-undo.
    define input parameter pcParametre        as character no-undo.
    define input parameter pcDeviseEdition    as character no-undo.
    define input-output parameter poCollection as class collection no-undo.

    define variable viCompteur        as integer   no-undo.
    define variable viNumeroDocument  as integer   no-undo.
    define variable vcTypeRole        as character no-undo.
    define variable viNumeroRole      as integer   no-undo.
    define variable vcCodeSignataire1 as character no-undo.
    define variable vcCodeSignataire2 as character no-undo.
    define variable vcCodeTheme       as character no-undo.
    define variable vcNomCanevas      as character no-undo.
    define variable vcMandatSEPA      as character no-undo.    /* NP 1214/0256 */
    define variable vcNomModele       as character no-undo.
    define variable vcObjetDocument   as character no-undo.
    define variable vcTypeSignalement as character no-undo.
    define variable vcLogo            as character no-undo.
    define variable vcEntete          as character no-undo.
    define variable vcPied            as character no-undo.
    define variable viRoleSignataire1 as integer   no-undo.
    define variable viRoleSignataire2 as integer   no-undo.
    define variable viCollaborateur   as integer   no-undo.

    define buffer tache   for tache.
    define buffer ctctt   for ctctt.
    define buffer inter   for inter.
    define buffer ctrat   for ctrat.
    define buffer champ   for champ.
    define buffer desti   for desti.
    define buffer refgi   for refgi.
    define buffer dtdev   for dtdev.
    define buffer dtord   for dtord.
    define buffer acreg   for acreg.
    define buffer lidoc   for lidoc.
    define buffer lides   for lides.
    define buffer mddoc   for mddoc.
    define buffer docum   for docum.
    define buffer refcl   for refcl.
    /*    {fccredoc.i}    /* Fonction de generation de documents */  */
    /*    {isdirage.i}    /* 0109/0156 */    */
    /*    {fctsigna.i}    /* 0109/0156 */    */

    /*--ROLE-------------------------------------------------------------------------------------------------------------------*/
    if  pcTypeContrat <> {&TYPEINTERVENTION-signalement}  and pcTypeContrat <> {&TYPEINTERVENTION-demande2devis} and pcTypeContrat <> {&TYPEINTERVENTION-ordre2service} 
    and pcTypeContrat <> {&TYPEACCORDREGLEMENT-locataire} and pcTypeContrat <> {&TYPETACHE-cleMagnetiqueDetails} and pcTypeContrat <> {&TYPETACHE-garantieLocataire}
    and pcTypeContrat <> {&TYPETACHE-noteHonoraire}       and pcTypeContrat <> "06000"                           and pcTypeContrat <> {&TYPECONTRAT-MandatLocation}
    and num-entries(pcParametre, SEPAR[1]) <= 1 then do:
        /* Génération sous-dossier roles */
        find first ctrat no-lock
            where ctrat.tpcon = pcTypeContrat
              and ctrat.nocon = piNumeroContrat no-error.
        if not available ctrat then do:
            assign
                vcTypeRole   = pcTypeContrat
                viNumeroRole = piNumeroContrat
            .
            find first ctrat no-lock
                where ctrat.tprol = vcTypeRole
                  and ctrat.norol = viNumeroRole
                  and ctrat.dtree = ? no-error.
            if not available ctrat
            then find first ctrat no-lock
                where ctrat.tprol = vcTypeRole
                  and ctrat.norol = viNumeroRole no-error.
            if available ctrat
            then assign
                pcTypeContrat   = ctrat.tpcon
                piNumeroContrat = ctrat.nocon
            .
        end.
        else assign
            vcTypeRole   = ctrat.tprol
            viNumeroRole = ctrat.norol
        .
        if vcTypeRole <> "FOU"
        and not can-find(first roles no-lock
            where roles.tprol = vcTypeRole
              and roles.norol = viNumeroRole) then return.
    end.
    /*--SERVICE - SIGLE--------------------------------------------------------------------------------------------------------*/
    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic}  then run service(pcTypeContrat, piNumeroContrat, output vcTypeSignalement, output vcLogo, output vcEntete, output vcPied).
        when {&TYPECONTRAT-mandat2Gerance} then run service(pcTypeContrat, piNumeroContrat, output vcTypeSignalement, output vcLogo, output vcEntete, output vcPied).
        when {&TYPECONTRAT-titre2copro} or when {&TYPECONTRAT-bail}          or when {&TYPECONTRAT-preBail}
     or when {&TYPECONTRAT-Salarie}     or when {&TYPECONTRAT-SalariePegase} or when {&TYPECONTRAT-DossierMutation}
     or when {&TYPECONTRAT-fournisseur} then for first ctctt no-lock /* SY 0114/0244 */
            where ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat
              and (ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic} or ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}):
            run service(ctctt.tpct1, ctctt.noct1).
        end.
        when {&TYPETACHE-garantieLocataire} then for first tache no-lock
            where tache.noita = piNumeroContrat
          , first ctctt no-lock
            where ctctt.tpct2 = tache.tpcon
              and ctctt.noct2 = tache.nocon
              and ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}:
            run service(ctctt.tpct1, ctctt.noct1).
        end.
        when {&TYPEINTERVENTION-signalement} then for first inter no-lock
            where inter.nosig = piNumeroContrat:
            run service(inter.tpcon, inter.nocon, output vcTypeSignalement, output vcLogo, output vcEntete, output vcPied).
        end.
        when {&TYPEINTERVENTION-demande2devis} then for first dtdev no-lock
            where dtdev.nodev = piNumeroContrat
          , first inter no-lock
            where inter.noint = dtdev.noint:
            run service(inter.tpcon, inter.nocon, output vcTypeSignalement, output vcLogo, output vcEntete, output vcPied).
        end.
        when {&TYPEINTERVENTION-ordre2service} then for first dtord no-lock
            where dtord.noord = piNumeroContrat
          , first inter no-lock
            where inter.noint = dtord.noint:
            run service(inter.tpcon, inter.nocon, output vcTypeSignalement, output vcLogo, output vcEntete, output vcPied).
        end.
        when {&TYPEACCORDREGLEMENT-locataire} then for first acreg no-lock
            where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
              and acreg.nocon = piNumeroContrat
              and acreg.tplig = "0":
            run service(acreg.tpmdt, acreg.nomdt, output vcTypeSignalement, output vcLogo, output vcEntete, output vcPied).
        end.
        when {&TYPETACHE-noteHonoraire} then for last tache no-lock
            where tache.noita = piNumeroContrat
          , first ctctt no-lock
            where ctctt.tpct2 = tache.tpcon
              and ctctt.noct2 = tache.nocon
              and ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}:
            run service(ctctt.tpct1, ctctt.noct1, output vcTypeSignalement, output vcLogo, output vcEntete, output vcPied).
        end.
    end case.

    /* Pour rester compatible avec avant le passage par service.i */
    piGestionnaire = mToken:iGestionnaire.
    /*--TRAITEMENT-------------------------------------------------------------------------------------------------------------*/
    if piNumeroTraitement <> 0 then do:
        for each lidoc no-lock
           where lidoc.tpidt = vcTypeRole
             and lidoc.noidt = viNumeroRole
         , first docum no-lock
           where docum.nodoc = lidoc.nodoc
             and docum.nodot = piModele:
            if docum.notrt = piNumeroTraitement then return.
        end.
        if num-entries(pcParametre, SEPAR[1]) > 1 
        then do viCompteur = 1 to num-entries(pcParametre, SEPAR[2]):
            for each lidoc no-lock
                where lidoc.tpidt = entry(1, entry(viCompteur, pcParametre, SEPAR[2]), SEPAR[1])
                  and lidoc.noidt = integer(entry(2, entry(viCompteur, pcParametre, SEPAR[2]), SEPAR[1]))
              , first docum no-lock
                where docum.nodoc = lidoc.nodoc
                  and docum.nodot = piModele:
                if docum.notrt = piNumeroTraitement then return.
            end.
        end.
    end.
    
    /*--DOCUMENTS--------------------------------------------------------------------------------------------------------------*/
    for first mddoc no-lock 
        where mddoc.nodot = piModele:
        assign
            giAction        = mddoc.noact
            vcNomModele     = mddoc.lbdot
            vcObjetDocument = mddoc.lbcom
        .
        /* Ajout Sy le 14/12/2009 - initialisation des signataires (c.f. fiche 0109/0156 MICHEL LAURENT) */

        run donneSignataire(1, mtoken:cUser, output vcCodeSignataire1, output viRoleSignataire1). /* Signataire spécifique */
        //MagiToken:mLogger:writeLog(9, substitute("Utilisateur &1 - &2 : Signataire New 1 = &3 &4",
        //                               viCollaborateur, mtoken:cUser, viRoleSignataire1, vcCodeSignataire1)).
        if vcCodeSignataire1 = "?"
        then viRoleSignataire1 = (if piGestionnaire = 0 then viCollaborateur else piGestionnaire). /* Signataire standard */
        run donneSignataire(2, mtoken:cUser, output vcCodeSignataire2, output viRoleSignataire2). /* Signataire spécifique */
        //MagiToken:mLogger:writeLog(9, substitute("Utilisateur &1 - &2 : Signataire New 2 = &3 &4",
        //                               viCollaborateur, MagiToken:mtoken:cUser, viRoleSignataire2, vcCodeSignataire2)).
        if vcCodeSignataire2 = "?" then viRoleSignataire2 = (if piGestionnaire <> 0 then viCollaborateur else 0). /* Signataire standard */
        //MagiToken:mLogger:writeLog(9, substitute("Utilisateur &1 - &2 Signataires: 1 = &3 2 = &4",
        //                               viCollaborateur, MagiToken:mtoken:cUser, viRoleSignataire1, viRoleSignataire2)).

        {&_proparse_ prolint-nowarn(wholeIndex)}
        find last docum no-lock no-error.
        /* Récupération d'un éventuel thème si l'on vient de la génération de dossier */
        assign
            viNumeroDocument = if available docum then docum.nodoc + 1 else 1
            vcCodeTheme      = poCollection:getCharacter("CODE-THEME")
            vcNomCanevas     = poCollection:getCharacter("VISCOIMM-CANEVAS")
            vcMandatSEPA     = poCollection:getCharacter("VISCOIMM-MDTSEPA") /* NP 1214/0256 Récupération du spécifique MDTSEPA */
        .
        create docum.
        assign
            docum.nodoc      = viNumeroDocument
            docum.lbobj      = mddoc.lbcom
            docum.tbdat[1]   = today
            /*docum.noges    = piGestionnaire
            docum.nocol      = viCollaborateur*/    /* Modif SY le 14/12/2009 */
            docum.noges      = viRoleSignataire1 
            docum.nocol      = viRoleSignataire2
            docum.TbSig[1]   = vcTypeSignalement
            docum.tbsig[2]   = vcEntete
            docum.tbsig[3]   = vcLogo
            docum.tbsig[4]   = vcPied
            docum.nodot      = mddoc.nodot
            docum.notrt      = piNumeroTraitement
            docum.lbdiv      = pcDeviseEdition
            docum.noaction   = mddoc.noact       /* ajout SY le 14/04/2008 : maj no act (noaction) dans docum */
            docum.cCodeTheme = vcCodeTheme       /* Ajout PL le 28/01/2010 */
            docum.lbcav      = vcNomCanevas      /* Ajout PL le 11/04/2011 0411/0049 */
            /* ajout SY le 24/04/2009 */
            docum.dtcsy      = today
            docum.hecsy      = time
            docum.cdcsy      = mtoken:cUser
        .
        run creationDestinataire(buffer mddoc, pcTypeContrat, piNumeroContrat, viNumeroDocument, vcMandatSEPA, piGestionnaire, pcParametre, vcNomModele, vcObjetDocument, poCollection).
        /* Critere Supplementaire */
        do viCompteur = 1 to num-entries(mddoc.lbcrt, "."):
            /* C.F. PrcCritere dans fccredoc.i */
            run creationSousDossier(pcTypeContrat, piNumeroContrat, entry(viCompteur, mddoc.lbcrt, "."), viNumeroDocument, vcNomModele, vcObjetDocument).
        end.
        /* Code Remplir */
        find first refcl no-lock
            where refcl.nodot = mddoc.nodot no-error.
        if available refcl
        then for each refcl no-lock
            where refcl.nodot = mddoc.nodot
          , first champ no-lock
            where champ.nochp = refcl.nochp    // index unique sur nochp,
              and champ.tpchp = "00002"        // donc tpchp peut être mis dans le for first
          , each desti no-lock
            where desti.nodoc = viNumeroDocument:
            create lides.
            assign
                lides.nochp = champ.nochp
                lides.nodoc = viNumeroDocument
                lides.tprol = desti.tprol
                lides.norol = desti.norol
            .
        end.
        else for each refgi no-lock
            where refgi.nodot = mddoc.nodot
          , first champ no-lock
            where champ.nochp = refgi.nochp    // index unique sur nochp, 
              and champ.tpchp = "00002"        // donc tpchp peut être mis dans le for first
          , each desti no-lock
            where desti.nodoc = viNumeroDocument:
            create lides.
            assign
                lides.nochp = champ.nochp
                lides.nodoc = viNumeroDocument
                lides.tprol = desti.tprol
                lides.norol = desti.norol
            .
        end.
    end.
end procedure.

procedure creationDestinataire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer mddoc for mddoc.
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as integer   no-undo.
    define input parameter piNumeroDocument as integer   no-undo.
    define input parameter pcMandatSEPA     as character no-undo.
    define input parameter piGestionnaire   as integer   no-undo.
    define input parameter pcParametre      as character no-undo.
    define input parameter pcNomModele      as character no-undo.
    define input parameter pcObjetDocument  as character no-undo.
    define input parameter poCollection     as class Collection no-undo.

    define variable vcListeDesti as character no-undo.
    define variable vcLibelle    as character no-undo.
    define variable vcTypeRole   as character no-undo.
    define variable viNumeroRole as integer   no-undo.
    define variable vcCodeCatTmp as character no-undo.
    define variable viCompteur   as integer   no-undo.

    define buffer desti for desti.
    define buffer vbRoles for roles.
    define buffer tiers for tiers.
    define buffer lidoc for lidoc.
    define buffer ssdos for ssdos.

    if num-entries(pcParametre, SEPAR[1]) <= 1 then do:
        assign
            vcLibelle    = if pcParametre > ""
                           then entry(1, pcParametre, SEPAR[1])
                           else if entry(1, mddoc.lbdiv, "|") > "" then entry(1, mddoc.lbdiv, "|") else vcTypeRole
            vcCodeCatTmp = if num-entries(mddoc.lbdiv, "|") > 2 then entry(3, mddoc.lbdiv, "|") else "000"
        .
        case vcLibelle:
            when {&TYPEROLE-compagnieAssurance}       then vcListeDesti = frmCompagnie(pcTypeContrat, piNumeroContrat).
            when {&TYPEROLE-Avocat}
         or when {&TYPEROLE-gerantExterne}
         or when {&TYPEROLE-notaire}                  then vcListeDesti = frmAnnexe(vcLibelle).
                                                      /* Prise en compte du titre de copro au lieu du destinataire pour les courriers Mdt Prélèvmt SEPA only */
            when {&TYPEROLE-coproprietaire}           then vcListeDesti = if pcMandatSEPA = "TitreCopro" then frmCoproprietaire2() else frmCoproprietaire().
            when {&TYPEROLE-courtier}                 then vcListeDesti = frmCourtier(pcTypeContrat, piNumeroContrat).
            when {&TYPEROLE-garant}                   then vcListeDesti = frmGarant().
            when {&TYPEROLE-Huissier}                 then vcListeDesti = frmHuissier().
            when {&TYPEROLE-locataire}                then vcListeDesti = frmLocataire().
            when {&TYPEROLE-mandant}                  then vcListeDesti = frmMandant().
            when {&TYPEROLE-presidentConseilSyndical} then vcListeDesti = frmPresident(pcTypeContrat, piNumeroContrat).
            when {&TYPEROLE-membreConseilSyndical}    then vcListeDesti = frmMembre(pcTypeContrat, piNumeroContrat).
            when {&TYPEROLE-vendeur}                  then vcListeDesti = frmVendeur(pcTypeContrat, piNumeroContrat).
            when {&TYPEROLE-acheteur}                 then vcListeDesti = frmAcheteur(pcTypeContrat, piNumeroContrat).
            when {&TYPEROLE-salarie}
         or when {&TYPEROLE-salariePegase}            then vcListeDesti = frmSalarie(vcCodeCatTmp).
            when {&TYPEROLE-candidatLocataire}        then vcListeDesti = frmCandidatLocataire().
            when "FOU"   then vcListeDesti = frmFournisseur(pcTypeContrat, piNumeroContrat, vcCodeCatTmp).  /* Fournisseur                      */
            when "OAS"   then vcListeDesti = frmAssedic(pcTypeContrat, piNumeroContrat).    /* Assedic                          */
            when "OTS"   then vcListeDesti = frmCentrePaiement().                           /* Centre de Paiement               */
            when "ODB"
         or when "ORP"   then vcListeDesti = frmRecette(pcTypeContrat, piNumeroContrat).    /* Centre de Recette                */
            when "CAF"   then vcListeDesti = frmCAF(pcTypeContrat, piNumeroContrat).        /* CAF                              */
            when "CDI"   then vcListeDesti = frmCDI(pcTypeContrat, piNumeroContrat).        /* Centre des Impots                */
            when "SIE"   then vcListeDesti = frmSIE(pcTypeContrat, piNumeroContrat).        /* Centre Service de l'impot des entreprise */
            when "SIG"   then vcListeDesti = frmSignalePar(pcTypeContrat, piNumeroContrat). /* Signalé par                      */
        end case.
        if vcListeDesti = "" and entry(1, mddoc.lbdiv, "|") = "" 
        then vcListeDesti = vcTypeRole + SEPAR[1] + string(viNumeroRole).
    end.
    else vcListeDesti = pcParametre.

    if vcListeDesti > ""
    then do transaction viCompteur = 1 to num-entries(vcListeDesti, SEPAR[2]):
        assign
            vcTypeRole   = entry(1, entry(viCompteur, vcListeDesti, SEPAR[2]), SEPAR[1])
            viNumeroRole = integer(entry(2, entry(viCompteur, vcListeDesti, SEPAR[2]), SEPAR[1]))
        .
        if can-find(first desti no-lock
                    where desti.nodoc = piNumeroDocument
                      and desti.tprol = vcTypeRole
                      and desti.norol = viNumeroRole) then next.

        create desti.
        assign
            desti.nodoc = piNumeroDocument
            desti.tprol = vcTypeRole
            desti.norol = viNumeroRole
            desti.tpdes = "00001"
            desti.tpadr = "00001"
            desti.tptel = "00001"
            desti.tpmod = "00000"
        .
        /* Mode d'envoie par défaut */
        for first vbRoles no-lock
            where vbRoles.tprol = vcTypeRole
              and vbRoles.norol = viNumeroRole
          , first tiers no-lock
            where tiers.notie = vbRoles.notie:
            desti.tpmod = if mddoc.fgtie
                          then if tiers.tpmod > "" then tiers.tpmod else "00000"
                          else if mddoc.tpmod > "" then mddoc.tpmod else "00000".
        end.
        run bureautique/fusion/gereEvenement.p persistent set ghProcEvent.
        run getTokenInstance in ghProcEvent(mToken:JSessionId).
        run evenementCreer in ghProcEvent(desti.tprol, desti.norol, giAction, "DOCUM", desti.nodoc, pcTypeContrat, piNumeroContrat, mddoc.lbcom, piGestionnaire, true, input-output poCollection).
        run destroy in ghProcEvent.
        if not can-find(first ssdos no-lock
                        where ssdos.tpidt = vcTypeRole
                          and ssdos.noidt = viNumeroRole
                          and ssdos.nossd = 0) then do:
            create ssdos.
            assign
                ssdos.tpidt = vcTypeRole
                ssdos.noidt = viNumeroRole
                ssdos.nossd = 0
            .
        end.
        create lidoc.
        assign
            lidoc.tpidt = vcTypeRole
            lidoc.noidt = viNumeroRole
            lidoc.nossd = 0
            lidoc.nodoc = piNumeroDocument
            lidoc.dtcsy = today
            lidoc.hecsy = time
            lidoc.cdcsy = substitute('&1&2&3', mtoken:cUser, "@", "credocum.p")
        .
        MagiToken:mLogger:writeLog(9,
                                   substitute("CreDesti -CREATE lidoc: lidoc.nodoc = &1 modele &2 &3 Idt = &4 &5 lidoc.nossd = 0",
                                              lidoc.nodoc,
                                              pcNomModele,
                                              pcObjetDocument,
                                              lidoc.tpidt,
                                              lidoc.noidt)
                                  ).
    end.

end procedure.

procedure creationSousDossier private:
    /*------------------------------------------------------------------------------
    Purpose: Generation de sous-dossier à partir des critéres supplementaires
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat     as character no-undo.
    define input parameter piNumeroContrat   as integer   no-undo.
    define input parameter pcTypeIdentifiant as character no-undo.
    define input parameter piNumeroDocument  as integer   no-undo.
    define input parameter pcNomModele       as character no-undo.
    define input parameter pcObjetDocument   as character no-undo.

    define variable viNumeroRole       as integer no-undo.
    define variable viIdentifiant      as integer no-undo.
    define variable viNiveauPaiePegase as integer no-undo.
    define variable viTypeIdentifiant  as integer no-undo.
    define variable voPayePegase       as class parametre.pclie.parametragePayePegase no-undo.

    define buffer lidoc for lidoc.
    define buffer ssdos for ssdos.

    assign
        viIdentifiant = frmCritere(pcTypeContrat, piNumeroContrat, pcTypeIdentifiant, viNumeroRole)
        voPayePegase  = new parametre.pclie.parametragePayePegase()
    .
    if voPayePegase:isActif() then viNiveauPaiePegase = voPayePegase:int01.
    delete object voPayePegase.

    if pcTypeIdentifiant = {&TYPECONTRAT-preBail} and viIdentifiant = 0 
    then assign
        pcTypeIdentifiant = {&TYPECONTRAT-Bail}
        viIdentifiant     = FRMCRITERE(pcTypeContrat, piNumeroContrat, pcTypeIdentifiant, viNumeroRole)
    .
    if viIdentifiant <> 0 then do transaction:
        if pcTypeIdentifiant = substitute("&1+&2", {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-mandat2Syndic})
        or pcTypeIdentifiant = substitute("&1+&2+&3+&4", {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-bail}, {&TYPECONTRAT-mandat2Syndic}, {&TYPECONTRAT-Salarie})
        or pcTypeIdentifiant = substitute("&1+&2+&3+&4", {&TYPECONTRAT-mandat2Gerance}, {&TYPECONTRAT-bail}, {&TYPECONTRAT-mandat2Syndic}, {&TYPECONTRAT-SalariePegase})
        then pcTypeIdentifiant = pcTypeContrat.

        if viNiveauPaiePegase >= 2 and pcTypeIdentifiant = {&TYPECONTRAT-Salarie} /* SY 0114/0244 */ 
        then pcTypeIdentifiant = {&TYPECONTRAT-SalariePegase}.
        if not can-find(first ssdos no-lock
                        where ssdos.tpidt = pcTypeIdentifiant
                          and ssdos.noidt = viIdentifiant
                          and ssdos.nossd = 0) then do:
            create ssdos.
            assign
                ssdos.tpidt = pcTypeIdentifiant
                ssdos.noidt = viIdentifiant
                ssdos.nossd = 0
            .
        end.

        viTypeIdentifiant = integer(pcTypeIdentifiant) no-error.
        if not error-status:error and ((viTypeIdentifiant > 1000 and viTypeIdentifiant < 2000) or viTypeIdentifiant = 2001)
        then do:
            run bureautique/fusion/gereEvenement.p persistent set ghProcEvent.
            run getTokenInstance in ghProcEvent(mToken:JSessionId).
            if viTypeIdentifiant > 1000 and viTypeIdentifiant < 2000
            then run evenementContrat in ghProcEvent(pcTypeContrat, piNumeroContrat, piNumeroDocument, pcTypeIdentifiant).
            else run evenementImmeuble in ghProcEvent(piNumeroDocument, viIdentifiant).
            run destroy in ghProcEvent.
        end.
        create lidoc.
        assign
            lidoc.tpidt = pcTypeIdentifiant
            lidoc.noidt = viIdentifiant
            lidoc.nossd = 0
            lidoc.nodoc = piNumeroDocument
            lidoc.dtcsy = today
            lidoc.hecsy = time
            lidoc.cdcsy = substitute('&1&2', mtoken:cUser, "@credocum.p")
        .
        MagiToken:mLogger:writeLog(9,
                                   substitute("CreSsDos -CREATE lidoc : lidoc.nodoc = &1 modele &2 &3 Idt = &4 &5 lidoc.nossd = 0",
                                              lidoc.nodoc,
                                              pcNomModele,
                                              pcObjetDocument,
                                              lidoc.tpidt,
                                              lidoc.noidt)
                                  ).
    end.

end procedure.
