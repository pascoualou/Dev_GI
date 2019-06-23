/*------------------------------------------------------------------------
File        : syspr.cls
Purpose     : classe générique de paramétrage défini dans sys_pr 
Author(s)   : devweb1  -  2017/11/08
Notes       : 
------------------------------------------------------------------------*/
using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspr.syspr: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}
    define public property isDbParameter as logical no-undo get. set.
    define public property giNumeroItem  as integer no-undo get. set.
    define public property cNomCombo     as character no-undo get. set.
    define public property tppar    as character no-undo get. set.
    define public property cdpar    as character no-undo get. set.
    define public property zone1    as decimal   no-undo get. set.
    define public property zone2    as character no-undo get. set.
    define public property LbparZo1 as character no-undo get. set.
    define public property nome1    as integer   no-undo get. set.
    define public property nome2    as integer   no-undo get. set.
    define public property LbparZo2 as character no-undo get. set.
    
    constructor public syspr():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: Pour les besoins de chargement de combo on se passe du reload
        ------------------------------------------------------------------------------*/
    end constructor.    
    constructor public syspr(pcTypeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTypeParam).
    end constructor.
    constructor public syspr(pcTypeParam as character, pcCodeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTypeParam, pcCodeParam).
    end constructor.
    constructor public syspr(pcTypeParam as character, pdeZone1 as decimal):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTypeParam, pdeZone1).
    end constructor.
    constructor public syspr(pcTypeParam as character, pcNomCombo as character, plDummy as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTypeParam).
        assign
            cNomCombo = pcNomCombo
        .
    end constructor.
    
    method public logical isParamExist(pcTppar as character, pcCdPar as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
        return can-find(first sys_pr no-lock 
                        where sys_pr.tppar = pcTppar 
                          and sys_pr.cdpar = pcCdPar).
    end method.    
    
    method public void initProperty():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            this-object:isDbParameter = false
            this-object:tppar         = ""
            this-object:cdpar         = ""
            this-object:zone1         = 0
            this-object:zone2         = ""
            this-object:nome1         = 0
            this-object:nome2         = 0
            this-object:LbparZo1      = ""
            this-object:LbparZo2      = ""
            this-object:cNomCombo     = ""
        .            
    end method.
    
    method public void reload(pcTypeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.
        
        initProperty().
        for first sys_pr no-lock
            where sys_pr.tppar = pcTypeParam:
            assignTable2property(buffer sys_pr).
        end.
    end method.
    method public void reload(pcTypeParam as character, pcCodeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.
        
        initProperty().
        for first sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
              and sys_pr.cdpar = pcCodeParam:
            assignTable2property(buffer sys_pr).
        end.
    end method.
    method public void reload(pcTypeParam as character, pdeZone1 as decimal):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        initProperty().
        for first sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
              and sys_pr.zone1 = pdeZone1:
            assignTable2property(buffer sys_pr).
        end.
    end method.
    method public void reload(pcTypeParam as character, pcNomCombo as character, plDummy as logical):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        this-object:reload(pcTypeParam).
        assign
            cNomCombo       = pcNomCombo
        .
    end method.    
    method private void createttCombo(pcNomCombo as character, pcCode as character, pcLibelle as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        create ttCombo.
        assign
            giNumeroItem             = giNumeroItem + 1
            ttcombo.iSeqId           = giNumeroItem
            ttCombo.cNomCombo        = pcNomCombo
            ttCombo.cCode            = trim(pcCode)
            ttCombo.cLibelle         = trim(pcLibelle)
        .
    end method.

    method private void assignTable2property(buffer pbSyspr for sys_pr):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            this-object:isDbParameter = true
            this-object:tppar    = pbSyspr.tppar
            this-object:cdpar    = pbSyspr.cdpar
            this-object:zone1    = pbSyspr.zone1
            this-object:zone2    = pbSyspr.zone2
            this-object:nome1    = pbSyspr.nome1
            this-object:nome2    = pbSyspr.nome2
            this-object:LbparZo1 = ""
            this-object:LbparZo2 = ""
        .
    end method.
    method public integer getComboParametre(pcTypeParam as character, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libellé long sur nome1
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        for each sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
               by sys_pr.cdpar:
            createttCombo(pcNomCombo, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1)).
        end.
        return giNumeroItem.
    end method.
    method public integer getComboParametreCourt(pcTypeParam as character, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libelle court sur nome2
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        for each sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
               by sys_pr.cdpar:
            createttCombo(pcNomCombo, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome2)).
        end.
        return giNumeroItem.
    end method.
    method public integer getComboParametreCdpar(pcTypeParam as character, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libelle court sur nome2
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        for each sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
               by sys_pr.cdpar:
            createttCombo(pcNomCombo, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.cdpar)).
        end.
        return giNumeroItem.
    end method.
    method public integer getComboParametreZone1(pcTypeParam as character, pcZone1 as decimal, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libelle court sur nome2
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        for each sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
              and sys_pr.zone1 = pcZone1
               by sys_pr.cdpar:
            createttCombo(pcNomCombo, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1)).
        end.
        return giNumeroItem.
    end method.
    method public integer getComboParametreZone2(pcTypeParam as character, pcZone1 as decimal, pcZone2 as character, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libelle court sur nome2
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        for each sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
              and sys_pr.zone1 = pcZone1
              and sys_pr.zone2 = pcZone2
               by sys_pr.cdpar:
            createttCombo(pcNomCombo, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1)).
        end.
        return giNumeroItem.
    end method.
    method public integer getComboParametreOnlyZone2(pcTypeParam as character, pcZone2 as character, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libelle court sur nome2
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.

        for each sys_pr no-lock
            where sys_pr.tppar = pcTypeParam
              and sys_pr.zone2 = pcZone2
            by sys_pr.zone1:
            createttCombo(pcNomCombo, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1)).
        end.
        return giNumeroItem.
    end method.
    method public integer creationttCombo(pcNomCombo as character, pcCode as character, pcLibelle as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  :
    ------------------------------------------------------------------------------*/
        for last ttCombo where ttCombo.cNomCombo = pcNomCombo: giNumeroItem = ttCombo.iSeqId. end.
        create ttCombo.
        assign
            giNumeroItem             = giNumeroItem + 1
            ttcombo.iSeqId           = giNumeroItem
            ttCombo.cNomCombo        = pcNomCombo
            ttCombo.cCode            = trim(pcCode)
            ttCombo.cLibelle         = trim(pcLibelle)
        .
    end method.
    method public character getTraductionCourt():
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  :
    ------------------------------------------------------------------------------*/
        return outilTraduction:getLibelle(this-object:nome2).
    end method.
    method public character getTraductionLong():
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  :
    ------------------------------------------------------------------------------*/
        return outilTraduction:getLibelle(this-object:nome1).
    end method.

    method public void setgiNumeroItem(piNumeroItem as integer) :
    /*------------------------------------------------------------------------------
     Purpose: Assignation de giNumeroItem
     Notes:
    ------------------------------------------------------------------------------*/
        giNumeroItem = piNumeroItem.
    end method.    
end class.
