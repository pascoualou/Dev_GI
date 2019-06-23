/*------------------------------------------------------------------------
File        : lancementProgramme.i
Purpose     : fonctions pour gerer le lancement des programmes
Author(s)   : GGA - 2018/03/07
Notes       : 
----------------------------------------------------------------------*/

function lancementPgm return handle private(pcProgramme as character, poCollectionHandlePgm as class collection):
    /*------------------------------------------------------------------------------
    Purpose: lancement en persistant de programme (si programme deja lance, juste retour de l'handle du programme)  
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    vhProc = poCollectionHandlePgm:getHandle(pcProgramme).
    if not valid-handle(vhProc) then do:
        run value(pcProgramme) persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        poCollectionHandlePgm:set(pcProgramme, vhProc) no-error.
    end.
    return vhProc.
end function.

function suppressionPgmPersistent return logical private(poCollectionHandlePgm as class collection):
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les programmes lancés en persistant dans les procedure de delete 
    Notes  : cette fonction n'est utilise que sur les programmes de plus haut niveau d'un traitement de suppression
    ------------------------------------------------------------------------------*/
    define variable vi           as integer   no-undo.
    define variable vcVariables  as character no-undo.
    define variable vhProcHandle as handle    no-undo.

    vcVariables = poCollectionHandlePgm:getShortMessage("HANDLE").
    do vi = 1 to num-entries(vcVariables, chr(13)):
        vhProcHandle = handle(entry(2, entry(vi, vcVariables, chr(13)), ":")).
        if valid-handle(vhProcHandle) then run destroy in vhProcHandle no-error.
    end.
    assign vi = vi no-error.  // reset error-status
    return true.
end function.
