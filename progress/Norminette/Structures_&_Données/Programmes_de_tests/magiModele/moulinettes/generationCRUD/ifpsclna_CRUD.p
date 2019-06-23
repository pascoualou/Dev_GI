/*------------------------------------------------------------------------
File        : ifpsclna_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifpsclna
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifpsclna.i}
{application/include/error.i}
define variable ghttifpsclna as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypenat-cd as handle, output phScen-cle as handle, output phLig-num as handle, output phPos as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typenat-cd/scen-cle/lig-num/pos, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typenat-cd' then phTypenat-cd = phBuffer:buffer-field(vi).
            when 'scen-cle' then phScen-cle = phBuffer:buffer-field(vi).
            when 'lig-num' then phLig-num = phBuffer:buffer-field(vi).
            when 'pos' then phPos = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfpsclna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfpsclna.
    run updateIfpsclna.
    run createIfpsclna.
end procedure.

procedure setIfpsclna:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfpsclna.
    ghttIfpsclna = phttIfpsclna.
    run crudIfpsclna.
    delete object phttIfpsclna.
end procedure.

procedure readIfpsclna:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifpsclna 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter piLig-num    as integer    no-undo.
    define input parameter piPos        as integer    no-undo.
    define input parameter table-handle phttIfpsclna.
    define variable vhttBuffer as handle no-undo.
    define buffer ifpsclna for ifpsclna.

    vhttBuffer = phttIfpsclna:default-buffer-handle.
    for first ifpsclna no-lock
        where ifpsclna.soc-cd = piSoc-cd
          and ifpsclna.etab-cd = piEtab-cd
          and ifpsclna.typenat-cd = piTypenat-cd
          and ifpsclna.scen-cle = pcScen-cle
          and ifpsclna.lig-num = piLig-num
          and ifpsclna.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsclna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpsclna no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfpsclna:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifpsclna 
    Notes  : service externe. Critère piLig-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypenat-cd as integer    no-undo.
    define input parameter pcScen-cle   as character  no-undo.
    define input parameter piLig-num    as integer    no-undo.
    define input parameter table-handle phttIfpsclna.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifpsclna for ifpsclna.

    vhttBuffer = phttIfpsclna:default-buffer-handle.
    if piLig-num = ?
    then for each ifpsclna no-lock
        where ifpsclna.soc-cd = piSoc-cd
          and ifpsclna.etab-cd = piEtab-cd
          and ifpsclna.typenat-cd = piTypenat-cd
          and ifpsclna.scen-cle = pcScen-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsclna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifpsclna no-lock
        where ifpsclna.soc-cd = piSoc-cd
          and ifpsclna.etab-cd = piEtab-cd
          and ifpsclna.typenat-cd = piTypenat-cd
          and ifpsclna.scen-cle = pcScen-cle
          and ifpsclna.lig-num = piLig-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifpsclna:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfpsclna no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfpsclna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifpsclna for ifpsclna.

    create query vhttquery.
    vhttBuffer = ghttIfpsclna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfpsclna:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpsclna exclusive-lock
                where rowid(ifpsclna) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpsclna:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle/lig-num/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifpsclna:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfpsclna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifpsclna for ifpsclna.

    create query vhttquery.
    vhttBuffer = ghttIfpsclna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfpsclna:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifpsclna.
            if not outils:copyValidField(buffer ifpsclna:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfpsclna private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypenat-cd    as handle  no-undo.
    define variable vhScen-cle    as handle  no-undo.
    define variable vhLig-num    as handle  no-undo.
    define variable vhPos    as handle  no-undo.
    define buffer ifpsclna for ifpsclna.

    create query vhttquery.
    vhttBuffer = ghttIfpsclna:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfpsclna:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypenat-cd, output vhScen-cle, output vhLig-num, output vhPos).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifpsclna exclusive-lock
                where rowid(Ifpsclna) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifpsclna:handle, 'soc-cd/etab-cd/typenat-cd/scen-cle/lig-num/pos: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypenat-cd:buffer-value(), vhScen-cle:buffer-value(), vhLig-num:buffer-value(), vhPos:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifpsclna no-error.
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

