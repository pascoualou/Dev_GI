/*------------------------------------------------------------------------
File        : itypeexp_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table itypeexp
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/itypeexp.i}
{application/include/error.i}
define variable ghttitypeexp as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTrt-cd as handle, output phMandat-cd as handle, output phMregl-cd as handle, output phTri-cd as handle, output phTypedoc-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/trt-cd/mandat-cd/mregl-cd/tri-cd/typedoc-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'trt-cd' then phTrt-cd = phBuffer:buffer-field(vi).
            when 'mandat-cd' then phMandat-cd = phBuffer:buffer-field(vi).
            when 'mregl-cd' then phMregl-cd = phBuffer:buffer-field(vi).
            when 'tri-cd' then phTri-cd = phBuffer:buffer-field(vi).
            when 'typedoc-cd' then phTypedoc-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudItypeexp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteItypeexp.
    run updateItypeexp.
    run createItypeexp.
end procedure.

procedure setItypeexp:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttItypeexp.
    ghttItypeexp = phttItypeexp.
    run crudItypeexp.
    delete object phttItypeexp.
end procedure.

procedure readItypeexp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table itypeexp 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piTrt-cd     as integer    no-undo.
    define input parameter piMandat-cd  as integer    no-undo.
    define input parameter pcMregl-cd   as character  no-undo.
    define input parameter pcTri-cd     as character  no-undo.
    define input parameter pcTypedoc-cd as character  no-undo.
    define input parameter table-handle phttItypeexp.
    define variable vhttBuffer as handle no-undo.
    define buffer itypeexp for itypeexp.

    vhttBuffer = phttItypeexp:default-buffer-handle.
    for first itypeexp no-lock
        where itypeexp.soc-cd = piSoc-cd
          and itypeexp.trt-cd = piTrt-cd
          and itypeexp.mandat-cd = piMandat-cd
          and itypeexp.mregl-cd = pcMregl-cd
          and itypeexp.tri-cd = pcTri-cd
          and itypeexp.typedoc-cd = pcTypedoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypeexp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypeexp no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getItypeexp:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table itypeexp 
    Notes  : service externe. Critère pcTri-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piTrt-cd     as integer    no-undo.
    define input parameter piMandat-cd  as integer    no-undo.
    define input parameter pcMregl-cd   as character  no-undo.
    define input parameter pcTri-cd     as character  no-undo.
    define input parameter table-handle phttItypeexp.
    define variable vhttBuffer as handle  no-undo.
    define buffer itypeexp for itypeexp.

    vhttBuffer = phttItypeexp:default-buffer-handle.
    if pcTri-cd = ?
    then for each itypeexp no-lock
        where itypeexp.soc-cd = piSoc-cd
          and itypeexp.trt-cd = piTrt-cd
          and itypeexp.mandat-cd = piMandat-cd
          and itypeexp.mregl-cd = pcMregl-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypeexp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each itypeexp no-lock
        where itypeexp.soc-cd = piSoc-cd
          and itypeexp.trt-cd = piTrt-cd
          and itypeexp.mandat-cd = piMandat-cd
          and itypeexp.mregl-cd = pcMregl-cd
          and itypeexp.tri-cd = pcTri-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer itypeexp:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttItypeexp no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateItypeexp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTrt-cd    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhMregl-cd    as handle  no-undo.
    define variable vhTri-cd    as handle  no-undo.
    define variable vhTypedoc-cd    as handle  no-undo.
    define buffer itypeexp for itypeexp.

    create query vhttquery.
    vhttBuffer = ghttItypeexp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttItypeexp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTrt-cd, output vhMandat-cd, output vhMregl-cd, output vhTri-cd, output vhTypedoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypeexp exclusive-lock
                where rowid(itypeexp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypeexp:handle, 'soc-cd/trt-cd/mandat-cd/mregl-cd/tri-cd/typedoc-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhTrt-cd:buffer-value(), vhMandat-cd:buffer-value(), vhMregl-cd:buffer-value(), vhTri-cd:buffer-value(), vhTypedoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer itypeexp:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createItypeexp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer itypeexp for itypeexp.

    create query vhttquery.
    vhttBuffer = ghttItypeexp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttItypeexp:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create itypeexp.
            if not outils:copyValidField(buffer itypeexp:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteItypeexp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTrt-cd    as handle  no-undo.
    define variable vhMandat-cd    as handle  no-undo.
    define variable vhMregl-cd    as handle  no-undo.
    define variable vhTri-cd    as handle  no-undo.
    define variable vhTypedoc-cd    as handle  no-undo.
    define buffer itypeexp for itypeexp.

    create query vhttquery.
    vhttBuffer = ghttItypeexp:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttItypeexp:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTrt-cd, output vhMandat-cd, output vhMregl-cd, output vhTri-cd, output vhTypedoc-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first itypeexp exclusive-lock
                where rowid(Itypeexp) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer itypeexp:handle, 'soc-cd/trt-cd/mandat-cd/mregl-cd/tri-cd/typedoc-cd: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhTrt-cd:buffer-value(), vhMandat-cd:buffer-value(), vhMregl-cd:buffer-value(), vhTri-cd:buffer-value(), vhTypedoc-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete itypeexp no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

