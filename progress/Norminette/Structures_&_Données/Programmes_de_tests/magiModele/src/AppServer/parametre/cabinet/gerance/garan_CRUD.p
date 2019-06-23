/*------------------------------------------------------------------------
File        : garan_CRUD.p
Purpose     :
Author(s)   : RF
Notes       : Mise à jour des assurances garantie tous type sauf garantie spéciale
              + test communs
              Garantie Loyer            01007
              Garantie Risque Locatif   01013
              Protection Juridique      01017
              Propriétaire Non Occupant 01018
              Vacance Locative          01087
derniere revue: 2018/04/24 - phm: KO
SPo le 2018/04/25 : programme renommé  : garantie.p -> garan_CRUD.p et fonctions déplacées dans outilGarantieLoyer.p
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bareme.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gerance/include/garantie.i}


function crudGarantie returns logical private():
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------------------*/
    run deleteGarantiePrivate.
    run updateGarantiePrivate.
    run createGarantiePrivate.
end function.

procedure setGarantie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (appel depuis les differents pgms de maintenance garan)
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttGarantie.
    crudGarantie().
end procedure.

procedure majGarantie_ModeComptabilisation:
    /*------------------------------------------------------------------------------
    Purpose: Procédure spécifique de répercussion du mode de comptabilisation sur les autres garanties de même type
    Notes  : appelé par la mise à jour dans chaque programme de garantie (protectionJuridique.p,...)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeGarantie          as character no-undo.
    define input parameter pcModeComptabilisation  as character no-undo.
    define input parameter piNumeroAssuranceModele as integer   no-undo.

    define buffer garan for garan.

    for each garan exclusive-lock
        where garan.tpctt = pcTypeGarantie
          and garan.noctt <> piNumeroAssuranceModele
          and garan.tpbar = ""
          and garan.lbdiv2 <> pcModeComptabilisation:
        assign
            garan.lbdiv2 = pcModeComptabilisation
            garan.dtmsy  = today
            garan.hemsy  = mtime
            garan.cdmsy  = mToken:cUser
        .
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.

procedure deleteGarantiePrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.

bloc:
    do transaction:
        for each ttGarantie where ttGarantie.CRUD = "D":
            find first garan exclusive-lock
                 where rowid(garan) = ttGarantie.rRowid no-wait no-error.
            if (garan.tpbar = ""
            and outils:isUpdated(buffer garan:handle, 'Type garantie/no garantie/type barème/no barème: ', substitute('&1/&2/&3/&4', ttGarantie.tpctt, string(ttGarantie.noctt), ttGarantie.tpbar, string(ttGarantie.nobar) ), ttGarantie.dtTimestamp))
            then undo bloc, leave bloc.

            delete garan no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo bloc, leave bloc.
            end.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.

procedure updateGarantiePrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.

bloc:
    do transaction:
        for each ttGarantie where ttGarantie.CRUD = "U":
            find first garan exclusive-lock
                where rowid(garan) = ttGarantie.rRowid no-wait no-error.
            if outils:isUpdated(buffer garan:handle, 'garan/no garantie/type barème/no barème: ', substitute('&1/&2/&3/&4', ttGarantie.tpctt, ttGarantie.noctt, ttGarantie.tpbar, ttGarantie.nobar), ttGarantie.dtTimestamp)
            or not outils:copyValidField(buffer garan:handle, buffer ttGarantie:handle, 'U', mtoken:cUser) 
            then undo bloc, leave bloc.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.

procedure createGarantiePrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.

    bloc:
    do transaction:
        for each ttGarantie where ttGarantie.CRUD = "C":
            create garan.
            if not outils:copyValidField(buffer garan:handle, buffer ttGarantie:handle, 'U', mtoken:cUser)
            then undo bloc, leave bloc.
        end.
    end.

end procedure.
