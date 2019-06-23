/*------------------------------------------------------------------------
File      : fctequip.i
Purpose   : 
Author(s) : - 2018/01/29 
Notes     :
------------------------------------------------------------------------*/

function formateEquipement return character private(piNumeroImmeuble as integer):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: ancienne procédure FrmEquipement
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define buffer imble       for imble.
    define buffer equipBien   for equipBien.
    define buffer equipements for equipements.

    find first imble no-lock
        where imble.noimm = piNumeroImmeuble no-error.
    {&_proparse_ prolint-nowarn(sortaccess)}
    if available imble
    then if can-find(first equipBien no-lock
                     where equipBien.cTypeBien   = {&TYPEBIEN-immeuble}
                       and equipBien.iNumeroBien = piNumeroImmeuble)
    then for each equipBien no-lock
        where equipBien.cTypeBien   = {&TYPEBIEN-immeuble}
          and equipBien.iNumeroBien = piNumeroImmeuble
      , first equipements no-lock
        where equipements.cCodeEquipement = equipBien.cCodeEquipement
        by integer(equipements.lbdiv2) by equipements.cCodeEquipement:
        vcRetour = vcRetour + ", " + Equipements.cDesignation.
    end.
    else do:
        if imble.nblog <> 0 then vcRetour =            "Loge".                 /* Loge           */
        if imble.nbasc <> 0 then vcRetour = vcRetour + ", Ascenseur".          /* Ascenseur      */
        if imble.nbmch <> 0 then vcRetour = vcRetour + ", Monte-charge".       /* Monte-Charges  */
        if imble.nbext <> 0 then vcRetour = vcRetour + ", Extincteur".         /* Extincteur     */
        if imble.nbant <> 0 then vcRetour = vcRetour + ", Antenne Collective". /* antenne        */
        if imble.nbint <> 0 then vcRetour = vcRetour + ", Interphone".         /* Interphone     */
        if imble.nbfer <> 0 then vcRetour = vcRetour + ", Fermeture Codée".    /* Fermeture Code */
        if imble.nbvid <> 0 then vcRetour = vcRetour + ", Vide-Ordure".        /* Vide Ordure    */
    end. 
    if imble.sfvet <> 0 then vcRetour = vcRetour + ", Espace vert".            /* Espace Vert    */
    vcRetour = trim(vcRetour, ", ").

    if vcRetour = "" or vcRetour = ? then return outilTraduction:getLibelle(102281).
    return vcRetour.
end function.

function formateEquipementLot returns character(piNumeroLoc as integer):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes: ancienne procédure FrmEquipementLot
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define buffer local       for local.
    define buffer equipBien   for equipBien.
    define buffer equipements for equipements.

    for first local no-lock
        where local.noloc = piNumeroLoc:
        {&_proparse_ prolint-nowarn(sortaccess)}
        if can-find(first equipBien no-lock
                    where equipBien.cTypeBien = {&TYPEBIEN-lot}
                      and equipBien.iNumeroBien = piNumeroLoc)
        then for each equipBien no-lock
            where equipBien.cTypeBien   = {&TYPEBIEN-lot}
              and equipBien.iNumeroBien = piNumeroLoc
          , first equipements no-lock
            where equipements.cCodeEquipement = equipBien.cCodeEquipement
            by integer(equipements.lbdiv2) by equipements.cCodeEquipement:
            vcRetour = vcRetour + ", " + equipements.cDesignation.
        end.
        else do: /* Equipement Individuel */
            if local.fgcha then vcRetour =                   outilTraduction:getLibelle(101370). /* Eau Chaude */
            if local.fgfra then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(101371). /* Eau Froide */
            if local.fgair then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(100452). /* Air Conditionne */
            if local.fgmbl then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(100454). /* Meuble */
            if local.fgwci then vcRetour = vcRetour + ", " + outilTraduction:getLibelle(103169). /* WC */
        end.
        vcRetour = trim(vcRetour, ", "). /* On enleve la 1ere virgule */
    end.
    if vcRetour = "" or vcRetour = ? then return outilTraduction:getLibelle(102281).
    return vcRetour.
end function.
