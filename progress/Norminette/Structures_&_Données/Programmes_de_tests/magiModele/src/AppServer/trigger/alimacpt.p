/*------------------------------------------------------------------------
File        : alimacpt.p
Purpose     : Mise a jour specifique pour le transfert des ecritures comptables
Author(s)   : PC 17/04/97  - GGA 2018/10/12
Notes       : a partir de trans/gene/alimacpt.p  

 Historique des modifications 
  Nø      Date     Auteur                   Objet                       
 0001  13/05/1997    PC    Remplacement de Gest-Cd par Gest-Cle                                                                               |
 0002  16/05/1997    PC    Mise en place de la nouvelle arborescence       
                           des transferts                                  
 0003  18/06/97    PC-JR   Remplacement du champ noref par soc-cd       
                                                                           
 0004   24/11/97     JR    Ajout trigger lstcptdps et creation-maj         
                                                                           
 0005   10/01/00     OF    Suppression de la trace si la piece est vide    
                                                                           
 0006   20/03/00     XS    Ajout des traces sur aruba                      
                                                                           
 007    27/04/00     JR    Patch 7.3.5                                     
                                                                           
                                                                           
 008    31/05/00    FR     Modif. du for each maj en 2 requetes            
 009    26/12/00    CC     Passage en Shared                               
 010    22/04/00    JR     Fiche 0201/0333                                 
 011    27/02/01     OF    Ajout d'un parametre d'entree pouc le tracage
                           des ecritures de cloture                     
 12     16/04/02    PS     FICHE 0302/0689 modif format prd-cd pour maj 
 013   23/04/2002   LG     0402/1028 - modif maj pour aruba.               
 014    06/05/02    PS     0301/0423 - envoi mensuel des analytiques       
 015    30/04/03    OF     0303/0197 - maj des nlles zones de cecrsai   
 016    03/11/03    OF     1003/0357 - On ne vide pas le champ maj.jtrf 
                           en modification car la piece peut etre en       
                           cours de transfert                              
 02    19/01/04     OF     1003/0028 Pb lorsque lancé dans le cron      
 03    29/03/04     PS     0303/0197 tracage pour les PME ne faisant pas   
                           le transfert                                    
 04    15/07/04     PS     0604/0477 on ne supprima pas toujours les       
                           trace de type 'cecrlnana' et 'suplnana'         
 05    25/08/04     OF     Suite modif precedente: plantage si cadb non    
                           connectee                                       
 06    27/05/05     OF     0305/0498 maj du nouveau champ nomprog          
 07    06/06/05     OF     Pb V9                                           
 08    02/06/05     OF     0105/0348 Gestion de la suppression des      
                           comptes generaux                             
 09    02/03/06     OF     Eviter de changer la date de modification de 
                           la piece lors de sa validation definitive       
                           (procedure maj-cecrsai de cont-d04.w)           
 10    27/06/06     JR     0606/0134 ne pas tracer une piece ne contenant
                           que des lignes à 0                               
 11    04/07/06     OF     Amelioration de la fonction retournant le nom    
                           des programmes ayant crée la piece comptable     
 12    04/10/06     JR     0905/0081 : Ajout ifour pour gérer la maj des    
                           org. sociaux au site central                     
                           Pas de triggers                                  
                           Alimacpt.p est appellé directement par :         
                             fasie.w, faios2.w et basc_sie.p                
------------------------------------------------------------------------*/

function maj-nomprog return character private ():
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/    
    define variable vcNomProg as character no-undo.
    define variable viCpt     as integer   no-undo.
    define variable vcTemp    as character no-undo.

    do viCpt = 4 to 12:
        assign
            vcTemp    = program-name(viCpt)
            vcNomProg = vcNomProg + (if lookup(substring(vcTemp, r-index(vcTemp,"/") + 1), vcNomProg) = 0 and r-index(vcTemp, "/") <> 0 and num-entries(vcNomProg) <= 5
                                     then "," + substring(vcTemp, r-index(vcTemp,"/") + 1)
                                     else "")
        .
    end.
    return trim(vcNomProg, ",").
end.    

function majExiste return logical private (piSociete as integer, pcNmLog as character, pcNmtab as character, pcCdenr as character):
    /*------------------------------------------------------------------------------
    Purpose:  controle si maj existe avec recherche sur cdenr =   
    Notes  :
    ------------------------------------------------------------------------------*/    
    return can-find (first maj
                     where maj.soc-cd = piSociete
                       and maj.nmlog  = pcNmLog
                       and maj.nmtab  = pcNmtab
                       and maj.cdenr  = pcCdenr).
end.    

function majExiste2 return logical private (piSociete as integer, pcNmLog as character, pcNmtab as character, pcCdenr as character):
    /*------------------------------------------------------------------------------
    Purpose:  controle si maj existe avec recherche sur cdenr begins 
    Notes  :
    ------------------------------------------------------------------------------*/    
    return can-find (first maj
                     where maj.soc-cd = piSociete
                       and maj.nmlog  = pcNmLog
                       and maj.nmtab  = pcNmtab
                       and maj.cdenr  begins pcCdenr).
end.    

procedure trtAlimacpt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter piCodeSociete as integer   no-undo.
    define input parameter pcNmLog       as character no-undo.
    define input parameter pcTable       as character no-undo.
    define input parameter pcCleCommune  as character no-undo.
    define input parameter pdaCompta     as date      no-undo.
    define input parameter pcGestCd      as character no-undo.
    define input parameter pcMandatCd    as character no-undo.

message "trtAlimacpt " PROGRAM-NAME(1) "// " PROGRAM-NAME(2) "// " PROGRAM-NAME(3) SKIP
piCodeSociete "// " pcNmLog "// " pcTable "// " pcCleCommune "// " pdaCompta "// " pcGestCd "// " pcMandatCd . 


    define variable viLongCleCom as integer no-undo.
    define variable vlCloture    as logical no-undo.

    define buffer isoc      for isoc.
    define buffer vbcecrsai for cecrsai.
    define buffer maj       for maj.

   /* Avant de rechercher s'il existe une trace precedente pour le code enregistrement, il faut interroger la table isoc de la base inter pour savoir si 
   il y a un transfert possible sur cet enregistrement */
   find first isoc no-lock
        where isoc.soc-cd = piCodeSociete no-error.
   if available isoc and isoc.fg-dispo
   then do:
       /* On recherche la longueur de la clé communes aux tables CECRSAI, CECRLN, CECRLNANA */
       viLongCleCom = length(pcCleCommune) - 6.
       case pcTable:
           /* Mise à jour d'une entête */
           when "CECRSAI" 
           then do :
               /**Ajout OF le 27/02/01 pour savoir si la piece a ete saisie sur une periode de cloture**/
               for first vbcecrsai exclusive-lock 
                   where vbcecrsai.soc-cd    = integer(substring(pcCleCommune,1,5))    
                     and vbcecrsai.etab-cd   = integer(substring(pcCleCommune,6,5))
                     and vbcecrsai.jou-cd    = substring(pcCleCommune,11,5)    
                     and vbcecrsai.prd-cd    = integer(substring(pcCleCommune,16,3))    
                     and vbcecrsai.prd-num   = integer(substring(pcCleCommune,19,4))   
                     and vbcecrsai.piece-int = integer(substring(pcCleCommune,23,9)):                                    
                   if vbcecrsai.usrid-eff = "CLOTURE" 
                   then vlCloture = true.
                   /**Ajout OF le 30/04/03**/
                   if vbcecrsai.ihcrea = 0 
                   then do:                                               /* Creation */
                       vbcecrsai.ihcrea = time.
                       if vbcecrsai.nomprog = "" 
                       then vbcecrsai.nomprog = maj-nomprog().                                          //gga todo revoir maj-nomprog
                   end.
                   /* Modification */
                   else 
                   if time - vbcecrsai.ihcrea > 60 
                   and not program-name(3) begins "maj-cecrsai"                                        //gga todo  evoir maj-nomprog
                   then assign
                            vbcecrsai.damod    = today
                            vbcecrsai.ihmod    = time
                            vbcecrsai.usridmod = entry (2, session:parameter) when num-entries(session:parameter) > 1
                   .
               end.
               /* Si la piece en cours de validation est vide on supprime la trace correspondante (Ajout OF le 10/01/00) */
               if (not can-find(first cecrln
                                where cecrln.soc-cd         = integer(substring(pcCleCommune,1,5))    
                                  and cecrln.mandat-cd      = integer(substring(pcCleCommune,6,5))
                                  and cecrln.jou-cd         = substring(pcCleCommune,11,5)    
                                  and cecrln.mandat-prd-cd  = integer(substring(pcCleCommune,16,3))
                                  and cecrln.mandat-prd-num = integer(substring(pcCleCommune,19,4))   
                                  and cecrln.piece-int      = integer(substring(pcCleCommune,23,9))
                                  and cecrln.mt             <> 0 /** 0606/0314 **/)                                               
                   and isoc.specif-cle = 1000) 
               or (not can-find(first cecrln                                                      /** Patch 7.3.5 **/ 
                                where cecrln.soc-cd    = integer(substring(pcCleCommune,1,5))    
                                  and cecrln.etab-cd   = integer(substring(pcCleCommune,6,5))
                                  and cecrln.jou-cd    = substring(pcCleCommune,11,5)    
                                  and cecrln.prd-cd    = integer(substring(pcCleCommune,16,3))    
                                  and cecrln.prd-num   = integer(substring(pcCleCommune,19,4))   
                                  and cecrln.piece-int = integer(substring(pcCleCommune,23,9))
                                  and cecrln.mt        <> 0 /** 0606/0314 **/)
                   and isoc.specif-cle <> 1000)
               then do:
                   if vlCloture
                   then run suppressionMaj2 (piCodeSociete, pcNmLog, "CLOTURE" + substring(pcCleCommune, 6, 5), substring(pcCleCommune, 1, viLongCleCom)).  
                   else do:
                       run suppressionMaj2 (piCodeSociete, pcNmLog, "CECRLN", substring(pcCleCommune, 1, viLongCleCom)).  
                       run suppressionMaj2 (piCodeSociete, pcNmLog, "CECRSAI", substring(pcCleCommune, 1, viLongCleCom)).  
                   end.
                   return.
               end.
               /* On regarde si une trace n'existe pas déjà pour CECRSAI On la crée uniquement si elle n'existe pas. Sinon on met à jour les dates 
               et heures de mise à jour et on réinitialise les dates et heures de transfert à ? */               
               if vlCloture 
               then do: /**Ajout du test par OF le 27/02/01**/
                   run creationMaj2 (piCodeSociete, pcNmLog, "CLOTURE" + substring(pcCleCommune, 6, 5), substring(pcCleCommune, 1, viLongCleCom),                    
                                     substring(pcCleCommune, 1, viLongCleCom) + string(0, ">>>>>9"), pdaCompta, pcGestCd, pcMandatCd, no).
               end.
               else do:
                   run creationMaj2 (piCodeSociete, pcNmLog, "CECRSAI", substring(pcCleCommune, 1, viLongCleCom),                    
                                     substring(pcCleCommune, 1, viLongCleCom) + string(0, ">>>>>9"), pdaCompta, pcGestCd, pcMandatCd, no).
                   /* On regarde si des traces n'existent pas déjà pour les écritures non analytiques associées à l'entête mise à jour et dans ce cas 
                      on les supprime */   
                   run suppressionMaj2 (piCodeSociete, pcNmLog, "CECRLN", substring(pcCleCommune, 1, viLongCleCom)).  
               end.                   
           end.
           /* Mise à jour d'une ligne d'écriture analytique */
           when "CECRLNANA" 
           then do:
               /* On regarde si une trace n'existe pas déjà pour CECRSAI auquel cas on ne fait rien car out sera automatiquement retransféré */
               if majExiste2 (piCodeSociete, pcNmLog, "CECRSAI", substring(pcCleCommune, 1, viLongCleCom - 6))
               then return.    
               if majExiste2 (piCodeSociete, pcNmLog, "CLOTURE" + substring(pcCleCommune, 6, 5), substring(pcCleCommune, 1, viLongCleCom - 6))
               then return.
               /* On teste si un CANA antérieur existe */
               if majExiste (piCodeSociete, pcNmLog, "cecrlnana", pcCleCommune)
               then return. /* inutile de retracer une analytique deja tracée */ /* PS LE 06/05/02 */
               /* On crée si elle n'existe pas déjà une trace pour CECRLN */
               run creationMaj (piCodeSociete, pcNmLog, "cecrlnana", pcCleCommune, pdaCompta, pcGestCd, pcMandatCd). /* "cecrln" PS LE 06/05/02 */ 
           end.
           when "SUPLNANA"                    /**** genération des CANS *****/ /* PS LE 06/05/02 */ 
           then do:  
               /* On regarde si une trace n'existe pas déjà pour CECRSAI auquel cas on ne fait rien car out sera automatiquement retransféré */
               if majExiste2 (piCodeSociete, pcNmLog, "CECRSAI", substring(pcCleCommune, 1, viLongCleCom - 6))
               then return.
               if majExiste2 (piCodeSociete, pcNmLog, "CLOTURE" + substring(pcCleCommune, 6, 5), substring(pcCleCommune, 1, viLongCleCom - 6))
               then return.
               /* On teste si un CANA antérieur existe  */
               if connected ("CADB")   /* DELETE maj. */ /** PS LE 15/07/2004 -- F 0604/0477 **/ 
               then for first maj exclusive-lock
                        where maj.soc-cd = piCodeSociete
                          and maj.nmlog  = pcNmLog
                          and maj.nmtab  = "cecrlnana"
                          and maj.cdenr  = pcCleCommune:
                   {application/include/tracemaj.i piCodeSociete}
               end.
               if majExiste (piCodeSociete, pcNmLog, "suplnana", pcCleCommune)
               then return.                    
               /* On crée si elle n'existe pas déjà une trace pour CECRLN */
               run creationMaj (piCodeSociete, pcNmLog, "suplnana", pcCleCommune, pdaCompta, pcGestCd, pcMandatCd).
           end.
           when "ietab"    or 
           when "agest"    or 
           when "lstcptdp" or 
           when "lstjoudp" or
           when "parjou"   or
           when "supcpt"   or                          /**Ajout OF le 02/06/05**/
           when "ifour"
           then run creationMaj (piCodeSociete, pcNmLog, pcTable, pcCleCommune, pdaCompta, pcGestCd, pcMandatCd).
           when "aruba"           /** XS le 20/03/2000 **/ 
           then run creationMaj2 (piCodeSociete, pcNmLog, pcTable, substring(pcCleCommune, 1, 11), pcCleCommune, pdaCompta, pcGestCd, pcMandatCd, yes).
       end case.    
       
   end. /* IF AVAILABLE isoc AND isoc.fg-dispo THEN DO : */
   /** PS LE 29/03/04 -- F 0303/0197 ==> **/
   else if available isoc and not isoc.fg-dispo and pcTable = "CECRSAI" 
   then do:
       for first vbcecrsai exclusive-lock  
           where vbcecrsai.soc-cd    = integer(substring(pcCleCommune,1,5))    
             and vbcecrsai.etab-cd   = integer(substring(pcCleCommune,6,5))
             and vbcecrsai.jou-cd    = substring(pcCleCommune,11,5)    
             and vbcecrsai.prd-cd    = integer(substring(pcCleCommune,16,3))    
             and vbcecrsai.prd-num   = integer(substring(pcCleCommune,19,4))   
             and vbcecrsai.piece-int = integer(substring(pcCleCommune,23,9)):                                    
           if vbcecrsai.ihcrea = 0                      /* Creation */
           then do: 
               vbcecrsai.ihcrea = time.
               if vbcecrsai.nomprog = "" 
               then vbcecrsai.nomprog = maj-nomprog().
           end.
           else 
           if time - vbcecrsai.ihcrea > 60              /* Modification */
           then assign
                    vbcecrsai.damod    = today
                    vbcecrsai.ihmod    = time
                    vbcecrsai.usridmod = entry (2, session:parameter) when num-entries(session:parameter) > 1
           .
       end.
   end.
     
end procedure.    
    
procedure creationMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/    
    define input parameter  piSociete    as integer   no-undo.
    define input parameter  pcNmLog      as character no-undo.
    define input parameter  pcTable      as character no-undo.
    define input parameter  pcCleCommune as character no-undo.
    define input parameter  pdaCompta    as date      no-undo.
    define input parameter  pcGestCd     as character no-undo.
    define input parameter  pcMandatCd   as character no-undo.
 
    define buffer maj for maj.
        
    find first maj exclusive-lock
         where maj.soc-cd = piSociete
           and maj.nmlog  = pcNmLog
           and maj.nmtab  = pcTable
           and maj.cdenr  = pcCleCommune no-wait no-error.
    if locked maj 
    then return.    /* Conflit de traçage de mise à jour. Réessayez plus tard. */ /*** Fiche 0201/0333 {mestrans.i "100195" "'I'"} ***/
    
    if not available maj 
    then do:
        create maj.
        assign
            maj.soc-cd   = piSociete
            maj.nmlog    = pcNmLog
            maj.nmtab    = pcTable
            maj.cdenr    = pcCleCommune
            maj.jcremvt  = today
            maj.ihcremvt = mtime
            maj.nomprog  = maj-nomprog() /**Ajout OF le 27/05/05**/
        .
    end.                         
    assign
        maj.jmodmvt   = today
        maj.ihmodmvt  = mtime
        maj.DateComp  = pdaCompta
        maj.Gest-Cle  = pcGestCd
        maj.Mandat-Cd = pcMandatCd
    .
    
end procedure.

procedure creationMaj2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/    
    define input parameter piSociete        as integer   no-undo.
    define input parameter pcNmLog          as character no-undo.
    define input parameter pcTable          as character no-undo.
    define input parameter pcRechercheCdenr as character no-undo.
    define input parameter pcCleCommune     as character no-undo.
    define input parameter pdaCompta        as date      no-undo.
    define input parameter pcGestCd         as character no-undo.
    define input parameter pcMandatCd       as character no-undo.
    define input parameter plMajCdenrModif  as logical   no-undo.

    define buffer maj for maj.

    find first maj exclusive-lock
         where maj.soc-cd = piSociete
           and maj.nmlog  = pcNmLog
           and maj.nmtab  = pcTable
           and maj.cdenr  begins pcRechercheCdenr no-wait no-error.
    if locked maj 
    then return.
    if not available maj 
    then do:
        create maj.
        assign
            maj.soc-cd   = piSociete
            maj.nmlog    = pcNmLog
            maj.nmtab    = pcTable
            maj.cdenr    = pcCleCommune when not plMajCdenrModif
            maj.jcremvt  = today
            maj.ihcremvt = mtime
            maj.nomprog  = maj-nomprog()
            
        . 
    end.                         
    assign
        maj.cdenr     = pcCleCommune when plMajCdenrModif
        maj.jmodmvt   = today
        maj.ihmodmvt  = mtime
        maj.DateComp  = pdaCompta
        maj.Gest-Cle  = pcGestCd
        maj.Mandat-Cd = pcMandatCd
    .
            
end procedure.

procedure suppressionMaj2 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/    
    define input parameter piSociete as integer   no-undo.
    define input parameter pcNmLog   as character no-undo.
    define input parameter pcNmtab   as character no-undo.
    define input parameter pcCdenr   as character no-undo.

    define buffer maj for maj.

    for each maj exclusive-lock 
       where maj.soc-cd = piSociete
         and maj.nmlog  = pcNmLog
         and maj.nmtab  = pcNmtab
         and maj.cdenr  begins pcCdenr:
        delete maj.
    end.

end procedure.
    