/*------------------------------------------------------------------------
File        : commentaireContrat.p
Purpose     : gestion commentaire contrat
Author(s)   : GGA  -  2017/09/26
Notes       : reprise du pgm adb/cont/gescom00.p
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{note/include/notes.i}
{preprocesseur/type2contrat.i}
{adblib/include/cttac.i}
{preprocesseur/type2tache.i}

procedure getNotesContrat:
    /*------------------------------------------------------------------------------
    Purpose: affichage commentaire d'un mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttNotes.

    define variable vhProcNote as handle no-undo.

    define buffer ctrat for ctrat.

    empty temp-table ttNotes.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ctrat.noblc <> 0 then do:
        run note/notes_CRUD.p persistent set vhProcNote.
        run getTokenInstance in vhProcNote(mToken:JSessionId).
        run getNotes in vhProcNote(ctrat.noblc, input-output table ttNotes).
        run destroy in vhProcNote.
    end.

end procedure.

procedure setNotesContrat:
    /*------------------------------------------------------------------------------
    Purpose: gestion commentaire d'un mandat
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter table for ttNotes.

    define variable vhProcNote  as handle no-undo.
    define variable vhProcCttac as handle no-undo.

    define buffer ctrat for ctrat.
    define buffer cttac for cttac.

    if not can-find (first ttNotes where lookup(ttNotes.CRUD, "C,U,D") > 0) then return.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    if ctrat.noblc = 0
    then do:
        if can-find(first ttNotes where lookup(ttNotes.CRUD, "U,D") > 0)
        then do:
            mError:createError({&error}, 1000549).        //numéro bloc inexistant pour ce madant, modification ou suppression note impossible
            return.
        end.
        if can-find(first ttNotes where ttNotes.iNumeroBlocNote <> 0)
        then do:
            mError:createError({&error}, 1000550).        //Pas encore de note pour ce mandat, mais un numéro de bloc est renseigné
            return.
        end.
        if not can-find(first ttNotes where ttNotes.CRUD = "C") then return.
    end.
    else do:
        if can-find(first ttNotes where ttNotes.iNumeroBlocNote <> ctrat.noblc)
        then do:
            mError:createError({&error}, 1000551).           //un numéro de bloc ne correspond pas à celui du mandat
            return.
        end.
    end.
    run note/notes_CRUD.p persistent set vhProcNote.
    run getTokenInstance in vhProcNote(mToken:JSessionId).
    run setNotes in vhProcNote(input-output table ttNotes).
    run destroy in vhProcNote.
    if mError:erreur() then return.

    for first ctrat
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        if ctrat.noblc = 0
        then for first ttNotes
            where ttNotes.CRUD = "C":
            ctrat.noblc = ttNotes.iNumeroBlocNote.
        end.
        if ctrat.noblc <> 0
        and not can-find(first notes no-lock
                         where notes.noblc = ctrat.noblc)
        then ctrat.noblc = 0.
    end.

    if ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
    then do:
        find first cttac no-lock
             where cttac.tpcon = pcTypeContrat
               and cttac.nocon = piNumeroContrat
               and cttac.tptac = {&TYPETACHE-Commentaires} no-error.
        if (ctrat.noblc = 0 and available cttac)
        or (ctrat.noblc <> 0 and not available cttac)
        then do:
            run adblib/cttac_CRUD.p persistent set vhProcCttac.
            run getTokenInstance in vhProcCttac(mToken:JSessionId).
            empty temp-table ttCttac.
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-Commentaires}
            .
            if ctrat.noblc = 0 and available cttac
            then assign
                ttCttac.CRUD        = "D"
                ttCttac.rRowid      = rowid(cttac)
                ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
            .
            else ttCttac.CRUD = "C".
            run setCttac in vhProcCttac(table ttCttac by-reference).
            if mError:erreur() then return.
        end.
    end.

end procedure.
