/*------------------------------------------------------------------------
    File        : bqudfmdt.i
    Purpose     : 
    Description : 
    Author(s)   : KANTENA
    Created     : Fri Mar 02 10:47:50 CET 2018
    Notes       :
  ----------------------------------------------------------------------*/

procedure BquDfMdt:
    /*------------------------------------------------------------------------------
        Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input        parameter SocCdUse-IN as integer   no-undo.
    define input        parameter NoMdtUse-IN as integer   no-undo.
    define output       parameter NoRetUse-OU as integer   no-undo.
    define output       parameter JouBqUse-OU as character no-undo.
    define output       parameter MdtBqUse-OU as integer   no-undo.
    define input-output parameter LbDivPar-IO as character no-undo.
    
    define buffer bietab for ietab.

    find first ietab no-lock 
         where ietab.soc-cd  = SocCdUse-IN
           and ietab.etab-cd = NoMdtUse-In no-error.
    if not available ietab then do:
        NoRetUse-ou = 2.
        return.
    end.

    /* code journal de banque */
    JouBqUse-OU = ietab.bqjou-cd.

    if ietab.profil-cd <> ietab.bqprofil-cd then do:
        /* recherche du mandat global (8000, 8500, 9000) */
        find first bietab no-lock
            where bietab.soc-cd = SocCdUse-IN
            and bietab.profil-cd = ietab.bqprofil-cd no-error.
    end.

    /** recherche journal de banque par défaut **/
    find first ijou no-lock
         where ijou.soc-cd  = SocCdUse-IN
           and ijou.etab-cd = (if available bietab then bietab.etab-cd else ietab.etab-cd)
           and ijou.jou-cd  = ietab.bqjou-cd no-error.
              
    if not available ijou then do:
        NoRetUse-ou = 3.
        return.
    end.
    
    /* mandat du journal de banque (8000, 8500, 9000 ou no mandat) */
    MdtBqUse-OU = ijou.etab-cd.
               
    find first ibque no-lock 
        where ibque.soc-cd  = SocCdUse-IN
          and ibque.etab-cd = ijou.etab-cd
          and ibque.cpt-cd  = ijou.cpt-cd no-error.
    if not available ibque then do:
        find first ibque no-lock 
             where ibque.soc-cd  = SocCdUse-IN
               and ibque.etab-cd = ijou.etab-cd no-error.
    end.
    if available ibque then do: 
        LbDivPar-IO = ibque.nne         + "|" + 
                      ibque.tip-cd      + "|" +
                      ibque.iban        + "|" +
                      ibque.bque        + "|" +
                      ibque.guichet     + "|" +
                      ibque.cpt         + "|" +
                      ibque.rib         + "|" +
                      ibque.domicil[2]  + "|" +
                      ibque.domicil[1]  + "|" + /* titulaire */
                      ijou.jou-cd       + "|" + 
                      ibque.cpt-cd      + "|" + 
                      STRING(available bietab)  + "|" +
                      ibque.fmtprl + "|" +      /* SY 0511/0023 */  
                      ibque.fmtvir + "|" +      /* SY 0511/0023 */  
                      ibque.ics                 /* SY 0511/0023 */                        
                      .                        
    end.
    else do:
        NoRetUse-ou = 4.
        return.
    end.
    NoRetUse-OU = 0.
    
end procedure.
 
