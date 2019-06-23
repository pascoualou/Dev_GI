/*------------------------------------------------------------------------
File        : rubqt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rubqt
Author(s)   : generation automatique le 01/29/18
              reprise et complément de adb/src/lib/l_rubqt_ext.p
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/08/16 - phm: 
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttrubqt as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phCdrub as handle, output phCdlib as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des 2 champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when "cdrub" then phCdrub = phBuffer:buffer-field(vi).
            when "cdlib" then phCdlib = phBuffer:buffer-field(vi).
        end case.
    end.
end function.

procedure crudRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRubqt.
    run updateRubqt.
    run createRubqt.
end procedure.

procedure setRubqt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe - A appeler avec by-reference.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRubqt.
    ghttRubqt = phttRubqt.
    run crudRubqt.
    delete object phttRubqt.
end procedure.

procedure readRubqt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rubqt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdrub as integer  no-undo.
    define input parameter piCdlib as integer  no-undo.
    define input parameter table-handle phttRubqt.

    define variable vhttBuffer as handle no-undo.
    define buffer rubqt for rubqt.

    vhttBuffer = phttRubqt:default-buffer-handle.
    for first rubqt no-lock
        where rubqt.cdrub = piCdrub
          and rubqt.cdlib = piCdlib:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubqt:handle, vhttBuffer).  // copy table physique vers temp-table
        vhttBuffer::iNumeroReleve = 1 no-error.                  // par défaut, si défini, iNumeroReleve = 1
    end.
    delete object phttRubqt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRubqt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rubqt
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
             A appeler avec by-reference.
    ------------------------------------------------------------------------------*/
    define input parameter piCdrub as integer no-undo.
    define input parameter table-handle phttRubqt.

    define variable vhttBuffer as handle  no-undo.
    define buffer rubqt for rubqt.

    vhttBuffer = phttRubqt:default-buffer-handle.
    if piCdrub = ?
    then for each rubqt no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubqt:handle, vhttBuffer).  // copy table physique vers temp-table
        vhttBuffer::iNumeroReleve = 1 no-error.                  // par défaut, si défini, iNumeroReleve = 1
    end.
    else for each rubqt no-lock
        where rubqt.cdrub = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rubqt:handle, vhttBuffer).  // copy table physique vers temp-table
        vhttBuffer::iNumeroReleve = 1 no-error.                  // par défaut, si défini, iNumeroReleve = 1
    end.
    delete object phttRubqt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getReleveRubqt:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour du champ iNumeroReleve.
    Notes  : service externe. - A appeler avec by-reference.
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.
    define input parameter table-handle phttRubqt.

    define variable vhttBuffer   as handle  no-undo.
    define variable vhQuery      as handle  no-undo.
    define variable vi           as integer no-undo.
    define variable vhFieldCdrub as handle  no-undo.  // si la temp-table est définie avec des labels pour mapper les champs
    define variable vhFieldCdlib as handle  no-undo.  // si la temp-table est définie avec des labels pour mapper les champs
    define variable vhFieldCdfam as handle  no-undo.  // si la temp-table est définie avec des labels pour mapper les champs
    define variable vhFieldCdsfa as handle  no-undo.  // si la temp-table est définie avec des labels pour mapper les champs
    define buffer pclie for pclie.

    run getRubqt(?, table-handle phttRubqt by-reference).
    vhttBuffer = phttRubqt:default-buffer-handle.
    create query vhQuery.
    vhQuery:set-buffers(vhttBuffer).
    do vi = 1 to vhttBuffer:num-fields:
        case vhttBuffer:buffer-field(vi):label:
            when "cdrub" then vhFieldCdrub = vhttBuffer:buffer-field(vi).
            when "cdlib" then vhFieldCdlib = vhttBuffer:buffer-field(vi).
            when "cdfam" then vhFieldCdfam = vhttBuffer:buffer-field(vi).
            when "cdsfa" then vhFieldCdsfa = vhttBuffer:buffer-field(vi).
        end case.
    end.
    if not valid-handle(vhFieldCdrub) or not valid-handle(vhFieldCdlib)
    or not valid-handle(vhFieldCdfam) or not valid-handle(vhFieldCdsfa) then return.

    /*On balaie la table des exceptions afin d'avoir la bonne affectation pour chaque rubrique*/
    for each pclie no-lock
        where pclie.tppar = "RBCRG" 
          and pclie.zon01 = "QTT"
          and pclie.zon10 = string(piNumeroMandat):
        vhQuery:query-prepare(substitute("for each &1 where &1.&2 = &3", vhttBuffer:name, vhFieldCdfam:name, pclie.int01)).
        vhQuery:query-open().
        repeat:
            vhQuery:get-next().
            if vhQUery:query-off-end then leave.

            if  (pclie.int02 = 0  or pclie.int02 = vhFieldCdsfa:buffer-value())
            and (pclie.zon02 = "" or integer(pclie.zon02) = vhFieldCdrub:buffer-value())
            and (pclie.zon03 = "" or integer(pclie.zon03) = vhFieldCdlib:buffer-value())
            then vhttBuffer::iNumeroReleve = pclie.int03.
        end.
        vhQuery:query-close().
    end.
    delete object vhQuery.
    delete object phttRubqt.
end procedure.

procedure getRubriqueEncaissement:
    /*--------------------------------------------------------------------------- 
    Purpose : Chargement de la liste des rubriques de quittancement entrant dans le calcul du montant encaissé
    Notes   :
    ---------------------------------------------------------------------------*/ 
    define output parameter pcRubriqueLoyer   as character no-undo.
    define output parameter pcRubriqueCharges as character no-undo.
    define output parameter pcRubriqueTOM     as character no-undo.
    define output parameter pcRubriqueTVA     as character no-undo.
    define buffer rubqt for rubqt.

    for each rubqt no-lock
        where rubqt.cdlib = 0
// whole-index corrige par la creation dans la version d'un index sur cdlib            
        by rubqt.cdrub:
        /* Loyer = famille 01  ... */
        if rubqt.cdfam = 01
        then pcRubriqueLoyer = pcRubriqueLoyer + "," + string(rubqt.cdrub, "999").
        /* Charges = famille 02 ... */
        if rubqt.cdfam = 02
        then pcRubriqueCharges = pcRubriqueCharges + "," + string(rubqt.cdrub, "999").
        /* TOM = rub 701 & 721... */
        if rubqt.cdrub = 701 or rubqt.cdrub = 721
        then pcRubriqueTOM = pcRubriqueTOM + "," + string(rubqt.cdrub, "999").
        /* TVA = 05 ssfam 02 et genre calculé ... */
        if rubqt.cdfam = 05 and rubqt.cdsfa = 02 and rubqt.cdgen = "00004"
        then pcRubriqueTVA = pcRubriqueTVA + "," + string(rubqt.cdrub, "999").
    end.
    assign
        pcRubriqueLoyer   = trim(pcRubriqueLoyer, ",")
        pcRubriqueCharges = trim(pcRubriqueCharges, ",")
        pcRubriqueTOM     = trim(pcRubriqueTOM, ",")
        pcRubriqueTVA     = trim(pcRubriqueTVA, ",")
    .
end procedure.

procedure updateRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrub as handle no-undo.
    define variable vhCdlib as handle no-undo.
    define buffer rubqt for rubqt.

    create query vhttquery.
    vhttBuffer = ghttRubqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRubqt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubqt exclusive-lock
                where rowid(rubqt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubqt:handle, 'cdrub/cdlib: ', substitute("&1/&2", vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rubqt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rubqt for rubqt.

    create query vhttquery.
    vhttBuffer = ghttRubqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRubqt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rubqt.
            if not outils:copyValidField(buffer rubqt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRubqt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdrub    as handle   no-undo.
    define variable vhCdlib    as handle   no-undo.
    define buffer rubqt for rubqt.

    create query vhttquery.
    vhttBuffer = ghttRubqt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRubqt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdrub, output vhCdlib).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rubqt exclusive-lock
                where rowid(Rubqt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rubqt:handle, 'cdrub/cdlib: ', substitute("&1/&2", vhCdrub:buffer-value(), vhCdlib:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rubqt no-error.
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

