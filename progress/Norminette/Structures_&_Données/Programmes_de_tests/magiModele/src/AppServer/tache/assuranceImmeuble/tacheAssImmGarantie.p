/*------------------------------------------------------------------------
File        : tacheAssImmGarantie.p
Purpose     : tache assurance immeuble garantie
Author(s)   : GGA  -  2017/11/24
Notes       : a partir de adb/tach/prmasgar.p adb/tach/prmobgar.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}

using parametre.syspg.parametrageGarantie.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheAssuranceImmeuble.i}
{tache/include/tache.i}
{adblib/include/cttac.i}

procedure getGarantie:
    /*------------------------------------------------------------------------------
    Purpose: lecture tache garantie assurance 
    Notes  : service externe
    @param piNumeroContrat       : numero d'assurance
    @param pcTypeContrat         : type de contrat d'assurance TYPECONTRAT-assuranceGerance (01039) ou TYPECONTRAT-assuranceSyndic (01044)      
    @param ttGarantieAssImm      : infos garantie   
    @param ttTypeGarantieAssImm  : liste des types de garantie   
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttGarantieAssImm.
    define output parameter table for ttTypeGarantieAssImm.

    define variable vcCode    as character no-undo.
    define variable vcLibelle as character no-undo.
    define variable viI       as integer   no-undo.
    define variable voGarantie as class parametrageGarantie no-undo.
    
    define buffer ctrat for ctrat.
    define buffer tache for tache.
    
    empty temp-table ttGarantieAssImm.
    empty temp-table ttTypeGarantieAssImm.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-GarantieAssurance} no-error.
    if not available tache 
    then do:
        mError:createError({&error}, 1000407). // Tache inexistante
        return.
    end.
    create ttGarantieAssImm.
    assign
        ttGarantieAssImm.iNumeroTache              = tache.noita
        ttGarantieAssImm.cTypeContrat              = tache.tpcon
        ttGarantieAssImm.iNumeroContrat            = tache.nocon
        ttGarantieAssImm.iChronoTache              = tache.notac
        ttGarantieAssImm.lReconstructionValeurNeuf = (tache.tpfin = "yes")
        ttGarantieAssImm.lLimiteCapital            = (tache.ntges = "yes")
        ttGarantieAssImm.dValLimiteCapital         = tache.mtreg
        ttGarantieAssImm.dtTimestamp               = datetime(tache.dtmsy, tache.hemsy)
        ttGarantieAssImm.CRUD                      = 'R'
        ttGarantieAssImm.rRowid                    = rowid(tache)
    .
    voGarantie = new parametrageGarantie().
    voGarantie:listeGarantie(ctrat.ntcon, output vcCode, output vcLibelle). 
    delete object voGarantie.
    do viI = 1 to num-entries(vcCode, '@'):
        create ttTypeGarantieAssImm.
        assign 
            ttTypeGarantieAssImm.cCodeTypeGarantie = entry(viI, vcCode, '@')  
            ttTypeGarantieAssImm.cLibTypeGarantie  = entry(viI, vcLibelle, '@')
            ttTypeGarantieAssImm.lGarantieActive   = (lookup(entry(viI, vcCode, '@'), tache.lbdiv, '@') > 0)
        .  
    end.

end procedure.

procedure setGarantie:
    /*------------------------------------------------------------------------------
    Purpose: maj tache garantie assurance 
    Notes  : service externe
    @param ttGarantieAssImm      : infos garantie   
    @param ttTypeGarantieAssImm  : liste des types de garantie   
    ------------------------------------------------------------------------------*/
    define input parameter table for ttGarantieAssImm.
    define input parameter table for ttTypeGarantieAssImm.

    define buffer tache for tache.

    for first ttGarantieAssImm where lookup(ttGarantieAssImm.CRUD, "C,U,D") > 0:
        if can-find(first ctrat no-lock
                    where ctrat.tpcon = ttGarantieAssImm.cTypeContrat
                      and ctrat.nocon = ttGarantieAssImm.iNumeroContrat)
        then do:
            find last tache no-lock
                where tache.tpcon = ttGarantieAssImm.cTypeContrat
                  and tache.nocon = ttGarantieAssImm.iNumeroContrat
                  and tache.tptac = {&TYPETACHE-GarantieAssurance} no-error.
            if not available tache and lookup(ttGarantieAssImm.CRUD, "U,D") > 0
            then mError:createError({&error}, 1000413). // modification d'une tache inexistante
            else if available tache and ttGarantieAssImm.CRUD = "C"
            then mError:createError({&error}, 1000581). // 1000581 "Création d'une tache existante"
            else run majtbltch(buffer ttGarantieAssImm).
        end.
        else mError:createError({&error}, 100057).
    end.

end procedure.

procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache garantie assurance 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttGarantieAssImm for ttGarantieAssImm. 
    
    define variable vhTache       as handle    no-undo.
    define variable vhCttac       as handle    no-undo.
    define variable vcListeGarSel as character no-undo. 

    define buffer cttac for cttac.

    for each ttTypeGarantieAssImm                  //constitution de la liste des garanties selectionnees  
        where ttTypeGarantieAssImm.lGarantieActive:
        vcListeGarSel = substitute('&1@&2', vcListeGarSel, string(ttTypeGarantieAssImm.cCodeTypeGarantie)).
    end.
    vcListeGarSel = trim(vcListeGarSel, '@').
    empty temp-table ttTache.
    create ttTache.
    assign
        ttTache.noita       = ttGarantieAssImm.iNumeroTache
        ttTache.tpcon       = ttGarantieAssImm.cTypeContrat
        ttTache.nocon       = ttGarantieAssImm.iNumeroContrat
        ttTache.tptac       = {&TYPETACHE-GarantieAssurance}
        ttTache.notac       = ttGarantieAssImm.iChronoTache
        ttTache.lbdiv       = vcListeGarSel 
        ttTache.tpfin       = string(ttGarantieAssImm.lReconstructionValeurNeuf, "yes/no")
        ttTache.ntges       = string(ttGarantieAssImm.lLimiteCapital, "yes/no")
        ttTache.mtreg       = ttGarantieAssImm.dValLimiteCapital
        ttTache.CRUD        = ttGarantieAssImm.CRUD
        ttTache.dtTimestamp = ttGarantieAssImm.dtTimestamp
        ttTache.rRowid      = ttGarantieAssImm.rRowid
    .   
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    run destroy in vhTache.  
    if mError:erreur() then return.

    empty temp-table ttCttac.
    if lookup(ttGarantieAssImm.CRUD, "U,C") > 0
    then do:
        if not can-find(first cttac no-lock
            where cttac.tpcon = ttGarantieAssImm.cTypeContrat
              and cttac.nocon = ttGarantieAssImm.iNumeroContrat
              and cttac.tptac = {&TYPETACHE-GarantieAssurance})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = ttGarantieAssImm.cTypeContrat
                ttCttac.nocon = ttGarantieAssImm.iNumeroContrat
                ttCttac.tptac = {&TYPETACHE-GarantieAssurance}
                ttCttac.CRUD  = "C"
            .
        end.
    end.
    else if ttGarantieAssImm.CRUD = "D"
    then for first cttac no-lock
        where cttac.tpcon = ttGarantieAssImm.cTypeContrat
          and cttac.nocon = ttGarantieAssImm.iNumeroContrat
          and cttac.tptac = {&TYPETACHE-GarantieAssurance}:
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
    if can-find(first ttCttac) then do:
        run adblib/cttac_CRUD.p persistent set vhCttac.
        run getTokenInstance in vhCttac(mToken:JSessionId).        
        run setCttac in vhCttac(table ttCttac by-reference).
        run destroy in vhCttac.
    end.
end procedure.

procedure initGarantie:
    /*------------------------------------------------------------------------------
    Purpose: initialisation tache garantie assurance 
             creation table echange a partir des données par defaut quand tache n'existe pas
    Notes  : service externe
    @param piNumeroContrat       : numero d'assurance
    @param pcTypeContrat         : type de contrat d'assurance TYPECONTRAT-assuranceGerance (01039) ou TYPECONTRAT-assuranceSyndic (01044)      
    @param ttGarantieAssImm      : infos garantie   
    @param ttTypeGarantieAssImm  : liste des types de garantie   
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttGarantieAssImm.
    define output parameter table for ttTypeGarantieAssImm.

    define variable vcCode    as character no-undo.
    define variable vcLibelle as character no-undo.
    define variable viI       as integer   no-undo.
    define variable voGarantie as class parametrageGarantie no-undo.
    
    define buffer ctrat for ctrat.
    
    empty temp-table ttGarantieAssImm.
    empty temp-table ttTypeGarantieAssImm.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-GarantieAssurance})
    then do:
        mError:createError({&error}, 1000582). // 1000582 "Demande d'initialisation d'une tache existante"
        return.
    end.
    create ttGarantieAssImm.
    assign
        ttGarantieAssImm.iNumeroTache              = 0
        ttGarantieAssImm.cTypeContrat              = pcTypeContrat
        ttGarantieAssImm.iNumeroContrat            = piNumeroContrat
        ttGarantieAssImm.iChronoTache              = 1
        ttGarantieAssImm.lReconstructionValeurNeuf = no
        ttGarantieAssImm.lLimiteCapital            = no
        ttGarantieAssImm.dValLimiteCapital         = 0
        ttGarantieAssImm.CRUD                      = 'C'
    .
    voGarantie = new parametrageGarantie().
    voGarantie:listeGarantie(ctrat.ntcon, output vcCode, output vcLibelle). 
    delete object voGarantie.
    do viI = 1 to num-entries(vcCode, '@'):
        create ttTypeGarantieAssImm.
        assign 
            ttTypeGarantieAssImm.cCodeTypeGarantie = entry(viI, vcCode, '@')  
            ttTypeGarantieAssImm.cLibTypeGarantie  = entry(viI, vcLibelle, '@')
            ttTypeGarantieAssImm.lGarantieActive   = no
        .  
    end.
end procedure.
