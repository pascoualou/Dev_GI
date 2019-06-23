/*-----------------------------------------------------------------------------
File        : fctequip.i
Description : Formatage Equipement Immeuble et Lot (immeuble.p,lot.p...)
Author(s)   : SY - 2010/05/12, KANTENA - 2018/02/26
Notes       : Dossier analyse: EquipementBienLotV04.doc, Fiche: 1008/0150
-----------------------------------------------------------------------------*/

function FrmEquipement return character(piNumeroImmeuble as integer):
    /*------------------------------------------------------------------------------
    Purpose: Formatage de la zone equipement collectif
    Notes:
    todo : I18N - utiliser les traductions pour ascenceur (soutilTraduction:getLibelle).
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define buffer imble       for imble.
    define buffer equipBien   for equipBien.
    define buffer equipements for equipements.

    for first imble no-lock
        where imble.noimm = piNumeroImmeuble:
        find first equipBien no-lock
            where equipBien.cTypeBien = {&TYPEBIEN-immeuble}
              and equipBien.iNumeroBien = piNumeroImmeuble no-error.
        {&_proparse_ prolint-nowarn(sortaccess)}
        if available equipBien
        then for each equipBien no-lock
            where equipBien.cTypeBien = {&TYPEBIEN-immeuble}
              and equipBien.iNumeroBien = piNumeroImmeuble
          , first equipements no-lock
            where equipements.cCodeEquipement = equipBien.cCodeEquipement
            by integer(equipements.lbdiv2) by equipements.cCodeEquipement:
            vcRetour = vcRetour + ", " + equipements.cDesignation.
        end.
        else do:
            if imble.nblog <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(700500). // Loge
            if imble.nbasc <> 0 then vcRetour = vcRetour + ", Ascenseur".                             // Ascenseur
            if imble.nbmch <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(102227). // Monte-Charges
            if imble.nbext <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(102228). // Extincteurs
            if imble.nbant <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(102229). // antennes collectives
            if imble.nbint <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(102230). // Interphones
            if imble.nbfer <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(102231). // Fermetures Codees
            if imble.nbvid <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(102235). // Vide Ordure
        end. 
        if imble.sfvet <> 0 then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(108586).      // Espaces Verts
        vcRetour = trim(vcRetour, ", ").
    end.
    if vcRetour = "" or vcRetour = ? then vcRetour = outilTraduction:getLibelle(102281).
    return vcRetour.
end function.

function FrmEquipementLot returns character(piNumeroLocal as integer):
    /*------------------------------------------------------------------------------
    Purpose: Formatage de la zone equipement collectif
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define buffer local       for local.
    define buffer equipements for equipements.
    define buffer equipBien   for equipBien.

    for first local no-lock
        where local.noloc = piNumeroLocal:
        find first equipBien no-lock
            where equipBien.cTypeBien   = {&TYPEBIEN-lot}
              and equipBien.iNumeroBien = piNumeroLocal no-error.
        {&_proparse_ prolint-nowarn(sortaccess)}
        if available equipBien
        then for each equipBien no-lock
            where equipBien.cTypeBien   = {&TYPEBIEN-lot}
              and equipBien.iNumeroBien = piNumeroLocal
          , first equipements no-lock
            where equipements.cCodeEquipement = equipBien.cCodeEquipement
            by integer(equipements.lbdiv2) by equipements.cCodeEquipement:
            vcRetour = vcRetour + ", " + equipements.cDesignation.
        end.
        else do: /* Equipement Individuel */
            if local.fgcha then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(101370). // Eau Chaude
            if local.fgfra then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(101371). // Eau Froide
            if local.fgair then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(100452). // Air Conditionne
            if local.fgmbl then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(100454). // Meuble
            if local.fgwci then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(103169). // WC
        end.
        vcRetour = trim(vcRetour, ", ").
    end.
    if vcRetour = "" or vcRetour = ? then vcRetour = outilTraduction:getLibelle(102281).
    return vcRetour.
end function.
