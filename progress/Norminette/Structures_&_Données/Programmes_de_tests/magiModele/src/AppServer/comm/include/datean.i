/*-----------------------------------------------------------------------------
File        : datean.i
Purpose     : Date des A Nouveaux à une date donnée
Author(s)   : , Kantena - 2018/01/11
Notes       : reprise comm/datean.i
derniere revue: 2018/05/28 - phm: OK
-----------------------------------------------------------------------------*/

function f_DebExeClot returns date(piCodeSociete as integer, piCodeEtablissement as integer, pdaJour as date):
    /*-----------------------------------------------------------------------------
    Purpose : Retourne la date des AN à une date donnée
    Notes   :
    -----------------------------------------------------------------------------*/
    define variable vdaDebutExercice as date    no-undo.
    define variable viCodePeriode    as integer no-undo.
    define buffer iprd  for iprd.
    define buffer ietab for ietab.
    
    find first ietab no-lock
        where ietab.soc-cd = piCodeSociete
          and ietab.etab-cd = piCodeEtablissement no-error.
    if not available ietab then return ?.

    find first iprd no-lock
        where iprd.soc-cd = piCodeSociete
          and iprd.etab-cd = piCodeEtablissement
          and iprd.dadebprd <= pdaJour
          and iprd.dafinprd >= pdaJour no-error.
    if available iprd then do:
        viCodePeriode = iprd.prd-cd.
        find first iprd no-lock
            where iprd.soc-cd  = piCodeSociete
              and iprd.etab-cd = piCodeEtablissement
              and iprd.prd-cd  = viCodePeriode no-error.
        if available iprd then vdaDebutExercice = iprd.dadebprd.
    end.
    return minimum(vdaDebutExercice, if ietab.exercice then ietab.dadebex2 else ietab.dadebex1).
end function.
