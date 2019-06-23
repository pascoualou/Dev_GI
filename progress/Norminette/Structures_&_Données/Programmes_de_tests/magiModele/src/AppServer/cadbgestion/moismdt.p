/*------------------------------------------------------------------------
File        : moismdt.p
Purpose     : Recherche du mandat de contrepartie 
Author(s)   : OF 12/06/97   -  GGA  2019/01/07
Notes       : a partir de cadb/gestion/moismdt.p


gga todo voir avec Olivier utilite et retourne quoi (rapport entre date et mandat contrepartie dans purpose)


  1    27/06/1997  PB      Recherche du mois le plus ancien lorsque
                           le mandat n'existe pas en comptabilité  
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
 
procedure rechercheAnneeMoisComptableCopro:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete   as integer no-undo. 
    define input  parameter piNumeroContrat as integer no-undo. 
    define output parameter pcAnneeMois     as character no-undo.
    
    define variable vdaDate as date init "01/01/2100" no-undo. 
    
    define buffer ietab for ietab. 
    define buffer agest for agest. 
    
    pcAnneeMois = string(year(vdaDate), "9999") + string(month(vdaDate), "99").
    
    // Recherche du mandat
    find first ietab no-lock
         where ietab.soc-cd  = piCodeSociete
           and ietab.etab-cd = piNumeroContrat no-error.
    if not available ietab 
    then do:
        for each agest no-lock 
           where agest.soc-cd = piCodeSociete:
            if agest.dadeb < vdaDate then vdaDate = agest.dadeb.
        end.
        pcAnneeMois = string(year(vdaDate), "9999") + string(month(vdaDate), "99").
    end.
    else do:
        // Recherche du gestionnaire
        find first agest no-lock
             where agest.soc-cd   = piCodeSociete
               and agest.gest-cle = ietab.gest-cle no-error.
        if not available agest 
        then
        find first agest no-lock
             where agest.soc-cd   = piCodeSociete                
               and agest.gest-cle = ietab.gest-old no-error.
        if not available agest 
        then do:
            for each agest no-lock 
               where agest.soc-cd = piCodeSociete:
                if agest.dadeb < vdaDate then vdaDate = agest.dadeb.
            end.    
            pcAnneeMois = string(year(vdaDate), "9999") + string(month(vdaDate), "99").
        end.
        else pcAnneeMois = string(year(agest.dadeb), "9999") + string(month(agest.dadeb), "99").
    end.

message "fin rechercheMois " pcAnneeMois.

end procedure.
