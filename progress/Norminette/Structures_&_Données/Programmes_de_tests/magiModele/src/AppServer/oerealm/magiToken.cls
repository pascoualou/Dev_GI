/*------------------------------------------------------------------------
File        : magiToken.cls
Purpose     :
Author(s)   : kantena - 2016/05/13
Notes       :
Tables      : wadb : magiToken
------------------------------------------------------------------------*/

using Progress.Lang.Object.
using oerealm.token.
using oerealm.magiToken.
using outils.errorHandler.
using outils.logHandler.

block-level on error undo, throw.

class oerealm.magiToken:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes  :
    ------------------------------------------------------------------------------*/
    define public static property mtoken  as class token        no-undo get. set.
    define public static property mError  as class errorHandler no-undo get. set.
    define public static property mLogger as class logHandler   no-undo get. set.

    define static variable ghProcUtil as handle  no-undo.
    /* Forward declare doubler() */
    function getCodeSociete     returns integer                                                                           in ghProcUtil.
    function getLangueReference returns integer (pcUser as character)                                                     in ghProcUtil.
    function getGestionnaire    returns logical (pcUser as character, output piGest as integer, output piColl as integer) in ghProcUtil.
    function getReferences      returns logical (output pcNoRefUse as character, output pcNoRefCop as character, output pcNoRefGer as character) in ghProcUtil.
    function getCodeUser        returns character(piUserID as integer)                                                    in ghProcUtil.
    function getDateCptaEnCours returns date(cTypeMandat as character)                                                    in ghProcUtil.
    function getDeviseReference returns character()                                                                       in ghProcUtil.

    method public static void createMagiToken (pcJSessionId as character, piUserID as integer):
        /*------------------------------------------------------------------------------
        Purpose: Création d'un objet magiToken et persistence dans la base.
        Notes  : On en profite pour effacer tous les enregistrements > 1 jours (86 400 000 ms)
        ------------------------------------------------------------------------------*/
        define variable vdtemp   as datetime  no-undo.
        define buffer magiToken for magiToken.

        run outils/ctrlUtilisateur.p persistent set ghProcUtil.
        find first magiToken no-lock
            where magiToken.jSessionId = pcJSessionId no-error.
        if not available magiToken
        then do:
            create magiToken.
            assign
                magiToken.jSessionId   = pcJSessionId
                magiToken.iUser        = piUserID
                magiToken.cUser        = getCodeUser(piUserID)
                magiToken.cValeur      = ''
                magiToken.iCodeSociete = getCodeSociete()
                magiToken.iCodeLangueReference = getLangueReference(magiToken.cUser)
                magiToken.iCodeLangueSession   = magiToken.iCodeLangueReference
                magiToken.horodate             = now
                magiToken.daDateFinRespGerance = getDateCptaEnCours("GERANCE")
                magiToken.daDateFinRespCopro   = getDateCptaEnCours("COPRO")
                magiToken.cDeviseReference     = getDeviseReference()
                magiToken.cDeviseSession       = magiToken.cDeviseReference
            .
            getReferences(output magiToken.cRefPrincipale, output magiToken.cRefCopro, output magiToken.cRefGerance).
            getGestionnaire(magiToken.cUser, output magiToken.iGestionnaire, output magiToken.iCollaborateur).
        end.
        assign
            mToken                      = new oerealm.token()
            mError                      = new outils.errorHandler()
            mLogger                     = new outils.logHandler()
            mToken:horodate             = magiToken.horodate
            mToken:cValeur              = magiToken.cValeur
            mToken:cItemSep             = chr(2)
            mToken:cCodeSep             = chr(3)
            mToken:JSessionId           = magiToken.JSessionId
            mToken:iUser                = magiToken.iUser
            mToken:cUser                = magiToken.cUser
            mToken:cRefPrincipale       = magiToken.cRefPrincipale
            mToken:cRefCopro            = magiToken.cRefCopro
            mToken:cRefGerance          = magiToken.cRefGerance
            mToken:iCodeSociete         = magiToken.iCodeSociete
            mToken:iGestionnaire        = magiToken.iGestionnaire
            mToken:iCollaborateur       = magiToken.iCollaborateur
            mToken:iCodeLangueSession   = magiToken.iCodeLangueSession
            mToken:iCodeLangueReference = magiToken.iCodeLangueReference
            mToken:lDebug               = magiToken.lDebug
            mToken:iTraceLevel          = magiToken.iTraceLevel
            mToken:daDateFinRespGerance = magiToken.daDateFinRespGerance
            mToken:daDateFinRespCopro   = magiToken.daDateFinRespCopro
            mToken:cDeviseReference     = magiToken.cDeviseReference
            mToken:cDeviseSession       = magiToken.cDeviseSession
            mLogger:cLogFilename        = substitute('&1&2.log', session:temp-directory, mToken:cUser)
            vdtemp                      = now - 86400000
        .
        for each magiToken exclusive-lock
            where magiToken.horodate < vdtemp:       /* plus vieux d'un jour */
            delete magiToken.
        end.
        delete object ghProcUtil no-error.
    end method.

    method public static void createMagiToken (pcJSessionId as character):
        /*------------------------------------------------------------------------------
        Purpose: Création d'un objet magiToken.
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer magiToken for magiToken.

        find first magiToken no-lock
            where magiToken.jSessionId = pcJSessionId no-error.
        if not available magiToken
        then undo, throw new Progress.Lang.AppError("Can't find magiToken", 550).

        assign
            mError                = new outils.errorHandler()
            mToken                = new oerealm.token()
            mLogger               = new outils.logHandler()
            mToken:horodate       = magiToken.horodate
            mToken:cValeur        = magiToken.cValeur
            mToken:cItemSep       = chr(2)
            mToken:cCodeSep       = chr(3)
            mToken:JSessionId     = pcJSessionId
            mToken:iUser          = magiToken.iUser
            mToken:cUser          = magiToken.cUser
            mToken:cRefPrincipale = magiToken.cRefPrincipale
            mToken:cRefCopro      = magiToken.cRefCopro
            mToken:cRefGerance    = magiToken.cRefGerance
            mToken:iCodeSociete   = magiToken.iCodeSociete
            mToken:iGestionnaire  = magiToken.iGestionnaire
            mToken:iCollaborateur = magiToken.iCollaborateur
            mToken:iCodeLangueSession   = magiToken.iCodeLangueSession
            mToken:iCodeLangueReference = magiToken.iCodeLangueReference
            mToken:lDebug               = magiToken.lDebug
            mToken:iTraceLevel          = magiToken.iTraceLevel
            mToken:daDateFinRespGerance = magiToken.daDateFinRespGerance
            mToken:daDateFinRespCopro   = magiToken.daDateFinRespCopro
            mToken:cDeviseReference     = magiToken.cDeviseReference
            mToken:cDeviseSession       = magiToken.cDeviseSession
            mLogger:cLogFilename        = substitute('&1&2.log', session:temp-directory, mToken:cUser)
        .
    end method.

    method public static void setValeur(pcJSessionId as character, pcCode as character, pcValeur as character):
        /*------------------------------------------------------------------------------
        Purpose: Persistence dans la base faite sur le set de la propriété cCode.
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable viI     as integer   no-undo.
        define variable viJ     as integer   no-undo.
        define variable viEntry as integer   no-undo.
        define variable vcEntry as character no-undo.

        define buffer magiToken for magiToken.

        find first magiToken exclusive-lock
            where magiToken.jSessionId = pcJSessionId no-wait no-error.
        if locked magiToken
        then undo, throw new Progress.Lang.AppError(substitute("magiToken '&1' verrouillé. Set '&2' impossible", pcJSessionId, pcCode), 550).
        if not available magiToken
        then undo, throw new Progress.Lang.AppError(substitute("magiToken '&1' n'existe pas. Set '&2' impossible", pcJSessionId, pcCode), 550).

        viJ = num-entries(magiToken.cValeur, mToken:cItemSep).
        do viI = 1 to viJ:
            vcEntry = entry(viI, magiToken.cValeur, mToken:cItemSep).
            if entry(1, vcEntry, mToken:cCodeSep) = pcCode then viEntry = viI.
        end.

        /* REPGI = répertoire de l'application MAGI
        if pcCode = 'repgi'
        then do:
            define variabme voRepertoireMagi as class parametrageRepertoireMagi no-undo.
            voRepertoireMagi = new parametrageRepertoireMagi().
            if voRepertoireMagi:isDbParameter /* si le paramètre est défini, on prend celui de la bdd */
            pcValeur = voRepertoireMagi:getRepertoireMagi().
            delete object voRepertoireMagi.
        end.
        
        */
        vcEntry = substitute("&1&2&3", pcCode, mToken:cCodeSep, pcValeur).
        if viEntry = 0
        then magiToken.cValeur = if magiToken.cValeur = '' or magiToken.cValeur = ?
                                   then vcEntry
                                   else substitute("&1&2&3", magiToken.cValeur, mToken:cItemSep, vcEntry).
        else entry(viEntry, magiToken.cValeur, mToken:cItemSep) = vcEntry.
        mToken:cValeur = magiToken.cValeur.
    end method.

    method public static void deletePersistentMagitoken(pcJSessionId as character):
        /*------------------------------------------------------------------------------
        Purpose: Suppression de la persistence d'un objet magiToken.
        Notes  :
        ------------------------------------------------------------------------------*/
        define buffer magiToken for magiToken.

        find first magiToken exclusive-lock
            where magiToken.jSessionId = pcJSessionId no-wait no-error.
        if locked magiToken
        then undo, throw new Progress.Lang.AppError(substitute("magiToken '&1' verrouillé. Suppression impossible", pcJSessionId), 550).
        if not available magiToken
        then undo, throw new Progress.Lang.AppError(substitute("magiToken '&1' n'existe pas. Suppression impossible", pcJSessionId), 550).
        delete magiToken.
    end method.

    method public static void getUniqueInstance(pcJSessionId as character):
        /*------------------------------------------------------------------------------
        Purpose: Récupère l'instance de l'objet
        Notes  :
        ------------------------------------------------------------------------------*/

        if not valid-object(magiToken:mtoken)
        or magiToken:mtoken:JsessionId <> pcJSessionId
        then magiToken:createMagiToken(pcJSessionId).
        return.
    end method.

    method public static void trace-magitoken(pctext as character):
        /*------------------------------------------------------------------------------
        Purpose: pour debug
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable voObject as object  no-undo.

        message 'DEBUG--------------: ' pctext.
        voObject = session:first-object.
        do while valid-object(voObject):
            message 'objet: ' voObject:tostring().
            voObject = voObject:next-sibling.
        end.
    end method.

end class.
