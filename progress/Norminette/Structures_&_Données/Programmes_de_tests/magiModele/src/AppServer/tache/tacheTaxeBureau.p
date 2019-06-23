/*------------------------------------------------------------------------
File        : tacheTaxeBureau.p
Purpose     : taxe sur les bureaux
Author(s)   : GGA - 2018/01/02
Notes       : a partir de adb/tach/prmmttxb.p 
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/type2honoraire.i}

using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{tache/include/tache.i}
{adblib/include/cttac.i}
{adblib/include/local.i}
{tache/include/tacheTaxeBureau.i}
{application/include/glbsepar.i}

function numeroImmeuble return integer private(piNumeroMandat as int64, pcTypeMandat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    find first intnt no-lock
         where intnt.tpcon = pcTypeMandat
           and intnt.nocon = piNumeroMandat
           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
    if not available intnt
    then do:
        mError:createErrorGestion({&error}, 106470, string(piNumeroMandat)). //immeuble non trouve pour mandat %1
        return 0.
    end.
    return intnt.noidt.
end function.

function nomOrganisme return character private (pcTypeOrganisme as character, pcCodeOrganisme as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche nom organisme social
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer orsoc for orsoc.

    for first orsoc no-lock
        where orsoc.tporg = pcTypeOrganisme
          and orsoc.ident = pcCodeOrganisme
          and orsoc.mssup = 0:
        return orsoc.lbnom.
    end.
    return "???".
end function.

procedure getTaxeBureau:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piPeriode      as integer   no-undo.
    define output parameter table for ttTacheTaxeBureau.
    define output parameter table for ttULTaxeBureau.
    define output parameter table for ttSurfaceTaxeBureau.

    define variable viNumeroImmeuble as integer   no-undo.

    define buffer ctrat for ctrat.
    define buffer txbet for txbet.

    empty temp-table ttTacheTaxeBureau.
    empty temp-table ttULTaxeBureau.
    empty temp-table ttSurfaceTaxeBureau.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    viNumeroImmeuble = numeroImmeuble(piNumeroMandat, pcTypeMandat).
    if mError:erreur() then return.

    if not can-find(first garan no-lock
                    where garan.tpctt = "01011"
                      and garan.NoBar = 0
                      and garan.noctt = piPeriode) then do:
        mError:createErrorGestion({&error}, 1000411, string(piPeriode)). //exercice %1 inexistant dans paramètre taxe bureau
        return.
    end.

/*
    find last garan no-lock
        where garan.tpctt = "01011"
          and garan.tpbar = "00001"
          and garan.nobar <> 0
          and garan.txcot <> 0
          and garan.noctt = NoExoEnc no-error.
    if not available garan
    then find last garan no-lock
             where garan.tpctt = "01011"
               and garan.tpbar = "00001"
               and garan.nobar <> 0
               and garan.txcot <> 0 no-error.
    if not available garan
    then do:
        mError:createError({&error}, 103514).
        return.
    end.
*/


    /*--> tester s'il y a eu déjà comptabilisation */
    if can-find(first txbdt no-lock
                where txbdt.noimm = viNumeroImmeuble
                  and txbdt.annee = piPeriode
                  and txbdt.NoMan = ctrat.norol) then do:
        find first txbet no-lock                      //lecture enregistrement entete taxe bureau
             where txbet.noimm = viNumeroImmeuble
               and txbet.annee = piPeriode
               and txbet.noman = ctrat.norol no-error.
        if not available txbet then do:
            mError:createErrorGestion({&error}, 1000416, string(piPeriode)). //exercice %1 comptabilisé, entête taxe bureau inexistant dans historique (table txbet)
            return.
        end.
        run lectureInfoPeriodeComptabilise(ctrat.tpcon, ctrat.norol, viNumeroImmeuble, piPeriode).
        run lectureInfoTache(ctrat.tpcon, ctrat.nocon, piPeriode, yes, viNumeroImmeuble).
        for first ttTacheTaxeBureau:                   //on efface les infos par les infos de l'enregistrement entete taxe bureau
            assign
                ttTacheTaxeBureau.cCentrePaiement           = txbet.ctpai
                ttTacheTaxeBureau.cLibelleCentrePaiement    = nomOrganisme("OTB", txbet.ctpai)
                ttTacheTaxeBureau.cCentreDeclaration        = txbet.ctdec
                ttTacheTaxeBureau.cLibelleCentreDeclaration = nomOrganisme("CDI", txbet.ctdec)
            .
        end.
    end.
    else do:
        run lectureInfoUniteLocation(ctrat.tpcon, ctrat.norol, viNumeroImmeuble, piPeriode).
        run lectureInfoTache(ctrat.tpcon, ctrat.nocon, piPeriode, no, viNumeroImmeuble).
        run lectureInfoSurface.
    end.

end procedure.

procedure setTaxeBureau:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheTaxeBureau.
    define input parameter table for ttULTaxeBureau.
    define input parameter table for ttSurfaceTaxeBureau.

    for first ttTacheTaxeBureau
        where lookup(ttTacheTaxeBureau.CRUD, "U,D") > 0:
        run verZonSai.
        if not mError:erreur() then run majTacheEtSurface.
    end.
end procedure.

procedure lectureInfoTache private:
    /*------------------------------------------------------------------------------
    Purpose: lecture des informations de la tache pour l'exercice
             creation a vide de l'enregistrement ttTacheTaxeBureau et ensuite on recherche le premier enregistrement
             tache pour les contrats du mandant / immeuble pour completer les informations.
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  pcTypeMandat   as character no-undo.
    define input parameter  piNumeroMandat as int64     no-undo.
    define input parameter  piPeriode      as integer   no-undo.
    define input parameter  plComptabilise as logical   no-undo.
    define input parameter  piImmeuble     as integer   no-undo.

    define buffer tache   for tache.
    define buffer vbroles for roles.
    define buffer ctanx   for ctanx.

    create ttTacheTaxeBureau.
    assign
        ttTacheTaxeBureau.iPeriode        = piPeriode
        ttTacheTaxeBureau.lComptabilise   = plComptabilise
        ttTacheTaxeBureau.cTypeContrat    = pcTypeMandat
        ttTacheTaxeBureau.iNumeroImmeuble = piImmeuble
        ttTacheTaxeBureau.cTypeTache      = {&TYPETACHE-taxeSurBureau}
        ttTacheTaxeBureau.CRUD            = 'R'
    .
rechercheTache:
    for each ttULTaxeBureau
      , first tache no-lock
        where tache.tptac = {&TYPETACHE-taxeSurBureau}
          and tache.notac = piPeriode
          and tache.tpcon = pcTypeMandat
          and tache.nocon = ttULTaxeBureau.iNumeroContrat:
        assign
            ttTacheTaxeBureau.cZone                     = string(tache.duree, "99999")
            ttTacheTaxeBureau.cLibelleZone              = outilTraduction:getLibelleParam("TPZON", ttTacheTaxeBureau.cZone)
            ttTacheTaxeBureau.cCentrePaiement           = tache.utreg
            ttTacheTaxeBureau.cLibelleCentrePaiement    = nomOrganisme("OTB", tache.utreg)
            ttTacheTaxeBureau.cCentreDeclaration        = tache.dcreg
            ttTacheTaxeBureau.cLibelleCentreDeclaration = nomOrganisme("CDI", tache.dcreg)
            ttTacheTaxeBureau.cNoSie01                  = substring(tache.nosie, 1, 3, 'character')
            ttTacheTaxeBureau.cNoSie02                  = substring(tache.nosie, 4, 2, 'character')
            ttTacheTaxeBureau.cNoSie03                  = substring(tache.nosie, 6, 2, 'character')
            ttTacheTaxeBureau.iNoDossier                = integer(tache.dossier)
            ttTacheTaxeBureau.iNoCle                    = integer(tache.nocle)
            ttTacheTaxeBureau.iCodeCdir                 = integer(tache.cdir)
            ttTacheTaxeBureau.iCodeService              = integer(tache.service)
        .
        leave rechercheTache.
    end.

end procedure.

procedure lectureInfoUniteLocation private:
    /*------------------------------------------------------------------------------
    Purpose: chargement table des unites de location
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat as character no-undo.
    define input parameter piMandant    as int64     no-undo.
    define input parameter piImmeuble   as integer   no-undo.
    define input parameter piPeriode    as integer   no-undo.

    define variable vdaDebutPeriode  as date      no-undo.
    define variable viComposition    as integer   no-undo.
    define variable viNumeroOccupant as integer   no-undo.
    define variable vcTypeOccupant   as character no-undo.
    define variable viI              as integer   no-undo.
    define variable vcTempo          as character no-undo.

    define buffer unite   for unite.
    define buffer vbunite for unite.
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer tache   for tache.
    define buffer ctrat   for ctrat.

    vdaDebutPeriode = date(01, 01, piPeriode).                       // Date de début exercice = 1er Janvier
    for each vbintnt no-lock
       where vbintnt.tpcon = pcTypeMandat
         and vbintnt.tpidt = {&TYPEROLE-mandant}
         and vbintnt.noidt = piMandant
    , first intnt no-lock
      where intnt.tpcon = vbintnt.tpcon
        and intnt.nocon = vbintnt.nocon
        and intnt.tpidt = {&TYPEBIEN-immeuble}
        and intnt.noidt = piImmeuble
    , each unite no-lock
     where unite.nomdt = vbintnt.nocon
       and unite.noact = 0
    break by unite.noapp:

        /* on affiche les UL dont la compo active est antérieure a l'exercice en cours */
        /* la taxe sur les bureaux est établie au 1er janvier de l'exercice */
        viComposition = unite.nocmp.
        for first vbunite no-lock
            where vbunite.nomdt = unite.nomdt
              and vbunite.noapp = unite.noapp
              and vbunite.dtdeb > vdaDebutPeriode:
            viComposition = if vbunite.nocmp > 10 then vbunite.nocmp - 1 else 0.
        end.
        for first cpuni no-lock
            where cpuni.nomdt = unite.nomdt
              and cpuni.noapp = unite.noapp
              and cpuni.nocmp = viComposition:
            create ttULTaxeBureau.
            assign
                ttULTaxeBureau.iNumeroContrat  = unite.nomdt
                ttULTaxeBureau.iNumeroImmeuble = unite.noimm
                ttULTaxeBureau.iNumeroUL       = unite.noapp
                ttULTaxeBureau.iComposition    = cpuni.nocmp
                ttULTaxeBureau.cTypeTarif      = "00001"              //Tarif normal par defaut si pas de tarif au niveau de la tache
            .
            for first tache no-lock
                where tache.tptac = {&TYPETACHE-taxeSurBureau}
                  and tache.notac = piPeriode
                  and tache.tpcon = pcTypeMandat
                  and tache.nocon = ttULTaxeBureau.iNumeroContrat:
                do viI = 1 to num-entries(tache.lbdiv, '#'):
                    vcTempo = entry(viI, tache.lbdiv,"#").
                    if unite.noapp = integer(entry(1, vcTempo, "@")) and num-entries(vcTempo, "@") >= 4
                    then ttULTaxeBureau.cTypeTarif = entry(4, vcTempo, "@").
                end.
            end.
            ttULTaxeBureau.cLibelleTypeTarif = outilTraduction:getLibelleParam("TPTAR", ttULTaxeBureau.cTypeTarif).
            /* recherche de l'occupant */
            /* Modif SY le 02/03/2010 - 0210/0197 : au 1er janvier en tenant compte de ses vrais dates entrée/sortie */
            assign
                vcTypeOccupant   = ""
                viNumeroOccupant = 0
            .
            if unite.noapp = 997
            then assign
                     vcTypeOccupant   = {&TYPEROLE-mandant}
                     viNumeroOccupant = vbintnt.noidt
            .
            else
            if unite.noapp <> 998
            then for each ctrat no-lock /* Modif SY le 02/03/2010 : chercher le locataire présent au 1er janvier de l'exercice */
                    where ctrat.tpcon = {&TYPECONTRAT-bail}
                      and ctrat.nocon >= integer(string(unite.nomdt, "99999") + string(unite.noapp , "999") + "01")
                      and ctrat.nocon <= integer(string(unite.nomdt, "99999") + string(unite.noapp , "999") + "99")
                 , last tache no-lock
                  where tache.tpcon = ctrat.tpcon
                    and tache.nocon = ctrat.nocon
                    and tache.tptac = {&TYPETACHE-quittancement}
                    and tache.dtdeb <= vdaDebutPeriode
                    and (tache.dtfin = ? or (tache.dtfin <> ? and tache.dtfin >= vdaDebutPeriode)):
                assign
                    vcTypeOccupant   = ctrat.tprol
                    viNumeroOccupant = ctrat.norol
                .
            end.
            if vcTypeOccupant > "" and viNumeroOccupant <> 0
            then ttULTaxeBureau.cOccupant = outilFormatage:getNomTiers(vcTypeOccupant, viNumeroOccupant).
            else ttULTaxeBureau.cOccupant = outilTraduction:getLibelle(700358).                        // vacant
        end.

    end.

end procedure.

procedure lectureInfoPeriodeComptabilise private:
    /*------------------------------------------------------------------------------
    Purpose: lecture des informations pour une periode deja comptabilise
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat as character no-undo.
    define input parameter piMandant    as int64     no-undo.
    define input parameter piImmeuble   as integer   no-undo.
    define input parameter piPeriode    as integer   no-undo.
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer txbdt   for txbdt.

    for each vbintnt no-lock
       where vbintnt.tpcon = pcTypeMandat
         and vbintnt.tpidt = {&TYPEROLE-mandant}
         and vbintnt.noidt = piMandant
    , first intnt no-lock
      where intnt.tpcon = vbintnt.tpcon
        and intnt.nocon = vbintnt.nocon
        and intnt.tpidt = {&TYPEBIEN-immeuble}
        and intnt.noidt = piImmeuble
    , each txbdt no-lock
     where txbdt.annee = piPeriode
       and txbdt.noimm = piImmeuble
       and txbdt.noman = vbintnt.noidt
       and txbdt.nomdt = vbintnt.nocon
    break by txbdt.noulo:
        create ttSurfaceTaxeBureau.
        assign
            ttSurfaceTaxeBureau.iNumeroUL             = txbdt.noulo
            ttSurfaceTaxeBureau.iNumeroLot            = txbdt.noLot
            ttSurfaceTaxeBureau.iNumeroContrat        = txbdt.nomdt
            ttSurfaceTaxeBureau.iNumeroImmeuble       = txbdt.noimm
            ttSurfaceTaxeBureau.iComposition          = 0
            ttSurfaceTaxeBureau.lDivisible            = ?
            ttSurfaceTaxeBureau.dSurfaceBureau        = txbdt.sfbur
            ttSurfaceTaxeBureau.dSurfaceCommerciale   = txbdt.sfcom
            ttSurfaceTaxeBureau.dSurfaceStockage      = txbdt.sfstk
            ttSurfaceTaxeBureau.dSurfaceStationnement = (if txbdt.sfpkg <> 0 then txbdt.sfpkg else decimal(entry(1, txbdt.lbdiv, separ[1])))
            ttSurfaceTaxeBureau.dSurfaceExpo          = 0
            ttSurfaceTaxeBureau.dtTimestamp           = datetime(txbdt.dtmsy, txbdt.hemsy)
            ttSurfaceTaxeBureau.CRUD                  = "R"
            ttSurfaceTaxeBureau.rRowid                = rowid(txbdt)
        .
        if last-of(txbdt.noulo)
        then do:
            create ttULTaxeBureau.
            assign
                ttULTaxeBureau.iNumeroContrat        = txbdt.nomdt
                ttULTaxeBureau.iNumeroImmeuble       = txbdt.noimm
                ttULTaxeBureau.iNumeroUL             = txbdt.noulo
                ttULTaxeBureau.iComposition          = 0
                ttULTaxeBureau.cTypeTarif            = txbdt.tpbar
                ttULTaxeBureau.cLibelleTypeTarif     = outilTraduction:getLibelleParam("TPTAR", ttULTaxeBureau.cTypeTarif)
                ttULTaxeBureau.dSurfaceNormale       = 0
                ttULTaxeBureau.dSurfaceReduite       = 0
                ttULTaxeBureau.dSurfaceCommerciale   = 0
                ttULTaxeBureau.dSurfaceStockage      = 0
                ttULTaxeBureau.dSurfaceStationnement = 0
                ttULTaxeBureau.dSurfaceExpo          = 0
            .
            if txbdt.noulo = 997
            then ttULTaxeBureau.cOccupant = outilFormatage:getNomTiers({&TYPEROLE-mandant}, txbdt.noman).
            else do:
                if txbdt.noloc = 0
                then outilTraduction:getLibelle(700358).                        // vacant
                else outilFormatage:getNomTiers("00019", txbdt.noloc).
            end.
        end.
    end.

end procedure.

procedure lectureInfoSurface private:
    /*------------------------------------------------------------------------------
    Purpose: chargement table surface
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdSfStationnement as decimal no-undo.

    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer local for local.

    for each ttULTaxeBureau
    , first unite no-lock
      where unite.nomdt = ttULTaxeBureau.iNumeroContrat
        and unite.NoApp = ttULTaxeBureau.iNumeroUL
        and unite.nocmp = ttULTaxeBureau.iComposition
    , each cpuni no-lock
     where cpuni.nomdt = unite.nomdt
       and cpuni.noapp = unite.noapp
       and cpuni.nocmp = unite.nocmp
    , first local no-lock
      where local.noimm = cpuni.noimm
        and local.nolot = cpuni.nolot:

        vdSfStationnement = (if local.sfpkg <> 0 then local.sfpkg else decimal(entry(1, local.cddev, separ[1]))).
        if not can-find(first ttSurfaceTaxeBureau
                        where ttSurfaceTaxeBureau.iNumeroContrat = cpuni.nomdt
                          and ttSurfaceTaxeBureau.iNumeroUL      = cpuni.noapp
                          and ttSurfaceTaxeBureau.iNumeroLot     = local.nolot)
        then do:
            create ttSurfaceTaxeBureau.
            assign
                ttSurfaceTaxeBureau.iNumeroUL       = cpuni.noapp
                ttSurfaceTaxeBureau.iNumeroLot      = local.nolot
                ttSurfaceTaxeBureau.iNumeroContrat  = cpuni.nomdt
                ttSurfaceTaxeBureau.iNumeroImmeuble = unite.noimm
                ttSurfaceTaxeBureau.iComposition    = cpuni.nocmp
                ttSurfaceTaxeBureau.lDivisible      = local.fgdiv
                ttSurfaceTaxeBureau.dtTimestamp     = datetime(local.dtmsy, local.hemsy)
                ttSurfaceTaxeBureau.CRUD            = "R"
                ttSurfaceTaxeBureau.rRowid          = rowid(local)
            .
            if not local.fgdiv
            then assign
                     ttSurfaceTaxeBureau.dSurfaceBureau        = local.sfbur
                     ttSurfaceTaxeBureau.dSurfaceCommerciale   = local.sfcom
                     ttSurfaceTaxeBureau.dSurfaceStockage      = local.sfstk
                     ttSurfaceTaxeBureau.dSurfaceStationnement = vdSfStationnement
                     ttSurfaceTaxeBureau.dSurfaceExpo          = local.sfPex                                                                            /* NP 0115/0183 Next version */
            .
            else assign
                     ttSurfaceTaxeBureau.dSurfaceBureau        = (local.sfbur       / local.sfree) * (if local.sfbur       <> 0 then cpuni.sflot else 0)
                     ttSurfaceTaxeBureau.dSurfaceCommerciale   = (local.sfcom       / local.sfree) * (if local.sfcom       <> 0 then cpuni.sflot else 0)
                     ttSurfaceTaxeBureau.dSurfaceStockage      = (local.sfstk       / local.sfree) * (if local.sfstk       <> 0 then cpuni.sflot else 0)
                     ttSurfaceTaxeBureau.dSurfaceStationnement = (vdSfStationnement / local.sfree) * (if vdSfStationnement <> 0 then cpuni.sflot else 0)
                     ttSurfaceTaxeBureau.dSurfaceExpo          = (local.sfpex       / local.sfree) * (if local.sfpex       <> 0 then cpuni.sflot else 0)
            .
        end.
    end.

end procedure.

procedure initComboTaxeBureau:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeCombo.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspr as class syspr no-undo.

    empty temp-table ttCombo.

    voSyspr = new syspr().
    voSyspr:getComboParametre("TPZON", "ZONE"     , output table ttCombo by-reference).
    voSyspr:getComboParametre("TPTAR", "TYPETARIF", output table ttCombo by-reference).
    delete object voSyspr.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    define buffer tache for tache.
    define buffer txbdt for txbdt.

    for each ttULTaxeBureau
    break by ttULTaxeBureau.iNumeroContrat:
        if first-of (ttULTaxeBureau.iNumeroContrat)
        then do:
            find first ctrat no-lock
                 where ctrat.tpcon = ttTacheTaxeBureau.cTypeContrat
                   and ctrat.nocon = ttULTaxeBureau.iNumeroContrat no-error.
            if not available ctrat
            then do:
                mError:createErrorGestion({&error}, 211656, string(ttULTaxeBureau.iNumeroContrat)).   //mandat %1 introuvable
                return.
            end.
            for first txbdt no-lock
                where txbdt.noimm = ttTacheTaxeBureau.iNumeroImmeuble
                  and txbdt.annee = ttTacheTaxeBureau.iPeriode
                  and txbdt.noman = ctrat.norol:
                mError:createErrorGestion({&error}, 1000433, substitute('&2&1&3', separ[1], ttTacheTaxeBureau.iPeriode, txbdt.nomdt)). //Exercice %1 historisé pour le mandat %2 , modification ou suppression impossible
                return.
            end.
            if ttTacheTaxeBureau.CRUD = "D"
            and can-find(first tssdt no-lock
                         where tssdt.annee = ttTacheTaxeBureau.iPeriode
                           and tssdt.nomdt = ttULTaxeBureau.iNumeroContrat)
            then do:
                mError:createErrorGestion({&error}, 109495, substitute('&2&1&3', separ[1], ttTacheTaxeBureau.iPeriode, ttULTaxeBureau.iNumeroContrat)). //Exercice %1 historisé pour le mandat %2 , suppression impossible
                return.
            end.
        end.
    end.
    if ttTacheTaxeBureau.cCentrePaiement = ? or ttTacheTaxeBureau.cCentrePaiement = ""
    then do:
        mError:createError({&error}, 103512). //vous devez saisir un centre de paiement
        return.
    end.
    if not can-find(first orsoc no-lock
                    where orsoc.tporg = "OTB"
                      and orsoc.ident = ttTacheTaxeBureau.cCentrePaiement)
    then do:
        mError:createError({&error}, 103559). //centre de paiement invalide
        return.
    end.
    if ttTacheTaxeBureau.cCentreDeclaration = ? or ttTacheTaxeBureau.cCentreDeclaration = ""
    then do:
        mError:createError({&error}, 103511). //vous devez saisir un centre de declaration
        return.
    end.
    if not can-find(first orsoc no-lock
                    where orsoc.tporg = "CDI"
                      and orsoc.ident = ttTacheTaxeBureau.cCentreDeclaration)
    then do:
        mError:createError({&error}, 1000415). //centre de declaration invalide
        return.
    end.
    for each ttSurfaceTaxeBureau
       where ttSurfaceTaxeBureau.CRUD = "U"
    , first local no-lock
      where local.noimm = ttSurfaceTaxeBureau.iNumeroImmeuble
        and local.nolot = ttSurfaceTaxeBureau.iNumeroLot
        and local.fgdiv = yes:
        mError:createError({&error}, 1000417). //mise à jour surface sur lot divisible interdite
        return.
    end.

end procedure.

procedure majTacheEtSurface private:
    /*------------------------------------------------------------------------------
    Purpose:  mise a jour tache taxe bureau
              la mise a jour de cette table tache se fait pour tous les contrats de la combinaison mandant / immeuble (pas de numero de mandat sur table ttTacheTaxeBureau)
              mise a jour infos surface
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhTache         as handle    no-undo.
    define variable vhCttac         as handle    no-undo.
    define variable vhLocal         as handle    no-undo.
    define variable vListeTypeTarif as character no-undo.

    define buffer tache for tache.
    define buffer local for local.

    empty temp-table ttTache.
    for each ttULTaxeBureau                                                      //boucle lecture des UL trie par numero de contrat / UL
    break by ttULTaxeBureau.iNumeroContrat
          by ttULTaxeBureau.iNumeroUL:
        if first-of (ttULTaxeBureau.iNumeroContrat)
        then vListeTypeTarif = "".
        vListeTypeTarif = substitute('&1#&2@&3@&4@&5', vListeTypeTarif, ttULTaxeBureau.iNumeroUL, ttULTaxeBureau.iComposition, '', ttULTaxeBureau.cTypeTarif).
        if last-of (ttULTaxeBureau.iNumeroContrat)                              //traitement de mise a jour a chaque dernier enregistrement pour un numero de contrat
        then do:
            find first tache no-lock                                          //lecture tache pour voir type de traitement a realiser
                 where tache.tptac = {&TYPETACHE-taxeSurBureau}
                   and tache.notac = ttTacheTaxeBureau.iPeriode
                   and tache.tpcon = ttTacheTaxeBureau.cTypeContrat
                   and tache.nocon = ttULTaxeBureau.iNumeroContrat no-error.
            if not available tache and ttTacheTaxeBureau.CRUD = "D" then next.      //normalement impossible
            create ttTache.
            assign
                ttTache.tpcon   = ttTacheTaxeBureau.cTypeContrat
                ttTache.nocon   = ttULTaxeBureau.iNumeroContrat
                ttTache.tptac   = ttTacheTaxeBureau.cTypeTache
                ttTache.notac   = ttTacheTaxeBureau.iPeriode
                ttTache.duree   = integer(ttTacheTaxeBureau.cZone)
                ttTache.utreg   = ttTacheTaxeBureau.cCentrePaiement
                ttTache.dcreg   = ttTacheTaxeBureau.cCentreDeclaration
                ttTache.nosie   = substitute("&1&2&3", string(ttTacheTaxeBureau.cNoSie01, "X(3)"), string(ttTacheTaxeBureau.cNoSie02, "X(2)"), string(ttTacheTaxeBureau.cNoSie03, "X(2)"))
                ttTache.dossier = (if ttTacheTaxeBureau.iNoDossier <> ? then string(ttTacheTaxeBureau.iNoDossier) else "")
                ttTache.nocle   = (if ttTacheTaxeBureau.iNoCle <> ? then string(ttTacheTaxeBureau.iNoCle) else "")
                ttTache.cdir    = (if ttTacheTaxeBureau.iCodeCdir <> ? then string(ttTacheTaxeBureau.iCodeCdir) else "")
                ttTache.service = (if ttTacheTaxeBureau.iCodeService <> ? then string(ttTacheTaxeBureau.iCodeService) else "")
                ttTache.lbdiv   = substring(vListeTypeTarif, 2)
                ttTache.tphon   = {&TYPEHONORAIRE-taxe-bureau}
            .
            if available tache
            then assign
                     ttTache.noita       = tache.noita
                     ttTache.CRUD        = ttTacheTaxeBureau.CRUD            //enregistrement tache existe donc mise a jour possible U ou D
                     ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                     ttTache.rRowid      = rowid(tache)
            .
            else assign
                    ttTache.noita = 0
                    ttTache.CRUD  = "C"                               //enregistrement tache inexistant donc forcement une creation
            .
        end.
    end.

    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    run destroy in vhTache.
    if mError:erreur() then return.

    empty temp-table ttCttac.
    for each ttTache:
        if can-find (first tache no-lock
                     where tache.tpcon = ttTache.tpcon
                       and tache.nocon = ttTache.nocon
                       and tache.tptac = {&TYPETACHE-taxeSurBureau})
        and not can-find (first cttac no-lock
                          where cttac.tpcon = ttTache.tpcon
                            and cttac.nocon = ttTache.nocon
                            and cttac.tptac = {&TYPETACHE-taxeSurBureau})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttTache.tpcon
                ttCttac.nocon = ttTache.nocon
                ttCttac.tptac = {&TYPETACHE-taxeSurBureau}
                ttCttac.CRUD  = "C"
            .
        end.
    end.
    run adblib/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).
    run setCttac in vhCttac (table ttCttac by-reference).
    run destroy in vhCttac.
    if mError:erreur() then return.

    if ttTacheTaxeBureau.CRUD = "D" then return.        //en supression tache, pas de maj des surfaces

    empty temp-table ttLocal.
    for each ttSurfaceTaxeBureau
        where ttSurfaceTaxeBureau.CRUD = "U"
      , first local no-lock
        where local.noimm = ttSurfaceTaxeBureau.iNumeroImmeuble
          and local.nolot = ttSurfaceTaxeBureau.iNumeroLot
          and local.fgdiv = no:
        create ttLocal.
        assign
            ttLocal.noloc       = local.noloc
            ttLocal.noimm       = ttSurfaceTaxeBureau.iNumeroImmeuble
            ttLocal.nolot       = ttSurfaceTaxeBureau.iNumeroLot
            ttLocal.sfbur       = ttSurfaceTaxeBureau.dSurfaceBureau
            ttLocal.sfcom       = ttSurfaceTaxeBureau.dSurfaceCommerciale
            ttLocal.sfstk       = ttSurfaceTaxeBureau.dSurfaceStockage
            ttLocal.cddev       = substitute('&1&200001', ttSurfaceTaxeBureau.dSurfaceStationnement, separ[1])
            ttLocal.sfpkg       = ttSurfaceTaxeBureau.dSurfaceStationnement
            ttLocal.uspkg       = "00001"
            ttLocal.sfpex       = ttSurfaceTaxeBureau.dSurfaceExpo
            ttLocal.uspex       = "00001"
            ttLocal.CRUD        = ttSurfaceTaxeBureau.CRUD
            ttLocal.dtTimestamp = ttSurfaceTaxeBureau.dtTimestamp
            ttLocal.rRowid      = ttSurfaceTaxeBureau.rRowid
        .
    end.
    run adblib/local_CRUD.p persistent set vhLocal.
    run getTokenInstance in vhLocal(mToken:JSessionId).
    run setlocal in vhLocal(table ttLocal by-reference).
    run destroy in vhLocal.
    if mError:erreur() then return.

end procedure.

