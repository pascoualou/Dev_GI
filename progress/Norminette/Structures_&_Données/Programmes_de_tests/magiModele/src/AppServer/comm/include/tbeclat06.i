/*-----------------------------------------------------------------------------
File        : tbeclat.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  -- diverses initialisations
              NB: il faut que la variable pré-processeur &VARLOC soit pas définie
-----------------------------------------------------------------------------*/
    
    /* Recherche mandat gerance globale              */
    find first ietab no-lock 
        where ietab.soc-cd = mtoken:iCodeSociete
          and ietab.profil-cd = 20 no-error.
    iMdGerGlb = (if available ietab then ietab.etab-cd else 8000). 

    /* Recherche mandat gestion commune              */
    find first ietab no-lock 
        where ietab.soc-cd = mtoken:iCodeSociete
          and ietab.profil-cd = 10 no-error.
    iMdGesCom = (if available ietab then ietab.etab-cd else 8500). 
    