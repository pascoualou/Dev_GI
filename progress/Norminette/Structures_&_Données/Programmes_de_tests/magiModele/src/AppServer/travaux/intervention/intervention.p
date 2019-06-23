/*------------------------------------------------------------------------
File        : intervention.p
Purpose     :
Author(s)   : kantena - 2016/02/09
Notes       :
Tables      : BASE sadb: intnt trInt Dtfac factu Dtord OrdSe dtlot signa
                         ctctt devis prmtv TrDos ctrat DtDev SvDev inter adres
----------------------------------------------------------------------*/
&SCOPED-DEFINE MAXRETURNEDROWS  500
{preprocesseur/type2intervention.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/statut2intervention.i}

using parametre.pclie.parametrageCarnetEntretien.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{Travaux/include/intervention.i}

define variable ghFournisseur as handle  no-undo. // handle de procédure
define variable giNombreLigne as integer no-undo.

// Stockage du montant total de traitement. Evite de refaire un calcul à chaque intervention lue.
define temp-table ttMontantTraitement no-undo
    field cCodeTraitement   as character
    field iNumeroTraitement as integer
    field dMontantTTC       as decimal
index idxTraitement is unique primary cCodeTraitement iNumeroTraitement.

function calculMontantTraitementTTC returns decimal private (pcCodeTraitement as character, piNumeroTraitement as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne le montant TTC du traitement concerné.
    Notes  : provient de la temp table si déjà calculé.
    ------------------------------------------------------------------------------*/
    define variable vdMontantTTC as decimal no-undo.
    define variable vhTva        as handle  no-undo.
    define buffer dtOrd for dtOrd.
    define buffer svDev for svDev.

    find first ttMontantTraitement 
         where ttMontantTraitement.cCodeTraitement   = pcCodeTraitement
           and ttMontantTraitement.iNumeroTraitement = piNumeroTraitement no-error.
    if not available ttMontantTraitement then do:
        run compta/outilsTVA.p persistent set vhTva.
        run getTokenInstance in vhTva(mToken:JSessionId).
        create ttMontantTraitement.
        assign 
            ttMontantTraitement.cCodeTraitement   = pcCodeTraitement
            ttMontantTraitement.iNumeroTraitement = piNumeroTraitement
        .
        case pcCodeTraitement:
            when {&TYPEINTERVENTION-reponseDevis} then for each svdev no-lock where svdev.nodev = piNumeroTraitement:
                 vdMontantTTC = vdMontantTTC + dynamic-function("calculTTCdepuisHT" in vhTva, svDev.cdtva, svDev.mtint).
            end.
            when {&TYPEINTERVENTION-ordre2service} then for each dtord no-lock where dtOrd.noord = piNumeroTraitement:
                vdMontantTTC = vdMontantTTC + dynamic-function("calculTTCdepuisHT" in vhTva, dtOrd.cdtva, dtOrd.mtint).
            end.
        end case.
        ttMontantTraitement.dMontantTTC = vdMontantTTC.
        run destroy in vhTva.
    end.    
    return ttMontantTraitement.dMontantTTC.

end function.

function existeEtapeSuivante returns logical private (pcCodeTraitement as character, piNumeroIntervention as int64):
    /*------------------------------------------------------------------------------
    Purpose: Indique si il existe un traitement suivant dans le workflow
    Notes:
    ------------------------------------------------------------------------------*/
    return can-find(first trint no-lock 
                    where trint.noint = piNumeroIntervention
                      and trint.tptrt > pcCodeTraitement).

end function.

function controleSuppressionIntervention returns logical private (piNumeroIntervention as int64):
    /*------------------------------------------------------------------------------
    Purpose: vérifie les condition de suppression d'une intervention
    Notes  :     0: OK
            107738: existence d'un detail devis sur au moins une intervention
            107739: existence d'un suivi devis sur au moins une intervention
            107740: existence d'un ordre de service sur au moins une intervention
            107741: existence d'une facture sur au moins une intervention
    ------------------------------------------------------------------------------*/
    define buffer inter for inter.

    for each inter no-lock
       where inter.noint = piNumeroIntervention:
        // Suppression impossible s'il existe un detail devis, un suivi devis, un ordre de service, une facture sur au moins une intervention
        if can-find(first dtdev no-lock where dtdev.noint = inter.noint)
        then do:
            mError:create2Error(104432, 107738).
            return false.
        end.
        if can-find(first svdev no-lock where svdev.noint = inter.noint)
        then do:
            mError:create2Error(104432, 107739).
            return false.
        end.
        if can-find(first dtord no-lock where dtord.noint = inter.noint)
        then do:
            mError:create2Error(104432, 107740).
            return false.
        end.
        if can-find(first dtfac no-lock where dtfac.noint = inter.noint)
        then do:
            mError:create2Error(104432, 107741).
            return false.
        end.
    end.
    return true.

end function.

function creSelection returns logical private
    (buffer pbInter for inter, piNumeroImmeuble as int64, pcCodeTraitement as character, piNumeroTraitement as int64, pcNumeroFournisseur as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer PrmTv for PrmTv.
    define buffer devis for devis.
    define buffer DtDev for DtDev.
    define buffer SvDev for SvDev.
    define buffer OrdSe for OrdSe.
    define buffer DtOrd for DtOrd.
    define buffer factu for factu.
    define buffer DtFac for DtFac.
    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.
    define buffer TrDos for TrDos.

    /*--> Si pas déjà créé */
    if can-find(first ttIntervention
        where ttIntervention.iNumeroIntervention = pbInter.noint
          and ttIntervention.cCodeTraitement     = pcCodeTraitement
          and ttIntervention.iNumeroTraitement   = piNumeroTraitement) then return true.

    /*--> Recherche du parametre de durée */
    find first prmtv no-lock
         where prmtv.tppar = "DLINT"
           and prmtv.cdpar = pbInter.dlint no-error.
    case pcCodeTraitement:
        when {&TYPEINTERVENTION-signalement} then do:
            if pcNumeroFournisseur > '' then return true.

            create ttIntervention.
            assign
                giNombreLigne                       = giNombreLigne + 1
                ttIntervention.CRUD                 = 'R'
                ttIntervention.iNumeroIntervention  = pbInter.noint
                ttIntervention.cCodeTraitement      = pcCodeTraitement
                ttIntervention.iNumeroTraitement    = piNumeroTraitement
                ttIntervention.iNumeroImmeuble      = piNumeroImmeuble
                ttIntervention.cTypeMandat          = pbInter.tpcon
                ttIntervention.iNumeroMandat        = pbInter.nocon
                ttIntervention.daDateCreation       = pbInter.dtcsy
                ttIntervention.daDateRealisation    = pbInter.dtcsy + (if available prmtv then prmtv.nbpar else 0)
                ttIntervention.cLibelleIntervention = pbInter.lbint
                ttIntervention.cCodeStatut          = pbInter.cdsta
                ttIntervention.lFacture             = pbInter.fgfac
                ttIntervention.lBAP                 = false
                ttIntervention.cLibelleTraitement   = substring(outilTraduction:getLibelleProg("O_CLC", pcCodeTraitement), 1, 3, 'character')
                ttIntervention.cLibelleStatut       = outilTraduction:getLibelleParam("STTRV", pbInter.cdsta)
                ttIntervention.dtTimestampInter     = datetime(pbInter.dtmsy, pbInter.hemsy)
            .
            if ttIntervention.cCodeFournisseur > ""  // on ne peut pas faire un when !!! ifournisseur assigné plus haut
            then ttIntervention.cLibelleFournisseur  = dynamic-function('getLibelleFour' in ghFournisseur, ttIntervention.cTypeMandat, ttIntervention.cCodeFournisseur).             
        end.
        when {&TYPEINTERVENTION-demande2devis} then do:
            if pcNumeroFournisseur > ''
            then find first devis no-lock
                where devis.nodev = piNumeroTraitement
                  and devis.nofou = integer(pcNumeroFournisseur) no-error.
            else find first devis no-lock
                where devis.nodev = piNumeroTraitement no-error.
            if not available Devis then return true.

            find first dtdev no-lock
                where dtdev.noint = pbInter.noint
                  and dtdev.nodev = devis.nodev no-error.
            if not available dtDev then return true.

            create ttIntervention.
            assign 
                giNombreLigne                       = giNombreLigne + 1 
                ttIntervention.cCodeFournisseur     = string(devis.nofou)
                ttIntervention.CRUD                 = 'R'
                ttIntervention.iNumeroIntervention  = pbInter.noint
                ttIntervention.cCodeTraitement      = pcCodeTraitement
                ttIntervention.iNumeroTraitement    = piNumeroTraitement
                ttIntervention.iNumeroImmeuble      = piNumeroImmeuble
                ttIntervention.cTypeMandat          = pbInter.tpcon
                ttIntervention.iNumeroMandat        = pbInter.nocon
                ttIntervention.daDateCreation       = dtdev.dtcsy
                ttIntervention.daDateRealisation    = dtdev.dtcsy + (if available prmtv then prmtv.nbpar else 0)
                ttIntervention.cLibelleIntervention = dtdev.lbint
                ttIntervention.cCodeStatut          = dtdev.cdsta
                ttIntervention.lFacture             = pbInter.fgfac
                ttIntervention.lBAP                 = false
                ttIntervention.cLibelleTraitement   = substring(outilTraduction:getLibelleProg("O_CLC", pcCodeTraitement), 1, 3, 'character')
                ttIntervention.cLibelleStatut       = outilTraduction:getLibelleParam("STTRV", dtdev.cdsta)
                ttIntervention.dtTimestampInter     = datetime(pbInter.dtmsy, pbInter.hemsy)
            .
            if ttIntervention.cCodeFournisseur > ""  // on ne peut pas faire un when !!! ifournisseur assigné plus haut
            then ttIntervention.cLibelleFournisseur  = dynamic-function('getLibelleFour' in ghFournisseur, ttIntervention.cTypeMandat, Devis.nofou).
        end.
        when {&TYPEINTERVENTION-reponseDevis} then for first svdev no-lock 
            where svdev.noint = pbInter.noInt
              and svdev.nodev = piNumeroTraitement:

            if pcNumeroFournisseur > ''
            then find first devis no-lock
                where devis.nodev = svdev.nodev
                  and Devis.NoFou = integer(pcNumeroFournisseur) no-error.
            else find first devis no-lock
                where devis.nodev = svdev.nodev no-error.
            if not available devis then return true.

            create ttIntervention.
            assign 
                giNombreLigne                         = giNombreLigne + 1 
                ttIntervention.cCodeFournisseur       = string(devis.nofou)
                ttIntervention.CRUD                   = 'R'
                ttIntervention.iNumeroIntervention    = pbInter.noint
                ttIntervention.cCodeTraitement        = pcCodeTraitement
                ttIntervention.iNumeroTraitement      = piNumeroTraitement
                ttIntervention.iNumeroImmeuble        = piNumeroImmeuble
                ttIntervention.cTypeMandat            = pbInter.tpcon
                ttIntervention.iNumeroMandat          = pbInter.nocon
                ttIntervention.daDateCreation         = svdev.dtcsy
                ttIntervention.daDateRealisation      = svdev.dtcsy + SvDev.NbJou //(if available prmtv then prmtv.nbpar else 0)
                ttIntervention.cLibelleIntervention   = svdev.lbint
                ttIntervention.cCodeStatut            = svdev.cdsta
                ttIntervention.lFacture               = pbInter.fgfac
                ttIntervention.lBAP                   = false
                ttIntervention.cLibelleTraitement     = substring(outilTraduction:getLibelleProg("O_CLC", pcCodeTraitement), 1, 3, 'character')
                ttIntervention.cLibelleStatut         = outilTraduction:getLibelleParam("STTRV", svdev.cdsta)
                ttIntervention.dtTimestampInter       = datetime(pbInter.dtmsy, pbInter.hemsy)
                ttIntervention.dMontantTotalTTC       = calculMontantTraitementTTC(pcCodeTraitement, piNumeroTraitement)
            .
            if ttIntervention.cCodeFournisseur > ""  // on ne peut pas faire un when !!! ifournisseur assigné plus haut
            then ttIntervention.cLibelleFournisseur = dynamic-function('getLibelleFour' in ghFournisseur, ttIntervention.cTypeMandat, devis.nofou).
        end.
        when {&TYPEINTERVENTION-Ordre2Service} then do:
            if pcNumeroFournisseur > ''
            then find first ordse no-lock
                where ordse.noOrd = piNumeroTraitement
                  and ordse.noFou = integer(pcNumeroFournisseur) no-error.
            else find first ordse no-lock
                where ordse.noOrd = piNumeroTraitement no-error.
            if not available ordse then return true.

            find first dtord no-lock
                where dtord.noOrd = piNumeroTraitement
                  and dtord.noint = pbInter.noint no-error.
            if not available dtord then return true.

            create ttIntervention.
            assign 
                giNombreLigne                         = giNombreLigne + 1 
                ttIntervention.cCodeFournisseur       = string(ordse.nofou)
                ttIntervention.CRUD                   = 'R'
                ttIntervention.iNumeroIntervention    = pbInter.noint
                ttIntervention.cCodeTraitement        = pcCodeTraitement
                ttIntervention.iNumeroTraitement      = piNumeroTraitement
                ttIntervention.iNumeroImmeuble        = piNumeroImmeuble
                ttIntervention.cTypeMandat            = pbInter.tpcon
                ttIntervention.iNumeroMandat          = pbInter.nocon
                ttIntervention.daDateCreation         = dtord.dtcsy
                ttIntervention.daDateRealisation      = DtOrd.DtFin //dtord.dtcsy + (if available prmtv then prmtv.nbpar else 0) cas ordre de service on prends dtfin
                ttIntervention.cLibelleIntervention   = dtord.lbint
                ttIntervention.cCodeStatut            = dtord.cdsta
                ttIntervention.lFacture               = pbInter.fgfac
                ttIntervention.lBAP                   = ordse.fgbap
                ttIntervention.cLibelleTraitement     = substring(outilTraduction:getLibelleProg("O_CLC", pcCodeTraitement), 1, 3, 'character')
                ttIntervention.cLibelleStatut         = outilTraduction:getLibelleParam("STTRV", dtord.cdsta)
                ttIntervention.dtTimestampInter       = datetime(pbInter.dtmsy, pbInter.hemsy)
                ttIntervention.dMontantTotalTTC       = calculMontantTraitementTTC(pcCodeTraitement, piNumeroTraitement)
            .
            if ttIntervention.cCodeFournisseur > ""  // on ne peut pas faire un when !!! ifournisseur assigné plus haut
            then ttIntervention.cLibelleFournisseur = dynamic-function('getLibelleFour' in ghFournisseur, ttIntervention.cTypeMandat, ordse.nofou).
        end.
        when {&TYPEINTERVENTION-facture} then do:
            if pcNumeroFournisseur > ''
            then find first factu no-lock
                where factu.nofac = piNumeroTraitement
                  and Factu.NoFou = integer(pcNumeroFournisseur) no-error.
            else find first factu no-lock
                where factu.nofac = piNumeroTraitement no-error.
            if not available factu then return true.

            find first dtFac no-lock
                 where dtfac.noint = pbInter.noint
                   and dtfac.nofac = piNumeroTraitement no-error.
            if not available dtfac then return true.

            create ttIntervention.
            assign
                giNombreLigne                         = giNombreLigne + 1
                ttIntervention.CRUD                   = 'R'
                ttIntervention.cCodeFournisseur       = string(factu.nofou)
                ttIntervention.dMontantfactureHT      = factu.mtttc - factu.mttva
                ttIntervention.dMontantfactureTTC     = factu.MtTtc
                ttIntervention.dMontantTotalTTC       = factu.MtTtc
                ttIntervention.iNumeroIntervention    = pbInter.noint
                ttIntervention.cCodeTraitement        = pcCodeTraitement
                ttIntervention.iNumeroTraitement      = piNumeroTraitement
                ttIntervention.iNumeroImmeuble        = piNumeroImmeuble
                ttIntervention.cTypeMandat            = pbInter.tpcon
                ttIntervention.iNumeroMandat          = pbInter.nocon
                ttIntervention.daDateCreation         = dtfac.dtcsy
            // ttIntervention.daDateRealisation    = dtfac.dtcsy + (if available prmtv then prmtv.nbpar else 0) a ne pas renseigner dans le cas fac
                ttIntervention.cLibelleIntervention   = dtfac.lbint
                ttIntervention.cCodeStatut            = dtfac.cdsta
                ttIntervention.lFacture               = pbInter.fgfac
                ttIntervention.lBAP                   = factu.fgbap
                ttIntervention.cLibelleTraitement     = substring(outilTraduction:getLibelleProg("O_CLC", pcCodeTraitement), 1, 3, 'character')
                ttIntervention.cLibelleStatut         = outilTraduction:getLibelleParam("STTRV", dtfac.cdsta)
                ttIntervention.dtTimestampInter       = datetime(pbInter.dtmsy, pbInter.hemsy)
           .
           if ttIntervention.cCodeFournisseur > ""  // on ne peut pas faire un when !!! ifournisseur assigné plus haut
           then ttIntervention.cLibelleFournisseur = dynamic-function('getLibelleFour' in ghFournisseur, ttIntervention.cTypeMandat, factu.nofou).
       end.
       otherwise return true.

    end case.
    /* Service de gestion */
    if available ttIntervention then do:
        for first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = ttIntervention.cTypeMandat
              and ctctt.noct2 = ttIntervention.iNumeroMandat
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct1
              and ctrat.nocon = ctctt.noct1:
            assign
                ttIntervention.iNumeroServGestion  = ctrat.nocon
                ttIntervention.cLibelleServGestion = outilFormatage:getNomTiers(ctrat.tprol, ctrat.norol)
            .
        end.
        /* Adresse immeuble lié au mandat */
        ttIntervention.cAdresseImmeuble = outilFormatage:formatageAdresse({&TYPEBIEN-immeuble}, piNumeroImmeuble).
        for first trdos no-lock
            where trdos.tpcon = ttIntervention.cTypeMandat 
              and trdos.nocon = ttIntervention.iNumeroMandat 
              and trdos.nodos = pbInter.nodos:
            assign
                ttIntervention.iNumeroDosTravaux  = trdos.nodos
                ttIntervention.cLibelleDosTravaux = trdos.Lbdos
            .
        end.
    end.
    if giNombreLigne >= {&MAXRETURNEDROWS}
    then do:
        mError:createError({&warning}, 211668, "{&MAXRETURNEDROWS}").  // nombre maxi d'enregistrement atteint
        return false.
    end.
    return true.

end function.

function creSelectionListe returns logical private (buffer pbInter for inter, pcCodeTraitement as character, piNumeroTraitement as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer devis for devis.
    define buffer dtdev for dtdev.
    define buffer svdev for svdev.
    define buffer ordse for ordse.
    define buffer dtord for dtord.
    define buffer factu for factu.
    define buffer dtfac for dtfac.

    /*--> Si pas déjà créé */
    if can-find(first ttListeIntervention
        where ttListeIntervention.iNumeroIntervention = pbInter.noint
          and ttListeIntervention.cCodeTraitement     = pcCodeTraitement
          and ttListeIntervention.iNumeroTraitement   = piNumeroTraitement) then return false.

    create ttListeIntervention.
    assign
        ttListeIntervention.CRUD                = 'R'
        ttListeIntervention.cCodeTraitement     = pcCodeTraitement
        ttListeIntervention.iNumeroTraitement   = piNumeroTraitement
        ttListeIntervention.iNumeroIntervention = pbInter.noint
        ttListeIntervention.iNumeroDosTravaux   = pbInter.nodos
        ttListeIntervention.cCodeStatut         = pbInter.cdsta
        ttListeIntervention.cLibelleStatus      = outilTraduction:getLibelleParam("STTRV", pbInter.cdsta)
        //ttListeIntervention.FgFac = pbInter.fgfac
        //ttListeIntervention.CdArt = pbInter.cdart
        ttListeIntervention.cCodeTypeTraitement = substring(outilTraduction:getLibelleProg("O_CLC", pcCodeTraitement), 1, 3, 'character')          
        ttListeIntervention.dtTimestamp         = datetime(pbInter.dtmsy, pbInter.hemsy)
    .
    case pcCodeTraitement:
        when {&TYPEINTERVENTION-signalement} then assign
            ttListeIntervention.daDateCreation       = pbInter.dtcsy
            ttListeIntervention.cLibelleIntervention = pbInter.lbint
        .
        when {&TYPEINTERVENTION-demande2devis} then for first devis no-lock
            where devis.nodev = piNumeroTraitement
          , first dtdev no-lock
            where dtdev.noint = ttListeIntervention.iNumeroIntervention
              and dtdev.nodev = devis.Nodev:
            assign
                ttListeIntervention.daDateCreation       = devis.dtcsy
                ttListeIntervention.cLibelleIntervention = dtdev.lbint
                ttListeIntervention.cCodeFournisseur     = string(devis.nofou)
                ttListeIntervention.cLibelleFournisseur  = dynamic-function('getLibelleFour' in ghFournisseur, pbInter.tpcon, devis.nofou)
            .
        end.
        when {&TYPEINTERVENTION-reponseDevis} then for first devis no-lock
            where devis.nodev = piNumeroTraitement
          , first svdev no-lock
            where svdev.noint = pbInter.NoInt
              and svdev.nodev = devis.Nodev:
            assign
                ttListeIntervention.daDateCreation       = Svdev.dtcsy
                ttListeIntervention.cLibelleIntervention = Svdev.lbint
                ttListeIntervention.cCodeFournisseur     = string(devis.nofou)
                ttListeIntervention.cLibelleFournisseur  = dynamic-function('getLibelleFour' in ghFournisseur, pbInter.tpcon,devis.nofou)
             .
        end.
        when {&TYPEINTERVENTION-ordre2service} then for first ordse no-lock
            where ordse.noord = piNumeroTraitement
          , first dtord no-lock
            where dtord.noint = pbInter.NoInt
              and dtord.noord = ordse.Noord:
            assign
                ttListeIntervention.daDateCreation       = DtOrd.dtcsy
                ttListeIntervention.cLibelleIntervention = DtOrd.lbint
                ttListeIntervention.cCodeFournisseur     = string(ordse.nofou)
                ttListeIntervention.cLibelleFournisseur  = dynamic-function('getLibelleFour' in ghFournisseur, pbInter.tpcon,ordse.nofou)
            .
        end.
        when {&TYPEINTERVENTION-facture} then for first factu no-lock
            where factu.nofac = piNumeroTraitement
          , first dtfac no-lock
            where dtfac.noint = pbInter.NoInt
              and dtfac.nofac = factu.Nofac:
            assign
                ttListeIntervention.daDateCreation       = DtFac.dtcsy
                ttListeIntervention.cLibelleIntervention = DtFac.lbint
                ttListeIntervention.cCodeFournisseur     = string(factu.nofou)
                ttListeIntervention.cLibelleFournisseur  = dynamic-function('getLibelleFour' in ghFournisseur, pbInter.tpcon,factu.nofou)
            .
        end.
    end case.

end function.

function isOrdre2ServiceTermine returns logical private (piNoIntUse as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer Trint for TrInt.

    for each trint no-lock
        where trint.NoInt = piNoIntUse
          and Trint.TpTrt = {&TYPEINTERVENTION-ordre2service}
        break by trint.notrt:
        if last-of(trint.notrt)
        and can-find(first dtord no-lock
            where dtord.noord = trInt.notrt
              and dtord.noint = trint.noint
              and dtord.cdsta = {&STATUTINTERVENTION-termine}) then return true.
    end.
    return false.

end function.

procedure rechercheIntervention:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beIntervention.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttIntervention.

    define variable vhQuery      as handle    no-undo.
    define variable vcQuery      as character no-undo.
    // Critères de recherche
    define variable vcNoImm      as character no-undo.
    define variable vcNoImmDeb   as character no-undo.
    define variable vcNoImmFin   as character no-undo.
    define variable vcNoMdt      as character no-undo.
    define variable vcNoMdtDeb   as character no-undo.
    define variable vcNoMdtFin   as character no-undo.
    define variable viCpUseInc   as integer   no-undo.
    define variable vcNoGesUse   as character no-undo.
    define variable vcTpTrtUse   as character no-undo.
    define variable viNoResUse   as integer   no-undo.
    define variable vcCdStaUse   as character no-undo.
    define variable viNoDosDeb   as integer   no-undo.
    define variable viNoDosFin   as integer   no-undo.
    define variable viNoIntDeb   as integer   no-undo.
    define variable viNoIntFin   as integer   no-undo.
    define variable vcNoFouUse   as character no-undo.
    define variable vdaDebut     as date      no-undo.
    define variable vdaFin       as date      no-undo.

    define buffer trint for trint.
    define buffer inter for Inter.
    define buffer intnt for intnt.

    empty temp-table ttIntervention.
    assign
        vcNoGesUse = poCollection:getCharacter("cCodeService")
        vcNoImm    = string(poCollection:getInteger("iNumeroImmeuble"))
        vcNoImmDeb = string(poCollection:getInteger("iNumeroImmeuble1"))
        vcNoImmFin = string(poCollection:getInteger("iNumeroImmeuble2"))
        vcNoMdt    = string(poCollection:getInteger("iNumeroMandat"))
        vcNoMdtDeb = string(poCollection:getInteger("iNumeroMandat1"))
        vcNoMdtFin = string(poCollection:getInteger("iNumeroMandat2"))
        vcTpTrtUse = poCollection:getCharacter("cTypeIntervention")
        viNoResUse = poCollection:getInteger("iNumeroResponsable")
        vcCdStaUse = poCollection:getCharacter("cStatutIntervention")
        viNoDosDeb = poCollection:getInteger("iNumeroDossier1")
        viNoDosFin = poCollection:getInteger("iNumeroDossier2")
        viNoIntDeb = poCollection:getInteger("iNumeroIntervention1")
        viNoIntFin = poCollection:getInteger("iNumeroIntervention2")
        vcNoFouUse = poCollection:getCharacter("cCodeFournisseur")
        vdaDebut   = poCollection:getDate("daDateIntervention1")
        vdafin     = poCollection:getDate("daDateIntervention2")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign  // ne pas fusionner les assign, when utilisé plus bas !!!
        giNombreLigne = 0
        vcNoMdtDeb    = '0' when vcNoMdtDeb = '' or vcNoMdtDeb = ?
        vcNoImmDeb    = '0' when vcNoImmDeb = '' or vcNoImmDeb = ?
        vcNoMdtDeb    = if vcNoMdt > '' then vcNoMdt else vcNoMdtDeb
        vcNoMdtFin    = if vcNoMdt > '' then vcNoMdt else vcNoMdtFin
        vcNoImmDeb    = if vcNoImm > '' then vcNoImm else vcNoImmDeb
        vcNoImmFin    = if vcNoImm > '' then vcNoImm else vcNoImmFin
        viNoIntDeb    = 0 when viNoIntDeb = ?
        viNoIntFin    = 0 when viNoIntFin = ?
        viNoIntFin    = if viNoIntDeb = 0 and viNoIntFin = 0 then 999999999 else if viNoIntFin <> 0 then viNoIntFin else viNoIntDeb 
        viNoDosDeb    = 0 when viNoDosDeb = ?
        viNoDosFin    = 0 when viNoDosFin = ?
        viNoDosFin    = if viNoDosDeb = 0 and viNoDosFin = 0 then 999999999 else if viNoDosFin <> 0 then viNoDosFin else viNoDosDeb 
        vcNoGesUse    = if vcNoGesUse = "all" or vcNoGesUse = ? then "" else vcNoGesUse
        vcTpTrtUse    = if lookup("all", vcTpTrtUse) > 0  then "*" else trim(vcTpTrtUse)
        viNoResUse    = if viNoResUse = ? then 0 else viNoResUse
        vcCdStaUse    = if lookup("all", vcCdStaUse) > 0  then "" else trim(vcCdStaUse)
    .
    create query vhQuery.
    vhQuery:set-buffers(buffer intnt:handle).
    vcQuery = substitute(
        'for each intnt no-lock where intnt.tpidt = {&TYPEBIEN-immeuble} and (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} or intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}) &1 &2 &3 &4 &5 &6 by intnt.tpcon by intnt.nocon',
        if vcNoImmDeb > '' and vcNoImmDeb <> '0' then 'and intnt.noidt >= ' + vcNoImmDeb else '',
        if vcNoImmFin > '' and vcNoImmFin <> '0' then 'and intnt.noidt <= ' + vcNoImmFin else '',
        if vcNoMdtDeb > '' and vcNoMdtDeb <> '0' then 'and intnt.nocon >= ' + vcNoMdtDeb else '',
        if vcNoMdtFin > '' and vcNoMdtFin <> '0' then 'and intnt.nocon <= ' + vcNoMdtFin else ''
        ).
    vhQuery:query-prepare(vcQuery).
message "rechercheIntervention ----- query: " vcQuery.

    vhQuery:query-open().
    run tiers/fournisseur.p persistent set ghFournisseur.
    run getTokenInstance in ghFournisseur (mToken:JSessionId).

boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.
intervention:
        /*--> Nombre d'interventions */
        for each inter no-lock
           where inter.tpcon = intnt.tpcon
             and inter.nocon = intnt.nocon:
           /* and inter.dtCsy > today - 730:*/
            if (vdaDebut <> ? and inter.dtcsy < vdaDebut)
            or (vdaFin <> ?   and inter.dtcsy > vdaFin)
            or inter.noint < viNoIntDeb
            or inter.noint > viNoIntFin
            or (viNoResUse > 0 and viNoResUse <> inter.nores)
            or inter.nodos < viNoDosDeb
            or inter.nodos > viNoDosFin then next intervention.

            /* KANTENA : déplacé de la boucle repeat vers la boucle inter */
            viCpUseInc = 0.
            run application/envt/gesflges.p (mToken, vcNoGesUse, input-output viCpUseInc, 'Direct', intnt.tpcon + '|' + string(intnt.nocon)).
            if viCpUseInc > 0 then next intervention.

            /*--> Recherche des traitements */
traitement:
            for each trint no-lock
                where trint.NoInt = inter.noint
                break by TrInt.NoInt by trint.tptrt by trint.notrt by trint.rgtrt:

                if last-of(trint.notrt) then do:
                    /*--> Filtre sur le type de traitement */
                    if vcTpTrtUse > '' and not can-do(vcTpTrtUse, trint.tptrt) then next traitement.

                    /*--> Filtre sur le statut */
                    if vcCdStaUse > "" then do:
                        /* statut: dernière sauf terminé, Ne pas prendre les interventions terminées */
                        /*         non facturée, test sur le flag facturation */
                        /*         non bon a payer */
                        if (can-do(vcCdStaUse, "99999") and trint.cdsta = {&STATUTINTERVENTION-termine})
                        or (can-do(vcCdStaUse, "99998") and inter.fgfac)
                        or (can-do(vcCdStaUse, "99997") and trint.tptrt <> {&TYPEINTERVENTION-ordre2service} and trint.tptrt <> {&TYPEINTERVENTION-facture})
                        then next traitement.

                        if can-do(vcCdStaUse, "99999") or can-do(vcCdStaUse, "99998") or can-do(vcCdStaUse, "99997")
                        then case trint.TpTrt:                    /* Ne prendre que les dernières interventions */
                            when {&TYPEINTERVENTION-signalement}   then if trint.cdsta = {&STATUTINTERVENTION-enCours} then next traitement.
                            when {&TYPEINTERVENTION-demande2devis} then if trint.cdsta = {&STATUTINTERVENTION-repondu} or trint.cdsta = {&STATUTINTERVENTION-nonRepondu} then next traitement.
                            when {&TYPEINTERVENTION-reponseDevis}  then if trint.cdsta = {&STATUTINTERVENTION-accepte} or trint.cdsta = {&STATUTINTERVENTION-refuse} then next traitement.
                            when {&TYPEINTERVENTION-facture}       then if trint.cdsta = {&STATUTINTERVENTION-bonAPayer} and inter.qtfac <= 0 then next traitement.
                        end case.
                        else if not can-do(vcCdStaUse, trint.cdsta) then next traitement. /* Ne pas prendre les interventions avec un statut différent */
                    end.
                    /* Ne pas afficher devis si ordre de service "terminé" */
                    if (trint.TpTrt = {&TYPEINTERVENTION-demande2devis} and isOrdre2ServiceTermine(inter.noint))
                    or existeEtapeSuivante(trint.tptrt, inter.noint) then next traitement.

                    if not creSelection(buffer Inter, intnt.noidt, trint.tptrt, trint.notrt, vcNoFouUse) then leave boucle.
                end.
            end.
        end.
    end.
    vhQuery:query-close() no-error.
    delete object vhQuery no-error.
    run destroy in ghFournisseur.

end procedure.

procedure getHistoriqueIntervention:
    /*------------------------------------------------------------------------------
    Purpose: procédure de référence ChgTbHis dans visinter_srv.p
    Notes  : service pour beIntervention.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroIntervention as integer no-undo.
    define output parameter table for ttHistoriqueIntervention.

    define variable vcLibelleFour         as character no-undo.
    define variable vcLibelleIntervention as character no-undo.
    define variable viNoFour              as integer   no-undo.
    define variable vcCommentaire         as character no-undo.
    define variable viTpsTot              as integer   no-undo.

    define buffer inter for inter.
    define buffer prmTv for prmTv.
    define buffer trInt for trInt.
    define buffer tutil for tutil.
    define buffer DtDev for DtDev.
    define buffer devis for devis.
    define buffer svdev for svdev.
    define buffer dtOrd for dtOrd.
    define buffer ordSe for ordSe.
    define buffer dtfac for dtfac.
    define buffer factu for factu.

    empty temp-table ttIntervention.
    giNombreLigne = 0.
    find first inter no-lock where inter.noint = piNumeroIntervention no-error.
    if not available inter then return.

    find first prmtv no-lock
        where prmtv.tppar = "DLINT"
          and prmtv.cdpar = inter.dlint no-error.
    run tiers/fournisseur.p persistent set ghFournisseur.
    run getTokenInstance in ghFournisseur (mToken:JSessionId).

boucleIntervention:
    for each trint no-lock
        where trint.noint = piNumeroIntervention
        break by trint.noint:
        find first tutil no-lock where tutil.ident_u = trint.cdcsy no-error.
        assign
            viNoFour      = 0
            vcLibelleFour = ''
            vcCommentaire = inter.lbmot
        .
        case TrInt.TpTrt:
            when {&TYPEINTERVENTION-demande2devis} then for first dtdev no-lock
                where dtdev.noint = trint.noint
                  and dtdev.nodev = trint.notrt          // .Nodev
              , first devis no-lock
                where devis.nodev = dtdev.nodev
              , first inter no-lock
                where inter.noint = DtDev.noint:
                assign
                    viNoFour              = devis.nofou
                    vcLibelleIntervention = dtdev.lbint
                    vcLibelleFour         = dynamic-function('getLibelleFour' in ghFournisseur, Inter.TpCon, devis.nofou)
                    vcCommentaire         = dtdev.lbmot
                .
            end.
            when {&TYPEINTERVENTION-reponseDevis} then for first svdev no-lock 
                where svdev.nodev = trint.notrt
                  and svdev.noint = trint.noint
              , first devis no-lock where devis.nodev = svdev.nodev
              , first inter no-lock
                where inter.noint = SvDev.noint:
                assign
                    viNoFour              = devis.Nofou
                    vcLibelleIntervention = svdev.lbint
                    vcLibelleFour         = dynamic-function('getLibelleFour' in ghFournisseur,inter.tpcon, devis.nofou)
                    vcCommentaire         = svdev.lbmot
                .
            end.
            when {&TYPEINTERVENTION-ordre2service} then for first dtOrd no-lock
                where dtord.NoInt = piNumeroIntervention
              , first ordse no-lock
                where ordse.NoOrd = dtord.noOrd
              , first inter no-lock
                where inter.noint = dtord.noint:
                assign
                    vcLibelleIntervention = dtord.lbint
                    viNoFour              = ordse.nofou
                    vcLibelleFour         = dynamic-function('getLibelleFour' in ghFournisseur, inter.tpcon, ordse.nofou)
                    vcCommentaire         = dtord.lbmot
                .
            end.
            when {&TYPEINTERVENTION-facture} then for first dtfac no-lock
                where dtfac.nofac = trint.notrt
                  and dtfac.noint = trint.noint
              , first factu no-lock
                where factu.nofac = dtfac.nofac
              , first inter no-lock
                where inter.noint = dtfac.noint:
                assign
                    vcLibelleIntervention = dtfac.lbint
                    viNoFour              = factu.nofou
                    vcLibelleFour         = dynamic-function('getLibelleFour' in ghFournisseur, inter.tpcon, factu.nofou)
                .
            end.
        end case.
        create ttHistoriqueIntervention.
        assign
            giNombreLigne                                 = giNombreLigne + 1
            ttHistoriqueIntervention.CRUD                 = 'R'
            ttHistoriqueIntervention.iNumeroIntervention  = piNumeroIntervention
            ttHistoriqueIntervention.cCodeTraitement      = trint.tptrt
            ttHistoriqueIntervention.iNumeroTraitement    = trint.notrt
            ttHistoriqueIntervention.cCodeArticle         = inter.cdart
            ttHistoriqueIntervention.cCodeFournisseur     = string(viNoFour)
            ttHistoriqueIntervention.cLibelleFournisseur  = vcLibelleFour
            ttHistoriqueIntervention.cTypeMandat          = inter.tpcon
            ttHistoriqueIntervention.iNumeroMandat        = inter.nocon
            ttHistoriqueIntervention.iDureeTraitement     = TrInt.DuTrt
            ttHistoriqueIntervention.daDateCreation       = trint.dtcsy
            ttHistoriqueIntervention.cLibelleIntervention = vcLibelleIntervention
            ttHistoriqueIntervention.cCodeStatut          = trint.cdsta
            ttHistoriqueIntervention.cLibelleStatut       = outilTraduction:getLibelleParam("STTRV", trint.cdsta)
            ttHistoriqueIntervention.cLibelleTraitement   = substring(outilTraduction:getLibelleProg("O_CLC", ttHistoriqueIntervention.cCodeTraitement), 1, 3, 'character')
            ttHistoriqueIntervention.cCommentaire         = trint.lbcom + (if last-of(trint.noint) and trim(vcCommentaire) > "" then " - " + vcCommentaire else "")
            ttHistoriqueIntervention.cUserModification    = if available tutil then tutil.nom else trint.cdcsy
          //ttIntervention.daDateRealisation              = inter.dtcsy + (if available prmtv then prmtv.nbpar else 0)
          //ttIntervention.lFacture                       = inter.fgfac
          //ttIntervention.lBAP                           = false
          //ttIntervention.dtTimestamp                    = datetime(inter.dtmsy, inter.hemsy)
            viTpsTot                                      = viTpsTot + TrInt.duTrt
        .
        if giNombreLigne >= {&MAXRETURNEDROWS}
        then do:
            mError:createError({&warning}, 211668, "{&MAXRETURNEDROWS}").  // nombre maxi d'enregistrement atteint
            leave boucleIntervention.
        end.
    end.
    run destroy in ghFournisseur.

end procedure.

procedure deleteIntervention:
    /*------------------------------------------------------------------------------
    Purpose:     TODO: manque un timestamp pour gérer la suppression
    Notes  : service pour beIntervention.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeTraitement     as character no-undo.
    define input parameter piNumeroTraitement   as int64     no-undo.
    define input parameter piNumeroIntervention as integer   no-undo.
    define output parameter table for ttIntervention.

    define buffer inter for inter.
    define buffer trint for trint.
    define buffer signa for signa.
    define buffer devis for devis.
    define buffer dtdev for dtdev.
    define buffer ordse for ordse.
    define buffer dtord for dtord.
    define buffer dtlot for dtlot.

    empty temp-table ttIntervention.
    /* Controle avant suppression */
    if not controleSuppressionIntervention(piNumeroIntervention) then return.

    /*--> Suppression des interventions */
    for each inter exclusive-lock
       where inter.noint = piNumeroIntervention:
        delete inter.
    end.
    /*--> Suppression des traitements */
    for each trint exclusive-lock
       where trint.tptrt = pcCodeTraitement
         and TrInt.notrt = piNumeroTraitement:
        delete trint.
    end.
    /*--> Suppression du signalement */
    for first signa exclusive-lock 
         where signa.nosig = piNumeroTraitement:
        delete signa.
    end.
    /*--> Suppression de la demande de devis */
    for first devis no-lock
        where devis.nodev = piNumeroTraitement
      , first dtdev exclusive-lock
        where dtdev.nodev = devis.nodev
          and dtdev.noint = piNumeroIntervention:
        delete dtdev.
    end.
    /*--> Suppression de l'ordre de service */
    for first ordse exclusive-lock 
        where ordse.noord = piNumeroTraitement:
        for first dtord exclusive-lock
            where dtord.noord = ordse.noOrd
              and dtord.noInt = piNumeroIntervention:
            delete dtord.
        end.
        delete ordse.
    end.
    /*--> Suppression des 'lot' */
    for each dtlot exclusive-lock
        where dtlot.tptrt = pcCodeTraitement
          and dtlot.notrt = piNumeroTraitement:
        delete dtlot.
    end.
    mError:createError({&information}, 103340).    /* Suppression effectuée.*/

end procedure.

procedure editionListeIntervention:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beIntervention.cls
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttIntervention.
    define output parameter pcFile    as character no-undo.

    define variable voCarnetEntretien   as class parametrageCarnetEntretien no-undo.
    define variable vlFgEdtUse          as logical   no-undo.
    define variable vcRepertoireEdition as character no-undo.
    define variable vcFichierEdition    as character no-undo.
    define variable vcRpRunExe          as character no-undo.

    assign
        vcRepertoireEdition = session:temp-directory
        vcFichierEdition    = "LsInt.txt"
    .
    output to value(vcRepertoireEdition + vcFichierEdition).

    /* Mise à jour utilisateur */
    run RecupereRepertoires(input-output vcRpRunExe).
    /*--> Couleur du Cabinet */
    voCarnetEntretien = new parametrageCarnetEntretien("00001", "", "").
    /*--> Parametre :
       - Nre de colonne
       - Nbr de Ligne titre
       - Orientation (1-portrait 2-Paysage)
       - Zoom
       - Hauteur des lignes
       - Nombre de lignes de rupture
       - Nombre de lignes dans la page (0 pas de gestion du saut de page) */
    put unformatted
        "PARAM;12;2;2;75;20;0;0;" string(voCarnetEntretien:getColorRed()) ";" string(voCarnetEntretien:getColorGreen()) ";" string(voCarnetEntretien:getColorBlue()) skip
        /*--> Taille des colonnes */
        "TAILLE;7;7;40;7;40;7;7;7;7;7;7;40" skip
        /*--> Alignement des colonnes : -4131 left -4108 centrer -4152 right */
        "HALIGN;-4108;-4108;-4131;-4108;-4131;-4131;-4108;-4108;-4131;-4108;-4108;-4131" skip
        /*--> Format des colonnes */
        "FORMAT;C;C;C;C;C;C;C;C;C;C;C;C" skip
        "ENT1;LISTE DES INTERVENTIONS" skip
        "TIT2;N° imm;N° mdt;Nom mandat;Type;Nom intervention;Statut;FAC;BAP;N° inter;Création;Prévue;Fournisseur" skip
    .
    delete object voCarnetEntretien.
    /*--> Flag lancement de l'édition */
    vlFgEdtUse = true.
    for each ttIntervention:
        put unformatted
            "LIG1;"
            string(ttIntervention.iNumeroImmeuble, "99999") ";"
            string(ttIntervention.iNumeroMandat, "99999") ";"
            ttIntervention.cLibelleImmeuble ";"
            ttIntervention.cLibelleTraitement ";"
            ttIntervention.cLibelleIntervention ";"
            ttIntervention.cLibelleStatut ";"
            string(ttIntervention.lFacture, "X/") ";"
            string(ttIntervention.lBAP, "X/") ";"
            string(ttIntervention.iNumeroTraitement) ";"
            string(ttIntervention.daDateCreation, "99/99/9999") ";"
            string(ttIntervention.daDateRealisation, "99/99/9999") ";"
            ttIntervention.cLibelleFournisseur skip
        .
    end.
    output close.
    if vlFgEdtUse
    then do:
        /* TODO  kantena, pour l'instant, répertoire accessible tomcat !!!
        pcFile = cRepertoireEdition + mtoken:cUser + "-" + REPLACE(cFichierEdition,".txt",".xls").
        */
        pcFile = substitute("C:~\dlc~\wrkOE116~\magiController~\webapps~\ROOT~\&1-&2", mtoken:cUser, replace(vcFichierEdition, ".txt", ".xls")).
        run EdtExcel(
            vcRpRunExe + "gidev~\adb~\excel~\reque~\macro~\",
            "tableur.xls",
            vcRepertoireEdition + vcFichierEdition,
            pcFile).
        pcFile =  substitute("/&1-&2", mtoken:cUser, replace(vcFichierEdition, ".txt", ".xls")).
    end.

end procedure.

procedure EdtExcel private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcLbCheMac as character no-undo.
    define input parameter pcNmMacUse as character no-undo.
    define input parameter pcLbCheTxt as character no-undo.
    define input parameter pcLbCheXls as character no-undo.

    define variable vHwComExc as com-handle no-undo.
    define variable vHwComXls as com-handle no-undo.
    define variable vHwComMac as com-handle no-undo.

    /*--> Suppression du fichier */
    os-delete value(pcLbCheXls).
    if os-error = 999 then do:

message "edtExcel: " outilTraduction:getLibelle(105179).

        mError:createError({&erreur}, 105179).
        return.
    end.

    /*--> Lancement d'Excel */
    create "Excel.Application" vHwComExc no-error.
    vHwComExc:visible = true.

    /*--> Ouverture du classeur Macro */
    vHwComExc:WORKBOOKS:OPEN(pcLbCheMac + pcNmMacUse,,,,,,TRUE).
    vHwComXls = vHwComExc:ACTIVEWORKBOOK.

    /*--> Execution de la Macro */
    vHwComExc:run(pcNmMacUse + "!ouverture", pcLbCheTxt, mToken:cRefPrincipale).
    vHwComMac = vHwComExc:ACTIVEWORKBOOK.

    /*--> Sauvegarde */
    vHwComMac:SAVEAS(pcLbCheXls,-4143,,,,,).
    vHwComXls:close(false).
    vHwComExc:quit().

    /*--> Liberation des Caneaux de communication*/
    release object vHwComExc.
    release object vHwComXls.
    release object vHwComMac.

end procedure.

procedure cloture:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service pour beDemandeDeDevis.cls, beIntervention.cls, ...
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.

    define variable viNumeroTraitement   as int64     no-undo.
    define variable vcCodeTraitement     as character no-undo.
    define variable vcCodeCloture        as character no-undo.
    define variable vcLibelleCloture     as character no-undo.
    define variable vcCommentaireCloture as character no-undo.

    define buffer trint   for trint.
    define buffer vbTrint for trint.
    define buffer inter   for inter.
    define buffer dtdev   for dtdev.
    define buffer devis   for devis.
    define buffer svdev   for svdev.
    define buffer ordse   for ordse.
    define buffer dtord   for dtord.
    define buffer signa   for signa.

    assign
        viNumeroTraitement   = poCollection:getInt64("iNumeroTraitement")
        vcCodeTraitement     = poCollection:getCharacter("cCodeTraitement")
        vcCodeCloture        = poCollection:getCharacter("cCodeCloture")
        vcLibelleCloture     = poCollection:getCharacter("cLibelleCloture")
        vcCommentaireCloture = poCollection:getCharacter("cCommentaireCloture")
    .
    if not can-find(first trint no-lock
                    where trint.notrt = viNumeroTraitement
                      and trint.tptrt = vcCodeTraitement 
                      and trint.cdsta = {&STATUTINTERVENTION-termine})
    then do transaction:
        {&_proparse_prolint-nowarn(sortaccess)}
        for each trint no-lock 
            where trint.notrt = viNumeroTraitement
              and trint.tptrt = vcCodeTraitement
            break by trint.notrt by trint.tptrt by trint.noidt by trint.noint:
            if last-of(trint.noidt) then do:
                create vbTrint.
                assign
                    vbTrint.noRef = integer(mToken:cRefPrincipale)
                    vbTrint.noInt = trint.noint
                    vbTrint.noIdt = trint.noidt + 1
                    vbTrint.tpTrt = vcCodeTraitement
                    vbTrint.noTrt = viNumeroTraitement
                    vbTrint.cdSta = {&STATUTINTERVENTION-termine}
                    vbTrint.lbCom = vcLibelleCloture //inter.lbcom
                    vbTrint.cdcsy = mtoken:cUser
                    vbTrint.dtCsy = today
                    vbTrint.heCsy = mtime
                .
            end.
        end.
        /* Cloture et création du traitement pour l'historique */
        case vcCodeTraitement:
            when {&TYPEINTERVENTION-signalement} then for first signa no-lock
                where signa.nosig = viNumeroTraitement
              , each inter exclusive-lock
                where inter.nosig = signa.nosig:
                assign
                    inter.cdsta = {&STATUTINTERVENTION-termine}
                    inter.cdmot = vcCodeCloture
                    inter.lbmot = vcCommentaireCloture
                    inter.cdmsy = mtoken:cUser
                    inter.dtmsy = today
                    inter.hemsy = mtime
                .
            end.
            when {&TYPEINTERVENTION-demande2devis} then for first devis no-lock
                where devis.nodev = viNumeroTraitement
              , each dtdev exclusive-lock
                where dtdev.nodev = devis.nodev:
                assign
                    dtdev.cdsta = {&STATUTINTERVENTION-termine}
                    dtdev.cdmot = vcCodeCloture
                    dtdev.lbmot = vcCommentaireCloture
                    dtdev.cdmsy = mtoken:cUser
                    dtdev.dtmsy = today
                    dtdev.hemsy = mtime
                .
            end.
            when {&TYPEINTERVENTION-reponseDevis} then for first devis no-lock
                where devis.nodev = viNumeroTraitement
              , each svdev exclusive-lock
                where svdev.nodev = devis.NoDev:
                assign
                    svdev.cdsta = {&STATUTINTERVENTION-termine}
                    svdev.cdmot = vcCodeCloture
                    svdev.lbmot = vcCommentaireCloture
                    svdev.cdmsy = mtoken:cUser
                    svdev.dtmsy = today
                    svdev.hemsy = mtime
                .
            end.
            when {&TYPEINTERVENTION-ordre2service} then for first ordSe no-lock
                where ordse.noOrd = viNumeroTraitement
              , each dtord exclusive-lock
                where dtord.noord = OrdSe.NoOrd:
                assign
                    dtord.cdsta = {&STATUTINTERVENTION-termine}
                    dtord.cdmot = vcCodeCloture
                    dtord.lbmot = vcCommentaireCloture
                    dtord.cdmsy = mtoken:cUser
                    dtord.dtmsy = today
                    dtord.hemsy = mtime
                .
            end.
            otherwise return.
        end case.
    end.
    else mError:createError({&information}, 1000265). /* Déjà clôturé */

end procedure.

procedure getListeInterventions:
    /*------------------------------------------------------------------------------
    Purpose: Recuperation des interventions du dossier ou toutes les interventions non rattachées à un dossier
    Notes  : service pour beIntervention.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttListeIntervention.

    define variable vcTypeMandat             as character no-undo.
    define variable viNumeroMandat           as integer   no-undo.
    define variable vcCodeStatutIntervention as character no-undo.
    define variable viNoDossierTravaux       as integer   no-undo.
    define buffer inter for inter.
    define buffer trint for trint.

    assign
        vcTypeMandat             = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat           = poCollection:getInteger("iNumeroMandat")
        vcCodeStatutIntervention = poCollection:getCharacter("cCodeStatutIntervention")
        viNoDossierTravaux       = poCollection:getInteger("iNumeroDossierTravaux")
        giNombreLigne            = 0
    .

message "Recuperation des interventions du mandat " viNumeroMandat " Dossier " viNoDossierTravaux " statut " vcCodeStatutIntervention.

    run tiers/fournisseur.p persistent set ghFournisseur.
    run getTokenInstance in ghFournisseur (mtoken:JSessionId).
    {&_proparse_prolint-nowarn(sortaccess)}
    for each inter no-lock
        where inter.tpcon = vcTypeMandat
          and inter.nocon = viNumeroMandat
          /*and inter.cdsta = {&STATUTINTERVENTION-enCours}
          and (inter.nodos = piNoDossierTravaux or inter.nodos = 0)*/
          and (vcCodeStatutIntervention = "" or inter.cdsta = vcCodeStatutIntervention)
          and (if viNoDossierTravaux <> 0 then inter.nodos = viNoDossierTravaux else true)
      , each trint no-lock
        where trint.noint = inter.noint
        by trint.tptrt by trint.notrt:
        creSelectionListe(buffer Inter, trint.tptrt, trint.notrt).
    end.
    run destroy in ghFournisseur.

end procedure.

procedure RecupereRepertoires private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input-output parameter pcRpRunExe as character no-undo.

    /* TODO    PL : A REVOIR */
    pcRpRunExe = "c:~\magi~\Appli_V11~\".

end procedure.
