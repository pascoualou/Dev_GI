/*------------------------------------------------------------------------
File        : fctLibelleCompte.i
Description : 
Created     : kantena - 2018/08/08
Notes       :
derniere revue: 2018/08/09 - phm: OK
------------------------------------------------------------------------*/
function contientChampsCompte returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Indique si la temp table contient les champs nécessaires au découpage 
             du numéro de compte ainsi qu'à la récupération du libellé
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vi              as integer no-undo.
    define variable vlLibelleCompte as logical no-undo.
    define variable vlSousCompte    as logical no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cLibelleCompte' then vlLibelleCompte = true.
            when 'cSousCompte'    then vlSousCompte    = true.
        end case.
    end.
    return (vlLibelleCompte and vlSousCompte).
end function.

function getLibelleCompte returns character private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libelle du compte
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ccpt   for ccpt.
    define buffer csscpt for csscpt.

    if phBuffer::cCollectif > ""
    then for first csscpt no-lock
        where csscpt.soc-cd     = phBuffer::iCodeSociete
          and csscpt.etab-cd    = phBuffer::iCodeEtablissement
          and csscpt.sscoll-cle = phBuffer::cCollectif
          and csscpt.cpt-cd     = phBuffer::cSousCompte:
        return csscpt.lib.
    end.
    else for first ccpt no-lock
        where ccpt.soc-cd     = phBuffer::iCodeSociete 
          and ccpt.coll-cle   = "" 
          and ccpt.libtype-cd <= 2 
          and ccpt.cpt-cd     = phBuffer::cCompte + phBuffer::cSousCompte:
         return ccpt.lib.
    end.
    return "".

end function.

procedure decoupeCompte private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération du compte - sous-compte
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter phBuffer as handle no-undo.
    define variable vcCompte as character no-undo.
    define buffer ietab for ietab.

    if phBuffer::cCollectif > "" then return.

    vcCompte = phBuffer::cCompte.
    find first ietab no-lock
        where ietab.soc-cd  = phBuffer::iCodeSociete
          and ietab.etab-cd = phBuffer::iCodeEtablissement no-error.
    assign
        phBuffer::cCompte     = substring(vcCompte, 1, ietab.Lgcum, "character")
        phBuffer::cSousCompte = substring(vcCompte, ietab.Lgcum + 1, ietab.Lgcpt - ietab.Lgcum, "character")
    .
end procedure.
