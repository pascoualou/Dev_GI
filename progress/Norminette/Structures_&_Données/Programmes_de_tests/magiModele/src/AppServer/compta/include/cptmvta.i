/*------------------------------------------------------------------------
File        : cptmvta.i
Purpose     : MAJ de compte mouvement ou creation automatiquement
Author(s)   : gga  -  2017/05/15
Notes       : reprise include gest\src\batch\cptmvta.i
              CE le 11/05/1999 Ajout du delete ccptmvtana si tous les mts sont a 0 Fiche 911
----------------------------------------------------------------------*/

for each cecrlnana no-lock
    where cecrlnana.soc-cd    = {1}.soc-cd
      and cecrlnana.etab-cd   = {1}.etab-cd
      and cecrlnana.jou-cd    = {1}.jou-cd
      and cecrlnana.prd-cd    = {1}.prd-cd
      and cecrlnana.prd-num   = {1}.prd-num
      and cecrlnana.piece-int = {1}.piece-int
      and cecrlnana.lig       = {1}.lig:
    {&_proparse_ prolint-nowarn(nowait)}
    find first ccptmvtana exclusive-lock
        where ccptmvtana.soc-cd     = cecrlnana.soc-cd
          and ccptmvtana.etab-cd    = cecrlnana.etab-cd
          and ccptmvtana.sscoll-cle = cecrlnana.sscoll-cle
          and ccptmvtana.cpt-cd     = cecrlnana.cpt-cd
          and ccptmvtana.ana1-cd    = cecrlnana.ana1-cd
          and ccptmvtana.ana2-cd    = cecrlnana.ana2-cd
          and ccptmvtana.ana3-cd    = cecrlnana.ana3-cd
          and ccptmvtana.ana4-cd    = cecrlnana.ana4-cd
          and ccptmvtana.prd-cd     = cecrlnana.prd-cd
          and ccptmvtana.prd-num    = cecrlnana.prd-num no-error.
    if not available ccptmvtana
    then do:
        create ccptmvtana.
        assign
            ccptmvtana.soc-cd     = cecrlnana.soc-cd
            ccptmvtana.etab-cd    = cecrlnana.etab-cd
            ccptmvtana.sscoll-cle = cecrlnana.sscoll-cle
            ccptmvtana.cpt-cd     = cecrlnana.cpt-cd
            ccptmvtana.ana1-cd    = cecrlnana.ana1-cd
            ccptmvtana.ana2-cd    = cecrlnana.ana2-cd
            ccptmvtana.ana3-cd    = cecrlnana.ana3-cd
            ccptmvtana.ana4-cd    = cecrlnana.ana4-cd
            ccptmvtana.prd-cd     = cecrlnana.prd-cd
            ccptmvtana.prd-num    = cecrlnana.prd-num
        .
    end.
    if {2}.situ
    then if cecrlnana.sens
        then assign                                                                    /* DEBIT */
            ccptmvtana.mtdeb      = ccptmvtana.mtdeb      + cecrlnana.mt
            ccptmvtana.mtdeb-EURO = ccptmvtana.mtdeb-EURO + cecrlnana.mt-EURO      /**  XS le 12/02/99  **/
        .
        else assign
            ccptmvtana.mtcre      = ccptmvtana.mtcre      + cecrlnana.mt
            ccptmvtana.mtcre-EURO = ccptmvtana.mtcre-EURO + cecrlnana.mt-EURO      /**  XS le 12/02/99  **/
        .
    else if cecrlnana.sens
        then assign                                                                    /* DEBIT PROVISOIRE */
            ccptmvtana.mtdebp      = ccptmvtana.mtdebp      + cecrlnana.mt
            ccptmvtana.mtdebp-EURO = ccptmvtana.mtdebp-EURO + cecrlnana.mt-EURO   /**  XS le 12/02/99  **/
        .
        else assign                                                                    /* CREDIT PROVISOIRE */
            ccptmvtana.mtcrep      = ccptmvtana.mtcrep      + cecrlnana.mt
            ccptmvtana.mtcrep-EURO = ccptmvtana.mtcrep-EURO + cecrlnana.mt-EURO   /**  XS le 12/02/99  **/
        .
    /* CE le 11/05/1999 Fiche 911 */
    if ccptmvtana.mtdeb = 0 and ccptmvtana.mtcre = 0 and ccptmvtana.mtdebp = 0 and ccptmvtana.mtcrep = 0
    then delete ccptmvtana.
end.
