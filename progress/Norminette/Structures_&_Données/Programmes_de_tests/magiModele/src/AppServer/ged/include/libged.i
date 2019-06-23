/*------------------------------------------------------------------------
File        : libged.i
Purpose     : fonctions module GED 
Description : 
Author(s)   : LGI/   -  2017/03/13 
Notes       :
------------------------------------------------------------------------*/

function f_VisibiliteRoleExtranet returns collection private(pcTypeRole as character, piNumeroImmeuble as integer, piNumeroMandat as integer):
    /*------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------*/
    define variable voCollection as collection no-undo.

    define buffer ctrat  for ctrat.
    define buffer intnt  for intnt.
    define buffer vbIntnt for intnt.

    voCollection = new collection().
    case pcTypeRole:
        when {&TYPEROLE-locataire} then do:
            voCollection:set('voirLocataire', true).
            voCollection:set('saisirProprietaire', true).
            voCollection:set('voirProprietaire', true).
        end.
        when {&TYPEROLE-mandant} then do:
            voCollection:set('saisirLocataire', true).
            voCollection:set('voirProprietaire', true).
        end.
        when {&TYPEROLE-mandant} then do:
            voCollection:set('saisirLocataire', true).
            voCollection:set('voirProprietaire', true).
        end.
        when {&TYPEROLE-salariePegase} then voCollection:set('voirEmployeImmeuble', true).
        when {&TYPEROLE-coproprietaire} then do:
            voCollection:set('voirCoproprietaire', true).
            voCollection:set('saisirConseilSyndic', true).
        end.
        otherwise do:
            if piNumeroMandat <> 0
            then do : /* Mandat renseigné */
                find first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                      and ctrat.nocon = piNumeroMandat no-error.
                if available ctrat
                then do:
                    voCollection:set('saisirCoproprietaire', true).
                    voCollection:set('saisirConseilSyndic', true).
                    voCollection:set('saisirEmployeImmeuble', true).
                    if integer(pcTypeRole) = 0 then voCollection:set('voirCoproprietaire', true).
                end.
                else do:
                    find first ctrat no-lock
                        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                          and ctrat.nocon = piNumeroMandat no-error.
                    if available ctrat
                    then do:
                        voCollection:set('saisirLocataire', true).
                        voCollection:set('saisirProprietaire', true).
                        voCollection:set('saisirEmployeImmeuble', true).
                        if integer(pcTypeRole) = 0 then voCollection:set('voirProprietaire', true).
                    end.                
                    else . 
                end.
            end.
            else if piNumeroImmeuble <> 0 then do : /* Immeuble renseigné sans mandat renseigné */
                 find first intnt no-lock
                     where intnt.tpidt = {&TYPEBIEN-immeuble}
                       and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                       and intnt.noidt = piNumeroImmeuble no-error.
                 find first vbIntnt no-lock 
                     where vbIntnt.tpidt = {&TYPEBIEN-immeuble}
                       and vbIntnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                       and vbIntnt.noidt = piNumeroImmeuble no-error.
                voCollection:set('saisirEmployeImmeuble', true).
                if available vbIntnt then do:
                    voCollection:set('saisirLocataire', true).
                    voCollection:set('saisirProprietaire', true).
                    if integer(pcTypeRole) = 0 and not available intnt then voCollection:set('voirProprietaire', true).
                end.
                if available intnt then do:
                    voCollection:set('saisirCoproprietaire', true).
                    voCollection:set('saisirConseilSyndic', true).
                    if integer(pcTypeRole) = 0 and not available vbIntnt then voCollection:set('voirCoproprietaire', true).
                end.
            end.
        end.
    end case.
    return voCollection.

end function.
