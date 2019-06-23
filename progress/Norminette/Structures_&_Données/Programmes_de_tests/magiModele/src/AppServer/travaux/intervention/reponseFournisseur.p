/*------------------------------------------------------------------------
File        : reponseFournisseur.p
Purpose     :
Author(s)   : KANTENA - 2016/08/11
Created     : Thu Aug 11 13:38:41 CEST 2016
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2intervention.i}
{preprocesseur/statut2intervention.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/rang2importance.i}
{preprocesseur/actionUtilisateur.i}

using parametre.pclie.parametrageChaineTravaux.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{travaux/include/reponseFournisseur.i}
{travaux/include/detailsIntervention.i}

function controleDeleteUpdateReponse returns logical private (pcMode as character, piNumeroDemandeDeDevis as integer, piNumeroDossier as integer, piNumeroContrat as integer, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer svdev for svdev.

    if can-find(first devis no-lock where devis.nodev = piNumeroDemandeDeDevis)
    then do:
        // Modification/Suppression impossible si existence d'un ordre de service sur ce devis
        for each svdev no-lock
            where svdev.nodev = piNumeroDemandeDeDevis
              and can-find(first dtord no-lock where dtord.noint = svdev.noint):
            mError:create2Error(if pcMode = 'U' then 104446 else 104432, 107745).
            return false.
        end.
        // Modification/Suppression impossible si existence d'une facture sur ce devis
        for each svdev no-lock
            where svdev.nodev = piNumeroDemandeDeDevis
              and can-find(first dtfac no-lock where dtfac.noint = svdev.noint):
            mError:create2Error(if pcMode = 'U' then 104446 else 104432, 107746).
            return false.
        end.

        // Suppession impossible si reponse voté et existence d'appels de fond
        if pcMode = 'D' and can-find(first svdev where svdev.nodev = piNumeroDemandeDeDevis)
        then for each svdev no-lock
            where svdev.nodev = piNumeroDemandeDeDevis
              and can-find(first doset no-lock
               where doset.tpcon = pcTypeContrat
                 and doset.nocon = piNumeroContrat
                 and doset.nodos = piNumeroDossier
                 and doset.noint = svdev.noint):
            mError:create2Error(104432, 211703).
            return false.
        end.
    end.
    return true.

end function.

function estCloture returns logical private (piNumeroTraitement as int64):
    /*------------------------------------------------------------------------------
    Purpose: La réponse est-elle clôturée ?
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer trint for TrInt.

    for last trint no-lock
       where trint.notrt = piNumeroTraitement
         and trint.tptrt = {&TYPEINTERVENTION-reponseDevis}:
        if TrInt.CdSta = {&STATUTINTERVENTION-termine} then return true.
    end.
    return false.
end function.

procedure createReponseFournisseur:
    /*------------------------------------------------------------------------------
    Purpose: création d'une réponse fournisseur
    Notes  : service utilisé par beReponseFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phtt.
    define input parameter table for ttDetailsIntervention.

    define variable vhbtt as handle  no-undo.
    define variable vhqtt as handle  no-undo.

    define buffer devis   for devis.
    define buffer dtlot   for dtlot.
    define buffer vbDtlot for dtlot.

    vhbtt = phtt:default-buffer-handle.
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

            /* Vérification de l'existence du devis */
            find first devis exclusive-lock
                 where devis.nodev = vhbtt::iNumeroDemandeDeDevis no-wait no-error.
            if outils:isUpdated(buffer devis:handle, 'devis: ', string(vhbtt::iNumeroDemandeDeDevis), vhbtt::dtTimestampDevis)
            then undo blocRepeat, leave blocRepeat.

            /* THK - 14/04/2017 - Evolution GI : La référence fournisseur n'est plus obligatoire
            if vhbtt::cReferenceDevisFournisseur = "" or vhbtt::cReferenceDevisFournisseur = ? then do:
                // La référence fournisseur est obligatoire
                mError:createError({&Error},107752).
                return.
            end.
            */
            devis.noreg = vhbtt::cReferenceDevisFournisseur.
            mError:createInfoRowid(rowid(devis)). // enregistrement créé, permet de renvoyer le rowid en réponse.
            run updateDetailIntervention(devis.tpPar, devis.NoPar, vhbtt).
            run createDetailIntervention(devis.nodev, devis.tpPar, devis.NoPar, vhbtt).
            run createTraitement({&Action-creation}, devis.nodev, vhbtt).
            /* Reprise des lots du devis */
            for each vbDtlot no-lock
               where vbDtlot.tptrt = {&TYPEINTERVENTION-demande2devis}
                 and vbDtlot.notrt = devis.nodev:
                create dtlot.
                assign
                    dtlot.tptrt = {&TYPEINTERVENTION-reponseDevis}
                    dtlot.notrt = devis.nodev
                    dtlot.noloc = vbDtlot.noloc
                    dtlot.dtcsy = today
                    dtlot.hecsy = mtime
                    dtlot.cdcsy = mtoken:cUser
                    dtlot.dtmsy = today
                    dtlot.hemsy = mtime
                    dtlot.cdmsy = mtoken:cUser
                .
            end.
        end.
    end.
end procedure.

procedure updateReponseFournisseur:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour d'une réponse fournisseur
    Notes  : service pour beReponseFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phtt.
    define input parameter table for ttDetailsIntervention.

    define variable vhbtt as handle no-undo.
    define variable vhqtt as handle no-undo.

    define buffer devis for devis.

    vhbtt = phtt:default-buffer-handle.
    create query vhqtt.
    vhqtt:set-buffers(vhbtt).
    vhqtt:query-prepare(substitute('for each &1 where &1.CRUD="U"', vhbtt:name)).
    vhqtt:query-open().

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhqtt:get-next().
            if vhqtt:query-off-end then leave blocRepeat.

            /* Vérification de l'existence du devis */
            find first devis exclusive-lock
                where devis.nodev = vhbtt::iNumeroDemandeDeDevis no-wait no-error.
            if outils:isUpdated(buffer devis:handle, 'devis: ', string(vhbtt::iNumeroDemandeDeDevis), vhbtt::dtTimestampDevis)
            or not controleDeleteUpdateReponse('U', devis.nodev, 0, 0, '')
            then undo blocTransaction, leave blocTransaction.

            /* THK - 14/04/2017 - Evolution GI : La référence fournisseur n'est plus obligatoire
            if vhbtt::cReferenceDevisFournisseur = "" or vhbtt::cReferenceDevisFournisseur = ? then do:
                // La référence fournisseur est obligatoire
                mError:createError({&Error},107752).
                return.
            end.
            */
            devis.noreg = vhbtt::cReferenceDevisFournisseur.
            run deleteDetailIntervention(vhbtt).
            run updateDetailIntervention(devis.tpPar, devis.NoPar, vhbtt).
            run createDetailIntervention(devis.nodev, devis.tpPar, devis.NoPar, vhbtt).
            run createTraitement({&Action-modification}, devis.nodev,vhbtt).
        end.
    end.
end procedure.

procedure deleteReponseFournisseur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beReponseFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable viNumeroDemandeDeDevis as integer   no-undo.
    define variable viNumeroDossier        as int64     no-undo.
    define variable viNumeroMandat         as int64     no-undo.
    define variable vcTypeMandat           as character no-undo.

    define buffer devis for devis.
    define buffer svdev for svdev.
    define buffer inter for inter.
    define buffer trint for trint.
    define buffer dtlot for dtlot.

    assign
        viNumeroDemandeDeDevis = poCollection:getInt64("iNumeroTraitement")
        viNumeroDossier        = poCollection:getInt64("iNumeroDossier")
        viNumeroMandat         = poCollection:getint64("iNumeroMandat")
        vcTypeMandat           = poCollection:getCharacter("cTypeMandat")
    .
    if controleDeleteUpdateReponse('D', viNumeroDemandeDeDevis, viNumeroDossier, viNumeroMandat, vcTypeMandat)
    then for first devis no-lock
        where devis.nodev = viNumeroDemandeDeDevis:
        /* Suppression du detail de la réponse */
        for each svdev exclusive-lock
            where svdev.nodev = devis.nodev
          , first inter exclusive-lock
            where inter.noint = SvDev.NoInt:
            /*--> suppression de l'intervention si elle n'est pas lié a un détail devis */
            if not can-find(first dtdev no-lock where dtdev.nodev = svdev.nodev)
            then delete inter.
            else inter.cdsta = {&STATUTINTERVENTION-enCours}. // THK : Nouvelle règle de modernisation. Si elle existe on positionne l'intervention à "en cours"
            delete svdev.
        end.
        /* Suppression des traitements de ce devis */
        for each trint exclusive-lock
            where trint.tptrt = {&TYPEINTERVENTION-reponseDevis}
              and trint.notrt = devis.nodev:
            delete trint.
        end.
        /* THK : Nouvelle règle de modernisation. */
        /* Remise au statut "En cours" des traitements de ce devis */
        for each trint exclusive-lock
            where trint.tptrt = {&TYPEINTERVENTION-demande2Devis}
              and trint.notrt = devis.nodev:
            trint.cdsta = {&STATUTINTERVENTION-enCours}.
        end.

        /* Suppression des lien avec les lots */
        for each dtlot exclusive-lock
            where dtlot.tptrt = {&TYPEINTERVENTION-reponseDevis}
              and dtlot.notrt = devis.nodev:
            delete dtlot.
        end.
    end.
end procedure.

procedure createDetailIntervention private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroDemandeDeDevis as integer   no-undo.
    define input parameter pcDevisTpPar           as character no-undo.
    define input parameter piDevisNoPar           as integer   no-undo.
    define input parameter phBuffer               as handle    no-undo.

    define variable viNextNumeroIntervention  as integer no-undo.

    define buffer inter for inter.
    define buffer svdev for svdev.

blocTransaction:
    do transaction:
blocDetail:
        for each ttDetailsIntervention
           where ttDetailsIntervention.CRUD = 'C':
            /* Recherche du prochaine n° d'Inter */
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last inter no-lock no-error.
            viNextNumeroIntervention = if available inter then inter.noint + 1 else 1.
            create inter.
            assign
                inter.noref = integer(if phBuffer::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                inter.noint = viNextNumeroIntervention
                inter.nocon = phBuffer::iNumeroMandat
                inter.tpcon = phBuffer::cTypeMandat
                inter.cdcsy = mtoken:cUser
                inter.DtCsy = today
                inter.HeCsy = mtime
                inter.LbInt = ttDetailsIntervention.cLibelleIntervention
                inter.DlInt = phBuffer::cCodeDelai
                inter.QtInt = ttDetailsIntervention.dQuantite
                inter.cdcle = ttDetailsIntervention.cCodeCle
                inter.CdArt = ttDetailsIntervention.cCodeArticle
                inter.tppar = pcDevisTpPar
                inter.nopar = piDevisNoPar
                inter.LbCom = ttDetailsIntervention.cCommentaireIntervention
                inter.qtfac = ttDetailsIntervention.dQuantite
                inter.cdsta = {&STATUTINTERVENTION-enCours}
                inter.cdmsy = mToken:cUser
                inter.dtmsy = today
                inter.hemsy = mtime
                ttDetailsIntervention.iNumeroIntervention = viNextNumeroIntervention
                ttDetailsIntervention.dtTimestampInter    = datetime(inter.dtmsy, inter.hemsy)
            .
            create svdev.
            assign
                svdev.noref     = integer(if phBuffer::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                svdev.noint     = ttDetailsIntervention.iNumeroIntervention
                svdev.NoDev     = piNumeroDemandeDeDevis
                svdev.cdcsy     = mtoken:cUser
                svdev.DtCsy     = today
                svdev.HeCsy     = mtime
                SvDev.NbJou     = ttDetailsIntervention.daFinPrevue - SvDev.DtCsy
                svdev.QtInt     = ttDetailsIntervention.dQuantite
                svdev.PxUni     = ttDetailsIntervention.dPrixUnitaire
                svdev.MtInt     = (ttDetailsIntervention.dQuantite * ttDetailsIntervention.dPrixUnitaire) // Montant net
                svdev.TxRem     = ttDetailsIntervention.dTauxRemise
                svdev.CdTva     = ttDetailsIntervention.iCodeTVA
                svdev.CdSta     = {&STATUTINTERVENTION-initie}
                svdev.LbCom     = outilTraduction:getLibelle(101287)
                svDev.LbInt     = ttDetailsIntervention.cLibelleIntervention
                svdev.cdcle     = ttDetailsIntervention.cCodeCle
                svdev.tpidt-fac = phBuffer::cCodeFacturableA
                svdev.noidt-fac = phBuffer::iNumeroTiersFacturableA
                svdev.tppar     = phBuffer::cCodeRoleSignalant
                svdev.nopar     = phBuffer::iNumeroSignalant
                svdev.mdsig     = phBuffer::cCodeMode
                svdev.cdmsy     = mToken:cUser
                svdev.dtmsy     = today
                svdev.hemsy     = mtime
            .
        end.
    end.
end procedure.

procedure updateDetailIntervention private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter pcTppar  as character no-undo.
    define input parameter piNopar  as integer   no-undo.
    define input parameter phBuffer as handle    no-undo.

    define buffer inter  for inter.
    define buffer svDev  for svDev.

blocTransaction:
    do transaction:
        /*--> Creation / Mise à jour des interventions */
        for each ttDetailsIntervention
            where ttDetailsIntervention.CRUD = 'U'
              and ttDetailsIntervention.iNumeroTraitement = phBuffer::iNumeroDemandeDeDevis:
            find first inter exclusive-lock
                where rowid(inter) = ttDetailsIntervention.rRowidInter no-wait no-error.
            if outils:isUpdated(buffer inter:handle, 'inter: ', string(ttDetailsIntervention.iNumeroIntervention), ttDetailsIntervention.dtTimestampInter)
            then undo blocTransaction, leave blocTransaction.

            assign
                inter.CdArt  = ttDetailsIntervention.cCodeArticle
                inter.TpCon  = phBuffer::cTypeMandat
                inter.NoCon  = phBuffer::iNumeroMandat
                inter.LbCom  = ttDetailsIntervention.cCommentaireIntervention
                inter.qtfac  = ttDetailsIntervention.dQuantite
                inter.cdsta  = {&STATUTINTERVENTION-enCours}
                inter.cdcle  = ttDetailsIntervention.cCodeCle
                inter.DlInt  = phBuffer::cCodeDelai
                inter.tppar  = pcTppar
                inter.nopar  = piNopar
                inter.cdmsy  = mToken:cUser
                inter.Dtmsy  = today
                inter.Hemsy  = mtime
            .
            if ttDetailsIntervention.rRowidSvDev = ?
            then do:
                create svdev.
                assign
                     svdev.noref = integer(if phBuffer::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                     svdev.noint = ttDetailsIntervention.iNumeroIntervention
                     svdev.nodev = ttDetailsIntervention.iNumeroTraitement
                     svdev.cdcsy = mtoken:cUser
                     svdev.dtcsy = today
                     svdev.hecsy = mtime
                .
            end.
            else do:
                find first svdev exclusive-lock
                    where rowid(svdev) = ttDetailsIntervention.rRowidSvdev no-wait no-error.
                if outils:isUpdated(buffer svDev:handle, 'svdev: ', string(ttDetailsIntervention.iNumeroTraitement), ttDetailsIntervention.dtTimestampSvDev)
                then undo blocTransaction, leave blocTransaction.
            end.
            assign
                svDev.LbInt = ttDetailsIntervention.cLibelleIntervention
                svDev.QtInt = ttDetailsIntervention.dQuantite
                svDev.PxUni = ttDetailsIntervention.dPrixUnitaire
                svDev.MtInt = (ttDetailsIntervention.dQuantite * ttDetailsIntervention.dPrixUnitaire) // Montant net
                svDev.CdTva = ttDetailsIntervention.iCodeTVA
                svDev.NbJou = ttDetailsIntervention.daFinPrevue - SvDev.DtCsy
                svDev.cdSta = {&STATUTINTERVENTION-enCours}
                svDev.LbCom = ttDetailsIntervention.cCommentaireIntervention
                svDev.cdcle = ttDetailsIntervention.cCodeCle
                svDev.cdmsy = mToken:cUser
                svDev.Dtmsy = today
                svDev.Hemsy = mtime
            .
        end.
    end.
end procedure.

procedure deleteDetailIntervention private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer as handle  no-undo.

    define buffer inter for inter.
    define buffer svdev for svdev.
    define buffer devis for devis.

blocTransaction:
    do transaction:
blocDetail:
        for each ttDetailsIntervention
           where ttDetailsIntervention.CRUD = 'D'
             and ttDetailsIntervention.iNumeroTraitement = phBuffer::iNumeroDemandeDeDevis
         , first devis no-lock
           where devis.nodev = ttDetailsIntervention.iNumeroTraitement:
           for each inter exclusive-lock
                where inter.noint = ttDetailsIntervention.iNumeroIntervention:
                /*--> Suppression du detail reponse */
                for each svdev exclusive-lock
                    where svdev.nodev = devis.nodev
                      and svdev.NoInt = inter.noint:
                    delete svdev.
                end.
                if not can-find(first dtdev no-lock where dtdev.nodev = devis.nodev and dtdev.noint = inter.noint)
                then delete inter.
            end.
        end.
    end.
end procedure.

procedure createTraitement private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour des traitements pour l'historique
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piActionUtilisateur    as integer no-undo.
    define input parameter piNumeroDemandeDeDevis as integer no-undo.
    define input parameter phBuffer               as handle  no-undo.

    define variable viNumeroTraitement as integer   no-undo.

    define buffer trint for trint.
    define buffer svdev for svdev.
    define buffer inter for inter.
    define buffer dtdev for dtdev.

    /*--> Creation du traitement */
    for each svdev no-lock
       where svDev.nodev = piNumeroDemandeDeDevis
     , first inter no-lock
       where inter.NoInt = svDev.NoInt:
        /*--> Recherche prochaine n° traitement sur l'intervention */
        find last trint no-lock
            where /*trint.notrt = svdev.nodev
              and */ trint.noint = inter.noint no-error.
        viNumeroTraitement = if available trint then trint.noidt + 1 else 1.
        create TrInt.
        assign
            TrInt.NoRef = integer(if phBuffer::cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
            TrInt.NoInt = inter.NoInt
            Trint.noIdt = viNumeroTraitement
            TrInt.TpTrt = {&TYPEINTERVENTION-reponseDevis}
            TrInt.NoTrt = piNumeroDemandeDeDevis
            TrInt.CdSta = svDev.CdSta
            TrInt.RgTrt = {&RANGIMPORTANCE-reponse}
            TrInt.lbCom = outilTraduction:getLibelle(piActionUtilisateur)
            TrInt.cdcsy = mToken:cUser
            TrInt.DtCsy = today
            TrInt.HeCsy = mtime
        .
        /* Positionner la demande de devis à répondu */
        for each trint exclusive-lock
           where trint.noint = inter.noint
              and trint.notrt = piNumeroDemandeDeDevis
              and trint.tptrt = {&TYPEINTERVENTION-demande2devis}:
            assign
                trint.cdsta = {&STATUTINTERVENTION-repondu}
                trint.cdmsy = mToken:cUser
                trint.dtmsy = today
                trint.hemsy = mtime
            .
        end.
        /*--> Mise à jour du detail devis */
        for first dtdev exclusive-lock
            where dtdev.noint = inter.noint
              and dtdev.nodev = piNumeroDemandeDeDevis:
            assign
                dtdev.cdsta = {&STATUTINTERVENTION-repondu}
                dtdev.cdmsy = mToken:cUser
                dtdev.dtmsy = today
                dtdev.hemsy = mtime
            .
        end.
    end.
end procedure.

procedure getReponseFournisseur:
    /*------------------------------------------------------------------------------
    Purpose: Récupération d'une réponse devis (réponse fournisseur)
    Notes  : service pour beReponseFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttReponseFournisseur.
    define output parameter table for ttDetailsIntervention.

    define variable vcTypeMandat           as character no-undo.
    define variable viNumeroMandat         as int64     no-undo.
    define variable viNumeroDemandeDeDevis as int64     no-undo.
    define variable vhFournisseur          as handle    no-undo.
    define variable vhTiers                as handle    no-undo.
    define variable vhTva                  as handle    no-undo.
    define variable vcLibelleFour          as character no-undo.
    define variable vlVote                 as logical   no-undo.
    define variable vdeMontantReponse      as decimal   no-undo.

    define buffer intnt for intnt.
    define buffer trint for trint.
    define buffer tarif for tarif.
    define buffer artic for artic.
    define buffer imble for imble.
    define buffer ctrat for ctrat.
    define buffer devis for devis.
    define buffer svdev for svdev.
    define buffer inter for inter.
    define buffer dtdev for dtdev.
    define buffer tutil for tutil.

    assign
        vcTypeMandat           = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat         = poCollection:getInt64("iNumeroMandat")
        viNumeroDemandeDeDevis = poCollection:getInt64("iNumeroTraitement")
    .
    find first devis no-lock where devis.nodev = viNumeroDemandeDeDevis no-error.
    if not available devis then return.

    run tiers/fournisseur.p persistent set vhFournisseur.
    run getTokenInstance in vhFournisseur (mToken:JSessionId).
    run tiers/tiers.p       persistent set vhTiers.
    run getTokenInstance in vhTiers (mToken:JSessionId).
    run compta/outilsTVA.p  persistent set vhTva.
    run getTokenInstance in vhTva (mToken:JSessionId).
    /* Recherche de l'immeuble */
    for first intnt no-lock
        where intnt.tpcon = vcTypeMandat
          and intnt.nocon = viNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt
      , first ctrat no-lock
        where ctrat.tpcon = vcTypeMandat
          and ctrat.nocon = viNumeroMandat:

        /* Recherche de l'utilisateur ayant créé la demande de devis */
        find first tutil no-lock where tutil.ident_u = devis.cdcsy no-error.
        create ttReponseFournisseur.
        assign
            vcLibelleFour                              = dynamic-function('getLibelleFour' in vhFournisseur, vcTypeMandat, devis.nofou)
            ttReponseFournisseur.CRUD                  = 'R'
            ttReponseFournisseur.iNumeroMandat         = viNumeroMandat
            ttReponseFournisseur.cTypeMandat           = vcTypeMandat
            ttReponseFournisseur.cCodeTraitement       = {&TYPEINTERVENTION-reponseDevis}
            ttReponseFournisseur.cLibelleMandat        = ctrat.lbnom
            ttReponseFournisseur.iNumeroDemandeDeDevis = viNumeroDemandeDeDevis
            ttReponseFournisseur.iNumeroImmeuble       = intnt.noidt
            ttReponseFournisseur.cLibelleImmeuble      = imble.lbnom
            ttReponseFournisseur.cCodeFournisseur      = string(devis.nofou)
            ttReponseFournisseur.cLibelleFournisseur   = vcLibelleFour
            ttReponseFournisseur.cCodeMode             = devis.MdSig
            ttReponseFournisseur.cCodeFacturableA      = devis.tpidt-fac
            ttReponseFournisseur.cCodeTheme            = devis.LbDiv1
            ttReponseFournisseur.lCloture              = estCloture(devis.nodev)
            ttReponseFournisseur.dtTimestampDevis      = datetime(devis.dtmsy, devis.hemsy)
            ttReponseFournisseur.cSysUser              = if available tutil then tutil.ident_u else ""
            ttReponseFournisseur.daSysDateCreate       = Devis.dtcsy
            ttReponseFournisseur.rRowid                = rowid(Devis)
        .
        /* Reprendre la réponse fournisseur */
        if can-find(first svdev no-lock where svdev.nodev = viNumeroDemandeDeDevis)
        then for each svdev no-lock
            where svdev.nodev = viNumeroDemandeDeDevis
          , first inter no-lock
            where inter.noint = SvDev.NoInt:
            create ttDetailsIntervention.
            assign
                ttDetailsIntervention.CRUD                  = 'R'
                ttDetailsIntervention.iNumeroIntervention   = inter.noint
                ttDetailsIntervention.iNumeroTraitement     = SvDev.nodev
                ttDetailsIntervention.cCodeArticle          = inter.cdart
                ttDetailsIntervention.cLibelleIntervention  = svdev.lbint
                ttDetailsIntervention.dQuantite             = svdev.qtint
                ttDetailsIntervention.dPrixUnitaire         = svdev.pxuni
                ttDetailsIntervention.dTauxRemise           = svdev.txrem
                ttDetailsIntervention.iNombreJours          = svdev.NbJou
                ttDetailsIntervention.cCodeStatut           = svdev.cdsta
                ttDetailsIntervention.iCodeTVA              = svdev.CdTva
                ttDetailsIntervention.dTauxTVA              = dynamic-function("getTauxTva" in vhTva, svdev.CdTva)
                ttDetailsIntervention.dMontantHT            = svdev.MtInt
                ttDetailsIntervention.dMontantTTC           = svdev.MtInt * (1 + ttDetailsIntervention.dTauxTVA / 100)
                ttDetailsIntervention.cCommentaire          = svdev.lbcom
                ttDetailsIntervention.cCodeCle              = svdev.cdcle
                ttDetailsIntervention.cLibelleStatut        = outilTraduction:getLibelleParam("STTRV", svdev.cdsta)
                ttDetailsIntervention.daFinPrevue           = SvDev.DtCsy + SvDev.NbJou
                ttDetailsIntervention.dtTimestampInter      = datetime(inter.dtmsy, inter.hemsy)
                ttDetailsIntervention.dtTimestampSvdev      = datetime(svdev.dtmsy, svdev.hemsy)
                ttDetailsIntervention.rRowidSvDev           = rowid(svdev)
                ttDetailsIntervention.rRowidInter           = rowid(inter)
                vlVote                                      = svdev.fgvot
                vdeMontantReponse                           = vdeMontantReponse + svdev.mtint
                ttReponseFournisseur.iNumeroSignalant       = if ttReponseFournisseur.iNumeroSignalant > 0 then ttReponseFournisseur.iNumeroSignalant else inter.nopar
                ttReponseFournisseur.cCodeRoleSignalant     = if ttReponseFournisseur.cCodeRoleSignalant > "" then ttReponseFournisseur.cCodeRoleSignalant else inter.tppar
                ttReponseFournisseur.cLibelleSignalant      = if ttReponseFournisseur.cLibelleSignalant   > "" then ttReponseFournisseur.cLibelleSignalant 
                                                              else if inter.tppar = "FOU" then outilFormatage:getNomFour("F", inter.nopar, inter.tpcon)
                                                              else outilFormatage:getNomTiers(inter.tppar, inter.nopar)
                ttReponseFournisseur.iNumeroGestionnaire    = if ttReponseFournisseur.iNumeroGestionnaire > 0 then ttReponseFournisseur.iNumeroGestionnaire else inter.nores
                ttReponseFournisseur.iNumeroIntervention    = if ttReponseFournisseur.iNumeroIntervention > 0 then ttReponseFournisseur.iNumeroIntervention else inter.noint
                ttReponseFournisseur.cReferenceDevisFournisseur = if ttReponseFournisseur.cReferenceDevisFournisseur > "" then ttReponseFournisseur.cReferenceDevisFournisseur else devis.noreg
            .
            if vlVote and (ttReponseFournisseur.cTypeVote = "" or ttReponseFournisseur.cTypeVote = ?)
            then do:
                find last trint no-lock
                    where trint.noint = svdev.noint
                      and trint.tptrt = {&TYPEINTERVENTION-reponseDevis}
                      and trint.notrt = svdev.nodev no-error.
                ttReponseFournisseur.cTypeVote = if available trint then trint.cdsta else "?".
            end.
            else ttReponseFournisseur.cTypeVote = "?".
        end.
        /*--> La reponse n'a pas encore été saisie : récuperation du detail du devis */
        else for each dtdev no-lock
            where dtdev.nodev = viNumeroDemandeDeDevis
          , first inter no-lock
            where inter.noint = DtDev.NoInt:
            find first artic no-lock where artic.cdart = inter.cdart no-error.
            create ttDetailsIntervention.
            assign
                ttDetailsIntervention.CRUD                  = 'U' // inter existe déjà mais pas svdev. svdev sera créé en validation de la réponse fournisseur
                ttDetailsIntervention.iNumeroIntervention   = inter.noint
                ttDetailsIntervention.iNumeroTraitement     = dtdev.nodev
                ttDetailsIntervention.cCodeArticle          = inter.cdart
                ttDetailsIntervention.cLibelleIntervention  = dtdev.lbint
                ttDetailsIntervention.dQuantite             = dtdev.qtint
                ttDetailsIntervention.cCodeStatut           = dtdev.cdsta
                ttDetailsIntervention.iCodeTVA              = artic.CdTva when available artic
                ttDetailsIntervention.dTauxTVA              = dynamic-function("getTauxTva" in vhTva, artic.CdTva) when available artic
                ttDetailsIntervention.cCommentaire          = dtdev.lbcom
                ttDetailsIntervention.cCodeCle              = dtdev.cdcle
                ttDetailsIntervention.cLibelleStatut        = outilTraduction:getLibelleParam("STTRV", dtdev.cdsta)
                ttDetailsIntervention.dtTimestampInter      = datetime(inter.dtmsy, inter.hemsy)
                ttDetailsIntervention.dtTimestampdtdev      = datetime(dtdev.dtmsy, dtdev.hemsy)
                ttDetailsIntervention.rRowidInter           = rowid (inter)
                ttDetailsIntervention.rRowiddtDev           = rowid (dtdev)
                ttReponseFournisseur.iNumeroSignalant       = if ttReponseFournisseur.iNumeroSignalant > 0 then ttReponseFournisseur.iNumeroSignalant else inter.nopar
                ttReponseFournisseur.cCodeRoleSignalant     = if ttReponseFournisseur.cCodeRoleSignalant > "" then ttReponseFournisseur.cCodeRoleSignalant else inter.tppar
                ttReponseFournisseur.cLibelleSignalant      = if ttReponseFournisseur.cLibelleSignalant   > "" then ttReponseFournisseur.cLibelleSignalant 
                                                              else if inter.tppar = "FOU" then outilFormatage:getNomFour("F", inter.nopar, inter.tpcon)
                                                              else outilFormatage:getNomTiers(inter.tppar, inter.nopar)
                ttReponseFournisseur.iNumeroGestionnaire    = if ttReponseFournisseur.iNumeroGestionnaire > 0 then ttReponseFournisseur.iNumeroGestionnaire else inter.nores
                ttReponseFournisseur.iNumeroIntervention    = if ttReponseFournisseur.iNumeroIntervention > 0 then ttReponseFournisseur.iNumeroIntervention else inter.noint
            .
            /*--> Recherche du prix sur l'immeuble */
            find first tarif no-lock
                 where tarif.cdart = inter.cdart
                   and tarif.nofou = devis.nofou
                   and tarif.noimm = imble.noimm no-error.
            /*--> Sinon celui du fournisseur */
            if not available tarif
            then find first tarif no-lock
                where tarif.cdart = inter.cdart
                  and tarif.nofou = devis.nofou
                  and tarif.noimm = 0 no-error.
            if available tarif
            then assign
                 ttDetailsIntervention.dPrixUnitaire = tarif.pxuni
                 ttDetailsIntervention.dTauxRemise   = tarif.txrem
                 ttDetailsIntervention.dMontantHT    = ttDetailsIntervention.dQuantite * tarif.pxuni
                 ttDetailsIntervention.dMontantHT    = ttDetailsIntervention.dMontantHT - (ttDetailsIntervention.dMontantHT * tarif.txrem / 100)
                 ttDetailsIntervention.dMontantTTC   = ttDetailsIntervention.dMontantHT * (1 + ttDetailsIntervention.dTauxTVA / 100)
            .
        end.
    end.
    run destroy in vhFournisseur.
    run destroy in vhTiers.
    run destroy in vhTva.

end procedure.

procedure getReponseFournisseurRowId:
    /*------------------------------------------------------------------------------
    Purpose: Récupération d'une réponse devis (réponse fournisseur)
    Notes  : service pour beReponseFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input  parameter prRowid as rowid no-undo.
    define output parameter table for ttReponseFournisseur.
    define output parameter table for ttDetailsIntervention.

    define variable vhFournisseur     as handle    no-undo.
    define variable vhTiers           as handle    no-undo.
    define variable vhTva             as handle    no-undo.
    define variable vcLibelleFour     as character no-undo.
    define variable vlVote            as logical   no-undo.
    define variable vdeMontantReponse as decimal   no-undo.

    define buffer intnt   for intnt.
    define buffer trint   for trint.
    define buffer imble   for imble.
    define buffer ctrat   for ctrat.
    define buffer devis   for devis.
    define buffer svdev   for svdev.
    define buffer vbSvdev for svdev.
    define buffer inter   for inter.
    define buffer vbInter for inter.
    define buffer tutil   for tutil.

    run tiers/fournisseur.p persistent set vhFournisseur.
    run getTokenInstance in vhFournisseur (mToken:JSessionId).
    run tiers/tiers.p persistent set vhTiers.
    run getTokenInstance in vhTiers (mToken:JSessionId).
    run compta/outilsTVA.p persistent set vhTva.
    run getTokenInstance in vhTva (mToken:JSessionId).

    for first devis no-lock where rowid(devis) = prRowid
      , first svdev no-lock
        where svdev.nodev = devis.nodev
      , first inter no-lock
        where inter.noint = svdev.noint
      , first intnt no-lock
        where intnt.tpcon = inter.tpcon
          and intnt.nocon = inter.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , first imble no-lock
        where imble.noimm = intnt.noidt
      , first ctrat no-lock
        where ctrat.tpcon = inter.tpcon
          and ctrat.nocon = inter.nocon:

        /* Recherche de l'utilisateur ayant créé la demande de devis */
        find first tutil no-lock where tutil.ident_u = devis.CdCsy no-error.
        create ttReponseFournisseur.
        assign
            vcLibelleFour                               = dynamic-function('getLibelleFour' in vhFournisseur, inter.tpcon,devis.nofou)
            ttReponseFournisseur.CRUD                  = 'R'
            ttReponseFournisseur.iNumeroMandat         = inter.nocon
            ttReponseFournisseur.cTypeMandat           = inter.tpcon
            ttReponseFournisseur.cCodeTraitement       = {&TYPEINTERVENTION-reponseDevis}
            ttReponseFournisseur.cLibelleMandat        = ctrat.lbnom
            ttReponseFournisseur.iNumeroDemandeDeDevis = devis.nodev
            ttReponseFournisseur.iNumeroImmeuble       = intnt.noidt
            ttReponseFournisseur.cLibelleImmeuble      = imble.lbnom
            ttReponseFournisseur.cCodeFournisseur      = string(devis.nofou)
            ttReponseFournisseur.cLibelleFournisseur   = vcLibelleFour
            ttReponseFournisseur.cCodeMode             = devis.MdSig
            ttReponseFournisseur.cCodeFacturableA      = devis.tpidt-fac
            ttReponseFournisseur.cCodeTheme            = devis.LbDiv1
            ttReponseFournisseur.lCloture              = estCloture(devis.nodev)
            ttReponseFournisseur.dtTimestampDevis      = datetime(devis.dtmsy, devis.hemsy)
            ttReponseFournisseur.cSysUser              = if available tutil then tutil.ident_u else ""
            ttReponseFournisseur.daSysDateCreate       = devis.dtcsy
            ttReponseFournisseur.cReferenceDevisFournisseur = devis.noreg
            ttReponseFournisseur.rRowid                = rowid(Devis)
        .
        for each vbSvdev no-lock
            where vbSvdev.nodev = Devis.nodev
          , first vbInter no-lock
            where vbInter.noint = vbSvdev.NoInt:
            create ttDetailsIntervention.
            assign
                ttDetailsIntervention.CRUD                 = 'R'
                ttDetailsIntervention.iNumeroIntervention  = vbInter.noint
                ttDetailsIntervention.iNumeroTraitement    = vbSvdev.nodev
                ttDetailsIntervention.cCodeArticle         = vbInter.cdart
                ttDetailsIntervention.cLibelleIntervention = vbSvdev.lbint
                ttDetailsIntervention.dQuantite            = vbSvdev.qtint
                ttDetailsIntervention.dPrixUnitaire        = vbSvdev.pxuni
                ttDetailsIntervention.dTauxRemise          = vbSvdev.txrem
                ttDetailsIntervention.iCodeTVA             = vbSvdev.CdTva
                ttDetailsIntervention.dTauxTVA             = dynamic-function("getTauxTva" in vhTva, ttDetailsIntervention.iCodeTVA)
                ttDetailsIntervention.dMontantHT           = vbSvdev.MtInt
                ttDetailsIntervention.dMontantTTC          = vbSvdev.MtInt * (1 + (ttDetailsIntervention.dTauxTVA / 100))
                ttDetailsIntervention.iNombreJours         = vbSvdev.NbJou
                ttDetailsIntervention.cCodeStatut          = vbSvdev.cdsta
                ttDetailsIntervention.cCommentaire         = vbSvdev.lbcom
                ttDetailsIntervention.cCodeCle             = vbSvdev.cdcle
                ttDetailsIntervention.cLibelleStatut       = outilTraduction:getLibelleParam("STTRV", svdev.cdsta)
                ttDetailsIntervention.daFinPrevue          = vbSvdev.DtCsy + svdev.NbJou
                ttDetailsIntervention.dtTimestampInter     = datetime(vbInter.dtmsy, vbInter.hemsy)
                ttDetailsIntervention.dtTimestampSvdev     = datetime(vbSvdev.dtmsy, vbSvdev.hemsy)
                ttDetailsIntervention.rRowidSvDev          = rowid(vbSvdev)
                ttDetailsIntervention.rRowidInter          = rowid(vbInter)
                ttReponseFournisseur.iNumeroSignalant      = if ttReponseFournisseur.iNumeroSignalant > 0 then ttReponseFournisseur.iNumeroSignalant else inter.nopar
                ttReponseFournisseur.cLibelleSignalant     = if ttReponseFournisseur.cLibelleSignalant   > "" then ttReponseFournisseur.cLibelleSignalant 
                                                             else if vbInter.tppar = "FOU" then outilFormatage:getNomFour("F", vbInter.nopar, vbInter.tpcon)
                                                             else outilFormatage:getNomTiers(vbInter.tppar, vbInter.nopar)
                ttReponseFournisseur.cCodeRoleSignalant    = if ttReponseFournisseur.cCodeRoleSignalant > "" then ttReponseFournisseur.cCodeRoleSignalant else inter.tppar
                ttReponseFournisseur.iNumeroGestionnaire   = if ttReponseFournisseur.iNumeroGestionnaire > 0 then ttReponseFournisseur.iNumeroGestionnaire else inter.nores
                ttReponseFournisseur.iNumeroIntervention   = if ttReponseFournisseur.iNumeroIntervention > 0 then ttReponseFournisseur.iNumeroIntervention else inter.noint
                ttReponseFournisseur.cTypeVote             = "?"
                vlVote                                     = vbSvdev.fgvot
                vdeMontantReponse                          = vdeMontantReponse + vbSvdev.mtint
            .
            if vlVote and (ttReponseFournisseur.cTypeVote = "" or ttReponseFournisseur.cTypeVote = ?)
            then for last trint no-lock
                where trint.noint = svdev.noint
                  and trint.tptrt = {&TYPEINTERVENTION-reponseDevis}
                  and trint.notrt = svdev.nodev:
                ttReponseFournisseur.cTypeVote = trint.cdsta.
            end.
        end.
    end.
    run destroy in vhFournisseur.
    run destroy in vhTiers.
    run destroy in vhTva.

end procedure.

function controleVoteAG returns logical private (pcTypeVote as character, piCollaborateur as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viTypeVote as integer no-undo.
    define variable voChaineTravaux as class parametrageChaineTravaux no-undo.

    define buffer prmtv for prmtv.

    case pcTypeVote:
//        when {&STATUTINTERVENTION-vote}     then viTypeVote = 0. JAMAIS UTILISE
        when {&STATUTINTERVENTION-voteCS}   then viTypeVote = 1.
        when {&STATUTINTERVENTION-voteAG}   then viTypeVote = 2.
        when {&STATUTINTERVENTION-VoteProp} then viTypeVote = 3.
        when {&STATUTINTERVENTION-voteResp} then viTypeVote = 4.
    end case.

    /*--> Gestion des délégation */
    voChaineTravaux = new parametrageChaineTravaux().
    if voChaineTravaux:isGestionDelegation()
    then do:
        find first prmtv no-lock
             where prmtv.tppar = "HABIL"
               and prmtv.noord = piCollaborateur no-error.
        if not available prmtv
        or (num-entries(prmtv.lbpar, "|") >= viTypeVote and entry(viTypeVote, prmtv.lbpar, "|") = "NO")
        then do:
            mError:createError({&Error}, 211685). // "Vous n'avez pas les droits, vous permettant de voter cette réponse de devis"
            delete object voChaineTravaux.
            return false.
        end.
    end.
    delete object voChaineTravaux.
    return true.

end function.

procedure voteAG:
    /*------------------------------------------------------------------------------
    Purpose: Passer une réponse fournisseur au statut Votée
    Notes: service utilisé par beRepnseFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttReponseFournisseur.
    define input parameter table for ttError.

    define variable viNumeroTraitement as integer no-undo.

    define buffer svdev   for svdev.
    define buffer vbSvdev for svdev.
    define buffer trint   for trint.
    define buffer inter   for inter.

    for each ttReponseFournisseur:
        if controleVoteAG(ttReponseFournisseur.cTypeVote, mtoken:iCollaborateur)
        then do:
            /*--> On regarde si un autre devis est déjà voté */
            for each svdev no-lock
	            where svdev.nodev = ttReponseFournisseur.iNumeroDemandeDeDevis
              , each vbSvdev exclusive-lock
	            where vbSvdev.nodev <> ttReponseFournisseur.iNumeroDemandeDeDevis
                  and vbSvdev.noint = svdev.noint
                  and vbSvdev.fgvot = true:
                if outils:questionnaire(211686, table ttError by-reference) <= 2   // pas répondu oui à la question: Attention un autre devis a été voté par l'assemblé générale. Confirmez-vous votre choix ?
                then return.
                /*--> Modification flag et statut */
                assign
                    vbSvdev.fgvot = false
                    vbSvdev.cdsta = {&STATUTINTERVENTION-enCours}
                .
                /*--> Recherche prochaine n° traitement sur l'intervention */
                find last trint no-lock
                    where trint.noint = vbSvdev.noint no-error.
                viNumeroTraitement = if available trint then trint.noidt + 1 else 1.
                create TrInt.
                assign
                    trint.noRef = integer(if ttReponseFournisseur.cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                    TrInt.NoInt = vbSvdev.NoInt
                    Trint.NoIdt = viNumeroTraitement
                    TrInt.TpTrt = {&TYPEINTERVENTION-reponseDevis}
                    TrInt.NoTrt = vbSvdev.nodev
                    TrInt.CdSta = vbSvdev.CdSta
                    TrInt.RgTrt = {&RANGIMPORTANCE-reponse}
                    TrInt.cdcsy = mtoken:cUser
                    TrInt.DtCsy = today
                    TrInt.HeCsy = mtime
                    TrInt.LbCom = outilTraduction:getLibelle(107775)
                .
            end.
            /*--> Si reponse positive ou si pas d'autre devis voté */
            for each svdev exclusive-lock
	            where svdev.nodev = ttReponseFournisseur.iNumeroDemandeDeDevis
              , first inter no-lock
                where inter.noint = svdev.noint:
                /*--> Modification flag et statut */
                assign
                    svdev.fgvot = true
                    svdev.cdsta = ttReponseFournisseur.cTypeVote
                .
                /*--> Recherche prochaine n° traitement sur l'intervention */
                find last trint no-lock
                    where trint.noint = svdev.noint no-error.
                viNumeroTraitement = if available trint then trint.noidt + 1 else 1.
                create TrInt.
                assign
                    TrInt.NoRef = integer(if ttReponseFournisseur.cTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
                    TrInt.NoInt = svdev.NoInt
                    Trint.NoIdt = viNumeroTraitement
                    TrInt.TpTrt = {&TYPEINTERVENTION-reponseDevis}
                    TrInt.NoTrt = svdev.nodev
                    TrInt.CdSta = SvDev.CdSta
                    TrInt.RgTrt = {&RANGIMPORTANCE-reponse}
                    TrInt.cdcsy = mtoken:cUser
                    TrInt.DtCsy = today
                    TrInt.HeCsy = mtime
                    TrInt.LbCom = outilTraduction:getLibelle(107775)
                .
            end.
        end.
    end.
end procedure.
