/*------------------------------------------------------------------------
File        : piece.p
Description :
Author(s)   : kantena - 2017/08/09
Notes       : 2017/11/16 - la combo designation a été mise dans labelladb.p
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/piece.i}
{application/include/error.i}

function crudPiece returns logical private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/

    run deletePiece.
    run updatePiece.
    run createPiece.
    mError:getErrors(output table ttError).
    return not can-find(first ttError where ttError.iType >= {&error}).

end function.

procedure updatePiece private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer piece for piece.

bloc:
    do transaction:
        for each ttPiece where ttPiece.CRUD = "U":
            find first piece exclusive-lock
                 where piece.noloc = ttPiece.iNumeroBien
                   and piece.nopie = ttPiece.iNumeroPiece no-wait no-error.
            if outils:isUpdated(buffer piece:handle, 'lot/piece: ', substitute('&1/&2', ttPiece.iNumeroBien, ttPiece.iNumeroPiece), ttPiece.dtTimestamp)
            or not outils:copyValidLabeledField(buffer piece:handle, buffer ttPiece:handle, 'U', mtoken:cUser)
            then undo bloc, leave bloc.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.

procedure createPiece private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer piece for piece.

bloc:
    do transaction:
        for each ttPiece where ttPiece.CRUD = "C" on error undo, leave:
            create piece.
            assign piece.noloc = ttPiece.iNumeroBien
                   piece.nopie = ttPiece.iNumeroPiece no-error.
            if error-status:error then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo bloc, leave bloc.
            end.
            if not outils:copyValidLabeledField(buffer piece:handle, buffer ttPiece:handle, 'C', mtoken:cUser)
            then undo bloc, leave bloc.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.

procedure deletePiece private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer piece for piece.

bloc:
    do transaction:
        for each ttPiece where ttPiece.CRUD = "D":
            find first piece exclusive-lock
                 where piece.noloc = ttPiece.iNumeroBien
                   and piece.nopie = ttPiece.iNumeroPiece no-wait no-error.
            if outils:isUpdated(buffer piece:handle, 'lot/piece: ', substitute('&1/&2', ttPiece.iNumeroBien, ttPiece.iNumeroPiece), ttPiece.dtTimestamp)
            then undo bloc, leave bloc.

            delete piece no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo bloc, leave bloc.
            end.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.


procedure getPiece:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie les informations des pieces d'un lot
    Notes  : service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLoc as int64   no-undo.
    define output parameter table for ttPiece.

    define buffer piece for piece.

    for each piece no-lock
        where piece.noloc = piNumeroLoc:
        create ttPiece.
        assign
            ttPiece.CRUD           = 'R'
            ttPiece.iNumeroBien    = piece.noloc
            ttPiece.iNumeroPiece   = piece.nopie
            ttPiece.iNumeroBloc    = piece.noblc
            ttPiece.cCodeNature    = piece.ntpie
            ttPiece.cLibelleNature = outilTraduction:getLibelleParam("NTPIE", piece.ntpie)
            ttPiece.cNiveau        = piece.cdniv
            ttPiece.cCodeUnite     = piece.uspie
//          ttPiece.cLibelleUnite  = outilTraduction:getLibelleParam("UTPIE", piece.uspie)
            ttPiece.dValeur        = piece.sfpie
            ttPiece.dtTimestamp    = datetime(piece.dtmsy, piece.hemsy)
            ttPiece.rRowid         = rowid(piece)
        .
        /*
        assign
            vcTempAdresse   = if piece.sfpie <> 0
                         then substitute(" (&1 &2)", VALMONTANT(piece.sfpie, false), LIBPR("UTPIE", piece.uspie)).
                         else ""
            ListePiece = substitute('&1&2&3', ListePiece, DonneLibelleDesignation(piece.ntpie), vcTempAdresse)
            vcTempAdresse   = if piece.cdniv <> "1"
                         then substitute(" (&1 : &2)", LIB(100045), piece.cdniv)
                         else ""
            ListePiece = substitute('&1&2&3', ListePiece, vcTempAdresse, if last(piece.noloc) then "." else ", ")
        .
        */
    end.

end procedure.

procedure setPiece:
    /*------------------------------------------------------------------------------
    Purpose: MAJ des informations des pieces d'un lot
    Notes  : service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttPiece.

    for each ttPiece:
        ttPiece.cCodeUnite = "00001". // On force le code unité à M²
    end.
    crudPiece().

end procedure.

