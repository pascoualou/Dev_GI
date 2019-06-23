/*------------------------------------------------------------------------
File        : demandeDeDevis.p
Purpose     :
Author(s)   : kantena - 2016/08/03
Notes       :
derniere revue: 2018/05/25 - phm: OK
----------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/actionUtilisateur.i}
{preprocesseur/rang2importance.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{Travaux/include/demandeDeDevis.i}
{Travaux/include/detailsIntervention.i}
{tiers/include/fournisseur.i}
{application/include/glbsepar.i}
{tiers/include/tiers.i}
{application/include/error.i}

define variable ghFournisseur as handle no-undo.

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

function estCloture returns logical private (piNumeroTraitement as int64):
    /*------------------------------------------------------------------------------
    Purpose: La demande de devis est-elle clôturée ?
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer trint for TrInt.

    for last trint no-lock
        where trint.notrt = piNumeroTraitement
          and trint.tptrt = {&TYPEINTERVENTION-demande2devis}:
        return TrInt.CdSta = {&STATUTINTERVENTION-termine}.
    end.
    return false.
end function.

function controleValidationFournisseur returns logical private (pcTypeMandat as character, piNumeroContrat as int64, cCodeFournisseur as character, table ttError):
    /*------------------------------------------------------------------------------
    Purpose: controle Date de validité et référencement du fournisseur
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viSociete as integer no-undo.
    
    // Cette fonction retourne TRUE si le fournisseur n'est plus valide
    if DateDeValidite (piNumeroContrat, "F", cCodeFournisseur, today) then return false.

    // Vérification du flag actif du fournisseur
    viSociete = mtoken:getSociete(pcTypeMandat).
    if not dynamic-function('isActif' in ghFournisseur, viSociete, cCodeFournisseur) then return false.

    // Cette fonction retourne FALSE si le référencement ne permet pas le traitement
    if not dynamic-function('isReference' in ghFournisseur, viSociete, cCodeFournisseur)
    then if can-find(first iparm no-lock where iparm.tppar = "REFERB" and iparm.cdpar = "01") /* avec blocage */
         then do:
             mError:createError({&erreur}, 1000192).
             return false.
         end.
         else if outils:questionnaire(1000301, cCodeFournisseur, table ttError by-reference) <= 2
         then return false.

    return true.

end function.

function getNextDemande2Devis returns logical private (piActionUtilisateur as integer, output piNextNumeroDD as integer):
    /*------------------------------------------------------------------------------
    Purpose: renvoie le prochain numéro DD. sous la forme aamm99999
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer devis for devis.

    piNextNumeroDD = ((year(today) modulo 100) * 100  + month(today)) * 100000.
    find last devis no-lock
        where devis.nodev > piNextNumeroDD no-error.
    if available devis
    then if devis.nodev = piNextNumeroDD + 99999
         then do:
             mError:create2Error(piActionUtilisateur, 107713).
             return false.
         end.
         else piNextNumeroDD = devis.Nodev + 1.
    else piNextNumeroDD = piNextNumeroDD + 1.
    return true.

end function.

function controleDeleteUpdateDemandeDeDevis returns logical private (pcMode as character, piNumeroTraitement as int64):
    /*------------------------------------------------------------------------------
    Purpose: controles avant suppression/modification d'un devis
    Notes  : pcMode = 'U' ou 'D'
    ------------------------------------------------------------------------------*/
    define buffer dtdev for dtdev.

    if not can-find(first devis no-lock where devis.nodev = piNumeroTraitement) then return true.

    // Modification/Suppression impossible si existence d'un suivi devis sur ce devis
    if can-find(first svdev no-lock where svdev.nodev = piNumeroTraitement)
    then do:
        mError:create2Error(if pcMode = 'U' then 104446 else 104432, 211700).
        return false.
    end.
    // Modification/Suppression impossible si existence d'un ordre de service sur ce devis
    for each dtdev no-lock
        where dtdev.nodev = piNumeroTraitement
          and can-find(first dtord no-lock where dtord.noint = dtdev.noint):
        mError:create2Error(if pcMode = 'U' then 104446 else 104432, 211701).
        return false.
    end.
    // Modification/Suppression impossible si existence d'une facture sur ce devis
    for each dtdev no-lock
        where dtdev.nodev = piNumeroTraitement
          and can-find(first dtfac no-lock where dtfac.noint = dtdev.noint):
        mError:create2Error(if pcMode = 'U' then 104446 else 104432, 211702).
        return false.
    end.
    return true.

end function.

procedure getDemandeDeDevis:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service pour beDemandeDeDevis.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttDemandeDeDevis.
    define output parameter table for ttDetailsIntervention.

    define variable vcTypeMandat         as character no-undo.
    define variable viNumeroMandat       as int64     no-undo.
    define variable viNumeroTraitement   as int64     no-undo.
    define variable viNumeroIntervention as integer   no-undo.
    define variable vcLibelleFour        as character no-undo.
    define variable vhCle                as handle    no-undo.
    define variable vhTiers              as handle    no-undo.

    define buffer intnt for intnt.
    define buffer imble for imble.
    define buffer ctrat for ctrat.
    define buffer dtDev for dtDev.
    define buffer inter for inter.
    define buffer devis for devis.
    define buffer artic for artic.
    define buffer tutil for tutil.

    empty temp-table ttDemandeDeDevis.
    assign
        vcTypeMandat         = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat       = poCollection:getInt64("iNumeroMandat")
        viNumeroTraitement   = poCollection:getInt64("iNumeroTraitement")
        viNumeroIntervention = poCollection:getInteger("iNumeroIntervention")
    .
    run tiers/tiers.p persistent set vhTiers.
    run getTokenInstance in vhTiers (mToken:JSessionId).
    run tiers/fournisseur.p persistent set ghFournisseur. // ghFournisseur déclaré en global
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
    run mandat/clemi.p persistent set vhCle.
    run getTokenInstance in vhCle (mToken:JSessionId).

   /* Recherche de l'immeuble */
    for each intnt no-lock
        where intnt.tpcon = vcTypeMandat
          and intnt.nocon = viNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt
      , first ctrat no-lock
        where ctrat.tpcon = vcTypeMandat
          and ctrat.nocon = viNumeroMandat
      , first dtdev no-lock
        where dtdev.nodev = viNumeroTraitement
          and DtDev.noint = viNumeroIntervention
      , first inter no-lock
        where inter.noint = dtdev.noint
      , first devis no-lock
        where devis.noDev = dtdev.nodev:

        run getTiersGestionnaire in vhTiers(viNumeroMandat, vcTypeMandat, output table ttTiers by-reference).
        find first ttTiers no-error.
        vcLibelleFour = dynamic-function('getLibelleFour' in ghFournisseur, vcTypeMandat, devis.nofou).
        find first artic no-lock where artic.cdArt = inter.cdArt no-error.
        /* Recherche de l'utilisateur ayant créé la demande de devis */
        find first tutil no-lock where tutil.ident_u = devis.cdcsy no-error.
        create ttDemandeDeDevis.
        assign
            ttDemandeDeDevis.CRUD                     = 'R'
            ttDemandeDeDevis.iNumeroDemandeDeDevis    = devis.nodev
            ttDemandeDeDevis.iNumeroIntervention      = inter.noint
            ttDemandeDeDevis.iNumeroMandat            = viNumeroMandat
            ttDemandeDeDevis.cCodeTraitement          = {&TYPEINTERVENTION-demande2devis}
            ttDemandeDeDevis.cTypeMandat              = vcTypeMandat
            ttDemandeDeDevis.cLibelleMandat           = ctrat.lbnom
            ttDemandeDeDevis.iNumeroImmeuble          = intnt.noidt
            ttDemandeDeDevis.cLibelleImmeuble         = imble.lbnom
            ttDemandeDeDevis.cCodeFournisseur         = string(devis.Nofou)
            ttDemandeDeDevis.cLibellefournisseur      = vcLibelleFour
            ttDemandeDeDevis.cCodeTheme               = Devis.LbDiv1 /* '00002' */
            ttDemandeDeDevis.cCodeArticle             = Inter.CdArt
            ttDemandeDeDevis.cLibelleArticle          = if available artic then Artic.LbArt else ""
            ttDemandeDeDevis.cLibelleIntervention     = dtDev.LbInt
            ttDemandeDeDevis.cCommentaireIntervention = dtDev.LbCom
            ttDemandeDeDevis.cCodeDelai               = inter.dlint
            ttDemandeDeDevis.cCodeFacturableA         = devis.tpidt-fac
            ttDemandeDeDevis.iNumeroTiersFacturableA  = devis.noidt-fac
            ttDemandeDeDevis.iNumeroGestionnaire      = if available ttTiers then ttTiers.iNumeroTiers else 0
            ttDemandeDeDevis.cLibelleGestionnaire     = if available ttTiers then ttTiers.cNom1 + " " + ttTiers.cPrenom1 else ""
            ttDemandeDeDevis.cCodeCle                 = dtdev.cdcle
            ttDemandeDeDevis.iNumeroSignalant         = inter.nopar
            ttDemandeDeDevis.cLibelleSignalant        = if inter.tppar = "FOU" then outilFormatage:getNomFour("F", inter.nopar, inter.tpcon)
                                                        else outilFormatage:getNomTiers(inter.tppar, inter.nopar)
            ttDemandeDeDevis.cCodeRoleSignalant       = inter.tppar
            ttDemandeDeDevis.cLibelleRoleSignalant    = outilTraduction:getLibelleProg("O_ROL", inter.tppar)
            ttDemandeDeDevis.cCodeMode                = devis.MdSig
            ttDemandeDeDevis.cCodeStatut              = inter.cdsta
            ttDemandeDeDevis.lCloture                 = estCloture(devis.nodev)
            ttDemandeDeDevis.cSysUser                 = if available tutil then tutil.nom else ""
            ttDemandeDeDevis.daSysDateCreate          = devis.dtcsy
            ttDemandeDeDevis.dtTimestampDevis         = datetime(devis.dtmsy, devis.hemsy)
            ttDemandeDeDevis.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
            ttDemandeDeDevis.dtTimestampDtdev         = datetime(dtdev.dtmsy, dtdev.hemsy)
            ttDemandeDeDevis.rRowid                   = rowid(Devis)
        .
        case devis.tpidt-fac:
            when {&TYPEROLE-coproprietaire}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = dynamic-function("getLibelleTiers" in vhTiers, string(devis.noidt-fac, ">>>>>>>>>99999"), 'C', viNumeroMandat).
            when {&TYPEROLE-locataire}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = dynamic-function("getLibelleTiers" in vhTiers, string(devis.noidt-fac, ">>>>>>>>>99999"), 'L', viNumeroMandat).
            when {&TYPECONTRAT-mandat2syndic}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = outilTraduction:getLibelle(701337).
            when {&TYPECONTRAT-mandat2Gerance}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = outilTraduction:getLibelle(701793).
        end case.

        create ttDetailsIntervention.
        assign
            ttDetailsIntervention.CRUD                     = 'R'
            ttDetailsIntervention.iNumeroIntervention      = inter.NoInt
            ttDetailsIntervention.iNumeroTraitement        = devis.nodev
            ttDetailsIntervention.cCodeArticle             = inter.cdart
            ttDetailsIntervention.cCodeCle                 = dtdev.cdcle
            ttDetailsIntervention.cCodeStatut              = dtDev.cdsta
            ttDetailsIntervention.cLibelleIntervention     = inter.lbInt
            ttDetailsIntervention.cCommentaireIntervention = inter.lbcom
            ttDetailsIntervention.cCodeStatut              = inter.cdsta
            ttDetailsIntervention.rRowidInter              = rowid(inter)
            ttDetailsIntervention.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
        .
    end.
    run destroy in vhcle.
    run destroy in vhTiers.
    run destroy in ghFournisseur.

end procedure.

procedure getDemandeDeDevisRowid:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service pour beDemandeDeDevis.cls
    ------------------------------------------------------------------------------*/
    define input  parameter prRowid as rowid no-undo.
    define output parameter table for ttDemandeDeDevis.
    define output parameter table for ttDetailsIntervention.

    define variable vcLibelleFour  as character no-undo.
    define variable vhCle          as handle    no-undo.
    define variable vhTiers        as handle    no-undo.

    define buffer intnt for intnt.
    define buffer imble for imble.
    define buffer ctrat for ctrat.
    define buffer dtDev for dtDev.
    define buffer inter for inter.
    define buffer devis for devis.
    define buffer artic for artic.
    define buffer tutil for tutil.

    empty temp-table ttDemandeDeDevis.
    run tiers/tiers.p persistent set vhTiers.
    run getTokenInstance in vhTiers (mToken:JSessionId).
    run tiers/fournisseur.p persistent set ghFournisseur. // ghFournisseur déclaré en global
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
    run mandat/clemi.p persistent set vhCle.
    run getTokenInstance in vhCle (mToken:JSessionId).

    for first devis no-lock
         where rowid(devis) = prRowid
      , first dtdev no-lock
        where dtdev.nodev = devis.nodev
      , first inter no-lock
        where inter.noint = dtdev.noint
      , first ctrat no-lock
        where ctrat.tpcon = inter.tpcon
          and ctrat.nocon = inter.nocon
      , first intnt no-lock
        where intnt.tpcon = inter.tpcon
          and intnt.nocon = inter.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt:

        run getTiersGestionnaire  in vhTiers (inter.nocon, inter.tpcon, output table ttTiers by-reference).
        find first ttTiers no-error.
        vcLibelleFour = dynamic-function('getLibelleFour' in ghFournisseur, inter.tpcon, devis.nofou).
        find first artic no-lock where artic.cdArt = inter.cdart no-error.
        /* Recherche de l'utilisateur ayant créé la demande de devis */
        find first tutil no-lock where tutil.ident_u = devis.CdCsy no-error.
        create ttDemandeDeDevis.
        assign
            ttDemandeDeDevis.CRUD                     = 'R'
            ttDemandeDeDevis.iNumeroDemandeDeDevis    = devis.nodev
            ttDemandeDeDevis.iNumeroIntervention      = inter.noint
            ttDemandeDeDevis.iNumeroMandat            = inter.nocon
            ttDemandeDeDevis.cCodeTraitement          = {&TYPEINTERVENTION-demande2devis}
            ttDemandeDeDevis.cTypeMandat              = inter.tpcon
            ttDemandeDeDevis.cLibelleMandat           = ctrat.lbnom
            ttDemandeDeDevis.iNumeroImmeuble          = intnt.noidt
            ttDemandeDeDevis.cLibelleImmeuble         = imble.lbnom
            ttDemandeDeDevis.cCodeFournisseur         = string(devis.nofou)
            ttDemandeDeDevis.cLibellefournisseur      = vcLibelleFour
            ttDemandeDeDevis.cCodeTheme               = devis.LbDiv1 /* '00002' */
            ttDemandeDeDevis.cCodeArticle             = Inter.CdArt
            ttDemandeDeDevis.cLibelleArticle          = if available artic then Artic.LbArt else ""
            ttDemandeDeDevis.cLibelleIntervention     = dtdev.LbInt
            ttDemandeDeDevis.cCommentaireIntervention = dtdev.LbCom
            ttDemandeDeDevis.cCodeDelai               = inter.dlint
            ttDemandeDeDevis.cCodeFacturableA         = devis.tpidt-fac
            ttDemandeDeDevis.iNumeroTiersFacturableA  = devis.noidt-fac
            ttDemandeDeDevis.iNumeroGestionnaire      = if available ttTiers then ttTiers.iNumeroTiers else 0
            ttDemandeDeDevis.cLibelleGestionnaire     = if available ttTiers then ttTiers.cNom1 + " " + ttTiers.cPrenom1 else ""
            ttDemandeDeDevis.cCodeCle                 = dtdev.cdcle
            ttDemandeDeDevis.iNumeroSignalant         = inter.nopar
            ttDemandeDeDevis.cLibelleSignalant        = if inter.tppar = "FOU" then outilFormatage:getNomFour("F", inter.nopar, inter.tpcon)
                                                        else outilFormatage:getNomTiers(inter.tppar, inter.nopar)
            ttDemandeDeDevis.cCodeRoleSignalant       = inter.tppar
            ttDemandeDeDevis.cLibelleRoleSignalant    = outilTraduction:getLibelleProg("O_ROL", inter.tppar)
            ttDemandeDeDevis.cCodeMode                = devis.MdSig
            ttDemandeDeDevis.cCodeStatut              = inter.cdsta
            ttDemandeDeDevis.lCloture                 = estCloture(devis.nodev)
            ttDemandeDeDevis.cSysUser                 = if available tutil then tutil.nom else ""
            ttDemandeDeDevis.daSysDateCreate          = Devis.DtCsy
            ttDemandeDeDevis.dtTimestampDevis         = datetime(devis.dtmsy, devis.hemsy)
            ttDemandeDeDevis.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
            ttDemandeDeDevis.dtTimestampDtdev         = datetime(dtdev.dtmsy, dtdev.hemsy)
            ttDemandeDeDevis.rRowid                   = rowid(Devis)
        .
        case devis.tpidt-fac:
            when {&TYPEROLE-coproprietaire}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = dynamic-function("getLibelleTiers" in vhTiers, string(devis.noidt-fac, ">>>>>>>>>99999"), 'C', inter.nocon).
            when {&TYPEROLE-locataire}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = dynamic-function("getLibelleTiers" in vhTiers, string(devis.noidt-fac, ">>>>>>>>>99999"), 'L', inter.nocon).
            when {&TYPECONTRAT-mandat2syndic}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = outilTraduction:getLibelle(701337).
            when {&TYPECONTRAT-mandat2Gerance}
                then ttDemandeDeDevis.cLibelleTiersFacturableA = outilTraduction:getLibelle(701793).
        end case.

        create ttDetailsIntervention.
        assign
            ttDetailsIntervention.CRUD = 'R'
            ttDetailsIntervention.iNumeroIntervention      = inter.NoInt
            ttDetailsIntervention.iNumeroTraitement        = devis.nodev
            ttDetailsIntervention.cCodeArticle             = inter.cdart
            ttDetailsIntervention.cCodeCle                 = dtdev.cdcle
            ttDetailsIntervention.cCodeStatut              = dtDev.cdsta
            ttDetailsIntervention.cLibelleIntervention     = inter.lbInt
            ttDetailsIntervention.cCommentaireIntervention = inter.lbcom
            ttDetailsIntervention.cCodeStatut              = inter.cdsta
            ttDetailsIntervention.rRowidInter              = rowid(inter)
            ttDetailsIntervention.dtTimestampInter         = datetime(inter.dtmsy, inter.hemsy)
        .
    end.
    run destroy in vhcle.
    run destroy in vhTiers.
    run destroy in ghFournisseur.

end procedure.

procedure updateDemandeDedevis:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour d'une demande de devis
    Notes  : service pour beDemandeDeDevis.cls
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttDemandeDeDevis.
    define output parameter table for ttDemandeDeDevis2.

    define variable viActionUtilisateur as integer   no-undo.
    define variable vcTypeIntervention  as character no-undo initial {&TYPEINTERVENTION-demande2devis}.
    define buffer devis for devis.
    define buffer inter for inter.
    define buffer dtDev for dtDev.

    empty temp-table ttDemandeDeDevis2.
blocTransaction:
    do transaction:
        for each ttDemandeDeDevis
            where ttDemandeDeDevis.CRUD = 'U':
            {&_proparse_ prolint-nowarn(blocklabel)}
            if not controleDeleteUpdateDemandeDeDevis(ttDemandeDeDevis.CRUD, ttDemandeDeDevis.iNumeroDemandeDeDevis) then next.
            find first devis exclusive-lock
                 where rowid(devis) = ttDemandeDeDevis.rRowid no-wait no-error.
            if outils:isUpdated(buffer devis:handle, 'devis: ', string(ttDemandeDeDevis.iNumeroDemandeDeDevis), ttDemandeDeDevis.dtTimestampDevis)
            then undo blocTransaction, leave blocTransaction.

            assign
                viActionUtilisateur = {&ACTION-modification}
                devis.cdmsy     = mtoken:cUser
                devis.Dtmsy     = today
                devis.Hemsy     = mtime
                devis.MdSig     = ttDemandeDeDevis.cCodeMode
                devis.LbDiv1    = ttDemandeDeDevis.cCodeTheme
                devis.tpidt-fac = ttDemandeDeDevis.cCodeFacturableA
                devis.noidt-fac = ttDemandeDeDevis.iNumeroTiersFacturableA
                devis.tppar     = ttDemandeDeDevis.cCodeRoleSignalant
                devis.nopar     = ttDemandeDeDevis.iNumeroSignalant
            .
            find first inter exclusive-lock
                where inter.noint = ttDemandeDeDevis.iNumeroIntervention no-wait no-error.
            if outils:isUpdated(buffer inter:handle, 'devis: ', string(ttDemandeDeDevis.iNumeroDemandeDeDevis), ttDemandeDeDevis.dtTimestampInter)
            then undo blocTransaction, leave blocTransaction.

            assign
                 inter.CdArt = ttDemandeDeDevis.cCodeArticle
                 inter.LbInt = ttDemandeDeDevis.cLibelleIntervention
                 inter.NoRes = ttDemandeDeDevis.iNumeroGestionnaire
                 inter.TpRes = {&TYPEROLE-gestionnaire}
                 inter.TpPar = ttDemandeDeDevis.cCodeRoleSignalant
                 inter.NoPar = ttDemandeDeDevis.iNumeroSignalant
                 inter.TpCon = ttDemandeDeDevis.cTypeMandat
                 inter.NoCon = ttDemandeDeDevis.iNumeroMandat
                 inter.DlInt = ttDemandeDeDevis.cCodeDelai
                 inter.LbCom = ttDemandeDeDevis.cCommentaireIntervention
                 inter.cdmsy = mtoken:cUser
                 inter.Dtmsy = today
                 inter.Hemsy = mtime
            .
            find first dtdev exclusive-lock
                 where dtdev.noint = ttDemandeDeDevis.iNumeroIntervention
                   and dtdev.nodev = devis.nodev no-wait no-error.
            if outils:isUpdated(buffer dtdev:handle, 'dtdev: ', string(ttDemandeDeDevis.iNumeroIntervention), ttDemandeDeDevis.dtTimestampDtdev)
            then undo blocTransaction, leave blocTransaction.

            assign
                dtDev.LbInt = ttDemandeDeDevis.cLibelleIntervention
                dtDev.cdsta = inter.cdsta
                dtDev.LbCom = ttDemandeDeDevis.cCommentaireIntervention
                dtdev.cdcle = ttDemandeDeDevis.cCodeCle
                dtdev.cdmsy = mtoken:cUser
                dtdev.Dtmsy = today
                dtdev.Hemsy = mtime
            .
            run createttDemandeDevis2(Devis.nodev, vcTypeIntervention).
            run createHistorique(ttDemandeDeDevis.cTypeMandat, dtdev.nodev, dtdev.noint, vcTypeIntervention, viActionUtilisateur).
        end.
    end.

end procedure.

procedure CreateDemandeDeDevis:
    /*------------------------------------------------------------------------------
    Purpose: Creation ou modification demndeDeDevis
    Notes  : service pour beDemandeDeDevis.cls
    ------------------------------------------------------------------------------*/
    define input  parameter table-handle phtt.
    define input  parameter table for ttFournisseur.
    define input  parameter table for ttError.
    define output parameter table for ttDemandeDeDevis2.

    define variable vhbtt                as handle    no-undo.
    define variable vhqtt                as handle    no-undo.
    define variable viActionUtilisateur  as integer   no-undo.
    define variable vcTypeIntervention   as character no-undo initial {&TYPEINTERVENTION-demande2devis}.
    define variable viNumeroIntervention as integer   no-undo.
    define variable viNextNumeroDD       as integer   no-undo.

    define buffer devis for devis.
    define buffer inter for inter.
    define buffer dtDev for dtDev.

    empty temp-table ttDemandeDeDevis2.
    run tiers/fournisseur.p persistent set ghFournisseur.
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
    vhbtt = phtt:default-buffer-handle.
    create query vhqtt.
    vhqtt:set-buffers(vhbtt).
    vhqtt:query-prepare(substitute('for each &1 where &1.CRUD="C"', vhbtt:name)).

 blocTransaction:
    do transaction:
        for each ttFournisseur where ttFournisseur.cCodeFournisseur > "":
            vhqtt:query-open().
blocRepeat:
            repeat:
                vhqtt:get-next().
                if vhqtt:query-off-end then leave blocRepeat.

                if not controleValidationFournisseur(vhbtt::cTypeMandat, vhbtt::iNumeroMandat, ttFournisseur.cCodeFournisseur, table ttError by-reference) then next blocRepeat.
                /*--> Recherche du prochain n° d'Inter */
                /* Pour la création d'un devis pour plusieurs fournisseur, seul un enregistrement d'intervention doit être créé.
                   De plus lorsque l'on vient d'un signalement on utilise l'intervention du signalement.
                */
                if vhbtt::iNumeroIntervention <> 0
                then viNumeroIntervention = vhbtt::iNumeroIntervention.
                else if viNumeroIntervention = 0 then do:    // OUI, il faut tester viNumeroIntervention = 0, fonctionnel!!!
                    {&_proparse_ prolint-nowarn(wholeindex)}
                    find last inter no-lock no-error.
                    viNumeroIntervention = if available inter then inter.noint + 1 else 1.
                end.
                //   if not controleDemande2Devis('C', hbtt) then undo blocTransaction, leave blocTransaction.
                viActionUtilisateur = {&ACTION-creation}.
                if not getNextDemande2Devis(viActionUtilisateur, output viNextNumeroDD)
                then undo blocTransaction, leave blocTransaction.   // erreur créée dans getNextOrdre2Service.

                create devis.
                assign
                    devis.noref     = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                    devis.nodev     = viNextNumeroDD
                    devis.Nofou     = integer(ttFournisseur.cCodeFournisseur)
                    devis.LbDiv1    = vhbtt::cCodeTheme
                    devis.MdSig     = vhbtt::cCodeMode
                    devis.tpidt-fac = vhbtt::cCodeFacturableA
                    devis.noidt-fac = vhbtt::iNumeroTiersFacturableA
                    devis.tppar     = vhbtt::cCodeRoleSignalant
                    devis.nopar     = vhbtt::iNumeroSignalant
                    devis.cdcsy     = mtoken:cUser
                    devis.Dtcsy     = today
                    devis.Hecsy     = mtime
                    devis.cdmsy     = mToken:cUser
                    devis.Dtmsy     = devis.Dtcsy
                    devis.Hemsy     = devis.Hecsy
                    vhbtt::rRowid   = rowid(devis)
                    vhbtt::iNumeroDemandeDeDevis = viNextNumeroDD      // besoin pour mise à jour lienLot
                .
                mError:createInfoRowid(rowid(devis)).          // enregistrement créé, permet de renvoyer le rowid en réponse.
                {&_proparse_prolint-nowarn(nowait)}
                find first inter exclusive-lock where inter.noint = viNumeroIntervention no-error.
                if not available inter then do:
                    create inter.
                    assign
                        inter.noref = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                        inter.noint = viNumeroIntervention
                        inter.cdcsy = mtoken:cUser
                        inter.DtCsy = today
                        inter.HeCsy = mtime
                        inter.CdSta = {&STATUTINTERVENTION-enCours}
                        inter.CdArt = vhbtt::cCodeArticle
                        inter.LbInt = vhbtt::cLibelleIntervention
                        inter.DlInt = vhbtt::cCodeDelai
                        inter.TpPar = vhbtt::cCodeRoleSignalant
                        inter.NoPar = vhbtt::iNumeroSignalant
                        inter.TpRes = {&TYPEROLE-gestionnaire}
                        inter.NoRes = vhbtt::iNumeroGestionnaire
                        inter.TpCon = vhbtt::cTypeMandat
                        inter.NoCon = vhbtt::iNumeroMandat
                        inter.LbCom = vhbtt::cCommentaireIntervention
                        inter.cdmsy = mtoken:cUser
                        inter.Dtmsy = today
                        inter.Hemsy = mtime
                    .
                end.
                else assign
                    inter.cdSta = {&STATUTINTERVENTION-enCours}
                    inter.dtmsy = today
                    inter.hemsy = mtime
                .
                /* Creattion dtdev: detail devis */
                if not can-find(first dtdev no-lock
                     where dtdev.noint = viNumeroIntervention
                       and dtdev.nodev = devis.nodev) then do:
                    create dtdev.
                    assign
                        dtdev.noref = integer(if vhbtt::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                        dtdev.nodev = devis.nodev
                        dtdev.noint = viNumeroIntervention
                        dtdev.cdcsy = mtoken:cUser
                        dtdev.dtcsy = today
                        dtdev.hecsy = mtime
                        dtdev.LbInt = vhbtt::cLibelleIntervention
                        dtdev.LbCom = vhbtt::cCommentaireIntervention
                        dtdev.dlInt = vhbtt::cCodeDelai
                        dtdev.CdSta = {&STATUTINTERVENTION-enCours}
                        dtdev.cdcle = vhbtt::cCodeCle
                        dtdev.cdmsy = mtoken:cUser
                        dtdev.dtmsy = today
                        dtdev.hemsy = mtime
                    .
                end.
                /* Creation des historiques de traitements */
                run createttDemandeDevis2(Devis.nodev, vcTypeIntervention).
                run createHistorique(vhbtt::cTypeMandat, devis.nodev, viNumeroIntervention, vcTypeIntervention, viActionUtilisateur).
            end.
            vhqtt:query-close().
        end.
    end.
    assign error-status:error = false no-error. // reset error-status:error
    run destroy in ghFournisseur.

end procedure.

procedure createttDemandeDevis2 private:
    /*------------------------------------------------------------------------------
    Purpose: Création de la temps table de retour pour les liens lots
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroDemandeDevis as integer   no-undo.
    define input parameter pcTypeIntervention   as character no-undo.

    if not can-find(first ttDemandeDeDevis2
        where ttDemandeDeDevis2.iNumeroDemandeDeDevis = piNumeroDemandeDevis)
    then do:
        create ttDemandeDeDevis2.
        assign
            ttDemandeDeDevis2.iNumeroDemandeDeDevis = piNumeroDemandeDevis
            ttDemandeDeDevis2.cCodeTraitement       = pcTypeIntervention
        .
    end.
end procedure.

procedure createHistorique private:
    /*------------------------------------------------------------------------------
    Purpose: Création des traitements liés à la demande de devis
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat           as character no-undo.
    define input parameter piNumeroDemandeDeDevis as integer   no-undo.
    define input parameter piNumeroIntervention   as integer   no-undo.
    define input parameter pcTypeIntervention     as character no-undo.
    define input parameter piActionUtilisateur    as integer   no-undo.

    define variable viNumeroTraitement as integer no-undo.
    define buffer trInt for trInt.
    define buffer inter for inter.

    for each inter no-lock
        where inter.noint = piNumeroIntervention:
        /*--> Recherche prochain n° traitement sur l'intervention */
        {&_proparse_ prolint-nowarn(use-index)}
        find last trint no-lock
            where trint.noint = inter.NoInt
            use-index ix_TrInt01 no-error.         // index trint.noint, trint.noidt
        viNumeroTraitement = if available trint then trint.noidt + 1 else 1.
        create TrInt.
        assign
            TrInt.noref = integer(if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
            TrInt.noInt = inter.NoInt
            trInt.noIdt = viNumeroTraitement
            TrInt.tptrt = pcTypeIntervention
            TrInt.cdsta = inter.cdSta
            TrInt.notrt = piNumeroDemandeDeDevis
            TrInt.lbcom = outilTraduction:getLibelle(piActionUtilisateur)
            TrInt.cdcsy = mtoken:cUser
            TrInt.dtcsy = today
            TrInt.hecsy = mtime
        .
    end.
end procedure.

procedure deleteDemandeDeDevis:
    /*------------------------------------------------------------------------------
    Purpose: Suppression d'une demande de devis
    Notes  : service pour beDemandeDeDevis.cls
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define variable viNumeroTraitement  as int64      no-undo.

    define buffer dtLot   for dtLot.
    define buffer dtdev   for dtdev.
    define buffer inter   for inter.
    define buffer trint   for trint.
    define buffer devis   for devis.
    define buffer vbDtdev for dtdev.

    viNumeroTraitement = poCollection:getInt64("iNumeroTraitement").
    if controleDeleteUpdateDemandeDeDevis('D', viNumeroTraitement)
    then for first devis exclusive-lock where devis.nodev = viNumeroTraitement:
        for each dtdev exclusive-lock where dtdev.nodev = devis.nodev:
            for first inter exclusive-lock where inter.noint = dtdev.noint:
                /*--> On ne supprime pas l'intervention si elle est rattachée à un signalement */
                if inter.nosig = 0 then do:
                    /* On ne supprime pas l'intervention si elle est rattachée:
                         à un autre devis, à une reponse, à un ordre de service,  à une facture */
                    if not can-find (first vbDtdev no-lock where vbDtdev.noint = inter.noint and vbDtdev.nodev <> devis.nodev)
                    and not can-find (first svdev no-lock where svdev.noint = inter.noint)
                    and not can-find (first dtord no-lock where dtord.noint = inter.noint)
                    and not can-find (first dtfac no-lock where dtfac.noint = inter.noint)
                    then do:
                        /*--> Suppression des traitements de cette intervention */
                        for each trint exclusive-lock where trint.noint = inter.noint:
                            delete trint.
                        end.
                        /*--> Suppression de l'intervention */
                        delete inter.
                    end.
                end.
                else assign inter.cdsta = {&STATUTINTERVENTION-initie}.
            end.
            /* Suppression du detail devis */
            delete dtdev.
        end.
        /* Suppression des traitements de ce devis */
        for each trint exclusive-lock
            where trint.tptrt = {&TYPEINTERVENTION-demande2devis}
              and trint.notrt = devis.nodev:
            delete trint.
        end.
        /* suppression des lots associés */
        for each dtlot exclusive-lock
            where dtlot.tptrt = {&TYPEINTERVENTION-demande2devis}
              and dtlot.notrt = devis.nodev:
            delete dtlot.
        end.
        /* Suppression du devis */
        delete devis.
    end.
end procedure.

procedure duplicationDemandeDeDevis:
    /*------------------------------------------------------------------------------
    Purpose: Duplication d'un devis pour X fournisseurs
    Notes  : service pour beDemandeDeDevis.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttDemandeDeDevis.
    define input parameter table for ttFournisseur.
    define input parameter table for ttError.

    define variable viNumeroTraitement as integer no-undo.
    define variable viNumeroDevis      as integer no-undo.

    define buffer dtDev   for dtdev.
    define buffer vbDtdev for dtdev.
    define buffer devis   for devis.
    define buffer vbdevis for devis.
    define buffer dtlot   for dtlot.
    define buffer vbDtlot for dtlot.
    define buffer inter   for inter.
    define buffer local   for local.
    define buffer trint   for trint.

    // ghFournisseur déclaré en global
    run tiers/fournisseur.p persistent set ghFournisseur.
    run getTokenInstance in ghFournisseur (mToken:JSessionId).
bloc:
    for first ttdemandeDeDevis transaction:
        /*--> Creation / Mise à jour du Devis */
        for first devis no-lock
            where devis.nodev = ttdemandeDeDevis.iNumeroDemandeDeDevis
          , each ttFournisseur                           // Dupliquer le devis pour chaque fournisseur selectionné
            where ttFournisseur.cCodeFournisseur <> "":
            {&_proparse_ prolint-nowarn(blocklabel)}
            if not controleValidationFournisseur(ttdemandeDeDevis.cTypeMandat, ttdemandeDeDevis.iNumeroMandat, ttFournisseur.cCodeFournisseur, table ttError by-reference) then next.

            /*--> Recherche du prochain numero libre */
            viNumeroDevis = ((year(today) modulo 100) * 100  + month(today)) * 100000.
            find last vbDevis no-lock
                where vbDevis.nodev > viNumeroDevis no-error.
            if available vbDevis
            then if vbDevis.nodev = viNumeroDevis + 99999
                 then do:
                     mError:createError({&erreur}, 107713).
                     undo bloc, leave bloc.
                 end.
                 else viNumeroDevis = vbDevis.nodev + 1.
            else viNumeroDevis = viNumeroDevis + 00001.
            /*--> Creation de l'enregistrement */
            create vbDevis.
            buffer-copy devis
                except noref nodev nofou cdmsy dtmsy hemsy to vbDevis
                assign
                    vbDevis.noref = integer(if ttdemandeDeDevis.cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro
                                           else if ttdemandeDeDevis.cTypeMandat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance
                                           else mtoken:cRefPrincipale)
                    vbDevis.nodev = viNumeroDevis
                    vbDevis.nofou = integer(ttFournisseur.cCodeFournisseur)
                    vbDevis.cdmsy = mtoken:cUser
                    vbDevis.Dtmsy = today
                    vbDevis.Hemsy = mtime
            .
            /*--> Dupliquer le detail du devis */
            for each dtdev no-lock
                where dtdev.nodev = ttdemandeDeDevis.iNumeroDemandeDeDevis
              , first inter no-lock
                where inter.noint = dtdev.noint:
                create vbDtdev.
                buffer-copy dtdev
                    except noref noint nodev CdSta dtmsy hemsy cdmsy to vbDtdev
                    assign
                        vbDtdev.noref = integer(if ttdemandeDeDevis.cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro
                                          else if ttdemandeDeDevis.cTypeMandat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance
                                          else mtoken:cRefPrincipale)
                        vbDtdev.noint = inter.noint
                        vbDtdev.NoDev = viNumeroDevis
                        vbDtdev.CdSta = {&STATUTINTERVENTION-enCours}
                        vbDtdev.cdmsy = mtoken:cUser
                        vbDtdev.Dtmsy = today
                        vbDtdev.Hemsy = mtime
                .
            end.
            /* 0306/0215 : dupliquer le détail des 'lot' */
            for each dtlot no-lock
                where dtlot.tptrt = {&TYPEINTERVENTION-demande2devis}
                  and dtlot.notrt = devis.nodev
              , first local no-lock
                where local.noloc = dtlot.noloc:
                create vbDtlot.
                buffer-copy dtLot
                    except notrt dtmsy hemsy cdmsy to vbDtlot
                    assign
                        vbDtlot.notrt = viNumeroDevis
                        vbDtlot.cdmsy = mtoken:cUser
                        vbDtlot.dtmsy = today
                        vbDtlot.hemsy = mtime
                .
            end.
            /*--> Creation du traitement */
            for each vbDtdev no-lock
                where vbDtdev.NoDev = viNumeroDevis
              , first inter no-lock
                where inter.NoInt = vbDtdev.NoInt:
                /*--> Recherche prochaine n° traitement sur l'intervention */
                {&_proparse_ prolint-nowarn(use-index)}
                find last trint no-lock
                    where trint.noint = inter.NoInt
                    use-index ix_TrInt01 no-error.     // index trint.noint, trint.noidt
                viNumeroTraitement = if available trint then trint.noidt + 1 else 1.
                create trint.
                assign
                    trint.noRef = integer(if ttdemandeDeDevis.cTypeMandat = {&TYPECONTRAT-mandat2Syndic}  then mtoken:cRefCopro
                                     else if ttdemandeDeDevis.cTypeMandat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance
                                     else mtoken:cRefPrincipale)
                    trint.noint = inter.noint
                    trint.noidt = viNumeroTraitement
                    trint.tptrt = {&TYPEINTERVENTION-demande2devis}
                    trint.notrt = viNumeroDevis
                    trint.cdsta = vbDtdev.cdsta
                    trint.rgtrt = {&RANGIMPORTANCE-devis}
                    TrInt.duTrt = 0
                    trint.lbcom = outilTraduction:getLibelle(107754) + " " + string(ttdemandeDeDevis.iNumeroDemandeDeDevis)
                    trint.cdcsy = mtoken:cUser
                    trint.dtcsy = today
                    trint.hecsy = mtime
                .
            end.
        end.
    end.
    assign error-status:error = false no-error.   // reset error-status:error.
    run destroy in ghFournisseur.

end procedure.
