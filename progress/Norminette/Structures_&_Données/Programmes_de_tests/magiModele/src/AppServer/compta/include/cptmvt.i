/*------------------------------------------------------------------------
File        : cptmvt.i
Purpose     : MAJ de compte mouvement ou creation automatiquement
Author(s)   : gga  -  2017/05/15
Notes       : reprise include gest\src\batch\cptmvt.i
----------------------------------------------------------------------*/

if not available ccptmvt
then do:
    create ccptmvt.
    assign
        ccptmvt.soc-cd     = cecrln.soc-cd
        ccptmvt.etab-cd    = cecrln.etab-cd
        ccptmvt.sscoll-cle = {1}
        ccptmvt.cpt-cd     = {2}
        ccptmvt.prd-cd     = cecrln.prd-cd
        ccptmvt.prd-num    = cecrln.prd-num
    .
end.

if cecrsai.situ                                                       /* Situation definitive */
then if cecrln.sens                                                   /* DEBIT */
    then assign
        ccptmvt.mtdeb      = ccptmvt.mtdeb      + cecrln.mt
        ccptmvt.mtdeb-EURO = ccptmvt.mtdeb-EURO + cecrln.mt-EURO
    .
    else assign                                                       /* CREDIT */
        ccptmvt.mtcre      = ccptmvt.mtcre      + cecrln.mt
        ccptmvt.mtcre-EURO = ccptmvt.mtcre-EURO + cecrln.mt-EURO
    .
else if cecrln.sens                                                   /* DEBIT */
    then assign
        ccptmvt.mtdebp      = ccptmvt.mtdebp      + cecrln.mt
        ccptmvt.mtdebp-EURO = ccptmvt.mtdebp-EURO + cecrln.mt-EURO
    .
    else assign                                                       /* CREDIT */
        ccptmvt.mtcrep      = ccptmvt.mtcrep      + cecrln.mt
        ccptmvt.mtcrep-EURO = ccptmvt.mtcrep-EURO + cecrln.mt-EURO
    .
