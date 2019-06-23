/*---------------------------------------------------------------------------
File        : majseq.p
Purpose     : Mise a jour de toutes les sequences 
Author(s)   : TM 31/10/1995  -  GGA 2018/05/23
Notes       : reprise adb/lib/majseq.p

 0001 13/07/1999 SY Correction sq_norol01 afin de tenir compte   
                    du dernier no mandataire                     
 0002 07/01/2000 SY Correction sq_norol01 afin de tenir compte   
                    de la plage 8000-8999 r‚serv‚e aux mandants  
                    des mandats 8xxx pour la sous-location       
 0003 18/09/2000 SY Correction sq_norol01 : la plage 8000-8999   
                    n'est plus r‚serv‚e                          
                    + gestion limite s‚quence … 89999            
 0004 21/09/2000 SY Correction sq_norol01 : il manque les roles  
                    00035 & 00036 qui font aussi partie de la    
                    famille propri‚taire (R_RFR="12000")         
 0005 17/11/2004 SY 1104/0150: sq_norol01 : il manque les roles  
                    li‚s a l'usufruit qui font aussi partie de la
                    famille propri‚taire (R_RFR="12000")         
                    00018, 00029, 00065 & 00066                  
 0006 30/06/2005 SY Correction sq_norol01 : il manque les roles  
                    00041 & 00042 qui font aussi partie de la    
                    famille propri‚taire => boucle sur R_RFR     
 0007 10/10/2005 AF 0205/0300 Roles 00071 - Gerant               
 0008 16/10/2007 PL 0807/0106 ajout idsui.                       
---------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using

procedure lanceMajseq:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/    
message "lanceMajseq".    
    run majSeqCtanx.
    run majSeqLocal.
    run majSeqIntnt.
    run majSeqRoles.
    run majSeqTache.
    run majSeqTiers.
                    
end procedure.

procedure majSeqCtanx private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define buffer ctanx for ctanx. 
    
    find last ctanx no-lock
    use-index ix_ctanx01 no-error.
    if available ctanx 
    then current-value (Sq_nodoc01) = ctanx.nodoc.
    else current-value (Sq_nodoc01) = 1.

end procedure.

procedure majSeqLocal private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/        
    define buffer local for local. 

    find last local no-lock
    use-index ix_local01 no-error.
    if available local 
    then current-value (Sq_noloc01) = local.noloc.
    else current-value (Sq_noloc01) = 1.
    
end procedure.

procedure majSeqIntnt private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/        
    define buffer intnt for intnt. 

    find last intnt no-lock
        where intnt.idsui <> 0
    use-index ix_intnt07 no-error.
    if available intnt 
    then current-value (Sq_idsui01) = intnt.idsui.
    else current-value (Sq_idsui01) = 1.

end procedure.

procedure majSeqRoles private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : Sq_norol01 : roles.norol
                          (tprol = "00008" ou tprol = "00016" ou tprol = "00022")
                          +tprol = "00035" ou tprol = "00036" 
                          +tprol = "00018" ou tprol = "00029" 
                          +tprol = "00065" ou tprol = "00066" 
             ATTENTION : le no de mandataire ("00014") utilise aussi cette séquence 
                         car il ne doit pas avoir le meme no qu'un prop ou coprop
                         => modif SY le 13/07/1999
             ATTENTION : les no 8000 … 8999 sont r‚serv‚s aux mandants des mandats 8xxx
                         => modif SY le 07/01/2000
                         Plus de plage reservee le 18/09/2000
    ------------------------------------------------------------------------------*/       
    define variable viDernierNumeroRole as integer no-undo init 1.
    
    define buffer vbroles for roles.
    define buffer sys_pg  for sys_pg.

    /* role gérant/mandataire particulier (pas dans famille 12000) */
    for last vbroles no-lock
       where vbroles.tprol = "00014"
         and vbroles.norol < 89999
    use-index ix_roles01:
        if viDernierNumeroRole < vbroles.norol 
        then viDernierNumeroRole = vbroles.norol.
    end.
    for last vbroles no-lock
       where vbroles.tprol = "00071"
         and vbroles.norol < 89999
    use-index ix_roles01:
        if viDernierNumeroRole < vbroles.norol 
        then viDernierNumeroRole = vbroles.norol.
    end.
    for each sys_pg no-lock
       where sys_pg.tppar = "R_RFR" 
         and sys_pg.zone2 = "12000":
        for last vbroles no-lock
           where vbroles.tprol = sys_pg.zone1
             and vbroles.norol < 89999
        use-index ix_roles01:
            if viDernierNumeroRole < vbroles.norol 
            then viDernierNumeroRole = vbroles.norol.
        end.
    end.    
    current-value (Sq_norol01) = viDernierNumeroRole.

end procedure.

procedure majSeqTache private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/       
    define buffer tache for tache.
     
    find last tache no-lock
    use-index ix_tache01 no-error.
    if available tache 
    then current-value (Sq_notac01) = tache.noita. 
    else current-value (Sq_notac01) = 1.
    
end procedure.

procedure majSeqTiers private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/        
    define buffer tiers for tiers.

    find last tiers no-lock
    use-index ix_tiers01 no-error.
    if available tiers 
    then current-value (Sq_notie01) = tiers.notie.
    else current-value (Sq_notie01) = 1.
    
end procedure.

