/*-----------------------------------------------------------------------------
File        : erlet_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table erlet
Author(s)   : generation automatique le 01/31/18 + modifications SPo 03/22/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/04/12 - phm: KO
            A revoir par rapport à l'unicité des index.
            noimm est un champ intermédiaire dans l'index ix_erlet03, donc getNextNumeroReleveCompteur est très douteux.
            readErletMandatNumeroReleve ne se base pas sur un index unique.
            ...
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
{application/include/error.i}
define variable ghtterlet as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNorli as handle, output phTpcon as handle, output phNocon as handle, output phTpcpt as handle, output phNorlv as handle, output phNoimm as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur norli, il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'norli' then phNorli = phBuffer:buffer-field(vi).
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'tpcpt' then phTpcpt = phBuffer:buffer-field(vi).
            when 'norlv' then phNorlv = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteErlet.
    run updateErlet.
    run createErlet.
end procedure.

procedure setErlet:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttErlet.
    ghttErlet = phttErlet.
    run crudErlet.
    delete object phttErlet.
end procedure.

procedure readErlet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table erlet à partir du no interne unique 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNorli as integer   no-undo.
    define input parameter table-handle phttErlet.

    define variable vhttBuffer as handle no-undo.
    define buffer erlet for erlet.

    vhttBuffer = phttErlet:default-buffer-handle.
    for first erlet no-lock
        where erlet.norli = piNorli:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erlet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttErlet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure readErletMandatNumeroReleve:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table erlet à partir du mandat + no relevé
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as integer   no-undo.
    define input parameter pcTpcpt as character no-undo.
    define input parameter piNorlv as integer   no-undo.
    define input parameter table-handle phttErlet.
    define variable vhttBuffer as handle no-undo.
    define buffer erlet for erlet.

    vhttBuffer = phttErlet:default-buffer-handle.
    for first erlet no-lock
        where erlet.tpcon = pcTpcon
          and erlet.nocon = piNocon
          and erlet.tpcpt = pcTpcpt
          and erlet.norlv = piNorlv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erlet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttErlet no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getErlet:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table erlet pour un mandat et un type de compteur 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeCompteur  as character no-undo.
    define input parameter table-handle phttErlet.

    define variable vhttBuffer as handle  no-undo.
    define buffer erlet for erlet.

    vhttBuffer = phttErlet:default-buffer-handle.
    if pcTypeCompteur = ?
    then for each erlet no-lock
        where erlet.tpcon = pcTypeContrat
          and erlet.nocon = piNumeroContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erlet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each erlet no-lock
        where erlet.tpcon = pcTypeContrat
          and erlet.nocon = piNumeroContrat
          and erlet.tpcpt = pcTypeCompteur:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer erlet:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttErlet no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNorli    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpcpt    as handle  no-undo.
    define variable vhNorlv    as handle  no-undo.
    define variable vhNoImm    as handle  no-undo.
    define buffer erlet for erlet.

    create query vhttquery.
    vhttBuffer = ghttErlet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttErlet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorli, output vhTpcon, output vhNocon, output vhTpcpt, output vhNorlv, output vhNoImm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first erlet exclusive-lock
                where rowid(erlet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer erlet:handle, 'norli/mandat/type compteur/no relevé: ', substitute('&1/&2/&3/&4', vhNorli:buffer-value(), vhNocon:buffer-value(), vhTpcpt:buffer-value(), vhNorlv:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer erlet:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNorli    as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpcpt    as handle  no-undo.
    define variable vhNorlv    as handle  no-undo.
    define variable vhNoImm    as handle  no-undo.
    define variable viNorli    as int64   no-undo.
    define variable viNorlv    as integer no-undo.
    define buffer erlet for erlet.

    create query vhttquery.
    vhttBuffer = ghttErlet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttErlet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorli, output vhTpcon, output vhNocon, output vhTpcpt, output vhNorlv, output vhNoImm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            viNorli = vhNorli:buffer-value().
            viNorlv = vhNorlv:buffer-value().
            if viNorli = 0 or viNorlv = 0 then do:
                run getNextNumeroReleveCompteur(vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpcpt:buffer-value(), output viNorli, output viNorlv).
                assign
                    vhNorli:buffer-value() = viNorli
                    vhNorlv:buffer-value() = viNorlv
                .
            end.
            create erlet.
            if not outils:copyValidField(buffer erlet:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteErlet private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle no-undo.
    define variable vhttBuffer as handle no-undo.
    define variable vhNorli    as handle no-undo.
    define variable vhTpcon    as handle no-undo.
    define variable vhNocon    as handle no-undo.
    define variable vhTpcpt    as handle no-undo.
    define variable vhNorlv    as handle no-undo.    
    define variable vhNoImm    as handle no-undo.    
    define buffer erlet for erlet.

    create query vhttquery.
    vhttBuffer = ghttErlet:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttErlet:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNorli, output vhTpcon, output vhNocon, output vhTpcpt, output vhNorlv, output vhNoImm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first erlet exclusive-lock
                where rowid(Erlet) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer erlet:handle, 'norli/mandat/type compteur/no relevé: ', substitute('&1/&2/&3/&4', vhNorli:buffer-value(), vhNocon:buffer-value(), vhTpcpt:buffer-value(), vhNorlv:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete erlet no-error.
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

procedure getNextNumeroReleveCompteur private:
    /*------------------------------------------------------------------------------
    Purpose: recherche prochain numero de relevé (erlet.norlv) pour un mandat et un type de compteur
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeCompteur  as character no-undo.
    define output parameter piNextNorli     as int64     no-undo.
    define output parameter piNextNorlv     as integer   no-undo initial 1.
    define buffer erlet for erlet.

    run getNextNumeroIdentifiantErlet(output piNextNorli).
    if piNextNorli <> ?
    then for last erlet no-lock          /* Récuperation du numero réel de la erlet  */
        where erlet.tpcon = pcTypeContrat
          and erlet.nocon = piNumeroContrat
          and erlet.tpcpt = pcTypeCompteur:
        piNextNorlv = erlet.norlv + 1.
    end.
end procedure.

procedure getNextNumeroIdentifiantErlet private:
    /*------------------------------------------------------------------------------
    Purpose: recherche prochain numero interne de relevé (erlet.norli)
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter piNextNorli     as int64     initial 1 no-undo.
    define buffer erlet for erlet.
    for last erlet no-lock:
        piNextNorli = erlet.norli + 1.
    end.
end procedure.

