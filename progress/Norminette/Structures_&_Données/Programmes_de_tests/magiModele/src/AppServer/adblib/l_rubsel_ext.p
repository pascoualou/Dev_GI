/*------------------------------------------------------------------------
File        : l_rubsel_ext.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table RUBSEL
Author(s)   : DM - 2017/10/04
Notes       : 
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{adblib/include/rubsel.i}

function f-isNull returns logical private(pcChaine as character):
    /*------------------------------------------------------------------------------
    Purpose:     
    Notes  :
    ------------------------------------------------------------------------------*/
    return pcChaine = ? or pcChaine = "".
end function.

procedure newRubSel:
    /*------------------------------------------------------------------------------
    Purpose: Création nouvel enregistrement de rubsel.     
    Notes  : service appelé par paramBaseRubrique.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttRubsel for ttRubsel.
    define buffer rubsel for rubsel.
    
    create rubsel.
    outils:copyValidField(buffer rubsel:handle, buffer ttRubsel:handle, 'C', mtoken:cUser).
    if not mError:erreur() then mError:createInfoRowid(rowid(rubsel)). // enregistrement créé, permet de renvoyer le rowid en réponse.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.    

procedure majRubSel:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour d'enregistrement de rubsel.     
    Notes  : service appelé par paramBaseRubrique.p
    ------------------------------------------------------------------------------*/
    define parameter buffer rubsel   for rubsel.
    define parameter buffer ttRubsel for ttRubsel.  

    if not outils:isUpdated(buffer rubsel:handle, substitute(outilTraduction:getLibelle(1000320),""), ttRubsel.ixd01, ttRubsel.dtTimestamp) /* 1000320 Base de calcul &1 */
    then outils:copyValidField(buffer rubsel:handle, buffer ttRubsel:handle, 'U', mtoken:cUser).
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.    

procedure delRubsel:
    /*------------------------------------------------------------------------------
    Purpose: Suppression d'un enregistrement de rubsel.     
    Notes  : service appelé par paramBaseRubrique.p
    ------------------------------------------------------------------------------*/
    define parameter buffer ttRubsel for ttRubsel.
    define buffer rubsel for rubsel.

blocTrans:
    do transaction:
        if f-isNull(ttRubsel.tprub) and f-isNull(ttRubsel.cdrub) and f-isNull(ttRubsel.cdlib)
        then for each rubsel exclusive-lock
            where rubsel.tpmdt = ttRubsel.tpmdt
              and rubsel.nomdt = ttRubsel.nomdt
              and rubsel.tpct2 = ttRubsel.tpct2
              and rubsel.noct2 = ttRubsel.noct2
              and rubsel.tptac = ttRubsel.tptac         
              and rubsel.ixd01 = ttRubsel.ixd01:
            delete rubsel no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
        else if ttRubsel.tprub > "" and f-isNull(ttRubsel.cdrub) and f-isNull(ttRubsel.cdlib)
        then for each rubsel exclusive-lock
            where rubsel.tpmdt = ttRubsel.tpmdt
              and rubsel.nomdt = ttRubsel.nomdt
              and rubsel.tpct2 = ttRubsel.tpct2
              and rubsel.noct2 = ttRubsel.noct2
              and rubsel.tptac = ttRubsel.tptac         
              and rubsel.ixd01 = ttRubsel.ixd01
              and rubsel.tprub = ttRubsel.tprub:
            delete rubsel no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
        else for first rubsel exclusive-lock 
            where rubsel.tpmdt = ttRubsel.tpmdt
              and rubsel.nomdt = ttRubsel.nomdt
              and rubsel.tpct2 = ttRubsel.tpct2
              and rubsel.noct2 = ttRubsel.noct2
              and rubsel.tptac = ttRubsel.tptac         
              and rubsel.ixd01 = ttRubsel.ixd01
              and rubsel.tprub = ttRubsel.tprub
              and rubsel.cdrub = ttRubsel.cdrub
              and rubsel.cdlib = ttRubsel.cdlib:
            delete rubsel no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.
