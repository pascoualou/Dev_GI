/*------------------------------------------------------------------------
File        : clotureManuelle.p
Purpose     : tache cloture exercice manuelle
Author(s)   : GGA  -  2017/08/07
Notes       : a partir du programme adb/tache/prmclman.p
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tache.i}
{adblib/include/cttac.i}
{tache/include/tacheClotureManuelle.i}

procedure getClotureManuelle:
    /*------------------------------------------------------------------------------
    Purpose: retourne les informations de la tache
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttTacheClotureManuelle.

    define buffer cttac for cttac.
    define buffer ietab for ietab.

    empty temp-table ttTacheClotureManuelle.
    create ttTacheClotureManuelle.
    assign
        ttTacheClotureManuelle.cTypeContrat     = pcTypeMandat
        ttTacheClotureManuelle.iNumeroContrat   = piNumeroMandat
        ttTacheClotureManuelle.cTypeTache       = {&TYPETACHE-clotureExercieManuelle}
        ttTacheClotureManuelle.lClotureManuelle = no
        ttTacheClotureManuelle.CRUD             = 'R'
    .
    for first cttac no-lock
        where cttac.tpcon = pcTypeMandat
          and cttac.nocon = piNumeroMandat
          and cttac.tptac = {&TYPETACHE-clotureExercieManuelle}:
        assign ttTacheClotureManuelle.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
               ttTacheClotureManuelle.rRowid      = rowid(cttac)
        .         
        for first ietab no-lock
            where ietab.soc-cd   = integer(if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
              and ietab.etab-cd  = piNumeroMandat:
            ttTacheClotureManuelle.lClotureManuelle = ietab.fg-cptim.
        end.
    end.

end procedure.

procedure setClotureManuelle:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheClotureManuelle.

    run majTache.

end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhProc   as handle  no-undo.

    define buffer cttac for cttac.
    define buffer ietab for ietab.

    for first ttTacheClotureManuelle
        where ttTacheClotureManuelle.CRUD = "U":
       find first cttac no-lock
            where cttac.tpcon = ttTacheClotureManuelle.cTypeContrat
              and cttac.nocon = ttTacheClotureManuelle.iNumeroContrat
              and cttac.tptac = {&TYPETACHE-clotureExercieManuelle} no-error.
        if (ttTacheClotureManuelle.lClotureManuelle = no and available cttac)
        or (ttTacheClotureManuelle.lClotureManuelle = yes and not available cttac)
        then do:
            empty temp-table ttCttac.
            create ttCttac.
            assign
                ttCttac.tpcon       = ttTacheClotureManuelle.cTypeContrat
                ttCttac.nocon       = ttTacheClotureManuelle.iNumeroContrat
                ttCttac.tptac       = {&TYPETACHE-clotureExercieManuelle}
                ttCttac.CRUD        = string(ttTacheClotureManuelle.lClotureManuelle, "C/D")
                ttCttac.rRowid      = if available cttac then rowid(cttac) else ?
                ttCttac.dtTimestamp = ttTacheClotureManuelle.dtTimestamp
            .
            // pour cette tache pas de maj de la table tache, mais seulement de la table de relation cttac
            run adblib/cttac_CRUD.p persistent set vhproc.
            run getTokenInstance in vhproc(mToken:JSessionId).
            run setCttac in vhproc(table ttCttac by-reference).
            run destroy in vhproc.
            if mError:erreur() then return.
        end.
        for first ietab exclusive-lock
            where ietab.soc-cd   = integer(if ttTacheClotureManuelle.cTypeContrat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
              and ietab.etab-cd  = ttTacheClotureManuelle.iNumeroContrat:
            ietab.fg-cptim = ttTacheClotureManuelle.lClotureManuelle.
        end.
    end.

end procedure.
