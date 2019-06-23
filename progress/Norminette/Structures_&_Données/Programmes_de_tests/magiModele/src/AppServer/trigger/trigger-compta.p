/*------------------------------------------------------------------------
File        : trigger-compta.p
Purpose     : reprise des triggers programme pour la base compta  
Author(s)   : GGA 2018/11/26
Notes       : a partir de trans/gene/compta.p  
------------------------------------------------------------------------*/

using parametre.pclie.parametrageBnp.

define variable GcUserId as character no-undo.
define variable glBnp    as logical   no-undo.

define variable ghAlimacpt as handle no-undo.
define variable ghMdmws    as handle no-undo.
 
run initialisationTrigger.
            
procedure initialisationTrigger:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define variable voBnp as class parametrageBnp no-undo.
    
    run trigger/alimacpt.p persistent set ghAlimacpt.
    voBnp = new parametrageBnp().
    glBnp = voBnp:isDbParameter.
    delete object voBnp.  
    if glBnp
    then run trigger/mdmws.p persistent set ghMdmws.

end procedure.

on write of cecrsai
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : extrait de trans/gene/compta.p (ON WRITE OF cecrsai) 
    ------------------------------------------------------------------------------*/    
message "on write of cecrsai " . 

    define variable vcGestionnaire as character no-undo.
    
    define buffer isoc  for isoc.    
    define buffer ietab for ietab. 
    
    if cecrsai.dadoss <> ? then return.
     
    if not can-find(first isoc no-lock where isoc.soc-cd = cecrsai.soc-cd) then return.
    
    for first ietab no-lock
        where ietab.soc-cd  = cecrsai.soc-cd
          and ietab.etab-cd = cecrsai.etab-cd:
        vcGestionnaire = ietab.gest-cle.
    end.
    run trtAlimacpt in ghAlimacpt (cecrsai.soc-cd,
                                   'compta',
                                   'cecrsai',
                                   string(cecrsai.soc-cd, '>>>>9') + string(cecrsai.etab-cd, '>>>>9')
                                                                   + string(cecrsai.jou-cd, 'x(5)')
                                                                   + string(cecrsai.prd-cd, '>>9')  /* ps le 16/04/02 */
                                                                   + string(cecrsai.prd-num, '>>>9')
                                                                   + string(cecrsai.piece-int, '>>>>>>>>9')
                                                                   + string(0,">>>>>9"),
                                   cecrsai.dacompta,
                                   vcGestionnaire,
                                   string(cecrsai.etab-cd)).
    
end.
    
on write of cecrln
do:  
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF cecrln) 
    ------------------------------------------------------------------------------*/    
message "on write of cecrln " .              
  
    define buffer isoc    for isoc.   
    define buffer cecrsai for cecrsai. 
    define buffer ietab   for ietab. 
    
    //{cecrln.wri}
    /* Test spécifique aux ecritures de tresorerie : elles sont d'abord crees avec lig négatif,
    puis avec lig positif. Pour les transferts, il ne faut tracer que les ecritures definitives. */
    if cecrln.lig < 0 then return.
    
    find first isoc no-lock where isoc.soc-cd = cecrln.soc-cd no-error.
    if not available isoc then return.
    
    if isoc.specif-cle = 1000 
    then find first cecrsai no-lock 
              where cecrsai.soc-cd    = cecrln.soc-cd         
                and cecrsai.etab-cd   = cecrln.mandat-cd
                and cecrsai.jou-cd    = cecrln.jou-cd
                and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                and cecrsai.prd-num   = cecrln.mandat-prd-num
                and cecrsai.piece-int = cecrln.piece-int no-error.
    else find first cecrsai no-lock 
              where cecrsai.soc-cd    = cecrln.soc-cd   
                and cecrsai.etab-cd   = cecrln.etab-cd
                and cecrsai.jou-cd    = cecrln.jou-cd
                and cecrsai.prd-cd    = cecrln.prd-cd
                and cecrsai.prd-num   = cecrln.prd-num
                and cecrsai.piece-int = cecrln.piece-int no-error.
    if not available cecrsai or cecrsai.dadoss <> ? then return.
     
    for first ietab no-lock
        where ietab.soc-cd  = cecrln.soc-cd
          and ietab.etab-cd = cecrln.etab-cd:
        run trtAlimacpt in ghAlimacpt (cecrsai.soc-cd,
                                       'compta',
                                       'cecrsai',                                   
                                       string(cecrsai.soc-cd, '>>>>9') + string(cecrsai.etab-cd, '>>>>9')
                                                                       + string(cecrsai.jou-cd, 'x(5)')
                                                                       + string(cecrsai.prd-cd, '>>9') /* ps le 16/04/02 */
                                                                       + string(cecrsai.prd-num, '>>>9')
                                                                       + string(cecrsai.piece-int, '>>>>>>>>9')
                                                                       + string(0,">>>>>9"),
                                       cecrsai.dacompta,
                                       ietab.gest-cle,
                                       string(cecrsai.etab-cd)).
    end.

end.                 

on assign of cecrln.lettre
do:  
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON ASSIGN OF cecrln.lettre) 
    ------------------------------------------------------------------------------*/           
    //{cecrln.asi} 
message "assign of cecrln.lettre " .    
    cecrln.fg-reac = true.
    
end.

on write of cecrlnana
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF cecrlnana) 
    ------------------------------------------------------------------------------*/        
message "on write of cecrlnana " .    
    define buffer aparm  for aparm.
    define buffer cecrln for cecrln.

    {trigger/majtrace.i "cecrlnana"}
    
    find first aparm no-lock
         where aparm.soc-cd  = 0
           and aparm.etab-cd = 0
           and aparm.tppar   = "TAUTO"
           and aparm.cdpar   = "AUTO" no-error.
    if available aparm and aparm.zone1 = 1 then return.
    
    run majAlrubEtAlrubhlp (cecrlnana.soc-cd, cecrlnana.ana1-cd, cecrlnana.ana2-cd).

    for first cecrln exclusive-lock
        where cecrln.soc-cd    = cecrlnana.soc-cd
          and cecrln.etab-cd   = cecrlnana.etab-cd
          and cecrln.jou-cd    = cecrlnana.jou-cd
          and cecrln.prd-cd    = cecrlnana.prd-cd
          and cecrln.prd-num   = cecrlnana.prd-num
          and cecrln.piece-int = cecrlnana.piece-int
          and cecrln.lig       = cecrlnana.lig:
        cecrln.fg-reac = true.              
    end.   
                                                                                   
end.

on delete of cecrlnana
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON DELETE OF cecrlnana) 
    ------------------------------------------------------------------------------*/       
message "on delete of cecrlnana " .    
    define buffer cecrln for cecrln.
    
    for first cecrln exclusive-lock
        where cecrln.soc-cd    = cecrlnana.soc-cd
          and cecrln.etab-cd   = cecrlnana.etab-cd
          and cecrln.jou-cd    = cecrlnana.jou-cd
          and cecrln.prd-cd    = cecrlnana.prd-cd
          and cecrln.prd-num   = cecrlnana.prd-num
          and cecrln.piece-int = cecrlnana.piece-int
          and cecrln.lig       = cecrlnana.lig:
        cecrln.fg-reac = true.              
    end.
    
end.

on write of cextlnana
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF cextlnana) 
    ------------------------------------------------------------------------------*/      
message "on write of cextlnana " .    
    define buffer aparm for aparm.
    
    find first aparm no-lock
         where aparm.soc-cd  = 0
           and aparm.etab-cd = 0
           and aparm.tppar   = "TAUTO"
           and aparm.cdpar   = "AUTO" no-error.
    if available aparm and aparm.zone1 = 1 then return.
 
    run majAlrubEtAlrubhlp (cextlnana.soc-cd, cextlnana.ana1-cd, cextlnana.ana2-cd).
 
end.

on write of ccpt                                    
do:  
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF ccpt) 
    ------------------------------------------------------------------------------*/      
message "on write of ccpt " .    
    define variable vcCptCd          as character no-undo.
    define variable vcTypCpt         as character no-undo. 
    define variable vrRowidLstcptdps as rowid     no-undo.
    
    define buffer isoc      for isoc.    
    define buffer ietab     for ietab. 
    define buffer lstcptdps for lstcptdps.
    
    {trigger/majtrace.i "ccpt"}  

message "on write of ccpt 02 " ccpt.coll-cle "// " ccpt.soc-cd.    

    if ccpt.coll-cle <> "" then return.
    
    find first isoc no-lock where isoc.soc-cd = ccpt.soc-cd no-error.
    if not available isoc then return. 

message "on write of ccpt 03 " isoc.specif-cle.    
    
    if isoc.specif-cle = 1000 
    then do:
        find first ietab no-lock 
             where ietab.soc-cd    = ccpt.soc-cd 
               and ietab.profil-cd = 10 no-error.
        if not available ietab  
        then find first ietab no-lock
             where ietab.soc-cd = ccpt.soc-cd no-error.
message "on write of ccpt 04 " available ietab "// " ccpt.libtype-cd .    
             
        if available ietab 
        then do:
            if ccpt.libtype-cd >= 3 
            then assign vcCptCd = fill("0", ietab.lgcum - length(ccpt.cpt-cd)) + ccpt.cpt-cd + fill("0", (ietab.lgcpt - ietab.lgcum))
                        vcTypCpt = "C"
            .
            else assign vcCptCd = fill("0", ietab.lgcum + (ietab.lgcpt - ietab.lgcum) - length(ccpt.cpt-cd)) + ccpt.cpt-cd
                        vcTypCpt = "G"
            .
            find first lstcptdps no-lock  
                 where lstcptdps.soc-cd    = ccpt.soc-cd 
                   and lstcptdps.mandat-cd = 0           
                   and lstcptdps.cpt-cd    = vcTypCpt + "," + vcCptCd no-error. 
 message "on write of ccpt 05 " available lstcptdps .    
                   
            if available lstcptdps 
            then do:
                if not (ccpt.libtype-cd >= 3) 
                then do:
 
  message "on write of ccpt 06 " lstcptdps.lib "// "  ccpt.lib .    
                    
                    if lstcptdps.lib <> ccpt.lib 
                    then do:
                        run majLstcptdps (rowid(lstcptdps), ccpt.lib, 0, 0).
                        run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                                       'compta',
                                                       'lstcptdp',
                                                       string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                         + string(lstcptdps.cpt-cd, 'x(15)'),
                                                       today,
                                                       ietab.gest-cle,
                                                       string(lstcptdps.mandat-cd)).
                    end.
                end.
            end.
            else do:
                run creationLstcptdps (ccpt.soc-cd, 0, vcCptCd, ccpt.lib, vcTypCpt, 0, 0, output vrRowidLstcptdps).
                find first lstcptdps no-lock where rowid(lstcptdps) = vrRowidLstcptdps.
                if not (ccpt.libtype-cd >= 3) 
                then run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                                    'compta',
                                                    'lstcptdp',
                                                    string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                      + string(lstcptdps.cpt-cd, 'x(15)'),
                                                    today,
                                                    ietab.gest-cle,
                                                    string(lstcptdps.mandat-cd)).
            end.    
        end.
    end.                       
    else do:
        for first ietab no-lock
            where ietab.soc-cd = ccpt.soc-cd:
            if ccpt.libtype-cd >= 3 
            then assign vcCptCd = ccpt.cpt-cd 
                        vcTypCpt = "C"
            .
            else assign vcCptCd = ccpt.cpt-cd 
                        vcTypCpt = "G"
            .
            find first lstcptdps no-lock
                 where lstcptdps.soc-cd    = ccpt.soc-cd 
                   and lstcptdps.mandat-cd = 0           
                   and lstcptdps.cpt-cd    = vcTypCpt + "," + vcCptCd no-error.
            if available lstcptdps 
            then do:
                if not (ccpt.libtype-cd >= 3) 
                then do:
                    if lstcptdps.lib <> ccpt.lib 
                    then do:
                        run majLstcptdps (rowid(lstcptdps), ccpt.lib, 0, 0).
                        run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                                       'compta',
                                                       'lstcptdp',
                                                       string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                         + string(lstcptdps.cpt-cd, 'x(50)'),
                                                       today,
                                                       ietab.gest-cle,
                                                       string(lstcptdps.mandat-cd)). 
                    end. 
                end. 
            end. 
            else do:
                run creationLstcptdps (ccpt.soc-cd, 0, vcCptCd, ccpt.lib, vcTypCpt, 0, 0, output vrRowidLstcptdps).
                find first lstcptdps no-lock where rowid(lstcptdps) = vrRowidLstcptdps.                        
                if not (ccpt.libtype-cd >= 3) 
                then run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                                    'compta',
                                                    'lstcptdp',
                                                    string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                      + string(lstcptdps.cpt-cd, 'x(50)'),
                                                    today,
                                                    ietab.gest-cle,
                                                    string(lstcptdps.mandat-cd)). 
            end.  
        end. 
    end.                        
end.

on delete of ccpt                                    
do:  
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON DELETE OF ccpt) 
    ------------------------------------------------------------------------------*/      
message "on delete of ccpt " .    
    define buffer ietab for ietab. 
    
    if ccpt.coll-cle = "" 
    then do:
        find first ietab no-lock 
             where ietab.soc-cd = ccpt.soc-cd 
               and ietab.profil-cd = 10 no-error.
        if not available ietab  
        then find first ietab no-lock
             where ietab.soc-cd = ccpt.soc-cd no-error.
        if available ietab and length(ccpt.cpt-cd) > ietab.lgcum 
        then do:
            run trtAlimacpt in ghAlimacpt (ccpt.soc-cd,
                                           'compta',
                                           'Supcpt',
                                           string(ccpt.soc-cd, '>>>>9') + string(0, '>>>>9')
                                                                        + string(ccpt.cpt-cd, 'x(15)'),
                                           today,
                                           ietab.gest-cle,
                                           "0").
        end.
    end.
end.

on write of csscpt old csscpt-old
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF csscpt OLD csscpt-old) 
    ------------------------------------------------------------------------------*/        
message "on write of csscpt " .    
    define variable vcCptCd               as character no-undo.
    define variable viCodeRole            as integer   no-undo. 
    define variable vlResultBufferCompare as logical   no-undo.
    define variable TrfRpRunGen           as character no-undo.
    define variable vrRowidLstcptdps      as rowid     no-undo.
  
    define buffer ietab     for ietab. 
    define buffer csscptcol for csscptcol.
    define buffer ccptcol   for ccptcol.
    define buffer isoc      for isoc.     
    define buffer lstcptdps for lstcptdps.
    define buffer vbroles     for roles.
    define buffer ctrat     for ctrat.      
    
    buffer-compare csscpt except dacrea ihcrea
    to csscpt-old
    save result in vlResultBufferCompare no-error.
    
message "on write of csscpt 02 " vlResultBufferCompare.    
    
    if vlResultBufferCompare = false and glBnp
    then do:
        case csscpt.sscoll-cle:
            when "L" 
            then do:
                for first vbroles no-lock 
                     where vbroles.norol = integer(string(csscpt.etab-cd) + csscpt.cpt-cd) 
                       and vbroles.tprol = "00019":
                    run trtMdmws in ghMdmws (vbroles.notie, 'C', true).
                end.
            end.
            when "P" 
            then do:
                find first ctrat no-lock
                      where ctrat.tpcon = "01030"
                        and ctrat.nocon = csscpt.etab-cd no-error.
                find first vbroles no-lock
                     where vbroles.tprol = "00016"
                       and vbroles.norol = integer(csscpt.cpt-cd) no-error.
                if not available vbroles 
                then
                find first vbroles no-lock
                     where vbroles.tprol = "00022"
                       and vbroles.norol = integer(csscpt.cpt-cd) no-error.
                if available vbroles 
                then do:
                    if available ctrat and (ctrat.ntcon = "03075" or ctrat.ntcon = "03085" or ctrat.ntcon = "03093") 
                    then run trtMdmws in ghMdmws (vbroles.notie, 'F', true).
                    else run trtMdmws in ghMdmws (vbroles.notie, 'C', true).
                end.    
            end.
            when "C" 
            then do:
                for first vbroles no-lock
                    where vbroles.tprol = "00008"
                      and vbroles.norol = integer(csscpt.cpt-cd):
                    run trtMdmws in ghMdmws (vbroles.notie, 'C', true).
                end.
            end.
        end case.
    end. 
    
    {trigger/majtrace.i "csscpt"}
    
    find first isoc no-lock where isoc.soc-cd = csscpt.soc-cd no-error.
    if not available isoc then return.  
    
    if isoc.specif-cle = 1000 
    then do:
        //{csscpt.wri}
        for first ietab no-lock
            where ietab.soc-cd  = csscpt.soc-cd 
              and ietab.etab-cd = csscpt.etab-cd:
            find first csscptcol of csscpt no-lock no-error.     
            find first ccptcol no-lock 
                 where ccptcol.soc-cd   = csscpt.soc-cd 
                   and ccptcol.coll-cle = csscptcol.coll-cle no-error.
            assign      
                vcCptCd    = fill ("0", ietab.lgcum - length(csscptcol.sscoll-cpt)) + csscptcol.sscoll-cpt + fill ("0", (ietab.lgcpt - ietab.lgcum) - length(csscpt.cpt-cd)) + csscpt.cpt-cd
                viCodeRole = ccptcol.tprole 
            .                                                             //gga todo pas de test sur available csscptcol ccptcol 
            find first lstcptdps no-lock
                 where lstcptdps.soc-cd    = csscpt.soc-cd  
                   and lstcptdps.mandat-cd = csscpt.etab-cd 
                   and lstcptdps.cpt-cd    = "I" + "," + vcCptCd no-error.
            if available lstcptdps 
            then do:
                if lstcptdps.lib <> csscpt.lib 
                then do:
                    run majLstcptdps (rowid(lstcptdps), csscpt.lib, csscpt.numerateur, csscpt.denominateur).
                    run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                                   'compta',
                                                   'lstcptdp',
                                                   string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                     + string(lstcptdps.cpt-cd, 'x(15)'),
                                                   today,
                                                   ietab.gest-cle,
                                                   string(lstcptdps.mandat-cd)).
                end.
                else 
                if viCodeRole = 16 
                then do:
                    if lstcptdps.numerateur   <> csscpt.numerateur 
                    or lstcptdps.denominateur <> csscpt.denominateur
                    then do:
                        run majLstcptdps (rowid(lstcptdps), csscpt.lib, csscpt.numerateur, csscpt.denominateur).
                        run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                                       'compta',
                                                       'lstcptdp',
                                                       string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                         + string(lstcptdps.cpt-cd, 'x(15)'),
                                                       today,
                                                       ietab.gest-cle,
                                                       string(lstcptdps.mandat-cd)). 
                    end.
                end.
            end.
            else do:
                if viCodeRole = 16 
                then run creationLstcptdps (csscpt.soc-cd, csscpt.etab-cd, vcCptCd, csscpt.lib, "I", csscpt.numerateur, csscpt.denominateur, output vrRowidLstcptdps).
                else run creationLstcptdps (csscpt.soc-cd, csscpt.etab-cd, vcCptCd, csscpt.lib, "I", 0, 0, output vrRowidLstcptdps).
                find first lstcptdps no-lock where rowid(lstcptdps) = vrRowidLstcptdps.
                run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                               'compta',
                                               'lstcptdp',
                                               string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                 + string(lstcptdps.cpt-cd, 'x(15)'),
                                               today,
                                               ietab.gest-cle,
                                               string(lstcptdps.mandat-cd)).
            end.
        end.
    end.
    else do:
        for first ietab no-lock
            where ietab.soc-cd = csscpt.soc-cd:
            find first csscptcol of csscpt no-lock no-error.     
            vcCptCd = csscptcol.sscoll-cpt + csscpt.cpt-cd + "," + csscptcol.sscoll-cpt.    //gga todo pas de test sur available csscptcol 
            find first lstcptdps no-lock 
                 where lstcptdps.soc-cd    = csscpt.soc-cd  
                   and lstcptdps.mandat-cd = csscpt.etab-cd 
                   and lstcptdps.cpt-cd    = "I" + "," + vcCptCd no-error.
            if available lstcptdps 
            then do:
                if lstcptdps.lib <> csscpt.lib 
                then do:
                    run majLstcptdps (rowid(lstcptdps), csscpt.lib, 0, 0).                
                    run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                                   'compta',
                                                   'lstcptdp',
                                                   string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                     + string(lstcptdps.cpt-cd, 'x(50)'),
                                                   today,
                                                   ietab.gest-cle,
                                                   string(lstcptdps.mandat-cd)).
                end.
            end.
            else do:
                run creationLstcptdps (csscpt.soc-cd, csscpt.etab-cd, vcCptCd, csscpt.lib, "I", 0, 0, output vrRowidLstcptdps).
                find first lstcptdps no-lock where rowid(lstcptdps) = vrRowidLstcptdps.
                run trtAlimacpt in ghAlimacpt (lstcptdps.soc-cd,
                                               'compta',
                                               'lstcptdp',
                                               string(lstcptdps.soc-cd, '>>>>9') + string(lstcptdps.mandat-cd, '>>>>9')
                                                                                 + string(lstcptdps.cpt-cd, 'x(50)'),
                                               today,
                                               ietab.gest-cle,
                                               string(lstcptdps.mandat-cd)).
            end.
        end.
    end.
end.

on write of aruba 
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF aruba) 
    ------------------------------------------------------------------------------*/   
message "on write of aruba " .    
    define buffer alrub for alrub.
    
    if aruba.fg-rub
    then run trtAlimacpt in ghAlimacpt (aruba.soc-cd,
                                        'cadb',
                                        'aruba',
                                        string(aruba.soc-cd, '>>>>9') + string(aruba.rub-cd, 'x(3)')
                                                                      + fill(" ", 3)
                                                                      + string(aruba.lib, 'x(32)') 
                                                                      + fill(" ", 12)
                                                                      + fill(" ", 4)
                                                                      + fill(" ", 4)
                                                                      + fill(" ", 3)
                                                                      + fill(" ", 4)
                                                                      + fill(" ", 4)
                                                                      + string(0, ">>>>>9")
                                                                      + fill("0", 15)                                   /** 0505/0074 COMPTE **/ 
                                                                      + fill("0", 8)                                    /** 0505/0074 DAFIN **/
                                                                      + fill(" ", 4),                                   /** 0505/0074 type-chg **/
                                        today,
                                        "",
                                        '').
    else for each alrub no-lock 
            where alrub.soc-cd = aruba.soc-cd
              and alrub.ssrub  = aruba.rub-cd: 
        run trtAlimacpt in ghAlimacpt (aruba.soc-cd,
                                       'cadb',
                                       'aruba',
                                       string(aruba.soc-cd, '>>>>9') + string(alrub.rub-cd, 'x(3)')
                                                                     + string(alrub.ssrub-cd, 'x(3)') 
                                                                     + string(aruba.lib, 'x(32)') 
                                                                     + string((  entry(1, alrub.cfb-cd, ",") 
                                                                               + entry(2, alrub.cfb-cd, ",")
                                                                               + entry(3, alrub.cfb-cd, ",")
                                                                               + entry(4, alrub.cfb-cd, ",")), 'x(12)')
                                                                     + string((  entry(1, alrub.fisc-cle, ",")
                                                                               + entry(2, alrub.fisc-cle, ",")
                                                                               + entry(3, alrub.fisc-cle, ",")
                                                                               + entry(4, alrub.fisc-cle, ",")), 'x(4)')
                                                                     + string(alrub.rub-old, 'x(4)') 
                                                                     + string(alrub.type-rub, '999') 
                                                                     + string((  entry(1, alrub.honoraires, ",")
                                                                               + entry(2, alrub.honoraires, ",")
                                                                               + entry(3, alrub.honoraires, ",")
                                                                               + entry(4, alrub.honoraires, ",")), 'x(4)')
                                                                     + string((  entry(1, alrub.honodas, ",")
                                                                               + entry(2, alrub.honodas, ",")
                                                                               + entry(3, alrub.honodas, ",")
                                                                               + entry(4, alrub.honodas, ",")), 'x(4)')
                                                                     + string(0, ">>>>>9")
                                                                     + fill("0", 15 - length(alrub.cpt-cd)) + trim(alrub.cpt-cd) /** 0505/0074 **/
                                                                     + (if alrub.dafin <> ? then string(year(alrub.dafin), "9999") else "0000") 
                                                                     + (if alrub.dafin <> ? then string(month(alrub.dafin), "99")  else "00") 
                                                                     + (if alrub.dafin <> ? then string(day(alrub.dafin), "99")    else "00") /** 0505/0074 DAFIN **/
                                                                     + string(alrub.type-chg, "x(5)"),
                                       today,
                                       "",
                                       '' ).
    end.

end.

on write of cexmsai 
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF cexmsai) 
    ------------------------------------------------------------------------------*/       
message "on write of cexmsai " .    
    {trigger/majtrace.i "cexmsai"} 
    
end.

on write of cextsai 
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/compta.p (ON WRITE OF cextsai) 
    ------------------------------------------------------------------------------*/        
message "on write of cextsai " .    
    {trigger/majtrace.i "cextsai"} 
    
end.

procedure creationLstcptdps private:   
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/incl/crelstcp.i (procedure creation-lstcptdps) 
    ------------------------------------------------------------------------------*/   
message "creationLstcptdps " .    
    define input parameter  piSociete      as integer   no-undo.
    define input parameter  piMandat       as integer   no-undo.    
    define input parameter  pcCompte       as character no-undo.    
    define input parameter  pclib          as character no-undo.
    define input parameter  pcTypCpt       as character no-undo.
    define input parameter  piNumerateur   as integer   no-undo.
    define input parameter  piDenominateur as integer   no-undo.
    define output parameter prRowid        as rowid     no-undo.
    
    define buffer lstcptdps for lstcptdps.
    
    create lstcptdps.
    assign lstcptdps.soc-cd       = piSociete
           lstcptdps.mandat-cd    = piMandat
           lstcptdps.cpt-cd       = substitute ("&1,&2", pcTypCpt, pcCompte)
           lstcptdps.lib          = pclib
           lstcptdps.jtrf         = ?
           lstcptdps.ihtrf        = 0                        
           lstcptdps.numerateur   = piNumerateur 
           lstcptdps.denominateur = piDenominateur  
           prRowid                  = rowid(lstcptdps)         
    .
    
end procedure.          
                
procedure majLstcptdps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/incl/procpme.maj (procedure maj-lstcptdps) 
    ------------------------------------------------------------------------------*/     
message "majLstcptdps " .    
    define input parameter prRowid        as rowid     no-undo.
    define input parameter pclib          as character no-undo.
    define input parameter piNumerateur   as integer   no-undo.
    define input parameter piDenominateur as integer   no-undo.
    
    define buffer lstcptdps for lstcptdps.
    
    for first lstcptdps exclusive-lock where rowid(lstcptdps) = prRowid:
        assign 
            lstcptdps.lib          = pclib
            lstcptdps.numerateur   = piNumerateur
            lstcptdps.denominateur = piDenominateur
        .
    end.
        
end procedure.

procedure majAlrubEtAlrubhlp private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/incl/proccadb.maj (procedure maj-alrub, procedure maj-alrubhlp) 
    ------------------------------------------------------------------------------*/    
message "majAlrubEtAlrubhlp " .    
    define input parameter pcCodeSociete      as integer   no-undo.
    define input parameter pcRubriqueAnal     as character no-undo.
    define input parameter pcSousRubriqueAnal as character no-undo.
    
    define buffer alrub    for alrub.
    define buffer alrubhlp for alrubhlp.
    
    for each alrub no-lock
       where alrub.soc-cd   = pcCodeSociete
         and alrub.rub-cd   = pcRubriqueAnal
         and alrub.ssrub-cd = pcSousRubriqueAnal:
        find current alrub exclusive-lock no-wait no-error.    /**Modif OF le 21/09/99 : On passe si l'enregistrement est locke par un autre utilisateur (Fiche 3261)**/

message "majAlrubEtAlrubhlp maj alrub " available alrub pcCodeSociete pcRubriqueAnal pcSousRubriqueAnal.    

        if available alrub then alrub.fg-use = true.
    end.
    for each alrubhlp no-lock
       where alrubhlp.soc-cd   = pcCodeSociete
         and alrubhlp.rub-cd   = pcRubriqueAnal
         and alrubhlp.ssrub-cd = pcSousRubriqueAnal:
        find current alrubhlp exclusive-lock no-wait no-error.    /**Modif OF le 21/09/99 : On passe si l'enregistrement est locke par un autre utilisateur (Fiche 3261)**/

message "majAlrubEtAlrubhlp maj alrubhlp" available alrubhlp pcCodeSociete pcRubriqueAnal pcSousRubriqueAnal.    

        if available alrubhlp then alrubhlp.fg-use = true.
    end.
    
end procedure.
