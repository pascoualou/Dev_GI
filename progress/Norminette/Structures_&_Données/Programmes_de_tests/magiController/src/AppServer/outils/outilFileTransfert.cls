/*------------------------------------------------------------------------
File        : outilFileTransfert.cls
Purpose     :
Author(s)   : 2014/10/15 - Progres; 2016/05/23 - kantena
Notes       :
derniere revue: 2018/05/23 - phm: OK
----------------------------------------------------------------------*/

using OpenEdge.Net.MultipartEntity.
using oerealm.beMagiToken.

block-level on error undo, throw.

@program FILE(name="PDFHandler.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
class outils.outilFileTransfert:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ----------------------------------------------------------------------*/
    {outils/include/pieceJointe.i}
    {application/include/error.i}

    define variable goEntity as class MultipartEntity no-undo.
    define temp-table ttFile no-undo
        field cFilename          as character
        field clbPayload         as clob
        field cLibelleTraitement as character
        field iNumeroTraitement  as integer.

    constructor public outilFileTransfert():
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ----------------------------------------------------------------------*/
        goEntity = new MultipartEntity().
    end constructor.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getFile(pcFileName as character, output table ttFile ):
        /*------------------------------------------------------------------------------
        Purpose: paramètre REPGI dans magiToken
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcFile       as longchar  no-undo.
        define variable vmFile       as memptr    no-undo.
        define variable vcFileName   as character no-undo.
        define variable vcRepertoire as character no-undo.

        empty temp-table ttFile.
        if pcFileName = ? or pcFileName = '' then return.

        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
        assign
            vcRepertoire = oerealm.beMagiToken:get('REPGI')
            vcFileName   = replace(pcFileName, "%20", " ")
            pcFileName   = substitute('&1/&2', vcRepertoire, vcFileName)
        .
        copy-lob from file pcFileName to vmFile.
        create ttFile.
        assign
            vcFile            = base64-encode(vmFile)
            ttFile.cFilename  = vcFileName
            ttFile.clbPayload = vcFile
        .
        return.

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getFileList(pcURI as character, output table ttPieceJointe):
        /*------------------------------------------------------------------------------
        Purpose: paramètre REPGI dans magiToken
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcFile       as character no-undo extent 3.
        define variable viOrder      as integer   no-undo.
        define variable vcRepertoire as character no-undo.
        define variable vcReference  as character no-undo.

        empty temp-table ttPieceJointe.
        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
        assign
            vcRepertoire = beMagiToken:get('REPGI')
            vcReference  = beMagiToken:mToken:cRefPrincipale
        .
        if vcRepertoire > "" and vcReference > "" and pcURI > "" 
        then assign  
            vcRepertoire  = substitute('&1/&2/&3', vcRepertoire, vcReference, pcURI)
            file-info:file-name = vcRepertoire
        .
        if file-info:full-pathname = ? then return.

        input from os-dir(file-info:full-pathname).
        repeat:
            import vcFile.
            if vcFile[3] = "D" or num-entries(vcFile[1], ".") < 2 then next.
            if lookup(entry(num-entries(vcFile[1], "."), vcFile[1], "."), "jpg,jpeg,gif,png,pdf,doc,docx,xls,xlsx,txt") = 0
            then next.   // si type de fichiers non géré, on sort.

            create ttPieceJointe.
            assign
                viOrder                  = viOrder + 1
                ttPieceJointe.iOrder     = viOrder
                ttPieceJointe.nomFichier = vcFile[1]
                ttPieceJointe.urlFichier = substitute('&1/&2/&3', vcRepertoire, if pcURI = ? then '' else pcURI, replace(vcFile[1], " ", "%20"))
            .
        end.
        input close.
        return.

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    method public void postFile (table ttFile):
        /*------------------------------------------------------------------------------
        Purpose: paramètre REPGI dans magiToken
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vmBuffer          as memptr    no-undo.
        define variable vcBuffer          as longchar  no-undo.
        define variable vcRepertoireBase  as character no-undo.
        define variable vcRepertoireFinal as character no-undo.
        define variable vcReference       as character no-undo.

        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
        assign
            vcRepertoireBase = beMagiToken:get('REPGI')
            vcReference      = beMagiToken:mToken:cRefPrincipale
        .
        if vcRepertoireBase > "" and vcReference > ""
        then vcRepertoireBase  = substitute('&1/&2', vcRepertoireBase, vcReference).
        for each ttFile:
            assign 
                vcRepertoireFinal = substitute('&1/&2/&3', vcRepertoireBase, ttFile.cLibelleTraitement, ttFile.iNumeroTraitement)
                file-info:file-name = vcRepertoireFinal
            .
            if search(file-info:full-pathname) = ? then os-create-dir value(vcRepertoireFinal).
            if vcRepertoireFinal > "" and ttFile.cFilename > ""
            then do:
                copy-lob from ttFile.clbPayload to vcBuffer.
                vmBuffer = base64-decode(vcBuffer).
                copy-lob from vmBuffer to file substitute('&1/&2', vcRepertoireFinal , ttFile.cFilename).
                set-size(vmBuffer) = 0.
                delete ttFile.
            end.
        end.
        return.

    end method.

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void deleteFile(pcFile as character, output table ttPieceJointe):
        /*------------------------------------------------------------------------------
        Purpose: paramètre REPGI dans magiToken
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcRepertoire           as character no-undo.
        define variable vcCheminCompletFichier as character no-undo.
        define variable vcReference            as character no-undo.

        beMagiToken:getUniqueInstance(session:current-request-info:ClientContextId).
        if pcFile > "" then do:
            assign
                vcRepertoire = beMagiToken:get('REPGI')
                vcReference  = beMagiToken:mToken:cRefPrincipale
            .
            if vcRepertoire > "" and vcReference > "" then do:
                assign
                    vcRepertoire           = substitute('&1/&2', vcRepertoire, vcReference) /*  REPGI + REF_CLIENT */
                    vcCheminCompletFichier = substitute('&1/&2', vcRepertoire, pcFile)      /* REPGI + REF_CLIENT + TYPE_TRAITEMENT + NUMERO TRAITEMENT + NOM_FICHIER */        
                .
                if vcCheminCompletFichier > "" then os-delete value(vcCheminCompletFichier).
            end.
        end.
    end method.

end class.
