/*------------------------------------------------------------------------
File        : parametreLoi.cls
Purpose     : 
Author(s)   : GGA  -  2018/01/16
Notes       : 
------------------------------------------------------------------------*/

block-level on error undo, throw.

class parametre.syspr.parametrageLoi inherits parametre.syspr.syspr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define public property dTauxAmmortissementPer1    as decimal no-undo get. set.
    define public property dTauxAmmortissementPer2    as decimal no-undo get. set.
    define public property dTauxAmmortissementPer3    as decimal no-undo get. set.
    define public property iNbAmmortissementPer1      as integer no-undo get. set.
    define public property iNbAmmortissementPer2      as integer no-undo get. set.
    define public property iNbAmmortissementPer3      as integer no-undo get. set.
    define public property lParamExistPer1            as logical no-undo get. set.
    define public property lParamExistPer2            as logical no-undo get. set.
    define public property lParamExistPer3            as logical no-undo get. set.
    define public property dTauxAmmortissementTravaux as decimal no-undo get. set.
    define public property iNbAmmortissementTravaux   as integer no-undo get. set.

    constructor public parametrageLoi():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        
    end constructor.

    method override public void reload (pcCodeLoi as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcAncSesUse as character no-undo.
        
        super:reload("CDLOI", pcCodeLoi).

        assign
            vcAncSesUse = session:numeric-format
            session:numeric-format  = "EUROPEAN"           //les taux sont stockes au format europeen dans ladb
        .
        assignAmmortissement().
        assignAmmortissementTravaux().
        session:numeric-format = vcAncSesUse.
    
    end method.

    method private void assignAmmortissement():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcTempo as character no-undo.
        
        assign 
            this-object:lParamExistPer1         = no
            this-object:dTauxAmmortissementPer1 = 0
            this-object:inbAmmortissementPer1   = 0
            this-object:lParamExistPer2         = no
            this-object:dTauxAmmortissementPer2 = 0
            this-object:inbAmmortissementPer2   = 0
            this-object:lParamExistPer3         = no
            this-object:dTauxAmmortissementPer3 = 0
            this-object:inbAmmortissementPer3   = 0
            vcTempo = entry(1, this-object:zone2, "&")            
        .
        if vcTempo <> ""
        then assign 
                 this-object:lParamExistPer1         = yes
                 this-object:dTauxAmmortissementPer1 = decimal(entry(1,entry(1, vcTempo, "#"), "@"))
                 this-object:inbAmmortissementPer1   = integer(entry(2,entry(1, vcTempo, "#"), "@"))
        .
        if num-entries(vcTempo, "#") >= 2 
        then assign 
                 this-object:lParamExistPer2         = yes
                 this-object:dTauxAmmortissementPer2 = decimal(entry(1, entry(2, vcTempo, "#"), "@"))
                 this-object:inbAmmortissementPer2   = integer(entry(2, entry(2, vcTempo, "#"), "@"))
        .
        if num-entries(vcTempo, "#") >= 3 
        then assign 
                 this-object:lParamExistPer3         = yes
                 this-object:dTauxAmmortissementPer3 = decimal(entry(1, entry(3, vcTempo, "#"), "@"))
                 this-object:inbAmmortissementPer3   = integer(entry(2, entry(3, vcTempo, "#"), "@"))
        .        
    
    end method.
    
    method private void assignAmmortissementTravaux():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define variable vcTempo as character no-undo.

        assign 
            this-object:dTauxAmmortissementTravaux = 0
            this-object:inbAmmortissementTravaux   = 0
        .
        if num-entries(this-object:zone2, "&") >= 2 
        then do:
            vcTempo = entry(2, this-object:zone2, "&").
            if num-entries(vcTempo, "@") >= 2 
            then assign 
                     this-object:dTauxAmmortissementTravaux = decimal(entry(1, vcTempo, "@"))
                     this-object:inbAmmortissementTravaux   = integer(entry(2, vcTempo, "@"))
            .
        end.

    end method.

end class.
