/*------------------------------------------------------------------------
File        : outils.cls
Purpose     : classe singleton des outils généraux
Author(s)   : kantena - 2016/12/07
Notes       : kantena - 2017/05/12: 2 méthodes pour copie physique --> temp-table
derniere revue: 2018/05/18 - phm: OK
----------------------------------------------------------------------*/
&SCOPED-DEFINE excludedField rRowid,dtcsy,hecsy,cdcsy,dtmsy,hemsy,cdmsy,crud,dtTime*

using oerealm.magiToken.
using outils.outilTraduction.
{preprocesseur/niveauErreur.i}

block-level on error undo, throw.

class outils.outils use-widget-pool final:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public static property mError  as class outils.errorHandler no-undo get. set.
    define public static property mLogger as class outils.logHandler   no-undo get. set.

    method public static integer questionnaire (piQuestion as integer, table-handle phttError):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :  0 - jamais répondu
                  1 - repondu à une autre question
                  2 - répondu à la question à faux
                  3 - répondu oui à la question
        ------------------------------------------------------------------------------*/
        define variable vhBuffer as handle no-undo.

        vhBuffer = phttError:default-buffer-handle.
        vhBuffer:find-first(substitute('where ttError.iType = {&NIVEAU-questionRepondue} and ttError.iErrorId = &1', piQuestion)) no-error.
        if not vhBuffer:available then do:
            vhBuffer:find-first(substitute('where ttError.iType = {&NIVEAU-questionYesNo} and ttError.iErrorId = &1', piQuestion)) no-error.
            if not vhBuffer:available or vhBuffer::lYesNo = ? then do:
                mError:createError({&NIVEAU-questionYesNo}, piQuestion). // question ?
                return 0.
            end.
        end.
        mError:createErrorRepondue(piQuestion, logical(vhBuffer::lYesNo)).  // on recrée la réponse dans la ttError du errorHandler.
        if not vhBuffer::lYesNo then return 2.
        return 3.
    end method.

    method public static integer questionnaire (piQuestion as integer, pcQuestion as character, table-handle phttError):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :  0 - jamais répondu
                  1 - repondu à une autre question
                  2 - répondu à la question à faux
                  3 - répondu oui à la question
        ------------------------------------------------------------------------------*/
        define variable vhBuffer as handle no-undo.

        vhBuffer = phttError:default-buffer-handle.
        vhBuffer:find-first(substitute('where ttError.iType = {&NIVEAU-questionRepondue} and ttError.iErrorId = &1', piQuestion)) no-error.
        if not vhBuffer:available then do:
            vhBuffer:find-first(substitute('where ttError.iType = {&NIVEAU-questionYesNo} and ttError.iErrorId = &1', piQuestion)) no-error.
            if not vhBuffer:available or vhBuffer::lYesNo = ? then do:
                mError:createError({&NIVEAU-questionYesNo}, piQuestion, pcQuestion). // question ?
                return 0.
            end.
        end.
        mError:createErrorRepondue(piQuestion, logical(vhBuffer::lYesNo), pcQuestion).  // on recrée la réponse dans la ttError du errorHandler.
        if not vhBuffer::lYesNo then return 2.
        return 3.   // cas ?
    end method.

    method public static integer questionnaireGestion (piQuestion as integer, pcQuestion as character, table-handle phttError):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :  0 - jamais répondu
                  1 - repondu à une autre question
                  2 - répondu à la question à faux
                  3 - répondu oui à la question
        ------------------------------------------------------------------------------*/
        define variable vhBuffer as handle no-undo.

        vhBuffer = phttError:default-buffer-handle.
        vhBuffer:find-first(substitute('where ttError.iType = {&NIVEAU-questionRepondue} and ttError.iErrorId = &1', piQuestion)) no-error.
        if not vhBuffer:available then do:
            vhBuffer:find-first(substitute('where ttError.iType = {&NIVEAU-questionYesNo} and ttError.iErrorId = &1', piQuestion)) no-error.
            if not vhBuffer:available or vhBuffer::lYesNo = ? then do:
                mError:createErrorGestion({&NIVEAU-questionYesNo}, piQuestion, pcQuestion). // question ?
                return 0.
            end.
        end.
        mError:createErrorRepondueGestion(piQuestion, logical(vhBuffer::lYesNo), pcQuestion).  // on recrée la réponse dans la ttError du errorHandler.
        if not vhBuffer::lYesNo then return 2.
        return 3.   // cas ?
    end method.

    method public static character separateurRepertoire():
        /*------------------------------------------------------------------------------
        Purpose: Donne le separateur de repertoire selon l'OS
        UNIX -> /   sinon \
        ------------------------------------------------------------------------------*/
        return (if opsys = "UNIX" then "/" else "~\").
    end method.

    method public static logical isUpdated(ph as handle, pcCodeEntite as character, pcIdentifiant as character, pdtTimestamp as datetime):
        /*------------------------------------------------------------------------------
        Purpose: verifie si l'enregistrement ph est locked, not available, updated
        Notes: si la mise à jour peut être faite, renvoit false.
        ------------------------------------------------------------------------------*/
        define variable viError      as integer   no-undo.
        define variable vdtTimestamp as datetime  no-undo.
        define variable vcUser       as character no-undo.

        if not ph:available then do:    // enregistrement déjà supprimé (par un autre utilisateur?)
            viError = if ph:locked then 211652 else 211651.
            mLogger:writeLog(0, substitute(outilTraduction:getLibelle(viError), ph:name + pcCodeEntite + ' ' + pcIdentifiant)).
            mError:createError({&NIVEAU-error}, viError, substitute("&1 &2 &3", ph:name, pcCodeEntite, pcIdentifiant)).
            assign error-status:error = false no-error.    // sinon error-status = not available !!!
            return true.
        end.
        vdtTimestamp = datetime(ph::Dtmsy, ph::HeMsy) no-error.          // ces champs n'existent pas sur toutes les tables
        if error-status:error                                            // si champs inexistant erreur et on recherche alors sur champ compta damod ihmod
        then vdtTimestamp = datetime(ph::damod, ph::ihmod) no-error.
        if not error-status:error and pdtTimestamp <> vdtTimestamp       // une modification depuis la consultation
        then do:
            vcUser = ph::cdmsy no-error.
            if error-status:error then vcUser = ph::usridmod no-error.
            mLogger:writeLog(0, substitute(outilTraduction:getLibelle(211650), pcCodeEntite + pcIdentifiant, 'user: ' + vcUser)).
            mError:createError({&NIVEAU-error}, 211650, substitute('&5 &2&3&1user: &4', if session:cpinternal = 'iso8859-1' then chr(164) else chr(49828), pcCodeEntite, pcIdentifiant, vcUser, ph:name)).
            return true.
        end.
        return false.

    end method.

    method public static logical copyValidField(phBuffer as handle, phttBuffer as handle, pcCrud as character, pcUser as character):
        /*------------------------------------------------------------------------------
        Purpose: copy temp-table vers table physique
        Notes: mappage des champs par le label de la colonne de la temp-table vers la colonne de la table
        ------------------------------------------------------------------------------*/
        define variable vhField       as handle    no-undo.
        define variable vhttField     as handle    no-undo.
        define variable vi            as integer   no-undo.
        define variable viJ           as integer   no-undo.
        define variable vcConversion  as character no-undo.
        define variable vlChampDtmsy  as logical   no-undo.
        define variable vlChampDacrea as logical   no-undo.

boucle:
        do vi = 1 to phttBuffer:num-fields:
            assign
                vhField   = ? // A cause de la boucle et du assign no-error
                vhttField = phttBuffer:buffer-field(vi)
                vhField   = phBuffer:buffer-field(vhttField:label)
            no-error.
            if can-do('{&excludedField}', vhttField:name) or not valid-handle(vhField) then next boucle.

            vcConversion = if vhField:data-type = "character" and vhttField:data-type = "character"
                           then "C2C"
                           else if vhField:data-type = "date"      and vhttField:data-type = "date"
                           then "D2D"
                           else if vhField:data-type = "character" and vhttField:data-type = "logical"
                           then "C2L"
                           else if vhField:data-type = "character" and (vhttField:data-type = "integer" or vhttField:data-type = "int64")
                           then "C2I"
                           else "".
            if vhttField:extent > 0 and vhField:extent > 0
            then do viJ = 1 to minimum(vhttField:extent, vhField:extent):
                if vhttField:buffer-value(viJ) = ? then next.

                case vcConversion:
                    when "C2C" then vhField:buffer-value(viJ) = trim(vhttField:buffer-value(viJ)) no-error.
                    when "D2D" then vhField:buffer-value(viJ) = if vhttField:buffer-value(viJ) = 01/01/0001 then ? //mise en place de ce test pour remise a blanc de la date
                                                                else vhttField:buffer-value(viJ) no-error.
                    when "C2L" then do:
                        vhField:buffer-value(viJ) = trim(string(vhttField:buffer-value(viJ), vhttField:format)) no-error.
                        error-status:error = false.    // en cas d'erreur, on laisse la valeur par défaut.
                    end.
                    when "C2I" then do:
                        vhField:buffer-value(viJ) = trim(string(vhttField:buffer-value(viJ), vhttField:format)) no-error.
                        if error-status:error then vhField:buffer-value(viJ) = vhttField:buffer-value(viJ) no-error.
                    end.
                    otherwise vhField:buffer-value(viJ) = vhttField:buffer-value(viJ) no-error.
                end case.
            end.
            else if vhttField:extent = 0 and vhField:extent = 0
            then do:
                if vhttField:buffer-value() = ? then next boucle.

                case vcConversion:
                    when "C2C" then vhField:buffer-value() = trim(vhttField:buffer-value()) no-error.
                    when "D2D" then vhField:buffer-value() = if vhttField:buffer-value() = 01/01/0001 then ? //mise en place de ce test pour remise a blanc de la date
                                                             else vhttField:buffer-value() no-error.
                    when "C2L" then do:
                        vhField:buffer-value() = trim(string(vhttField:buffer-value(), vhttField:format)) no-error.
                        error-status:error = false.    // en cas d'erreur, on laisse la valeur par défaut.
                    end.
                    when "C2I" then do:
                        vhField:buffer-value() = trim(string(vhttField:buffer-value(), vhttField:format)) no-error.
                        if error-status:error then vhField:buffer-value() = vhttField:buffer-value() no-error.
                    end.
                    otherwise vhField:buffer-value() = vhttField:buffer-value() no-error.
                end case.
            end.
            else next boucle.

            if error-status:error then do:
                mError:createError({&NIVEAU-error}, error-status:get-message(1)).
                error-status:error = false no-error.
                undo, return false.
            end.
        end.
        if not valid-handle(phBuffer:table-handle)        // si table physique
        or pcCRUD > ""                                    // ou CRUD non nul, ne pas écraser les champs crud/rowid/dtTimeStamp de la table d'origine  
        then do:
            phttBuffer::rRowid      = phBuffer:rowid no-error.
            phttBuffer::CRUD        = "R" no-error.
            phttBuffer::dtTimeStamp = now no-error.
        end.
        vlChampDtmsy = valid-handle(phBuffer:buffer-field("dtmsy")) no-error. // Ajout ofa pour gérer les champs des tables de compta
        case pcCRUD:
            when 'C' then do:
                if vlChampDtmsy then do:
                    assign
                        phBuffer::dtcsy = today
                        phBuffer::hecsy = mtime
                        phBuffer::cdcsy = pcUser
                        phBuffer::dtmsy = phBuffer::dtcsy
                        phBuffer::hemsy = phBuffer::hecsy
                        phBuffer::cdmsy = pcUser
                        /*gga test maj cdmsy dans certain programme, cdmsy est renseigne avec plus d'infos que le user (mtoken:cUser + "|CHPTC") */
                        vhttField       = ?
                        vhttField       = phttBuffer:buffer-field("cdmsy")
                    no-error.
                    if valid-handle(vhttField) and vhttField:buffer-value <> ?
                    then phBuffer::cdmsy = vhttField:buffer-value no-error.
                    /*gga test maj cdcsy dans certain programme, cdcsy est renseigne avec plus d'infos que le user (mtoken:cUser + "|CHPTC") */
                    assign 
                        vhttField = ?
                        vhttField = phttBuffer:buffer-field("cdcsy")
                    no-error.
                    if valid-handle(vhttField) and vhttField:buffer-value <> ?
                    then phBuffer::cdcsy = vhttField:buffer-value no-error.
                end.
                else do:
                    vlChampDacrea = valid-handle(phBuffer:buffer-field("dacrea")) no-error. //Ajout ofa pour gérer les champs des tables de compta
                    if vlChampDacrea then assign
                        phBuffer::dacrea = today
                        phBuffer::ihcrea = mtime
                        phBuffer::usrid = pcUser
                    .
                end.
            end.
            when 'U' then do:
                if vlChampDtmsy then do:
                    assign
                        phBuffer::dtmsy = today
                        phBuffer::hemsy = mtime
                        phBuffer::cdmsy = pcUser
                        /*gga test maj cdmsy dans certain programme, cdmsy est renseigne avec plus d'infos que le user (mtoken:cUser + "|CHPTC") */
                        vhttField       = ?
                        vhttField       = phttBuffer:buffer-field("cdmsy")
                    no-error.
                    if valid-handle(vhttField) and vhttField:buffer-value <> ?
                    then phBuffer::cdmsy = vhttField:buffer-value no-error.
                    /*gga test maj cdcsy dans certain programme, cdcsy est renseigne avec plus d'infos que le user (mtoken:cUser + "|CHPTC") */
                    assign 
                        vhttField = ?
                        vhttField = phttBuffer:buffer-field("cdcsy")
                    no-error.
                    if valid-handle(vhttField) and vhttField:buffer-value <> ?
                    then phBuffer::cdcsy = vhttField:buffer-value no-error.
                end.
                else do:
                    assign 
                        vhttField = ?
                        vhttField = phttBuffer:buffer-field("damod")
                    no-error.
                    if valid-handle(vhttField) then assign
                        phBuffer::damod    = today
                        phBuffer::ihmod    = mtime
                        phBuffer::usridmod = pcUser
                    .
                end.
            end.
        end case.
        assign error-status:error = false.
        return true.

    end method.

    method public static logical copyValidLabeledField(phBuffer as handle, phttBuffer as handle, pcCrud as character, pcUser as character):
        /*------------------------------------------------------------------------------
        Purpose: copy temp-table vers table physique - TODO: obsolete, a supprimer
        Notes: mappage des champs par le label de la colonne de la temp-table vers la colonne de la table
        ------------------------------------------------------------------------------*/
        return copyValidField(phBuffer, phttBuffer, pcCrud, pcUser).

    end method.

    method public static logical copyValidField(phBuffer as handle, phttBuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose: copy table physique vers temp-table
        Notes: mappage des champs par la colonne de la table vers le label de la colonne de la temp-table
        ------------------------------------------------------------------------------*/
        define variable vhField      as handle    no-undo.
        define variable vhttField    as handle    no-undo.
        define variable vi           as integer   no-undo.
        define variable viJ          as integer   no-undo.
        define variable vcConversion as character no-undo.

boucle:
        do vi = 1 to phttBuffer:num-fields:
            assign
                vhField   = ?
                vhttField = phttBuffer:buffer-field(vi)
                vhField   = phBuffer:buffer-field(vhttField:label)
            no-error.
            if not valid-handle(vhField) then next boucle.

            vcConversion = if vhField:data-type = "logical" and vhttField:data-type = "character"
                           then "L2C"
                           else if (vhField:data-type = "integer" or vhField:data-type = "int64") and vhttField:data-type = "character"
                           then "I2C"
                           else if vhField:data-type = "character" and vhttField:data-type = "character"
                           then "C2C"
                           else if vhField:data-type = "character" and vhttField:data-type = "logical"
                           then "C2L"
                           else "".
            if vhttField:extent > 0 and vhField:extent > 0
            then do viJ = 1 to minimum(vhttField:extent, vhField:extent):
                case vcConversion:
                    when "C2C" then vhttField:buffer-value(viJ) = trim(vhField:buffer-value(viJ)) no-error.
                    when "L2C" then do:
                        vhttField:buffer-value(viJ) = string(vhField:buffer-value(viJ), vhField:format) no-error.
                        error-status:error = false.    // par défaut, en cas d'erreur, on laisse la valeur false.
                    end.
                    when "I2C" then do:
                        vhttField:buffer-value(viJ) = string(vhField:buffer-value(viJ), vhttField:format) no-error.
                        if error-status:error then vhttField:buffer-value(viJ) = vhField:buffer-value(viJ) no-error.
                    end.
                    when "C2L" then vhttField:buffer-value(viJ) = (vhField:buffer-value(viJ) = entry(1,vhttField:format,"/")) no-error.
                    otherwise vhttField:buffer-value(viJ) = vhField:buffer-value(viJ) no-error.
                end case.
            end.
            else if vhttField:extent = 0 and vhField:extent = 0
            then case vcConversion:
                when "C2C" then vhttField:buffer-value() = trim(vhField:buffer-value()) no-error.
                when "L2C" then do:
                    vhttField:buffer-value() = string(vhField:buffer-value(), vhField:format) no-error.
                    error-status:error = false.    // par défaut, en cas d'erreur, on laisse la valeur false.
                end.
                when "I2C" then do:
                    vhttField:buffer-value() = string(vhField:buffer-value(), vhttField:format) no-error.
                    if error-status:error then vhttField:buffer-value() = vhField:buffer-value() no-error.
                end.
                when "C2L" then vhttField:buffer-value() = (vhField:buffer-value() = entry(1, vhttField:format, "/")) no-error.
                otherwise vhttField:buffer-value() = vhField:buffer-value() no-error.
            end case.
            else next boucle.

            if error-status:error then do:
                mError:createError({&NIVEAU-error}, error-status:get-message(1)).
                assign error-status:error = false no-error.
                undo, return false.
            end.
        end.
        phttBuffer::CRUD        = 'R' no-error.
        phttBuffer::dtTimestamp = datetime(phBuffer::dtmsy, phBuffer::hemsy) no-error.      // ces champs n'existent pas sur toutes les tables
        if error-status:error                                                               // si champs inexistant erreur et on recherche alors sur champ compta damod ihmod
        then phttBuffer::dtTimestamp = datetime(phBuffer::damod, phBuffer::ihmod) no-error.
        if error-status:error then phttBuffer::dtTimestamp = ? no-error.                             // si dtmsy damod n'existent pas
        phttBuffer::rRowid = phBuffer:rowid no-error.
        return true.

    end method.

    method public static logical copyValidLabeledField(phBuffer as handle, phttBuffer as handle):
        /*------------------------------------------------------------------------------
        Purpose: copy table physique vers temp-table - TODO:  obsolete, à supprimer
        Notes: mappage des champs par la colonne de la table vers le label de la colonne de la temp-table
        ------------------------------------------------------------------------------*/
        return copyValidField(phBuffer, phttBuffer).
    end method.

    method public static date convertionDate(pcFormatDate as character, pcDateIn as character):
        /*------------------------------------------------------------------------------
        Purpose: transforme un format date en dmy. On accepte d, dd; m,mm; y, yy, yyyy.
        Notes  : slashes(/), periods(.), and hyphens(-) are accepted as separator
        ------------------------------------------------------------------------------*/
        define variable vdaOut   as date no-undo.
        define variable vcFormat as character no-undo.

        assign
            pcFormatDate = replace(pcFormatDate, '/', '')
            pcFormatDate = replace(pcFormatDate, '.', '')
            pcFormatDate = replace(pcFormatDate, '-', '')
            pcFormatDate = replace(pcFormatDate, 'dd', 'd')
            pcFormatDate = replace(pcFormatDate, 'mm', 'm')
            pcFormatDate = replace(pcFormatDate, 'yy', 'y')
            pcFormatDate = replace(pcFormatDate, 'yy', 'y')
            pcFormatDate = replace(pcFormatDate, 'yy', 'y')
        .
        if pcFormatDate <> session:date-format and can-do('mdy,myd,ymd,ydm,myd,mdy', pcFormatDate)
        then do:
            assign
                vcFormat            = session:date-format
                session:date-format = pcFormatDate
                vdaOut              = date(pcDateIn)
             no-error.
             session:date-format = vcFormat.
        end.
        else vdaOut = date(pcDateIn) no-error.
        return vdaOut.

    end method.

    method public static character bufferCompare(phBuffer1 as handle, phBuffer2 as handle):
        /*------------------------------------------------------------------------------
        Purpose: faire une comparaison temp table (avec label) et table physique.
        Notes  : mappage des champs par le label de la colonne de la temp-table vers la colonne de la table
                 La chaîne renvoyée est la liste des champs différents, de la table temporaire
        ------------------------------------------------------------------------------*/
        define variable vhTTbuffer     as handle    no-undo.
        define variable vhDBbuffer     as handle    no-undo.
        define variable vhDBfield      as handle    no-undo.
        define variable vhTTfield      as handle    no-undo.
        define variable vi             as integer   no-undo.
        define variable viJ            as integer   no-undo.
        define variable vcConversion   as character no-undo.
        define variable vcCompare      as character no-undo.
        define variable vlValue        as logical   no-undo.

        if valid-handle(phBuffer1:table-handle) = valid-handle(phBuffer2:table-handle)
        then return error.    // on utilisera un buffer-compare pour 2 table physiques ou 2 tables TT.

        if valid-handle(phBuffer1:table-handle)    // table temporaire
        then assign
            vhTTbuffer = phBuffer1
            vhDBbuffer = phBuffer2
        .
        else assign
            vhTTbuffer = phBuffer2
            vhDBbuffer = phBuffer1
        .
boucle:
        do vi = 1 to vhTTbuffer:num-fields:
            assign
                vhDBfield = ? // A cause de la boucle et du assign no-error
                vhTTfield = ? // A cause de la boucle et du assign no-error
                vhTTfield = vhTTbuffer:buffer-field(vi)
                vhDBfield = vhDBbuffer:buffer-field(vhTTfield:label)
            no-error.
            if can-do('{&excludedField}', vhTTfield:name) or not valid-handle(vhDBfield) then next boucle.

            vcConversion = if vhDBfield:data-type = "character" and vhTTfield:data-type = "character"
                           then "C2C"
                           else if vhDBfield:data-type = "character" and vhTTfield:data-type = "logical"
                           then "C2L"
                           else if vhDBfield:data-type = "character" and (vhTTfield:data-type = "integer" or vhTTfield:data-type = "int64")
                           then "C2I"
                           else if vhDBfield:data-type = "date"      and vhTTfield:data-type = "date"
                           then "D2D"
                           else if vhDBfield:data-type = "logical"   and vhTTfield:data-type = "character"
                           then "L2C"
                           else if (vhDBfield:data-type = "integer" or vhDBfield:data-type = "int64") and vhTTfield:data-type = "character"
                           then "I2C"
                           else "".
            if vhTTfield:extent > 0 and vhDBfield:extent > 0
            then do viJ = 1 to minimum(vhTTfield:extent, vhDBfield:extent):
                case vcConversion:
                    when "C2C" then if vhDBfield:buffer-value(viJ) <> vhTTfield:buffer-value(viJ)
                                    then do: vcCompare = vcCompare + "," + vhTTfield:name. leave. end.
                    when "C2L" then do:
                        assign
                            vlValue = false
                            vlValue = (vhDBfield:buffer-value(viJ) = trim(string(vhTTfield:buffer-value(viJ), vhTTfield:format)))
                        no-error.
                        if vlValue = false
                        then do: vcCompare = vcCompare + "," + vhTTfield:name. leave. end.
                    end.
                    when "C2I" or when "I2C" then do:
                        assign
                            vlValue = false
                            vlValue = (int64(vhDBfield:buffer-value(viJ)) = int64(vhTTfield:buffer-value(viJ)))
                        no-error.
                        if vlValue = false
                        then do: vcCompare = vcCompare + "," + vhTTfield:name. leave. end.
                    end.
                    when "D2D" then if vhDBfield:buffer-value(viJ) <> vhTTfield:buffer-value(viJ)
                                    then do: vcCompare = vcCompare + "," + vhTTfield:name. leave. end.
                    when "L2C" then do:
                        assign
                            vlValue = false
                            vlValue = (vhTTfield:buffer-value(viJ) = string(vhDBfield:buffer-value(viJ), vhDBfield:format))
                        no-error.
                        if vlValue = false
                        then do: vcCompare = vcCompare + "," + vhTTfield:name. leave. end.
                    end.
                    otherwise if vhDBfield:buffer-value(viJ) <> vhTTfield:buffer-value(viJ)
                              then do: vcCompare = vcCompare + "," + vhTTfield:name. leave. end.
                end case.
            end.
            else if vhTTfield:extent = 0 and vhDBfield:extent = 0
            then case vcConversion:
                when "C2C" then if vhDBfield:buffer-value() <> vhTTfield:buffer-value()
                                then vcCompare = vcCompare + "," + vhTTfield:name.
                when "C2L" then do:
                    assign
                        vlValue = false
                        vlValue = (vhDBfield:buffer-value() = trim(string(vhTTfield:buffer-value(), vhTTfield:format)))
                    no-error.
                    if vlValue = false then vcCompare = vcCompare + "," + vhTTfield:name.
                end.
                when "C2I" or when "I2C" then do:
                    assign
                        vlValue = false
                        vlValue = (int64(vhDBfield:buffer-value()) = int64(vhTTfield:buffer-value()))
                    no-error.
                    if vlValue = false then vcCompare = vcCompare + "," + vhTTfield:name.
                end.
                when "D2D" then if (vhDBfield:buffer-value() <> ? or vhTTfield:buffer-value() <> 01/01/0001)
                                and vhDBfield:buffer-value() <> vhTTfield:buffer-value()
                                then vcCompare = vcCompare + "," + vhTTfield:name.
                when "L2C" then do:
                    assign
                        vlValue = false
                        vlValue = (vhTTfield:buffer-value() = string(vhDBfield:buffer-value(), vhDBfield:format))
                    no-error.
                    if vlValue = false then vcCompare = vcCompare + "," + vhTTfield:name.
                end.
                otherwise if vhDBfield:buffer-value() <> vhTTfield:buffer-value()
                          then vcCompare = vcCompare + "," + vhTTfield:name.
            end case.
            else vcCompare = vcCompare + "," + vhTTfield:name.
        end.
        return trim(vcCompare, ",").
    end method.

    method public static character isValidDate(pdaDate as date):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return if pdaDate = ? then "../../...." else string(pdaDate, "99/99/9999").
    end method.

end class.
