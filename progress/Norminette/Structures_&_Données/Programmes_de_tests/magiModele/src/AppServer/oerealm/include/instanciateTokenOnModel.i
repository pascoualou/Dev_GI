/*------------------------------------------------------------------------
File        : instanciateTokenOnModel.i
Purpose     : Toute procédure du modèle doit intégrer cet include
Author(s)   : kantena - 2016/07/22
Notes       : permet de récupérer tous les objets techniques.
              prise en compte d'un lancement en local (destroy et getTokenInstance).
------------------------------------------------------------------------*/

using outils.logHandler.
using outils.outils.
using outils.errorHandler.
using outils.collection.
using outils.outilFormatage.
using outils.outilTraduction.
using oerealm.token.
using oerealm.magiToken.

&GLOBAL-DEFINE oui    "00001"
&GLOBAL-DEFINE non    "00002"
&GLOBAL-DEFINE ouiNon "00001/00002"
&GLOBAL-DEFINE question    4
&GLOBAL-DEFINE erreur      3
&GLOBAL-DEFINE error       3
&GLOBAL-DEFINE warning     2
&GLOBAL-DEFINE info        1
&GLOBAL-DEFINE information 1

block-level on error undo, throw.

define variable mToken        as class token        no-undo.
define variable mError        as class errorHandler no-undo.
define variable mLogger       as class logHandler   no-undo.

procedure destroy:
/*------------------------------------------------------------------------------
Purpose:
Notes  :
------------------------------------------------------------------------------*/

    if this-procedure:remote
    then do:
        delete object mToken  no-error.
        delete object mError  no-error.
        delete object mLogger no-error.
    end.
    session:remove-super-procedure(this-procedure) no-error.
    delete procedure this-procedure.
    error-status:error = false no-error.    // reset error-status
    return.                                 // reset return-value

end procedure.

procedure getLocalToken:
    /*------------------------------------------------------------------------------
    Purpose: si un .p lance un .p persistent en local, récupère les handles techniques.
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter poToken  as class token        no-undo.
    define output parameter poError  as class errorHandler no-undo.
    define output parameter poLogger as class logHandler   no-undo.

    assign
        poToken  = mToken
        poError  = mError
        poLogger = mLogger
    .
end procedure.

procedure getTokenInstance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Met les objets techniques de MAGI à jour sur le singleton outilTraduction
    ------------------------------------------------------------------------------*/
    define input  parameter pcJSessionId  as character no-undo.

    if this-procedure:remote
    then do:
        magiToken:getUniqueInstance(pcJSessionId).
        assign
            mToken         = MagiToken:mToken
            mError         = MagiToken:mError
            mLogger        = MagiToken:mLogger
            mLogger:mtoken = mToken

            outilTraduction:mToken = mToken
            outilFormatage:mToken  = mToken

            outils:mLogger = mLogger
            outils:mError  = mError
        .
        if valid-object(mLogger) and valid-object(mLogger:mToken) then mLogger:mToken:iTraceLevel = 2.

        if not valid-object(mToken)
        then undo, throw new Progress.Lang.AppError("getTokenInstance: can't initialize token.").
        if not valid-object(mError)
        then undo, throw new Progress.Lang.AppError("getTokenInstance: can't initialize errorHandler.").
        if not valid-object(mLogger)
        then undo, throw new Progress.Lang.AppError("getTokenInstance: can't initialize loggerHandler.").

        mLogger:writeLog(0, substitute('SessionID = &1', pcJSessionId)).
    end.
    else run getLocalToken in this-procedure:instantiating-procedure(output mToken, output mError, output mLogger).

end procedure.

procedure getErrors:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter table-handle phttError.

    mError:getErrors(output table-handle phttError).

end procedure.

procedure getListeErreur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter table-handle phttListeErreur.

    mError:getListeErreur(output table-handle phttListeErreur).

end procedure.
