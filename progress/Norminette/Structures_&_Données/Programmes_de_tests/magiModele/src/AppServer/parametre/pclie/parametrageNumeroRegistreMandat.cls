/*------------------------------------------------------------------------
File        : parametrageNumeroRegistreMandat.cls
Description :
Author(s)   : gga  -  2018/01/05
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.pclie.parametrageNumeroRegistreMandat inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageNumeroRegistreMandat():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("REGIS").
    end constructor.
    method public logical isNumeroRegistreAuto():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "AUTO".
    end method.
    method public character calculNumeroRegistre(pcTypeContrat as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:   a partir de adb/lib/l_pecct_srv.p procedure MajuNoRegistre
        ------------------------------------------------------------------------------*/
        define variable vcNumeroRegistre as character no-undo.
        define variable viNumeroSequence as integer   no-undo.   
        if isDbParameter and zon01 = "AUTO"
        then do:
            /* no registre commun gerance et copro */
            if entry(1, zon03, "@") = "YES" 
            then do: 
                viNumeroSequence = integer(entry(2, zon03, "@")) + 1.
                if zon02 = "AAAANOREG" 
                then do:
                    if viNumeroSequence > 999999 then viNumeroSequence = 1.
                    vcNumeroRegistre = string(year(today), "9999") + string(viNumeroSequence, "999999").
                end.                                    
                else do:
                    if viNumeroSequence > 9999999999 then viNumeroSequence = 1.
                    vcNumeroRegistre = string(viNumeroSequence, "9999999999").   
                end.                                                    
                /* maj no séquence */
                assign
                    entry(2, zon03, "@") = string(viNumeroSequence)
                    entry(3, zon03, "@") = string(today, "99/99/9999") 
                .       
            end.
            else do:
                if pcTypeContrat = "01030" and entry(1, zon04, "@") = "YES" 
                then do: 
                    viNumeroSequence = integer(entry(2, zon04, "@")) + 1.
                    if zon02 = "AAAANOREG" 
                    then do: 
                        if viNumeroSequence > 999999 then viNumeroSequence = 1.
                        vcNumeroRegistre = string(year(today), "9999") + string(viNumeroSequence, "999999").
                    end.                                    
                    else do:
                        if viNumeroSequence > 9999999999 then viNumeroSequence = 1.
                        vcNumeroRegistre = string( viNumeroSequence , "9999999999"). 
                    end.                                    
                    /* maj no séquence */
                    assign
                        entry(2, zon04, "@") = string(viNumeroSequence)
                        entry(3, zon04, "@") = string(today, "99/99/9999") 
                    .       
                end.
                if pcTypeContrat = "01003" and entry(1, zon05, "@") = "YES" 
                then do: 
                    viNumeroSequence = integer(entry(2, zon05, "@")) + 1.
                    if zon02 = "AAAANOREG" 
                    then do:
                        if viNumeroSequence > 999999 then viNumeroSequence = 1. 
                        vcNumeroRegistre = string(year(today), "9999") + string(viNumeroSequence, "999999").
                    end.
                    else do:
                        if viNumeroSequence > 9999999999 then viNumeroSequence = 1.
                        vcNumeroRegistre = string(viNumeroSequence, "9999999999"). 
                    end.                                                                                                            
                    /* maj no séquence */
                    assign
                        entry(2, zon05, "@") = string(viNumeroSequence)
                        entry(3, zon05, "@") = string(today, "99/99/9999") 
                    .       
                end.   
            end.
        end.
        return vcNumeroRegistre.
    end method.
    
end class.
