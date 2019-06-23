/*-----------------------------------------------------------------------------
File        : eclatEncDefautMandat.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  -- diverses initialisations
derniere revue: 2018/09/04 - phm: 
-----------------------------------------------------------------------------*/
define variable iMdGerGlb       as integer no-undo.
define variable iMdGesCom       as integer no-undo.

assign
    iMdGerGlb = 8000 
    iMdGesCom = 8500
.
for first ietab no-lock 
    where ietab.soc-cd = mtoken:iCodeSociete
      and ietab.profil-cd = 20:    /* Recherche mandat gerance globale */
    iMdGerGlb = ietab.etab-cd. 
end.
for first ietab no-lock 
    where ietab.soc-cd = mtoken:iCodeSociete
      and ietab.profil-cd = 10:    /* Recherche mandat gestion commune */
    iMdGesCom = ietab.etab-cd.
end. 
