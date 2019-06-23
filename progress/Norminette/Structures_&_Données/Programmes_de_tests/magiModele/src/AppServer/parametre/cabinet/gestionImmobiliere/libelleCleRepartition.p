/*------------------------------------------------------------------------
File        : parametre/cabinet/cleRepartition.p
Purpose     :
Author(s)   : DM 2017/12/15
Notes       : à partir de adb/src/prmcl/pcllbcle.p

------------------------------------------------------------------------*/
using parametre.pclie.parametrageCleRepartition.
using parametre.syspr.syspr.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gestionImmobiliere/include/libelleCleRepartition.i &nomtable=ttLibelleCleRepartition &serialName=ttLibelleCleRepartition}
{application/include/combo.i}

function fIsNull returns logical private (pcString as character):
    /*------------------------------------------------------------------------------
    Purpose: retourne vrai si chaine en entree = "" ou ?
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.
end function.

procedure getLibelleCleRepartition:
    /*------------------------------------------------------------------------------
    Purpose: chargement de la liste des clés (code issu de la procédure ChgTabCle)
    Notes  : Service externe appelé par beParametreCabinet.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeCle as character no-undo.
    define output parameter table for ttLibelleCleRepartition.

    define variable voParametrageLibelleCleRepartition as class parametrageCleRepartition no-undo.

    voParametrageLibelleCleRepartition = new parametrageCleRepartition().
    voParametrageLibelleCleRepartition:getLibelleCleRepartition(pcCodeCle, output table ttLibelleCleRepartition by-reference).
    delete object voParametrageLibelleCleRepartition.

end procedure.

procedure initCombo :
    /*------------------------------------------------------------------------------
    Purpose: Chargement combo
    Notes  : Service externe appelé par beParametreCabinet.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.
    define variable voSyspr as class syspr no-undo.

    empty temp-table ttCombo.
    voSyspr = new syspr().
    voSyspr:getComboParametre("TPCLE", "CMBNATURECLE", output table ttCombo by-reference).
    delete object voSyspr.
end procedure.

procedure updateLibelleCleRepartition :
    /*------------------------------------------------------------------------------
    Purpose: Controle et validation des libellés de clé de répartition
    Notes  : Service externe appelé par beParametreCabinet.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLibelleCleRepartition.

blocTrans:
    do transaction:
        run controle.
        if merror:erreur() then undo blocTrans, return.
        run validation.
        if merror:erreur() then undo blocTrans, return.
    end.
end procedure.

procedure controle private:
    /*------------------------------------------------------------------------------
    Purpose: Controle avant validation
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspr as class syspr no-undo.
    define buffer vbttLibelleCleRepartition for ttLibelleCleRepartition.

    voSyspr = new syspr().
boucle:
    for each ttLibelleCleRepartition : // On controle tous les enregistrements qqsoit le CRUD
        if fisnull(ttLibelleCleRepartition.cCodeCle) then do:
            mError:createError({&error}, 1000399). // 1000399 "Le code de la clé est obligatoire"
            leave boucle.
        end.
        if fisnull(ttLibelleCleRepartition.cLibelleCle) then do:
            mError:createError({&error}, 1000400). // 1000400 "Le libellé de la clé est obligatoire"
            leave boucle.
        end.
        if ttLibelleCleRepartition.CRUD <> "D"
        then for first vbttLibelleCleRepartition
            where vbttLibelleCleRepartition.cCodeCle = ttLibelleCleRepartition.cCodeCle
              and vbttLibelleCleRepartition.CRUD <> "D"
              and rowid(vbttLibelleCleRepartition) <> rowid(ttLibelleCleRepartition):
            mError:createError({&error}, 1000402, ttLibelleCleRepartition.cCodeCle). // 1000402 "la cle &1 existe déjà"
            leave boucle.
        end.
        voSyspr:reload("TPCLE", ttLibelleCleRepartition.cNatureCle).
        if lookup(ttLibelleCleRepartition.CRUD,"C,U") > 0 and not voSyspr:isDbParameter then do:
            mError:createError({&error}, 1000401, ttLibelleCleRepartition.cNatureCle). // 1000401 "La nature de la clé &1 n'existe pas"
            leave boucle.
        end.
        voSyspr:reload("LBCLE", ttLibelleCleRepartition.cCodeCle).
        if ttLibelleCleRepartition.CRUD = "C" and voSyspr:isDbParameter then do:
            mError:createError({&error}, 1000402, ttLibelleCleRepartition.cCodeCle). // 1000402 "la cle &1 existe déjà"
            leave boucle.
        end.
    end.
    delete object voSyspr.
end procedure.

procedure validation private:
    /*------------------------------------------------------------------------------
    Purpose: Validation
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcPclie as handle no-undo.

    run adblib/pclie_CRUD.p persistent set vhProcPclie.
    run getTokenInstance in vhProcPclie(mToken:JSessionId).
    run setPclie in vhProcPclie(temp-table ttLibelleCleRepartition:handle).
    run destroy in vhProcPclie.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.
