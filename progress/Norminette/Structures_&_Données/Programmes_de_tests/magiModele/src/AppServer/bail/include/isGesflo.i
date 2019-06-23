/*------------------------------------------------------------------------
File        : isGesflo.i
Purpose     : 
Author(s)   : kantena  -  2017/11/27 
Notes       : vient de adb/comm/isGesflo.i
              procedure isGesflo remplacée par parametrageFournisseurLoyer
derniere revue: 2018/04/26 - phm: KO
            traiter les TODO
------------------------------------------------------------------------*/
{preprocesseur/codeRubrique.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}

function donneBailSousLoc returns int64(piImmeuble-in as integer, piLot-in as integer):
    /*--------------------------------------------------------------------------- 
    Purpose : Retourne le mandat de sous location associé à un couple (immeuble/lot)
    Notes   :
    ---------------------------------------------------------------------------*/ 
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer cpuni for cpuni.

    /* Récupération du mandat de sous-location de l'immeuble */
    for each intnt  no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piImmeuble-in
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
      , each ctrat  no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation}
      , each unite  no-lock
        where unite.nomdt = ctrat.nocon
          and unite.noact = 0
      , each cpuni  no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.nolot = piLot-in:
        return unite.norol.
    end.
    return 0.
end function. 

function donneBailSousLocDeleguee returns int64(piImmeuble-in as integer, piLot-in as integer):
    /*--------------------------------------------------------------------------- 
    Purpose : Retourne le mandat de sous location Déléguée associé à un couple (immeuble/lot)
    Notes   :
    ---------------------------------------------------------------------------*/ 
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer cpuni for cpuni.

    /* Récupération du mandat de sous-location de l'immeuble */
    for each intnt  no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piImmeuble-in
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
      , each ctrat  no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and ctrat.ntcon = {&NATURECONTRAT-mandatSousLocationDelegue}
      , each unite  no-lock
        where unite.nomdt = ctrat.nocon
          and unite.noact = 0
      , each cpuni  no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.nolot = piLot-in:
        return unite.norol.
    end.
    return 0.
end function. 

function donneMandatLoc returns int64(piImmeuble-in as integer, piLot-in as integer):
    /*--------------------------------------------------------------------------- 
    Purpose : Retourne le mandat de location associé à un couple (immeuble/lot)
    Notes   :
    ---------------------------------------------------------------------------*/ 
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer cpuni for cpuni.

    /* Récupération du mandat de sous-location de l'immeuble */
    for each intnt  no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piImmeuble-in
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
      , each ctrat  no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and (ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
            or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}
            or ctrat.ntcon = {&NATURECONTRAT-mandatLocationDelegue})
      , each unite  no-lock
        where unite.nomdt = ctrat.nocon
          and unite.noact = 0
      , each cpuni  no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.nolot = piLot-in:
        return unite.nomdt.
    end.
    return 0.
end function. 

function donneMandatSousLoc returns int64(piImmeuble-in as integer, piLot-in as integer):
    /*--------------------------------------------------------------------------- 
    Purpose : Retourne le mandat de sous-location associé à un couple (immeuble/lot)
    Notes   :
    ---------------------------------------------------------------------------*/ 
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer unite for unite.
    define buffer cpuni for cpuni.

    /* Récupération du mandat de sous-location de l'immeuble */
    for each intnt  no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piImmeuble-in
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
      , each ctrat  no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and (ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation}
            or ctrat.ntcon = {&NATURECONTRAT-mandatSousLocationDelegue})
      , each unite  no-lock
        where unite.nomdt = ctrat.nocon
          and unite.noact = 0
      , each cpuni  no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.nolot = piLot-in:
        return unite.nomdt.
    end.
    return 0.
end function. 

procedure donneLoyerQuittance:
    /*--------------------------------------------------------------------------- 
    Purpose : Donne le montant quittancé : temporaire
    Notes   :
    todo   procédure non utilisée ??? service? private ?
    ---------------------------------------------------------------------------*/ 
    define input  parameter piLocataire             as integer no-undo.
    define output parameter pdeLoyer                as decimal no-undo.
    define output parameter pdeToxeOrduresMenageres as decimal no-undo.
    define variable viBoucle as integer no-undo.
    define buffer equit for equit.

    for first equit no-lock
        where equit.noloc = piLocataire:
        do viBoucle = 1 to 20:
            if equit.tbfam[viBoucle] = 1 then pdeLoyer = pdeLoyer + equit.tbmtq[viBoucle].
            if lookup(string(equit.tbrub[viBoucle]), "{&RUBRIQUE-taxeOrduresMenageres}") > 0
            then pdeToxeOrduresMenageres = pdeToxeOrduresMenageres + equit.tbmtq[viBoucle].   
        end.
    end.
end procedure.

function chargementListeFamilles returns character(pcListeFamilleAutorisees as character):
    /*--------------------------------------------------------------------------- 
    Purpose : chargement de la liste des familles disponibles pour la rubrique loyer du FL de type bail proportionnel
    Notes   :
    TODO    : - whole index!!! index sur ntbai, cdfam --> fixer ntbai ci-dessous ou mettre index sur cdfam et revoir la requete.
    ---------------------------------------------------------------------------*/
    define variable vcListeFamilles as character no-undo.
    define buffer bxrbp for bxrbp.

    for each bxrbp no-lock
        where lookup(string(bxrbp.cdfam, "99"), pcListeFamilleAutorisees) > 0
        break by bxrbp.norub:
        if first-of(bxrbp.norub) then vcListeFamilles = vcListeFamilles + "," + string(bxrbp.norub).
    end.
    return trim(vcListeFamilles, ",").
end function.
