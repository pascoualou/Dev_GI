/*------------------------------------------------------------------------
File        : equipementBien.p
Purpose     :
Author(s)   : Kantena  -  2016/12/12
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/equipementBien.i}

procedure setEquipementBien:
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
            if not outils:copyValidLabeledField(buffer equipBien:handle, buffer ttEquipementBien:handle, 'C', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
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
            if not outils:copyValidLabeledField(buffer equipBien:handle, buffer ttEquipementBien:handle, 'U', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
        end.
    end.
end procedure.

procedure getTypeEquipementImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie les types d'equipements pour les immeubles
    Notes  : Service appelé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttEquipement.
    define buffer equipements for equipements.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for each Equipements no-lock
       where equipements.fgImmeuble:
        create ttEquipement.
        assign
            ttEquipement.cCodeEquipement        = Equipements.cCodeEquipement
            ttEquipement.cDesignationEquipement = Equipements.cDesignation
            ttEquipement.lValeur                = equipements.fgValeur
            ttEquipement.lOuiNon                = equipements.fgOuiNon
            ttEquipement.lNombre                = Equipements.fgNombre
            ttEquipement.cListeValeur           = equipements.cListeValeurs
            ttEquipement.dtTimestamp            = datetime(equipements.dtmsy, equipements.hemsy)
            ttEquipement.CRUD                   = "R"
            ttEquipement.rRowid                 = rowid(equipements)
        .
    end.
end procedure.

procedure getTypeEquipementLot:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie les types d'equipements pour les lots
    Notes  : Service appelé par beLot.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttEquipement.
    define buffer equipements for equipements.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for each Equipements no-lock
       where equipements.fgLot:
        create ttEquipement.
        assign
            ttEquipement.cCodeEquipement        = Equipements.cCodeEquipement
            ttEquipement.cDesignationEquipement = Equipements.cDesignation
            ttEquipement.lValeur                = equipements.fgValeur
            ttEquipement.lOuiNon                = equipements.fgOuiNon
            ttEquipement.lNombre                = Equipements.fgNombre
            ttEquipement.cListeValeur           = equipements.cListeValeurs
            ttEquipement.dtTimestamp            = datetime(equipements.dtmsy, equipements.hemsy)
            ttEquipement.CRUD                   = "R"
            ttEquipement.rRowid                 = rowid(equipements)
        .
    end.
end procedure.

procedure getEquipementBien:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Service appelé par batiment.p, immeuble.p, lot.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroBien as integer no-undo.
    define input parameter pcTypeBien as character no-undo.
    define output parameter table for ttEquipementBien.
    define output parameter table for ttFichierJointEquipement.

    define variable viDummy   as integer   no-undo.
    define variable vcTypeIdt as character no-undo.
    define buffer EquipBien   for EquipBien.
    define buffer Equipements for Equipements.
    define buffer tbfic       for tbfic.
    define buffer ifour       for ifour.
    define buffer ccptcol     for ccptcol.
    define buffer ctrat       for ctrat.

    for each equipBien no-lock
        where equipBien.cTypeBien   = pcTypeBien
          and equipBien.iNumeroBien = piNumeroBien
      , first equipements no-lock
        where equipements.cCodeEquipement = equipBien.cCodeEquipement:
        create ttEquipementBien.
        assign
            viDummy                                    = 0     // réinitialise iDummy dans le cas assign ... error.
            ttEquipementBien.CRUD                      = 'R'
            ttEquipementBien.cCodeEquipement           = equipBien.cCodeEquipement
            ttEquipementBien.iNumeroBien               = piNumeroBien
            ttEquipementBien.cTypeBien                 = pcTypeBien
            ttEquipementBien.iNombreEquipement         = equipBien.iNombre
            ttEquipementBien.cValeur                   = equipBien.cValeur
//            ttEquipementBien.lYenA                     = equipBien.fgOuiNon
            ttEquipementBien.iNumeroOrdre              = integer(equipements.lbdiv2)
            ttEquipementBien.cDesignationEquipement    = equipements.cDesignation
//            ttEquipementBien.cListeValeur              = equipements.cListeValeurs
            ttEquipementBien.cNumeroContratMaintenance = equipBien.cContratMaintenance
            ttEquipementBien.cNumeroCompteFournisseur  = equipBien.cEntreprise
            ttEquipementBien.cCommentaire              = equipBien.cCommentaire
            ttEquipementBien.dtTimestamp               = datetime(equipBien.dtmsy, equipBien.hemsy)
            ttEquipementBien.rRowid                    = rowid(equipBien)
            viDummy                                    = integer(equipBien.cContratMaintenance)
        no-error.
        /* contrat fournisseur */
        if viDummy > 0
        then for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-fournisseur}
              and ctrat.nocon = viDummy:
            ttEquipementBien.cRefContratMaintenance = ctrat.noree.
        end.
        /* nom fournisseur */
        for first ccptcol no-lock                            // Recherche du regroupement fournisseur
            where ccptcol.soc-cd = integer(mtoken:cRefCopro)
              and ccptcol.tprole = 12
          , first ifour no-lock
            where ifour.soc-cd   = integer(mtoken:cRefCopro)
              and ifour.coll-cle = ccptcol.coll-cle
              and ifour.cpt-cd   = EquipBien.cEntreprise:
            ttEquipementBien.cNomFournisseur = ifour.nom.
        end.
        vcTypeIdt = if pcTypeBien = {&TYPEBIEN-lot}
                    then substitute("EQUIPLOT&1", string(piNumeroBien, "9999999999"))
                    else if pcTypeBien = {&TYPEBIEN-immeuble}
                         then substitute("EQUIPIMM&1", string(piNumeroBien, "9999"))
                         else if pcTypeBien = {&TYPEBIEN-batiment}
                              then substitute("EQUIPBAT&1", string(piNumeroBien, "9999"))
                              else ''.
        for each tbfic no-lock      /*--> Fichiers joints equipement lot, immeuble ou bâtiment */
            where tbfic.tpidt = vcTypeIdt
              and tbfic.noidt = integer(equipBien.cCodeEquipement):
            create ttFichierJointEquipement.
            assign
                ttFichierJointEquipement.CRUD             = 'R'
                ttFichierJointEquipement.cTypeBien        = pcTypeBien
                ttFichierJointEquipement.iNumeroBien      = piNumeroBien
                ttFichierJointEquipement.cNomFichier      = tbfic.LbFic
                ttFichierJointEquipement.cCodeEquipement  = equipBien.cCodeEquipement
                ttFichierJointEquipement.cTypeIdentifiant = tbfic.tpidt
                ttFichierJointEquipement.cCommentaire     = tbfic.LbCom
                ttFichierJointEquipement.daDateDebut      = tbfic.dadeb
                ttFichierJointEquipement.daDateFin        = tbfic.dafin
                ttFichierJointEquipement.dtTimestamp      = datetime(tbfic.dtmsy, tbfic.hemsy)
                ttFichierJointEquipement.rRowid           = rowid(tbfic)
            .
        end.
    end.

end procedure.
