/*------------------------------------------------------------------------
File        : tacheReleve.p
Purpose     : tache eau froide, eau chaude, thermies, gaz etc...(paramétrage)
Author(s)   : SPo - 2018/02/08
Notes       : a partir de adb/tach/prmobrlv.p et PrO1rlv.p + encmtrlv.p et zommtrlv.p
derniere revue: 2018/04/17 - phm: KO
             regler les todo
             Garder mes modifs sauf erreur patente. (buffer tt pas à faire), attention au find last by ....
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2compteur.i}
{preprocesseur/codeUniteReleve.i}
{preprocesseur/type2uniteLocation.i}
{preprocesseur/statut2periode.i}
{preprocesseur/mode2saisie.i}
{preprocesseur/nature2journal.i}

using parametre.syspg.syspg.
using parametre.syspg.parametrageTache.
using parametre.syspr.syspr.
using parametre.pclie.pclie.
using parametre.pclie.parametrageReleveGerance.
using parametre.pclie.parametrageUniteOeuvre.
using parametre.pclie.parametrageUniteReleve.
using parametre.pclie.parametrageChargeLocative.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{tache/include/tache.i}
{adblib/include/cttac.i}
{adblib/include/lprtb.i}
{tache/include/tacheReleve.i}
{tache/include/CompteurReleve.i}
{tache/include/releveDeCompteur.i}
{compta/include/aparm.i}
{compta/include/tva.i}

function existeCle returns logical private(pcTypemandat as character, piNumeroMandat as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :  extrait de adb/tach.prmmtrlv.p
    ------------------------------------------------------------------------------*/
    if can-find(first clemi no-lock
                where clemi.tpcon = pcTypemandat
                  and clemi.nocon = piNumeroMandat
                  and clemi.cdeta <> "S"
                  and clemi.nbtot > 0) then return true.
    mError:createError({&error}, 103921).
    return false.
end function.

function libelleUniteReleve returns character private(pcCodeUnite as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voPclie as class pclie no-undo.
    define variable vcLibelleUniteReleve as character no-undo.

    if pcCodeUnite >= "00100" then do:
        assign
            voPclie              = new pclie("CDUNI", pcCodeUnite)
            vcLibelleUniteReleve = voPclie:zon02
        .
        delete object voPclie.
        return vcLibelleUniteReleve.
    end.
    else return outilTraduction:getLibelleParam("CDUNI", pcCodeUnite).
end function.

function typeTacheReleve return character private(pcTypeMandat as character, pcTypeCompteur as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche du type de tache relevé associée au type de compteur + type de mandat (gérance/syndic)
    Notes  :
    ------------------------------------------------------------------------------*/
   define variable vcTypeTacheReleve as character no-undo.
   case pcTypeCompteur:
        when {&TYPECOMPTEUR-EauFroide} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-eauFroideGerance} else {&TYPETACHE-eauFroide}).
        when {&TYPECOMPTEUR-EauChaude} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-eauChaudeGerance} else {&TYPETACHE-eauChaude}).
        when {&TYPECOMPTEUR-Thermie} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-thermieGerance} else {&TYPETACHE-thermie}).
        when {&TYPECOMPTEUR-Electricite} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then "" else {&TYPETACHE-electricite}).
        when {&TYPECOMPTEUR-UniteEvaporation} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then "" else {&TYPETACHE-uniteEvaporation}).
        when {&TYPECOMPTEUR-Frigorie} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then "" else {&TYPETACHE-frigorie}).
        when {&TYPECOMPTEUR-TotalGaz} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-TotalGazGerance} else {&TYPETACHE-TotalGaz}).
        when {&TYPECOMPTEUR-GazDeFrance} then
            vcTypeTacheReleve = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-GazGerance} else {&TYPETACHE-Gaz}).
        otherwise do:
            mError:createError({&error}, 1000596, pcTypeCompteur). // Type de compteur &1 inconnu."
            return "".
        end.
    end case.
    if vcTypeTacheReleve = "" then mError:createError({&error}, 1000603, pcTypeCompteur).  // Le type de compteur &1 n'est pas géré pour un mandat de gérance
    return vcTypeTacheReleve.
end function.

function codeUniteReleve return character private(pcTypeCompteur as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche du code unité associé au type de compteur
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcCodeUniteReleve as character no-undo.
    case pcTypeCompteur:
        when {&TYPECOMPTEUR-EauFroide} or when {&TYPECOMPTEUR-EauChaude} or when {&TYPECOMPTEUR-TotalGaz}
     or when {&TYPECOMPTEUR-GazDeFrance}      then vcCodeUniteReleve = {&CODEUNITE-M3}.
        when {&TYPECOMPTEUR-Thermie}         then vcCodeUniteReleve = {&CODEUNITE-Thermie}.
        when {&TYPECOMPTEUR-Electricite}      then vcCodeUniteReleve = {&CODEUNITE-KWH}.
        when {&TYPECOMPTEUR-UniteEvaporation} then vcCodeUniteReleve = {&CODEUNITE-UniteEvaporation}.
        when {&TYPECOMPTEUR-Frigorie}        then vcCodeUniteReleve = {&CODEUNITE-MWH}.
        otherwise mError:createError({&error}, 1000596, pcTypeCompteur). // Type de compteur &1 inconnu
    end case.
    return vcCodeUniteReleve.
end function.

function idReleveCoproPere return integer private(piNorliGerance as integer, piNumeroImmeuble as integer):
    /*------------------------------------------------------------------------------
    Purpose: recherche du no identifiant du relevé de copro à l'origine du relevé de gérance
             (si paramètre client "RLGER" indiquant que les relevés de gérance sont créés par la copropriété
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNorliCopro    as integer   no-undo.
    define variable voReleveGerance as class parametrageReleveGerance no-undo.
    define buffer erlet   for erlet.
    define buffer vberlet for erlet.

    voReleveGerance = new parametrageReleveGerance().
    if voReleveGerance:isDbParameter and voReleveGerance:isReleveEauGeranceCreeParLaCopropriete() then do:
       // positionnement sur le releve de gérance
        for first erlet no-lock
            where   erlet.norli = piNorliGerance:
            // recherche du relevé correspondant en copro
            find first vberlet no-lock
                where vberlet.tpcon = {&TYPECONTRAT-mandat2Syndic}
                and vberlet.noimm = piNumeroImmeuble
                and vberlet.cdbat = erlet.cdbat
                and vberlet.tpcpt = erlet.tpcpt
                and vberlet.dtrlv = erlet.dtrlv
                no-error.
            if available(vberlet) then viNorliCopro = vberlet.norli.
        end.
    end.
    delete object voReleveGerance no-error.
    return viNorliCopro.
end function.

procedure getCompteurPrix:
    /*------------------------------------------------------------------------------
    Purpose: liste des compteurs et paramétrage d'un type de compteur d'un mandat
    Notes  : service externe (beReleveCompteur.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat   as character no-undo.
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeCompteur as character no-undo.
    define output parameter table for ttTacheReleve.
    define output parameter table for ttListeCompteur.

    define variable vcTypeTacheReleve as character no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttTacheReleve.
    empty temp-table ttListeCompteur.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    vcTypeTacheReleve = typeTacheReleve(pcTypeMandat, pcTypeCompteur).
    if mError:erreur() then return.

    find first tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = vcTypeTacheReleve
          and tache.notac = 1 no-error.
    if available tache
    then do:
        create ttTacheReleve.
        assign
            ttTacheReleve.iNumeroTache                     = tache.noita
            ttTacheReleve.cTypeContrat                     = tache.tpcon
            ttTacheReleve.iNumeroContrat                   = tache.nocon
            ttTacheReleve.cTypeTache                       = tache.tptac
            ttTacheReleve.iChronoTache                     = tache.notac
            ttTacheReleve.cTypeCompteur                    = pcTypeCompteur
            ttTacheReleve.cLibelleTypeCompteur             = outilTraduction:getLibelleParam("TPCPT", ttTacheReleve.cTypeCompteur)
            ttTacheReleve.cCodeUnite                       = tache.cdreg
            ttTacheReleve.cLibelleCodeUnite                = outilTraduction:getLibelleParam("CDUNI", ttTacheReleve.cCodeUnite)
            ttTacheReleve.iCodeRubriqueAna                 = if length(tache.pdreg, "character") = 7 then integer(substring(tache.pdreg, 1, 3, "character")) else 0
            ttTacheReleve.iCodeSousRubriqueAna             = if length(tache.pdreg, "character") = 7 then integer(substring(tache.pdreg, 4, 3, "character")) else 0
            ttTacheReleve.iCodeFiscalite                   = if length(tache.pdreg, "character") = 7 then integer(substring(tache.pdreg, 7, 1, "character")) else 0
            ttTacheReleve.dPrixFluideTTC                   = if pcTypeCompteur <> {&TYPECOMPTEUR-EauChaude} then decimal(entry(1, tache.lbdiv, "@")) else if num-entries(tache.lbdiv, "@") >= 2 then decimal(entry(2, tache.lbdiv, "@")) else 0
            ttTacheReleve.dTauxTVAFluide                   = if pcTypeCompteur <> {&TYPECOMPTEUR-EauChaude} then decimal(tache.ntges) else decimal(tache.cdhon)
            ttTacheReleve.cCleRepartitionFluide            = tache.dcreg
            ttTacheReleve.cCleRecuperationFluide           = if pcTypeCompteur <> {&TYPECOMPTEUR-EauChaude} then tache.utreg else tache.tphon
            ttTacheReleve.dPrixEauFroideRechaufTTC         = if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude}  then decimal(entry(1, tache.lbdiv, "@")) else 0
            ttTacheReleve.dTauxTVAEauFroideRechauf         = if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude}  then decimal(tache.ntges) else 0
            ttTacheReleve.cCleRecuperationEauFroideRechauf = if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude}  then tache.utreg else ""
            ttTacheReleve.cCleRecuperation2                = if pcTypeCompteur = {&TYPECOMPTEUR-Thermie}   then tache.tphon else ""
            ttTacheReleve.dPouvoirCalorifique              = if pcTypeCompteur = {&TYPECOMPTEUR-GazDeFrance} and num-entries(tache.lbdiv, "@") >= 2 then decimal(entry(2, tache.lbdiv, "@")) else 0
            ttTacheReleve.dtTimestamp                      = datetime(tache.dtmsy, tache.hemsy)
            ttTacheReleve.CRUD                             = 'R'
            ttTacheReleve.rRowid                           = rowid(tache)
        .
        run getCompteur(pcTypeMandat, piNumeroMandat, pcTypeCompteur).
    end.
    else existeCle(pcTypeMandat, piNumeroMandat).  // positionne éventuellement une erreur.

end procedure.

procedure setTacheReleve:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beReleveCompteur.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheReleve.
    define input parameter table for ttListeCompteur.

    run ctrlAvantMajTache.
    if not mError:erreur() then run majTache.
end procedure.

procedure ctrlAvantMajTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Contrôles avant appel CRUD
    ------------------------------------------------------------------------------*/

bouclectrlAvantMajTache:
    for each ttTacheReleve
        where lookup(ttTacheReleve.CRUD, "C,U,D") > 0:
        if not can-find(first ctrat no-lock
                        where ctrat.tpcon = ttTacheReleve.cTypeContrat
                          and ctrat.nocon = ttTacheReleve.iNumeroContrat)
        then do:
            mError:createErrorGestion({&error}, 211656, substitute('&2&1', separ[1], string(ttTacheReleve.iNumeroContrat))).
            leave bouclectrlAvantMajTache.
        end.
        if ttTacheReleve.CRUD = "C"
        and can-find(first tache no-lock
                     where tache.tpcon = ttTacheReleve.cTypeContrat
                       and tache.nocon = ttTacheReleve.iNumeroContrat
                       and tache.tptac = ttTacheReleve.cTypeTache) then do:
            mError:createError({&error}, 1000412).   //création d'une tache existante
            leave bouclectrlAvantMajTache.
        end.
        if ttTacheReleve.CRUD = "D" then do:
            // controles avant suppression
            if can-find(first erlet no-lock
                        where erlet.tpcon = ttTacheReleve.cTypeContrat
                          and erlet.nocon = ttTacheReleve.iNumeroContrat
                          and erlet.tpcpt = ttTacheReleve.cTypeCompteur)
            then do:
                mError:createError({&error}, 1000604).   // "Suppression impossible : des relevés ont déjà été saisi pour ce type de compteur"
                leave bouclectrlAvantMajTache.
            end.
        end.
        else do:
            // verzonsai
            if not can-find(first sys_pr no-lock
                            where sys_pr.tppar = "CDUNI" and sys_pr.cdpar = ttTacheReleve.cCodeUnite)
            then do:
                mError:createError({&error}, 1000605, ttTacheReleve.cCodeUnite).   // Le code unité &1 est invalide
                leave bouclectrlAvantMajTache.
            end.
            if not can-find(first alrub no-lock
                            where alrub.soc-cd = (if ttTacheReleve.cTypeContrat = {&TYPECONTRAT-mandat2Syndic} then integer(mtoken:cRefCopro) else integer(mtoken:cRefGerance))
                              and alrub.rub-cd = string(ttTacheReleve.iCodeRubriqueAna,"999"))
            then do:
                mError:createErrorGestion({&error}, 102155, substitute('&2&1', separ[1], string(ttTacheReleve.iCodeRubriqueAna,"999"))).    // La rubrique %1 n'est pas disponible
                leave bouclectrlAvantMajTache.
            end.
            if not can-find(first alrub no-lock
                            where alrub.soc-cd   = (if ttTacheReleve.cTypeContrat = {&TYPECONTRAT-mandat2Syndic} then integer(mtoken:cRefCopro) else integer(mtoken:cRefGerance))
                              and alrub.rub-cd   = string(ttTacheReleve.iCodeRubriqueAna,"999"))
                              and alrub.ssrub-cd = string(ttTacheReleve.iCodeSousRubriqueAna,"999")
            then do:
                mError:createErrorGestion({&error}, 102156, substitute('&2&1&3', separ[1], string(ttTacheReleve.iCodeRubriqueAna,"999"), string(ttTacheReleve.iCodeSousRubriqueAna,"999"))).    // La sous-rubrique ... n'est pas disponible pour la rubrique ...
                leave bouclectrlAvantMajTache.
            end.
            if ttTacheReleve.iCodeFiscalite < 1 or ttTacheReleve.iCodeFiscalite > 4 then do:
                mError:createError({&error}, 102498).
                leave bouclectrlAvantMajTache.
            end.
            if ttTacheReleve.dPrixFluideTTC = 0 then do:
                mError:createError({&error}, 101462).
                leave bouclectrlAvantMajTache.
            end.
            // Eau chaude : Vérification Prix Eau Chaude > Prix Eau Froide (NB : prix eau froide facultatif)
            if ttTacheReleve.dPrixEauFroideRechaufTTC > ttTacheReleve.dPrixFluideTTC then do:
                mError:createError({&error}, 101374).
                leave bouclectrlAvantMajTache.
            end.
            if not can-find(first clemi no-lock
                            where clemi.tpcon = ttTacheReleve.cTypeContrat
                              and clemi.nocon = ttTacheReleve.iNumeroContrat
                              and clemi.cdcle = ttTacheReleve.cCleRepartitionFluide) then do:
                mError:createError({&error}, 101989).   // Vous devez saisir la clé de répartition .
                leave bouclectrlAvantMajTache.
            end.
            if not can-find(first clemi no-lock
                            where clemi.tpcon = ttTacheReleve.cTypeContrat
                              and clemi.nocon = ttTacheReleve.iNumeroContrat
                              and clemi.cdcle = ttTacheReleve.cCleRecuperationFluide) then do:
                mError:createError({&error}, 101990).   // Vous devez saisir la ou les clé(s) de récupération !!
                leave bouclectrlAvantMajTache.
            end.
            if (ttTacheReleve.cTypeCompteur = {&TYPECOMPTEUR-Thermie}   and ttTacheReleve.cCleRecuperation2 = "")
            or (ttTacheReleve.cTypeCompteur = {&TYPECOMPTEUR-EauChaude} and ttTacheReleve.cCleRecuperationEauFroideRechauf = "")
            then do:
                mError:createError({&error}, 101990).   // Vous devez saisir la ou les clé(s) de récupération !!
                leave bouclectrlAvantMajTache.
            end.
            if ttTacheReleve.dTauxTVAFluide = ?
            or (ttTacheReleve.cTypeCompteur = {&TYPECOMPTEUR-EauChaude}
            and ttTacheReleve.dPrixEauFroideRechaufTTC <> 0
            and ttTacheReleve.dTauxTVAEauFroideRechauf = ?) then do:
                mError:createError({&error}, 109931).       // Taux de TVA invalide
                leave bouclectrlAvantMajTache.
            end.
            // au moins 1 compteur
            if not can-find(first ttListeCompteur
                            where ttListeCompteur.cTypeContrat    = ttTacheReleve.cTypeContrat
                              and ttListeCompteur.iNumeroContrat  = ttTacheReleve.iNumeroContrat
                              and ttListeCompteur.cTypeCompteur   = ttTacheReleve.cTypeCompteur
                              and ttListeCompteur.cNumeroCompteur > "0") then do:
                mError:createError({&error}, 101461).       // Vous devez créer au moins un compteur.
                leave bouclectrlAvantMajTache.
            end.
        end.
    end.
end procedure.

procedure initCompteurPrix:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beReleveCompteur.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeCompteur as character no-undo.
    define output parameter table for ttTacheReleve.
    define output parameter table for ttListeCompteur.

    define variable vcTypeTacheReleve     as character no-undo.
    define variable viCodeRubriqueAna     as integer   no-undo.
    define variable viCodeSousRubriqueAna as integer   no-undo.
    define variable viCodeFiscalite       as integer   no-undo.

    empty temp-table ttTacheReleve.
    empty temp-table ttListeCompteur.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat) then do:
        mError:createError({&error}, 100057).
        return.
    end.
    vcTypeTacheReleve = typeTacheReleve(pcTypeMandat, pcTypeCompteur).
    if mError:erreur() then return.

    if can-find(first tache no-lock
                where tache.tpcon = pcTypeMandat
                  and tache.nocon = piNumeroMandat
                  and tache.tptac = vcTypeTacheReleve) then do:
        mError:createError({&error}, 1000410).             //demande d'initialisation d'une tache existante
        return.
    end.
    if not existeCle(pcTypeMandat, piNumeroMandat) then return.

    // Recherche du code analytique par défaut associé à une tache relevé eau...
    run codeAnalytiqueTacheReleve(vcTypeTacheReleve, output viCodeRubriqueAna, output viCodeSousRubriqueAna, output viCodeFiscalite).
    create ttTacheReleve.
    assign
        ttTacheReleve.iNumeroTache                     = 0
        ttTacheReleve.cTypeContrat                     = pcTypeMandat
        ttTacheReleve.iNumeroContrat                   = piNumeroMandat
        ttTacheReleve.cTypeTache                       = vcTypeTacheReleve
        ttTacheReleve.iChronoTache                     = 0
        ttTacheReleve.cTypeCompteur                    = pcTypeCompteur
        ttTacheReleve.cLibelleTypeCompteur             = outilTraduction:getLibelleParam("TPCPT", ttTacheReleve.cTypeCompteur)
        ttTacheReleve.cCodeUnite                       = codeUniteReleve (pcTypeCompteur)
        ttTacheReleve.cLibelleCodeUnite                = outilTraduction:getLibelleParam("CDUNI", ttTacheReleve.cCodeUnite)
        ttTacheReleve.iCodeRubriqueAna                 = viCodeRubriqueAna
        ttTacheReleve.iCodeSousRubriqueAna             = viCodeSousRubriqueAna
        ttTacheReleve.iCodeFiscalite                   = viCodeFiscalite
        ttTacheReleve.dPrixFluideTTC                   = 0
        ttTacheReleve.dTauxTVAFluide                   = 0
        ttTacheReleve.cCleRepartitionFluide            = ""
        ttTacheReleve.cCleRecuperationFluide           = ""
        ttTacheReleve.dPrixEauFroideRechaufTTC         = 0
        ttTacheReleve.dTauxTVAEauFroideRechauf         = 0
        ttTacheReleve.cCleRecuperationEauFroideRechauf = ""
        ttTacheReleve.cCleRecuperation2                = ""
        ttTacheReleve.dPouvoirCalorifique              = 0
        ttTacheReleve.CRUD  = 'C'
    .
    run getCompteur(pcTypeMandat, piNumeroMandat, pcTypeCompteur).

end procedure.

procedure getCompteur private:
    /*------------------------------------------------------------------------------
    Purpose: Liste des lots du mandat présents dans une unité de location au cours des 2 dernières années.
             + Liste des compteurs pour chacun des lots (1 à n)  (cteur)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeCompteur as character no-undo.

    define variable vdaDateDebutExtraction as date      no-undo.
    define variable vlCompteurGerance      as logical   no-undo.
    define variable viNombreCompteurLot    as integer   no-undo.
    define variable viCodageMandatGerance  as int64     no-undo.
    define variable viNumeroCodage         as int64     no-undo.
    define variable viNumeroLocataire      as int64     no-undo.
    define variable vcNomLocataire         as character no-undo.
    define variable vdaDateEntreeLocataire as date      no-undo.
    define variable vdaDateSortieLocataire as date      no-undo.

    define buffer perio for perio.
    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer vbcpuni for cpuni.
    define buffer local for local.
    define buffer cteur for cteur.

    assign
        viCodageMandatGerance  = 10000 + piNumeroMandat       // todo : à supprimer quand les structures de cteur seront corrigées (V19.00 ?)
        vdaDateDebutExtraction = date(month(today), 01, year(today) - 2)
    .
    /* ajout SY le 25/06/2010 : vieille période de charge ? */
    for first perio  no-lock
        where Perio.TpCtt = pcTypeMandat
          and Perio.Nomdt = piNumeroMandat
          and Perio.Noper = 0
          and perio.cdtrt = "00001":
        vdaDateDebutExtraction = minimum(vdaDateDebutExtraction, perio.dtdeb).
    end.
    for each unite no-lock
        where unite.nomdt = piNumeroMandat
          and unite.noapp <> {&TYPEUL-reserveProprietaire}
          and unite.noapp <> {&TYPEUL-lotNonAffecte}
          and (unite.noact = 0 or (unite.noact > 0 and (unite.dtfin = ? or unite.dtfin > vdaDateDebutExtraction)))
      , first cpuni no-lock
        where cpuni.noMdt = unite.noMdt
          and cpuni.noApp = unite.noApp
          and cpuni.noCmp = unite.noCmp
        by unite.noapp by unite.nocmp:
        //Balayer la composition pour récupérer la liste des lots
        for each vbcpuni no-lock
            where vbcpuni.nomdt = unite.nomdt
              and vbcpuni.noapp = unite.noapp
              and vbcpuni.nocmp = unite.nocmp
          , first local no-lock
            where local.noimm = vbcpuni.noimm
              and local.nolot = vbcpuni.nolot:
            find first ttListeCompteur
                where ttListeCompteur.iNumeroImmeuble = local.noimm
                  and ttListeCompteur.iNumeroLot      = local.noLot no-error.
            if not available ttListeCompteur then do:
                create ttListeCompteur.
                assign
                    ttListeCompteur.cTypeContrat      = pcTypeMandat
                    ttListeCompteur.iNumeroContrat    = piNumeroMandat
                    ttListeCompteur.iCodageContrat    = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then 10000 + piNumeroMandat else vbcpuni.noimm)
                    ttListeCompteur.iNumeroImmeuble   = vbcpuni.noimm
                    ttListeCompteur.iNumeroLot        = vbcpuni.nolot
                    ttListeCompteur.cTypeCompteur     = pcTypeCompteur
                    ttListeCompteur.cCodeUnite        = ""
                    ttListeCompteur.cLibelleNatureLot = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
                    // récupération des compteurs du Lot. : 1) en gérance  2) en copro
                    viNombreCompteurLot = 0
                    viNumeroCodage      = 0
                    vlCompteurGerance   = true
                .
                if can-find(first cteur no-lock
                            where cteur.tpcpt = pcTypeCompteur
                              and cteur.nolot = local.nolot
                              and cteur.noimm = viCodageMandatGerance)
                then viNumeroCodage = viCodageMandatGerance.
                else if can-find(first cteur no-lock
                                 where cteur.tpcpt = pcTypeCompteur
                                   and cteur.nolot = local.nolot
                                   and cteur.noimm = local.noimm)
                then assign
                    vlCompteurGerance = false
                    viNumeroCodage    = local.noimm
                .
                if viNumeroCodage > 0
                then for each cteur no-lock
                    where cteur.tpcpt = pcTypeCompteur
                      and cteur.nolot = local.nolot
                      and cteur.noimm = viNumeroCodage:
                    viNombreCompteurLot = viNombreCompteurLot + 1.
                    if viNombreCompteurLot > 1 then do:
                        create ttListeCompteur.
                        assign
                            ttListeCompteur.cTypeContrat    = pcTypeMandat
                            ttListeCompteur.iNumeroContrat  = piNumeroMandat
                            ttListeCompteur.iCodageContrat  = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then 10000 + piNumeroMandat else vbcpuni.noimm)
                            ttListeCompteur.iNumeroImmeuble = vbcpuni.noimm
                            ttListeCompteur.iNumeroLot      = vbcpuni.nolot
                            ttListeCompteur.cTypeCompteur   = pcTypeCompteur
                            ttListeCompteur.cCodeUnite      = ""
                        .
                    end.
                    assign
                        ttListeCompteur.cNumeroCompteur      = cteur.nocpt
                        ttListeCompteur.cEmplacementCompteur = cteur.lbemp
                        ttListeCompteur.daDateInstallation   = cteur.dtins
                    .
                    if vlCompteurGerance then assign
                        ttListeCompteur.CRUD        = "R"
                        ttListeCompteur.dtTimestamp = datetime(cteur.dtmsy, cteur.hemsy)
                        ttListeCompteur.rRowid      = rowid(cteur)
                    .
                    else ttListeCompteur.CRUD = "C".
                end.
            end.
        end.
    end.
    // mise à jour du dernier locataire occupant pour chaque lot
    for each ttListeCompteur
      , first local no-lock
        where local.noimm = ttListeCompteur.iNumeroImmeuble
          and local.nolot = ttListeCompteur.iNumeroLot
        break by ttListeCompteur.iNumeroLot by ttListeCompteur.cTypeCompteur by ttListeCompteur.cNumeroCompteur:

        if first-of(ttListeCompteur.iNumeroLot)
            then run dernierLocataireLotDuMandat(buffer local
                                                 ,piNumeroMandat
                                                 ,output viNumeroLocataire
                                                 ,output vcNomLocataire
                                                 ,output vdaDateEntreeLocataire
                                                 ,output vdaDateSortieLocataire).
        assign
            ttListeCompteur.iNumeroLocataire = viNumeroLocataire
            ttListeCompteur.cNomLocataire    = vcNomLocataire
            ttListeCompteur.daDateEntree     = vdaDateEntreeLocataire
            ttListeCompteur.daDateSortie     = vdaDateSortieLocataire
        .
    end.
end procedure.

procedure dernierLocataireLotDuMandat private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du dernier locataire du lot
    Notes  : En cas de lot divisible, la procédure ne renvoie qu'un seul des locataires
    ------------------------------------------------------------------------------*/
    define parameter buffer local for local.
    define input  parameter piNumeroMandat     as integer   no-undo.
    define output parameter piNumeroBail       as integer   no-undo.
    define output parameter pcNomLocataire     as character no-undo.
    define output parameter pdaEntreeLocataire as date      no-undo.
    define output parameter pdaSortieLocataire as date      no-undo.

    define variable viNumeroBailMin as int64 no-undo.
    define variable viNumeroBailMax as int64 no-undo.

    define buffer cpuni   for cpuni.
    define buffer unite   for unite.
    define buffer ctrat   for ctrat.
    define buffer tache   for tache.

    for each unite no-lock
        where unite.nomdt = piNumeroMandat
          and unite.noact = 0
          and unite.noapp <> {&TYPEUL-reserveProprietaire}
          and unite.noapp <> {&TYPEUL-lotNonAffecte}
      , each cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.noimm = local.noimm
          and cpuni.noLot = local.nolot:
        assign
            viNumeroBailMin = piNumeroMandat * 100000 + unite.NoApp * 100 + 1
            viNumeroBailMax = piNumeroMandat * 100000 + unite.NoApp * 100 + 99
        .
dernier:
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon >= viNumeroBailMin and ctrat.nocon <= viNumeroBailMax
              and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}
          , last tache no-lock
            where Tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-quittancement}
            by ctrat.nocon descending:
            assign
                piNumeroBail       = ctrat.nocon
                pcNomLocataire     = ctrat.lbnom
                pdaEntreeLocataire = tache.dtdeb
                pdaSortieLocataire = tache.dtfin
            .
            leave dernier.
        end.
    end.

end procedure.

procedure codeAnalytiqueTacheReleve private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du code analytique par défaut associé à une tache relevé eau...
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTacheReleve     as character no-undo.
    define output parameter piCodeRubriqueAna     as integer   no-undo.
    define output parameter piCodeSousRubriqueAna as integer   no-undo.
    define output parameter piCodeFiscalite       as integer   no-undo.

    case pcTypeTacheReleve:
        when {&TYPETACHE-eauChaude} or when {&TYPETACHE-eauChaudeGerance} then assign
            piCodeRubriqueAna     = 080
            piCodeSousRubriqueAna = 249
        .
        when {&TYPETACHE-eauFroide}  or when {&TYPETACHE-eauFroideGerance} then assign
            piCodeRubriqueAna     = 020
            piCodeSousRubriqueAna = 249
        .
        when {&TYPETACHE-thermie} or when {&TYPETACHE-thermieGerance} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 235
        .
        when {&TYPETACHE-TotalGaz} or when {&TYPETACHE-TotalGazGerance} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 244
        .
        when {&TYPETACHE-Gaz} or when {&TYPETACHE-GazGerance} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 244
        .
        when {&TYPETACHE-electricite} then assign
            piCodeRubriqueAna     = 010
            piCodeSousRubriqueAna = 200
        .
        when {&TYPETACHE-frigorie} then assign
            piCodeRubriqueAna     = 670
            piCodeSousRubriqueAna = 287
        .
        when {&TYPETACHE-uniteEvaporation} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 235
        .
    end case.
    piCodeFiscalite = 2.
end procedure.
procedure codeAnalytiqueRecuperationReleve private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du(des) code analytique par défaut associé à la(les) récupération d'un relevé eau...
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeCompteur         as character no-undo.
    define output parameter piCodeRubriqueAna      as integer   no-undo.
    define output parameter piCodeSousRubriqueAna  as integer   no-undo.
    define output parameter piCodeFiscalite        as integer   no-undo.
    define output parameter pcLibelleRecuperation  as character no-undo.
    define output parameter piCodeRubriqueAna2     as integer   no-undo.
    define output parameter piCodeSousRubriqueAna2 as integer   no-undo.
    define output parameter piCodeFiscalite2       as integer   no-undo.
    define output parameter pcLibelleRecuperation2 as character no-undo.

    case pcTypeCompteur:
        when {&TYPECOMPTEUR-eauFroide} then assign
            piCodeRubriqueAna     = 020
            piCodeSousRubriqueAna = 244
            pcLibelleRecuperation = outilTraduction:getLibelle(102911)
        .
        when {&TYPECOMPTEUR-EauChaude} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 235
            pcLibelleRecuperation = outilTraduction:getLibelle(102838)
            // recup eau froide réchauffée
            piCodeRubriqueAna2     = 020
            piCodeSousRubriqueAna2 = 244
            piCodeFiscalite2       = 2
            pcLibelleRecuperation2 = outilTraduction:getLibelle(102837)
        .
        when {&TYPECOMPTEUR-Thermie} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 235
            pcLibelleRecuperation = outilTraduction:getLibelle(102912)
            // recup 2
            piCodeRubriqueAna2     = 070
            piCodeSousRubriqueAna2 = 235
            piCodeFiscalite2       = 2
            pcLibelleRecuperation2 = outilTraduction:getLibelle(101320)
        .
        when {&TYPECOMPTEUR-TotalGaz} or when {&TYPECOMPTEUR-GazDeFrance} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 244
            pcLibelleRecuperation = outilTraduction:getLibelle(109021)
        .
        when {&TYPECOMPTEUR-electricite} then assign
            piCodeRubriqueAna     = 010
            piCodeSousRubriqueAna = 200
            pcLibelleRecuperation = outilTraduction:getLibelle(102913)
        .
        when {&TYPECOMPTEUR-frigorie} then assign
            piCodeRubriqueAna     = 670
            piCodeSousRubriqueAna = 194
            pcLibelleRecuperation = outilTraduction:getLibelle(102914)
        .
        when {&TYPECOMPTEUR-uniteEvaporation} then assign
            piCodeRubriqueAna     = 070
            piCodeSousRubriqueAna = 235
            pcLibelleRecuperation = outilTraduction:getLibelle(102915)
        .
    end case.
    piCodeFiscalite = 2.
end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhTache            as handle    no-undo.
    define variable vhCttac            as handle    no-undo.
    define variable vhcteur            as handle    no-undo.
    define variable vhaparm            as handle    no-undo.
    define variable viNumeroImmeuble   as integer   no-undo.
    define variable vlParamUniteOeuvre as logical   no-undo.
    define variable vcListeparametrage as character no-undo.
    define variable voparametrageUniteOeuvre as class parametrageUniteOeuvre no-undo.

    define buffer aparm for aparm.
    define buffer cttac for cttac.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    // Gestion des unités d'oeuvre ?
    assign
        voparametrageUniteOeuvre = new parametrageUniteOeuvre()
        vlParamUniteOeuvre       = voparametrageUniteOeuvre:isUniteOeuvre()
    .
    delete object voparametrageUniteOeuvre.
    empty temp-table ttTache.
    empty temp-table ttCttac.
    empty temp-table ttAparm.
    for each ttTacheReleve:
        // immeuble du mandat
        for first intnt no-lock
            where intnt.tpcon = ttTacheReleve.cTypeContrat
              and intnt.nocon = ttTacheReleve.iNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            viNumeroImmeuble = intnt.noidt.
        end.
        create ttTache.
        assign
            ttTache.noita       = ttTacheReleve.iNumeroTache
            ttTache.tpcon       = ttTacheReleve.cTypeContrat
            ttTache.nocon       = ttTacheReleve.iNumeroContrat
            ttTache.tptac       = ttTacheReleve.cTypeTache
            ttTache.notac       = ttTacheReleve.iChronoTache
            ttTache.duree       = viNumeroImmeuble
            ttTache.tpges       = ttTacheReleve.cTypeCompteur
            ttTache.cdreg       = ttTacheReleve.cCodeUnite
            ttTache.pdreg       = string(ttTacheReleve.iCodeRubriqueAna, "999") + string(ttTacheReleve.iCodeSousRubriqueAna, "999") + string(ttTacheReleve.iCodeFiscalite, "9")
            ttTache.dcreg       = ttTacheReleve.cCleRepartitionFluide
            ttTache.ntges       = string(ttTacheReleve.dTauxTVAFluide)
            ttTache.pdges       = ""
            ttTache.ntreg       = ""
            ttTache.utreg       = ttTacheReleve.cCleRecuperationFluide
            ttTache.tphon       = ""
            ttTache.cdhon       = ""
            ttTache.lbdiv       = string(ttTacheReleve.dPrixFluideTTC)
            ttTache.CRUD        = ttTacheReleve.CRUD
            ttTache.dtTimestamp = ttTacheReleve.dtTimestamp
            ttTache.rRowid      = ttTacheReleve.rRowid
        .
        if ttTacheReleve.cTypeCompteur = {&TYPECOMPTEUR-EauChaude}
        then assign
            ttTache.ntges = string(ttTacheReleve.dTauxTVAEauFroideRechauf)
            ttTache.utreg = ttTacheReleve.cCleRecuperationEauFroideRechauf
            ttTache.tphon = ttTacheReleve.cCleRecuperationFluide
            ttTache.cdhon = string(ttTacheReleve.dTauxTVAFluide)
            ttTache.lbdiv = string(ttTacheReleve.dPrixEauFroideRechaufTTC ) + "@" + string(ttTacheReleve.dPrixFluideTTC)
        .
        else if ttTacheReleve.cTypeCompteur = {&TYPECOMPTEUR-GazDeFrance}
        then ttTache.lbdiv = string(ttTacheReleve.dPrixFluideTTC) + "@" + string(ttTacheReleve.dPouvoirCalorifique).
        else if ttTacheReleve.cTypeCompteur = {&TYPECOMPTEUR-Thermie}
        then ttTache.tphon = ttTacheReleve.cCleRecuperation2.
        // Clés en majuscules sans blanc
        assign
            ttTacheReleve.cCleRepartitionFluide            = caps(trim(ttTacheReleve.cCleRepartitionFluide))
            ttTacheReleve.cCleRecuperationFluide           = caps(trim(ttTacheReleve.cCleRecuperationFluide))
            ttTacheReleve.cCleRecuperationEauFroideRechauf = caps(trim(ttTacheReleve.cCleRecuperationEauFroideRechauf))
            ttTacheReleve.cCleRecuperation2                = caps(trim(ttTacheReleve.cCleRecuperation2))
        .
        if lookup(ttTacheReleve.CRUD, "U,C") > 0 then do:
            if not can-find(first cttac no-lock
                where cttac.tpcon = ttTacheReleve.cTypeContrat
                  and cttac.nocon = ttTacheReleve.iNumeroContrat
                  and cttac.tptac = ttTacheReleve.cTypeTache)
            then do:
                create ttCttac.
                assign
                    ttCttac.tpcon = ttTacheReleve.cTypeContrat
                    ttCttac.nocon = ttTacheReleve.iNumeroContrat
                    ttCttac.tptac = ttTacheReleve.cTypeTache
                    ttCttac.CRUD  = "C"
                .
            end.
        end.
        else if ttTacheReleve.CRUD = "D"
        then for first cttac no-lock
            where cttac.tpcon = ttTacheReleve.cTypeContrat
              and cttac.nocon = ttTacheReleve.iNumeroContrat
              and cttac.tptac = ttTacheReleve.cTypeTache:
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
        // Generation des cttac pour les contrats charges locatives
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-prestations}
              and ctrat.nocon >= ttTacheReleve.iNumeroContrat * 100 + 1
              and ctrat.nocon <= ttTacheReleve.iNumeroContrat * 100 + 99:
            if lookup(ttTacheReleve.CRUD, "U,C") > 0
            then do:
                if not can-find(first cttac no-lock
                    where cttac.tpcon = ctrat.tpcon
                      and cttac.nocon = ctrat.nocon
                      and cttac.tptac = ttTacheReleve.cTypeTache)
                then do:
                    create ttCttac.
                    assign
                        ttCttac.tpcon = ctrat.tpcon
                        ttCttac.nocon = ctrat.nocon
                        ttCttac.tptac = ttTacheReleve.cTypeTache
                        ttCttac.CRUD  = "C"
                    .
                end.
            end.
            else if ttTacheReleve.CRUD = "D"
            then for first cttac no-lock
                where cttac.tpcon = ctrat.tpcon
                  and cttac.nocon = ctrat.nocon
                  and cttac.tptac = ttTacheReleve.cTypeTache:
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
        end.
        if vlParamUniteOeuvre then do:
            vcListeparametrage = substitute("&1|&2|&3",
                                            string(ttTacheReleve.iCodeRubriqueAna, "999"),
                                            string(ttTacheReleve.iCodeSousRubriqueAna, "999"),
                                            ttTacheReleve.cCodeUnite).
            if can-find(first sys_pr no-lock
                        where sys_pr.tppar = "CDUNI"
                          and sys_pr.cdpar = ttTacheReleve.cCodeUnite)
            then vcListeparametrage = substitute("&1|&2 &3",
                                                 vcListeparametrage,
                                                 outilTraduction:getLibelleParam("CDUNI", ttTacheReleve.cCodeUnite),
                                                 outilTraduction:getLibelleParam("TPCPT", ttTacheReleve.cTypeCompteur)).
            if lookup(ttTacheReleve.CRUD, "C,U") > 0
            then do:
                if not can-find(first aparm no-lock
                                where aparm.tppar   = "ANACP"
                                  and aparm.etab-cd = ttTacheReleve.iNumeroContrat
                                  and aparm.cdpar   = ttTacheReleve.cTypeCompteur)
                then do:
                    create ttaparm.
                    assign
                        ttaparm.tppar   = "ANACP"
                        ttaparm.etab-cd = ttTacheReleve.iNumeroContrat
                        ttaparm.cdpar   = ttTacheReleve.cTypeCompteur
                        ttaparm.zone2   = vcListeparametrage
                        ttaparm.CRUD  = "C"
                    .
                end.
            end.
            else if lookup(ttTacheReleve.CRUD, "C,U,D") > 0
            then for first aparm no-lock
                where aparm.tppar   = "ANACP"
                  and aparm.etab-cd = ttTacheReleve.iNumeroContrat
                  and aparm.cdpar   = ttTacheReleve.cTypeCompteur:
                create ttaparm.
                assign
                    ttaparm.tppar       = aparm.tppar
                    ttaparm.etab-cd     = aparm.etab-cd
                    ttaparm.cdpar       = aparm.cdpar
                    ttaparm.zone2       = vcListeparametrage
                    ttaparm.CRUD        = ttTacheReleve.CRUD
                    ttaparm.rRowid      = rowid(aparm)
                    ttaparm.dtTimestamp = datetime(aparm.damod, aparm.ihmod)
                .
            end.
        end.
    end.
    // Mise à jour de tache
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    run destroy in vhTache.
    if mError:erreur() then return.

    // Mise à jour des liens tache-contrat (cttac)
    run adblib/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).
    run setCttac in vhCttac(table ttCttac by-reference).
    run destroy in vhCttac.
    if mError:erreur() then return.

    // Mise à jour des compteurs (cteur)
    run adblib/cteur_CRUD.p persistent set vhcteur.
    run getTokenInstance in vhcteur(mToken:JSessionId).
    run setcteur in vhcteur(table ttListeCompteur by-reference).
    for each ttTacheReleve where ttTacheReleve.crud = "D":
        // suppression en masse des compteurs pour le mandat et le type de compteur
        run deleteEnMasseCteur in vhcteur(ttTacheReleve.cTypeContrat, ttTacheReleve.iNumeroContrat, ttTacheReleve.cTypeCompteur).
    end.
    run destroy in vhcteur.
    if mError:erreur() then return.

    if vlParamUniteOeuvre then do:
        run compta/aparm_CRUD.p persistent set vhaparm.
        run getTokenInstance in vhaparm(mToken:JSessionId).
        run setAparm in vhaparm(table ttAparm by-reference).
    end.
end procedure.

procedure initComboReleveDeCompteur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttcombo.

    run chargeCombo.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspr                  as class   syspr                  no-undo.
    define variable voUniteReleve            as class   parametrageUniteReleve no-undo.
    define variable vlParamUniteOeuvre       as logical no-undo.
    define variable voparametrageUniteOeuvre as class   parametrageUniteOeuvre no-undo.

    empty temp-table ttCombo.
    // Gestion des unités d'oeuvre ?
    assign
        voparametrageUniteOeuvre = new parametrageUniteOeuvre()
        vlParamUniteOeuvre       = voparametrageUniteOeuvre:isUniteOeuvre()
    .
    delete object voparametrageUniteOeuvre.
    if vlParamUniteOeuvre then do:
        voUniteReleve = new parametrageUniteReleve().
        voUniteReleve:getComboParametre("CMBUNITE", output table ttCombo by-reference).
        delete object voUniteReleve.
    end.
    if not can-find(first ttcombo where ttcombo.cNomCombo = "CMBUNITE") then do:
        voSyspr = new syspr().
        voSyspr:getComboParametre("CDUNI", "CMBUNITE", output table ttCombo by-reference).
        delete object voSyspr.
    end.
    for each ttcombo
        where ttcombo.cNomCombo = "CMBUNITE"
          and ttcombo.cCode >= "00100":
        ttCombo.cLibelle2 = "CLIENT".
    end.
end procedure.

procedure CalculDateExtractionReleve private:
    /*------------------------------------------------------------------------------
    Purpose: Dates d'extraction d'un relevé : Sur la période
             ou depuis le début de la dernière période non traitée
             ou depuis 2 ans
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer pbttReleveDeCompteur for ttReleveDeCompteur.
    define output parameter pdaDateDebutExtraction as date no-undo.
    define output parameter pdaDateFinExtraction   as date no-undo.
    define buffer perio for perio.

    if pbttReleveDeCompteur.iNumeroExercice > 0
    and pbttReleveDeCompteur.iNumeroExercice < 99
    then for first perio  no-lock
        where perio.tpCtt = pbttReleveDeCompteur.cTypeContrat
          and perio.nomdt = pbttReleveDeCompteur.iNumeroContrat
          and perio.noexo = pbttReleveDeCompteur.iNumeroExercice
          and perio.Noper = pbttReleveDeCompteur.iNumeroPeriode:
        assign
            pdaDateDebutExtraction = perio.dtdeb
            pdaDateFinExtraction   = perio.dtfin
        .
    end.
    else do:
        /* 1ère période non traitée ? */
        for first perio  no-lock
            where Perio.TpCtt = pbttReleveDeCompteur.cTypeContrat
              and Perio.Nomdt = pbttReleveDeCompteur.iNumeroContrat
              and perio.cdtrt = {&STATUTPERIODE-EnCours}:
            pdaDateDebutExtraction = perio.dtdeb.
        end.
        if pdaDateDebutExtraction = ?
        then for last perio  no-lock            /* dernière période traitée ? */
            where perio.tpCtt = pbttReleveDeCompteur.cTypeContrat
              and perio.nomdt = pbttReleveDeCompteur.iNumeroContrat
              and lookup(perio.cdtrt, substitute("&1,&2", {&STATUTPERIODE-Historique}, {&STATUTPERIODE-Traite})) > 0:
            pdaDateDebutExtraction = perio.dtfin + 1.
        end.
        if pdaDateDebutExtraction = ? then pdaDateDebutExtraction = date(month(today), 01, year(today) - 2).
    end.
// DEBUG message "pbttReleveDeCompteur.iNumeroExercice = " pbttReleveDeCompteur.iNumeroExercice " pdaDateDebutExtraction = " pdaDateDebutExtraction  " pdaDateFinExtraction = " pdaDateFinExtraction.
end procedure.

procedure getReleveCompteur:
    /*------------------------------------------------------------------------------
    Purpose: Chargement entete + détail d'un ou tous les relevés d'eau ou autre d'un mandat
    Notes  : service externe (beReleveCompteur.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat   as character no-undo.
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeCompteur as character no-undo.
    define input  parameter piNumeroReleve as integer no-undo.
    define output parameter table for ttReleveDeCompteur.
    define output parameter table for ttLigneReleveDeCompteur.

    define variable vcTypeTacheReleve as character no-undo.
    define variable viNumeroImmeuble  as integer   no-undo.

    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer erlet for erlet.
    define buffer lprtb for lprtb.
    define buffer perio for perio.

    empty temp-table ttReleveDeCompteur.
    empty temp-table ttLigneReleveDeCompteur.
    vcTypeTacheReleve = typeTacheReleve(pcTypeMandat, pcTypeCompteur).
    if mError:erreur() then return.

    for first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat:
        viNumeroImmeuble = intnt.noidt.
    end.
    for first tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = vcTypeTacheReleve
          and tache.notac = 1
      , each erlet no-lock
        where erlet.tpcon = pcTypeMandat
          and erlet.nocon = piNumeroMandat
          and erlet.tpcpt = pcTypeCompteur
          and erlet.norlv = (if piNumeroReleve <> 0 then piNumeroReleve else erlet.norlv):
        create ttReleveDeCompteur.
        assign
            ttReleveDeCompteur.cTypeContrat                     = erlet.tpcon
            ttReleveDeCompteur.iNumeroContrat                   = erlet.nocon
            ttReleveDeCompteur.cTypeCompteur                    = erlet.tpcpt
            ttReleveDeCompteur.iNumeroReleve                    = erlet.norlv
            ttReleveDeCompteur.iNumeroIdentifiant               = erlet.norli
            ttReleveDeCompteur.iCodageContrat                   = erlet.noimm
            ttReleveDeCompteur.iNumeroImmeuble                  = viNumeroImmeuble
            ttReleveDeCompteur.cCodeBatiment                    = erlet.cdbat
            ttReleveDeCompteur.daDateReleve                     = erlet.dtrlv
            ttReleveDeCompteur.daDateReception                  = erlet.dtrec
            ttReleveDeCompteur.cModeSaisie                      = erlet.mdsai
            ttReleveDeCompteur.cCodeUnite                       = tache.cdreg       // attention : sys_pr "CDUNI" ou pclie "CDUNI"
            ttReleveDeCompteur.iCodeRubriqueAna                 = if length(erlet.cdana, "character") = 7 then integer(substring(erlet.cdana, 1, 3, "character")) else 0
            ttReleveDeCompteur.iCodeSousRubriqueAna             = if length(erlet.cdana, "character") = 7 then integer(substring(erlet.cdana, 4, 3, "character")) else 0
            ttReleveDeCompteur.iCodeFiscalite                   = if length(erlet.cdana, "character") = 7 then integer(substring(erlet.cdana, 7, 1, "character")) else 0
            ttReleveDeCompteur.cCodeAnalytique                  = erlet.cdana
            ttReleveDeCompteur.cCodeTVAFluide                   = erlet.cdtva
            ttReleveDeCompteur.dPrixFluideTTC                   = erlet.pxuni
            ttReleveDeCompteur.dTauxTVAFluide                   = erlet.txtva
            ttReleveDeCompteur.cCleRecuperationFluide           = erlet.clrec
            ttReleveDeCompteur.cCleRepartitionFluide            = erlet.clrep
            ttReleveDeCompteur.dMontantTTC                      = erlet.totrl
            ttReleveDeCompteur.dMontantTVA                      = erlet.tvarl
            ttReleveDeCompteur.dConsommation                    = erlet.totco
            ttReleveDeCompteur.dMontantRecuperationTTC          = erlet.totrc
            ttReleveDeCompteur.dMontantRecuperationTVA          = erlet.tvarc
            ttReleveDeCompteur.iCodeRubriqueAnaRecuperation     = if length(erlet.anarc, "character") = 7 then integer(substring(erlet.anarc, 1, 3, "character")) else 0
            ttReleveDeCompteur.iCodeSousRubriqueAnaRecuperation = if length(erlet.anarc, "character") = 7 then integer(substring(erlet.anarc, 4, 3, "character")) else 0
            ttReleveDeCompteur.iCodeFiscaliteRecuperation       = if length(erlet.anarc, "character") = 7 then integer(substring(erlet.anarc, 7, 1, "character")) else 0
            ttReleveDeCompteur.cCodeAnalytiqueRecuperation      = erlet.anarc
            ttReleveDeCompteur.cLibelleRecuperation             = erlet.librc
            ttReleveDeCompteur.daDateRelevePrecedent            = erlet.ancdt
            ttReleveDeCompteur.dPrixEauFroideRechaufTTC         = erlet.pxuer
            ttReleveDeCompteur.cCodeTVAEauFroideRechauf         = erlet.cdter
            ttReleveDeCompteur.dTauxTVAEauFroideRechauf         = erlet.txter
            ttReleveDeCompteur.cCleRecuperation2                = erlet.recer
            ttReleveDeCompteur.dMontantRecup2TTC                = erlet.toter
            ttReleveDeCompteur.dMontantRecup2TVA                = erlet.tvaer
            ttReleveDeCompteur.iCodeRubriqueAnaRecup2           = if length(erlet.anaer, "character") = 7 then integer(substring(erlet.anaer, 1, 3, "character")) else 0
            ttReleveDeCompteur.iCodeSousRubriqueAnaRecup2       = if length(erlet.anaer, "character") = 7 then integer(substring(erlet.anaer, 4, 3, "character")) else 0
            ttReleveDeCompteur.iCodeFiscaliteRecup2             = if length(erlet.anaer, "character") = 7 then integer(substring(erlet.anaer, 7, 1, "character")) else 0
            ttReleveDeCompteur.cCodeAnalytiqueRecup2            = erlet.anaer
            ttReleveDeCompteur.cLibelleRecup2                   = erlet.liber
            ttReleveDeCompteur.cCompteurGeneral                 = erlet.lbdiv2
            ttReleveDeCompteur.cPointLivraison                  = erlet.lbdiv3
            ttReleveDeCompteur.lReleveToutBatiment              = erlet.fgrlvimm
            ttReleveDeCompteur.iNumeroIdentifiantReleveCopro    = idReleveCoproPere(erlet.norli,viNumeroImmeuble)
            ttReleveDeCompteur.dPouvoirCalorifique              = if pcTypeCompteur = {&TYPECOMPTEUR-GazDeFrance} and num-entries(tache.lbdiv, "@") >= 2 then decimal(entry(2, tache.lbdiv, "@")) else 0
            ttReleveDeCompteur.iNumeroExercice                  = 99
            ttReleveDeCompteur.iNumeroPeriode                   = 0
            ttReleveDeCompteur.cCodeTraitement                  = {&STATUTPERIODE-EnCours}
            ttReleveDeCompteur.cLibelleCodeTraitement           = outilTraduction:getLibelleParam("CDTRT", ttReleveDeCompteur.cCodeTraitement)
            ttReleveDeCompteur.lModifiable                      = true
            ttReleveDeCompteur.dtTimestamp                      = datetime(erlet.dtmsy, erlet.hemsy)
            ttReleveDeCompteur.CRUD                             = 'R'
            ttReleveDeCompteur.rRowid                           = rowid(erlet)
        .
        for first lprtb no-lock
            where lprtb.tpcon = tache.tpcon
              and lprtb.nocon = tache.nocon
              and lprtb.tpcpt = pcTypeCompteur
              and lprtb.norlv = erlet.norlv
          , first perio no-lock
            where perio.tpctt = lprtb.tpcon
              and perio.nomdt = lprtb.nocon
              and perio.noexo = lprtb.noexe:
            assign
                ttReleveDeCompteur.iNumeroExercice = perio.noexo
                ttReleveDeCompteur.iNumeroPeriode  = perio.noper
                ttReleveDeCompteur.daDebutPeriode  = perio.dtdeb
                ttReleveDeCompteur.daFinPeriode    = perio.dtfin
                ttReleveDeCompteur.cCodeTraitement = perio.cdtrt
                ttReleveDeCompteur.cLibelleCodeTraitement = outilTraduction:getLibelleParam("CDTRT", perio.cdtrt)
            .
            if lookup(perio.cdtrt, substitute("&1,&2", {&STATUTPERIODE-Historique}, {&STATUTPERIODE-Traite}) ) > 0 then ttReleveDeCompteur.lModifiable = false.
        end.
        run getDetailReleveSaisi.
        if ttReleveDeCompteur.lModifiable then run ajoutLotLocataireReleve.
        // Controle des lignes détail
        run controleLigneReleve.
    end.

end procedure.

procedure getDetailReleveSaisi private:
    /*------------------------------------------------------------------------------
    Purpose: lignes détail stockées lors de la saisie du relevé de consommations
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroUL   as integer   no-undo.
    define variable vcNatureBail as character no-undo.
    define buffer erldt for erldt.
    define buffer ctrat for ctrat.

    for each erldt no-lock
        where erldt.norli = ttReleveDeCompteur.iNumeroIdentifiant:
        if ttReleveDeCompteur.cTypeContrat = {&TYPECONTRAT-mandat2Gerance} then do:
            viNumeroUL = truncate(erldt.nocop modulo 100000 / 100, 0).
            if viNumeroUL <> {&TYPEUL-reserveProprietaire}
            then for first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-bail}
                  and ctrat.nocon = erldt.nocop:
                vcNatureBail = ctrat.ntcon.
            end.
        end.
        create ttLigneReleveDeCompteur.
        assign
            ttLigneReleveDeCompteur.cTypeContrat          = ttReleveDeCompteur.cTypeContrat
            ttLigneReleveDeCompteur.iNumeroContrat        = ttReleveDeCompteur.iNumeroContrat
            ttLigneReleveDeCompteur.cTypeCompteur         = ttReleveDeCompteur.cTypeCompteur
            ttLigneReleveDeCompteur.iNumeroReleve         = ttReleveDeCompteur.iNumeroReleve
            ttLigneReleveDeCompteur.iNumeroIdentifiant    = ttReleveDeCompteur.iNumeroIdentifiant
            ttLigneReleveDeCompteur.iNumeroImmeuble       = ttReleveDeCompteur.iNumeroImmeuble
            ttLigneReleveDeCompteur.iNumeroLot            = erldt.nolot
            ttLigneReleveDeCompteur.cLibelleNatureLot     = erldt.ntlot
            ttLigneReleveDeCompteur.cNumeroCompteur       = erldt.nocpt
            ttLigneReleveDeCompteur.lProprietaireOccupant = (viNumeroUL = {&TYPEUL-reserveProprietaire} )
            ttLigneReleveDeCompteur.lProprietaireVacant   = (vcNatureBail = {&NATURECONTRAT-specialVacant} )
            ttLigneReleveDeCompteur.iNumeroLocataire      = erldt.nocop
            ttLigneReleveDeCompteur.cNomLocataire         = erldt.nmcop
            ttLigneReleveDeCompteur.lEstimation           = erldt.FgEst
            ttLigneReleveDeCompteur.dMontantTTC           = erldt.mtlig
            ttLigneReleveDeCompteur.dMontantTVA           = erldt.dttva
            ttLigneReleveDeCompteur.dAncienIndex          = erldt.ancix
            ttLigneReleveDeCompteur.dNouvelIndex          = erldt.NewIx
            ttLigneReleveDeCompteur.dConsommation         = erldt.conso
            ttLigneReleveDeCompteur.dAncienneConso        = erldt.ancco
            ttLigneReleveDeCompteur.cLibelleConso         = erldt.lbdiv
            ttLigneReleveDeCompteur.lErreurLigne          = false
            ttLigneReleveDeCompteur.cLibelleErreur        = ""
            ttLigneReleveDeCompteur.dtTimestamp           = datetime(erldt.dtmsy, erldt.hemsy)
            ttLigneReleveDeCompteur.CRUD                  = "R"
            ttLigneReleveDeCompteur.rRowid                = rowid(erldt)
        .
    end.
end procedure.

procedure ajoutLotLocataireReleve private:
    /*------------------------------------------------------------------------------
    Purpose: Ajout des lots/compteur (1 à n) + locataire(s) du mandat
             présents dans une unité de location
             sur la période ou depuis le début de la dernière période non traitée ou depuis 2 ans
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdaDateDebutExtraction       as date      no-undo.
    define variable vdaDateFinExtraction         as date      no-undo.
    define variable vlChargeLocativeSurULVacante as logical   no-undo.
    define variable viNumeroLocMin               as int64     no-undo.
    define variable viNumeroLocMax               as int64     no-undo.
    define variable vcLibellenatureLot           as character no-undo.
    define variable voChargeLocative as class parametrageChargeLocative no-undo.

    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer local for local.
    define buffer ctrat for ctrat.
    define buffer tache for tache.

    empty temp-table ttListeCompteur.
    voChargeLocative = new parametrageChargeLocative().
    vlChargeLocativeSurULVacante = voChargeLocative:IsChargeLocativeSurULVacante().
    delete object voChargeLocative.
    run CalculDateExtractionReleve(buffer ttReleveDeCompteur, output vdaDateDebutExtraction, output vdaDateFinExtraction).
    run getCompteur(ttReleveDeCompteur.cTypeContrat, ttReleveDeCompteur.iNumeroContrat, ttReleveDeCompteur.cTypeCompteur).

boucleCompteur:
    for each ttListeCompteur
        where ttListeCompteur.cNumeroCompteur > ""
      , first local no-lock
        where local.noimm = ttListeCompteur.iNumeroImmeuble
          and local.nolot = ttListeCompteur.iNumeroLot
        by ttListeCompteur.iNumeroLot:
        // filtrage si relevé au batiment
        if not ttReleveDeCompteur.lReleveToutBatiment
        and ttReleveDeCompteur.cCodeBatiment > ""
        and local.cdbat <> ttReleveDeCompteur.cCodeBatiment then next boucleCompteur.

        vcLibellenatureLot = outilTraduction:getLibelleParam("NTLOT", local.ntlot).
        // boucle sur les compositions UL contenant le lot et recherche des locataires associés
        for each unite no-lock
            where unite.nomdt = ttReleveDeCompteur.iNumeroContrat
              and unite.noapp <> {&TYPEUL-lotNonAffecte}
              and (unite.noact = 0 or (unite.noact > 0 and (unite.dtfin = ? or unite.dtfin > vdaDateDebutExtraction)))
          , first cpuni no-lock
            where cpuni.noMdt = unite.noMdt
              and cpuni.noApp = unite.noApp
              and cpuni.noCmp = unite.noCmp
              and cpuni.nolot = local.nolot
            break by unite.noapp by unite.nocmp:

            if last-of(unite.noapp) then do:
                if unite.noapp = {&TYPEUL-reserveProprietaire}
                then run InitialisationLigneReleve(local.nolot, vcLibellenatureLot, ttListeCompteur.cNumeroCompteur, unite.nomdt * 100000 + 997 * 100 + 01).
                else do:
                    if vlChargeLocativeSurULVacante then run InitialisationLigneReleve(local.nolot, vcLibellenatureLot, ttListeCompteur.cNumeroCompteur, unite.nomdt * 100000 + unite.noapp * 100 + 00).
                    // boucle sur les baux de la période ou à partir de la date de début d'extraction
                    assign
                        viNumeroLocMin = unite.nomdt * 100000 + unite.noapp * 100 + 01
                        viNumeroLocMax = unite.nomdt * 100000 + unite.noapp * 100 + 99
                    .
boucleBaux:
                    for each ctrat no-lock
                        where ctrat.tpcon = {&TYPECONTRAT-bail}
                          and ctrat.nocon >= viNumeroLocMin
                          and ctrat.nocon <= viNumeroLocMax
                      , last tache no-lock
                        where tache.tpcon = ctrat.tpcon
                          and tache.nocon = ctrat.nocon
                          and tache.tptac = {&TYPETACHE-quittancement}:
                        if (vdaDateFinExtraction <> ? and tache.dtdeb > vdaDateFinExtraction)
                        or (tache.dtfin <> ? and tache.dtfin < vdaDateDebutExtraction) then next boucleBaux.

                        run initialisationLigneReleve(local.nolot, vcLibellenatureLot, ttListeCompteur.cNumeroCompteur, ctrat.nocon).
                    end.
                end.
            end.
        end.
    end.
end procedure.

procedure initialisationLigneReleve private:
    /*------------------------------------------------------------------------------
    Purpose: Ajout d'une ligne lot/compteur/locataire si elle n'existe pas déjà
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLot       as integer   no-undo.
    define input parameter pcLibelleNature   as character no-undo.
    define input parameter pcNumeroCompteur  as character no-undo.
    define input parameter piNumeroLocataire as int64     no-undo.

    define variable viNumeroUL     as integer   no-undo.
    define variable vcNatureBail   as character no-undo.
    define variable vcNomlocataire as character no-undo.
    define buffer erlet for erlet.
    define buffer erldt for erldt.
    define buffer ctrat for ctrat.

    if can-find(first ttLigneReleveDeCompteur
                where ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
                  and ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
                  and ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
                  and ttLigneReleveDeCompteur.iNumeroReleve      = ttReleveDeCompteur.iNumeroReleve
                  and ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant
                  and ttLigneReleveDeCompteur.iNumeroLot         = piNumeroLot
                  and ttLigneReleveDeCompteur.cNumeroCompteur    = pcNumeroCompteur
                  and ttLigneReleveDeCompteur.iNumeroLocataire   = piNumeroLocataire) then return.

    if ttReleveDeCompteur.cTypeContrat = {&TYPECONTRAT-mandat2Gerance} then do:
        viNumeroUL = truncate(piNumeroLocataire modulo 100000 / 100, 0).
        if viNumeroUL = {&TYPEUL-reserveProprietaire}
        then for first ctrat no-lock
            where ctrat.tpcon = ttReleveDeCompteur.cTypeContrat
              and ctrat.nocon = ttReleveDeCompteur.iNumeroContrat:
            vcNomlocataire = ctrat.lbnom.
        end.
        else for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon = piNumeroLocataire:
            assign
                vcNatureBail   = ctrat.ntcon
                vcNomlocataire = ctrat.lbnom
            .
        end.
    end.
    create ttLigneReleveDeCompteur.
    assign
        ttLigneReleveDeCompteur.cTypeContrat          = ttReleveDeCompteur.cTypeContrat
        ttLigneReleveDeCompteur.iNumeroContrat        = ttReleveDeCompteur.iNumeroContrat
        ttLigneReleveDeCompteur.cTypeCompteur         = ttReleveDeCompteur.cTypeCompteur
        ttLigneReleveDeCompteur.iNumeroReleve         = ttReleveDeCompteur.iNumeroReleve
        ttLigneReleveDeCompteur.iNumeroIdentifiant    = ttReleveDeCompteur.iNumeroIdentifiant
        ttLigneReleveDeCompteur.iNumeroImmeuble       = ttReleveDeCompteur.iNumeroImmeuble
        ttLigneReleveDeCompteur.iNumeroLot            = piNumeroLot
        ttLigneReleveDeCompteur.cLibelleNatureLot     = pcLibelleNature
        ttLigneReleveDeCompteur.cNumeroCompteur       = pcNumeroCompteur
        ttLigneReleveDeCompteur.lProprietaireOccupant = (viNumeroUL = {&TYPEUL-reserveProprietaire} )
        ttLigneReleveDeCompteur.lProprietaireVacant   = (vcNatureBail = {&NATURECONTRAT-specialVacant} )
        ttLigneReleveDeCompteur.iNumeroLocataire      = piNumeroLocataire
        ttLigneReleveDeCompteur.cNomLocataire         = vcNomlocataire + (if vcNatureBail = {&NATURECONTRAT-specialVacant} then " - " + outilTraduction:getLibelleProg('O_COT', vcNatureBail) else "")
        ttLigneReleveDeCompteur.lEstimation           = false
        ttLigneReleveDeCompteur.dMontantTTC           = 0
        ttLigneReleveDeCompteur.dMontantTVA           = 0
        ttLigneReleveDeCompteur.dAncienIndex          = 0
        ttLigneReleveDeCompteur.dNouvelIndex          = 0
        ttLigneReleveDeCompteur.dConsommation         = 0
        ttLigneReleveDeCompteur.dAncienneConso        = 0
        ttLigneReleveDeCompteur.cLibelleConso         = ""
        ttLigneReleveDeCompteur.lErreurLigne          = false
        ttLigneReleveDeCompteur.cLibelleErreur        = ""
        ttLigneReleveDeCompteur.dtTimestamp           = ?
        ttLigneReleveDeCompteur.CRUD                  = ""
        ttLigneReleveDeCompteur.rRowid                = ?
    .
    // recherche index et consommation du relevé précédent du compteur
boucleReleve:
    for each erlet no-lock
        where erlet.tpcon = ttReleveDeCompteur.cTypeContrat
          and erlet.nocon = ttReleveDeCompteur.iNumeroContrat
          and erlet.tpcpt = ttReleveDeCompteur.cTypeCompteur
          and (if ttReleveDeCompteur.daDateReleve <> ? then erlet.dtrlv < ttReleveDeCompteur.daDateReleve else true)
      , each erldt no-lock
        where erldt.norli = erlet.norli
          and erldt.nolot = ttLigneReleveDeCompteur.iNumeroLot
          and erldt.nocpt = ttLigneReleveDeCompteur.cNumeroCompteur
          and erldt.mtlig <> 0
        by erlet.dtrlv descending:
// DEBUG message "InitialisationLigneReleve : Lot " ttLigneReleveDeCompteur.iNumeroLot " récupération index et conso relevé no " erlet.norlv " du " erlet.dtrlv.
        assign
            ttLigneReleveDeCompteur.dAncienIndex   = erldt.newix
            ttLigneReleveDeCompteur.dNouvelIndex   = erldt.newix
            ttLigneReleveDeCompteur.dAncienneConso = (if ttLigneReleveDeCompteur.iNumeroLocataire = erldt.nocop then erldt.conso else 0)
        .
        leave boucleReleve.
    end.

end procedure.

procedure initReleveDeCompteur:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation entete + détail d'un relevé d'eau ou autre type d'un mandat
    Notes  : service externe (beReleveCompteur.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat   as character no-undo.
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeCompteur as character no-undo.
    define input  parameter pcReleveImmBat as character no-undo.     // relevé au batiment ("BAT") ou tout batiments confondus ("IMM")
    define input  parameter pcCodeBatiment as character no-undo.     // si "BAT" : code bâtiment
    define output parameter table for ttReleveDeCompteur.
    define output parameter table for ttLigneReleveDeCompteur.

    define variable vcTypeTacheReleve        as character no-undo.
    define variable viNumeroImmeuble         as integer   no-undo.
    define variable vlParamUniteOeuvre       as logical   no-undo.
    define variable vcCodeRubriqueAnaUO      as character no-undo.
    define variable vcCodeSousRubriqueAnaUO  as character no-undo.
    define variable vcCleRecuperationFluide  as character no-undo.
    define variable vcTypeCompteurUO         as character no-undo.
    define variable vcTypeTacheReleveUO      as character no-undo.
    define variable viCodeRubriqueAna        as integer   no-undo.
    define variable viCodeSousRubriqueAna    as integer   no-undo.
    define variable viCodeFiscalite          as integer   no-undo.
    define variable vcLibelleRecuperation    as character no-undo.
    define variable viCodeRubriqueAna2       as integer   no-undo.
    define variable viCodeSousRubriqueAna2   as integer   no-undo.
    define variable viCodeFiscalite2         as integer   no-undo.
    define variable vcLibelleRecuperation2   as character no-undo.
    define variable voparametrageUniteOeuvre as class     parametrageUniteOeuvre no-undo.
    define variable vhProcTVA                as handle    no-undo.

    define buffer tache     for tache.
    define buffer vbtache   for tache.
    define buffer intnt     for intnt.
    define buffer erlet     for erlet.
    define buffer perio     for perio.
    define buffer aparm     for aparm.
    define buffer cecrln    for cecrln.
    define buffer cecrlnana for cecrlnana.
    define buffer ijou      for ijou.

    empty temp-table ttReleveDeCompteur.
    empty temp-table ttLigneReleveDeCompteur.
    vcTypeTacheReleve = typeTacheReleve(pcTypeMandat, pcTypeCompteur).
    if mError:erreur() then return.

    for first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat:
        viNumeroImmeuble = intnt.noidt.
    end.
    if viNumeroImmeuble = 0 then do:
        // Immeuble non trouvé pour mandat %1
        mError:createErrorGestion({&error}, 106470, string(piNumeroMandat)).
        return.
    end.
    // vérification existence du code bâtiment
    if pcReleveImmBat = "BAT"
    and not can-find(first batim no-lock
                     where batim.noimm = viNumeroImmeuble
                       and batim.cdbat = pcCodeBatiment) then do:
        mError:createError({&error}, 103121).
        return.
    end.
    // paramétrage de la tache obligatoire pour pouvoir créer un relevé de compteurs
    if not can-find(first tache no-lock
                    where tache.tpcon = pcTypeMandat
                      and tache.nocon = piNumeroMandat
                      and tache.tptac = vcTypeTacheReleve
                      and tache.notac = 1)
    then do:
        mError:createError({&error}, 103925).    // Vous devez d'abord saisir le paramétrage de ce %s type de compteur (prix, clés...) pour ce mandat.
        return.
    end.
    // Recherche du/des code analytique par défaut associé à la(les) récupérations d'un relevé eau...
    run codeAnalytiqueRecuperationReleve(
        pcTypeCompteur,
        output viCodeRubriqueAna,
        output viCodeSousRubriqueAna,
        output viCodeFiscalite,
        output vcLibelleRecuperation,
        output viCodeRubriqueAna2,
        output viCodeSousRubriqueAna2,
        output viCodeFiscalite2,
        output vcLibelleRecuperation2
    ).
    for first tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = vcTypeTacheReleve
          and tache.notac = 1:
        create ttReleveDeCompteur.
        assign
            ttReleveDeCompteur.cTypeContrat                     = pcTypeMandat
            ttReleveDeCompteur.iNumeroContrat                   = piNumeroMandat
            ttReleveDeCompteur.cTypeCompteur                    = pcTypeCompteur
            ttReleveDeCompteur.iNumeroReleve                    = 0
            ttReleveDeCompteur.iNumeroIdentifiant               = 0
            ttReleveDeCompteur.iCodageContrat                   = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then 10000 + piNumeroMandat else viNumeroImmeuble)
            ttReleveDeCompteur.iNumeroImmeuble                  = viNumeroImmeuble
            ttReleveDeCompteur.cCodeBatiment                    = (if pcReleveImmBat = "BAT" then pcCodeBatiment else "")
            ttReleveDeCompteur.daDateReleve                     = ?
            ttReleveDeCompteur.daDateReception                  = ?
            ttReleveDeCompteur.cModeSaisie                      = {&MODESAISIE-Consommation}
            ttReleveDeCompteur.cCodeUnite                       = tache.cdreg       // attention : sys_pr "CDUNI" ou pclie "CDUNI"
            ttReleveDeCompteur.iCodeRubriqueAna                 = if length(tache.pdreg, "character") = 7 then integer(substring(tache.pdreg, 1, 3, "character")) else 0
            ttReleveDeCompteur.iCodeSousRubriqueAna             = if length(tache.pdreg, "character") = 7 then integer(substring(tache.pdreg, 4, 3, "character")) else 0
            ttReleveDeCompteur.iCodeFiscalite                   = if length(tache.pdreg, "character") = 7 then integer(substring(tache.pdreg, 7, 1, "character")) else 0
            ttReleveDeCompteur.cCodeAnalytique                  = tache.pdreg
            ttReleveDeCompteur.cCodeTVAFluide                   = "00000"
            ttReleveDeCompteur.dPrixFluideTTC                   = if pcTypeCompteur <> {&TYPECOMPTEUR-EauChaude} then decimal(entry(1, tache.lbdiv, "@")) else if num-entries(tache.lbdiv, "@") >= 2 then decimal(entry(2, tache.lbdiv, "@")) else 0
            ttReleveDeCompteur.dTauxTVAFluide                   = if pcTypeCompteur <> {&TYPECOMPTEUR-EauChaude} then decimal(tache.ntges) else decimal(tache.cdhon)
            ttReleveDeCompteur.cCleRecuperationFluide           = if pcTypeCompteur <> {&TYPECOMPTEUR-EauChaude} then tache.utreg else tache.tphon
            ttReleveDeCompteur.cCleRepartitionFluide            = tache.dcreg
            ttReleveDeCompteur.dMontantTTC                      = 0
            ttReleveDeCompteur.dMontantTVA                      = 0
            ttReleveDeCompteur.dConsommation                    = 0
            ttReleveDeCompteur.dMontantRecuperationTTC          = 0
            ttReleveDeCompteur.dMontantRecuperationTVA          = 0
            ttReleveDeCompteur.iCodeRubriqueAnaRecuperation     = viCodeRubriqueAna
            ttReleveDeCompteur.iCodeSousRubriqueAnaRecuperation = viCodeSousRubriqueAna
            ttReleveDeCompteur.iCodeFiscaliteRecuperation       = viCodeFiscalite
            ttReleveDeCompteur.cCodeAnalytiqueRecuperation      = substitute('&1&2&3', string(viCodeRubriqueAna,"999"),string(viCodeSousRubriqueAna,"999"), string(viCodeFiscalite,"9"))
            ttReleveDeCompteur.cLibelleRecuperation             = vcLibelleRecuperation
            ttReleveDeCompteur.daDateRelevePrecedent            = ?
            ttReleveDeCompteur.dPrixEauFroideRechaufTTC         = if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude}  then decimal(entry(1, tache.lbdiv, "@")) else 0
            ttReleveDeCompteur.cCodeTVAEauFroideRechauf         = "00000"
            ttReleveDeCompteur.dTauxTVAEauFroideRechauf         = if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude}  then decimal(tache.ntges) else 0
            ttReleveDeCompteur.cCleRecuperation2                = if pcTypeCompteur = {&TYPECOMPTEUR-Thermie}   then tache.tphon else ""
            ttReleveDeCompteur.dMontantRecup2TTC                = 0
            ttReleveDeCompteur.dMontantRecup2TVA                = 0
            ttReleveDeCompteur.iCodeRubriqueAnaRecup2           = viCodeRubriqueAna2
            ttReleveDeCompteur.iCodeSousRubriqueAnaRecup2       = viCodeSousRubriqueAna2
            ttReleveDeCompteur.iCodeFiscaliteRecup2             = viCodeFiscalite2
            ttReleveDeCompteur.cCodeAnalytiqueRecup2            = if viCodeFiscalite2 > 0 then substitute('&1&2&3', string(viCodeRubriqueAna2,"999"),string(viCodeSousRubriqueAna2,"999"), string(viCodeFiscalite2,"9")) else ""
            ttReleveDeCompteur.cLibelleRecup2                   = vcLibelleRecuperation2
            ttReleveDeCompteur.cCompteurGeneral                 = ""
            ttReleveDeCompteur.cPointLivraison                  = ""
            ttReleveDeCompteur.lReleveToutBatiment              = (pcReleveImmBat <> "BAT")
            ttReleveDeCompteur.iNumeroIdentifiantReleveCopro    = 0
            ttReleveDeCompteur.dPouvoirCalorifique              = if pcTypeCompteur = {&TYPECOMPTEUR-GazDeFrance} and num-entries(tache.lbdiv, "@") >= 2 then decimal(entry(2, tache.lbdiv, "@")) else 0
            ttReleveDeCompteur.iNumeroExercice                  = 99
            ttReleveDeCompteur.iNumeroPeriode                   = 0
            ttReleveDeCompteur.cCodeTraitement                  = {&STATUTPERIODE-EnCours}
            ttReleveDeCompteur.cLibelleCodeTraitement           = outilTraduction:getLibelleParam("CDTRT", ttReleveDeCompteur.cCodeTraitement)
            ttReleveDeCompteur.lModifiable                      = true
            ttReleveDeCompteur.dtTimestamp                      = ?
            ttReleveDeCompteur.CRUD                             = 'C'
            ttReleveDeCompteur.rRowid                           = ?
        .
        // Période de rattachement par défaut : 1ere periode non traitée
        for first perio no-lock
            where perio.tpctt = pcTypeMandat
              and perio.nomdt = piNumeroMandat
              and perio.noper = 0
              and lookup(perio.cdtrt, substitute("&1,&2", {&STATUTPERIODE-Historique}, {&STATUTPERIODE-Traite}) ) = 0:
            assign
                ttReleveDeCompteur.iNumeroExercice = perio.noexo
                ttReleveDeCompteur.iNumeroPeriode  = perio.noper
                ttReleveDeCompteur.daDebutPeriode  = perio.dtdeb
                ttReleveDeCompteur.daFinPeriode    = perio.dtfin
                ttReleveDeCompteur.cCodeTraitement = perio.cdtrt
                ttReleveDeCompteur.cLibelleCodeTraitement = outilTraduction:getLibelleParam("CDTRT", perio.cdtrt)
            .
        end.
        // Taux de TVA
        run compta/outilsTVA.p persistent set vhProcTVA.
        run getTokenInstance in vhProcTVA(mToken:JSessionId).
        run getCodeTVA in vhProcTVA(output table ttTVA).
        run destroy in vhProcTVA.
        find first ttTVA where ttTVA.dTauxTVA = ttReleveDeCompteur.dTauxTVAFluide no-error.
        if available ttTVA then ttReleveDeCompteur.cCodeTVAFluide = ttTVA.cCodeTVA.
        find first ttTVA where ttTVA.dTauxTVA = ttReleveDeCompteur.dTauxTVAEauFroideRechauf no-error.
        if available ttTVA then ttReleveDeCompteur.cCodeTVAEauFroideRechauf = ttTVA.cCodeTVA.
        // Date du relevé précédent
        if pcReleveImmBat = "IMM"
        then for each erlet no-lock
            where erlet.tpcon = pcTypeMandat
              and erlet.nocon = piNumeroMandat
              and erlet.tpcpt = pcTypeCompteur
              and erlet.cdbat = ""
            by erlet.dtrlv descending:
            ttReleveDeCompteur.daDateRelevePrecedent = erlet.dtrlv.
            leave.
        end.
        else for each erlet no-lock
            where erlet.tpcon = pcTypeMandat
              and erlet.nocon = piNumeroMandat
              and erlet.tpcpt = pcTypeCompteur
              and erlet.cdbat = pcCodeBatiment
            by erlet.dtrlv descending:
            ttReleveDeCompteur.daDateRelevePrecedent = erlet.dtrlv.
            leave.
        end.
       // Gestion des unités d'oeuvre ?
        assign
            voparametrageUniteOeuvre = new parametrageUniteOeuvre()
            vlParamUniteOeuvre       = voparametrageUniteOeuvre:isUniteOeuvre()
        .
        delete object voparametrageUniteOeuvre.
        if vlParamUniteOeuvre then do:
            // Récupération paramètres unité d'oeuvre et prix unitaire en fct de la dernière facture du mandat
            // pour l'eau chaude : Récupération du paramètrage rubrique analytique EF
            assign
                vcTypeCompteurUO        = if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude} then {&TYPECOMPTEUR-EauFroide} else pcTypeCompteur
                vcTypeTacheReleveUO     = if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude} then (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-eauFroideGerance} else {&TYPETACHE-eauFroide}) else vcTypeTacheReleve
                vcCleRecuperationFluide = tache.utreg
            .
            if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude}
            then for first vbtache no-lock
                where vbtache.tpcon = pcTypeMandat
                  and vbtache.nocon = piNumeroMandat
                  and vbtache.tptac = vcTypeTacheReleveUO
                  and vbtache.notac = 1:
                vcCleRecuperationFluide = vbtache.utreg.
            end.
            /* Récupération du parametrage UO au mandat  */
            find first aparm no-lock
                where aparm.tppar   = "ANACP"
                  and aparm.etab-cd = piNumeroMandat
                  and aparm.cdpar = vcTypeCompteurUO no-error.
            if not available aparm  /* Récupération du parametrage UO au cabinet */
            then find first aparm  no-lock
                where aparm.tppar = "ANACP"
                  and aparm.cdpar = vcTypeCompteurUO no-error.
            if available aparm then assign
                vcCodeRubriqueAnaUO     = entry(1, aparm.zone2, "|")
                vcCodeSousRubriqueAnaUO = entry(2, aparm.zone2, "|")
            .
            // 19/04/2018 : SPo -> PM : test modifications proposées OK
            if vcCodeRubriqueAnaUO > ""
            then for each cecrlnana no-lock
                where cecrlnana.soc-cd  = integer((if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro))
                  and cecrlnana.etab-cd = piNumeroMandat
                  and cecrlnana.ana1-cd = vcCodeRubriqueAnaUO
                  and cecrlnana.ana2-cd = vcCodeSousRubriqueAnaUO
                  and cecrlnana.ana4-cd = vcCleRecuperationFluide
                  and cecrlnana.qte <> 0
              , first ijou no-lock
                where ijou.soc-cd    = cecrlnana.soc-cd
                  and ijou.etab-cd   = cecrlnana.etab-cd
                  and ijou.jou-cd    = cecrlnana.jou-cd
                  and ijou.natjou-cd = {&NATJOUCD-achat}  /* journal d'achat */
                by cecrlnana.dacompta descending:
                for first cecrln no-lock
                    where cecrln.soc-cd    = cecrlnana.soc-cd
                      and cecrln.etab-cd   = cecrlnana.etab-cd
                      and cecrln.jou-cd    = cecrlnana.jou-cd
                      and cecrln.prd-cd    = cecrlnana.prd-cd
                      and cecrln.prd-num   = cecrlnana.prd-num
                      and cecrln.piece-int = cecrlnana.piece-int
                      and cecrln.lig       = cecrlnana.lig:
                    assign
                        ttReleveDeCompteur.cRefDocumentFactureUO = cecrln.ref-num
                        ttReleveDeCompteur.dQuantiteFactureUO    = cecrlnana.qte * (if cecrlnana.sens then 1 else -1)
                        ttReleveDeCompteur.dMontantFactureUO     = cecrlnana.mt  * (if cecrlnana.sens then 1 else -1)
                    .
                    if pcTypeCompteur = {&TYPECOMPTEUR-EauChaude}
                    then ttReleveDeCompteur.dPrixEauFroideRechaufTTC = round(cecrlnana.mt / cecrlnana.qte, 3).
                    else ttReleveDeCompteur.dPrixFluideTTC           = round(cecrlnana.mt / cecrlnana.qte, 3).
                end.
                leave.  // le premier est le bon!
            end.
        end.
        run ajoutLotLocataireReleve.
    end.
    if not can-find(first ttLigneReleveDeCompteur) then mError:createError({&error}, 111831). // "Vous n'avez pas de lot ou pas de compteur pour les lots"
end procedure.

procedure setReleveCompteur:
    /*------------------------------------------------------------------------------
    Purpose: Création ou mise à jour d'un relevé de compteur (1 seule création à la fois)
    Notes  : service externe (beReleveCompteur.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttReleveDeCompteur.
    define input parameter table for ttLigneReleveDeCompteur.

    define variable viNombreLienPeriode as integer no-undo.
    define variable vherlet             as handle no-undo.
    define variable vherldt             as handle no-undo.
    define variable vhlprtb             as handle no-undo.
    define buffer lprtb for lprtb.
    define buffer erldt for erldt.

    run ctrlAvantMajReleve.
    if mError:erreur() then return.

    run majLibelleConso.
    // gestion liens avec la période de charge (lprtb)
    for each ttReleveDeCompteur
        where ttReleveDeCompteur.CRUD = "D":
        for each lprtb no-lock
            where lprtb.tpcon = ttReleveDeCompteur.cTypeContrat
              and lprtb.nocon = ttReleveDeCompteur.iNumeroContrat
              and lprtb.tpcpt = ttReleveDeCompteur.cTypeCompteur
              and lprtb.norlv = ttReleveDeCompteur.iNumeroReleve:
            create ttlprtb.
            assign
                ttlprtb.tpcon       = lprtb.tpcon
                ttlprtb.nocon       = lprtb.nocon
                ttlprtb.tpcpt       = lprtb.tpcpt
                ttlprtb.norlv       = lprtb.norlv
                ttlprtb.dtTimestamp = datetime(lprtb.dtmsy, lprtb.hemsy)
                ttlprtb.CRUD        = "D"
                ttlprtb.rRowid      = rowid(lprtb)
            .
        end.
        for each erldt no-lock
            where erldt.norli = ttReleveDeCompteur.iNumeroIdentifiant:
            find first ttLigneReleveDeCompteur
                where ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
                  and ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
                  and ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
                  and ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant
                  and ttLigneReleveDeCompteur.iNumeroLot         = erldt.nolot
                  and ttLigneReleveDeCompteur.iNumeroLocataire   = erldt.nocop no-error.
             if available ttLigneReleveDeCompteur
                 then assign
                     ttLigneReleveDeCompteur.dtTimestamp = datetime(erldt.dtmsy, erldt.hemsy)
                     ttLigneReleveDeCompteur.CRUD        = "D"
                     ttLigneReleveDeCompteur.rRowid      = rowid(erldt)
                     .
             else do:
                 create ttLigneReleveDeCompteur.
                 assign
                     ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
                     ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
                     ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
                     ttLigneReleveDeCompteur.iNumeroIdentifiant = erldt.norli
                     ttLigneReleveDeCompteur.iNumeroReleve      = erldt.norlv
                     ttLigneReleveDeCompteur.dtTimestamp        = datetime(erldt.dtmsy, erldt.hemsy)
                     ttLigneReleveDeCompteur.CRUD               = "D"
                     ttLigneReleveDeCompteur.rRowid             = rowid(erldt)
                 .
             end.
        end.
    end.
    for each ttReleveDeCompteur
        where lookup(ttReleveDeCompteur.CRUD, "C,U") > 0:
        viNombreLienPeriode = 0.
        for each lprtb no-lock
            where lprtb.tpcon = ttReleveDeCompteur.cTypeContrat
              and lprtb.nocon = ttReleveDeCompteur.iNumeroContrat
              and lprtb.tpcpt = ttReleveDeCompteur.cTypeCompteur
              and lprtb.norlv = ttReleveDeCompteur.iNumeroReleve:
            viNombreLienPeriode = viNombreLienPeriode + 1.
            create ttlprtb.
            assign
                ttlprtb.tpcon       = lprtb.tpcon
                ttlprtb.nocon       = lprtb.nocon
                ttlprtb.tpcpt       = lprtb.tpcpt
                ttlprtb.norlv       = lprtb.norlv
                ttlprtb.noexe       = (if viNombreLienPeriode = 1 then ttReleveDeCompteur.iNumeroExercice else lprtb.noexe)
                ttlprtb.noper       = (if viNombreLienPeriode = 1 then ttReleveDeCompteur.iNumeroPeriode  else lprtb.noper)
                ttlprtb.noimm       = ttReleveDeCompteur.iNumeroImmeuble
                ttlprtb.cdtrt       = (if viNombreLienPeriode = 1 then ttReleveDeCompteur.cCodeTraitement else lprtb.cdtrt)
                ttlprtb.dtTimestamp = datetime(lprtb.dtmsy, lprtb.hemsy)
                ttlprtb.CRUD        = (if viNombreLienPeriode = 1 then "U" else "D")     // Maj lien période (unique) et suppression des autres (anomalie)
                ttlprtb.rRowid      = rowid(lprtb)
            .
        end.
        if not can-find(first lprtb no-lock
                        where lprtb.tpcon = ttReleveDeCompteur.cTypeContrat
                          and lprtb.nocon = ttReleveDeCompteur.iNumeroContrat
                          and lprtb.tpcpt = ttReleveDeCompteur.cTypeCompteur
                          and lprtb.norlv = ttReleveDeCompteur.iNumeroReleve) then do:
            create ttlprtb.
            assign
                ttlprtb.tpcon       = ttReleveDeCompteur.cTypeContrat
                ttlprtb.nocon       = ttReleveDeCompteur.iNumeroContrat
                ttlprtb.tpcpt       = ttReleveDeCompteur.cTypeCompteur
                ttlprtb.norlv       = ttReleveDeCompteur.iNumeroReleve
                ttlprtb.noexe       = ttReleveDeCompteur.iNumeroExercice
                ttlprtb.noper       = ttReleveDeCompteur.iNumeroPeriode
                ttlprtb.noimm       = ttReleveDeCompteur.iNumeroImmeuble
                ttlprtb.cdtrt       = ttReleveDeCompteur.cCodeTraitement
                ttlprtb.dtTimestamp = ?
                ttlprtb.CRUD        = "C"
                ttlprtb.rRowid      = ?
            .
        end.
    end.
    run adblib/erlet_CRUD.p persistent set vherlet.
    run getTokenInstance in vherlet(mToken:JSessionId).
    run seterlet in vherlet (table ttReleveDeCompteur by-reference).
    if mError:erreur() then do:
        run destroy in vherlet.
        return.
    end.
    // mise à jour no relevé et no identifiant dans les lignes détail
MajNumeroReleve:
    for each ttLigneReleveDeCompteur
        where ttLigneReleveDeCompteur.iNumeroIdentifiant = 0:
        for first ttReleveDeCompteur
            where ttReleveDeCompteur.cTypeContrat = ttLigneReleveDeCompteur.cTypeContrat
              and ttReleveDeCompteur.iNumeroContrat = ttLigneReleveDeCompteur.iNumeroContrat
              and ttReleveDeCompteur.cTypeCompteur = ttLigneReleveDeCompteur.cTypeCompteur
              and ttReleveDeCompteur.iNumeroIdentifiant > 0:
            assign
                ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant
                ttLigneReleveDeCompteur.iNumeroReleve      = ttReleveDeCompteur.iNumeroIdentifiant
            .
        end.
        if lookup(ttLigneReleveDeCompteur.CRUD, "C,U") > 0 and ttLigneReleveDeCompteur.iNumeroIdentifiant = 0 then do:
            mError:createError({&error}, outilTraduction:getLibelle(1000647) ).   //  "Numéro de relevé absent, création ligne détail relevé impossible"
            leave MajNumeroReleve.
        end.
    end.
    if mError:erreur() then do:
        run destroy in vherlet.
        return.
    end.
    run adblib/erldt_CRUD.p persistent set vherldt.
    run getTokenInstance in vherldt(mToken:JSessionId).
    run seterldt in vherldt (table ttLigneReleveDeCompteur by-reference).
    if mError:erreur() then do:
        run destroy in vherlet.
        run destroy in vherldt.
        return.
    end.
    if can-find(first ttlprtb) then do:
        run adblib/lprtb_CRUD.p persistent set vhlprtb.
        run getTokenInstance in vhlprtb(mToken:JSessionId).
        run setlprtb in vhlprtb(table ttlprtb by-reference).
        run destroy in vhlprtb.
    end.
    if valid-handle(vherlet) then run destroy in vherlet.
    if valid-handle(vherldt) then run destroy in vherldt.
end procedure.

procedure majLibelleConso private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Contrôles avant appel CRUD
    ------------------------------------------------------------------------------*/
    define variable vcLibelleMontant          as character no-undo.
    define variable vcLibelleForfait          as character no-undo.
    define variable vcLibelleA                as character no-undo.
    define variable vcLibelleUnite            as character no-undo.
    define variable vcInformationConsommation as character no-undo.

    assign
        vcLibelleMontant = caps(outilTraduction:getLibelle(100094))
        vcLibelleForfait = caps(outilTraduction:getLibelle(700880))
        vcLibelleA       = caps(outilTraduction:getLibelle(100068))
    .
    for each ttLigneReleveDeCompteur
        where lookup(ttLigneReleveDeCompteur.CRUD, "C,U") > 0
          and ttLigneReleveDeCompteur.dMontantTTC <> 0
      , first ttReleveDeCompteur
        where ttReleveDeCompteur.cTypeContrat       = ttLigneReleveDeCompteur.cTypeContrat
          and ttReleveDeCompteur.iNumeroContrat     = ttLigneReleveDeCompteur.iNumeroContrat
          and ttReleveDeCompteur.cTypeCompteur      = ttLigneReleveDeCompteur.cTypeCompteur
          and ttReleveDeCompteur.iNumeroIdentifiant = ttLigneReleveDeCompteur.iNumeroIdentifiant
        break by ttReleveDeCompteur.iNumeroContrat by ttReleveDeCompteur.cTypeCompteur by ttReleveDeCompteur.iNumeroIdentifiant:

        if first-of(ttReleveDeCompteur.cTypeCompteur) then vcLibelleUnite = libelleUniteReleve(ttReleveDeCompteur.cCodeUnite).

        assign
            vcInformationConsommation             = if ttLigneReleveDeCompteur.dConsommation = 0
                                                    then (if ttLigneReleveDeCompteur.lEstimation then vcLibelleForfait else vcLibelleMontant)
                                                    else substitute("&1 &2 &3 &4", ttLigneReleveDeCompteur.dConsommation, vcLibelleUnite, vcLibelleA, ttReleveDeCompteur.dPrixFluideTTC)
            ttLigneReleveDeCompteur.cLibelleConso = substitute("&1&2", string(outilTraduction:getLibelleParam("TPCPT", ttReleveDeCompteur.cTypeCompteur), "x(12)"), vcInformationConsommation)
        .
    end.
end procedure.

procedure ctrlAvantMajReleve private:
    /*------------------------------------------------------------------------------
    Purpose: Contrôles avant appel CRUD
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vclisteLotAbsentCle     as character no-undo.
    define variable vdCumulConsoLot         as decimal   no-undo.
    define variable viNumeroMandant         as integer   no-undo.
    define variable vlErreurLigne           as logical   no-undo.
    define variable vdTantiemeImmeuble      as decimal   no-undo.
    define variable vdTantiemeMandat        as decimal   no-undo.
    define variable vlRecuperationAutorisee as logical   no-undo.
    define variable vdTotalTTC              as decimal   no-undo.
    define variable vdTotalTVA              as decimal   no-undo.
    define buffer clemi for clemi.
    define buffer milli for milli.
    define buffer erlet for erlet.
    define buffer erldt for erldt.
    define buffer intnt for intnt.

boucleCtrlAvantMaj:
    for each ttReleveDeCompteur
        where lookup(ttReleveDeCompteur.CRUD, "C,U") > 0:
        if ttReleveDeCompteur.daDateReception = ?
        then ttReleveDeCompteur.daDateReception = ttReleveDeCompteur.daDateReleve.

        assign
            vdTantiemeMandat        = 0
            vdTantiemeImmeuble      = 0
            vdTotalTTC              = 0
            vdTotalTVA              = 0
            vlRecuperationAutorisee = false
            .
        if ttReleveDeCompteur.daDateReleve = ?
        then mError:createError({&error}, 105396).   // La date du relevé est obligatoire
        else if ttReleveDeCompteur.daDateReleve > ttReleveDeCompteur.daDateReception
        then mError:createError({&error}, 101328).   // La Date du Relevé doit être %s inférieure à la date de Réception.
        else if ttReleveDeCompteur.dTauxTVAFluide = ?
        then mError:createError({&error}, 109931).   // taux de TVA invalide
        else if lookup(ttReleveDeCompteur.cModeSaisie, substitute('&1,&2,&3', {&MODESAISIE-Index}, {&MODESAISIE-Consommation}, {&MODESAISIE-Montant})) = 0
        then mError:createError({&error}, 1000636).   // Mode de saisie &1 invalide (autorisé : 0, 1, 2)
        else if ttReleveDeCompteur.cTypeCompteur = {&TYPECOMPTEUR-EauChaude}
        and ttReleveDeCompteur.dPrixEauFroideRechaufTTC > ttReleveDeCompteur.dPrixFluideTTC
        then mError:createError({&error}, 101374).   // Le prix de l'eau chaude doit être %s supérieur au prix de l'eau froide.
        else if ttReleveDeCompteur.cTypeCompteur = {&TYPECOMPTEUR-EauChaude}
        and ttReleveDeCompteur.dTauxTVAEauFroideRechauf = ?
        then mError:createError({&error}, 109931).   // taux de TVA invalide
        else if ttReleveDeCompteur.CRUD = "C" and ttReleveDeCompteur.daDateRelevePrecedent >= ttReleveDeCompteur.daDateReleve
        then mError:createErrorGestion({&error}, 101438, substitute('&2&1', separ[1], string(ttReleveDeCompteur.daDateRelevePrecedent))).   // La Date du Relevé doit être supérieure %s à la date du dernier relevé créé (%1).

        if mError:erreur() then leave boucleCtrlAvantMaj.

        // clé de répartition
ControleMilliemes:
        for first clemi no-lock
            where clemi.tpcon = ttReleveDeCompteur.cTypeContrat
              and clemi.nocon = ttReleveDeCompteur.iNumeroContrat
              and clemi.cdcle = ttReleveDeCompteur.cCleRepartitionFluide
              and clemi.nbtot <> 0
          , each ttLigneReleveDeCompteur
            where ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
              and ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
              and ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
              and ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant
            break by ttLigneReleveDeCompteur.iNumeroLot:
            if first-of(ttLigneReleveDeCompteur.iNumeroLot)
            and not can-find(first milli
                             where milli.noimm = ttReleveDeCompteur.iNumeroImmeuble
                               and milli.nolot = ttLigneReleveDeCompteur.iNumeroLot
                               and milli.cdcle = clemi.cdcle
                               and milli.nbpar > 0)
            then vclisteLotAbsentCle = vclisteLotAbsentCle + (if vclisteLotAbsentCle > "" then "," else "") + string(ttLigneReleveDeCompteur.iNumeroLot).
            if length(vclisteLotAbsentCle, "character") > 150 then do:
                vclisteLotAbsentCle = vclisteLotAbsentCle + ",...".
                leave ControleMilliemes.
            end.
        end.
        if vclisteLotAbsentCle > "" then do:
            mError:createErrorGestion({&error}, 105570, substitute('&2&1&3', separ[1], ttReleveDeCompteur.cCleRepartitionFluide, vclisteLotAbsentCle)).   // Vous ne pouvez pas utiliser la clé de répartition %1 car %scertains lots du relevés n'ont pas de millièmes pour cette clé.%s (%2).
            leave boucleCtrlAvantMaj.
        end.
        // clé de récupération : tantièmes > 0
        for first clemi no-lock
            where clemi.tpcon = ttReleveDeCompteur.cTypeContrat
              and clemi.nocon = ttReleveDeCompteur.iNumeroContrat
              and clemi.cdcle = ttReleveDeCompteur.cCleRecuperationFluide:
            vdTantiemeMandat = clemi.nbtot.
        end.
        if vdTantiemeMandat = 0 then do:
            mError:createError({&error}, substitute(outilTraduction:getLibelle(1000648), ttReleveDeCompteur.cCleRecuperationFluide)). //  "Clé de récupération &1 invalide (sans millièmes)"
            leave boucleCtrlAvantMaj.
        end.
        // lignes détail
        if not can-find(first ttLigneReleveDeCompteur) then do:
            mError:createError({&error}, 103363). // Validation interdite:%sVous n'avez pas de lot ou pas de compteur pour les lots
            leave boucleCtrlAvantMaj.
        end.
        if not can-find(first ttLigneReleveDeCompteur where ttLigneReleveDeCompteur.dMontantTTC <> 0 ) then do:
            mError:createError({&error}, 103364). // Vous devez saisir au moins un montant non nul.
            leave boucleCtrlAvantMaj.
        end.
        // Controle des lignes détail (maj lErreurLigne/cLibelleErreur)
        run controleLigneReleve.
        if ttReleveDeCompteur.cTypeContrat = {&TYPECONTRAT-mandat2Gerance} then do:
ControleLigneCompteurLocataire:
            for each ttLigneReleveDeCompteur
                where ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
                  and ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
                  and ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
                  and ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant
                  and ttLigneReleveDeCompteur.lErreurLigne:
                if ttLigneReleveDeCompteur.dMontantTTC <> 0 then do:
                    // erreur bloquante
                   // Un montant de %1 a été saisi pour le Locataire %2 ,Lot %3, Compteur %4, %s%5 %sVeuillez vérifier et corriger ce relevé.
                    mError:createErrorGestion({&error}, 103910, substitute('&2&1&3&1&4&1&5&1&6', separ[1], string(ttLigneReleveDeCompteur.dMontantTTC), string(ttLigneReleveDeCompteur.iNumeroLocataire), string(ttLigneReleveDeCompteur.iNumeroLot), ttLigneReleveDeCompteur.cNumeroCompteur, ttLigneReleveDeCompteur.cLibelleErreur)).
                    vlErreurLigne = true.
                    leave ControleLigneCompteurLocataire.
                end.
                /* todo   n'ayant pas l'algo, il me semble qu'il faut mettre rrowid et timestamp à Jour? et si crud="c", mettre "r" à la place ??!! */
                // Spo -> PM : ajout d'un test sur la valeur CRUD mais pas de re-maj rowid/timestamp , le dataset est sensé être à jour
                else if LOOKUP(ttLigneReleveDeCompteur.CRUD, "R,U") > 0 then ttLigneReleveDeCompteur.CRUD = "D".    // ligne erronnée et sans montant: à supprimer (si elle existe)
            end.
            if vlErreurLigne then leave boucleCtrlAvantMaj.

            // Si relevé gérance créé à partir d'un relevé de copropriété controle de non dépassement des consommations saisies
            if ttReleveDeCompteur.iNumeroIdentifiantReleveCopro > 0 then do:
                /*--> No proprietaire principal */
                for first intnt  no-lock
                    where intnt.tpcon = ttReleveDeCompteur.cTypeContrat
                      and intnt.NoCon = ttReleveDeCompteur.iNumeroContrat
                      and intnt.TpIdt = {&TYPEROLE-mandant}:
                    viNumeroMandant = intnt.noidt.
ControleReleveCoproPere:
                    for each ttLigneReleveDeCompteur
                        where ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
                          and ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
                          and ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
                          and ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant
                        break by ttLigneReleveDeCompteur.iNumeroLot:
                        if first-of (ttLigneReleveDeCompteur.iNumeroLot) then vdCumulConsoLot = 0.
                        vdCumulConsoLot = vdCumulConsoLot + ttLigneReleveDeCompteur.dConsommation.
                        if last-of (ttLigneReleveDeCompteur.iNumeroLot)
                        then for first erldt no-lock
                            where erldt.norli = ttReleveDeCompteur.iNumeroIdentifiantReleveCopro
                              and erldt.nolot = ttLigneReleveDeCompteur.iNumeroLot
                              and erldt.nocop = viNumeroMandant             /* SY 0816/0078 */
                              and erldt.conso <> vdCumulConsoLot:
                            /* La consomation du lot %1 ne peut exceder celle saisie sur le relevé de copro %2 */
                            mError:createErrorGestion({&error}, 107522, substitute('&2&1&3', separ[1], string(ttLigneReleveDeCompteur.iNumeroLot), string(erldt.conso))).
                            leave ControleReleveCoproPere.
                        end.
                    end.
                end.
                if mError:erreur() then leave boucleCtrlAvantMaj.
            end.
        end.    // contrôles si mandat de Gérance
        // controle des totaux
        for each ttLigneReleveDeCompteur
            where ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
              and ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
              and ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
              and ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant
              and ttLigneReleveDeCompteur.dMontantTTC        <> 0
              and lookup(ttLigneReleveDeCompteur.CRUD, "C,R,U") > 0:
            assign
                vdTotalTTC = vdTotalTTC + ttLigneReleveDeCompteur.dMontantTTC
                vdTotalTVA = vdTotalTVA + ttLigneReleveDeCompteur.dMontantTVA
            .
        end.
        if vdTotalTTC <> ttReleveDeCompteur.dMontantTTC then do:
            // Le total TTC du relevé du &1 (&2) n'est pas égal à la somme des détails du relevé (&3)
            mError:createError({&error}, 1000649, substitute('&2&1&3&1&4', separ[1], string(ttReleveDeCompteur.daDateReleve), string(ttReleveDeCompteur.dMontantTTC), string(vdTotalTTC))).
            leave boucleCtrlAvantMaj.
        end.
        if vdTotalTVA <> ttReleveDeCompteur.dMontantTVA then do:
           // Le total TVA du relevé du &1 (&2) n'est pas égal à la somme des détails TVA du relevé (&3)
            mError:createError({&error}, 1000650, substitute('&2&1&3&1&4', separ[1], string(ttReleveDeCompteur.daDateReleve), string(ttReleveDeCompteur.dMontantTVA), string(vdTotalTVA))).
            leave boucleCtrlAvantMaj.
        end.
        // contrôles récupération
        if lookup( ttReleveDeCompteur.cTypeCompteur , substitute("&1,&2", {&TYPECOMPTEUR-EauChaude}, {&TYPECOMPTEUR-Thermie})) = 0
        then assign
            ttReleveDeCompteur.dMontantRecup2TTC = 0
            ttReleveDeCompteur.dMontantRecup2TVA = 0
        .
        if ttReleveDeCompteur.cTypeContrat = {&TYPECONTRAT-mandat2Gerance} then do:
            if ttReleveDeCompteur.iNumeroIdentifiantReleveCopro > 0 then do:
                assign
                    ttReleveDeCompteur.dMontantRecuperationTTC = 0
                    ttReleveDeCompteur.dMontantRecuperationTVA = 0
                    ttReleveDeCompteur.dMontantRecup2TTC       = 0
                    ttReleveDeCompteur.dMontantRecup2TVA       = 0
                .
                next boucleCtrlAvantMaj.
            end.
            // Saisie récupération autorisée si clé de récupération au mandat => soit num-alpha soit Alpha mais avec tantièmes immeuble = tantièmes mandat (mono-gérance)
            for first clemi no-lock
                where clemi.noimm = ttReleveDeCompteur.iNumeroImmeuble
                  and clemi.cdcle = ttReleveDeCompteur.cCleRecuperationFluide:
                vdTantiemeImmeuble = clemi.nbtot.
            end.
            for first clemi no-lock
                where clemi.tpcon = ttReleveDeCompteur.cTypeContrat
                  and clemi.nocon = ttReleveDeCompteur.iNumeroContrat
                  and clemi.cdcle = ttReleveDeCompteur.cCleRecuperationFluide:
                vdTantiemeMandat = clemi.nbtot.
            end.

            // todo   vérifier qu'il ne faut pas remettre vlRecuperationAutorisee à false avant? car on est dans une boucle.
            //        et dans ce cas, se passer de la variable vlRecuperationAutorisee.
            // 19/04/2018 SPo -> PM : ajout  initialisation variables en début de boucle
            if ttReleveDeCompteur.cCleRecuperationFluide < "A"
            or vdTantiemeImmeuble = vdTantiemeMandat then vlRecuperationAutorisee = true.
            if vlRecuperationAutorisee = false
            and (ttReleveDeCompteur.dMontantRecuperationTTC <> 0
              or ttReleveDeCompteur.dMontantRecuperationTVA <> 0
              or ttReleveDeCompteur.dMontantRecup2TTC       <> 0
              or ttReleveDeCompteur.dMontantRecup2TVA       <> 0) then do:
                mError:createError({&error}, 1000642, ttReleveDeCompteur.cCleRecuperationFluide).   // Vous ne pouvez pas saisir des montants de récupération car la clé de récupération &1 est à l'immeuble
                leave boucleCtrlAvantMaj.
            end.
            else if vlRecuperationAutorisee then do:
                if ttReleveDeCompteur.dMontantRecuperationTTC <> 0 and ttReleveDeCompteur.dMontantRecuperationTTC + ttReleveDeCompteur.dMontantRecup2TTC <> vdTotalTTC then do:
                    if lookup(ttReleveDeCompteur.cTypeCompteur, substitute("&1,&2", {&TYPECOMPTEUR-EauChaude}, {&TYPECOMPTEUR-Thermie})) = 0
                    then mError:createError({&error}, 103871). // Vous ne pouvez pas saisir un montant de récupération différent du total du tableau sauf 0
                    else mError:createError({&error}, 102843). // La somme des récupérations "T.T.C." doit être %s égale au total "T.T.C." du relevé.
                    leave boucleCtrlAvantMaj.
                end.
                if (ttReleveDeCompteur.dMontantRecuperationTTC <> 0 or ttReleveDeCompteur.dMontantRecup2TTC <> 0)
                and ttReleveDeCompteur.dMontantRecuperationTVA + ttReleveDeCompteur.dMontantRecup2TVA <> vdTotalTVA then do:
                    mError:createError({&error}, 102888). // La somme des " T.V.A." de récupération doit être %s égale au total "T.V.A." du relevé.
                    leave boucleCtrlAvantMaj.
                end.
                if ttReleveDeCompteur.dMontantRecuperationTTC <> 0 and ttReleveDeCompteur.cLibelleRecuperation = "" then do:
                    mError:createError({&error}, 103872). // Le libellé de la récupération est obligatoire
                    leave boucleCtrlAvantMaj.
                end.
                if ttReleveDeCompteur.dMontantRecuperationTTC <> 0 and ttReleveDeCompteur.cCodeAnalytiqueRecuperation = "" then do:
                    mError:createError({&error}, 101695). // Vous devez saisir un code analytique
                    leave boucleCtrlAvantMaj.
                end.
                if ttReleveDeCompteur.dMontantRecup2TTC <> 0 and ttReleveDeCompteur.cLibelleRecup2 = "" then do:
                    mError:createError({&error}, 103872). // Le libellé de la récupération est obligatoire
                    leave boucleCtrlAvantMaj.
                end.
            end.
        end.
    end.
    // SUPPRESSION autorisée (après demande de confirmation) si dernier relevé pour le batiment (ou l'immeuble) et si relevé modifiable (en cours ou retirage)
boucleCtrlAvantSupp:
    for each ttReleveDeCompteur
        where ttReleveDeCompteur.CRUD = "D":
        if not ttReleveDeCompteur.lModifiable then do:
            mError:createError({&error}, 1000651, substitute('&2&1&3', separ[1], string(ttReleveDeCompteur.daDateReleve), ttReleveDeCompteur.iNumeroExercice)). // Suppression du relevé du &1 interdite: la période &2 a été traitée ou historisée
            leave boucleCtrlAvantSupp.
        end.
        // recherche si il existe un relevé suivant
        if not ttReleveDeCompteur.lReleveToutBatiment and ttReleveDeCompteur.cCodeBatiment > ""
        then for first erlet no-lock
            where erlet.tpcon = ttReleveDeCompteur.cTypeContrat
              and erlet.nocon = ttReleveDeCompteur.iNumeroContrat
              and erlet.tpcpt = ttReleveDeCompteur.cTypeCompteur
              and erlet.cdbat = ttReleveDeCompteur.cCodeBatiment
              and erlet.dtrlv > ttReleveDeCompteur.daDateReleve
              and erlet.norli <> ttReleveDeCompteur.iNumeroIdentifiant:
            mError:createError({&error}, 1000652, substitute('&2&1&3', separ[1], ttReleveDeCompteur.daDateReleve, erlet.dtrlv)). // Suppression du relevé du &1 interdite: il existe un relevé suivant en date du &2
            leave boucleCtrlAvantSupp.
        end.
        else for first erlet no-lock
            where erlet.tpcon = ttReleveDeCompteur.cTypeContrat
              and erlet.nocon = ttReleveDeCompteur.iNumeroContrat
              and erlet.tpcpt = ttReleveDeCompteur.cTypeCompteur
              and erlet.cdbat = ""
              and erlet.dtrlv > ttReleveDeCompteur.daDateReleve
              and erlet.norli <> ttReleveDeCompteur.iNumeroIdentifiant:
            mError:createError({&error}, 1000652, substitute('&2&1&3', separ[1], ttReleveDeCompteur.daDateReleve, erlet.dtrlv)). // Suppression du relevé du &1 interdite: il existe un relevé suivant en date du &2
            leave boucleCtrlAvantSupp.
        end.
    end.
end procedure.

procedure ControleLigneReleve private:
    /*------------------------------------------------------------------------------
    Purpose: lignes détail stockées lors de la saisie du relevé de consommations
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroCodage         as int64 no-undo.
    define variable vdaDateDebutExtraction as date  no-undo.
    define variable vdaDateFinExtraction   as date  no-undo.
    define buffer ctrat for ctrat.
    define buffer tache for tache.

    run calculDateExtractionReleve(buffer ttReleveDeCompteur, output vdaDateDebutExtraction, output vdaDateFinExtraction).
    if ttReleveDeCompteur.cTypeContrat = {&TYPECONTRAT-mandat2Gerance}
    then viNumeroCodage = 10000 + ttReleveDeCompteur.iNumeroContrat.       // todo : cteur.noimm à supprimer quand les structures de cteur seront corrigées (V19.00 ?)
    else viNumeroCodage = ttReleveDeCompteur.iNumeroImmeuble.
    for each ttLigneReleveDeCompteur
        where ttLigneReleveDeCompteur.cTypeContrat       = ttReleveDeCompteur.cTypeContrat
          and ttLigneReleveDeCompteur.iNumeroContrat     = ttReleveDeCompteur.iNumeroContrat
          and ttLigneReleveDeCompteur.cTypeCompteur      = ttReleveDeCompteur.cTypeCompteur
          and ttLigneReleveDeCompteur.iNumeroIdentifiant = ttReleveDeCompteur.iNumeroIdentifiant:
        if not can-find(first local no-lock
                        where local.noimm = ttReleveDeCompteur.iNumeroImmeuble
                          and local.nolot = ttLigneReleveDeCompteur.iNumeroLot)
        then assign
            ttLigneReleveDeCompteur.lErreurLigne   = true
            ttLigneReleveDeCompteur.cLibelleErreur = outilTraduction:getLibelle(103119)  // Lot inexistant
        .
        //  : cteur.noimm à supprimer quand les structures de cteur seront corrigées (V19.00 ?)
        // Contrôle de l'existence du compteur pour ce lot
        else if not can-find(first cteur no-lock
                            where cteur.noimm = viNumeroCodage
                              and cteur.nolot = ttLigneReleveDeCompteur.iNumeroLot
                              and cteur.tpcpt = ttReleveDeCompteur.cTypeCompteur)
        then assign
            ttLigneReleveDeCompteur.lErreurLigne   = true
            ttLigneReleveDeCompteur.cLibelleErreur = substitute( outilTraduction:getLibelle(1000643), ttLigneReleveDeCompteur.cNumeroCompteur, ttLigneReleveDeCompteur.iNumeroLot, ttLigneReleveDeCompteur.iNumeroContrat)   //  "Numéro de compteur &1 inexistant pour le lot &2 du mandat &3"
        .
        // Contrôle de l'existence du bail
        else if ttReleveDeCompteur.cTypeContrat = {&TYPECONTRAT-mandat2Gerance}
            and not ttLigneReleveDeCompteur.lProprietaireOccupant
            and not ttLigneReleveDeCompteur.lProprietaireVacant
        then do:
            if not can-find(first ctrat no-lock
                            where ctrat.tpcon = {&TYPECONTRAT-bail}
                              and ctrat.nocon = ttLigneReleveDeCompteur.iNumeroLocataire)
            then assign
                ttLigneReleveDeCompteur.lErreurLigne   = true
                ttLigneReleveDeCompteur.cLibelleErreur = substitute(outilTraduction:getLibelle(1000644), ttLigneReleveDeCompteur.iNumeroLocataire, ttLigneReleveDeCompteur.iNumeroLot, ttLigneReleveDeCompteur.iNumeroContrat)     // "Numéro de locataire &1 inexistant pour le lot &2 du mandat &3"
            .
            else for first ctrat no-lock           // contrôle des dates d'occupation
                where ctrat.tpcon = {&TYPECONTRAT-bail}
                  and ctrat.nocon = ttLigneReleveDeCompteur.iNumeroLocataire
              , last tache no-lock
                where tache.tpcon = ctrat.tpcon
                  and tache.nocon = ctrat.nocon
                  and tache.tptac = {&TYPETACHE-quittancement}:
                if vdaDateFinExtraction <> ? and tache.dtdeb > vdaDateFinExtraction
                then assign
                    ttLigneReleveDeCompteur.lErreurLigne   = true
                    ttLigneReleveDeCompteur.cLibelleErreur = substitute(outilTraduction:getLibelle(1000645), ttLigneReleveDeCompteur.iNumeroLocataire, string(tache.dtdeb), string(vdaDateFinExtraction))     //  "Locataire &1 hors période, date d'entrée (&2) supérieure à la date de fin de période (&3)"
                .
                else if tache.dtfin <> ? and tache.dtfin < vdaDateDebutExtraction
                then assign
                    ttLigneReleveDeCompteur.lErreurLigne   = true
                    ttLigneReleveDeCompteur.cLibelleErreur = substitute(outilTraduction:getLibelle(1000646), ttLigneReleveDeCompteur.iNumeroLocataire, string(tache.dtfin), string(vdaDateDebutExtraction))     //  "Locataire &1 hors période, date de sortie (&2) inférieure à la date de début d'extraction (&3)"
                .
            end.
        end.
    end.
end procedure.
