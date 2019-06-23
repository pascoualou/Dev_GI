/*------------------------------------------------------------------------
File        : beMagiToken.cls
Purpose     :
Author(s)   : kantena - 2016/05/09
Notes       :
------------------------------------------------------------------------*/

using outils.outilHandle.
using oerealm.token.

block-level on error undo, throw.

class oerealm.beMagiToken:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define public static property mtoken  as class oerealm.token     no-undo get. set.
    define public static property mLogger as class outils.logHandler no-undo get. set.
    define public static property cPort   as character               no-undo get. set.

    constructor public beMagiToken():
    /*------------------------------------------------------------------------------
    Purpose: Création d'un objet magiToken vide
    Notes:
    ------------------------------------------------------------------------------*/
        mToken  = new oerealm.token().
        mLogger = new outils.logHandler().
        mLogger:mtoken = mToken.

    end constructor.

    method public static character get(pcCode as character):
    /*------------------------------------------------------------------------------
     Purpose: Getter de la propriété cValeur.
     Notes:
    ------------------------------------------------------------------------------*/
        define variable viCpt     as integer   no-undo.
        define variable viEntries as integer   no-undo.
        define variable vcEntry   as character no-undo.

        viEntries = num-entries(mtoken:cValeur, mtoken:cItemSep).
        do viCpt = 1 to viEntries:
            vcEntry = entry(viCpt, mtoken:cValeur, mtoken:cItemSep).
            if entry(1, vcEntry, mtoken:cCodeSep) = pcCode
            then return entry(2, vcEntry, mtoken:cCodeSep).
        end.
        return ?.

    end method.

    method public static void set(pcCode as character, pcValeur as character):
        /*------------------------------------------------------------------------------
        Purpose: Setter de la propriété cCode. Persistence dans la base faite sur le setter.
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vhProc  as handle    no-undo.
        define variable vcValue as character no-undo.

        vhProc = outilHandle:connectMaGIModeleFromRealm("oerealm/magiTokenUtil.p", cPort).
        run set in vhProc(mtoken:JSessionId, pcCode, pcValeur, output vcValue).
        mtoken:cValeur = vcValue.

    end method.

    method public void deletePersistentMagitoken():
        /*------------------------------------------------------------------------------
        Purpose: Suppression d'un objet magiToken et de sa persistence.
        Notes  : Il faut d'abord instancier l'objet pour pouvoir le supprimer.
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle no-undo.

        vhProc = outilHandle:connectMaGIModeleFromRealm("oerealm/magiTokenUtil.p", cPort).
        run deletePersistentMagitoken in vhProc(mtoken:JSessionId).
        delete object this-object.
 
    end method.

    method public static void getUniqueInstance(pcJSessionId as character):
        /*------------------------------------------------------------------------------
        Purpose: Récupère l'instance de l'objet
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhProc          as handle no-undo.
        define variable voSessionToken  as class oerealm.token.
        define variable voSessionLogger as class outils.logHandler.

        if not valid-object(oerealm.beMagiToken:mtoken)
        or oerealm.beMagiToken:mtoken:JsessionId <> pcJSessionId
        then do:
            vhProc = outilHandle:connectMaGIModele("oerealm/magiTokenUtil.p").
            run getToken in vhProc (output voSessionToken).
            if not valid-object(voSessionToken) then return.

            oerealm.beMagiToken:mToken = voSessionToken.
            run getLogger in vhProc (output voSessionLogger).
            if not valid-object(voSessionLogger) then return.

            assign
                voSessionLogger:cInstanceType = 'Controller'
                oerealm.beMagiToken:mLogger = voSessionLogger
            no-error.
        end.

    end method.

    destructor public beMagiToken():
        /*------------------------------------------------------------------------------
        Purpose: Suppression d'un objet magiToken.
        Notes  : Attention, la persistence dans la base est gardée?
                 Utiliser la methode deletePersistentMagitoken 
        ------------------------------------------------------------------------------*/
        outilHandle:deleteHandle().

    end destructor.

end class.
