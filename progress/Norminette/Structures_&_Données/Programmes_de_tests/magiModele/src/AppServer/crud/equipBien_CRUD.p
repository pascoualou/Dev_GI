/*-----------------------------------------------------------------------------
File        : equipBien_CRUD.p
Purpose     :
Author(s)   : Kantena  -  2016/12/12
Notes       :
derniere revue: 2018/09/07 - phm: KO
    todo créer une procédure crudEquipBien
-----------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/equipementBien.i}

procedure setEquipBien:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour Base de données. TODO : Que fait-on des fichiers joints ?
    Notes  : service beImmeuble.cls et beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttEquipementBien.
    define input parameter table for ttFichierJointEquipement.

    run deleteEquipementBien.
    run updateEquipementBien.
    run createEquipementBien.

end procedure.

procedure deleteEquipementBien private:
    /*------------------------------------------------------------------------------
    Purpose: suppression d'equipements
    Notes:
   ------------------------------------------------------------------------------*/
    define buffer equipBien   for equipBien.

blocTransaction:
    do transaction:
        for each ttEquipementBien
           where ttEquipementBien.crud = 'D':
            find first equipBien exclusive-lock
                where rowid(equipBien) = ttEquipementBien.rRowid no-wait no-error.
            if outils:isUpdated(buffer equipBien:handle, 'Equipbien',
                                substitute('&1/&2/&3',ttEquipementBien.cTypeBien, ttEquipementBien.iNumeroBien, ttEquipementBien.cCodeEquipement),
                                ttEquipementBien.dtTimestamp)
            then undo blocTransaction, leave blocTransaction.
            delete equipBien no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
        end.
    end.
end procedure.

procedure createEquipementBien private:
    /*------------------------------------------------------------------------------
    Purpose: creation d'equipements
    Notes:
   ------------------------------------------------------------------------------*/
    define buffer equipBien   for equipBien.

blocTransaction:
    do transaction:
        for each ttEquipementBien
           where ttEquipementBien.crud = 'C':
            create equipBien.
            assign
                equipBien.cTypeBien       = ttEquipementBien.cTypeBien
                equipBien.iNumeroBien     = ttEquipementBien.iNumeroBien
                equipBien.cCodeEquipement = ttEquipementBien.cCodeEquipement
                equipBien.fgOuiNon        = true
            no-error.
            if error-status:error
            then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
            if not outils:copyValidField(buffer equipBien:handle, buffer ttEquipementBien:handle, 'C', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
        end.
    end.
end procedure.

procedure updateEquipementBien private:
    /*------------------------------------------------------------------------------
    Purpose: modification d'equipements
    Notes:
   ------------------------------------------------------------------------------*/
    define buffer equipBien   for equipBien.

blocTransaction:
    do transaction:
        for each ttEquipementBien
            where ttEquipementBien.crud = 'U':
            find first equipBien exclusive-lock where rowid(equipBien) = ttEquipementBien.rRowid no-wait no-error.
            if error-status:error
            then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
            if not outils:copyValidField(buffer equipBien:handle, buffer ttEquipementBien:handle, 'U', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
        end.
    end.
end procedure.


