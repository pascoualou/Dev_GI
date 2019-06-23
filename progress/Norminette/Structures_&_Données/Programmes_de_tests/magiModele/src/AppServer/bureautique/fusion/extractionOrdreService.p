/*-----------------------------------------------------------------------------
File        : extractionOrdreService.p
Description : Recherche des donnees de fusion de l'ordre de Service
Author(s)   : RF - 2009/04/11, KANTENA - 2018/02/26
Notes       : anciennement ordreser.p
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionOrdreService.i}

using bureautique.fusion.classe.fusionOrdreservice.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.
using Progress.Json.ObjectModel.JsonObject.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

function getLibelleCle return character(piNumeroImmeuble as int64, pcTypeContrat as character, piNumeroContrat as int64, pcCodeCle as character):
    /*------------------------------------------------------------------------------
     Purpose: Retourne la cle de repartition
     Notes:
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.

    for first clemi no-lock
        where clemi.noimm = (if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} then piNumeroImmeuble else piNumeroContrat + 10000)
          and clemi.cdcle = pcCodeCle:
        return clemi.lbcle.
    end.
    return "".
end function.

function donneInfosArticle return character(pcCodeArticle as character):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo initial "####".

    define buffer artic for artic.
    define buffer prmrg for prmrg.
    define buffer prmar for prmar.
    define buffer prmtv for prmtv.

    /* Recherche de l'article */
    for first artic no-lock
         where artic.cdart = pcCodeArticle:
        /* Recherche des infos en fonction du code regroupement */
        if Artic.cdrgt <> "00000"
        then for first prmrg no-lock
            where prmrg.cdrgt = Artic.cdrgt:
            vcRetour = substitute("&1#&2#&3##", prmrg.norub, prmrg.nossr, prmrg.nofis).
        end.
        else for first prmar no-lock
            where prmar.cdart = artic.cdart:
            vcRetour = substitute("&1#&2#&3##", prmar.norub, prmar.nossr, prmar.nofis).
        end.
        /* SY 0316/0037 */
        find first prmtv no-lock
             where prmtv.tppar = "DOMAI" 
               and prmtv.cdpar = artic.cddom no-error.
        if available prmtv then entry(4, vcRetour, "#" ) = prmtv.lbpar.
        entry(5, vcRetour, "#") = artic.lbart.       /* SY 0416/0079 */
    end.
    return vcRetour.
end function.

procedure extractionOrdreService:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroOS       as integer   no-undo.
    define input        parameter piNumeroDocument as int64     no-undo.
    define input        parameter pcListeChamp     as character no-undo.
    define input-output parameter poFusionOS       as class fusionOrdreservice no-undo.

    define variable vcLibelleTvaInt   as character no-undo extent 30.  /* SY 1013/0167 EXTENT 20 -> 30 */
    define variable vdMontantTvaInt   as decimal   no-undo extent 30.  /* SY 1013/0167 EXTENT 20 -> 30 */
    define variable vdMontantTotalInt as decimal   no-undo extent 30.  /* SY 1013/0167 EXTENT 20 -> 30 */
    define variable vdMontantTva      as decimal   no-undo.
    define variable vdMontantHTTotal  as decimal   no-undo.
    define variable vdMontantTvaTotal as decimal   no-undo.

    define variable voAdresse         as class fusionAdresse no-undo.
    define variable voRole            as class fusionRole    no-undo.
    define variable vhProcLot         as handle    no-undo.
    define variable vcInfosArticle    as character no-undo.
    define variable vdTauxTVAReduitOS as decimal   no-undo.
    define variable vcDateClotureOS   as character no-undo.
    define variable viNumeroTva       as integer   no-undo.
    define variable viNumeroTvaMax    as integer   no-undo.
    define variable vcLibelleTva      as character no-undo.
    define variable viNoBaiOCC        as integer   no-undo.
    define variable viNoCttPro        as integer   no-undo.
    define variable vcTpCopUse        as character no-undo.
    define variable viNoCopUse        as integer   no-undo.
    define variable vdaDtAchLot       as date      no-undo.
    define variable vcCdRegLot        as character no-undo.
    define variable vcNmOccLot        as character no-undo.
    define variable vdaDtEntOcc       as date      no-undo.
    define variable vcTpOccLot        as character no-undo.
    define variable vcTpRolOcc        as character no-undo.
    define variable viNoRolOcc        as integer   no-undo.
    define variable vcDateDebut       as character no-undo.
    define variable vcDateFin         as character no-undo.
    define variable viCompteur        as integer   no-undo.
    define variable vlBloc1           as logical   no-undo.
    define variable vlBloc2           as logical   no-undo.
    define variable vcCodeTva         as character no-undo.
    define buffer intnt    for intnt.
    define buffer CcptCol  for CcptCol.
    define buffer dtlot    for dtlot.
    define buffer ifour    for ifour.
    define buffer ilibport for ilibport.
    define buffer local    for local.
    define buffer ordse    for ordse.
    define buffer iregl    for iregl.
    define buffer dtord    for dtord.
    define buffer inter    for inter.
    define buffer trint    for trint.
    define buffer itaxe    for itaxe.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-NumFourniordreService}             or when {&FUSION-NumordreService}         or when {&FUSION-DateCreationordreService} or
            when {&FUSION-DateLCreationordreService}         or when {&FUSION-CondPaiemordreService}   or when {&FUSION-CondPortordreService}     or
            when {&FUSION-DateCreationordreServiceLettre}    or when {&FUSION-ListeLotsoS}             or when {&FUSION-ListeNatureLotsoS}        or
            when {&FUSION-ListeBatLotsoS}                    or when {&FUSION-ListeentreeLotsoS}       or when {&FUSION-ListeescLotsoS}           or
            when {&FUSION-ListeetageLotsoS}                  or when {&FUSION-ListePorteLotsoS}        or when {&FUSION-ListeOccupantLotsOS}      or
            when {&FUSION-TableLotsoS}                       or when {&FUSION-TableLotsOccupantsOS}    or when {&FUSION-ListeTeloccupantLotsOS}   or
            when {&FUSION-RoleSignalantoS}                   or when {&FUSION-TitreSignalantoS}        or when {&FUSION-TitreLSignalantoS}        or
            when {&FUSION-CiviliteSignalantoS}               or when {&FUSION-NomSignalantoS}          or when {&FUSION-NomCompletSignalantoS}    or
            when {&FUSION-adresseSignalantoS}                or when {&FUSION-SuiteadresseSignalantoS} or when {&FUSION-CodePostalSignalantoS}    or
            when {&FUSION-VilleSignalantoS}                  or when {&FUSION-VilleCedexSignalantoS}   or when {&FUSION-TelSignalantoS}           or
            when {&FUSION-PortableSignalantoS}               or when {&FUSION-TauxTVareduitoS}         or when {&FUSION-ListeemailoccupantoS}     or
            when {&FUSION-ComplementAdresseIdentSignalantOS} or when {&FUSION-HeureCreationOS}         or when {&FUSION-UtilisateurCreationOS}    or
            when {&FUSION-Commentaire1OS}                    or when {&FUSION-DateClotureOS}           or when {&FUSION-MotifClotureOS}           or
            when {&FUSION-NumDossierTravOs} /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            then do:
                if vlBloc1 then next boucleCHamp.
                assign
                    vlBloc1                    = true
                    poFusionOS:NumOrdreService = string(piNumeroOS)
                .
                for first ordse no-lock 
                    where ordse.noord = piNumeroOS:
                    assign
                        poFusionOS:DateCreationOrdreService       = dateToCharacter(ordse.dtcsy)
                        poFusionOS:DateLCreationOrdreService      = outilFormatage:getDateFormat(ordse.dtcsy, "L")
                        poFusionOS:DateCreationOrdreServiceLettre = outilFormatage:getDateFormat(ordse.dtcsy, "LL")
                        poFusionOS:NumFourniOrdreService          = string(ordse.nofou)
                        poFusionOS:HeureCreationOS                = string(ordse.hecsy, "HH:MM")
                        poFusionOS:UtilisateurCreationOS          = ordse.cdcsy
                        poFusionOS:Commentaire1OS                 = ordse.lbcom
                    .
                    for first CcptCol no-lock
                        where ccptCol.tprol  = 12
                          and ccptcol.soc-cd = integer(mtoken:cRefPrincipale)
                      , first ifour no-lock
                        where ifour.soc-cd          = ccptcol.soc-cd
                          and ifour.coll-cle        = ccptcol.coll-cle
                          and integer(ifour.cpt-cd) = ordse.nofou:             // todo : A PROSCRIRE
                        for first iregl no-lock
                            where iregl.soc-cd  = integer(mtoken:cRefPrincipale)
                              and iregl.regl-cd = ifour.regl-cd:
                            poFusionOS:CondPaiemOrdreService = iregl.lib.
                        end.
                        for first ilibport no-lock
                             where ilibport.soc-cd  = integer(mtoken:cRefPrincipale)
                               and ilibport.port-cd = ifour.port-cd:
                            poFusionOS:CondPortOrdreService = ilibport.lib.
                        end.
                    end.
                    if ordse.tppar > "" and ordse.nopar <> 0 
                    then do:
                        assign
                            poFusionOS:RoleSignalantOS       = if ordse.tpPar = "FOU" then outilTraduction:getLibelle(100124) else outilTraduction:getLibelleProg("O_ROL",ordse.tpPar)
                            voRole                           = chargeRole(ordse.tpPar, ordse.NoPar, piNumeroDocument)
                            poFusionOS:TitreSignalantOS      = voRole:Titre
                            poFusionOS:TitreLSignalantOS     = voRole:titreLettre
                            poFusionOS:CiviliteSignalantOS   = voRole:Civilite
                            poFusionOS:NomSignalantOS        = voRole:Nom
                            poFusionOS:NomCompletSignalantOS = voRole:nomComplet
                        .
                        assign
                            voAdresse = chargeAdresse(ordse.tpPar, ordse.NoPar, piNumeroDocument)
                            poFusionOS:AdresseSignalantOS                = voAdresse:Adresse
                            poFusionOS:SuiteAdresseSignalantOS           = voAdresse:complementVoie
                            poFusionOS:CodePostalSignalantOS             = voAdresse:CodePostal
                            poFusionOS:VilleSignalantOS                  = voAdresse:Ville
                            poFusionOS:VilleCedexSignalantOS             = voAdresse:Cedex
                            poFusionOS:TelSignalantOS                    = voAdresse:Telephone
                            poFusionOS:PortableSignalantOS               = voAdresse:Portable
                            poFusionOS:ComplementAdresseIdentSignalantOS = voAdresse:IdentAdresse      /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                        .
                    end.
                    /* Ajout SY le 13/01/2011 */
                    for each dtlot no-lock
                        where dtlot.tptrt = {&TYPEINTERVENTION-ordre2service}
                          and dtlot.notrt = piNumeroOS
                      , first local no-lock
                        where local.noloc = dtlot.noloc
                        by local.nolot:
                        if not valid-handle(vhProcLot) then do:
                            run immeubleEtLot/lot.p persistent set vhProcLot.
                            run getTokenInstance in vhProcLot(mToken:JSessionId).
                        end.
                        run occupLot in vhProcLot(buffer local,
                                                  output vcNmOccLot, 
                                                  output vdaDtentOcc,
                                                  output viNoBaiOCC,
                                                  output viNoCttPro,
                                                  output vcTpCopUse,
                                                  output viNoCopUse,
                                                  output vdaDtAchLot,
                                                  output vcTpOccLot,
                                                  output vcCdRegLot).  /* include PrOccLot.i */
                        if viNoBaiOcc <> 0
                        then assign
                            vcTpRolOcc = {&TYPEROLE-locataire}
                            viNoRolOcc = viNoBaiOcc
                        .
                        else if vcTpOccLot = "00001"
                        then assign /* occupant */
                            vcTpRolOcc = vcTpCopUse
                            viNoRolOcc = viNoCopUse
                        .
                        if viNoRolOcc <> 0 
                        then assign
                            voAdresse = chargeAdresse(vcTpRolOcc, viNoRolOcc, piNumeroDocument)
                            poFusionOS:ListeLotsOS                 = poFusionOS:ListeLotsOS                 + (if poFusionOS:ListeLotsOS                 > "" then chr(10) else "") + string(local.nolot)
                            poFusionOS:ListeNatureLotsOS           = poFusionOS:ListeNatureLotsOS           + (if poFusionOS:ListeNatureLotsOS           > "" then chr(10) else "") + outilTraduction:getLibelleParam("NTLOT", local.ntlot)
                            poFusionOS:ListeBatLotsOS              = poFusionOS:ListeBatLotsOS              + (if poFusionOS:ListeBatLotsOS              > "" then chr(10) else "") + trim(local.cdbat)
                            poFusionOS:ListeEntreeLotsOS           = poFusionOS:ListeEntreeLotsOS           + (if poFusionOS:ListeEntreeLotsOS           > "" then chr(10) else "") + trim(local.lbdiv)
                            poFusionOS:ListeEscLotsOS              = poFusionOS:ListeEscLotsOS              + (if poFusionOS:ListeEscLotsOS              > "" then chr(10) else "") + trim(local.cdesc)
                            poFusionOS:ListeEtageLotsOS            = poFusionOS:ListeEtageLotsOS            + (if poFusionOS:ListeEtageLotsOS            > "" then chr(10) else "") + trim(local.cdeta)
                            poFusionOS:ListePorteLotsOS            = poFusionOS:ListePorteLotsOS            + (if poFusionOS:ListePorteLotsOS            > "" then chr(10) else "") + trim(local.cdpte)
                            poFusionOS:ListeOccupantLotsOS         = poFusionOS:ListeOccupantLotsOS         + (if poFusionOS:ListeOccupantLotsOS         > "" then chr(10) else "") + trim(vcNmOccLot)
                            poFusionOS:ListeTelOccupantLotsOS      = poFusionOS:ListeTelOccupantLotsOS      + (if poFusionOS:ListeTelOccupantLotsOS      > "" then chr(10) else "") + trim(voAdresse:Telephone)
                            poFusionOS:ListeEmailOccupantOS        = poFusionOS:ListeEmailOccupantOS        + (if poFusionOS:ListeEmailOccupantOS        > "" then chr(10) else "") + trim(voAdresse:Mail)
                            poFusionOS:ListePortableOccupantLotsOS = poFusionOS:ListePortableOccupantLotsOS + (if poFusionOS:ListePortableOccupantLotsOS > "" then chr(10) else "") + trim(voAdresse:Portable)     /* NP 1015/0106 */
                            poFusionOS:TableLotsOS                 = poFusionOS:TableLotsOS
                                                                   + (if poFusionOS:TableLotsOS > "" then chr(10) else "") 
                                                                   + string(local.nolot, ">>>>9")                                           + chr(9)
                                                                   + string(outilTraduction:getLibelleParam("NTLOT", local.ntlot), "X(22)") + chr(9)
                                                                   + trim(local.cdbat)                                                      + chr(9)
                                                                   + trim(local.lbdiv)                                                      + chr(9)
                                                                   + trim(local.cdesc)                                                      + chr(9)
                                                                   + trim(local.cdeta)                                                      + chr(9)
                                                                   + trim(local.cdpte)
                            poFusionOS:TableLotsOccupantsOS        = poFusionOS:TableLotsOccupantsOS
                                                        + (if poFusionOS:TableLotsOccupantsOS > "" then chr(10) else "") 
                                                        + string(local.nolot, ">>>>9")                                           + chr(9)
                                                        + string(outilTraduction:getLibelleParam("NTLOT", local.ntlot), "X(18)") + chr(9)
                                                        + trim(local.cdbat)                                                      + chr(9)
                                                        + trim(local.lbdiv)                                                      + chr(9)
                                                        + trim(local.cdesc)                                                      + chr(9)
                                                        + trim(local.cdeta)                                                      + chr(9)
                                                        + trim(local.cdpte)                                                      + chr(9)
                                                        + trim(local.nmocc)                                                      + chr(9)
                                                        + trim(voAdresse:telephone)                                              + chr(9)
                                                        + trim(voAdresse:Portable)
                        .
                    end.
                    /* SY 1113/0168: 1er taux réduit trouvé dans une des lignes d'intervention de l'OS */  
                    for first dtord no-lock
                        where dtord.noord = piNumeroOS
                          and lookup(string(dtord.cdtva), "1,10") > 0:   /* SY 1013/0167 TVA réduite 5,5% ou 10% */
                        case dtord.cdtva:
                            when 1  then vdTauxTVAreduitOS = 5.5.
                            when 7  then vdTauxTVAreduitOS = 7.
                            when 10 then vdTauxTVAreduitOS = 10.
                        end case.
                    end.
                    /* Date et motif de cloture sur 1ère ligne intervention */  
                    for first dtord no-lock
                        where dtord.noord = piNumeroOS
                      , each trint no-lock
                        where trint.noint = dtord.noint
                          and trint.cdsta = "00100":       /* CdStaTer */
                        if vcDateClotureOS = "" then vcDateClotureOS = dateToCharacter(trint.dtcsy).    /* 1ère occurence de cloture */
                        poFusionOS:MotifClotureOS = trint.lbcom.
                    end.
                    for first dtord no-lock
                        where dtord.noord = piNumeroOS
                      , first inter no-lock
                        where inter.noint = dtord.noint:
                        poFusionOS:NumDossierTravOs = (if inter.nodos > 0 then string(inter.nodos) else "").
                    end.
                end. /* FOR FIRST ordse */
                assign
                    poFusionOS:TauxTVAreduitOS = montantToCharacter(vdTauxTVAreduitOS, false)
                    poFusionOS:DateClotureOS   = vcDateClotureOS
                .
            end.
            when {&FUSION-TableordreService}  or when {&FUSION-110245}            or when {&FUSION-ListeDesignationOS} or
            when {&FUSION-ListeRefarticleOS}  or when {&FUSION-ListeDtDebutOS}    or when {&FUSION-ListeDtFinOS}       or
            when {&FUSION-ListeQteOS}         or when {&FUSION-ListePUOS}         or when {&FUSION-ListeTxRemiseOS}    or
            when {&FUSION-ListeMontantOS}     or when {&FUSION-ListeTxTVaOS}      or when {&FUSION-ListeTVaOS}         or
            when {&FUSION-ListeCommentaireOS} or when {&FUSION-ListMontantHTOS}   or when {&FUSION-ListeCleOS}         or
            when {&FUSION-ListeCleLibelleOS}  or when {&FUSION-DateDebutOS}       or when {&FUSION-DateFinOS}          or
            when {&FUSION-TotalTTCOS}         or when {&FUSION-TotalHTOS}         or when {&FUSION-TotalTVaOS}         or
            when {&FUSION-ListeRubArtOS}      or when {&FUSION-ListeSSRubArtOS}   or when {&FUSION-ListeCodeFiscArtOS} or
            when {&FUSION-ListeDomaiArtOs}    or when {&FUSION-ListeLibelleArtOs}
            then do:
                if vlBloc2 then next boucleCHamp.
                vlBloc2 = true.
                for each dtord no-lock
                    where dtord.noord = piNumeroOS
                  , first inter no-lock
                    where inter.noint = dtord.noint:
                    find first intnt no-lock
                         where intnt.tpcon = inter.tpcon
                           and intnt.nocon = inter.nocon
                           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
                    assign
                        viNumeroTva                    = if dtord.cdtva = 0 then 30 else dtord.cdtva
                        vdMontantTotalInt[viNumeroTva] = vdMontantTotalInt[viNumeroTva] + dtord.mtint
                        viNumeroTvaMax                 = maximum(viNumeroTvaMax, viNumeroTva)
                    .
                    if integer(dtord.cdtva) = 0 
                    then assign
                        vcLibelleTva = ""
                        vdMontantTva = 0
                    .
                    else for first itaxe no-lock
                        where itaxe.soc-cd = mtoken:iCodeSociete
                          and itaxe.taxe-cd = dtord.cdtva:
                        assign
                            vcLibelleTva                 = string(itaxe.Taux) + "%"
                            vdMontantTva                 = (dtord.mtint * itaxe.Taux / 100)
                            vcLibelleTvaInt[viNumeroTva] = substitute("T O T A L   &1%", itaxe.taux)
                            vdMontantTvaInt[viNumeroTva] = vdMontantTvaInt[viNumeroTva] + vdMontantTva
                        .
                    end.
                    {&_proparse_ prolint-nowarn(use-when)}
                    assign
                        vcinfosArticle                 = donneInfosArticle(inter.cdart)
                        vcDateDebut                    = dateToCharacter(dtord.dtdeb) when vcDateDebut = ""
                        vcDateFin                      = dateToCharacter(dtord.dtfin) when vcDateFin   = ""
                        poFusionOS:ListeDesignationOS  = poFusionOS:ListeDesignationOS + string(dtord.lbint, "X(120)")                         + chr(10)
                        poFusionOS:ListeRefArticleOS   = poFusionOS:ListeRefArticleOS  + inter.cdart                                           + chr(10)
                        poFusionOS:ListeDtDebutOS      = poFusionOS:ListeDtDebutOS     + dateToCharacter(dtord.dtdeb)                          + chr(10)
                        poFusionOS:ListeDtFinOS        = poFusionOS:ListeDtFinOS       + dateToCharacter(dtord.dtfin)                          + chr(10)
                        poFusionOS:ListeQteOS          = poFusionOS:ListeQteOS         + montantToCharacter(dtord.qtint, false)                + chr(10)
                        poFusionOS:ListePUOS           = poFusionOS:ListePUOS          + montantToCharacter(dtord.pxuni, false)                + chr(10)
                        poFusionOS:ListeTxRemiseOS     = poFusionOS:ListeTxRemiseOS    + montantToCharacter(dtord.txrem, false)                + chr(10)
                        poFusionOS:ListMontantHTOS     = poFusionOS:ListMontantHTOS    + montantToCharacter(dtord.mtint, false)                + chr(10)
                        poFusionOS:ListeMontantOS      = poFusionOS:ListeMontantOS     + montantToCharacter(dtord.mtint + vdMontantTva, false) + chr(10)
                        poFusionOS:ListeTxTVAOS        = poFusionOS:ListeTxTVAOS       + vcLibelleTva                                          + chr(10)
                        poFusionOS:ListeTVAOS          = poFusionOS:ListeTVAOS         + montantToCharacter(vdMontantTva, false)               + chr(10)
                        poFusionOS:ListeCommentaireOS  = poFusionOS:ListeCommentaireOS + dtord.lbcom                                           + chr(10)
                        poFusionOS:ListeCleOs          = poFusionOS:ListeCleOs         + dtord.cdcle                                           + chr(10)
                        poFusionOS:ListeRubArtOs       = poFusionOS:ListeRubArtOs      + entry(1, vcInfosArticle, "#")                         + chr(10)
                        poFusionOS:ListeSSRubArtOs     = poFusionOS:ListeSSRubArtOs    + entry(2, vcInfosArticle, "#")                         + chr(10)
                        poFusionOS:ListeCodeFiscArtOs  = poFusionOS:ListeCodeFiscArtOs + entry(3, vcInfosArticle, "#")                         + chr(10)
                        poFusionOS:ListeDomaiArtOs     = poFusionOS:ListeDomaiArtOs    + entry(4, vcInfosArticle, "#")                         + chr(10)
                        poFusionOS:ListeLibelleArtOs   = poFusionOS:ListeLibelleArtOs  + entry(5, vcInfosArticle, "#")                         + chr(10)  /* SY 0416/0079 */
                    .
                    if available intnt
                    then poFusionOS:ListeCleLibelleOs = poFusionOS:ListeCleLibelleOs + getLibelleCle(intnt.noidt, inter.tpcon, inter.nocon, dtord.cdcle) + chr(10).
                end.

boucleTva:
                /* Total par rubrique de TVA */
                do viCompteur = 1 to viNumeroTvaMax:
                    assign
                        vdMontantHTTotal  = vdMontantHTTotal  + vdMontantTotalInt[viCompteur]
                        vdMontantTvaTotal = vdMontantTvaTotal + vdMontantTvaInt[viCompteur]
                    .
                end.
                assign
                    poFusionOS:DateDebutOS = vcDateDebut
                    poFusionOS:DateFinOS   = vcDateFin
                    poFusionOS:TotalTTCOS  = montantToCharacter(vdMontantHTTotal + vdMontantTvaTotal, false)
                    poFusionOS:TotalHTOS   = montantToCharacter(vdMontantHTTotal, false)
                    poFusionOS:TotalTVAOS  = montantToCharacter(vdMontantTvaTotal, false)
                .
            end.
        end case.
    end.
    if valid-handle(vhProclot) then run destroy in vhProclot.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
