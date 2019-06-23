/*------------------------------------------------------------------------
File        : HybridRealm
Purpose     : 
Description : Singleton class that implements IHybridRealm for use as
              a single point of authentication for OE Realm Clients
              viz. OEBPM, REST and Rollbase
Author(s)   : Progress 2015/07/23 / Kantena 2016/03/09 
Notes       : 
----------------------------------------------------------------------*/

using oerealm.Util.Properties.
using oerealm.beMagiToken.  
using outils.outilHandle.

routine-level on error undo, throw.

class oerealm.HybridRealm:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define private variable glValidateCP as logical   no-undo.
    define private variable glDebugMsg   as logical   no-undo.
    define private variable gcPassword   as character no-undo.
    define private variable gcRoleUser   as character no-undo.
    define private variable goSpaProps   as class Properties no-undo.
    define temp-table ttUser no-undo
        field cCode        as character
        field iNumeroTiers as integer
        field cPassword    as character
    .

    constructor public HybridRealm ( ):
        /*------------------------------------------------------------------------------
         Purpose: Default constructor
         Notes: Reads a property file names "spaservice.properties" to intialize:
         1. ValidateCP - If true, the OERealm methods will validate if the request came from
                         a trusted client by checking for existence of a sealed client-Principal(C-P)
                       - If false, no such C-P validation will not be performed.
                       - This serves as an additional layer of security.It is highly recommended
                         that this validation be turned on
                       - In order to turn on this additional security validation:
                         1. The Implementor of OE Realm will create a .cp file using
                         genspacp utility and distribute it to the trusted OERealm Clients.
                        --------------------------------------------------------------------
                        The syntax of genspacp is as below:
                        genspacp -password <text> [-user <text> -role <text> -domain <text> -file <text>]
                        --------------------------------------------------------------------
                         2. The .cp file will be sealed by the "password" field provided to the utility
         2. Password  -  The value will be used to validate the incoming C-P
                      -  It must match the value provided while generating .cp using genspacp utility
                      -  It is applicable only when validateCP is true
         3. Role      -  The value must match the role that the incoming C-P contains
                      -  It must match the value provided while generating .cp using genspacp utility
                      -  It is applicable only when validateCP is true
         4. DebugMsg  - If true, debug messages will be logged in server log file
        ------------------------------------------------------------------------------*/
        super ().
        assign
            goSpaProps   = new Properties("spaservice.properties")
            glValidateCP = goSpaProps:GetLogicalProperty("validateCP", false)
            glDebugMsg   = goSpaProps:GetLogicalProperty("DebugMsg", false)
        .
        if glValidateCP
        then assign
            gcPassword = goSpaProps:GetCharacterProperty("Password", "")
            gcRoleUser = goSpaProps:GetCharacterProperty("role", "SpaClient")
        .
    end constructor.
    
    method protected logical ValidateClient( ):
        /*------------------------------------------------------------------------------
        Purpose: Returns true if the C-P received in the request is valid, else returns false
        Notes: Uses "password" value configured in spaservice.properties to validate the C-P
        --------------------------------------------------------------------------------- */
        define variable vlResult as logical no-undo.
        define variable vhCP     as handle  no-undo.
        
        vhCP = session:current-request-info:GetClientPrincipal().
        if valid-handle(vhCP)
        then do:
            vlResult = vhCP:validate-seal(gcPassword).
            if vlResult and vhCP:roles <> gcRoleUser then vlResult = false.
        end.
        return vlResult.
    end method.

    method public character GetAttribute(piUserId as integer, pcAttrName as character):
        /*------------------------------------------------------------------------------
        Purpose: Returns the attribute value of a user
        Notes  : 
        ------------------------------------------------------------------------------*/
        return getAttribute(piUserId, pcAttrName, '').
    end method.

    method public character GetMaGIRef(pcMaGIRef as character, pcSessionId as character, piUserID as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcPort      as character no-undo.
        define variable vcRepGi     as character no-undo.
        define variable vcRepReseau as character no-undo.
        define variable vcRepDisque as character no-undo.
        define variable vcRepWord   as character no-undo.
        define variable vhProc      as handle    no-undo.
        define variable vcValeur    as character no-undo.
        define variable vhorodate   as datetime  no-undo.
        define variable vcUser      as character no-undo.
        
        assign
            vcPort                     = getModelePort(pcMaGIRef)
            beMagiToken:mToken         = new oerealm.token()
            beMagiToken:mLogger        = new outils.logHandler()
            beMagiToken:mLogger:mtoken = beMagiToken:mToken
            vhProc                     = outilHandle:connectMaGIModeleFromRealm("oerealm/magiTokenUtil.p", vcPort)
        .
        run constructeur in vhProc(pcSessionId, piUserID, output vhorodate, output vcValeur, output vcUser).
        assign
            beMagiToken:mToken:cItemSep   = chr(2)
            beMagiToken:mToken:cCodeSep   = chr(3)
            beMagiToken:mToken:JSessionId = pcSessionId
            beMagiToken:mToken:iUser      = piUserID
            beMagiToken:mToken:cUser      = vcUser
            beMagiToken:cPort             = vcPort
            vcRepGi                       = goSpaProps:GetCharacterProperty("REPGI", "c:~\gidev")
            vcRepReseau                   = goSpaProps:GetCharacterProperty("RESEAU", "")
            vcRepDisque                   = goSpaProps:GetCharacterProperty("DISQUE", "")
            vcRepWord                     = goSpaProps:GetCharacterProperty("REPWORD", "\MAGI\WORD\")
        .
        beMagiToken:set("REPGI",   vcRepGi).
        beMagiToken:set("RESEAU",  vcRepReseau).
        beMagiToken:set("DISQUE",  vcRepDisque).
        beMagiToken:set("REPWORD", vcRepWord).
        return "MaGIModelePort:" + vcPort.
    end method.

    method public character GetAttribute(piUserId as integer, pcAttrName as character, pcMaGIRef as character):
        /*------------------------------------------------------------------------------
         Purpose: Returns the attribute value of a user
         Notes  :
         INPUT : piUserId  - positive user number in a MaGIRef
                 cAttrName - String name for an attribute to be fetched 
                           - Refer to OERealmDefs for the attribute name that this sample supports
        ------------------------------------------------------------------------------*/
        case pcAttrName:
            when 'ATTR_ENABLED' then return "1".
            when 'ATTR_LOCKED'  then return "0".
            when 'ATTR_EXPIRED' then return "0".
            when 'ATTR_ROLES'   then return "MaGIModelePort:" + getModelePort(pcMaGIRef).
            otherwise return ?.
        end.
    end method.

    method public character extent GetAttributeNames(piUserId as integer):
        /*------------------------------------------------------------------------------
        Purpose: Returns all the attributes defined for a user as a comma separeted list
        Notes  : Pas utilisé dans MaGI
        INPUT  : piUserId - positive user number
        ------------------------------------------------------------------------------*/
        define variable vcRetour as character no-undo extent.
        return vcRetour.
    end method.

    method public character extent GetUserNames( ):
        /*------------------------------------------------------------------------------
        Purpose: Returns all the user names as character extent
        Notes  : Pas utilisé dans MaGI
        ------------------------------------------------------------------------------*/
        define variable vcRetour as character no-undo extent.
        return vcRetour.
    end method.

    method public character extent GetUserNamesByQuery(pcQueryString as character):
        /*------------------------------------------------------------------------------
        Purpose: Returns the fully qualified usernames a matching a query pattern
        Notes  : Pas utilisé dans MaGI
        INPUT  : pcQueryString - character value which against which the userid should be matched
        ------------------------------------------------------------------------------*/
        define variable vcRetour as character no-undo extent.
        return vcRetour.
    end method.

    method public character extent GetUserNamesByQuery(pcAttrName as character, pcAttrValue as character):
        /*------------------------------------------------------------------------------
        Purpose: Returns the fully qualified usernames whose attributes match 
        Notes  : Pas utilisé dans MaGI 
        INPUT : attrName  - character value representing the attribute name
                attrValue - character value representing the attribute value
        ------------------------------------------------------------------------------*/
        define variable vcRetour as character no-undo extent.
        return vcRetour.
    end method.

    method public logical RemoveAttribute(piUserId as integer, pcAttrName as character):
        /*------------------------------------------------------------------------------
        Purpose: Removes an attribute from User account based on unique user number
        Notes  : Pas utilisé dans MaGI
        INPUT : theUserId - positive user number
                attrName  - String representing the attribute name to be removed
                          - Refer to OERealmDefs for the attribute name that this sample supports
        ------------------------------------------------------------------------------*/
        return true.
    end method.

    method public logical SetAttribute(piUserId as integer, pcAttrName as character, pcAttrValue as character):
        /*------------------------------------------------------------------------------
        Purpose: Sets an attribute value for a user value
        Notes  : Pas utilisé dans MaGI
        INPUT : piUserId    - positive user number
                pcAttrName  - String representing the attribute name to be removed
                            - Refer to OERealmDefs for the attribute name that this sample supports
                pcAttrValue - value of an attribute
        ------------------------------------------------------------------------------*/
        return true.
    end method.

    method public logical SetAttribute(piUserId as integer, pcPassword as character):
        /*------------------------------------------------------------------------------
        Purpose: Sets an password for a given user
        Notes  : Pas utilisé dans MaGI 
        INPUT  : piUserId    - positive user number
                 pcPassword  - String value to be set as the password
        The incoming request must contain a C-P to perform this operation
        ------------------------------------------------------------------------------*/
        return true.
    end method.

    method public logical ValidatePassword(piUserId as integer, pcPassword as character):
        /*------------------------------------------------------------------------------
        Purpose: basic password validation for a given user
        Notes: 
        ------------------------------------------------------------------------------*/
        return ValidatePassword(piUserId, pcPassword, '').
    end method.

    method public logical ValidatePassword(piUserId as integer, pcPassword as character, pcMaGIRef as character):
        /*------------------------------------------------------------------------------
        Purpose: basic password validation for a given user on a MaGIModeleRef
        Notes  : creation du magiToken
        ------------------------------------------------------------------------------*/
        define variable vlRetour as logical   no-undo.
        define variable vhServer as handle    no-undo.
        define variable vhProc   as handle    no-undo.
        define variable vcPort   as character no-undo.

        empty temp-table ttUser.
        if glValidateCP and this-object:ValidateClient() = false
        then undo, throw new Progress.Lang.AppError("Unauthorized client").

        vcPort = getModelePort(pcMaGIRef).
        if vcPort = ? or vcPort = ''
        then undo, throw new Progress.Lang.AppError(substitute("MaGI référence (&1) non trouvée.", pcMaGIRef)).

        if num-entries(vcPort, ':') = 1 then vcPort = 'localhost:' + vcPort.
        create server vhServer.
        vhServer:connect(substitute("-URL http://&1/apsv -sessionModel session-free", vcPort)).
        run oerealm/utilisateur.p persistent set vhProc on vhServer.
        run getUserById in vhProc(piUserId, output table ttUser).
        run destroy in vhProc.
        vhServer:disconnect().
        delete object vhServer.
        find first ttUser
            where ttUser.iNumeroTiers = piUserId no-error.
        if not available ttUser then undo, throw new Progress.Lang.AppError("Invalid User Id").
        vlRetour = if ttUser.cCode = "ins"
                  then search("passe.exe") <> ?
                  else encode(pcPassword) = ttUser.cPassword.
        return vlRetour.
    end method.

    method public logical ValidatePassword(piUserId as integer, pcDigest as character, pcNonce as character, pcTimestamp as character):
        /*------------------------------------------------------------------------------
        Purpose: validate a password for a given user using digest
        Notes: 
        ------------------------------------------------------------------------------*/
        return ValidatePassword(piUserId, pcDigest, pcNonce, pcTimestamp, '').
    end method.

    method public logical ValidatePassword(piUserId as integer, pcDigest as character, pcNonce as character, pcTimestamp as character, pcMaGIRef as character):
        /*------------------------------------------------------------------------------
        Purpose: validate a password for a given user using digest
        Notes: to complete if used in MaGI
         Digest version of ValidatePassword requires that the passwords be stored in such a way
         that they can be retrieved as clear text.
         Since, the _password field of _User table stores password in one way encoded format
         from which the clear-text password cannot be retrieved, therefore, in this sample,
         we have encrypted the passwords using encpwd.p and stored in _User._U-misc2[1]. 
         The encrypted passwords stored thus in the _User._U-misc2[1] can be retrieved as
         clear-text using decpwd.p.
         Please note that this is just a sample implementation, you can store the passwords in
         any other way of your choice such that it can be recovered as a clear-text.
        ------------------------------------------------------------------------------*/
        return false.
    end method.

    method public integer ValidateUser(pcUserName as character):
        /*------------------------------------------------------------------------------
        Purpose: validate if the given user exists and if it exists returns the user number
        Notes: 
        ------------------------------------------------------------------------------*/
        return ValidateUser(pcUserName, "").
    end method.

    method public integer ValidateUser(pcUserName as character, pcMaGIRef as character):
        /*------------------------------------------------------------------------------
        Purpose: validate if the given user exists and if it exists returns the user number
        Notes: 
        INPUT : userName - Fully qualified user name
        Throws: 
           Progress.Lang.AppError("Unauthorized client", 1).
           Progress.Lang.AppError("User not found", 8).
           Progress.Lang.AppError("User number unknown for the user " + userName).
        ------------------------------------------------------------------------------*/
        define variable viRetour as integer   no-undo.
        define variable vhServer as handle    no-undo.
        define variable vhProc   as handle    no-undo.
        define variable vcPort   as character no-undo.

        empty temp-table ttUser.
        if glValidateCP and this-object:ValidateClient() = false
        then undo, throw new Progress.Lang.AppError("Unauthorized client", 1).

        vcPort = getModelePort(pcMaGIRef).
        if vcPort = ? or vcPort = ''
        then undo, throw new Progress.Lang.AppError(substitute("MaGI référence (&1) non trouvée.", pcMaGIRef)).

        if num-entries(vcPort, ':') = 1 then vcPort = 'localhost:' + vcPort.
        create server vhServer.
        vhServer:connect(substitute("-URL http://&1/apsv -sessionModel session-free", vcPort)).
        run oerealm/utilisateur.p persistent set vhProc on vhServer.
        run getUserByName in vhProc(pcUserName, output table ttUser).
        run destroy in vhProc.
        vhServer:disconnect().
        delete object vhServer.
        find first ttUser
            where ttUser.cCode = pcUserName no-error.
        if not available ttUser
        then undo, throw new Progress.Lang.AppError("User not found", 8).

        viRetour = ttUser.iNumeroTiers.
        if viRetour = ?
        then undo, throw new Progress.Lang.AppError("User number unknown for the user " + pcUserName).
        return viRetour.
    end method.

    method public character getModelePort(pcMaGIRef as character):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes: 
        ------------------------------------------------------------------------------*/
        return goSpaProps:GetCharacterProperty("MaGIRef" + pcMaGIRef, "localhost:8830").
    end method.

end class.
