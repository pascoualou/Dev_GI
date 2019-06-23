/*------------------------------------------------------------------------
File        : tacheChargeLocative.p
Purpose     : tache charges locatives et prestations
Author(s)   : GGA - 2017/12/18
Notes       : a partir de adb/tach/prmmtchl.p, adb/tach/prmobchl.p
derniere revue: 2018/03/22 - phm
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}

using parametre.syspg.syspg.
using parametre.syspg.parametrageTache.
using parametre.syspr.syspr.
using parametre.pclie.pclie.
using parametre.pclie.parametrageChargeLocative.
using parametre.pclie.parametrageHistoCG.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define variable goHistoCG as class parametrageHistoCG no-undo.
{mandat/include/clemi.i}
{adblib/include/ctrat.i}
{tache/include/tache.i}
{tache/include/tacheChargeLocative.i}
{adblib/include/cttac.i}
{adblib/include/assrc.i}
{adblib/include/perio.i}
{adblib/include/lprtb.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{parametre/cabinet/gerance/include/paramChargeLocative.i}
{adb/include/archicle.i}              // fonction fctCleArc
{adb/include/majCleAlphaGerance.i}    // procedure majClger

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

function defautPresentationAu return character private():
    /*------------------------------------------------------------------------------
    Purpose: retourne valeur parametre par defaut (charge locative) du mode de presentation
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voparametrageChargeLocative as class parametrageChargeLocative no-undo.

    voparametrageChargeLocative = new parametrageChargeLocative().
    if voparametrageChargeLocative:isDbParameter
    then return voparametrageChargeLocative:getPresentationChargeLocative().
    return "00001".

end function.

procedure getChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheChargeLocative.
    define output parameter table for ttRubriqueChargeLocative.

    define variable viNumeroImmeuble as integer no-undo.
    define buffer tache   for tache.
    define buffer vbtache for tache.
    define buffer clemi   for clemi.

    empty temp-table ttTacheChargeLocative.
    empty temp-table ttRubriqueChargeLocative.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    viNumeroImmeuble = numeroImmeuble(piNumeroMandat, pcTypeMandat).
    if mError:erreur() then return.

    goHistoCG = new parametrageHistoCG().
    find first tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-chargesLocativesPrestations}
          and tache.notac = 1 no-error.
    if available tache
    then do:
        run ctrlCle(piNumeroMandat, yes, tache.tphon).
        if not mError:erreur() then do:
            create ttTacheChargeLocative.
            assign
                ttTacheChargeLocative.iNumeroTache             = tache.noita
                ttTacheChargeLocative.cTypeContrat             = tache.tpcon
                ttTacheChargeLocative.iNumeroContrat           = tache.nocon
                ttTacheChargeLocative.cTypeTache               = tache.tptac
                ttTacheChargeLocative.iChronoTache             = tache.notac
                ttTacheChargeLocative.cPresentationAu          = tache.tphon
                ttTacheChargeLocative.cLibellePresentationAu   = outilTraduction:getLibelleParam("TRCH3", tache.tphon)
                ttTacheChargeLocative.cPresentationType        = tache.ntges
                ttTacheChargeLocative.cLibellePresentationType = outilTraduction:getLibelleParam("CDCUM", tache.ntges)
                ttTacheChargeLocative.cCleDefaut               = trim(tache.dcreg)
                ttTacheChargeLocative.lIntegrationDirectCompta = (tache.pdges = "1")
                ttTacheChargeLocative.cEtatDepense             = tache.utreg
                ttTacheChargeLocative.cLibelleEtatDepense      = outilTraduction:getLibelle(if tache.utreg = "TTC" then 1000489 else 1000490)
                ttTacheChargeLocative.cRepartition             = tache.tpges
                ttTacheChargeLocative.cLibelleRepartition      = outilTraduction:getLibelleParam("CDLOT", tache.tpges)
                ttTacheChargeLocative.lReleveEauFroide         = (tache.cdreg = "1")
                ttTacheChargeLocative.lReleveEauChaude         = (tache.ntreg = "1")
                ttTacheChargeLocative.lReleveCalorifique       = (tache.pdreg = "1")
                ttTacheChargeLocative.dtTimestamp              = datetime(tache.dtmsy, tache.hemsy)
                ttTacheChargeLocative.CRUD                     = 'R'
                ttTacheChargeLocative.rRowid                   = rowid(tache)
            .
            case ttTacheChargeLocative.cRepartition:
                when "00001" then ttTacheChargeLocative.cInfoRepartition = outilTraduction:getLibelle(107336).
                when "00002" then ttTacheChargeLocative.cInfoRepartition = outilTraduction:getLibelle(107337).
                when "00003" then ttTacheChargeLocative.cInfoRepartition = outilTraduction:getLibelle(107338).
            end case.
            for first clemi no-lock
                where clemi.noimm = 10000 + piNumeroMandat
                  and clemi.cdeta <> "S"
                  and clemi.nbtot > 0
                  and clemi.cdcle = ttTacheChargeLocative.cCleDefaut:
                ttTacheChargeLocative.cLibelleCleDefaut = clemi.lbcle.
            end.
            run lectRubrique(piNumeroMandat, viNumeroImmeuble).
            for last vbtache no-lock
               where vbtache.tpcon = pcTypeMandat
                 and vbtache.nocon = piNumeroMandat
                 and vbtache.tptac = {&TYPETACHE-regulChargesLocatives}:
                assign
                    ttTacheChargeLocative.dPourcentageAugmentation = vbtache.mtreg
                    ttTacheChargeLocative.lReajustementProvision   = (vbtache.ntges = "00001")
                    ttTacheChargeLocative.lLissage                 = (vbtache.tpges = "00001")
                .
            end.
        end.
    end.
    else run ctrlCle(piNumeroMandat, no, defautPresentationAu()).
    delete object goHistoCG.

end procedure.

procedure setChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheChargeLocative.
    define input parameter table for ttRubriqueChargeLocative.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    for first ttTacheChargeLocative
        where lookup(ttTacheChargeLocative.CRUD, "C,U,D") > 0:
        if not can-find(first ctrat no-lock
                        where ctrat.tpcon = ttTacheChargeLocative.cTypeContrat
                          and ctrat.nocon = ttTacheChargeLocative.iNumeroContrat)
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        find first tache no-lock
            where tache.tpcon = ttTacheChargeLocative.cTypeContrat
              and tache.nocon = ttTacheChargeLocative.iNumeroContrat
              and tache.tptac = {&TYPETACHE-chargesLocativesPrestations} no-error.
        if not available tache and lookup(ttTacheChargeLocative.CRUD, "U,D") > 0
        then do:
            mError:createError({&error}, 1000413).    //modification d'une tache inexistante
            return.
        end.
        if available tache and ttTacheChargeLocative.CRUD = "C"
        then mError:createError({&error}, 1000412).    //création d'une tache existante
        else do:
            goHistoCG = new parametrageHistoCG().
            run verZonSai(buffer ttTacheChargeLocative).
            if not mError:erreur() then run majtbltch(buffer ttTacheChargeLocative).
            delete object goHistoCG.
        end.
    end.

end procedure.

procedure initChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheChargeLocative.
    define output parameter table for ttRubriqueChargeLocative.

    define variable viNumeroImmeuble as integer no-undo.
    define variable vhProc           as handle  no-undo.
    define variable voparametrageChargeLocative as class parametrageChargeLocative no-undo.

    empty temp-table ttTacheChargeLocative.
    empty temp-table ttRubriqueChargeLocative.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = {&TYPETACHE-chargesLocativesPrestations})
    then do:
        mError:createError({&error}, 1000410).             //demande d'initialisation d'une tache existante
        return.
    end.
    viNumeroImmeuble = numeroImmeuble(piNumeroMandat, pcTypeMandat).
    if mError:erreur() then return.

    goHistoCG = new parametrageHistoCG().
    run ctrlCle(piNumeroMandat, no, defautPresentationAu()).
    if mError:erreur() then do:
        delete object goHistoCG.
        return.
    end.
    create ttTacheChargeLocative.
    assign
        ttTacheChargeLocative.iNumeroTache   = 0
        ttTacheChargeLocative.cTypeContrat   = pcTypeMandat
        ttTacheChargeLocative.iNumeroContrat = piNumeroMandat
        ttTacheChargeLocative.cTypeTache     = {&TYPETACHE-chargesLocativesPrestations}
        ttTacheChargeLocative.iChronoTache   = 0
        ttTacheChargeLocative.CRUD           = 'C'
    .
    // info par defaut parametrage mandat gerance (charge locative)
    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run getParamChargeLocative in vhProc(output table ttParamChargeLocative by-reference).
    run destroy in vhProc.
    for first ttParamChargeLocative:
        assign
            ttTacheChargeLocative.lIntegrationDirectCompta = ttParamChargeLocative.lIntegrationDirectCompta
            ttTacheChargeLocative.cPresentationType        = ttParamChargeLocative.cCodePresentation
            ttTacheChargeLocative.cLibellePresentationType = ttParamChargeLocative.cLibellePresentation
            ttTacheChargeLocative.cRepartition             = ttParamChargeLocative.cCodeRepartition
            ttTacheChargeLocative.cLibelleRepartition      = ttParamChargeLocative.cLibelleRepartition
        .
        case ttTacheChargeLocative.cRepartition:
            when "00001" then ttTacheChargeLocative.cInfoRepartition = outilTraduction:getLibelle(107336).
            when "00002" then ttTacheChargeLocative.cInfoRepartition = outilTraduction:getLibelle(107337).
            when "00003" then ttTacheChargeLocative.cInfoRepartition = outilTraduction:getLibelle(107338).
        end case.
    end.
    // info par defaut parametrage charge locative
    voparametrageChargeLocative = new parametrageChargeLocative().
    if voparametrageChargeLocative:isDbParameter
    then assign
        ttTacheChargeLocative.cPresentationAu = voparametrageChargeLocative:getPresentationChargeLocative()
        ttTacheChargeLocative.cEtatDepense    = voparametrageChargeLocative:getPresentationEtatDepense()
    .
    else assign
        ttTacheChargeLocative.cPresentationAu = "00001"
        ttTacheChargeLocative.cEtatDepense    = "TTC"
    .
    assign
        ttTacheChargeLocative.cLibellePresentationAu = outilTraduction:getLibelleParam("TRCH3", ttTacheChargeLocative.cPresentationAu)
        ttTacheChargeLocative.cLibelleEtatDepense    = outilTraduction:getLibelle(if ttTacheChargeLocative.cEtatDepense = "TTC" then 1000489 else 1000490)
    .
    run lectRubrique(piNumeroMandat, viNumeroImmeuble).
    delete object goHistoCG.

end procedure.

procedure LectRubrique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.

    define buffer rubqt for rubqt.
    define buffer assrc for assrc.

    run listeCleAAssocier(piNumeroMandat, piNumeroImmeuble).
    for each rubqt no-lock        // todo  whole index, n'y a t'il pas d'autre plan pour la recherche ????
        where rubqt.cdlib = 0
          and rubqt.cdfam = 2
          and rubqt.cdsfa = 1
          and rubqt.cdrub <> 299:
        find first assrc no-lock
             where assrc.nomdt = piNumeroMandat
               and assrc.cdrub = rubqt.cdrub
               and assrc.cdlib = rubqt.cdlib no-error.
        if available assrc then do:
            create ttRubriqueChargeLocative.
            assign
                ttRubriqueChargeLocative.iRubrique        = rubqt.cdrub
                ttRubriqueChargeLocative.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
                ttRubriqueChargeLocative.cCle             = assrc.cdcle
                ttRubriqueChargeLocative.CRUD             = "R"
                ttRubriqueChargeLocative.dtTimestamp      = datetime(assrc.dtmsy, assrc.hemsy)
                ttRubriqueChargeLocative.rRowid           = rowid(assrc)
            .
            for first ttCleChargeLocative
                where ttCleChargeLocative.cCle = assrc.cdcle:
                assign
                    ttRubriqueChargeLocative.cLibelleCle   = ttCleChargeLocative.cLibelleCle
                    ttRubriqueChargeLocative.dBaseImmeuble = ttCleChargeLocative.dBaseImmeuble
                    ttRubriqueChargeLocative.dBaseMandat   = ttCleChargeLocative.dBaseMandat
                .
            end.
        end.
        else do:
            create ttRubriqueChargeLocative.
            assign
                ttRubriqueChargeLocative.iRubrique        = rubqt.cdrub
                ttRubriqueChargeLocative.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
                ttRubriqueChargeLocative.cCle             = ""
                ttRubriqueChargeLocative.cLibelleCle      = ""
                ttRubriqueChargeLocative.dBaseImmeuble    = 0
                ttRubriqueChargeLocative.dBaseMandat      = 0
                ttRubriqueChargeLocative.CRUD             = "R"
            .
        end.
    end.

end procedure.

procedure initComboChargeLocative:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttCombo.
    define output parameter table for ttCleChargeLocative.

    define variable viNumeroImmeuble as integer no-undo.
    define buffer tache for tache.

    viNumeroImmeuble = numeroImmeuble(piNumeroMandat, pcTypeMandat).
    if mError:erreur() then return.

    goHistoCG = new parametrageHistoCG().
    find first tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-chargesLocativesPrestations}
          and tache.notac = 1 no-error.
    if available tache
    then run ctrlCle(piNumeroMandat, yes, tache.tphon).
    else run ctrlCle(piNumeroMandat, no, defautPresentationAu()).
    if not mError:erreur() then do:
        run chargeCombo(piNumeroMandat).
        run listeCleAAssocier(piNumeroMandat, viNumeroImmeuble).
    end.
    delete object goHistoCG.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable voSyspr as class syspr no-undo.
    define variable voSyspg as class syspg no-undo.
    define buffer clemi for clemi.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("TRCH3", "PRESENTATION-AU"  , output table ttCombo by-reference).
    voSyspr:getComboParametre("CDCUM", "PRESENTATION-TYPE", output table ttCombo by-reference).
    voSyspr:getComboParametre("CDLOT", "REPARTITION"      , output table ttCombo by-reference).

    voSyspg = new syspg().
    voSyspg:creationttCombo("ETAT-DEPENSE", "TTC", outilTraduction:getLibelle(1000489), output table ttCombo by-reference). //"TTC dont TVA"
    voSyspg:creationttCombo("ETAT-DEPENSE", "HT" , outilTraduction:getLibelle(1000490), output table ttCombo by-reference). //"HT, TVA, TTC"

    for each ttCombo
        where ttCombo.cNomCombo = "REPARTITION":
        case ttCombo.cCode:
            when "00001" then ttCombo.cLibelle2 = outilTraduction:getLibelle(107336).
            when "00002" then ttCombo.cLibelle2 = outilTraduction:getLibelle(107337).
            when "00003" then ttCombo.cLibelle2 = outilTraduction:getLibelle(107338).
        end case.
    end.

    /* boucle extraite de adb/com/inccredf.i mais reportee dans ce pgm car seulement utilise ici */
    /* combo des cles par defaut */
    for each clemi no-lock
       where clemi.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and clemi.nocon = piNumeroMandat
         and clemi.cdeta <> "S"
         and clemi.nbtot > 0:
        voSyspg:creationttCombo("CLE-DEFAUT", clemi.cdcle, clemi.lbcle, output table ttCombo by-reference).
    end.
    delete object voSyspr.
    delete object voSyspg.

end procedure.

procedure ListeCleAAssocier private:
    /*------------------------------------------------------------------------------
    Purpose:  creation combo cle a associer. on utilise une table specifique ttCleChargeLocative car il y a en plus les
              infos de milliemes par rapport a une combo classique.
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.

    define buffer clemi for clemi.

    empty temp-table ttCleChargeLocative.
    for each clemi no-lock                                               /* recuperation des milliemes totaux pour l'immeuble */
        where clemi.noimm = piNumeroImmeuble
          and clemi.cdeta <> "S"
          and clemi.nbtot > 0:
        find first ttCleChargeLocative where ttCleChargeLocative.cCle = clemi.cdcle no-error.
        if not available ttCleChargeLocative
        then do:
            create ttCleChargeLocative.
            assign
                ttCleChargeLocative.cCle          = clemi.cdcle
                ttCleChargeLocative.cLibelleCle   = clemi.lbcle
                ttCleChargeLocative.dBaseImmeuble = clemi.nbtot
                ttCleChargeLocative.dBaseMandat   = 0
            .
        end.
    end.

    for each clemi no-lock                                               /* ToTaux cles milliemes du mandat */
       where clemi.noimm = 10000 + piNumeroMandat
         and clemi.cdeta <> "S"
         and clemi.nbtot >= 0:
        find first ttCleChargeLocative where ttCleChargeLocative.cCle = clemi.cdcle no-error.
        if not available ttCleChargeLocative
        then do:
            create ttCleChargeLocative.
            assign
                ttCleChargeLocative.cCle          = clemi.cdcle
                ttCleChargeLocative.cLibelleCle   = clemi.lbcle
                ttCleChargeLocative.dBaseImmeuble = 0
            .
        end.
        ttCleChargeLocative.dBaseMandat = clemi.nbtot.
    end.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheChargeLocative for ttTacheChargeLocative.

    define variable voTache          as class parametrageTache no-undo.
    define variable viNumeroImmeuble as integer no-undo.
    define buffer clemi for clemi.

    if ttTacheChargeLocative.CRUD = "D" then do:
        voTache = new parametrageTache().
        if voTache:tacheObligatoire(ttTacheChargeLocative.iNumeroContrat, ttTacheChargeLocative.cTypeContrat, {&TYPETACHE-chargesLocativesPrestations}) = yes
        then mError:createError({&error}, 1000492).      //Tache obligatoire, suppression interdite
        else if can-find(first trfpm no-lock
                    where trfpm.tptrf = "PS"
                      and trfpm.tpapp = ""
                      and trfpm.nomdt = ttTacheChargeLocative.iNumeroContrat)
        then mError:createError({&error}, 1000491).      //Des charges ont déjà été traitées sur ce mandat. Suppression de la tâche interdite
        delete object voTache.
        return.
    end.
    if ttTacheChargeLocative.cPresentationAu = "00002"
    and can-find(first aparm no-lock
                 where aparm.tppar = "DURCHL"
                   and aparm.cdpar = "01")
    then do:
        mError:createError({&error}, 109544). //L'option 'Durcir les charges locatives extra-comptables' est activée. Vous ne pouvez donc pas utiliser la présentation immeuble.
        return.
    end.
    if ttTacheChargeLocative.cCleDefaut = "" or ttTacheChargeLocative.cCleDefaut = ?
    then do:
        mError:createError({&error}, 104063).   //La cle par defaut est obligatoire
        return.
    end.
    find first clemi no-lock
         where clemi.noimm = 10000 + ttTacheChargeLocative.iNumeroContrat
           and clemi.cdeta <> "S"
           and clemi.nbtot > 0
           and clemi.cdcle = ttTacheChargeLocative.cCleDefaut no-error.
    if not available clemi
    or isCleArchivee(clemi.noimm, clemi.nocon, clemi.cdcle)   /* si archivage gere et clé archivée, on ne fait rien */
    then do:
        mError:createError({&error}, 1000436). //clé par défaut inexistante
        return.
    end.
    if ttTacheChargeLocative.cPresentationAu = "00002"
    and index ("0123456789", substring(ttTacheChargeLocative.cCleDefaut, 1, 1, 'character')) = 0
    then do:
        mError:createError({&error}, 1000434). //Pour une présentation à l'immeuble, le premier caractère de la clé par défaut doit être numérique
        return.
    end.
    if ttTacheChargeLocative.dPourcentageAugmentation > 100
    then do:
        mError:createError({&error}, 1000414).       //le pourcentage de l'augmentation ne peut pas depasser 100 %
        return.
    end.
    viNumeroImmeuble = numeroImmeuble(ttTacheChargeLocative.iNumeroContrat, ttTacheChargeLocative.cTypeContrat).
    run listeCleAAssocier(ttTacheChargeLocative.iNumeroContrat, viNumeroImmeuble).
    for first ttRubriqueChargeLocative
        where ttRubriqueChargeLocative.CRUD = "U"
          and ttRubriqueChargeLocative.cCle > ""
          and not can-find(first ttCleChargeLocative where ttCleChargeLocative.cCle = ttRubriqueChargeLocative.cCle):
        mError:createError({&error}, 1000435, substitute("&2&1&3", separ[1], ttRubriqueChargeLocative.cCle, ttRubriqueChargeLocative.iRubrique)).       //Clé &1 à associer sur rubrique &2 inexistante
        return.
    end.

end procedure.

procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
//gga todo voir Francis si pas d'enregistrement tache et surtout pas d'enregistrement periode pour pouvoir creer au moins un enregistrement tache
//dans l'appli message erreur acces interdit vous n avez pas cree de periodes de charges locatives (voir test sur mandat 1195        
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheChargeLocative for ttTacheChargeLocative.

    define variable vhProc as handle no-undo.

    define variable voTache as class parametrageTache no-undo.

    define buffer tache for tache.
    define buffer cttac for cttac.
    define buffer lprtb for lprtb.
    define buffer perio for perio.
    define buffer ctrat for ctrat.
    define buffer assrc for assrc.

    empty temp-table ttTache.
    empty temp-table ttAssrc.
    empty temp-table ttCttac.
    empty temp-table ttCtrat.
    empty temp-table ttPerio.
    empty temp-table ttLprtb.
    create ttTache.
    assign
        ttTache.noita = ttTacheChargeLocative.iNumeroTache
        ttTache.tpcon = ttTacheChargeLocative.cTypeContrat
        ttTache.nocon = ttTacheChargeLocative.iNumeroContrat
        ttTache.tptac = ttTacheChargeLocative.cTypeTache
        ttTache.notac = ttTacheChargeLocative.iChronoTache
        ttTache.tphon = ttTacheChargeLocative.cPresentationAu
        ttTache.ntges = ttTacheChargeLocative.cPresentationType
        ttTache.dcreg = ttTacheChargeLocative.cCleDefaut
        ttTache.pdges = string(ttTacheChargeLocative.lIntegrationDirectCompta,"1/0")
        ttTache.utreg = ttTacheChargeLocative.cEtatDepense
        ttTache.tpges = ttTacheChargeLocative.cRepartition
        ttTache.cdreg = string(ttTacheChargeLocative.lReleveEauFroide, "1/0")
        ttTache.ntreg = string(ttTacheChargeLocative.lReleveEauChaude, "1/0")
        ttTache.pdreg = string(ttTacheChargeLocative.lReleveCalorifique, "1/0")
        ttTache.CRUD        = ttTacheChargeLocative.CRUD
        ttTache.dtTimestamp = ttTacheChargeLocative.dtTimestamp
        ttTache.rRowid      = ttTacheChargeLocative.rRowid
    .
    //mise a jour sur parametrage regularisation des charges locatives (pour toutes les periodes non traitees)
    if lookup(ttTacheChargeLocative.CRUD, "U,C") > 0 then do:
        if not can-find(first cttac no-lock
            where cttac.tpcon = ttTacheChargeLocative.cTypeContrat
              and cttac.nocon = ttTacheChargeLocative.iNumeroContrat
              and cttac.tptac = {&TYPETACHE-chargesLocativesPrestations})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttTacheChargeLocative.cTypeContrat
                ttCttac.nocon = ttTacheChargeLocative.iNumeroContrat
                ttCttac.tptac = {&TYPETACHE-chargesLocativesPrestations}
                ttCttac.CRUD  = "C"
            .
        end.
        for each perio no-lock
            where perio.tpctt = ttTacheChargeLocative.cTypeContrat
              and perio.nomdt = ttTacheChargeLocative.iNumeroContrat
              and perio.noper = 0
              and lookup(perio.cdtrt, "00001,00002") > 0
          , each tache no-lock
            where tache.tpcon = ttTacheChargeLocative.cTypeContrat
              and tache.nocon = ttTacheChargeLocative.iNumeroContrat
              and tache.tptac = {&TYPETACHE-regulChargesLocatives}
              and tache.notac = perio.noexo:
            create ttTache.
            assign
                ttTache.noita = tache.noita
                ttTache.tpcon = tache.tpcon
                ttTache.nocon = tache.nocon
                ttTache.tptac = tache.tptac
                ttTache.notac = tache.notac
                ttTache.ntges = string(ttTacheChargeLocative.lReajustementProvision, "00001/00002")
                ttTache.tpges = string(ttTacheChargeLocative.lLissage, "00001/00002")
                ttTache.mtreg = ttTacheChargeLocative.dPourcentageAugmentation
                ttTache.ntreg = "00001"
                ttTache.cdreg = "2"
                ttTache.CRUD        = "U"
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                ttTache.rRowid      = rowid(tache)
            .
        end.
        for each ttRubriqueChargeLocative
            where ttRubriqueChargeLocative.CRUD = "U":
            create ttAssrc.
            assign
                ttAssrc.nomdt       = ttTacheChargeLocative.iNumeroContrat
                ttAssrc.cdrub       = ttRubriqueChargeLocative.iRubrique
                ttAssrc.cdlib       = 0
                ttAssrc.cdcle       = ttRubriqueChargeLocative.cCle
                ttAssrc.dtTimestamp = ttRubriqueChargeLocative.dtTimestamp
                ttAssrc.rRowid      = ttRubriqueChargeLocative.rRowid
            .     
            if can-find(first assrc no-lock
                        where assrc.nomdt = ttTacheChargeLocative.iNumeroContrat
                          and assrc.cdrub = ttRubriqueChargeLocative.iRubrique
                          and assrc.cdlib = 0)
            then do:
                if ttRubriqueChargeLocative.cCle = "" 
                then ttAssrc.CRUD = "D".
                else ttAssrc.CRUD = "U".
            end.
            else do:
                if ttRubriqueChargeLocative.cCle > ""
                then ttAssrc.CRUD  = "C".
            end.    
        end.
        run tache/tache.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setTache in vhProc(table ttTache by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.   
        
        run adblib/cttac_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCttac in vhProc(table ttCttac by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.     
                        
        run adblib/assrc_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setAssrc in vhProc(table ttAssrc by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.    
            
    end.
    else do:
        for first cttac no-lock
            where cttac.tpcon = ttTacheChargeLocative.cTypeContrat
              and cttac.nocon = ttTacheChargeLocative.iNumeroContrat
              and cttac.tptac = {&TYPETACHE-chargesLocativesPrestations}:
            create ttCttac.
            assign
                ttCttac.tpcon       = cttac.tpcon
                ttCttac.nocon       = cttac.nocon
                ttCttac.tptac       = cttac.tptac
                ttCttac.CRUD        = "D"
                ttCttac.rRowid      = rowid(cttac)
                ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            .
        end.
        // Suppression des liens taches prestation-mandat (Imputations particulieres...)
        voTache = new parametrageTache().
        voTache:delLienPrestationMandat(ttTacheChargeLocative.iNumeroContrat, ttTacheChargeLocative.cTypeContrat).
        delete object voTache.
        // Suppression des liens tache des pseudo-contrat prestation
        for each cttac no-lock
            where cttac.tpcon = {&TYPECONTRAT-prestations}
              and cttac.nocon >= ttTacheChargeLocative.iNumeroContrat * 100 + 1   // integer(string(ttTacheChargeLocative.iNumeroContrat,"99999") + "01")
              and cttac.nocon <= ttTacheChargeLocative.iNumeroContrat * 100 + 99: // integer(string(ttTacheChargeLocative.iNumeroContrat,"99999") + "99")
            create ttCttac.
            assign
                ttCttac.tpcon       = cttac.tpcon
                ttCttac.nocon       = cttac.nocon
                ttCttac.tptac       = cttac.tptac
                ttCttac.CRUD        = "D"
                ttCttac.rRowid      = rowid(cttac)
                ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            .            
        end.
        // Suppression des associations rubrique - cle
        run adblib/assrc_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run deleteAssrcSurMandat in vhProc(ttTacheChargeLocative.iNumeroContrat).
        run destroy in vhProc.
        if mError:erreur() then return.
        // Suppression des liens tableau - periode
        for each lprtb no-lock
            where lprtb.tpcon = ttTacheChargeLocative.cTypeContrat
              and lprtb.nocon = ttTacheChargeLocative.iNumeroContrat:
            create ttLprtb.
            assign
                ttLprtb.tpcon       = lprtb.tpcon
                ttLprtb.nocon       = lprtb.nocon
                ttLprtb.noexe       = lprtb.noexe
                ttLprtb.noper       = lprtb.noper
                ttLprtb.noimm       = lprtb.noimm
                ttLprtb.tpcpt       = lprtb.tpcpt
                ttLprtb.norlv       = lprtb.norlv
                ttLprtb.dtTimestamp = datetime(lprtb.dtmsy, lprtb.hemsy)
                ttLprtb.CRUD        = "D"
                ttLprtb.rRowid      = rowid(lprtb)
            .
        end.
        // Suppression des periodes de charges locatives
        for each perio no-lock
            where perio.tpctt = ttTacheChargeLocative.cTypeContrat
              and perio.nomdt = ttTacheChargeLocative.iNumeroContrat:
            // Suppression du pseudo-contrat
            for each ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-prestations}
                  and ctrat.nocon = ttTacheChargeLocative.iNumeroContrat * 100 + perio.noexo: // integer(string(ttTacheChargeLocative.iNumeroContrat, "99999") + string(perio.noexo, "99"))
                create ttCtrat.
                assign
                    ttCtrat.tpcon       = ctrat.tpcon 
                    ttCtrat.nocon       = ctrat.nocon
                    ttCtrat.CRUD        = "D"
                    ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
                    ttCtrat.rRowid      = rowid(ctrat)
                .                
            end.
            create ttPerio.
            assign
                ttPerio.tpctt       = perio.tpctt
                ttPerio.nomdt       = perio.nomdt
                ttPerio.noexo       = perio.noexo
                ttPerio.noper       = perio.noper
                ttPerio.dtTimestamp = datetime(perio.dtmsy, perio.hemsy)
                ttPerio.CRUD        = "D"
                ttPerio.rRowid      = rowid(perio)
            .
        end.
        run tache/tache.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setTache in vhProc(table ttTache by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.
        
        run adblib/cttac_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCttac in vhProc(table ttCttac by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.
        
        run adblib/ctrat_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setCtrat in vhProc(table ttCtrat by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.
        
        run adblib/perio_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setPerio in vhProc(table ttPerio by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.
        
        run adblib/lprtb_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run setLprtb in vhProc(table ttLprtb by-reference).
        run destroy in vhProc.
        if mError:erreur() then return.
        
    end.
end procedure.

procedure ctrlCle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :  extrait de adb/tach.prmmtchl.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter plTacheExiste    as logical   no-undo.
    define input parameter pcPresentationAu as character no-undo.

    define variable vlCleDefautExiste as logical no-undo.
    define variable vhProcclemi       as handle  no-undo.
    define buffer clemi for clemi.

    if not can-find(first clemi no-lock
                    where clemi.noimm = 10000 + piNumeroMandat
                      and clemi.cdeta = "V")
    then do :
        empty temp-table ttClemi.
        run adblib/clemi_CRUD.p persistent set vhProcclemi.
        run getTokenInstance in vhProcclemi(mToken:JSessionId).
        run majClger(piNumeroMandat). // creation de ttClemi
        run setclemi in vhProcclemi(table ttclemi by-reference).
        run destroy in vhProcclemi.
    end.        

    /* boucle extraite de adb/com/inccredf.i mais reportee dans ce pgm car seulement utilise ici */
boucleCleDefautExiste:
    for each clemi no-lock
       where clemi.noimm = 10000 + piNumeroMandat
         and clemi.cdeta <> "S"
         and clemi.nbtot > 0:
        if (pcPresentationAu = "00002" and index("0123456789", substring(clemi.cdcle, 1, 1, 'character')) = 0)
        or isCleArchivee(clemi.noimm, clemi.nocon, clemi.cdcle) /* si archivage gere et clé archivée, on ne fait rien */
        then next boucleCleDefautExiste.

        vlCleDefautExiste = yes.
        leave boucleCleDefautExiste.
    end.
    if vlCleDefautExiste = no
    then if pcPresentationAu = "00002"
         then mError:createErrorGestion({&error}, if plTacheExiste then 109992 else 109991, "").
         else mError:createError({&error}, 103921).

end procedure.
