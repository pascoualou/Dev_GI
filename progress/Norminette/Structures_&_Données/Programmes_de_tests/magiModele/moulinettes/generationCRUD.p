/*------------------------------------------------------------------------------
Purpose: génération programme crud
authors: kantena - 2018/01/20
Notes  :
------------------------------------------------------------------------------*/

define stream sortie.
define variable gcParam as character no-undo initial "    define input parameter p&1&2 as &3 no-undo.&4".

define variable gcEnteteInclude as character no-undo initial
"~/~*------------------------------------------------------------------------&3
File        : &4.i&3
Purpose     : &7&3
Author(s)   : generation automatique le &2&3
Notes       :&3
------------------------------------------------------------------------*/&3
~&~&if defined(nomTable)   = 0 ~&~&then ~&~&scoped-define nomTable tt&1&3
~&~&endif&3
~&~&if defined(serialName) = 0 ~&~&then ~&~&scoped-define serialName ~{~&~&nomTable}&3
~&~&endif&3
define temp-table ~{~&~&nomTable} no-undo serialize-name '~{~&~&serialName}'".
define variable gcEntete   as character no-undo initial
"/*------------------------------------------------------------------------&3
File        : &1_CRUD.p&3
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table &1&3
Author(s)   : generation automatique le &2&3
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition&3
              que les champs de l'index unique soient tous présents.&3
------------------------------------------------------------------------*/&3
&3
~{oerealm/include/instanciateTokenOnModel.i}      ~// Doit être positionnée juste après using&3
~/~/~{include/&1.i}&3
~{application/include/error.i}&3
define variable ghtt&1 as handle no-undo.      ~// le handle de la temp table à mettre à jour&3
&3".
define variable gcCrud as character no-undo initial
"procedure crud&1 private:&3
    /*------------------------------------------------------------------------------&3
    Purpose:&3
    Notes  :&3
    ------------------------------------------------------------------------------*/&3
    run delete&1.&3
    run update&1.&3
    run create&1.&3
end procedure.&3
&3
procedure set&1:&3
    /*------------------------------------------------------------------------------&3
    Purpose:&3
    Notes  : service externe&3
    ------------------------------------------------------------------------------*/&3
    define input parameter table-handle phtt&1.&3
    ghtt&1 = phtt&1.&3
    run crud&1.&3
    delete object phtt&1.&3
end procedure.&3
".
define variable gcRead as character no-undo initial
"procedure read&1:&3
    /*------------------------------------------------------------------------------&3
    Purpose: Lecture d'un enregistrement de la table &4 &7&3
    Notes  : service externe&3
    ------------------------------------------------------------------------------*/&3
&8
    define input parameter table-handle phtt&1.&3
    define variable vhttBuffer as handle no-undo.&3
    define buffer &4 for &4.&3
&3
    vhttBuffer = phtt&1:default-buffer-handle.&3
    for first &4 no-lock&3
        where &9:&3
        vhttBuffer:buffer-create().&3
        outils:copyValidField(buffer &4:handle, vhttBuffer).  // copy table physique vers temp-table&3
    end.&3
    delete object phtt&1 no-error.&3
    assign error-status:error = false no-error.   // reset error-status&3
    return.                                       // reset return-value&3
end procedure.&3
".
define variable gcGetAvecParametre as character no-undo initial
"procedure get&1:&3
    /*------------------------------------------------------------------------------&3
    Purpose: Lecture des enregistrements de la table &4 &7&3
    Notes  : service externe. Critère &2 = ? si pas à prendre en compte&3
    ------------------------------------------------------------------------------*/&3
&8
    define input parameter table-handle phtt&1.&3
    define variable vhttBuffer as handle  no-undo.&3
    define buffer &4 for &4.&3
&3
    vhttBuffer = phtt&1:default-buffer-handle.&3
    if &2 = ?&3
    then for each &4 no-lock&3
        where &6:&3
        vhttBuffer:buffer-create().&3
        outils:copyValidField(buffer &4:handle, vhttBuffer).  // copy table physique vers temp-table&3
    end.&3
    else for each &4 no-lock&3
        where &9:&3
        vhttBuffer:buffer-create().&3
        outils:copyValidField(buffer &4:handle, vhttBuffer).  // copy table physique vers temp-table&3
    end.&3
    delete object phtt&1 no-error.&3
    error-status:error = false no-error.   // reset error-status&3
    return.                                // reset return-value&3
end procedure.&3
".
define variable gcGetSansParametre as character no-undo initial
"procedure get&1:&3
    /*------------------------------------------------------------------------------&3
    Purpose: Lecture des enregistrements de la table &4 &7&3
    Notes  : service externe.&3
    ------------------------------------------------------------------------------*/&3
    define input parameter table-handle phtt&1.&3
    define variable vhttBuffer as handle  no-undo.&3
    define buffer &4 for &4.&3
&3
    vhttBuffer = phtt&1:default-buffer-handle.&3
    for each &4 no-lock:&3
        vhttBuffer:buffer-create().&3
        outils:copyValidField(buffer &4:handle, vhttBuffer).  // copy table physique vers temp-table&3
    end.&3
    delete object phtt&1 no-error.&3
    error-status:error = false no-error.   // reset error-status&3
    return.                                // reset return-value&3
end procedure.&3
".
define variable gcUpdate as character no-undo initial
"procedure update&1 private:&3
    /*------------------------------------------------------------------------------&3
    Purpose:&3
    Notes  :&3
    ------------------------------------------------------------------------------*/&3
    define variable vhttquery  as handle   no-undo.&3
    define variable vhttBuffer as handle   no-undo.&3
&2
    define buffer &4 for &4.&3
&3
    create query vhttquery.&3
    vhttBuffer = ghtt&1:default-buffer-handle.&3
    vhttquery:set-buffers(vhttBuffer).&3
    vhttquery:query-prepare(substitute(~"for each ~&~&1 where ~&~&1.crud = 'U'~", ghtt&1:name)).&3
    vhttquery:query-open().&3
&7&3
blocTrans:&3
    do transaction:&3
        repeat:&3
            vhttquery:get-next().&3
            if vhttquery:query-off-end then leave blocTrans.&3
&3
            find first &4 exclusive-lock&3
                where rowid(&4) = vhttBuffer::rRowid no-wait no-error.&3
            if outils:isUpdated(buffer &4:handle, '&5: ', &6, vhttBuffer::dtTimestamp)&3
            or not outils:copyValidField(buffer &4:handle, vhttBuffer, ~"U~", mtoken:cUser)&3
            then undo blocTrans, leave blocTrans.&3
        end.&3
    end.&3
    vhttquery:query-close().&3
    delete object vhttQuery no-error.&3
    error-status:error = false no-error.   // reset error-status&3
    return.                                // reset return-value&3
end procedure.&3
".
define variable gcCreate as character no-undo initial
"procedure create&1 private:&3
    /*------------------------------------------------------------------------------&3
    Purpose:&3
    Notes  :&3
    ------------------------------------------------------------------------------*/&3
    define variable vhttquery  as handle   no-undo.&3
    define variable vhttBuffer as handle   no-undo.&3
    define buffer &4 for &4.&3
&3
    create query vhttquery.&3
    vhttBuffer = ghtt&1:default-buffer-handle.&3
    vhttquery:set-buffers(vhttBuffer).&3
    vhttquery:query-prepare(substitute(~"for each ~&~&1 where ~&~&1.crud = 'C'~", ghtt&1:name)).&3
    vhttquery:query-open().&3
blocTrans:&3
    do transaction:&3
        repeat:&3
            vhttquery:get-next().&3
            if vhttquery:query-off-end then leave blocTrans.&3
&3
            create &4.&3
            if not outils:copyValidField(buffer &4:handle, vhttBuffer, ~"C~", mtoken:cUser)&3
            then undo blocTrans, leave blocTrans.&3
        end.&3
    end.&3
    vhttquery:query-close().&3
    delete object vhttQuery no-error.&3
    error-status:error = false no-error.   // reset error-status&3
    return.                                // reset return-value&3
end procedure.&3
".
define variable gcDelete as character no-undo initial
"procedure delete&1 private:&3
    /*------------------------------------------------------------------------------&3
    Purpose:&3
    Notes  :&3
    ------------------------------------------------------------------------------*/&3
    define variable vhttquery  as handle   no-undo.&3
    define variable vhttBuffer as handle   no-undo.&3
&2
    define buffer &4 for &4.&3
&3
    create query vhttquery.&3
    vhttBuffer = ghtt&1:default-buffer-handle.&3
    vhttquery:set-buffers(vhttBuffer).&3
    vhttquery:query-prepare(substitute(~"for each ~&~&1 where ~&~&1.crud = 'D'~", ghtt&1:name)).&3
    vhttquery:query-open().&3
&7&3
blocTrans:&3
    do transaction:&3
        repeat:&3
            vhttquery:get-next().&3
            if vhttquery:query-off-end then leave blocTrans.&3
&3
            find first &4 exclusive-lock&3
                where rowid(&1) = vhttBuffer::rRowid no-wait no-error.&3
            if outils:isUpdated(buffer &4:handle, '&5: ', &6, vhttBuffer::dtTimestamp)&3
            then undo blocTrans, leave blocTrans.&3
&3
            delete &4 no-error.&3
            if error-status:error then do:&3
                mError:createError(~{~&~&error}, error-status:get-message(1)).&3
                undo blocTrans, leave blocTrans.&3
            end.&3
        end.&3
    end.&3
    vhttquery:query-close().&3
    delete object vhttQuery no-error.&3
    error-status:error = false no-error.   // reset error-status&3
    return.                                // reset return-value&3
end procedure.&3
".
define variable gcgetIndexfield1 as character no-undo initial
"function getIndexField returns logical private(phBuffer as handle&2):&3
    /*------------------------------------------------------------------------------&3
    Purpose: récupère les handles des n champs de l'index unique&3
    Notes: si la temp-table contient un mapping de label sur &5, &3
           il faut mapper les champs dynamiques&3
    ------------------------------------------------------------------------------*/&3
    define variable vi as integer no-undo.&3
    do vi = 1 to phBuffer:num-fields:&3
        case phBuffer:buffer-field(vi):label:&3
".
define variable gcgetIndexfield2 as character no-undo initial
"       end case.&3
    end.&3
end function.&3
".


run _main.

function formatChamp returns character(pcChamp as character, pimaxlength as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    return caps(substring(pcChamp, 1, 1, "character")) + lc(substring(pcChamp, 2)) + fill(" ", pimaxlength - length(pcChamp, "character")).
end function.
function getParametreIndex returns character(pcListeChamps as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDesc    as character no-undo.
    define variable vcItem    as character no-undo.
    define variable vi        as integer   no-undo.
    do vi = 1 to num-entries(pcListeChamps, "/"):
        if vi > 9 then leave.
        vcItem = entry(vi, pcListeChamps, "/").
        vcDesc = substitute("&1, output ph&2&3 as handle", vcDesc, caps(substring(vcItem, 1, 1)), lc(substring(vcItem, 2))).
    end.
    return vcDesc.
end function.
function getWhenIndex returns character(pcListeChamps as character, output pcRunGetIndex as character, output pcVariableIndex as character, output pcSubstIndex as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDesc    as character no-undo.
    define variable vcItem    as character no-undo.
    define variable vi        as integer   no-undo.
    define variable vcVar     as character   no-undo.
    pcVariableIndex = "".
    pcRunGetIndex = "    getIndexField(vhttBuffer".
    do vi = 1 to num-entries(pcListeChamps, "/"):
        if vi > 9 then leave.
        pcSubstIndex = pcSubstIndex + '/&' + string(vi).
    end.
    pcSubstIndex = "substitute('" + TRIM(pcSubstIndex, "/") + "'".
    do vi = 1 to num-entries(pcListeChamps, "/"):
        if vi > 9 then leave.
        assign
            vcItem          = entry(vi, pcListeChamps, "/")
            vcVar           = caps(substring(vcItem, 1, 1)) + LC(substring(vcItem, 2))
            vcDesc          = substitute("&1            when '&2' then ph&3 = phBuffer:buffer-field(vi).&4", vcDesc, vcItem, vcVar , chr(10))
            pcRunGetIndex   = substitute("&1, output vh&2", pcRunGetIndex, vcVar)
            pcVariableIndex = substitute("&1    define variable vh&2    as handle  no-undo.&3", pcVariableIndex, vcVar, chr(10))
            pcSubstIndex    = substitute("&1, vh&2:buffer-value()", pcSubstIndex, vcVar)
        .
    end.
    pcRunGetIndex = pcRunGetIndex + ").".
    pcSubstIndex  = pcSubstIndex  + ")".
    return vcDesc.
end function.

function getParameter returns character(prFile as recid, pcListeChamps as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDesc    as character no-undo.
    define variable vi        as integer   no-undo.
    define variable maxLength as integer   no-undo.
    define variable vcType    as character no-undo.
    define buffer vbfield for _field.

    do vi = 1 to num-entries(pcListeChamps, "/"):
        if vi > 9 then leave.
        maxLength = maximum(maxLength, length(entry(vi, pcListeChamps, "/"), "character")).
    end.
    do vi = 1 to num-entries(pcListeChamps, "/"):
        if vi > 9 then leave.
        for first vbfield no-lock
            where vbfield._file-recid = prFile
              and vbField._field-name = entry(vi, pcListeChamps, "/"):
            case vbField._data-type:
                when "character" then vcType = "c".
                when "integer"   then vcType = "i".
                when "int64"     then vcType = "i".
                when "logical"   then vcType = "l".
                when "date"      then vcType = "da".
                when "datetime"  then vcType = "dt".
                when "decimal"   then vcType = "de".
                otherwise vcType = "c".
            end case.
            vcDesc = vcDesc + substitute(gcParam, vcType, formatChamp(vbField._field-name, maxlength), string(vbField._data-type, "x(10)"), chr(10)).
        end.
    end.
    return vcDesc.
end function.
function getParameterBis returns character(prFile as recid, pcListeChamps as character, output pcExclude as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDesc    as character no-undo.
    define variable vi        as integer   no-undo.
    define variable maxLength as integer   no-undo.
    define variable vcType    as character no-undo.
    define buffer vbfield for _field.

    do vi = 1 to num-entries(pcListeChamps, "/"):
        if vi > 9 then leave.
        maxLength = maximum(maxLength, length(entry(vi, pcListeChamps, "/"), "character")).
    end.
    do vi = 1 to num-entries(pcListeChamps, "/") - 1:
        if vi > 9 then leave.
        for first vbfield no-lock
            where vbfield._file-recid = prFile
              and vbField._field-name = entry(vi, pcListeChamps, "/"):
            case vbField._data-type:
                when "character" then vcType = "c".
                when "integer"   then vcType = "i".
                when "int64"     then vcType = "i".
                when "logical"   then vcType = "l".
                when "date"      then vcType = "da".
                when "datetime"  then vcType = "dt".
                when "decimal"   then vcType = "de".
                otherwise vcType = "c".
             end case.
             assign
                 pcExclude = substitute("p&1&2&3", vcType, caps(substring(vbField._field-name, 1, 1, "character")), lc(substring(vbField._field-name, 2)))
                 vcDesc    = vcDesc + substitute(gcParam, vcType, formatChamp(vbField._field-name, maxlength), string(vbField._data-type, "x(10)"), chr(10))
             .
        end.
    end.
    return vcDesc.
end function.

function getWhere returns character(prFile as rowid, pcListeChamps as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDesc as character no-undo.
    define variable vi     as integer   no-undo.
    define variable vcType as character no-undo.
    define buffer vbfile  for _file.
    define buffer vbfield for _field.

    for first vbFile no-lock where rowid(vbFile) = prFile:
        do vi = 1 to num-entries(pcListeChamps, "/"):
            if vi > 9 then leave.
            for first vbfield no-lock
                where vbfield._file-recid = recid(vbFile)
                  and vbField._field-name = entry(vi, pcListeChamps, "/"):
                case vbField._data-type:
                    when "character" then vcType = "c".
                    when "integer"   then vcType = "i".
                    when "int64"     then vcType = "i".
                    when "logical"   then vcType = "l".
                    when "date"      then vcType = "da".
                    when "datetime"  then vcType = "dt".
                    when "decimal"   then vcType = "de".
                    otherwise vcType = "c".
                end case.
                vcDesc = substitute("&1$&2.&3 = p&4&5&6&7",
                             vcDesc, vbFile._file-name, vbField._field-name, vcType, caps(substring(vbField._field-name, 1, 1, "character")), lc(substring(vbField._field-name, 2)), chr(10)).
            end.
        end.
    end.
    return replace(trim(trim(vcDesc, chr(10)), "$"), "$", "          and ").
end function.
function getWhereBis returns character(prFile as rowid, pcListeChamps as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDesc as character   no-undo.
    define variable vi     as integer     no-undo.
    define variable vcType as character   no-undo.
    define buffer vbfile  for _file.
    define buffer vbfield for _field.

    for first vbFile no-lock where rowid(vbFile) = prFile:
        do vi = 1 to num-entries(pcListeChamps, "/") - 1:
            if vi > 9 then leave.
            for first vbfield no-lock
                where vbfield._file-recid = recid(vbFile)
                  and vbField._field-name = entry(vi, pcListeChamps, "/"):
                case vbField._data-type:
                    when "character" then vcType = "c".
                    when "integer"   then vcType = "i".
                    when "int64"     then vcType = "i".
                    when "logical"   then vcType = "l".
                    when "date"      then vcType = "da".
                    when "datetime"  then vcType = "dt".
                    when "decimal"   then vcType = "de".
                    otherwise vcType = "c".
                end case.
                vcDesc = substitute("&1$&2.&3 = p&4&5&6&7",
                             vcDesc, vbFile._file-name, vbField._field-name, vcType, caps(substring(vbField._field-name, 1, 1, "character")), lc(substring(vbField._field-name, 2)), chr(10)).
            end.
        end.
    end.
    return replace(trim(trim(vcDesc, chr(10)), "$"), "$", "          and ").
end function.

function getFileDesc returns character(prFile as recid):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer vbfile for _file.

    for first vbFile no-lock where recid(vbFile) = prFile:
        return if vbFile._desc = ? or vbFile._desc = ? then vbFile._file-name else vbFile._desc.
    end.
    return "".
end function.

function getCle returns character(prFile as recid):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    heuristique: Si plusieurs index uniques, on prend celui ayant le plus de champs!
                 si aucun, on prend l'index primaire.
    ------------------------------------------------------------------------------*/
    define variable vcCle     as character no-undo.
    define variable vcCleTemp as character no-undo.
    define buffer vbindex      for _index.
    define buffer vbindexField for _index-field.
    define buffer vbfile       for _file.
    define buffer vbfield      for _field.

    for each vbindex no-lock
        where vbindex._file-recid = prFile
          and vbindex._unique:
        vcCleTemp = "".
        for each vbindexField no-lock
            where vbindexField._index-recid = recid(vbindex)
          , first vbfield no-lock
            where recid(vbfield) = vbindexField._field-recid:
            vcCleTemp = vcCleTemp + "/" + vbfield._field-name.
        end.
        if num-entries(vcCleTemp) > num-entries(vcCle)
        then vcCle = vcCleTemp.
    end.
    vcCle = trim(vcCle, "/").
    if vcCle = ""
    then for first vbFile no-lock
        where recid(vbFile) = prFile
      , first vbindex no-lock
        where recid(vbindex) = vbFile._prime-Index:
        vcCleTemp = "".
        for each vbindexField no-lock
            where vbindexField._index-recid = recid(vbindex)
          , first vbfield no-lock
            where recid(vbfield) = vbindexField._field-recid:
            vcCleTemp = vcCleTemp + "/" + vbfield._field-name.
        end.
        if num-entries(vcCleTemp) > num-entries(vcCle)
        then vcCle = vcCleTemp.
    end.
    return trim(vcCle, "/").
end function.

function getUpdateMessage returns character(pcFileName as character, pcListeChamps as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define variable vi       as integer   no-undo.
    define variable vcAmper  as character no-undo.
    define variable vcChamps as character no-undo.
    vcRetour = "substitute(~"" + lc(pcFileName) + ": &1~", &2)".
    do vi = 1 to minimum(num-entries(pcListeChamps, "/"), 9):
        assign
            vcAmper  = substitute("&1/&&&2", vcAmper, vi)
            vcChamps = substitute("&1, vhttBuffer::&3", vcChamps, pcFileName, entry(vi, pcListeChamps, "/"))
        .
    end.
    if trim(vcChamps, ", ") = "" then vcChamps = '""'.
    return substitute(vcRetour, trim(vcAmper, "/"), trim(vcChamps, ", ")).
end function.

procedure _main:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcFilename          as character no-undo.
    define variable vcCleUpdated        as character no-undo.
    define variable vcUpdateMessage     as character no-undo.
    define variable vcFileDesc          as character no-undo.
    define variable vcParameter         as character no-undo.
    define variable vcWhere             as character no-undo.
    define variable viMaxLength         as integer   no-undo.
    define variable vcParameter2Exclude as character no-undo.
    define variable vcParametreIndex    as character no-undo.
    define variable vcWhere2Exclude     as character no-undo.
    define variable vcRunGetIndex       as character no-undo.
    define variable vcVariableIndex     as character no-undo.
    define variable vcSubstIndex        as character no-undo.
    define buffer vbField for _field.
    define buffer vbFile  for _file.

    for each vbFile no-lock
        where not vbFile._hidden
          and not vbFile._file-name = "system":

        output stream sortie to value(substitute("/MAGI/Outils/generationCRUD/&1_CRUD.p", vbFile._file-name)).
        assign
            vcFileName      = caps(substring(vbFile._file-name, 1, 1, "character")) + lc(substring(vbFile._file-name, 2))
            vcCleUpdated    = getCle(recid(vbFile))
            vcUpdateMessage = getUpdateMessage(vcFileName, vcCleUpdated)
            vcFileDesc      = getFileDesc(recid(vbFile))
            vcParameter     = getParameter(recid(vbFile), vcCleUpdated)
            vcWhere         = getWhere(rowid(vbFile), vcCleUpdated)
            vcParametreIndex = getParametreIndex(vcCleUpdated).
        .
        put stream sortie unformatted substitute(gcEntete, vbFile._file-name,  today, chr(10)) skip.
        
        put stream sortie unformatted substitute(gcgetIndexfield1 ,vcFileName, vcParametreIndex, chr(10), vbFile._file-name, vcCleUpdated, vcUpdateMessage, vcFileDesc, vcParameter, vcWhere).
        put stream sortie unformatted getWhenIndex(vcCleUpdated, output vcRunGetIndex, output vcVariableIndex, output vcSubstIndex).
        put stream sortie unformatted substitute(gcgetIndexfield2 ,vcFileName, today, chr(10), vbFile._file-name, vcCleUpdated, vcUpdateMessage, vcFileDesc, vcParameter, vcWhere) skip.
        
        put stream sortie unformatted substitute(gcCrud, vcFileName, today, chr(10)) skip.
        put stream sortie unformatted substitute(gcRead, vcFileName, today, chr(10), vbFile._file-name, vcCleUpdated, vcUpdateMessage, vcFileDesc, vcParameter, vcWhere) skip.
        assign
            vcParameter     = getParameterBis(recid(vbFile), vcCleUpdated, output vcParameter2Exclude)
            vcWhere         = getWhereBis(rowid(vbFile), vcCleUpdated)
            vcWhere2Exclude = substring(vcWhere, 1, r-index(vcWhere, chr(10)) - 1, "character")
        .
        if num-entries(vcCleUpdated, "/") >= 2
        then put stream sortie unformatted substitute(gcGetAvecParametre,  vcFileName,
                                vcParameter2Exclude , chr(10), vbFile._file-name, vcCleUpdated, vcWhere2Exclude, vcFileDesc, vcParameter, vcWhere) skip.
        else put stream sortie unformatted substitute(gcGetSansParametre,  vcFileName, today, chr(10), vbFile._file-name, vcCleUpdated, vcUpdateMessage, vcFileDesc, vcParameter, vcWhere) skip.

        put stream sortie unformatted substitute(gcUpdate, vcFileName, vcVariableIndex, chr(10), vbFile._file-name, vcCleUpdated, vcSubstIndex, vcRunGetIndex) skip.

        
        put stream sortie unformatted substitute(gcCreate, vcFileName, today, chr(10), vbFile._file-name, vcCleUpdated, vcUpdateMessage) skip.
        put stream sortie unformatted substitute(gcDelete, vcFileName, vcVariableIndex, chr(10), vbFile._file-name, vcCleUpdated, vcSubstIndex, vcRunGetIndex) skip.
        
        output stream sortie close.

        output stream sortie to value(substitute("/MAGI/Outils/generationCRUD/&1.i", vbFile._file-name)).
        viMaxLength = 0.
        put stream sortie unformatted substitute(gcEnteteInclude, vcFileName, today, chr(10), vbFile._file-name, vcCleUpdated, vcUpdateMessage, vcFileDesc, vcParameter, vcWhere) skip.
        for each vbfield no-lock
            where vbfield._file-recid = recid(vbFile):
            viMaxLength = maximum(viMaxLength, length(vbfield._field-name, "character")).
        end.
        for each vbfield no-lock
            where vbfield._file-recid = recid(vbFile):
            put stream sortie unformatted "    field " vbfield._field-name fill(" ", viMaxLength - length(vbfield._field-name, "character")) " as " vbfield._data-type format "x(10)"  " initial ? ".
            if vbfield._data-type = "decimal"
            then put stream sortie unformatted " decimals " vbfield._decimals skip.
            else put stream sortie unformatted skip.
        end.
        put stream sortie unformatted
            "    field dtTimestamp as datetime  initial ?" skip
            "    field CRUD        as character initial ?" skip
            "    field rRowid      as rowid" skip
            "." skip.
        output stream sortie close.
    end.

end procedure.
