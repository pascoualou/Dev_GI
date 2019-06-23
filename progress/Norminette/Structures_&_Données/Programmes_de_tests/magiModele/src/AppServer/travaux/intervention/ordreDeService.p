/*------------------------------------------------------------------------
File        : ordreDeService.p
Purpose     :
Author(s)   : Kantena 2016/08/10
Notes       :
Tables      : BASE sadb : intnt inter imble ctrat dtord ordse prmtv artic lidoc
------------------------------------------------------------------------*/
{preprocesseur/rang2importance.i}
{preprocesseur/type2intervention.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/actionUtilisateur.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codestatutcontrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}

using parametre.pclie.parametragePayePegase.
using parametre.pclie.parametrageChaineTravaux.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{travaux/include/ordreDeService.i}
{travaux/include/detailsIntervention.i}
{tiers/include/tiers.i}
{application/include/glbsepar.i}
{application/include/error.i}

define variable ghTva         as handle no-undo.
define variable ghFournisseur as handle no-undo.

function getNextOrdre2Service returns logical private (piActionUtilisateur as integer, output piNextNumeroOS as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ordse for ordse.

    piNextNumeroOS = ((year(today) modulo 100) * 100  + month(today)) * 100000.
    find last ordse no-lock
        where ordse.NoOrd > piNextNumeroOS no-error.
    if available ordse
    then if ordse.NoOrd = piNextNumeroOS + 99999
        then do:
            mError:create2Error(piActionUtilisateur, 107713).
            return false.
        end.
        else piNextNumeroOS = ordse.NoOrd + 1.
    else piNextNumeroOS = piNextNumeroOS + 00001.
    return true.

end function.

function estCloture returns logical private (piNumeroTraitement as int64):
    /*------------------------------------------------------------------------------
    Purpose: L'ordre de service est-il clôturé ?
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer trint for TrInt.

    for last trint no-lock
       where trint.notrt = piNumeroTraitement
         and trint.tptrt = {&TYPEINTERVENTION-ordre2service}:
        return TrInt.CdSta = {&STATUTINTERVENTION-termine}.
    end.
    return false.
end function.

function DateDeValidite returns logical private (piCodeEtab as int64, pcColl-cle as character, pcNumeroCompte as character, pdaDate as date):
    /*------------------------------------------------------------------------------
    Purpose: Test des dates de validité
    Notes  : Le blocage au niveau du mandat est prioritaire sur celui au niveau global
    ------------------------------------------------------------------------------*/
    define variable vlErreur as logical no-undo.
    define buffer dtval for dtval.

    // Y a-t-il un blocage au niveau de tous les mandats sur ce compte ?
    find first dtval no-lock
        where dtval.soc-cd   = integer(mToken:cRefPrincipale)
          and dtval.etab-cd  = piCodeEtab
          and dtval.coll-cle = pcColl-cle
          and dtval.cpt-cd   = pcNumeroCompte no-error.
    if available dtval
    then do:
        if dtval.dadeb <> ? and dtval.dafin = ? and dtval.dadeb > pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 110926, string(dtval.dadeb, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dafin <> ? and dtval.dadeb = ? and dtval.dafin < pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 110927, string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dadeb <> ? and dtval.dafin <> ? and (dtval.dadeb > pdaDate or dtval.dafin < pdaDate)
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 110928, string(dtval.dadeb, "99/99/9999") + separ[1] + string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
    end.
    // Y a-t-il un blocage au niveau de tous les mandats sur ce compte ?
    else for first dtval no-lock
        where dtval.soc-cd   = integer(mToken:cRefPrincipale)
          and dtval.etab-cd  = 0
          and dtval.coll-cle = pcColl-cle
          and dtval.cpt-cd   = pcNumeroCompte:
        if dtval.dadeb <> ? and dtval.dafin = ? and dtval.dadeb > pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 109015, string(dtval.dadeb, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dafin <> ? and dtval.dadeb = ? and dtval.dafin < pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 109016, string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dadeb <> ? and dtval.dafin <> ? and (dtval.dadeb > pdaDate or dtval.dafin < pdaDate)
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 109017, string(dtval.dadeb, "99/99/9999") + separ[1] + string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
    end.
    return vlErreur.

end function.

function controleDeleteOrdreDeService returns logical private (piNumeroTraitement as int64, pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer ordse for ordse.
    define buffer dtord for dtord.
    define buffer inter for inter.
    define buffer doset for doset.

    for first ordse no-lock
        where ordse.noord = piNumeroTraitement:
        /*--> Suppression impossible si existence d'une facture sur cet ordre */
        for each dtord no-lock
           where dtord.noord = piNumeroTraitement
             and can-find(first dtfac no-lock where dtfac.noint = dtord.noint):
             mError:createError({&NIVEAU-erreur}, 104432).
             return false.
        end.
        /*--> Suppression impossible si existence d'un appel sans reponse voté */
        for each dtord no-lock
            where dtord.noOrd = piNumeroTraitement
          , first inter no-lock
            where inter.noint = dtord.noInt
          , first doset no-lock
            where doset.tpcon = pcTypeContrat
              and doset.nocon = piNumeroContrat
              and doset.nodos = inter.nodos
              and doset.noint = dtord.noint:
            if not can-find(first svdev no-lock where svdev.noint = dtord.noint and svdev.fgvot = true)
            then do:
                mError:createError({&NIVEAU-erreur}, 104432).
                return false.
            end.
        end.
    end.
    return true.

end function.

function controleValidationFournisseur returns logical private (pcTypeMandat as character, piNumeroContrat as int64, cCodeFournisseur as character, table ttError):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viSociete as integer no-undo.

    viSociete = mtoken:getSociete(pcTypeMandat).

    // Date de validité du fournisseur
    // dateDeValidite retourne TRUE si le fournisseur n'est plus valide et vérification du flag actif du fournisseur
    if dateDeValidite(piNumeroContrat, "F", cCodeFournisseur, today)
    or not dynamic-function('isActif' in ghFournisseur, pcTypeMandat, cCodeFournisseur) then return false.

    // Vérification du référencement du fournisseur
    // Cette fonction retourne FALSE si le référencement ne permet pas le traitement
    if not dynamic-function('isReference' in ghFournisseur, viSociete, cCodeFournisseur)
    then do:
        if can-find(first iparm no-lock where iparm.tppar = "REFERB" and iparm.cdpar = "01") /* avec blocage */
        then do:
            mError:createError({&NIVEAU-erreur}, 1000192).
            return false.
        end.
        else if outils:questionnaire(1000301, cCodeFournisseur, table ttError by-reference) <= 2
        then return false.
    end.
    return true.

end function.

function controleOrdre2Service returns logical private (pcMode as character, phBuffer as handle, table ttDetailsIntervention, table ttError):
    /*------------------------------------------------------------------------------
    purpose: pcMode = C, U ou D
    Note   :
    ------------------------------------------------------------------------------*/
    define variable vdeMontantTotal as decimal   no-undo.
    define variable voChaineTravaux as class parametrageChaineTravaux no-undo.

    define buffer inter   for inter.
    define buffer dtord   for dtord.
    define buffer doset   for doset.
    define buffer prmtv   for prmtv.

    if pcMode <> 'D'
    then do:
        // Le contrat doit exister.
        if not can-find(first ctrat no-lock
            where ctrat.tpcon = phBuffer::cTypeMandat
              and ctrat.nocon = phBuffer::iNumeroMandat)
        then do:
            mError:createError({&NIVEAU-erreur}, 211669, substitute('&2&1&3', separ[1], phBuffer::cTypeMandat, phBuffer::iNumeroMandat)).
            return false.
        end.
        // L'immeuble doit exister.
        if not can-find(first imble no-lock where imble.noimm = phBuffer::iNumeroImmeuble)
        then do:
            mError:createError({&NIVEAU-erreur}, 211676, substitute('&1', phBuffer::iNumeroImmeuble)).
            return false.
        end.
        // L'immeuble doit être sur le contrat.
        if not can-find(first intnt no-lock
            where intnt.tpcon = phBuffer::cTypeMandat
              and intnt.nocon = phBuffer::iNumeroMandat
              and intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = phBuffer::iNumeroImmeuble)
        then do:
            mError:createError({&NIVEAU-erreur}, 211677, substitute('&2&1&3&1&4', separ[1], phBuffer::iNumeroImmeuble, phBuffer::cTypeMandat, phBuffer::iNumeroMandat)).
            return false.
        end.

        // Controle fournisseur
        if not controleValidationFournisseur(phBuffer::cTypeMandat, phBuffer::iNumeroMandat, phBuffer::cCodeFournisseur, table ttError by-reference) then return false.

    end.
    // Modification ou suppression impossible si existence d'une facture sur cet ordre de service.
    for each dtord no-lock
        where dtord.noord = phBuffer::iNumeroOrdreDeService
          and can-find(first dtfac no-lock where dtfac.noint = dtord.noint):
        mError:createError({&NIVEAU-erreur}, 211681).
        return false.
    end.

    // Suppression impossible si existence d'un appel sans reponse voté
    if pcMode = 'D'
    then for each dtord no-lock
        where dtord.noord = phBuffer::iNumeroOrdreDeService
      , first inter no-lock
        where inter.noint = dtord.noint
      , first doset no-lock
        where doset.tpcon = phBuffer::cTypeMandat
          and doset.nocon = phBuffer::iNumeroMandat
          and DosEt.nodos = inter.nodos
          and doset.noint = dtord.noint:
        if not can-find(first svdev no-lock where svdev.noint = dtord.noint and svdev.fgvot)
        then do:
            mError:createError({&NIVEAU-erreur}, 211681).
            return false.
        end.
    end.
    if pcMode <> 'D'
    then do:
        voChaineTravaux = new parametrageChaineTravaux().
        for each ttDetailsIntervention
           where ttDetailsIntervention.iNumeroTraitement = phBuffer::iNumeroOrdreDeService:
            // le montant de la ligne doit être égal au calcul.
            if ttDetailsIntervention.dMontantTTC <> (ttDetailsIntervention.dQuantite * ttDetailsIntervention.dPrixUnitaire) * (1 + (dynamic-function("getTauxTva" in ghTva, ttDetailsIntervention.iCodeTVA) / 100))
            then do:
                mError:createError({&NIVEAU-erreur}, 211672, substitute('&2&1&3&1&4',
                                                     separ[1],
                                                     ttDetailsIntervention.dMontantTTC,
                                                     ttDetailsIntervention.dQuantite,
                                                     ttDetailsIntervention.dPrixUnitaire,
                                                     dynamic-function("getTauxTva" in ghTva, ttDetailsIntervention.iCodeTVA))).
                delete object voChaineTravaux.
                return false.
            end.
            // Si paramétrage, Le Prix Unitaire doit être supérieur à zéro.
            if voChaineTravaux:isPrixUnitaire() and ttDetailsIntervention.dPrixUnitaire = 0
            then do:
                mError:createError({&NIVEAU-erreur}, 211675).
                delete object voChaineTravaux.
                return false.
            end.
            vdeMontantTotal = vdeMontantTotal + (ttDetailsIntervention.dMontantHT * ttDetailsIntervention.dQuantite).
        end.
        if voChaineTravaux:isPlafond()
        then do:
            find first prmtv no-lock
                 where prmtv.tppar = "HABIL"
                   and prmtv.noOrd = mToken:iCollaborateur no-error.
            if (not available prmtv or prmtv.mtpar < vdeMontantTotal)
            and outils:questionnaire(211673
                                   , substitute('&2&1&3', separ[1], vdeMontantTotal, if available prmtv then prmtv.mtpar else 0)
                                   , table ttError by-reference) <= 2   // pas répondu oui à la question: Vous n'êtes pas habilité à créer/modifier cet ordre de service. Votre plafond est de %1.
            then do:
                delete object voChaineTravaux.
                return false.
            end.
        end.
        // Modification impossible si Bon à Payer
        delete object voChaineTravaux.
        if pcMode = 'U' and can-find(first ordse no-lock where rowid(ordse) = phBuffer::rRowid and ordse.fgbap)
        then do:
            mError:createError({&NIVEAU-erreur}, 211674).
            return false.
        end.
    end.
    return true.

end function.

function rechercheSalarie returns int64 private (pcTypeRoleSalarie as character, pcTypeContratSalarie as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroSalarieMin  as int64     no-undo.
    define variable viNumeroSalarieMax  as int64     no-undo.
    define variable vcCodeProfilGardien as character no-undo.

    define buffer ctrat for ctrat.

    vcCodeProfilGardien = substitute("*CODPROFIL=GIGAR&1*", separ[2]).
    if pcTypeContratSalarie = {&TYPECONTRAT-Salarie}
    then assign
        viNumeroSalarieMin = int64(string(piNumeroContrat) + "01")
        viNumeroSalarieMax = int64(string(piNumeroContrat) + "99")
    .
    else assign
        viNumeroSalarieMin = int64(string(piNumeroContrat, "99999") + "00001")
        viNumeroSalarieMax = int64(string(piNumeroContrat, "99999") + "99999")
    .
    /*--> Recherche du gardien */
    for each ctrat no-lock
        where ctrat.tpcon = pcTypeContratSalarie
          and ctrat.nocon >= viNumeroSalarieMin
          and ctrat.nocon <= viNumeroSalarieMax
          and ctrat.dtree = ?
          and can-find(first salar no-lock
                       where salar.tprol = pcTypeRoleSalarie
                         and salar.norol = ctrat.nocon
                         and (salar.cdcat = {&CODECONTRAT-categorieB} or salar.cdcat = {&CODECONTRAT-categorieBP} or salar.lbdiv5 matches vcCodeProfilGardien)
                         and salar.cdsta = {&CODESTATUT-titulaire}
                         and salar.dtsor = ?):
        return ctrat.nocon.
    end.
    for each ctrat no-lock
        where ctrat.tpcon = pcTypeContratSalarie
          and ctrat.nocon >= viNumeroSalarieMin
          and ctrat.nocon <= viNumeroSalarieMax
          and ctrat.dtree = ?
          and can-find(first salar no-lock
                       where salar.tprol = pcTypeRoleSalarie
                         and salar.norol = ctrat.nocon
                         and salar.dtsor = ?):
        return ctrat.nocon.
    end.
    return 0.

end function.

procedure getOrdreDeService:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service pour beOrdreDeService.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttOrdreDeService.
    define output parameter table for ttDetailsIntervention.

    define variable vcTypeMandat         as character no-undo.
    define variable viNumeroMandat       as int64     no-undo.
    define variable viNumeroTraitement   as int64     no-undo.
    define variable viNumeroIntervention as integer   no-undo.
    define variable vhTiers              as handle    no-undo.
    define variable vcLibelleFour        as character no-undo.

    define buffer inter  for Inter.
    define buffer ordse  for ordse.
    define buffer ctrat  for ctrat.
    define buffer imble  for imble.
    define buffer intnt  for intnt.
    define buffer tutil  for tutil.
    define buffer ttOrdreDeService for ttOrdreDeService.

    empty temp-table ttOrdreDeService.
    empty temp-table ttDetailsIntervention.
    assign
        vcTypeMandat         = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat       = poCollection:getInt64("iNumeroMandat")
        viNumeroTraitement   = poCollection:getInt64("iNumeroTraitement")
        viNumeroIntervention = poCollection:getInteger("iNumeroIntervention")
    .
message "************** " vcTypeMandat " / " viNumeroMandat " / " viNumeroTraitement " / " viNumeroIntervention .    
    run tiers/tiers.p persistent set vhTiers.
    run getTokenInstance in vhTiers (mToken:JSessionId).
    run tiers/fournisseur.p persistent set ghFournisseur.
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
    run compta/outilsTVA.p persistent set ghTva.
    run getTokenInstance in ghTva(mToken:JSessionId).

    /* Recherche de l'immeuble */
    for first intnt no-lock
        where intnt.tpcon = vcTypeMandat
          and intnt.nocon = viNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt
      , first ctrat no-lock
        where ctrat.tpcon = vcTypeMandat
          and ctrat.nocon = viNumeroMandat
      , first inter no-lock
        where inter.noint = viNumeroIntervention
      , first ordse no-lock
        where ordse.noord = viNumeroTraitement:
        vcLibelleFour = dynamic-function('getLibelleFour' in ghFournisseur, vcTypeMandat,ordse.nofou).
        run getTiersGestionnaire in vhTiers(viNumeroMandat, vcTypeMandat, output table ttTiers by-reference).
        find first ttTiers no-error.
        /* Recherche de l'utilisateur ayant créé l'ordre de service */
        find first tutil no-lock where tutil.ident_u = ordse.CdCsy no-error.
        create ttOrdreDeService.
        assign
            ttOrdreDeService.CRUD                     = 'R'
            ttOrdreDeService.iNumeroOrdreDeService    = ordse.noord
            ttOrdreDeService.iNumeroMandat            = viNumeroMandat
            ttOrdreDeService.cCodeTraitement          = {&TYPEINTERVENTION-ordre2service}
            ttOrdreDeService.iNumeroIntervention      = inter.noint
            ttOrdreDeService.cLibelleIntervention     = inter.lbint
            ttOrdreDeService.cTypeMandat              = vcTypeMandat
            ttOrdreDeService.cLibelleMandat           = ctrat.lbnom
            ttOrdreDeService.iNumeroImmeuble          = intnt.noidt
            ttOrdreDeService.cLibelleImmeuble         = imble.lbnom
            ttOrdreDeService.cCodeFournisseur         = string(ordse.Nofou)
            ttOrdreDeService.cLibellefournisseur      = vcLibelleFour
            ttOrdreDeService.cCodeTheme               = ordse.LbDiv1 /* '00002' */
            ttOrdreDeService.cCommentaireIntervention = ordse.lbCom
            ttOrdreDeService.cCodeFacturableA         = ordse.tpidt-fac
            ttOrdreDeService.iNumeroTiersFacturableA  = ordse.noidt-fac
            ttOrdreDeService.iNumerogestionnaire      = if available ttTiers then ttTiers.iNumeroTiers else 0
            ttOrdreDeService.cLibelleGestionnaire     = if available ttTiers then substitute('&1 &2', ttTiers.cNom1, ttTiers.cPrenom1) else ""
            ttOrdreDeService.iNumeroSignalant         = ordse.nopar
            ttOrdreDeService.cLibelleSignalant        = if ordse.tppar = "FOU" then outilFormatage:getNomFour("F", ordse.nopar, inter.tpcon)
                                                        else outilFormatage:getNomTiers(ordse.tppar, ordse.nopar)
            ttOrdreDeService.cCodeRoleSignalant       = ordse.tppar
            ttOrdreDeService.cLibelleRolesignalant    = outilTraduction:getLibelleProg("O_ROL", ordse.tppar)
            ttOrdreDeService.cCodeMode                = string(ordse.MdSig)
            ttOrdreDeService.lBonAPayer               = ordSe.fgbap
            ttOrdreDeService.lCloture                 = estCloture(ordse.noord)
            ttOrdreDeService.rRowid                   = rowid(ordse)
            ttOrdreDeService.cSysUser                 = if available tutil then tutil.nom else ""
            ttOrdreDeService.daSysDateCreate          = ordSe.dtcsy
            ttOrdreDeService.dtTimestampOrdre         = datetime(ordse.dtmsy, ordse.hemsy)
        .

        case ordse.tpidt-fac:
            when {&TYPEROLE-coproprietaire} or when {&TYPEROLE-locataire}
            then ttOrdreDeService.cLibelleTiersFacturableA = dynamic-function("getLibelleTiers" in vhTiers,
                                                        string(ordse.noidt-fac, ">>>>>>>>>99999"),
                                                        string(ordse.tpidt-fac = {&TYPEROLE-coproprietaire}, 'C/L'),
                                                        viNumeroMandat).
            when {&TYPECONTRAT-mandat2Syndic}  then ttOrdreDeService.cLibelleTiersFacturableA = outilTraduction:getLibelle(701337).
            when {&TYPECONTRAT-mandat2Gerance} then ttOrdreDeService.cLibelleTiersFacturableA = outilTraduction:getLibelle(701793).
        end case.
        run getDetailIntervention(OrdSe.NoOrd).
    end.
    run destroy in ghTva.
    run destroy in vhTiers.
    run destroy in ghFournisseur.

end procedure.

procedure getOrdreDeServiceRowid:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service pour beOrdreDeService.cls
    ------------------------------------------------------------------------------*/
    define input  parameter prRowid as rowid no-undo.
    define output parameter table for ttOrdreDeService.
    define output parameter table for ttDetailsIntervention.

    define variable vhTiers        as handle    no-undo.
    define variable vcLibelleFour  as character no-undo.

    define buffer inter  for Inter.
    define buffer ordse  for ordse.
    define buffer dtord  for dtord.
    define buffer ctrat  for ctrat.
    define buffer imble  for imble.
    define buffer intnt  for intnt.
    define buffer tutil  for tutil.

    empty temp-table ttOrdreDeService.
    empty temp-table ttDetailsIntervention.
    run tiers/tiers.p persistent set vhTiers.
    run getTokenInstance in vhTiers (mToken:JSessionId).
    run tiers/fournisseur.p persistent set ghFournisseur.
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
    run compta/outilsTVA.p persistent set ghTva.
    run getTokenInstance in ghTva(mToken:JSessionId).

    for first ordse no-lock
        where rowid(ordse) = prRowid
      , first dtord no-lock
        where dtord.noord = ordse.NoOrd
      , first inter no-lock
        where inter.noint = dtord.noint
      , first intnt no-lock
        where intnt.tpcon = inter.tpcon
          and intnt.nocon = inter.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt
      , first ctrat no-lock
        where ctrat.tpcon = inter.tpcon
         and ctrat.nocon  = inter.nocon:
        vcLibelleFour = dynamic-function('getLibelleFour' in ghFournisseur, inter.tpcon, ordse.nofou).
        run getTiersGestionnaire in vhTiers(inter.nocon, inter.tpcon, output table ttTiers by-reference).
        find first ttTiers no-error.
        /* Recherche de l'utilisateur ayant créé l'ordre de service */
        find first tutil no-lock where tutil.ident_u = ordse.CdCsy no-error.
        create ttOrdreDeService.
        assign
            ttOrdreDeService.CRUD                     = 'R'
            ttOrdreDeService.iNumeroOrdreDeService    = ordse.noord
            ttOrdreDeService.iNumeroMandat            = inter.nocon
            ttOrdreDeService.cCodeTraitement          = {&TYPEINTERVENTION-ordre2service}
            ttOrdreDeService.iNumeroIntervention      = inter.noint
            ttOrdreDeService.cLibelleIntervention     = inter.lbint
            ttOrdreDeService.cTypeMandat              = inter.tpcon
            ttOrdreDeService.cLibelleMandat           = ctrat.lbnom
            ttOrdreDeService.iNumeroImmeuble          = intnt.noidt
            ttOrdreDeService.cLibelleImmeuble         = imble.lbnom
            ttOrdreDeService.cCodeFournisseur         = string(ordse.Nofou)
            ttOrdreDeService.cLibellefournisseur      = vcLibelleFour
            ttOrdreDeService.cCodeTheme               = ordse.LbDiv1 /* '00002' */
            ttOrdreDeService.cCommentaireIntervention = ordse.lbCom
            ttOrdreDeService.cCodeFacturableA         = ordse.tpidt-fac
            ttOrdreDeService.iNumeroTiersFacturableA  = ordse.noidt-fac
            ttOrdreDeService.iNumerogestionnaire      = if available ttTiers then ttTiers.iNumeroTiers else 0
            ttOrdreDeService.cLibelleGestionnaire     = if available ttTiers then substitute('&1 &2', ttTiers.cNom1, ttTiers.cPrenom1) else ""
            ttOrdreDeService.iNumeroSignalant         = inter.nopar
            ttOrdreDeService.cLibelleSignalant        = if ordse.tppar = "FOU" then outilFormatage:getNomFour("F", ordse.nopar, inter.tpcon)
                                                        else outilFormatage:getNomTiers(ordse.tppar, ordse.nopar)
            ttOrdreDeService.cCodeRoleSignalant       = inter.tppar
            ttOrdreDeService.cLibelleRolesignalant    = outilTraduction:getLibelleProg("O_ROL", inter.tppar)
            ttOrdreDeService.cCodeMode                = string(ordse.MdSig)
            ttOrdreDeService.lBonAPayer               = ordSe.fgbap
            ttOrdreDeService.lCloture                 = estCloture(ordse.noord)
            ttOrdreDeService.rRowid                   = rowid(ordse)
            ttOrdreDeService.cSysUser                 = if available tutil then tutil.nom else ""
            ttOrdreDeService.daSysDateCreate          = ordSe.dtcsy
            ttOrdreDeService.dtTimestampOrdre         = datetime(ordse.dtmsy, ordse.hemsy)
        .
        case ordse.tpidt-fac:
            when {&TYPEROLE-coproprietaire} or when {&TYPEROLE-locataire}
            then ttOrdreDeService.cLibelleTiersFacturableA = dynamic-function("getLibelleTiers" in vhTiers
                                                                            , string(ordse.noidt-fac, ">>>>>>>>>99999")
                                                                            , string(ordse.tpidt-fac = {&TYPEROLE-coproprietaire}, 'C/L')
                                                                            , inter.nocon).
            when {&TYPECONTRAT-mandat2Syndic}  then ttOrdreDeService.cLibelleTiersFacturableA = outilTraduction:getLibelle(701337).
            when {&TYPECONTRAT-mandat2Gerance} then ttOrdreDeService.cLibelleTiersFacturableA = outilTraduction:getLibelle(701793).
        end case.
        run getDetailIntervention(OrdSe.NoOrd).
    end.
    run destroy in ghTva.
    run destroy in vhTiers.
    run destroy in ghFournisseur.

end procedure.

procedure getDetailIntervention private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroOrdreDeService as integer no-undo.

    define buffer inter for inter.
    define buffer ordSe for ordSe.
    define buffer dtord for dtord.

    find first ordSe no-lock
         where OrdSe.NoOrd = piNumeroOrdreDeService no-error.
    if not available OrdSe then return.

    for each dtord no-lock
        where dtord.noOrd = piNumeroOrdreDeService
      , first inter no-lock
        where inter.noint = dtord.noint:
        create ttDetailsIntervention.
        assign
            ttDetailsIntervention.CRUD                     = 'R'
            ttDetailsIntervention.iNumeroTraitement        = piNumeroOrdreDeService
            ttDetailsIntervention.iNumeroIntervention      = dtord.noint /* inter.cdart */
            ttDetailsIntervention.cCodeArticle             = inter.cdArt
            ttDetailsIntervention.cLibelleIntervention     = inter.lbint
            ttDetailsIntervention.cCodeCle                 = inter.cdcle
            ttDetailsIntervention.dQuantite                = dtord.qtint
            ttDetailsIntervention.dPrixUnitaire            = dtord.pxUni
            ttDetailsIntervention.dMontantHT               = dtord.MtInt
            ttDetailsIntervention.cCommentaireIntervention = if available inter then inter.lbCom else ""
            ttDetailsIntervention.daFinPrevue              = dtord.dtfin
            ttDetailsIntervention.daDateDebut              = dtord.dtdeb
            ttDetailsIntervention.iCodeTVA                 = DtOrd.CdTva
            ttDetailsIntervention.dTauxTVA                 = dynamic-function("getTauxTva" in ghTva, dtord.cdtva)
            ttDetailsIntervention.dMontantTTC              = dtord.MtInt * (1 + ttDetailsIntervention.dTauxTVA / 100)
            ttDetailsIntervention.rRowidDtord              = rowid(dtord)
            ttDetailsIntervention.rRowidInter              = rowid(inter)
            ttDetailsIntervention.dtTimestampDtord         = datetime(dtord.dtmsy, dtord.hemsy)
            ttDetailsIntervention.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
        .
    end.

end procedure.

procedure createOrdreDeService:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service pour beOrdreDeService.cls
    ------------------------------------------------------------------------------*/
    define input-output parameter table-handle phtt.
    define input parameter table for ttDetailsIntervention.
    define input parameter table for ttError.

    define variable vhbtt                as handle    no-undo.
    define variable vhqtt                as handle    no-undo.
    define variable viNextNumeroOS       as integer   no-undo.
    define variable vcTypeRoleSalarie    as character no-undo.
    define variable vcTypeContratSalarie as character no-undo.
    define variable viNumeroSalarie      as int64     no-undo.
    define variable voPayePegase         as class parametragePayePegase no-undo.

    define buffer ordse  for ordse.

    run tiers/fournisseur.p persistent set ghFournisseur. // ghFournisseur déclaré en global
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
    run compta/outilsTVA.p persistent set ghTva.
    run getTokenInstance in ghTva(mToken:JSessionId).
    assign
        voPayePegase         = new parametragePayePegase()
        vcTypeRoleSalarie    = (if voPayePegase:iNiveauPaiePegase >= 2 then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
        vcTypeContratSalarie = (if vcTypeRoleSalarie = {&TYPEROLE-salariePegase} then {&TYPECONTRAT-SalariePegase} else {&TYPECONTRAT-Salarie})
        vhbtt                = phtt:default-buffer-handle
    .
    delete object voPayePegase.
    create query vhqtt.
    vhqtt:set-buffers(vhbtt).
    vhqtt:query-prepare(substitute('for each &1 where &1.CRUD="C"', vhbtt:name)).
    vhqtt:query-open().

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhqtt:get-next().
            if vhqtt:query-off-end then leave blocRepeat.

            // En création, on autorise un iNumeroOrdreDeService <> 0, pour permettre un lien avec ttDetailsIntervention
            // if vhbtt::iNumeroOrdreDeService > 0 then next blocRepeat.
            if not controleOrdre2Service('C', vhbtt, table ttDetailsIntervention by-reference, table ttError by-reference)
            or not getNextOrdre2Service({&ACTION-creation}, output viNextNumeroOS) then undo blocTransaction, leave blocTransaction.   // erreur créée dans getNextOrdre2Service.

            viNumeroSalarie = rechercheSalarie(vcTypeRoleSalarie, vcTypeContratSalarie, vhbtt::iNumeroMandat).
            /*--> Creation de l'ordre de service */
            create ordse.
            assign
                ordse.noref     = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                ordse.noOrd     = viNextNumeroOS
                ordse.nofou     = vhbtt::cCodeFournisseur
                ordse.tpSal     = vcTypeRoleSalarie
                ordse.noSal     = viNumeroSalarie
                ordse.lbdiv1    = vhbtt::cCodeTheme
                ordse.LbCom     = vhbtt::cCommentaireIntervention
                ordse.tpidt-fac = vhbtt::cCodeFacturableA
                ordse.noidt-fac = vhbtt::iNumeroTiersFacturableA
                ordse.tpPar     = vhbtt::cCodeRoleSignalant
                ordse.noPar     = vhbtt::iNumeroSignalant    /* (if ordse.TpPar = "FOU" then INT(HwCodNFp) else INT(HwCodNPa)) */
                ordse.mdsig     = vhbtt::cCodeMode
                ordse.cdcsy     = mToken:cUser
                ordse.Dtcsy     = today
                ordse.Hecsy     = mtime
                ordse.cdmsy     = mToken:cUser
                ordse.Dtmsy     = ordse.Dtcsy
                ordse.Hemsy     = ordse.Hecsy
                vhbtt::iNumeroOrdreDeService = viNextNumeroOS     // besoin pour mise à jour lienLot
            .
            mError:createInfoRowid(rowid(ordse)). // enregistrement créé, permet de renvoyer le rowid en réponse.
            run deleteDetailIntervention(vhbtt).
            run createDetailIntervention(ordse.noOrd, ordse.tpPar, ordse.noPar, vhbtt).
            run updateDetailIntervention(ordse.tpPar, ordse.noPar, vhbtt).
            run createTraitement({&ACTION-creation}, ordse.noOrd, vhbtt).
        end.
    end.
    run destroy in ghTva.
    run destroy in ghFournisseur.
    assign error-status:error = false no-error. // reset error-status:error

end procedure.

procedure updateOrdreDeService:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service pour beOrdreDeService.cls
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttOrdreDeService.
    define input parameter table for ttDetailsIntervention.
    define input parameter table for ttError.

    define variable vcTypeContratSalarie as character no-undo.
    define variable viNumeroSalarie      as int64     no-undo.
    define variable vhbuffer             as handle    no-undo.

    define buffer ordse   for ordse.
    define buffer lidoc   for lidoc.
    define buffer vbLidoc for lidoc.

    run tiers/fournisseur.p persistent set ghFournisseur. // ghFournisseur déclaré en global
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
    run compta/outilsTVA.p persistent set ghTva.
    run getTokenInstance in ghTva(mToken:JSessionId).

    /* TODO revoir l'initialisation !!!
    define variable voPayePegase  as class parametragePayePegase no-undo.
    assign
        voPayePegase  = new parametragePayePegase()
        vcTypeRoleSalarie    = (if voPayePegase:iNiveauPaiePegase >= 2 then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
        vcTypeContratSalarie = (if vcTypeRoleSalarie = {&TYPEROLE-salariePegase} then {&TYPECONTRAT-SalariePegase} else {&TYPECONTRAT-Salarie})
    .
    */

blocTransaction:
    do transaction:
        for each ttOrdreDeService
            where ttOrdreDeService.CRUD = 'U':
            find first ordse exclusive-lock
                where rowid(ordse) = ttOrdreDeService.rRowid no-wait no-error.
            if outils:isUpdated(buffer ordse:handle, 'ordse: ', string(ttOrdreDeService.iNumeroOrdreDeService), ttOrdreDeService.dtTimestampOrdre)
            or not controleOrdre2Service('U', buffer ttOrdreDeService:handle, table ttDetailsIntervention by-reference, table ttError by-reference)
            then undo blocTransaction, leave blocTransaction.
            assign
            //  viNumeroSalarie  = rechercheSalarie(vcTypeRoleSalarie, vcTypeContratSalarie, ttOrdreDeService.iNumeroMandat)
                ordse.nofou     = integer(ttOrdreDeService.cCodeFournisseur)
            //  ordse.TpSal     = vcTypeRoleSalarie
            /*  ordse.NoSal     = viNumeroSalarie */
                ordse.lbdiv1    = ttOrdreDeService.cCodeTheme
                ordse.LbCom     = ttOrdreDeService.cCommentaireIntervention
                ordse.Tpidt-fac = ttOrdreDeService.cCodeFacturableA
                ordse.Noidt-fac = ttOrdreDeService.iNumeroTiersFacturableA
                ordse.TpPar     = ttOrdreDeService.cCodeRoleSignalant
                ordse.NoPar     = ttOrdreDeService.iNumeroSignalant    /* (if ordse.TpPar = "FOU" then INT(HwCodNFp) else INT(HwCodNPa)) */
                ordse.mdsig     = ttOrdreDeService.cCodeMode
                ordse.cdmsy     = mToken:cUser
                ordse.Dtmsy     = today
                ordse.Hemsy     = mtime
                vhbuffer        = buffer ttOrdreDeService:handle
            .
            run deleteDetailIntervention(vhbuffer).
            run updateDetailIntervention(ordse.tpPar, ordse.noPar, vhbuffer).
            run createDetailIntervention(ordse.noOrd, ordse.tpPar, ordse.NoPar, vhbuffer).
            run createTraitement({&ACTION-modification}, ordse.noOrd, vhbuffer).
            /* Modification et maj du document fusionné s'il existe déjà */
            for last lidoc no-lock
                where lidoc.tpidt = {&TYPEINTERVENTION-ordre2Service}
                  and lidoc.noidt = ordse.noord
                  and lidoc.nossd = 1
              , first vbLidoc exclusive-lock                 /* Récupération du no de document lié à l'OS */
                where vbLidoc.tpidt = vcTypeContratSalarie    /* Contrat salarié */
                  and vbLidoc.nossd = 0
                  and vbLidoc.nodoc = lidoc.nodoc:
                if vbLidoc.noidt <> viNumeroSalarie
                then assign
                    vbLidoc.noidt = viNumeroSalarie
                    vbLidoc.cdmsy = mToken:cUser
                    vbLidoc.dtmsy = today
                    vbLidoc.hemsy = mtime
                .
            end.
        end.
    end.
    run destroy in ghTva.
    run destroy in ghFournisseur.
    assign error-status:error = false no-error. // reset error-status:error

end procedure.

procedure deleteDetailIntervention private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer     as handle no-undo.

    define buffer trint for trint.
    define buffer inter for inter.
    define buffer dtord for dtord.

blocTransaction:
    do transaction:
blocDetail:
        for each ttDetailsIntervention
            where ttDetailsIntervention.CRUD = 'D'
              and ttDetailsIntervention.iNumeroTraitement = phBuffer::iNumeroOrdreDeService:
            /*--> Suppression des interventions */
            for each dtord exclusive-lock
               where dtord.noOrd = ttDetailsIntervention.iNumeroTraitement
                 and DtOrd.NoInt = ttDetailsIntervention.iNumeroIntervention
             , first inter exclusive-lock
               where inter.noint = dtord.noint:
                /*--> Suppression des traitements */
                for each trint exclusive-lock
                   where trint.noint = inter.noint
                     and trint.tptrt = phBuffer::CodeTraitement
                     and trint.notrt = ttDetailsIntervention.iNumeroTraitement:
                    delete trint.
                end.
                /*--> On ne supprime pas l'intervention si elle est rattachée à un devis, à une reponse, à une facture */
                if inter.nosig = 0
                then do:
                    if not can-find(first dtdev no-lock where dtdev.noint = inter.noint)
                    and not can-find(first svdev no-lock where svdev.noint = inter.noint)
                    and not can-find(first dtfac no-lock where dtfac.noint = inter.noint)
                    then do:
                        /*--> Suppression des traitements de cette intervention */
                        for each trint exclusive-lock
                            where trint.noint = inter.noint:
                            delete trint.
                        end.
                        /*--> Suppression de l'intervention */
                        delete inter.
                    end.
                end.
                else inter.cdsta = {&STATUTINTERVENTION-initie}.
                /*--> Suppression du detail ordre de service */
                delete dtord.
            end.
        end.
    end.
end procedure.

procedure createDetailIntervention private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroOS as integer   no-undo.
    define input parameter pcTpparOS  as character no-undo.
    define input parameter piNoparOS  as integer   no-undo.
    define input parameter phBuffer   as handle    no-undo.

    define variable viNoIntervention as integer  no-undo.

    define buffer dtord  for dtord.
    define buffer inter  for inter.

blocTransaction:
    do transaction:
blocDetail:
        for each ttDetailsIntervention
            where ttDetailsIntervention.CRUD = 'C':
             // and ttDetailsIntervention.iNumeroOrdreDeService = phBuffer::iNumeroOrdreDeService

            /*--> Recherche du prochain n° d'Inter */
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last inter no-lock no-error.
            if available inter then viNoIntervention = inter.noint + 1.
            create inter.
            assign
                inter.noref  = integer(if phBuffer::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                inter.noint  = viNoIntervention
                inter.lbint  = ttDetailsIntervention.cLibelleIntervention
                inter.qtint  = ttDetailsIntervention.dQuantite
                inter.cdart  = ttDetailsIntervention.cCodeArticle
               /*inter.TpRes = TbTmpInt.TpRes
                inter.NoRes  = TbTmpInt.NoRes */
                inter.tpcon  = phBuffer::cTypeMandat
                inter.nocon  = phBuffer::iNumeroMandat
                /*inter.NoDos     = NoDosUse NUMERO DE DOSSIER TRAVAUX */
                inter.lbCom  = ttDetailsIntervention.cCommentaireIntervention
                inter.qtfac  = ttDetailsIntervention.dQuantite
                inter.cdsta  = {&STATUTINTERVENTION-enCours}
                inter.cdcle  = ttDetailsIntervention.cCodeCle
                inter.dlInt  = phBuffer::cCodeDelai
                inter.tppar  = pcTpparOS
                inter.nopar  = piNoparOS
                inter.cdcsy  = mToken:cUser
                inter.dtcsy  = today
                inter.hecsy  = mtime
                inter.cdmsy  = mToken:cUser
                inter.dtmsy  = inter.DtCsy
                inter.hemsy  = inter.HeCsy
            .
            create DtOrd.
            assign
                dtord.noref = integer(if phBuffer::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                dtord.noint = inter.noint
                dtord.noOrd = piNumeroOS
                dtord.lbInt = ttDetailsIntervention.cLibelleIntervention
                dtord.qtInt = ttDetailsIntervention.dQuantite
                dtord.pxUni = ttDetailsIntervention.dPrixUnitaire
                DtOrd.MtInt = (ttDetailsIntervention.dQuantite * ttDetailsIntervention.dPrixUnitaire) // Montant Net
                dtord.cdTva = ttDetailsIntervention.iCodeTVA
                dtord.dtDeb = ttDetailsIntervention.daDateDebut
                dtord.dtFin = ttDetailsIntervention.daFinPrevue
                dtord.cdSta = {&STATUTINTERVENTION-initie}
                dtord.lbCom = ttDetailsIntervention.cCommentaireIntervention
                dtord.cdcle = ttDetailsIntervention.cCodeCle
                dtord.cdcsy = mToken:cUser
                dtord.dtCsy = today
                dtord.heCsy = mtime
                dtord.cdmsy = mToken:cUser
                dtord.dtmsy = dtord.dtCsy
                dtord.hemsy = dtord.heCsy
            .
        end.
    end.

end procedure.

procedure updateDetailIntervention private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter pcTpparOS  as character no-undo.
    define input parameter piNoparOS  as integer   no-undo.
    define input parameter phBuffer   as handle    no-undo.

    define buffer dtord  for dtord.
    define buffer inter  for inter.

blocTransaction:
    do transaction:
        /*--> Creation / Mise à jour des interventions */
        for each ttDetailsIntervention
            where ttDetailsIntervention.CRUD = 'U':
              // 25/04/2017 - THK : Pour la création d'un OS à partir d'un signalement le numéro d'ordre de service ne peut être positionné dans le détail intervention
              // and ttDetailsIntervention.iNumeroTraitement = phBuffer::iNumeroOrdreDeService
            find first inter exclusive-lock
                where rowid(inter) = ttDetailsIntervention.rRowidInter no-wait no-error.
            if outils:isUpdated(buffer inter:handle, 'inter: ', string(ttDetailsIntervention.iNumeroIntervention), ttDetailsIntervention.dtTimestampInter)
            then undo blocTransaction, leave blocTransaction.

            assign
                inter.cdArt  = ttDetailsIntervention.cCodeArticle
               /*inter.tpRes = TbTmpInt.TpRes
                inter.noRes  = TbTmpInt.NoRes */
                inter.tpcon  = phBuffer::cTypeMandat
                inter.nocon  = phBuffer::iNumeroMandat
              /*  inter.NoDos     = NoDosUse */
                inter.lbcom  = ttDetailsIntervention.cCommentaireIntervention
                inter.qtfac  = ttDetailsIntervention.dQuantite
                inter.cdsta  = {&STATUTINTERVENTION-enCours}
                inter.cdcle  = ttDetailsIntervention.cCodeCle
                inter.dlInt  = phBuffer::cCodeDelai
                inter.tppar  = pcTpparOS
                inter.nopar  = piNoparOS
                inter.cdmsy  = mToken:cUser
                inter.Dtmsy  = today
                inter.Hemsy  = mtime
            .
            if ttDetailsIntervention.rRowiddtOrd = ?
            then do:
                create dtord.
                assign
                     dtord.noint = ttDetailsIntervention.iNumeroIntervention
                     dtord.noord = phBuffer::iNumeroOrdreDeService
                     dtord.cdcsy = mtoken:cUser
                     dtord.dtcsy = today
                     dtord.hecsy = mtime
                .
            end.
            else do:
                find first dtOrd exclusive-lock
                     where rowid(dtOrd) = ttDetailsIntervention.rRowiddtOrd no-wait no-error.
                if outils:isUpdated(buffer dtOrd:handle, 'dtOrd: ', string(ttDetailsIntervention.iNumeroTraitement), ttDetailsIntervention.dtTimestampDtord)
                then undo blocTransaction, leave blocTransaction.
            end.
            assign
                dtord.lbInt = ttDetailsIntervention.cLibelleIntervention
                dtord.qtInt = ttDetailsIntervention.dQuantite
                dtord.pxUni = ttDetailsIntervention.dPrixUnitaire
                DtOrd.MtInt = (ttDetailsIntervention.dQuantite * ttDetailsIntervention.dPrixUnitaire) // Montant Net
                dtord.cdTva = ttDetailsIntervention.iCodeTVA
                dtord.dtDeb = ttDetailsIntervention.daDateDebut
                dtord.dtFin = ttDetailsIntervention.daFinPrevue
                dtord.cdSta = {&STATUTINTERVENTION-enCours}
                dtord.LbCom = ttDetailsIntervention.cCommentaireIntervention
                dtord.cdcle = ttDetailsIntervention.cCodeCle
                dtord.cdmsy = mToken:cUser
                dtord.dtmsy = today
                dtord.hemsy = mtime
            .
        end.
    end.

end procedure.

procedure createTraitement private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter piActionUtilisateur as integer no-undo.
    define input parameter piNumeroOS          as int64   no-undo.
    define input parameter phBuffer            as handle  no-undo.

    define variable viNoTraitement as integer   no-undo.
    define variable vcLstDevUse    as character no-undo.

    define buffer trInt  for trInt.
    define buffer dtord  for dtord.
    define buffer inter  for inter.
    define buffer svDev  for svDev.
    define buffer dtDev  for dtDev.

    /*--> Creation du traitement */
    for each dtord no-lock
        where dtord.NoOrd = piNumeroOS
      , first inter no-lock
        where inter.NoInt = DtOrd.NoInt:
        /*--> Recherche prochaine n° traitement sur l'intervention */
        find last trint no-lock
            where trint.noint = inter.NoInt no-error.
        viNoTraitement = if available trint then trint.noidt + 1 else 1.
        create TrInt.
        assign
           TrInt.NoRef = integer(if phBuffer::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
           TrInt.NoInt = inter.NoInt
           Trint.NoIdt = viNoTraitement
           TrInt.TpTrt = {&TYPEINTERVENTION-ordre2service}
           TrInt.NoTrt = piNumeroOS
           TrInt.CdSta = dtord.CdSta
           TrInt.RgTrt = {&RANGIMPORTANCE-ordre2service}
      /*  TrInt.DuTrt = round(NbTpsUse / iNbIntUse,0) NbTpsUse non utilisé par les clients GI */
           TrInt.LbCom = outilTraduction:getLibelle(piActionUtilisateur)
           TrInt.cdcsy = mToken:cUser
           TrInt.DtCsy = today
           TrInt.HeCsy = mtime
       .
      /*--> Postionner les traitements signalement à en cours */
       for each trint exclusive-lock
          where trint.noint = inter.noint
            and trint.tptrt = {&TYPEINTERVENTION-signalement}
            and trint.notrt = inter.nosig:
            assign
                trint.cdsta = {&STATUTINTERVENTION-enCours}
                trint.cdmsy = mToken:cUser
                trint.dtmsy = today
                trint.hemsy = mtime
            .
        end.
        for each svdev no-lock
           where svdev.NoInt = inter.noint:
            if lookup(vcLstDevUse, string(svdev.nodev)) = 0 then vcLstDevUse = vcLstDevUse + "|" + string(svdev.nodev).
        end.
        if vcLstDevUse > ""
        then do:
            /*--> Positionner les traitements devis lié à répondu et devis non lié à non répondu */
            for each trint exclusive-lock
                where trint.noint = inter.noint
                  and trint.tptrt = {&TYPEINTERVENTION-demande2devis}
                  and trint.cdsta <> {&STATUTINTERVENTION-repondu}:
                assign
                    trint.cdsta = if lookup(string(trint.notrt), vcLstDevUse, "|") > 0 then {&STATUTINTERVENTION-repondu} else {&STATUTINTERVENTION-nonRepondu}
                    trint.cdmsy = mToken:cUser
                    trint.dtmsy = today
                    trint.hemsy = mtime
                .
                /*--> Mise à jour du detail devis */
                for first dtdev exclusive-lock
                    where dtdev.noint = inter.noint
                      and dtdev.nodev = trint.NoTrt:
                    assign
                        dtdev.cdsta = trint.cdsta
                        dtdev.cdmsy = mToken:cUser
                        dtdev.dtmsy = today
                        dtdev.hemsy = mtime
                    .
                end.
            end.
            /*--> Postionner les traitements reponse devis lié à accepté et non lié à refusé */
            for each trint exclusive-lock
                where trint.noint = inter.noint
                  and trint.tptrt = {&TYPEINTERVENTION-reponseDevis}:
                assign
                    trint.cdsta = if lookup(string(trint.notrt), vcLstDevUse, "|") > 0 then {&STATUTINTERVENTION-accepte} else {&STATUTINTERVENTION-refuse}
                    trint.cdmsy = mToken:cUser
                    trint.dtmsy = today
                    trint.hemsy = mtime
                .
                /*--> Mise à jour du detail devis */
                for first svdev exclusive-lock
                    where svdev.noint = inter.noint
                      and svdev.nodev = trint.NoTrt:
                    assign
                        svdev.cdsta = trint.cdsta
                        svdev.cdmsy = mToken:cUser
                        svdev.dtmsy = today
                        svdev.hemsy = mtime
                    .
                end.
            end.
        end.
    end.
end procedure.

procedure deleteOrdreDeService:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beOrdreDeService.cls
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable viNumeroTraitement as int64     no-undo.
    define variable vcTypeMandat       as character no-undo.
    define variable viNumeroMandat     as int64     no-undo.

    define buffer ordse for ordse.
    define buffer dtord for dtord.
    define buffer inter for inter.
    define buffer trint for trint.
    define buffer dtLot for dtLot.

    assign
        viNumeroTraitement = poCollection:getInt64("iNumeroTraitement")
        vcTypeMandat       = poCollection:getCharacter("vcTypeMandat")
        viNumeroMandat     = poCollection:getInt64("viNumeroMandat")
    .
    if controleDeleteOrdreDeService(viNumeroTraitement, vcTypeMandat, viNumeroMandat)
    then for first ordse exclusive-lock
        where ordse.noOrd = viNumeroTraitement:
        for each dtord exclusive-lock
            where dtord.noord = ordse.noord:
            for first inter exclusive-lock
                where inter.noint = dtord.noint
                  and inter.nosig = 0                  // On supprime l'intervention si elle n'est rattachée à aucun signalement
                  // On peut supprimer l'intervention si elle n'est ni rattachée à un devis, ni à une réponse, ni à une facture
                  and not can-find(first dtdev no-lock where dtdev.noint = inter.noint)
                  and not can-find(first svdev no-lock where svdev.noint = inter.noint)
                  and not can-find(first dtfac no-lock where dtfac.noint = inter.noint):
                for each trint exclusive-lock               // Suppression des traitements de cette intervention
                    where trint.noint = inter.noint:
                    delete trint.
                end.
                delete inter.
            end.
            /*--> Suppression du detail ordre de service */
            delete dtord.
        end.

        /*--> Suppression des 'lot' */
        for each dtlot exclusive-lock
            where dtlot.tptrt = {&TYPEINTERVENTION-ordre2service}
              and dtlot.notrt = viNumeroTraitement:
          delete dtlot.
        end.
        /*--> Suppression des traitements de cet ordre */
        for each trint exclusive-lock
            where trint.tptrt = {&TYPEINTERVENTION-ordre2service}
              and trint.notrt = ordse.noord:
            delete trint.
        end.
        delete ordse.
    end.
end procedure.

procedure bonAPayer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beOrdreDeService.cls
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable viNumeroOrdreService as integer   no-undo.
    define variable viNumeroTraitement   as integer   no-undo.
    define variable viNumeroMandat       as integer   no-undo.
    define variable vcTypeMandat         as character no-undo.
    define variable vcCommentaire        as character no-undo.
    define variable voChaineTravaux as class parametrageChaineTravaux no-undo.

    define buffer ordse   for ordse.
    define buffer dtord   for dtord.
    define buffer trint   for trint.
    define buffer dtfac   for dtfac.
    define buffer factu   for factu.
    define buffer cecrsai for cecrsai.
    define buffer prmtv   for prmtv.

    assign
        viNumeroOrdreService = poCollection:getInt64("iNumeroOrdreService")
        viNumeroMandat       = poCollection:getInt64("iNumeroMandat")
        vcTypeMandat         = poCollection:getCharacter("cTypeMandat")
    .
    /*--> On regarde si l'utilisateur à les droits necessaires */
    voChaineTravaux = new parametrageChaineTravaux().
    if voChaineTravaux:isPlafond() then do:
        find first prmtv no-lock
            where prmtv.tppar = "HABIL"
              and prmtv.noOrd = mtoken:iCollaborateur no-error.
        if not available prmtv or (num-entries(prmtv.lbpar, "|") >= 5 and entry(5, prmtv.lbpar, "|") <> "yes")
        then do:
            mError:createError({&NIVEAU-information}, 1000266).  // Vous n'êtes pas habilité à passer les OS en Bon à Payer
            delete object voChaineTravaux.
            return.
        end.
    end.
    delete object voChaineTravaux.
    if outils:questionnaire(1000267, table ttError by-reference) <= 2 then return.   // pas répondu oui à la question: Confirmez-vous la réception des travaux ?

    /* Commentaire sur le traitement : Bon à payer */
    vcCommentaire = outilTraduction:getLibelle(704698).
    /* Flager toutes les lignes de l'ordre de service */
    for first ordse exclusive-lock where ordse.noOrd = viNumeroOrdreService
       , each dtord exclusive-lock where dtord.noOrd = viNumeroOrdreService:

        /* Recherche prochain n° traitement sur l'intervention */
        find last trint no-lock where trint.noint = dtord.NoInt no-error.
        viNumeroTraitement = if available trint then trint.noidt + 1 else 1.
        create trint.
        assign
            trint.NoRef = integer(if vcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
            trint.NoInt = dtord.NoInt
            trint.NoIdt = viNumeroTraitement
            trint.TpTrt = {&TYPEINTERVENTION-ordre2service}
            trint.NoTrt = viNumeroOrdreService
            trint.CdSta = dtord.cdsta
            trint.RgTrt = {&RANGIMPORTANCE-ordre2service}
            trint.LbCom = vcCommentaire
            trint.cdcsy = mtoken:cUser
            trint.DtCsy = today
            trint.HeCsy = mtime
            ordse.fgbap = true     // --> Mise à jour flag
        .
        /*--> Flager tt les lignes de la facture */
        for each dtfac exclusive-lock
           where dtfac.noint = dtord.noint
         , first factu exclusive-lock
           where factu.nofac = dtfac.nofac
             and factu.fgcpt = true
             and factu.fgbap = false:
            /*--> Recherche prochaine n° traitement sur l'intervention */
            find last trint no-lock where trint.noint = dtord.NoInt no-error.
            viNumeroTraitement = if available trint then trint.noidt + 1 else 1.
            create TrInt.
            assign
                trint.NoRef = integer(if vcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                trint.NoInt = dtfac.NoInt
                Trint.NoIdt = viNumeroTraitement
                trint.TpTrt = {&TYPEINTERVENTION-facture}
                trint.NoTrt = dtfac.nofac
                trint.CdSta = {&STATUTINTERVENTION-bonAPayer}
                trint.RgTrt = {&RANGIMPORTANCE-facture} + 1
                TrInt.LbCom = vcCommentaire
                TrInt.cdcsy = mtoken:cUser
                TrInt.DtCsy = today
                TrInt.HeCsy = mtime
                dtfac.cdsta = {&STATUTINTERVENTION-bonAPayer}     // --> Mise à jour flag et statut
                factu.fgbap = true
            .
            /*--> Bon à payer comptable */
            for first cecrsai exclusive-lock
                where cecrsai.soc-cd       = mtoken:iCodeSociete
                  and cecrsai.etab-cd      = viNumeroMandat
                  and cecrsai.jou-cd       = factu.cdjou
                  and cecrsai.prd-cd       = factu.noexe
                  and cecrsai.prd-num      = factu.noper
                  and cecrsai.piece-compta = factu.nopie:
                cecrsai.bonapaye = true.
            end.
        end.
    end.

end procedure.

