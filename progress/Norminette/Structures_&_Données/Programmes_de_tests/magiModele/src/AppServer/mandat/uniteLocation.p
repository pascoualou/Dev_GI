/*------------------------------------------------------------------------
File        : uniteLocation.p
Purpose     : Unite de location du mandat de gérance
Author(s)   : SPo 2017/03/10
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2uniteLocation.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2fiche.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2voie.i}
{preprocesseur/type2adresse.i}

using parametre.pclie.parametrageMotifIndisponibilite.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/uniteLocation.i}
{mandat/include/coloc.i &nomTable=ttColoc}
{mandat/include/uniteAdresse.i}
{role/include/typeRole.i}
{adblib/include/unite.i}

function getUsageUL returns character private(pcNatureUL as character, pcCodeUsage as character):
    /*------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------*/
    define buffer usage for usage.

    for first usage no-lock
        where usage.ntapp = pcNatureUL
          and usage.cdusa = pcCodeUsage:
        return usage.lbusa.
    end.
    if pcCodeUsage > "" then for first usage no-lock
        where usage.ntapp = "00000"
          and usage.cdusa = pcCodeUsage:
        return usage.lbusa.
    end.
    return "".
end function.

procedure getListeUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose: Liste des UL (option : ULVACANTE)
    Notes  : service utilisé par beUniteLocation.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcVue                as character no-undo.
    define input  parameter pdaDateVacanteAu     as date      no-undo.
    define input  parameter plMandatInvestisseur as logical   no-undo.
    define output parameter table for ttUniteLocation.

    define variable viNoDernierLocataire   as int64   no-undo.
    define variable vdaDateEntreeLocataire as date    no-undo.
    define variable vdaDateSortieLocataire as date    no-undo.
    define variable vlULvacante            as logical no-undo.
    define variable viNombreLigne          as integer no-undo.
    define variable viNumeroMandatMini     as int64   no-undo.
    define variable viNumeroMandatMaxi     as int64   no-undo.
    define variable voMotifIndisponibilite as class parametrageMotifIndisponibilite no-undo.

    define buffer vbCtrat  for ctrat.
    define buffer ctrat    for ctrat.
    define buffer unite    for unite.
    define buffer cpuni    for cpuni.
    define buffer local    for local.
    define buffer tache    for tache.
    define buffer gl_fiche for gl_fiche.
    define buffer ladrs    for ladrs.
    define buffer adres    for adres.

    {&_proparse_ prolint-nowarn(when)}
    assign
        pdaDateVacanteAu       = today when pdaDateVacanteAu = ?
        plMandatInvestisseur   = false when plMandatInvestisseur = ?
        voMotifIndisponibilite = new parametrageMotifIndisponibilite()  // pour des raisons de performance, on instantie en dehors de la boucle, puis on "reload"
    .
boucleContratGerance:
    for each vbCtrat no-lock
        where vbCtrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and (vbCtrat.dtree = ? or vbCtrat.dtree > add-interval(today, -6, "MONTHS"))      /*  pour limiter la recherche */
          and vbCtrat.fgfloy = plMandatInvestisseur
      , each unite no-lock
        where unite.nomdt = vbCtrat.nocon
          and unite.noact = 0
          and unite.noapp <> {&TYPEUL-reserveProprietaire}
          and unite.noapp <> {&TYPEUL-lotNonAffecte}
        /*and unite.cdcmp <= {&NATUREUL-commerce}*/          /* hab ou com ET parking (contrairement à la Location ALLIANZ) */
      , first cpuni no-lock                        /* UL non vide */
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
      , first local no-lock
        where local.noimm = cpuni.Noimm
          and local.nolot = cpuni.nolot:
        /* Locataire */
        assign
            viNoDernierLocataire   = 0
            vdaDateEntreeLocataire = ?
            vdaDateSortieLocataire = ?
            vlULvacante            = false
            viNumeroMandatMaxi     = unite.nomdt * 100000 + unite.noapp * 100
            viNumeroMandatMini     = viNumeroMandatMaxi + 01
            viNumeroMandatMaxi     = viNumeroMandatMaxi + 99
            /* équivalent à ce qui précède, mais 5 fois plus lent !!
            viNumeroMandatMini     = int64(string(unite.nomdt, "99999") + string(unite.noapp, "999") + "01")
            viNumeroMandatMaxi     = int64(string(unite.nomdt, "99999") + string(unite.noapp, "999") + "99")
            */
        .
boucleContratBail:
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon >= viNumeroMandatMini
              and ctrat.nocon <= viNumeroMandatMaxi
              and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}     /* sans les baux spécial vacant */
              and ctrat.fgannul = false                             /* sans les baux annulés */
          , last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-quittancement}
            by ctrat.nocon:
            assign
                viNoDernierLocataire   = ctrat.nocon
                vdaDateEntreeLocataire = tache.dtdeb
                vdaDateSortieLocataire = tache.dtfin
            .
            leave boucleContratBail.
        end.
        if viNoDernierLocataire = 0 or vdaDateSortieLocataire <= pdaDateVacanteAu then vlULvacante = true.
        if pcVue = "ULVACANTE" and not vlULvacante then next boucleContratGerance.

        /* Recherche si Fiche commercialisation existe */
        find first gl_fiche no-lock
            where gl_fiche.tpcon    = vbCtrat.tpcon
              and gl_fiche.nocon    = vbCtrat.nocon
              and gl_fiche.noapp    = unite.noapp
              and gl_fiche.typfiche = {&TYPEFICHE-location} no-error.
        create ttUniteLocation.
        assign
            viNombreLigne                              = viNombreLigne + 1
            ttUniteLocation.CRUD                       = 'R'
            ttUniteLocation.cCodeTypeContrat           = vbCtrat.tpcon
            ttUniteLocation.iNumeroContrat             = vbCtrat.nocon
            ttUniteLocation.iNumeroAppartement         = unite.noapp
            ttUniteLocation.iNumeroMandant             = vbCtrat.norol
            ttUniteLocation.cNomMandant                = vbCtrat.lbnom
            ttUniteLocation.cNomCompletMandant         = vbCtrat.lnom2
            ttUniteLocation.iNumeroImmeuble            = cpuni.noimm
            ttUniteLocation.iNumeroLotPrincipal        = cpuni.nolot
            ttUniteLocation.iIdLotPrincipal            = local.noloc
            ttUniteLocation.cCodeNatureUL              = unite.cdcmp
            ttUniteLocation.cLibelleNatureUL           = outilTraduction:getLibelleParam("NTAPP", unite.cdcmp)
            ttUniteLocation.cCodeMotifIndisponibilite  = unite.cdmotindis
            ttUniteLocation.daDateDebutIndisponibilite = unite.dtdebindis
            ttUniteLocation.daDateFinIndisponibilite   = unite.dtfinindis
            ttUniteLocation.iNumeroContratBail         = viNoDernierLocataire
            ttUniteLocation.daDateEntree               = vdaDateEntreeLocataire
            ttUniteLocation.daDateSortie               = vdaDateSortieLocataire
            ttUniteLocation.iNumeroFicheCom            = if available gl_fiche then gl_fiche.nofiche else 0
            ttUniteLocation.iNoWorkFlowFicheCom        = if available gl_fiche then gl_fiche.noworkflow else 0
            ttUniteLocation.cLibelleWorkFlowFicheCom   = if ttUniteLocation.iNoWorkFlowFicheCom > 0 then outilTraduction:getLibelleParam("GLWFW", string(ttUniteLocation.iNoWorkFlowFicheCom, "99999")) else ""
            ttUniteLocation.dtTimestamp                = datetime(unite.dtmsy, unite.hemsy)
            ttUniteLocation.rRowid                     = rowid(unite)
        .
        /*  Recherche Motif d'Indisponibilité */
        if unite.cdmotindis > ""
        then do:
            voMotifIndisponibilite:reload(unite.cdmotindis).
            if voMotifIndisponibilite:isDbParameter then ttUniteLocation.cLibelleMotifIndisponibilite = voMotifIndisponibilite:getLibelleMotif().
        end.
        // surface totale et pondérée en m2
        run getSurfaceUniteLocation(rowid(unite), output ttUniteLocation.dSurfaceUtileULm2, output ttUniteLocation.dSurfacePondereULm2, output ttUniteLocation.iNombrePiece ).
        // adresse immeuble
        for first ladrs no-lock
            where ladrs.tpidt = {&TYPEBIEN-immeuble}
              and ladrs.noidt = ttUniteLocation.iNumeroImmeuble
              and ladrs.tpadr = {&TYPEADRESSE-Principale}
          , first adres no-lock
            where adres.noadr = ladrs.noadr:
            assign
                ttUniteLocation.cCodePostal     = trim(adres.cdpos)
                ttUniteLocation.cVille          = trim(adres.lbvil)
                ttUniteLocation.cAdresse        = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 0 /* ni ville, ni pays */)
                ttUniteLocation.cLibelleAdresse = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 3 /* ville et pays */)
            .
        end.
    end.
    delete object voMotifIndisponibilite.

end procedure.

procedure getUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose: Informations sur 1 UL
    Notes  : service utilisé par beUniteLocation.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat         as character no-undo.
    define input  parameter piNumeroContrat       as integer   no-undo.
    define input  parameter piNumeroUniteLocation as integer   no-undo.
    define output parameter table for ttUniteLocation.

    define variable viNoDernierLocataire   as int64   no-undo.
    define variable vdaDateEntreeLocataire as date    no-undo.
    define variable vdaDateSortieLocataire as date    no-undo.
    define variable viNombreLigne          as integer no-undo.
    define variable viNoLotPrincipal       as integer no-undo.
    define variable viIdNoLocal            as integer no-undo.
    define variable viNumeroMandatMini     as int64   no-undo.
    define variable viNumeroMandatMaxi     as int64   no-undo.
    define variable voMotifIndisponibilite as class parametrageMotifIndisponibilite no-undo.

    define buffer vbCtrat  for ctrat.
    define buffer ctrat    for ctrat.
    define buffer unite    for unite.
    define buffer cpuni    for cpuni.
    define buffer local    for local.
    define buffer tache    for tache.
    define buffer intnt    for intnt.
    define buffer gl_fiche for gl_fiche.
    define buffer etxdt    for etxdt.

    voMotifIndisponibilite = new parametrageMotifIndisponibilite().  // pour des raisons de performance, on instantie en dehors de la boucle, puis on "reload"
    for each vbCtrat no-lock
        where vbCtrat.tpcon = pcTypeContrat
          and vbCtrat.nocon = piNumeroContrat
      , first intnt no-lock
        where intnt.tpcon = vbCtrat.tpcon
          and intnt.nocon = vbCtrat.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , each unite no-lock
        where unite.nomdt = vbCtrat.nocon
          and unite.noapp = (if piNumeroUniteLocation > 0 then piNumeroUniteLocation else unite.noapp)
          and unite.noact = 0:
        assign
            viNoLotPrincipal       = 0
            viIdNoLocal            = 0
            viNoDernierLocataire   = 0
            vdaDateEntreeLocataire = ?
            vdaDateSortieLocataire = ?
            viNumeroMandatMaxi     = unite.nomdt * 100000 + unite.noapp * 100
            viNumeroMandatMini     = viNumeroMandatMaxi + 01
            viNumeroMandatMaxi     = viNumeroMandatMaxi + 99
        .
        for first cpuni no-lock                        /* UL non vide */
            where cpuni.nomdt = unite.nomdt
              and cpuni.noapp = unite.noapp
              and cpuni.nocmp = unite.nocmp
          , first local no-lock
            where local.noimm = cpuni.Noimm
              and local.nolot = cpuni.nolot:
            assign
                viNoLotPrincipal = local.nolot
                viIdNoLocal      = local.noloc
            .
        end.
        /* Locataire */
boucleContratBail:
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon >= viNumeroMandatMini
              and ctrat.nocon <= viNumeroMandatMaxi
              and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}     /* sans les baux spécial vacant */
              and ctrat.fgannul = false                             /* sans les baux annulés */
          , last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-quittancement}
            by ctrat.nocon:
            assign
                viNoDernierLocataire   = ctrat.nocon
                vdaDateEntreeLocataire = tache.dtdeb
                vdaDateSortieLocataire = tache.dtfin
            .
            leave boucleContratBail.
        end.
        /* Recherche si Fiche commercialisation existe */
        find first gl_fiche no-lock
            where gl_fiche.tpcon    = vbCtrat.tpcon
              and gl_fiche.nocon    = vbCtrat.nocon
              and gl_fiche.noapp    = unite.noapp
              and gl_fiche.typfiche = {&TYPEFICHE-location} no-error.
        create ttUniteLocation.
        assign
            viNombreLigne                              = viNombreLigne + 1
            ttUniteLocation.CRUD                       = 'R'
            ttUniteLocation.cCodeTypeContrat           = vbCtrat.tpcon
            ttUniteLocation.iNumeroContrat             = vbCtrat.nocon
            ttUniteLocation.iNumeroAppartement         = unite.noapp
            ttUniteLocation.iNumeroComposition         = unite.nocmp
            ttUniteLocation.iNumeroMandant             = vbCtrat.norol
            ttUniteLocation.iNumeroImmeuble            = intnt.noidt
            ttUniteLocation.iNumeroLotPrincipal        = viNoLotPrincipal
            ttUniteLocation.iIdLotPrincipal            = viIdNoLocal
            ttUniteLocation.cCodeNatureUL              = unite.cdcmp
            ttUniteLocation.cLibelleNatureUL           = outilTraduction:getLibelleParam("NTAPP", unite.cdcmp)
            ttUniteLocation.cCodeUsage                 = unite.cdusa
            ttUniteLocation.cLibelleUsage              = getUsageUL (unite.cdcmp ,unite.cdusa)
            ttUniteLocation.daDateDebutComposition     = unite.dtdeb
            ttUniteLocation.daDateFinComposition       = unite.dtfin
            ttUniteLocation.cCodeMotifIndisponibilite  = unite.cdmotindis
            ttUniteLocation.daDateDebutIndisponibilite = unite.dtdebindis
            ttUniteLocation.daDateFinIndisponibilite   = unite.dtfinindis
            ttUniteLocation.cCodeOccupation            = unite.cdocc
            ttUniteLocation.cLibelleOccupation         = outilTraduction:getLibelleParam("NTOCC", unite.cdocc)
            ttUniteLocation.iNumeroContratBail         = viNoDernierLocataire
            ttUniteLocation.daDateEntree               = vdaDateEntreeLocataire
            ttUniteLocation.daDateSortie               = vdaDateSortieLocataire
            ttUniteLocation.iNumeroFicheCom            = if available gl_fiche then gl_fiche.nofiche else 0
            ttUniteLocation.dtTimestamp                = datetime(unite.dtmsy, unite.hemsy)
            ttUniteLocation.rRowid                     = rowid(unite)
        .
        /*  Recherche Motif d'Indisponibilité */
        if unite.cdmotindis > ""
        then do:
            voMotifIndisponibilite:reload(unite.cdmotindis).
            if voMotifIndisponibilite:isDbParameter then ttUniteLocation.cLibelleMotifIndisponibilite = voMotifIndisponibilite:getLibelleMotif().
        end.
        // surface totale et pondérée en m2
        run getSurfaceUniteLocation(rowid(unite), output ttUniteLocation.dSurfaceUtileULm2, output ttUniteLocation.dSurfacePondereULm2, output ttUniteLocation.iNombrePiece ).
        // recherche s'il existe un loi de défiscalisation sur le lot principal
        for first etxdt no-lock
            where etxdt.notrx = vbCtrat.nocon
              and etxdt.tpapp = "00000"
              and etxdt.noapp = 0
              and etxdt.nolot = viIdNoLocal:
            ttUniteLocation.cLibelleLoiLotIRF = outilTraduction:getLibelleParam("CDLOI", etxdt.lbdiv3).
        end.
    end.
    delete object voMotifIndisponibilite.

end procedure.

procedure getSurfaceUniteLocation private:
    /*------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------*/
    define input  parameter prowidUnite      as rowid   no-undo.
    define output parameter pdSurfaceUtile   as decimal no-undo.
    define output parameter pdSurfacePondere as decimal no-undo.
    define output parameter piNombrePiece    as integer no-undo.

    define variable vdSfTotUtile    as decimal no-undo.
    define variable vdSfTotPonderee as decimal no-undo.
    define variable viNombrePiece   as integer no-undo.

    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer local for local.

    /* surface (c.f. event/bail.p) */
    assign
        vdSfTotUtile = 0
        vdSfTotPonderee = 0
    .
    for first unite no-lock
        where rowid(unite) = prowidUnite
      , each cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
      , first local no-lock
        where local.noimm = cpuni.noimm
          and local.nolot = cpuni.nolot:
        assign
            viNombrePiece   = viNombrePiece + local.nbprf
            vdSfTotPonderee = vdSfTotPonderee + outilFormatage:convSurface(local.sfpde, local.uspde)
            vdSfTotUtile    = vdSfTotUtile + if Local.fgdiv then cpuni.sflot else outilFormatage:convSurface(local.sfree, local.usree)
        .
    end.
    assign
        pdSurfaceUtile   = vdSfTotUtile
        pdSurfacePondere = vdSfTotPonderee
        piNombrePiece    = viNombrePiece
    .
end procedure.

procedure getAdresseUnite:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie l'adresse d'une unité de location
    Notes  : pas utilisé.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroUnite   as integer no-undo.
    define input  parameter piNumeroContrat as integer no-undo.
//  define output parameter table for ttAdresseUnite.

    define buffer unite for unite.
    define buffer intnt for intnt.
    define buffer ladrs for ladrs.
    define buffer adres for adres.

    for first unite no-lock
        where unite.noapp = piNumeroUnite
          and unite.nomdt = piNumeroContrat
      , first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = Unite.nomdt
      , first ladrs no-lock
        where ladrs.tpidt = {&TYPEBIEN-immeuble}
          and ladrs.noidt = intnt.noidt
          and ladrs.tpadr = {&TYPEADRESSE-Principale}
      , first adres no-lock
        where adres.noadr = ladrs.noadr:
        create ttAdresseUnite.
        assign
            ttAdresseUnite.CRUD                = 'R'
            ttAdresseUnite.iNumeroContrat      = unite.nomdt
            ttAdresseUnite.itypebranche        = 3
            ttAdresseUnite.cTypeIdentifiant    = {&TYPEBIEN-immeuble}
            ttAdresseUnite.cCodeNumeroBis      = ladrs.cdadr
            ttAdresseUnite.cLibelleNumeroBis   = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr)
            ttAdresseUnite.cCodeTypeAdresse    = ladrs.tpadr
            ttAdresseUnite.cLibelleTypeAdresse = outilTraduction:getLibelleParam("TPADR", ladrs.tpadr)
            ttAdresseUnite.cNumeroVoie         = trim(ladrs.novoi)
            ttAdresseUnite.cComplementVoie     = if ladrs.cdadr = "00000" then "" else outilTraduction:getLibelleParam("TPADR", ladrs.tpadr)
            ttAdresseUnite.iNumeroAdresse      = adres.noadr
            ttAdresseUnite.cNatureVoie         = adres.ntvoi
            ttAdresseUnite.cLibelleNatureVoie  = if adres.ntvoi = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", adres.ntvoi)
            ttAdresseUnite.cLibelleVoie        = trim(adres.lbvoi)
            ttAdresseUnite.cComplementAdresse  = trim(adres.cpvoi)
            ttAdresseUnite.cCodePostal         = trim(adres.cdpos)
            ttAdresseUnite.cVille              = trim(adres.lbvil)
            ttAdresseUnite.cCodePays           = adres.cdpay
            ttAdresseUnite.cLibellePays        = outilTraduction:getLibelleParam("CDPAY", adres.cdpay)
            ttAdresseUnite.cLibelle            = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 0 /* ni ville, ni pays */)
            ttAdresseUnite.dtTimestampAdres    = datetime(adres.dtmsy, adres.hemsy)
            ttAdresseUnite.dtTimestampLadrs    = datetime(ladrs.dtmsy, ladrs.hemsy)
            ttAdresseUnite.rRowid              = rowid(adres)
         .
    end.

end procedure.

procedure getListeColoc:
    /*------------------------------------------------------------------------
    Purpose: Liste des colocataires d'un contrat
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeRole      as character no-undo.
    define input parameter pcNumeroRole    as character no-undo.
    define input parameter table for ttTypeRole.
    define output parameter table for ttColoc.

    empty temp-table ttColoc.
    run getColocation(pcTypeContrat, piNumeroContrat, pcTypeRole, pcNumeroRole).

end procedure.

procedure getColocation private:
    /*------------------------------------------------------------------------
    Purpose: Liste des colocataires d'un contrat
    Notes  :
    ------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeRole      as character no-undo.
    define input parameter pcNumeroRole    as character no-undo.

    define buffer coloc   for coloc.
    define buffer vbRoles for roles.
    define buffer ctctt   for ctctt.

    if pcTypeContrat = {&TYPECONTRAT-bail}
    then for each coloc no-lock
        where coloc.tpcon = pcTypeContrat
          and coloc.nocon = piNumeroContrat
          and coloc.noqtt = 0
      , first vbRoles no-lock
        where vbRoles.tprol = coloc.tpidt
          and vbRoles.norol = coloc.noidt:
        find first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2gerance}
              and ctctt.tpct2 = coloc.tpcon
              and ctctt.noct2 = coloc.nocon no-error.
        create ttColoc.
        assign
            ttColoc.iNumeroTiers    = vbRoles.notie
            ttColoc.cTypeRole       = vbRoles.tprol
            ttColoc.cNumeroRole     = trim(string(vbRoles.norol, ">>>>>99999"))
            ttColoc.cTypeContrat    = coloc.tpcon
            ttColoc.iNumeroContrat  = coloc.nocon
            ttColoc.cAdresseTiers   = outilFormatage:formatageAdresse(vbRoles.tprol, vbRoles.norol)
            ttColoc.cLibelleTiers   = outilFormatage:getNomTiers(vbRoles.tprol, vbRoles.norol)
            ttColoc.lSelection      = (vbRoles.tprol = pcTypeRole and vbRoles.norol = int64(pcNumeroRole))
        .
        for first ttTypeRole where ttTypeRole.cTypeRole = ttColoc.cTypeRole:
            ttColoc.cLibelleTypeRole  = ttTypeRole.cLibelleTypeRole.
        end.
    end.

end procedure.

procedure majIndisponibiliteUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose: maj information indisponibilité sur l'unite (
             (pour renseigner ces informations plus simplement en commercialisation)
    Notes  : service utilisé par beUniteLocation.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttUniteLocation.

    define buffer unite for unite.
    define buffer tache for tache.
    define buffer ctrat for ctrat.

    for each ttUniteLocation
        where ttUniteLocation.CRUD = "U"
      , first unite exclusive-lock
        where unite.nomdt = ttUniteLocation.iNumeroContrat
          and unite.noact = 0
          and unite.noapp = ttUniteLocation.iNumeroAppartement:

        if ttUniteLocation.daDateDebutIndisponibilite <> ?
        and ttUniteLocation.daDateFinIndisponibilite <> ?
        and ttUniteLocation.daDateDebutIndisponibilite > ttUniteLocation.daDateFinIndisponibilite
        then do:
            mError:createError({&error}, "Date début indisponinilité > à date de fin").  // todo: traduction
            return.
        end.
        if ttUniteLocation.daDateDebutIndisponibilite <> ?
        then do:
            for last tache no-lock
               where tache.tpcon = {&TYPECONTRAT-bail}
                 and tache.nocon = unite.norol
                 and tache.tptac = {&TYPETACHE-quittancement}:
                if ttUniteLocation.daDateDebutIndisponibilite < tache.dtfin
                then do:
                    mError:createError({&error}, "Il y a chevauchement entre la date de sortie du locataire et la date d'indisponibilité").
                    return.
                end.
            end.
            for first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-bail}
                  and ctrat.nocon = unite.norol:
                if ttUniteLocation.daDateDebutIndisponibilite < ctrat.dtree
                then do:
                    mError:createError({&error}, "Il y a chevauchement entre la date de résiliation du bail et la date d'indisponibilité").
                    return.
                end.
            end.
        end.
        assign
            unite.cdmotindis = ttUniteLocation.cCodeMotifIndisponibilite
            unite.dtdebindis = ttUniteLocation.daDateDebutIndisponibilite
            unite.dtfinindis = ttUniteLocation.daDateFinIndisponibilite
        .
    end.

end procedure.

procedure setNatureUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose: correspond a changement nature UL
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttUniteLocation.

    define variable vhProc   as handle  no-undo.

    bloc-maj:
    for each ttUniteLocation
        where ttUniteLocation.CRUD = "U":
        empty temp-table ttUnite.
        create ttUnite.
        assign
            ttUnite.nomdt       = ttUniteLocation.iNumeroContrat
            ttUnite.noapp       = ttUniteLocation.iNumeroAppartement
            ttUnite.noact       = ttUniteLocation.iCodeActif
            ttUnite.cdcmp       = ttUniteLocation.cCodeNatureUL
            ttUnite.CRUD        = ttUniteLocation.CRUD
            ttUnite.dtTimestamp = ttUniteLocation.dtTimestamp
            ttUnite.rRowid      = ttUniteLocation.rRowid
        .
        if not valid-handle(vhProc)
        then do:
            run adblib/unite_CRUD.p persistent set vhproc.
            run getTokenInstance in vhproc(mToken:JSessionId).
        end.
        run setUnite in vhproc(table ttUnite by-reference).
        if mError:erreur() = yes
        then leave bloc-maj.
    end.
    if valid-handle(vhProc) then run destroy in vhproc.

end procedure.

procedure setLotPrincipalUniteLocation:
    /*------------------------------------------------------------------------------
    Purpose: correspond a changement du lot principal
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
/*
    define input parameter table for ttUniteLocation.
    define input parameter table for ttCompositionUnite.

    define variable vhProcUnite  as handle  no-undo.
    define variable vhProcCpuni  as handle  no-undo.
    define variable vlRetour     as logical no-undo.
    define variable viNouvLotPrc as integer no-undo.
    define variable viAncLotPrc  as integer no-undo.

//gga toto en attente voir avec Nicolas comment gerer cet inversion de numero d'ordre entre 2 lots

    bloc-maj:
    for each ttCompositionUnite
       where ttCompositionUnite.CRUD = "U":
    end.
*/
end procedure.
