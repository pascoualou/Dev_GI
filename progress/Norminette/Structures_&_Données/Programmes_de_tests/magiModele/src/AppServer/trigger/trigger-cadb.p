/*------------------------------------------------------------------------
File        : trigger-cadb.p
Purpose     : reprise des triggers programme pour la base cadba  
Author(s)   : GGA 2018/11/26
Notes       : a partir de trans/gene/cadb.p  
------------------------------------------------------------------------*/

define variable GcUserId as character no-undo.

define variable ghAlimacpt as handle no-undo.

run initialisationTrigger.

procedure initialisationTrigger:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/    
    run trigger/alimacpt.p persistent set ghAlimacpt.

end procedure.

on write of agest
do:   
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : extrait de trans/gene/cadb.p (ON WRITE OF agest) 
    ------------------------------------------------------------------------------*/    
message "on write of agest " .    
            
    run trtAlimacpt in ghAlimacpt (cadb.agest.soc-cd,
                                   'cadb',
                                   'agest',
                                   string(cadb.agest.soc-cd,'99999') + string(cadb.agest.gest-cle,"x(5)"),
                                   today,
                                   agest.gest-cle,
                                   " ").
                          
end.

on write of aparm 
do:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : extrait de trans/gene/cadb.p (ON WRITE OF aparm) 
    ------------------------------------------------------------------------------*/       
message "on write of aparm " .    
     
    {trigger/majtrace.i "aparm"}
    
end.


