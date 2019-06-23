/*------------------------------------------------------------------------
File        : cecrln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cecrln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/08/09 - phm: OK
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i}        // Doit être positionnée juste après using
{compta/include/fctLibelleCompte.i}                // fonction contientChampsCompte, getLibelleCompte, decoupeCompte
{compta/include/fctDebitCredit.i}                  // fonction contientChampsDebitCredit
define variable ghttcecrln as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'    then phSoc-cd    = phBuffer:buffer-field(vi).
            when 'etab-cd'   then phEtab-cd   = phBuffer:buffer-field(vi).
            when 'jou-cd'    then phJou-cd    = phBuffer:buffer-field(vi).
            when 'prd-cd'    then phPrd-cd    = phBuffer:buffer-field(vi).
            when 'prd-num'   then phPrd-num   = phBuffer:buffer-field(vi).
            when 'piece-int' then phPiece-int = phBuffer:buffer-field(vi).
            when 'lig'       then phLig       = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCecrln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCecrln.
    run updateCecrln.
    run createCecrln.
end procedure.

procedure setCecrln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCecrln.
    ghttCecrln = phttCecrln.
    run crudCecrln.
    delete object phttCecrln.
end procedure.

procedure readCecrln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cecrln Fichier des lignes d'ecritures
    Notes  : service externe
             lecture unqiue, pas "d'optimisation" ContientChampsDebitCredit.
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer   no-undo.
    define input parameter piEtab-cd   as integer   no-undo.
    define input parameter pcJou-cd    as character no-undo.
    define input parameter piPrd-cd    as integer   no-undo.
    define input parameter piPrd-num   as integer   no-undo.
    define input parameter piPiece-int as integer   no-undo.
    define input parameter piLig       as integer   no-undo.
    define input parameter table-handle phttCecrln.
    define variable vhttBuffer as handle no-undo.
    define buffer cecrln for cecrln.

    vhttBuffer = phttCecrln:default-buffer-handle.
    for first cecrln no-lock
        where cecrln.soc-cd    = piSoc-cd
          and cecrln.etab-cd   = piEtab-cd
          and cecrln.jou-cd    = pcJou-cd
          and cecrln.prd-cd    = piPrd-cd
          and cecrln.prd-num   = piPrd-num
          and cecrln.piece-int = piPiece-int
          and cecrln.lig       = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrln:handle, vhttBuffer).  // copy table physique vers temp-table
        run decoupeCompte(vhttBuffer) no-error.
        assign vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer) no-error.
        if vhttBuffer::lDebit
        then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant no-error.
        else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant no-error.
    end.
    delete object phttCecrln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCecrln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cecrln Fichier des lignes d'ecritures
    Notes  : service externe. Critère piPiece-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer   no-undo.
    define input parameter piEtab-cd   as integer   no-undo.
    define input parameter pcJou-cd    as character no-undo.
    define input parameter piPrd-cd    as integer   no-undo.
    define input parameter piPrd-num   as integer   no-undo.
    define input parameter piPiece-int as integer   no-undo.
    define input parameter table-handle phttCecrln.
    define variable vhttBuffer                  as handle  no-undo.
    define variable vlContientChampsCompte      as logical no-undo.
    define variable vlContientChampsDebitCredit as logical no-undo.

    define buffer cecrln for cecrln.

    assign 
        vhttBuffer                  = phttCecrln:default-buffer-handle
        vlContientChampsCompte      = contientChampsCompte(vhttBuffer)
        vlContientChampsDebitCredit = contientChampsDebitCredit(vhttBuffer)
    .
    if piPiece-int = ?
    then for each cecrln no-lock
        where cecrln.soc-cd  = piSoc-cd
          and cecrln.etab-cd = piEtab-cd
          and cecrln.jou-cd  = pcJou-cd
          and cecrln.prd-cd  = piPrd-cd
          and cecrln.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrln:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsCompte then do:
            run decoupeCompte (vhttBuffer).
            vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer).
        end.
        if vlContientChampsDebitCredit then do:
            if vhttBuffer::lDebit
            then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant.
            else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant.
        end.
    end.
    else for each cecrln no-lock
        where cecrln.soc-cd    = piSoc-cd
          and cecrln.etab-cd   = piEtab-cd
          and cecrln.jou-cd    = pcJou-cd
          and cecrln.prd-cd    = piPrd-cd
          and cecrln.prd-num   = piPrd-num
          and cecrln.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrln:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsCompte then do:
            run decoupeCompte (vhttBuffer).
            vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer).
        end.
        if vlContientChampsDebitCredit then do:
            if vhttBuffer::lDebit
            then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant.
            else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant.
        end.
    end.
    delete object phttCecrln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCecrln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd   as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num   as handle  no-undo.
    define variable vhPiece-int as handle  no-undo.
    define variable vhLig       as handle  no-undo.
    define buffer cecrln for cecrln.

    create query vhttquery.
    vhttBuffer = ghttCecrln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCecrln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrln exclusive-lock
                where rowid(cecrln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrln:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cecrln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCecrln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cecrln for cecrln.

    create query vhttquery.
    vhttBuffer = ghttCecrln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCecrln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cecrln.
            if not outils:copyValidField(buffer cecrln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCecrln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhPrd-cd    as handle  no-undo.
    define variable vhPrd-num    as handle  no-undo.
    define variable vhPiece-int    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer cecrln for cecrln.

    create query vhttquery.
    vhttBuffer = ghttCecrln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCecrln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrln exclusive-lock
                where rowid(Cecrln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrln:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cecrln no-error.
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
