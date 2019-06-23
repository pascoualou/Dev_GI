/*------------------------------------------------------------------------
File        : cecrlnana_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cecrlnana
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/08/09 - phm: OK
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i}        // Doit être positionnée juste après using
{compta/include/fctLibelleAnalytique.i}            // fonction contientChampsAnalytique, getLibelleRubrique, getLibelleSousRubrique, getLibelleFiscal, getLibelleCle
{compta/include/fctLibelleCompte.i}                // fonction contientChampsCompte, getLibelleCompte, decoupeCompte
{compta/include/fctDebitCredit.i}                  // fonction contientChampsDebitCredit
define variable ghttcecrlnana as handle no-undo.   // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-int as handle, output phLig as handle, output phPos as handle, output phAna-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd, 
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
            when 'pos'       then phPos       = phBuffer:buffer-field(vi).
            when 'ana-cd'    then phAna-cd    = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCecrlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCecrlnana.
    run updateCecrlnana.
    run createCecrlnana.
end procedure.

procedure setCecrlnana:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCecrlnana.
    ghttCecrlnana = phttCecrlnana.
    run crudCecrlnana.
    delete object phttCecrlnana.
end procedure.

procedure readCecrlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cecrlnana Fichier des lignes d'ecritures analytiques
    Notes  : service externe
             lecture unqiue, pas "d'optimisation" ContientChampsDebitCredit.
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcJou-cd    as character  no-undo.
    define input parameter piPrd-cd    as integer    no-undo.
    define input parameter piPrd-num   as integer    no-undo.
    define input parameter piPiece-int as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter piPos       as integer    no-undo.
    define input parameter pcAna-cd    as character  no-undo.
    define input parameter table-handle phttCecrlnana.
    define variable vhttBuffer as handle no-undo.
    define buffer cecrlnana for cecrlnana.

    vhttBuffer = phttCecrlnana:default-buffer-handle.
    for first cecrlnana no-lock
        where cecrlnana.soc-cd    = piSoc-cd
          and cecrlnana.etab-cd   = piEtab-cd
          and cecrlnana.jou-cd    = pcJou-cd
          and cecrlnana.prd-cd    = piPrd-cd
          and cecrlnana.prd-num   = piPrd-num
          and cecrlnana.piece-int = piPiece-int
          and cecrlnana.lig       = piLig
          and cecrlnana.pos       = piPos
          and cecrlnana.ana-cd    = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrlnana:handle, vhttBuffer).  // copy table physique vers temp-table
        run decoupeCompte(vhttBuffer) no-error.
        run getLibelleAnalytique(vhttBuffer) no-error.
        assign vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer) no-error.
        if vhttBuffer::lDebit
        then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant no-error.
        else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant no-error.
    end.
    delete object phttCecrlnana no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCecrlnana:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cecrlnana Fichier des lignes d'ecritures analytiques
    Notes  : service externe. Critère piPos = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer   no-undo.
    define input parameter piEtab-cd   as integer   no-undo.
    define input parameter pcJou-cd    as character no-undo.
    define input parameter piPrd-cd    as integer   no-undo.
    define input parameter piPrd-num   as integer   no-undo.
    define input parameter piPiece-int as integer   no-undo.
    define input parameter piLig       as integer   no-undo.
    define input parameter piPos       as integer   no-undo.
    define input parameter table-handle phttCecrlnana.
    
    define variable vhttBuffer                  as handle  no-undo.
    define variable vlContientChampsCompte      as logical no-undo.
    define variable vlContientChampsAnalytique  as logical no-undo.
    define variable vlContientChampsDebitCredit as logical no-undo.
    define buffer cecrlnana for cecrlnana.

    assign
        vhttBuffer                  = phttCecrlnana:default-buffer-handle
        vlContientChampsCompte      = contientChampsCompte(vhttBuffer)
        vlContientChampsAnalytique  = contientChampsAnalytique(vhttBuffer)
        vlContientChampsDebitCredit = contientChampsDebitCredit(vhttBuffer)
    .
    if piLig = ? and piPos = ? and piPiece-int = ?
    then for each cecrlnana no-lock
        where cecrlnana.soc-cd   = piSoc-cd
          and cecrlnana.etab-cd  = piEtab-cd
          and cecrlnana.jou-cd   = pcJou-cd
          and cecrlnana.prd-cd   = piPrd-cd
          and cecrlnana.prd-num  = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrlnana:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsCompte then do:
            run decoupeCompte (vhttBuffer).
            vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer).
        end.
        if vlContientChampsAnalytique then run getLibelleAnalytique (vhttBuffer).
        if vlContientChampsDebitCredit then do:
           if vhttBuffer::lDebit
           then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant.
           else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant.
       end.
    end.
    else if piLig = ? and piPos = ?
    then for each cecrlnana no-lock
        where cecrlnana.soc-cd    = piSoc-cd
          and cecrlnana.etab-cd   = piEtab-cd
          and cecrlnana.jou-cd    = pcJou-cd
          and cecrlnana.prd-cd    = piPrd-cd
          and cecrlnana.prd-num   = piPrd-num
          and cecrlnana.piece-int = piPiece-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrlnana:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsCompte then do:
            run decoupeCompte (vhttBuffer).
            vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer).
        end.
        if vlContientChampsAnalytique then run getLibelleAnalytique (vhttBuffer).
        if vlContientChampsDebitCredit then do:
            if vhttBuffer::lDebit
            then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant.
            else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant.
        end.
    end.
    else if piPos = ?
    then for each cecrlnana no-lock
        where cecrlnana.soc-cd = piSoc-cd
          and cecrlnana.etab-cd = piEtab-cd
          and cecrlnana.jou-cd = pcJou-cd
          and cecrlnana.prd-cd = piPrd-cd
          and cecrlnana.prd-num = piPrd-num
          and cecrlnana.piece-int = piPiece-int
          and cecrlnana.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrlnana:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsCompte then do:
            run decoupeCompte (vhttBuffer).
            vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer).
        end.
        if vlContientChampsAnalytique then run getLibelleAnalytique (vhttBuffer).
        if vlContientChampsDebitCredit then do:
            if vhttBuffer::lDebit
            then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant.
            else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant.
        end.
    end.
    else for each cecrlnana no-lock
        where cecrlnana.soc-cd = piSoc-cd
          and cecrlnana.etab-cd = piEtab-cd
          and cecrlnana.jou-cd = pcJou-cd
          and cecrlnana.prd-cd = piPrd-cd
          and cecrlnana.prd-num = piPrd-num
          and cecrlnana.piece-int = piPiece-int
          and cecrlnana.lig = piLig
          and cecrlnana.pos = piPos:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrlnana:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsCompte then do:
            run decoupeCompte (vhttBuffer).
            vhttBuffer::cLibelleCompte = getLibelleCompte(vhttBuffer).
        end.
        if vlContientChampsAnalytique then run getLibelleAnalytique (vhttBuffer).
        if vlContientChampsDebitCredit then do:
            if vhttBuffer::lDebit
            then assign vhttBuffer::dMontantDebit  = vhttBuffer::dMontant.
            else assign vhttBuffer::dMontantCredit = vhttBuffer::dMontant.
        end.
    end.
    delete object phttCecrlnana no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCecrlnana private:
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
    define variable vhPos       as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer cecrlnana for cecrlnana.

    create query vhttquery.
    vhttBuffer = ghttCecrlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCecrlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrlnana exclusive-lock
                where rowid(cecrlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrlnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cecrlnana:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCecrlnana private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cecrlnana for cecrlnana.

    create query vhttquery.
    vhttBuffer = ghttCecrlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCecrlnana:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cecrlnana.
            if not outils:copyValidField(buffer cecrlnana:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCecrlnana private:
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
    define variable vhPos       as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer cecrlnana for cecrlnana.

    create query vhttquery.
    vhttBuffer = ghttCecrlnana:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCecrlnana:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-int, output vhLig, output vhPos, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrlnana exclusive-lock
                where rowid(Cecrlnana) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrlnana:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-int/lig/pos/ana-cd: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-int:buffer-value(), vhLig:buffer-value(), vhPos:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cecrlnana no-error.
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
