using OpenEdge.Net.HTTP.ClientBuilder.
using OpenEdge.Net.HTTP.Credentials.
using OpenEdge.Net.HTTP.IHttpClient.
using OpenEdge.Net.HTTP.IHttpRequest.
using OpenEdge.Net.HTTP.RequestBuilder.
using OpenEdge.Net.URI.
using OpenEdge.Net.HTTP.IHttpResponse.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.

using OpenEdge.Net.HTTP.IHttpClientLibrary.
using OpenEdge.Net.HTTP.Lib.ClientLibraryBuilder. 

class outils.httpClient use-widget-pool final:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public property moClient as class IHttpClient no-undo get. set.

    constructor public httpClient (  ):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes:
        ------------------------------------------------------------------------------*/
        define variable voLib as IHttpClientLibrary no-undo.

        assign
            voLib    = ClientLibraryBuilder:Build():sslVerifyHost(no):Library
            moClient = ClientBuilder:Build():UsingLibrary(voLib):Client
        .
    end constructor.

    method public jsonObject httpGET(poURI as class URI):
        /*------------------------------------------------------------------------------
        Purpose: Retribution de l'adresse via un service WEB
        Notes  :
        -------------------------------------------------------------------------------*/
        define variable voJson   as class JsonObject    no-undo.
        define variable voJsonA  as class JsonArray     no-undo.
        define variable voReq    as class IHttpRequest  no-undo.
        define variable voResp   as class IHttpResponse no-undo.

        assign
            voReq  = RequestBuilder:Get(poUri):Request
            voResp = moClient:Execute(voReq)
        .
        if type-of(voResp:Entity, JsonObject)
        then voJson = cast(voResp:Entity, JsonObject).
        else if type-of(voResp:Entity, JsonArray) 
        then do:
            assign 
                voJsonA = cast(voResp:Entity, JsonArray)
                voJson  = new JsonObject()
            .
            voJson:Add("1", voJsonA).
        end.
        return voJson.

        catch voError as Progress.Lang.Error:
            message 
                voError:GetMessage(1) skip(2)
                voError:CallStack
            view-as alert-box.
        end catch.
    end method.

end class.
