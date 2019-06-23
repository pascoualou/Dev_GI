/*------------------------------------------------------------------------
File        : logHandler.cls
Purpose     :
Author(s)   : kantena - 2016/10/13
Notes       :
    0: trace explicite fichier
    1: trace fichier des run on appServer
    2: trace 1 + run pro in
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

using oerealm.token.
using outils.outilHandle.

block-level on error undo, throw.

class outils.logHandler final serializable: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/error.i}
    define public property cInstanceType as character no-undo initial 'modele' get. set.
    define public property cLogFilename  as character no-undo get. set.
    define public property mtoken        as class oerealm.token no-undo get. set.
    define stream sortie.

    constructor public logHandler():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
    end constructor.

    destructor public logHandler():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
    end destructor.

    method public void writeLog(piNiveau as integer, cMessage as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : Si le niveau est inférieur au niveau actif, pas de log.
        ------------------------------------------------------------------------------*/
        define variable vcPrefixe     as character no-undo.
        define variable vhTable       as handle    no-undo.
        define variable vhBuffer      as handle    no-undo.
        define variable vhQuery       as handle    no-undo.
        define variable viNiveauActif as integer   no-undo.

        viNiveauActif = openLogFilename(piNiveau, output vcPrefixe).
        if viNiveauActif < 0 then return.

        put stream sortie unformatted cMessage skip.
        // Pour le niveau 9, on trace la liste des handles actifs de la session
        if viNiveauActif = 9 then do:  // cInstanceType <> 'modele'
            vhTable = outilHandle:traceListeHandle().
            if valid-handle(vhTable) and vhTable:has-records then do:
                vhBuffer = vhTable:default-buffer-handle.
                create query vhQuery.
                vhQuery:set-buffers(vhBuffer).
                vhQuery:query-prepare(substitute("FOR EACH &1", vhBuffer:name)).
                vhQuery:query-open().
                repeat:
                    vhQuery:get-next().
                    if vhQuery:query-off-end then leave.
                    put stream sortie unformatted vcPrefixe vhBuffer::cError skip.
                end.
                if vhQuery:is-open then vhQuery:query-close().
                delete object vhQuery no-error.
            end.
            delete object vhTable no-error.
        end.
        output stream sortie close.
        assign error-status:error = false no-error. /* reset error-status:error */

    end method.

    method public void writeLog(piNiveau as integer, phTable as handle):
        /*------------------------------------------------------------------------------
        Purpose: Sortie sur le log de la ttError (ou autre si champ cError)
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcPrefixe     as character no-undo.
        define variable vhBuffer      as handle    no-undo.
        define variable vhQuery       as handle    no-undo.
        define variable viNiveauActif as integer   no-undo.

        if valid-handle(phTable) and phTable:has-records then do:
            viNiveauActif = openLogFilename(piNiveau, output vcPrefixe).
            if viNiveauActif < 0 then return.

            vhBuffer = phTable:default-buffer-handle.
            create query vhQuery.
            vhQuery:set-buffers(vhBuffer).
            vhQuery:query-prepare(substitute("FOR EACH &1", vhBuffer:name)).
            vhQuery:query-open().
            repeat:
                vhQuery:get-next().
                if vhQuery:query-off-end then leave.
                put stream sortie unformatted vcPrefixe vhBuffer::cError skip.
            end.
            if vhQuery:is-open then vhQuery:query-close().
            delete object vhQuery no-error.
            output stream sortie close.
        end.
        delete object phTable no-error.
        assign error-status:error = false no-error. /* reset error-status:error */

    end method.

    method private integer openLogFilename(piNiveau as integer, output pcPrefixe as character):
    /*------------------------------------------------------------------------------
    Purpose: Ouverture du fichier log
    Notes  : Si le niveau est inférieur au niveau actif, pas de log.
    ------------------------------------------------------------------------------*/
        define variable vdtNow        as datetime  no-undo.
        define variable viNiveauActif as integer   no-undo.
        define variable vcJSessionId  as character no-undo.

        if valid-object(this-object:mToken) then do:
            if piNiveau > mToken:iTraceLevel then return -1.

            assign
                viNiveauActif = mToken:iTraceLevel
                vcJSessionId  = entry(1, mToken:JSessionId, '.')
                vcJSessionId  = substitute('&1...&2', substring(vcJSessionId, 1, 4), substring(vcJSessionId, length(vcJSessionId) - 4))
            .
        end.
        else assign
            viNiveauActif = 9
            vcJSessionId  = 'Appel Direct'
            this-object:cLogFilename = substitute('&1defaultMagiLog.log', session:temp-directory) when this-object:cLogFilename = '' or this-object:cLogFilename = ?  
        .
        // Si le log est plus vieux d'un jour, on le sauve pour en ouvrir un nouveau ?
        /* TODO: Enlever les commentaire ???
        file-info:file-name = this-object:cLogFilename.
        if file-info:file-type > '' and file-info:file-create-date <> today
        then do:
            // pas nécessaire de transformer les / en ~\
            os-copy value(this-object:cLogFilename) value(this-object:cLogFilename + '.' + string(today, '99999999')).
            output stream sortie to value(this-object:cLogFilename).  // pas d'append dans ce cas, il faut réinitialiser le fichier
        end.
        else
        */
        do on error undo, retry:
            if retry then do:
                message "ERROR OpenLogFileName " this-object:cLogFilename.
                return -1.
            end.
            output stream sortie to value(this-object:cLogFilename) append.
        end.
        assign
            vdtNow     = now       // need variable to get right datatype for string() !!!
            pcPrefixe = substitute('&1-&2 - &3-&4 - ', string(vdtNow), vcJSessionId, string(cInstanceType = 'modele', 'MODL/CTRL'), viNiveauActif)
        .
        put stream sortie unformatted pcPrefixe.
        if num-entries(program-name(2), chr(32)) > 1
        then put stream sortie unformatted entry(2, program-name(2), chr(32)) '(' entry(1, program-name(2), chr(32)) '): '.
        else put stream sortie unformatted program-name(2) ': '.
        return viNiveauActif.

    end method.

end class.
