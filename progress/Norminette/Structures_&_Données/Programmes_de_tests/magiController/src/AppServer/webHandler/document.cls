  /*------------------------------------------------------------------------
    File        : document
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : kantena
    Created     : Tue Jun 26 14:43:01 CEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Web.WebResponseWriter.
using OpenEdge.Net.HTTP.StatusCodeEnum.
using OpenEdge.Net.HTTP.IHttpResponse.
using OpenEdge.Net.HTTP.ContentDispositionHeader.
using OpenEdge.Web.WebResponseWriter.
using OpenEdge.Web.WebHandler.
using bureautique.beBureautique.
block-level on error undo, throw.

class webHandler.document inherits WebHandler: 

    {preprocesseur/type2fichier.i}
    /*------------------------------------------------------------------------------
            Purpose: Handler for unsupported methods. The request being serviced and
            		 an optional status code is returned. A zero or null value means 
            		 this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
	method override protected integer HandleNotAllowedMethod( input poRequest as OpenEdge.Web.IWebRequest ):
	
		/* Throwing an error from this method results in a 500/Internal Server Error response. 
        The web handler will attempt to log this exception.
 	    
        See the HandleGet method's comments on choosing a value to return from this method. */
        	
		undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
	end method.


	/*------------------------------------------------------------------------------
            Purpose: Handler for unknown methods. The request being serviced and an 
                     optional status code is returned. A zero or null value means 
                     this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
	method override protected integer HandleNotImplemented( input poRequest as OpenEdge.Web.IWebRequest ):

		/* Throwing an error from this method results in a 500/Internal Server Error response. 
        The web handler will attempt to log this exception.

        See the HandleGet method's comments on choosing a value to return from this method. */	
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
   	end method.

    /*------------------------------------------------------------------------------
            Purpose: Default handler for the HTTP GET method. The request being 
                     serviced and an optional status code is returned. A zero or 
                     null value means this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
 	method override protected integer HandleGet( input poRequest as OpenEdge.Web.IWebRequest ):
    
        define variable voResponse       as IHttpResponse            no-undo.
        define variable voHeader         as ContentDispositionHeader no-undo.
        define variable voResponseWriter as WebResponseWriter        no-undo.
        define variable voBodyBinary     as OpenEdge.Core.Memptr     no-undo.
        define variable voBodyString     as OpenEdge.Core.String     no-undo.
        define variable vcNomDocument    as character                no-undo.
        define variable vcData           as longchar                 no-undo.
        define variable vcExtension      as character                no-undo.
        define variable beBureautique    as class beBureautique      no-undo.
        
        /* The WebResponse body is a wrapper around an entire HTTP response message.
           It contains a status code and reason; headers; cookies and a message body.
           
           API-level doc for this and related classes can be found at
           https://documentation.progress.com/output/oehttpclient/      */
        assign
            voResponse            = new OpenEdge.Web.WebResponse()
            voHeader              = new OpenEdge.Net.HTTP.ContentDispositionHeader("Content-Disposition")
            voResponse:StatusCode = integer(StatusCodeEnum:OK)
            vcExtension           = poRequest:getpathparameter ("extension")
        .

        beBureautique = new beBureautique().
        beBureautique:getDocument(integer(poRequest:getpathparameter ("id")),
                                          poRequest:getpathparameter ("extension"),
                                          output vcNomDocument,
                                          output vcData).
        if length(vcData) > 0 and lookup(vcExtension, substitute('&1,&2', {&TYPEFICHIER-pdf},{&TYPEFICHIER-docx})) > 0 
        then do:
            case vcExtension:
                when {&TYPEFICHIER-pdf}  then voResponse:ContentType = substitute('application/&1', {&TYPEFICHIER-pdf}).
                when {&TYPEFICHIER-docx} then voResponse:ContentType = substitute('application/&1', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document').
            end case.
            voHeader:SetParameterValue('filename', substitute('&1', vcNomDocument)).
            voResponse:SetHeader(voHeader). 
            assign
                voBodyBinary = new OpenEdge.Core.Memptr(base64-decode(vcData))
                voResponse:Entity        = voBodyBinary
                voResponse:ContentLength = voBodyBinary:Size
            .
//            delete object voBodyBinary no-error.
        end.
        else do:
            assign
                voBodyString = new OpenEdge.Core.String("KO")
                voResponse:Entity       = voBodyString

                /* HTTP messages require a content type */
                voResponse:ContentType   = 'application/json':u

                /* ContentLength is good too */
                voResponse:ContentLength = voBodyString:Size
            .
//            delete object voBodyString no-error.
        end.
        
        /* The WebResponseWriter ensures that the status line and
           all headers are writted out before the message body/entity. */
        assign voResponseWriter = new WebResponseWriter(voResponse).
        voResponseWriter:Open().

        /* Finish writing the response message */
        voResponseWriter:Close().
//        delete object voResponseWriter no-error.
        /* A response of 0 means that this handler will build the entire response;
           a non-zero value is mapped to a static handler in the webapp's /static/error folder.
           The mappings are maintained in the webapps's WEB-INF/web.xml 
           A predefined set of HTTP status codes is provided in the OpenEdge.Net.HTTP.StatusCodeEnum 
           enumeration */
        return 0.
        
    end method.

end class.