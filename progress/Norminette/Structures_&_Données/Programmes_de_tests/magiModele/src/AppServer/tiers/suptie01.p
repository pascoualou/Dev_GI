/*------------------------------------------------------------------------
File      : suptie01.p
Purpose   : Suppression d'un Tiers après contrôle (lib\ctsuptie.p) (en gestion uniquement)
Author(s) : SY 13/01/2004    -  GGA 2018/04/18
Notes     : adb/lib/suptie01.p
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{outils/include/lancementProgramme.i}

define variable ghProc as handle no-undo.

procedure suppressionTiers:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroTiers as int64 no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
    
    define variable viNumeroTiersDeLaListe as integer   no-undo.
    define variable vcListeIndividu        as character no-undo.
    define variable viI                    as integer   no-undo.
    define variable vcRetourCtrl           as character no-undo.

    define buffer litie for litie.

    /* liens couple */
    for each litie no-lock
       where litie.notie = piNumeroTiers:
        vcListeIndividu = vcListeIndividu + "," + string(litie.noind).
    end.
    ghProc = lancementPgm("tiers/tiers_CRUD.p", poCollectionHandlePgm).
    run supTie01 in ghProc(piNumeroTiers).
    if mError:erreur() then return.
    if vcListeIndividu <> "" 
    then do:
        vcListeIndividu = substring(vcListeIndividu, 2).
        do viI = 1 to num-entries(vcListeIndividu):
            viNumeroTiersDeLaListe = integer(entry(viI, vcListeIndividu)).
            ghProc = lancementPgm("tiers/ctsuptie.p", poCollectionHandlePgm).         
            run controleTiers in ghProc(viNumeroTiersDeLaListe, no, output vcRetourCtrl).
            if vcRetourCtrl = "00"
            then do:
                ghProc = lancementPgm("tiers/tiers_CRUD.p", poCollectionHandlePgm).
                run supTie01 in ghProc(viNumeroTiersDeLaListe).
                if mError:erreur() then return.
            end.
        end.
    end.

end procedure.

