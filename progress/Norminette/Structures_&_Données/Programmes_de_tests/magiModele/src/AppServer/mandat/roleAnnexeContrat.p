/*------------------------------------------------------------------------
File        : roleAnnexeContrat.p
Purpose     : role annexe d'un contrat
Author(s)   : GGA  -  2017/08/31
Notes       : reprise du pgm adb/cont/gesanx00.p
              pour le moment reprise du code necessaire pour type de contrat 01030, 01039 
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}

using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{mandat/include/roleMandat.i &nomtable=ttRoleAnnexe}
{adblib/include/intnt.i}
{adblib/include/coloc.i}

procedure getRoleAnnexe:
    /*------------------------------------------------------------------------------
    Purpose: affichage role annexe d'un contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttRoleAnnexe.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    empty temp-table ttRoleAnnexe.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run chargeCombo (buffer ctrat).     //on conserve l'utilisation de la combo car plus facile de retrouver les roles annexes
    for each ttCombo
        where ttCombo.cNomCombo = "CMBROLEANNEXE"
      , each intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = ttCombo.cCode:
        create ttRoleAnnexe.
        assign
            ttRoleAnnexe.cTypeContrat     = intnt.tpcon
            ttRoleAnnexe.iNumeroContrat   = intnt.nocon
            ttRoleAnnexe.cTypeRole        = intnt.tpidt
            ttRoleAnnexe.cLibTypeRole     = outilTraduction:getLibelleProgZone2("R_CR2", ctrat.ntcon, intnt.tpidt)
            ttRoleAnnexe.iNumeroRole      = intnt.noidt
            ttRoleAnnexe.cNom             = outilFormatage:getNomTiers(intnt.tpidt, intnt.noidt)
            ttRoleAnnexe.cAdresse         = outilFormatage:formatageAdresse(intnt.tpidt, intnt.noidt)
            ttRoleAnnexe.dtTimestamp      = datetime(intnt.dtmsy, intnt.hemsy)
            ttRoleAnnexe.CRUD             = "R"
            ttRoleAnnexe.rRowid           = rowid(intnt)
        .
    end.
end procedure.

procedure setRoleAnnexe:
    /*------------------------------------------------------------------------------
    Purpose: maj role annexe d'un contrat
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRoleAnnexe.

    define variable vhIntnt      as handle no-undo.
    define variable vhAlimaj     as handle no-undo.
    define variable vhMandatSepa as handle no-undo.
    define variable vhColoc      as handle no-undo.

    define buffer ctrat         for ctrat.
    define buffer intnt         for intnt.
    define buffer coloc         for coloc.
    define buffer vbroles       for roles.

    find first ttRoleAnnexe where lookup(ttRoleAnnexe.crud, "C,D") > 0 no-error.
    if not available ttRoleAnnexe
    then return. 
    find first ctrat no-lock
         where ctrat.tpcon = ttRoleAnnexe.cTypeContrat
           and ctrat.nocon = ttRoleAnnexe.iNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run chargeCombo(buffer ctrat).  //on conserve l'utilsation de la combo car plus facilde de controler les roles annexes
blocMiseAJour:
    do:
        empty temp-table ttIntnt.
        empty temp-table ttColoc.
        for each ttRoleAnnexe
            where ttRoleAnnexe.crud = 'C':
            if not can-find(first ttCombo
                            where ttCombo.cNomCombo = "CMBROLEANNEXE"
                              and ttCombo.cCode     = ttRoleAnnexe.cTypeRole)
            then do:
                mError:createError({&error}, 1000592, ttRoleAnnexe.cTypeRole).         //type de rôle &1 interdit
                leave blocMiseAJour.
            end.
            if not can-find(first vbroles no-lock
                            where vbroles.tprol = ttRoleAnnexe.cTypeRole
                              and vbroles.norol = ttRoleAnnexe.iNumeroRole)
            then do:   
                mError:createError({&error}, 1000599, substitute('&2&1&3', separ[1], ttRoleAnnexe.cTypeRole, ttRoleAnnexe.iNumeroRole)).      //rôle &1 &2 inexistant
                leave blocMiseAJour.            
            end.
            create ttIntnt.
            assign
                ttIntnt.tpidt = ttRoleAnnexe.cTypeRole
                ttIntnt.noidt = ttRoleAnnexe.iNumeroRole
                ttIntnt.tpcon = ttRoleAnnexe.cTypeContrat
                ttIntnt.nocon = ttRoleAnnexe.iNumeroContrat
                ttIntnt.nbnum = if ttRoleAnnexe.cTypeRole = {&TYPEROLE-colocataire}
                                then year(ctrat.dtini) * 10000 + month(ctrat.dtini) * 100 + day(ctrat.dtini)
                                else 0
                ttIntnt.idsui = 0
                ttIntnt.nbden = 0
                ttIntnt.cdreg = ""
                ttIntnt.lbdiv = ""
                ttIntnt.CRUD  = 'C'
            .
        end.
        
        for each ttRoleAnnexe
            where ttRoleAnnexe.crud = 'D':
            find first intnt no-lock
                where rowid(intnt) = ttRoleAnnexe.rRowid no-error.
            if not available intnt
            then do:
                mError:createError({&error}, 1000208, string(ttRoleAnnexe.iNumeroRole)).
                leave blocMiseAJour.
            end.
            if can-find(first coloc no-lock                           //Vérification que le colocataire n'est pas dans une répartition historisée
                        where coloc.tpidt = ttRoleAnnexe.cTypeRole
                          and coloc.noidt = ttRoleAnnexe.iNumeroRole
                          and coloc.tpcon = ttRoleAnnexe.cTypeContrat
                          and coloc.nocon = ttRoleAnnexe.iNumeroContrat
                          and coloc.noqtt > 0)
            then do:
                mError:createError({&error}, 1000591).              //Suppression impossible car le colocataire est présent dans une répartition historisée
                leave blocMiseAJour.
            end.
            create ttIntnt.
            assign
                ttIntnt.tpidt       = intnt.tpidt
                ttIntnt.noidt       = intnt.noidt
                ttIntnt.tpcon       = intnt.tpcon
                ttIntnt.nocon       = intnt.nocon
                ttIntnt.nbnum       = intnt.nbnum
                ttIntnt.idpre       = intnt.idpre
                ttIntnt.idsui       = intnt.idsui
                ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
                ttIntnt.rRowid      = rowid(intnt)
                ttIntnt.CRUD        = 'D'
            .
            /* Suppression de l'entete du colocataire */
            for first coloc no-lock
                where coloc.tpidt = ttRoleAnnexe.cTypeRole
                  and coloc.noidt = ttRoleAnnexe.iNumeroRole
                  and coloc.tpcon = ttRoleAnnexe.cTypeContrat
                  and coloc.nocon = ttRoleAnnexe.iNumeroContrat
                  and coloc.noqtt = 0:
                create ttColoc.
                assign
                    ttColoc.tpcon       = coloc.tpcon
                    ttColoc.nocon       = coloc.nocon
                    ttColoc.msqtt       = coloc.msqtt
                    ttColoc.noord       = coloc.noord
                    ttColoc.tpidt       = coloc.tpidt
                    ttColoc.noidt       = coloc.noidt
                    ttColoc.dtTimestamp = datetime(coloc.dtmsy, coloc.hemsy)
                    ttColoc.rRowid      = rowid(coloc)
                    ttColoc.CRUD        = 'D'
                .
            end.
            
            /* Ajout SY le 26/07/2013 : SEPA */
            if valid-handle(vhMandatSepa) = no
            then do:
                run "adblib/mandatSEPA_CRUD.p" persistent set vhMandatSepa.
                run getTokenInstance in vhMandatSepa (mToken:JSessionId).
            end.
            run deleteMandatSepa01 in vhMandatSepa({&TYPECONTRAT-sepa}, ttRoleAnnexe.cTypeContrat, ttRoleAnnexe.iNumeroContrat, ttRoleAnnexe.cTypeRole, ttRoleAnnexe.iNumeroRole).
            if mError:erreur() = yes then leave blocMiseAJour.
            
            if valid-handle(vhAlimaj) = no
            then do:
                run "application/transfert/GI_alimaj.p" persistent set vhAlimaj.
                run getTokenInstance in vhAlimaj (mToken:JSessionId).
            end.
            run majTrace in vhAlimaj (integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
            if mError:erreur() = yes then leave blocMiseAJour.
        
        end.
        
        if can-find(first ttIntnt) then do:
            run adblib/intnt_CRUD.p persistent set vhIntnt.
            run getTokenInstance in vhIntnt(mToken:JSessionId).
            run setIntnt in vhIntnt(table ttIntnt by-reference).
            if mError:erreur() = yes then leave blocMiseAJour.
        end.
        if can-find(first ttColoc) then do:
            run adblib/coloc_CRUD.p persistent set vhColoc.
            run getTokenInstance in vhColoc (mToken:JSessionId).
            run setColoc in vhColoc(table ttColoc by-reference).
            if mError:erreur() = yes then leave blocMiseAJour.
        end.
    
    end.
    if valid-handle(vhMandatSepa) then run destroy in vhMandatSepa.
    if valid-handle(vhAlimaj) then run destroy in vhAlimaj.
    if valid-handle(vhIntnt) then run destroy in vhIntnt.
    if valid-handle(vhColoc) then run destroy in vhColoc.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure initComboRoleAnnexe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.    
    define output parameter table for ttCombo.

    define buffer ctrat for ctrat.
    
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    run chargeCombo(buffer ctrat).

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les combos
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable viNumeroItem    as integer no-undo.
    define variable vlGerantExterne as logical no-undo.
    define variable voSyspg         as class syspg no-undo.
        
    define buffer intnt  for intnt.
    define buffer sys_pg for sys_pg.

    empty temp-table ttCombo.
    
    voSyspg = new syspg().
    if ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
    and lookup(mtoken:cRefGerance, "03308,03318,06505,06506") > 0 
    then do:
        if ctrat.tpgerance = "00002" or ctrat.tpgerance = "00003"
        then vlGerantExterne = yes.
        else for first intnt no-lock
            where intnt.tpcon = ctrat.tpcon
              and intnt.nocon = ctrat.nocon
              and intnt.tpidt = "00078":
            vlGerantExterne = yes.
        end.
    end.
boucle:
    for each sys_pg no-lock
        where sys_pg.tppar = "R_CR2"
          and sys_pg.zone1 = ctrat.ntcon:
        if vlGerantExterne = no and sys_pg.zone2 = "00078" then next boucle.
        voSyspg:creationttCombo("CMBROLEANNEXE", sys_pg.zone2, outilTraduction:getLibelle(sys_pg.nome1), output table ttCombo by-reference).
    end.
    delete object voSyspg.

end procedure.
