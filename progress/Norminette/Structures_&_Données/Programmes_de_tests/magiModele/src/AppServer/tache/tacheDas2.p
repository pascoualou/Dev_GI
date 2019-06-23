/*------------------------------------------------------------------------
File        : tacheDas2.p
Purpose     : tache Das2
Author(s)   : OFA  2017/12/11
Notes       : a partir de adb/tach/prmobdas.p
Derniere revue: 2018/05/28 - ofa: OK
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2honoraire.i}
{preprocesseur/codeReglement.i}

using parametre.pclie.pclie.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheDas2.i}
{parametre/cabinet/gerance/include/paramDas2.i}
{application/include/error.i}

procedure initTacheDas2:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la tâche Das2 à partir des paramètres client
    Notes: service
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as integer   no-undo.
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter pcTypeTraitement as character no-undo.
    define output parameter table for ttTacheDas2.

    define variable vhproc as handle no-undo.
    
    define buffer ctrat for ctrat.
    define buffer honor for honor.

    run parametre/cabinet/gerance/defautMandatGerance.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run getParamDas2 in vhproc(output table ttParamDas2 by-reference).
    run destroy in vhproc.

    for first ctrat no-lock                                             //recherche mandat
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroMandat:
        create ttTacheDas2.
        buffer-copy ttParamDas2 to ttTacheDas2
            assign
            ttTacheDas2.CRUD                   = if pcTypeTraitement = "INITIALISATION" then 'R' else 'C'
            ttTacheDas2.cTypeContrat           = pcTypeContrat
            ttTacheDas2.iNumeroContrat         = piNumeroMandat
            ttTacheDas2.cTypeTache             = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-Das2Gerance} else {&TYPETACHE-Das2Copropriete})
            ttTacheDas2.lDeclaration           = ttParamDas2.lDeclaration
            ttTacheDas2.cTypeBaremeHonoraires  = {&TYPEHONORAIRE-Das2T}
            ttTacheDas2.iCodeBaremeHonoraires  = integer(ttParamDas2.cCodeHonoraire)
            ttTacheDas2.daActivation           = ctrat.dtdeb
        .
        //Libellé du barême d'honoraires
        for first honor no-lock
            where honor.tphon = ttTacheDas2.cTypeBaremeHonoraires
              and honor.cdhon = ttTacheDas2.iCodeBaremeHonoraires:
            ttTacheDas2.cLibelleBaremeHonoraires = if honor.lbhon > ""
                                                   then substitute('&1-&2', outilTraduction:getLibelleProg("O_NTH", honor.nthon), honor.lbhon)
                                                   else outilTraduction:getLibelleProg("O_NTH", honor.nthon). 
        end.
    end.

end procedure.

procedure miseAJourTableTache private:
    /*------------------------------------------------------------------------------
     Purpose: Mise à jour de la table tache à partir du dataset
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vhproc  as handle  no-undo.
    define variable vrTtTacheDas2 as rowid no-undo.

    define buffer cttac for cttac.

    vrTtTacheDas2 = rowid(ttTacheDas2).
    //Mise à jour table tache
    run tache/tache.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run setTache in vhproc(table ttTacheDas2 by-reference).
    if mError:erreur() then return.

    // Mise à jour table cttac: utilisation de la table ttTacheDas2 pour éviter de devoir créer un ttCttac sachant que les champs à mettre à jour sont identiques
    for first ttTacheDas2 where rowid(ttTacheDas2) = vrTtTacheDas2,
        first cttac no-lock
         where cttac.tpcon = ttTacheDas2.cTypeContrat
           and cttac.nocon = ttTacheDas2.iNumeroContrat
           and cttac.tptac = ttTacheDas2.cTypeTache:
        assign
            ttTacheDas2.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            ttTacheDas2.rRowid      = rowid(cttac)
        .
    end.
    run adblib/cttac_CRUD.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run setCttac in vhproc(table ttTacheDas2 by-reference).
    run destroy in vhproc.

end procedure.

procedure setTacheDas2:
    /*------------------------------------------------------------------------------
    Purpose: Update de la tâche Das2
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheDas2.
    
    for first ttTacheDas2
        where lookup(ttTacheDas2.CRUD, "C,U,D") > 0:
        run controlesAvantValidation.
        if mError:erreur() then return.
        run miseAJourTableTache.
    end.

end procedure.

procedure getTacheDas2:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des informations de la tâche DAS2
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as int64     no-undo.
    define input  parameter pcTypeContrat  as character no-undo.
    define output parameter table for ttTacheDas2.

    define variable vhproc  as handle  no-undo.
    define buffer tache     for tache.
    define buffer honor     for honor.

    empty temp-table ttTacheDas2.
    run tache/tache.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run readTache in vhproc(pcTypeContrat, piNumeroMandat, if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then {&TYPETACHE-Das2Gerance} else {&TYPETACHE-Das2Copropriete}, 0, table ttTacheDas2 by-reference).

    for first ttTacheDas2
      , first honor no-lock
        where honor.tphon = ttTacheDas2.cTypeBaremeHonoraires
        and   honor.cdhon = ttTacheDas2.iCodeBaremeHonoraires:
        ttTacheDas2.cLibelleBaremeHonoraires = if honor.lbhon > ""
                                               then substitute('&1-&2', outilTraduction:getLibelleProg("O_NTH", honor.nthon), honor.lbhon)
                                               else outilTraduction:getLibelleProg("O_NTH", honor.nthon). 
    end.
    run destroy in vhproc.

end procedure.

procedure controlesAvantValidation private:
    /*------------------------------------------------------------------------------
    Purpose: Contrôle des informations saisies par l'utilisateur avant de faire l'update 
    Notes  : 
    ------------------------------------------------------------------------------*/
    if ttTacheDas2.daActivation = ?
    then mError:createError({&error}, 100057). //La date d'application est obligatoire !
    else if ttTacheDas2.lDeclaration and ttTacheDas2.iCodeBaremeHonoraires = 0
    then mError:createError({&error}, 100343). //Le numéro d'honoraire est obligatoire !
    else if not can-find(first honor no-lock
        where honor.tphon = ttTacheDas2.cTypeBaremeHonoraires
          and honor.cdhon = ttTacheDas2.iCodeBaremeHonoraires)
    then mError:createError({&error}, 1000290). //numéro d'honoraire inexistant
end procedure.
