/*------------------------------------------------------------------------
File        : critere2Recherche.p
Purpose     :
Author(s)   : kantena - 2017/01/23
Notes       :
Tables      : BASE wadb : magiPreference
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure getPreferenceJson:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beCritere2Recherche.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcType    as character no-undo.
    define input  parameter pcCritere as character no-undo.
    define output parameter pcJson    as longchar  no-undo initial "~{~}".

    define variable vcUser      as character no-undo.
    define variable vcReference as character no-undo.
    define buffer magiPreference for magiPreference.

    assign
        vcUser      = if mtoken:cUser > "" then mtoken:cUser else "default"
        vcReference = fill("0", 5 - length(mtoken:cRefPrincipale, 'character')) + mtoken:cRefPrincipale
    .
    find first magiPreference no-lock
        where magiPreference.cType          = pcType      // R = recherche; S = Synthese
          and magiPreference.cSousType      = pcCritere
          and magiPreference.cRefPrincipale = vcReference
          and magiPreference.cUser          = vcUser
          and magiPreference.jSessionId     = entry(1, mtoken:JSessionId, '.') no-error.
    if not available magiPreference
    then find first magiPreference no-lock
        where magiPreference.cType          = pcType      // R = recherche; S = Synthese
          and magiPreference.cSousType      = pcCritere
          and magiPreference.cRefPrincipale = vcReference
          and magiPreference.cUser          = vcUser
          and magiPreference.jSessionId     = '' no-error.
    if available magiPreference 
    and length(magiPreference.cJson, "character") > 2 // au minimum "{}" 
    then pcJson = magiPreference.cJson.

end procedure.

procedure setPreferenceJson:
    /*------------------------------------------------------------------------------
    Purpose: création d'un enregistrement magiPreference pour la session JsessionId ou toute session
    Notes  : service utilisé par beCritere2Recherche.cls
             On en profite pour effacer tous les enregistrements > 1 jours (86 400 000 ms)
             plSession: true=enregistrement user/session, false=toutes sessions
    ------------------------------------------------------------------------------*/
    define input        parameter pcType    as character no-undo.
    define input        parameter plSession as logical   no-undo.    
    define input        parameter pcCritere as character no-undo.
    define input-output parameter pcJson    as longchar  no-undo.

    define variable vdtemp      as datetime  no-undo.
    define variable vcUser      as character no-undo.
    define variable vcReference as character no-undo.
    define variable vcSession   as character no-undo.
    define buffer magiPreference for magiPreference.

    do transaction:
        assign
            vcUser      = if mtoken:cUser > "" then mtoken:cUser else "default"
            vcReference = fill("0", 5 - length(mtoken:cRefPrincipale, 'character')) + mtoken:cRefPrincipale
            vcSession   = if plSession then entry(1, mtoken:JSessionId, '.') else ''
        .
        find first magiPreference exclusive-lock
            where magiPreference.cType          = pcType                     // R = recherche; S = Synthese
              and magiPreference.cSousType      = pcCritere
              and magiPreference.cRefPrincipale = vcReference
              and magiPreference.cUser          = vcUser
              and magiPreference.jSessionId     = vcSession no-error.
        if not available magiPreference
        then do:
            create magiPreference.
            assign
                magiPreference.cType          = pcType                       // R = recherche; S = Synthese
                magiPreference.cSousType      = pcCritere
                magiPreference.cRefPrincipale = vcReference
                magiPreference.cUser          = vcUser
                magiPreference.jSessionId     = vcSession
            .
        end.
        assign
            magiPreference.cJson    = if pcJson > "" then pcJson else "~{~}"
            magiPreference.horodate = now
            vdtemp                  = now - 86400000    // 24 * 60 * 60 * 1000
        .
        for each magiPreference exclusive-lock
            where magiPreference.horodate < vdtemp       /* plus vieux d'un jour */
              and magiPreference.jSessionId > '':
            delete magiPreference.
        end.
    end.

end procedure.
