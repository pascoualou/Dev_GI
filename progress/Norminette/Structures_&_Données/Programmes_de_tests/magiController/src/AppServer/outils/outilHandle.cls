/*------------------------------------------------------------------------
File        : outilHandle.cls
Purpose     : classe singleton de manipulation de handles 
Author(s)   : kantena - 2016/03/23
Notes       : Lance le singleton de gestion des transaction, mais ne démarre pas la transaction.
derniere revue: 2018/05/23 - phm: OK
----------------------------------------------------------------------*/

using Progress.Lang.Object.
using outils.logHandler.
using oerealm.beMagiToken.

block-level on error undo, throw.

class outils.outilHandle use-widget-pool final serializable: 
    /*------------------------------------------------------------------------
    Purpose : 
    Notes   :
    ------------------------------------------------------------------------*/
    {application/include/error.i &classProp=static}
    define public static property hTransactionManager as handle no-undo public get. set.
    define public static property hServer             as handle no-undo public get. set.

    method public static handle connectMaGIModele (pcProcName as character):
        /*------------------------------------------------------------------------------
        purpose: Démarrage d'un programme singleton persistant sur magiModele.
        Notes  : un run singleton pour ne pas changer d'agent! (un run persistent change d'agent !!!).
        ------------------------------------------------------------------------------*/
        define variable vhProc as handle    no-undo.
        define variable vcPort as character no-undo.
        define variable vcHost as character no-undo.
        define variable vhCPIn as handle    no-undo.

        vhCPIn = session:current-request-info:GetClientPrincipal().
        if not valid-handle(vhCPIn)
        then undo, throw new Progress.Lang.AppError("erreur client principal inexistant.", 8).

        if not valid-handle(hServer) or not hServer:connected()
        then do:
            vcPort = vhCPIn:get-property("MaGiRefId").
            if vcPort = ? then vcPort = ''.
            if num-entries(vcPort, ":") < 2 or entry(1, vcPort, ":") <> "MaGIModelePort"
            then undo, throw new Progress.Lang.AppError("erreur port modèle MaGI :" + vcPort, 8).

            if num-entries(vcPort, ":") = 2
            then assign    // si de la forme MaGIModelePort:8810
                vcHost = 'localhost'
                vcPort = entry(2, vcPort, ':')
            .
            else assign    // si de la forme MaGIModelePort:localhost:8810
                vcHost = entry(2, vcPort, ':')  // ne pas changer l'ordre de l'assign !!!
                vcPort = entry(3, vcPort, ':')
            .
            create server hServer.
            hServer:connect(substitute("-URL http://&1:&2/apsv -sessionModel session-managed", vcHost, vcPort)).
            run outils/transactionManager.p on server hServer persistent set hTransactionManager.
        end.
        run value(pcProcName) on server hServer persistent set vhProc.
        run getTokenInstance in vhProc(vhCPin:session-id).
        return vhProc.

    end method.

    method public static handle connectMaGIModeleFromRealm (pcProcName as character, pcPort as character):
        /*------------------------------------------------------------------------------
        purpose: Démarrage d'un programme persistant sur magiModele en donnat le port du magiModele.
        Notes  : Procédure lancée uniquement par beMagiToken.cls
        ------------------------------------------------------------------------------*/
        define variable vhServer as handle   no-undo.
        define variable vhProc   as handle   no-undo.

        if num-entries(pcPort, ':') = 1 then pcPort = 'localhost:' + pcPort.
        create server vhServer.
        vhServer:connect(substitute("-URL http://&1/apsv -sessionModel session-free", pcPort)).
        run value(pcProcName) persistent set vhProc on vhServer.
        return vhProc.

    end method.

    method public static handle traceListeHandle ():
        /*------------------------------------------------------------------------------
        purpose: Fonction retournant la liste des handles de la session
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable voObject as object  no-undo.
        define variable vhHandle as handle  no-undo.
        define variable vhProc   as handle  no-undo.

        empty temp-table ttError.
        createError('Liste des Handles de Session.').

        vhHandle = session:first-buffer.
        do while valid-handle(vhHandle):
            createError(substitute("-- &1: &2", vhHandle:type, vhHandle:name)).
            vhHandle = vhHandle:next-sibling.
        end.

        vhHandle = session:first-dataset.
        do while valid-handle(vhHandle):
            createError(substitute("-- &1: &2", vhHandle:type, vhHandle:name)).
            vhHandle = vhHandle:next-sibling.
        end.

        vhHandle = session:first-data-source.
        do while valid-handle(vhHandle):
            createError(substitute("-- &1: &2", vhHandle:type, vhHandle:name)).
            vhHandle = vhHandle:next-sibling.
        end.

        vhHandle = session:first-query.
        do while valid-handle(vhHandle):
            createError(substitute("-- &1: &2", vhHandle:type, vhHandle:prepare-string)).
            vhHandle = vhHandle:next-sibling.
        end.

        voObject = session:first-object.
        do while valid-object(voObject):
            createError(substitute("-- &1: &2", voObject:getClass(), voObject:toString())).
            voObject = voObject:next-sibling.
        end.

        vhHandle = session:first-server.
        do while valid-handle(vhHandle):
            createError(substitute("-- &1: &2", vhHandle:type, vhHandle:name)).
            vhProc = vhHandle:first-procedure.
            do while valid-handle(vhProc):
                createError(substitute("---- &1: &2", vhProc:type, vhProc:name)).
                vhProc = vhProc:next-sibling.
            end.
            vhHandle = vhHandle:next-sibling.
        end.

        createError('FIN-- Handles de Session.').
        return temp-table ttError:handle.

    end method.

    method public static void deleteHandle():
        /*------------------------------------------------------------------------------
        purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        deleteHandle(0).
    end method.

    method public static void deleteHandle (iTrace as integer):
        /*------------------------------------------------------------------------------
        purpose: Fonction retournant la liste des handles de la session
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable mObject   as object no-undo.
        define variable mObject2  as object no-undo.
        define variable vhHandle  as handle no-undo.
        define variable vhHandle2 as handle no-undo.
        define variable vhProc    as handle no-undo.
        define variable vhProc2   as handle no-undo.

        empty temp-table ttError.
        if valid-handle(hTransactionManager) then run destroy in hTransactionManager no-error.

        if iTrace > 0 then do:
            beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
            traceListeHandle ().
            beMagiToken:mLogger:writeLog(iTrace, temp-table ttError:handle).
        end.

        vhHandle = session:first-buffer.
        do while valid-handle(vhHandle):
            vhHandle2 = vhHandle:next-sibling.
            delete object vhHandle no-error.
            vhHandle = vhHandle2.
        end.

        vhHandle = session:first-dataset.
        do while valid-handle(vhHandle):
            vhHandle2 = vhHandle:next-sibling.
            delete object vhHandle no-error.
            vhHandle = vhHandle2.
        end.

        vhHandle = session:first-data-source.
        do while valid-handle(vhHandle):
            vhHandle2 = vhHandle:next-sibling.
            delete object vhHandle no-error.
            vhHandle = vhHandle2.
        end.

        vhHandle = session:first-query.
        do while valid-handle(vhHandle):
            vhHandle2 = vhHandle:next-sibling.
            if vhHandle:is-open then vhHandle:query-close() no-error.  
            delete object vhHandle no-error.
            vhHandle = vhHandle2.
        end.

        mObject = session:first-object.
        do while valid-object(mObject):
            mObject2 = mObject:next-sibling.
            delete object mObject no-error.
            mObject = mObject2.
        end.

        vhHandle = session:first-server.
        do while valid-handle(vhHandle):
            vhHandle2 = vhHandle:next-sibling.
            vhProc = vhHandle:first-procedure.
            do while valid-handle(vhProc):
                vhProc2 = vhProc:next-sibling.
                run destroy in vhProc no-error.
                if valid-handle(vhProc) then delete object vhProc no-error.
                vhProc = vhProc2.
            end.
            if vhHandle:connected() then vhHandle:disconnect().
            delete object vhHandle no-error.
            vhHandle = vhHandle2.
        end.
        vhProc = vhProc no-error. /* reset error-status */
        return.

    end method.

    method private static void createError(pcMessage as character):
        /*------------------------------------------------------------------------------
        purpose: Fonction permettant de créer un record ttError
        Notes  :
        ------------------------------------------------------------------------------*/
        create ttError.
        assign
            ttError.horodate = now
            ttError.iType    = {&info}
            ttError.cError   = pcMessage
        .
    end method.

end class.
