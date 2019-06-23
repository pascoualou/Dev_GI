/*------------------------------------------------------------------------
File        : objetAssImm.p
Purpose     : objet assurance (d'un contrat)
Author(s)   : GGA  -  2017/11/24
Notes       : a partir de adb/cont/gesobj01.p
derniere revue: 2018/04/11 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/codePeriode.i}

using parametre.syspg.syspg.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{adblib/include/ctrat.i}
{tache/include/tacheAssuranceImmeuble.i}

define variable goSyspg as class syspg no-undo.
define variable goSyspr as class syspr no-undo.

procedure getListeAssuranceImmeubleMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter pcTypeMandat     as character no-undo.
    define input parameter pcTypeContratLie as character no-undo.
    define output parameter table for ttObjetAssImm.

    define buffer ctctt for ctctt.

    empty temp-table ttObjetAssImm.
    for each ctctt no-lock
        where ctctt.tpct1 = pcTypeMandat
          and ctctt.noct1 = piNumeroMandat
          and ctctt.tpct2 = pcTypeContratLie:
        if can-find(first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct2
                      and ctrat.nocon = ctctt.noct2)
        then run getInfoContrat(ctctt.tpct2, ctctt.noct2).
    end.

end procedure.

procedure getObjet:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet assurance
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.    
    define output parameter table for ttObjetAssImm.

    empty temp-table ttObjetAssImm.
    if can-find(first ctrat no-lock
                where ctrat.tpcon = pcTypeContrat
                  and ctrat.nocon = piNumeroContrat)
    then run getInfoContrat(pcTypeContrat, piNumeroContrat).
    else mError:createError({&error}, 100057).
    return.
end procedure.

procedure initComboObjet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beAssuranceImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat as character no-undo.    
    define output parameter table for ttCombo.

    empty temp-table ttCombo.
    assign
        goSyspr = new syspr()
        goSyspg = new syspg()
    .
    goSyspr:getComboParametre("UTDUR", "CMBUNITEDUREE"      , output table ttCombo by-reference).
    goSyspr:getComboParametre("TPACT", "CMBTYPEACTE"        , output table ttCombo by-reference).
    goSyspr:getComboParametre("TPMOT", "CMBMOTIFRESILIATION", output table ttCombo by-reference).
    goSyspg:creationComboSysPgZonXX("R_CRC", "CMBNATURECONTRAT", "L", pcTypeContrat, output table ttCombo by-reference).
    /* creation combo delai preavis */
    for each ttCombo
        where ttCombo.cNomCombo = "CMBUNITEDUREE"
          and ttCombo.cCode    <> "00001":
        goSyspg:creationttCombo("CMBUNITEDELAIPREAVIS", ttCombo.cCode, ttCombo.cLibelle, output table ttCombo by-reference).  
    end.
    /* supprimer les motifs de resiliation ne concernant pas les assurances ( - et Chgt assureur) */
    for each ttCombo
        where ttCombo.cNomCombo = "CMBMOTIFRESILIATION":
        if not (ttCombo.cCode = "00000" or ttCombo.cCode begins "2")
        then delete ttCombo.
    end.
    delete object goSyspg.
    delete object goSyspr.
    return.

end procedure.

procedure setObjet:
    /*------------------------------------------------------------------------------
    Purpose: maj information objet assurance
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt as character no-undo.
    define input parameter table for ttObjetAssImm.

    define buffer ctrat for ctrat.

    for first ttObjetAssImm where ttObjetAssImm.CRUD = "U":
        find first ctrat no-lock
             where ctrat.tpcon = ttObjetAssImm.cTypeContrat 
               and ctrat.nocon = ttObjetAssImm.iNumeroContrat no-error.
        if available ctrat then do:
            goSyspr = new syspr().
            goSyspg = new syspg().
            run verZonSai(pcTypeTrt, ctrat.dtfin, ctrat.dtdeb, ctrat.dtsig).
            if not mError:erreur() then run miseAJourContrat.
            delete object goSyspr.
            delete object goSyspg.
        end.
        else mError:createError({&error}, 100057).
    end.
    return.
end procedure.

procedure createAssurance:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttObjetAssImm.

    for first ttObjetAssImm where ttObjetAssImm.CRUD = "C":
        assign
            goSyspr = new syspr()
            goSyspg = new syspg()
        .
        run verZonSai("CREATION", ?, ?, ?).
        if not mError:erreur() then run miseAJourContrat.
        delete object goSyspr.
        delete object goSyspg.
    end.
    return.
end procedure.

procedure getInfoContrat private:
    /*------------------------------------------------------------------------------
    Purpose: affichage information objet d'un mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.    
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        create ttObjetAssImm.
        outils:copyValidField(buffer ctrat:handle, buffer ttObjetAssImm:handle).        
        assign
            ttObjetAssImm.cLibUniteDuree       = outilTraduction:getLibelleParam("UTDUR", ctrat.cddur)
            ttObjetAssImm.cLibUnitePreavis     = outilTraduction:getLibelleParam("UTDUR", ctrat.utres)
            ttObjetAssImm.lTaciteReconduction  = (ctrat.tpren = "00001")
            ttObjetAssImm.cLibTypeActe         = outilTraduction:getLibelleParam("TPACT", ctrat.tpact)
            ttObjetAssImm.cLibNatureContrat    = outilTraduction:getLibelleProgZone2("R_CRC", pcTypeContrat, ctrat.ntcon)
            ttObjetAssImm.lResiliation         = ctrat.dtree <> ?
            ttObjetAssImm.cMotifResiliation    = (if ctrat.dtree <> ? then ctrat.tpfin else ?)
            ttObjetAssImm.cLibMotifResiliation = outilTraduction:getLibelleParam("TPMOT", ttObjetAssImm.cMotifResiliation)
        .
    end.
end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : 2 types de traitement possible: "" pour maj ou resiliation et "renouvellemnt". 
             Pas de type de traitement resiliation car on se base sur la date de resiliation.
             Donc si date vide c'est une modification et si si date renseigne c'est une resiliation
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTrt   as character no-undo.
    define input parameter pdaCtratFin as date      no-undo.
    define input parameter pdaCtratDeb as date      no-undo.
    define input parameter pdaCtratSig as date      no-undo.

    /* on verifie qu'en mode lesinformations de résiliation ne sont pas renseignees */ 
    if pcTypeTrt = "CREATION"
    and (ttObjetAssImm.daResiliation <> ? or ttObjetAssImm.lResiliation = yes)
    then mError:createError({&error}, 1000640).   //En creation, vous ne pouvez pas renseigner les informations de résiliation

    // on verifie qu'en mode renouvellement la date de resiliation est vide (le renouvellement est une modification d'un contrat actif)
    else if pcTypeTrt = "RENOUVELLEMENT"
    and (ttObjetAssImm.daResiliation <> ? or pdaCtratFin <> ?) 
    then mError:createError({&error}, 1000547).           //Le renouvellement ne peut se faire que sur un contrat actif (date résiliation vide)

    /*--> On teste la partie haute si on n'est pas en resiliation (donc date de resiliation a blanc) */
    else if ttObjetAssImm.daResiliation = ? and ttObjetAssImm.lResiliation = no
    then do:
        if not goSyspg:isParamExist("R_CRC", ttObjetAssImm.cTypeContrat, ttObjetAssImm.cNatureContrat)
        then mError:createError({&error}, 1000611, ttObjetAssImm.cNatureContrat).   //nature de contrat &1 inconnue        
        else if ttObjetAssImm.cNumeroPolice = "" or ttObjetAssImm.cNumeroPolice = ?
        then mError:createError({&error}, 100071).        /*--> Numero Reel de Contrat. Uniquement si contrat <> bail */
        else if ttObjetAssImm.daInitiale = ?
        then mError:createError({&error}, 104078).        /*--> La date du 1er contrat est obligatoire */
        else if ttObjetAssImm.daDebut = ?
        then mError:createError({&error}, 100072).        /*--> la date d'effet est obligatoire. */
        else if pcTypeTrt = "RENOUVELLEMENT"
        and pdaCtratDeb <> ? and ttObjetAssImm.daDebut < pdaCtratDeb
        then mError:createErrorGestion({&error}, 101955, string(pdaCtratDeb, "99/99/9999")).
        else if ttObjetAssImm.daInitiale > ttObjetAssImm.daDebut 
        then mError:createError({&error}, 104079).
        else if ttObjetAssImm.iDuree = ?
        then mError:createError({&error}, 100073).        /*--> Duree du Contrat */
        else if ttObjetAssImm.iDuree = 0
        then mError:createError({&error}, 101998).
        else if goSyspr:isParamExist("UTDUR", ttObjetAssImm.cUniteDuree) = no     
        then mError:createError({&error}, 100074).        /*--> Unite Duree du Contrat. */
        else run controleDureeContrat.
        if mError:erreur() then return.

        if ttObjetAssImm.daFin = ?
        then mError:createError({&error}, 100075).        /*--> Date d'Expiration. */
        else if ttObjetAssImm.daFin <= ttObjetAssImm.daDebut
        then mError:createError({&error}, 100076).
        else if ttObjetAssImm.iDelaiPreavis = ?
        then mError:createError({&error}, 100077).        /*--> Delai de resiliation*/
        else if ttObjetAssImm.iDelaiPreavis = 0
        then mError:createError({&error}, 102045).
        else if goSyspr:isParamExist("UTDUR", ttObjetAssImm.cUnitePreavis) = no   
             or ttObjetAssImm.cUnitePreavis = "00001"
        then mError:createError({&error}, 100078).        /*--> Unite Duree du Contrat. */
        else if ttObjetAssImm.daSignature = ?
        then mError:createError({&error}, 100079).        /*--> Date de Signature */
        else if ttObjetAssImm.cLieuSignature = ? or ttObjetAssImm.cLieuSignature = ""
        then mError:createError({&error}, 100081).        /*--> Lieu de Signature. */
        else if goSyspr:isParamExist("TPACT", ttObjetAssImm.cTypeActe) = no     
        then mError:createError({&error}, 100082).        /*--> Type d'acte */
    end.
    else do:
        if ttObjetAssImm.daResiliation <> ? and ttObjetAssImm.lResiliation = no
        then mError:createError({&error}, 1000548).            //Si flag résiliation à non, alors date résiliation doit être vide
        else if ttObjetAssImm.daResiliation = ? and ttObjetAssImm.lResiliation = yes
        then mError:createError({&error}, 100083).        /*--> Date de resiliation. */
        else if ttObjetAssImm.daResiliation < pdaCtratDeb
        then mError:createError({&error}, 100084).
        else if ttObjetAssImm.daResiliation > pdaCtratFin
        then mError:createError({&error}, 102046).
        else if ttObjetAssImm.daResiliation < pdaCtratSig
        then mError:createError({&error}, 102047).
        else if goSyspr:isParamExist("TPMOT", ttObjetAssImm.cMotifResiliation) = no
             or not (ttObjetAssImm.cMotifResiliation = "00000" or ttObjetAssImm.cMotifResiliation begins "2")
        then mError:createError({&error}, 100085).
    end.
end procedure.

procedure miseAJourContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        ttCtrat.tpcon       = ttObjetAssImm.cTypeContrat
        ttCtrat.nocon       = if ttObjetAssImm.CRUD = "C" then 0 else ttObjetAssImm.iNumeroContrat
        ttCtrat.CRUD        = ttObjetAssImm.CRUD
        ttCtrat.dtTimestamp = ttObjetAssImm.dtTimestamp
        ttCtrat.rRowid      = ttObjetAssImm.rRowid
    .
    if ttObjetAssImm.daResiliation = ?
    then assign
         ttCtrat.dtdeb = ttObjetAssImm.daDebut
         ttCtrat.ntcon = ttObjetAssImm.cNatureContrat
         ttCtrat.dtfin = ttObjetAssImm.daFin
         ttCtrat.nbdur = ttObjetAssImm.iDuree
         ttCtrat.cddur = ttObjetAssImm.cUniteDuree
         ttCtrat.dtsig = ttObjetAssImm.daSignature
         ttCtrat.lisig = caps(ttObjetAssImm.cLieuSignature)
         ttCtrat.dtini = ttObjetAssImm.daInitiale
         ttCtrat.noree = ttObjetAssImm.cNumeroPolice
         ttCtrat.tpren = string(ttObjetAssImm.lTaciteReconduction, "00001/00000")
         ttCtrat.nbres = ttObjetAssImm.iDelaiPreavis
         ttCtrat.utres = ttObjetAssImm.cUnitePreavis
         ttCtrat.tpact = ttObjetAssImm.cTypeActe
         ttCtrat.dtree = 01/01/0001  // outil de copie qui transforme un 01/01/0001 en ?
         ttCtrat.tpfin = ""
    .
    else assign
         ttCtrat.dtree = ttObjetAssImm.daResiliation
         ttCtrat.tpfin = ttObjetAssImm.cMotifResiliation
    .
    run adblib/ctrat_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCtrat in vhProc(table ttCtrat by-reference).
    run destroy  in vhproc.
    if ttObjetAssImm.CRUD = "C"
    then for first ttCtrat:
        ttObjetAssImm.iNumeroContrat = ttCtrat.nocon. 
    end.    
end procedure.

procedure controleDureeContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNbMoiDur as integer     no-undo.
    define variable viNbMoiMin as integer     no-undo.
    define variable viNbMoiMax as integer     no-undo.

    viNbMoiDur = (if ttObjetAssImm.cUniteDuree = {&CODEPERIODE-annuel} then 12 * ttObjetAssImm.iDuree else ttObjetAssImm.iDuree).
    goSyspg:reloadUnique("O_COT", ttObjetAssImm.cNatureContrat).
    if num-entries(goSyspg:zone9, "@") >= 2 
    then do:
        assign
            viNbMoiMin = integer(entry(1, goSyspg:zone9, "@"))
            viNbMoiMax = integer(entry(2, goSyspg:zone9, "@"))
        no-error.
        if viNbMoiDur < viNbMoiMin or viNbMoiDur > viNbMoiMax
        then mError:createErrorGestion({&error}, 101142, substitute('&2&1&3', separ[1], string(viNbMoiMin), string(viNbMoiMax))).
    end.

end procedure.
