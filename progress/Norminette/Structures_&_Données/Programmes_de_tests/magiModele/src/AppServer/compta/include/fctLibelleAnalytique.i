/*------------------------------------------------------------------------
File        : fctLibelleAnalytique.i
Description : 
Author(s)   : kantena - 2018/08/08
Notes       :
derniere revue: 2018/08/09 - phm: KO
------------------------------------------------------------------------*/
function contientChampsAnalytique returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Indique si la temp table contient les champs nécessaires  
             à la récupération des libellés analytiques
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vi                    as integer no-undo.
    define variable vlCodeSociete         as logical no-undo.
    define variable vlCodeRubrique        as logical no-undo.
    define variable vlCodeSousRubrique    as logical no-undo.
    define variable vlCodeFiscal          as logical no-undo.
    define variable vlCodeCle             as logical no-undo.
    define variable vlLibelleRubrique     as logical no-undo.
    define variable vlLibelleSousRubrique as logical no-undo.
    define variable vlLibelleFiscal       as logical no-undo.
    define variable vlLibelleCle          as logical no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'               then vlCodeSociete         = true.
            when 'ana1-cd'              then vlCodeRubrique        = true.
            when 'ana2-cd'              then vlCodeSousRubrique    = true.
            when 'ana3-cd'              then vlCodeFiscal          = true.
            when 'ana4-cd'              then vlCodeCle             = true.
            when 'cLibelleRubrique'     then vlLibelleRubrique     = true.
            when 'cLibelleSousRubrique' then vlLibelleSousRubrique = true.
            when 'cLibelleFiscal'       then vlLibelleFiscal       = true.
            when 'cLibelleCle'          then vlLibelleCle          = true.
        end case.
    end.
    return (vlCodeSociete            and vlCodeRubrique 
           and vlCodeSousRubrique    and vlCodeFiscal 
           and vlCodeCle             and vlLibelleRubrique 
           and vlLibelleSousRubrique and vlLibelleFiscal 
           and vlLibelleCle).
end function.

function getLibelleRubrique returns character private(piCodeSociete as integer, pcCodeRubrique as character, pcCodeSousRubrique as character):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libelle de la rubrique
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer aruba for aruba.

    if pcCodeRubrique = "999" and pcCodeSousRubrique = "999" then return outilTraduction:getLibelle(107045).
    for first aruba no-lock 
        where aruba.soc-cd = piCodeSociete
          and aruba.cdlng  = mtoken:iCodeLangueSession
          and aruba.fg-rub
          and aruba.rub-cd = pcCodeRubrique:
        return aruba.lib.
    end.
    return "".
end function.

function getLibelleSousRubrique returns character private(piCodeSociete as integer, pcCodeRubrique as character, pcCodeSousRubrique as character):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libelle de la rubrique
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer aruba for aruba.

    if pcCodeRubrique  = "999" and pcCodeSousRubrique = "999" then return outilTraduction:getLibelle(101480).
    for first aruba no-lock
        where aruba.soc-cd = piCodeSociete
          and aruba.cdlng  = mtoken:iCodeLangueSession
          and aruba.fg-rub = false
          and aruba.rub-cd = pcCodeSousRubrique:
        return aruba.lib.
    end.
    return "".
end function.

function getLibelleFiscal returns character private(pcCodeFiscal as character):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libelle fiscal
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer aparm for aparm.

    for first aparm no-lock
        where aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and aparm.tppar   = "TFISC"
          and aparm.cdpar   = pcCodeFiscal:
        return outilTraduction:getLibelle(aparm.nome1).
    end.
    return "".

end function.

function getLibelleCle returns character private(pcCodeCle as character):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libelle de clé
    Notes  :
        todo   attention, rechercher avec tpcon, nocon -> thk
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.

    for first clemi no-lock 
        where clemi.cdcle = pcCodeCle:
        return clemi.lbcle.
    end.
    return "".
end function.

procedure getLibelleAnalytique private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des libellés analytiques 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer as handle no-undo.
    assign
        phBuffer::cLibelleRubrique     = getLibelleRubrique(phBuffer::iCodeSociete, phBuffer::cCodeRubrique, phBuffer::cCodeSousRubrique)
        phBuffer::cLibelleSousRubrique = getLibelleSousRubrique(phBuffer::iCodeSociete, phBuffer::cCodeRubrique, phBuffer::cCodeSousRubrique)
        phBuffer::cLibelleFiscal       = getLibelleFiscal(phBuffer::cCodeFiscal)
        phBuffer::cLibelleCle          = getLibelleCle(phBuffer::cCodeCle)
    .
end procedure.
