/*------------------------------------------------------------------------
File        : beLog.cls
Purpose     :
Author(s)   : kantena - 2016/10/19
Notes       :
derniere revue: 2018/05/23 - phm: OK
----------------------------------------------------------------------*/

@program FILE(name="beLog.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="beLog", URI="/beLog", schemaName="dsbeLog", schemaFile="").

using oerealm.beMagiToken.

block-level on error undo, throw.

class outils.beLog:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
	define temp-table ttLog no-undo
	    field iLigne     as integer
	    field timestamp  as character
	    field jSessionId as character
	    field cModele    as character
        field iLevel     as character
	    field cMessage   as character
    index primaire is unique primary iLigne.
    define dataset dsbeLog for ttLog.
    define stream entree.

    constructor public beLog():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    method public void ReadbeLog(pcfiltre as character, output dataset dsbeLog):
        /*------------------------------------------------------------------------------
        Purpose: Get one or more records, based on a filter string
        Notes:
        ------------------------------------------------------------------------------*/
        define variable voLogger     as class outils.logHandler no-undo.
        define variable vcJsessionID as character no-undo.
        define variable vcIdLogged   as character no-undo.
        define variable vcLigne      as character no-undo.
        define variable viEntries    as integer   no-undo.
        define variable viLigne      as integer   no-undo.

        vcJsessionID = session:current-request-info:ClientContextId.
        beMagiToken:getUniqueInstance(vcJsessionID).
        assign
            vcJsessionID = entry(1, vcJsessionID, '.')    // sur le log, on enlève le suffixe .controller
            voLogger     = beMagiToken:mLogger
        .
        voLogger:writeLog(0, substitute('fichier log: &1', voLogger:cLogFilename)).
        input stream entree from value(voLogger:cLogFilename).
        repeat:
            assign
                vcLigne    = ''
                vcIdLogged = ''
                viLigne    = viLigne + 1
            .
            import stream entree unformatted vcLigne.
            viEntries = num-entries(vcLigne, '-').
            if viEntries < 2 then next.

            vcIdLogged = entry(2, vcLigne, '-').
            if vcIdLogged <> vcJsessionID then next.

            create ttLog.
            assign
                ttLog.iLigne     = viLigne
                ttLog.timestamp  = entry(1, vcLigne, '-')
                ttLog.jSessionId = vcIdLogged
                ttLog.cModele    = entry(3, vcLigne, '-') when viEntries > 2
                ttLog.iLevel     = entry(4, vcLigne, '-') when viEntries > 3
                ttLog.cMessage   = entry(5, vcLigne, '-') when viEntries > 4
            .
        end.
        input stream entree close.
        delete object this-object. /* call destructor to delete all handles */
    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    method public void DeletebeLog(input-output dataset dsbeLog):
        /*------------------------------------------------------------------------------
        Purpose: Delete user log file
        Notes:
        ------------------------------------------------------------------------------*/
    end method.

end class.
