/*------------------------------------------------------------------------
File        : texteLocataire.p
Purpose     :
Author(s)   : GGA  -  2018/10/04
Notes       : a partir de adb/quit/majqtt20.p 
----------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{bail/include/texteLocataire.i}
{tache/include/tache.i}
{crud/include/equit.i}

procedure getTexte:
    /*------------------------------------------------------------------------------
    Purpose: liste des textes pour un mandant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandant as int64 no-undo.
    define output parameter table for ttTexteLocataire.

    define variable vhProc as handle no-undo.

    empty temp-table ttTexteLocataire. 
    run crud/txrole_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).    
    run getTxrole in vhProc({&TYPEROLE-mandant}, piNumeroMandant, table ttTexteLocataire by-reference).
    run destroy in vhProc.

end procedure.

procedure getListeLocataire:
    /*------------------------------------------------------------------------------
    Purpose: liste des locataires pour un mandant
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandant as int64 no-undo.
    define output parameter table for ttListeLocataire.

    define buffer intnt for intnt. 
    define buffer tache for tache. 
    define buffer ctctt for ctctt. 
    define buffer ctrat for ctrat. 

    empty temp-table ttListeLocataire. 
    
    for each intnt no-lock
       where intnt.tpidt = {&TYPEROLE-mandant}
         and intnt.noidt = piNumeroMandant
         and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance},
        each ctctt no-lock
       where ctctt.tpct1 = intnt.tpcon
         and ctctt.noct1 = intnt.nocon
         and ctctt.tpct2 = {&TYPECONTRAT-Bail},
        each ctrat no-lock
       where ctrat.tpcon = ctctt.tpct2
         and ctrat.nocon = ctctt.noct2
         and (ctrat.dtree = ? or ctrat.dtree > today):
        create ttListeLocataire.
        assign
            ttListeLocataire.CRUD             = "R"
            ttListeLocataire.cTypeRole        = intnt.tpidt    
            ttListeLocataire.iNumeroRole      = intnt.noidt  
            ttListeLocataire.iNumeroLocataire = ctrat.nocon  
        .
        for last tache no-lock
           where tache.tpcon = {&TYPECONTRAT-Bail}
             and tache.nocon = ctrat.nocon
             and tache.tptac = {&TYPETACHE-quittancement}:
            assign       
                ttListeLocataire.iNumeroTexte = tache.notxt
                ttListeLocataire.rRowid       = rowid(tache)
                ttListeLocataire.dtTimestamp  = datetime(tache.dtmsy, tache.hemsy)
            .      
        end.               
    end. 

end procedure.

procedure setTexte:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTexteLocataire.
 
    define variable vhProc as handle no-undo.
 
    define buffer vbttTexteLocataire for ttTexteLocataire.
    define buffer intnt              for intnt. 
    define buffer tache              for tache. 
    define buffer ctctt              for ctctt. 
    define buffer ctrat              for ctrat.     
    define buffer equit              for equit. 
 
    empty temp-table ttTache.    
    empty temp-table ttEquit.
    boucleTexteLocataire:    
    for each ttTexteLocataire
       where ttTexteLocataire.CRUD <> "R":
        if not can-find (first intnt no-lock
                         where intnt.tpidt = ttTexteLocataire.cTypeRole
                           and intnt.noidt = ttTexteLocataire.iNumeroRole)
        then do:
            mError:createError({&error}, 1000876, string(ttTexteLocataire.iNumeroRole)). //demande de mise a jour texte pour un mandant (&1) inexistant
            return.
        end.
        if ttTexteLocataire.CRUD = "C"
        then do:
            if can-find (first vbttTexteLocataire
                         where vbttTexteLocataire.cTypeRole = ttTexteLocataire.cTypeRole
                           and vbttTexteLocataire.iNumeroRole = ttTexteLocataire.iNumeroRole
                           and vbttTexteLocataire.CRUD = "C"
                           and rowid(vbttTexteLocataire) <> rowid(ttTexteLocataire))
            then do:
                mError:createError({&error}, 1000877).       //vous ne pouvez traiter qu'une création de texte à la fois
                return.        
            end.
            if can-find(first txrol no-lock
                        where txrol.tprol = ttTexteLocataire.cTypeRole
                          and txrol.norol = ttTexteLocataire.iNumeroRole
                          and txrol.notxt = ttTexteLocataire.iNumeroTexte)
            then do:
                mError:createError({&error}, 1000880, substitute("&2&1&3", separ[1], ttTexteLocataire.iNumeroTexte, ttTexteLocataire.iNumeroRole)). //demande de création d'un texte (&1) déjà existant pour le mandant (&2)
                return.                                                   
            end.
        end.
        if ttTexteLocataire.CRUD = "U" or ttTexteLocataire.CRUD = "D"
        then do:
            if not can-find(first txrole no-lock
                            where txrol.tprol = ttTexteLocataire.cTypeRole
                              and txrol.norol = ttTexteLocataire.iNumeroRole
                              and txrol.notxt = ttTexteLocataire.iNumeroTexte)
            then do:
                mError:createError({&error}, 1000878, substitute("&2&1&3", separ[1], ttTexteLocataire.iNumeroTexte, ttTexteLocataire.iNumeroRole)). //demande de mise à jour d'un texte (&1) inexistant pour le mandant (&2)
                return.                        
            end.            
        end.     
        if ttTexteLocataire.CRUD = "D"
        then do:         
            for each intnt no-lock
               where intnt.tpidt = ttTexteLocataire.cTypeRole
                 and intnt.noidt = ttTexteLocataire.iNumeroRole
                 and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance},
                each ctctt no-lock
               where ctctt.tpct1 = intnt.tpcon
                 and ctctt.noct1 = intnt.nocon
                 and ctctt.tpct2 = {&TYPECONTRAT-Bail},
                each ctrat   no-lock
               where ctrat.tpcon = ctctt.tpct2
                 and ctrat.nocon = ctctt.noct2
                 and (ctrat.dtree = ? or ctrat.dtree > today),
                last tache no-lock
               where tache.tpcon = {&TYPECONTRAT-Bail}
                 and tache.nocon = ctrat.nocon
                 and tache.tptac = {&TYPETACHE-quittancement}:
                create ttTache.
                assign
                    ttTache.tpcon       = tache.tpcon 
                    ttTache.nocon       = tache.nocon
                    ttTache.tptac       = tache.tptac
                    ttTache.notac       = tache.notac 
                    ttTache.CRUD        = "U"
                    ttTache.rRowid      = rowid(tache)
                    ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                    ttTache.notxt       = 0 
                .
                for first equit no-lock  
                    where equit.noloc = ctrat.nocon:
                    create ttEquit.
                    assign
                        ttEquit.noloc       = equit.noloc
                        ttEquit.noqtt       = equit.noqtt
                        ttEquit.CRUD        = "U"
                        ttEquit.rRowid      = rowid(equit)
                        ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
                        ttEquit.fgtrf       = no
                    .
                end.
            end. 
        end.
    end.
    
    run crud/txrole_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).    
    run setTxrole in vhProc(table ttTexteLocataire by-reference).
    run destroy in vhProc.
    if mError:erreur() then return.    
    
    run crud/tache_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run settache in vhProc(table ttTache by-reference).
    run destroy in vhProc.
    if mError:erreur() then return.

    run crud/equit_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setEquit in vhProc(table ttEquit by-reference).
    run destroy in vhProc.
    if mError:erreur() then return.

end procedure.

procedure setListeLocataire:
    /*------------------------------------------------------------------------------
    Purpose:  
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttListeLocataire.
    
    define variable vhProc as handle no-undo.
 
    define buffer tache for tache. 
 
    empty temp-table ttTache.    
    for each ttListeLocataire
       where ttListeLocataire.CRUD = "U":
        if ttListeLocataire.iNumeroTexte <> 0
        and not can-find(first txrol no-lock
                         where txrol.tprol = ttListeLocataire.cTypeRole
                           and txrol.norol = ttListeLocataire.iNumeroRole
                           and txrol.notxt = ttListeLocataire.iNumeroTexte)
        then do:
            mError:createError({&error}, 1000879, substitute("&2&1&3", separ[1], ttListeLocataire.iNumeroTexte, ttListeLocataire.iNumeroRole)). //demande de rattachement d'un texte (&1) inexistant pour le mandant (&2)
            return.                                                   
        end.
        for last tache no-lock
           where tache.tpcon = {&TYPECONTRAT-Bail}
             and tache.nocon = ttListeLocataire.iNumeroLocataire
             and tache.tptac = {&TYPETACHE-quittancement}:
            create ttTache.
            assign
                ttTache.tpcon       = tache.tpcon 
                ttTache.nocon       = tache.nocon
                ttTache.tptac       = tache.tptac
                ttTache.notac       = tache.notac 
                ttTache.CRUD        = "U"
                ttTache.rRowid      = rowid(tache)
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                ttTache.notxt       = ttListeLocataire.iNumeroTexte 
                .
        end.
    end.
    run crud/tache_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run settache in vhProc(table ttTache by-reference).
    run destroy in vhProc.
    if mError:erreur() then return.
    
end procedure.
