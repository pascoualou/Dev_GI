/*------------------------------------------------------------------------
    File        : dateValiditeCompte.i
    Purpose     : 
    Description : 
    Author(s)   : kantena
    Created     : Mon Nov 26 11:51:44 CET 2018
    Notes       :
  ----------------------------------------------------------------------*/

function DateDeValidite returns logical private (piCodeEtab as int64, pcColl-cle as character, pcNumeroCompte as character, pdaDate as date):
    /*------------------------------------------------------------------------------
    Purpose: Test des dates de validité
    Notes  : Le blocage au niveau du mandat est prioritaire sur celui au niveau global
    ------------------------------------------------------------------------------*/
    define variable vlErreur as logical no-undo.
    define buffer dtval for dtval.

    // Y a-t-il un blocage au niveau de tous les mandats sur ce compte ?
    find first dtval no-lock
        where dtval.soc-cd   = integer(mToken:cRefPrincipale)
          and dtval.etab-cd  = piCodeEtab
          and dtval.coll-cle = pcColl-cle
          and dtval.cpt-cd   = pcNumeroCompte no-error.
    if available dtval
    then do:
        if dtval.dadeb <> ? and dtval.dafin = ? and dtval.dadeb > pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 110926, string(dtval.dadeb, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dafin <> ? and dtval.dadeb = ? and dtval.dafin < pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 110927, string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dadeb <> ? and dtval.dafin <> ? and (dtval.dadeb > pdaDate or dtval.dafin < pdaDate)
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 110928, string(dtval.dadeb, "99/99/9999") + separ[1] + string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
    end.
    // Y a-t-il un blocage au niveau de tous les mandats sur ce compte ?
    else for first dtval no-lock
        where dtval.soc-cd   = integer(mToken:cRefPrincipale)
          and dtval.etab-cd  = 0
          and dtval.coll-cle = pcColl-cle
          and dtval.cpt-cd   = pcNumeroCompte:
        if dtval.dadeb <> ? and dtval.dafin = ? and dtval.dadeb > pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 109015, string(dtval.dadeb, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dafin <> ? and dtval.dadeb = ? and dtval.dafin < pdaDate
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 109016, string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
        if dtval.dadeb <> ? and dtval.dafin <> ? and (dtval.dadeb > pdaDate or dtval.dafin < pdaDate)
        then do:
            vlErreur = true.
            mError:createErrorCompta({&erreur}, 109017, string(dtval.dadeb, "99/99/9999") + separ[1] + string(dtval.dafin, "99/99/9999") + ". Fournisseur : " + pcNumeroCompte).
        end.
    end.
    return vlErreur.

end function.