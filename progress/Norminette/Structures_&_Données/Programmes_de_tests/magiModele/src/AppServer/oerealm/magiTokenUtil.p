/*------------------------------------------------------------------------
File        : magiTokenUtil.p
Purpose     :
Description :
Author(s)   : kantena - 2016/05/09
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure constructeur:
    /*------------------------------------------------------------------------------
    Purpose: persistence dans la base d'un objet magiToken.
    Notes: service utilisé par HybridRealm.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcJSessionId as character no-undo.
    define input  parameter piUserID     as integer   no-undo.
    define output parameter pdtHorodate  as datetime  no-undo.
    define output parameter pcValeur     as character no-undo.
    define output parameter pcUser       as character no-undo.

message "magiTokenUtil constructeur - JSessionID " pcJSessionId.

    magiToken:createMagiToken(pcJSessionId, piUserID).
    assign
        pdtHorodate   = magiToken:mToken:horodate
        pcValeur      = magiToken:mToken:cValeur
        pcUser        = magiToken:mToken:cUser
    .
end procedure.
/*
procedure getUniqueInstance:
/*------------------------------------------------------------------------------
Purpose:
Notes  :
------------------------------------------------------------------------------*/
define input  parameter pcJSessionId as character no-undo.
define output parameter mToken       as class oerealm.token       no-undo.
define output parameter mError       as class outils.errorHandler no-undo.
define output parameter mLogger      as class outils.logHandler   no-undo.


message "pcJSessionId: " pcJSessionId.

    magiToken:getUniqueInstance(pcJSessionId).
    assign
        mToken  = magiToken:mToken
        mError  = magiToken:mError
        mLogger = magiToken:mLogger
    .

end procedure.
*/
procedure getToken:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beMagiToken.cls
    ------------------------------------------------------------------------------*/
    define output parameter poToken as class token no-undo.

    if valid-object(mToken) then poToken = mToken.
    return.

end procedure.

procedure getLogger:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beMagiToken.cls
    ------------------------------------------------------------------------------*/
    define output parameter poLogger as class logHandler no-undo.

    if valid-object(mLogger) then poLogger = mLogger.
    return.

end procedure.

procedure getErrorHandler:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé nul par
    ------------------------------------------------------------------------------*/
    define output parameter poError as class errorHandler no-undo.

    if valid-object(mError) then poError = mError.
    return.

end procedure.

/*
procedure getTokenInstance:
/*------------------------------------------------------------------------------
Purpose:
Notes  :
------------------------------------------------------------------------------*/
define input  parameter pcJSessionId as character no-undo.
define output parameter pmToken as class oerealm.token no-undo.

message "pcJSessionId: " pcJSessionId.

    pmToken = magiToken:getUniqueInstance(pcJSessionId):mToken.

end procedure.
*/

procedure set:
    /*------------------------------------------------------------------------------
     Purpose: Persistence dans la base faite sur le set de la propriété cCode.
     Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  pcJSessionId as character no-undo.
    define input parameter  pcCode       as character no-undo.
    define input parameter  pcValeur     as character no-undo.
    define output parameter pcValue      as character no-undo.

    magiToken:getUniqueInstance(pcJSessionId).

message "magiTokenUtil - pcJSessionId / set cCode / cValeur / valid-object(mToken)" pcJSessionId "/" pcCode "/" pcValeur.

    magiToken:setValeur(pcJSessionId, pcCode, pcValeur).
    pcValue = magiToken:mToken:cValeur.

end procedure.

procedure deletePersistentMagitoken:
    /*------------------------------------------------------------------------------
    Purpose: Suppression de la persistence d'un objet magiToken.
    Notes  : service utilisé par beMagiToken.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcJSessionId as character no-undo.

    magiToken:deletePersistentMagitoken(pcJSessionId).

end procedure.

/* TODO : Voir possibilité d'utiliser la classe magiToken
procedure destroy:
/*------------------------------------------------------------------------------
 Purpose: Suppression d'un objet magiToken.
 Notes  : Attention, la persistence dans la base est gardée?
          Utiliser la methode deletePersistentMagitoken
------------------------------------------------------------------------------*/
    delete object magiTokenUtil.
    delete procedure this-procedure.

end procedure.
*/
