/*------------------------------------------------------------------------
File        : fctDebitCredit.i
Description : 
Author(s)   : kantena - 2018/08/08
Notes       :
derniere revue: 2018/08/09 - phm: OK
------------------------------------------------------------------------*/
function contientChampsDebitCredit returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Indique si la temp table contient les champs nécessaires  
             à la répartition Débit/Credit
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vi       as integer no-undo.
    define variable vlDebit  as logical no-undo.
    define variable vlCredit as logical no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'dMontantDebit'  then vlDebit  = true.
            when 'dMontantCredit' then vlCredit = true.
        end case.
    end.
    return (vlDebit and vlCredit).
end function.
