/*------------------------------------------------------------------------
File        : tacheGestionnaireMandat.p
Purpose     : tache gestionnaire mandat
Author(s)   : GGA  2017/10/13
Notes       : a partir de adb/tach/prmbxges.p


ATTENTION creation uniquement pour tester la création du mandat et faire la creation de cette tache qui est dans la PEC du mandat
sans regarder dans le pgm prmbxges.p 

------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tache.i}
{adblib/include/cttac.i}

procedure creationAutoGestionnaireMandat:
    /*------------------------------------------------------------------------------
    Purpose: creation automatique de la tache gestionnaire mandat (en PEC contrat) 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.

    define variable vhTache as handle no-undo.
    define variable vhCttac as handle no-undo.

    if can-find(first cttac no-lock
                where cttac.tpcon = pcTypeMandat
                  and cttac.nocon = piNumeroMandat
                  and cttac.tptac = {&TYPETACHE-services})
    then do:
        mError:createError({&error}, "Tache déjà existante, création interdite").
        return.
    end.
    create ttCttac.
    assign
        ttCttac.tpcon = pcTypeMandat
        ttCttac.nocon = piNumeroMandat
        ttCttac.tptac = {&TYPETACHE-services}
        ttCttac.CRUD  = "C"
    .
    run adblib/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).        
    run setCttac in vhCttac(table ttCttac by-reference).
    run destroy in vhCttac.
    if mError:erreur() then return.

end procedure.

