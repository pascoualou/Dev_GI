/*------------------------------------------------------------------------
File        : ctanx_CRUD.p
Purpose     : Librairie contenant les procedures liees a la maj de la table ctanx
Author(s)   : GGA 2017/11/13
Notes       : repris depuis adb/lib/l_ctanx.p (et seulement les procedures utilisees)
derniere revue: 2018/09/13 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttctanx as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodoc, il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCtanx private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtanx.
    run updateCtanx.
    run createCtanx.
end procedure.

procedure setCtanx:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtanx.
    ghttCtanx = phttCtanx.
    run crudCtanx.
    delete object phttCtanx.
end procedure.

procedure readCtanx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement contrat annexe
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter table-handle phttCtanx.

    define variable vhttBuffer as handle no-undo.
    define buffer ctanx for ctanx.

    vhttBuffer = phttCtanx:default-buffer-handle.
    for first ctanx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.nocon = piNumeroContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtanx no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtanx:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table des contrats annexes
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat as character no-undo.
    define input  parameter pcTypeRole    as character no-undo.
    define input  parameter piNumeroRole  as integer   no-undo.
    define input  parameter table-handle phttCtanx.

    define variable vhttBuffer as handle  no-undo.
    define buffer ctanx for ctanx.

    vhttBuffer = phttCtanx:default-buffer-handle.
    if piNumeroRole = ?
    then for each ctanx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.tprol = pcTypeRole:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ctanx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.tprol = pcTypeRole
          and ctanx.norol = piNumeroRole:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctanx:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtanx no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtanx private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la mise a jour de la table ctanx
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer ctanx   for ctanx.
    define buffer vbCtanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtanx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            if vhTpcon:buffer-value() = {&TYPECONTRAT-RIB} then run modifSepa(vhttBuffer). 
            find first ctanx exclusive-lock
                where rowid(ctanx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctanx:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctanx:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            // Duplication SIRET, APE et RCS du contrat 01047 (TVAIntracommunautaire) dans le 01002 (Association)
            if vhTpcon:buffer-value() = {&TYPECONTRAT-TVAIntracommunautaire} then do:
                find first vbCtanx exclusive-lock
                    where vbCtanx.tpcon = {&TYPECONTRAT-Association}
                      and vbCtanx.tprol = ctanx.tprol
                      and vbCtanx.norol = ctanx.norol no-error.
                if not available vbCtanx then do:
                    create vbCtanx.
                    assign
                        vbCtanx.nodoc = next-value(Sq_NoDoc01)
                        vbCtanx.tpcon = {&TYPECONTRAT-Association}
                        vbCtanx.nocon = vbCtanx.nodoc
                        vbCtanx.tprol = ctanx.tprol
                        vbCtanx.norol = ctanx.norol
                        vbCtanx.dtcsy = today
                        vbCtanx.hecsy = mtime
                        vbCtanx.cdmsy = mToken:cUser
                    . 
                end. 
                assign
                    vbCtanx.nosir = ctanx.nosir
                    vbCtanx.cptbq = ctanx.cptbq
                    vbCtanx.cdape = ctanx.cdape
                    vbCtanx.lbprf = ctanx.lbprf
                    vbCtanx.liexe = ctanx.liexe
                    vbCtanx.dtmsy = today
                    vbCtanx.hemsy = mtime
                    vbCtanx.cdmsy = mToken:cUser
                .
            end. 
            if mError:erreur() then undo blocTrans, leave blocTrans. 
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtanx private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure pour la creation dans la table ctanx
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable viNodoc    as int64   no-undo initial ?.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtanx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNodoc).

    if valid-handle(vhNodoc) then
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            if vhTpcon:buffer-value() = {&TYPECONTRAT-RIB} then run modifSepa(vhttBuffer). 
            viNodoc = vhNodoc:buffer-value().
            if viNodoc = 0 or viNodoc = ? then viNodoc = next-value (Sq_NoDoc01).
            create ctanx.
            assign
                ctanx.nodoc        = viNodoc
                ctanx.nocon        = viNodoc 
                vhttBuffer::rRowid = rowid(ctanx)
            no-error.
            if error-status:error then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
            if not outils:copyValidField(buffer ctanx:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.

            // todo pour pas Duplication SIRET, APE et RCS du contrat 01047 (TVAIntracommunautaire) dans le 01002 (Association) ?????

            if mError:erreur() then undo blocTrans, leave blocTrans. 
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtanx private:
    /*------------------------------------------------------------------------------
    Purpose: suppression des contrats annexes
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define buffer ctanx for ctanx.

    create query vhttquery.
    vhttBuffer = ghttCtanx:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtanx:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctanx exclusive-lock
                where rowid(Ctanx) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctanx:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ctanx no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.

            // todo si Duplication SIRET, APE et RCS du contrat 01047, supprimer le ctanx associé ????

        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure modifSepa private:
    /*------------------------------------------------------------------------------
    Purpose: ibantorib
    Notes  : On fait un mapping de champ sur label 
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer as handle no-undo.

    define variable vcTpcon as character no-undo.
    define variable vcTprol as character no-undo.
    define variable vhCdbqu as handle    no-undo.
    define variable vhCdqui as handle    no-undo.
    define variable vhNocpt as handle    no-undo.
    define variable vhNorib as handle    no-undo.
    define variable vcIban  as character no-undo.
    define variable vi      as integer   no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then vcTpcon = phBuffer:buffer-field(vi):buffer-value().
            when 'tprol' then vcTprol = phBuffer:buffer-field(vi):buffer-value().
            when 'iban'  then vcIban  = phBuffer:buffer-field(vi):buffer-value().
            when 'cdbqu' then vhCdbqu = phBuffer:buffer-field(vi).
            when 'cdqui' then vhCdqui = phBuffer:buffer-field(vi).
            when 'nocpt' then vhNocpt = phBuffer:buffer-field(vi).
            when 'norib' then vhNorib = phBuffer:buffer-field(vi).
       end case.
    end.
    if vcIban > "" and vcTpcon = {&TYPECONTRAT-RIB} and vcTprol = "99999"
    and valid-handle(vhCdbqu)
    and valid-handle(vhCdqui)
    and valid-handle(vhNocpt)
    and valid-handle(vhNorib) then do:                             /* Seulement pour les coord. bancaires */
        if can-do("FR*,MC*", vcIban)                               /* + "MC" = Monaco 0312/0118 */
        then assign
            vhCdbqu:buffer-value() = substring(vcIban, 5, 5, "character")
            vhCdqui:buffer-value() = substring(vcIban, 10, 5, "character")
            vhNocpt:buffer-value() = substring(vcIban, 15, 11, "character")
            vhNorib:buffer-value() = integer(substring(vcIban, 26, 2, "character"))
        .
        else assign
            vhCdbqu:buffer-value() = ""
            vhCdqui:buffer-value() = ""
            vhNocpt:buffer-value() = ""
            vhNorib:buffer-value() = 0
        .
    end.

end procedure.

function getNombreContratAnnexe returns integer(pcTypeContrat as character, pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: fonction qui retourne le nombre de contrat annexe 
    Notes: service externe 
    ------------------------------------------------------------------------------*/
    define variable viNombreCompte as integer no-undo.
    define buffer ctanx for ctanx.

    for each ctanx no-lock
        where ctanx.tpcon = pcTypeContrat
          and ctanx.tprol = pcTypeRole
          and ctanx.norol = piNumeroRole:
        viNombreCompte = viNombreCompte + 1.
    end.
    return viNombreCompte.

end function.
