/*---------------------------------------------------------------------------
File        : gestionSignataire.i
Purpose     : proc�dures et fonction et d�finitions pour la gestion des signataires
Author(s)   : PL  2009/07/24
Analyse     : 0109/0156
derniere revue: 2018/08/03 - phm: OK
*---------------------------------------------------------------------------*/

procedure donneSignataire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter  piNumeroSignataire as integer   no-undo.
    define input parameter  pcUtilisateur      as character no-undo.
    define output parameter pcCodeSignataire   as character no-undo.
    define output parameter piSignataire       as integer   no-undo.

    define buffer tutil for tutil.

    /* R�cup�ration du code signataire */
    for first tutil no-lock
        where tutil.ident_u = pcUtilisateur:
        pcCodeSignataire = if piNumeroSignataire = 1 then tutil.signataire1 else tutil.signataire2.
    end.
    /* R�cup�ration du numero de role si n�cessaire */
    if pcCodeSignataire > "" and pcCodeSignataire <> "?"
    then for first tutil no-lock
        where tutil.ident_u = pcCodeSignataire:
        piSignataire = tutil.norol.
    end.

end procedure.
