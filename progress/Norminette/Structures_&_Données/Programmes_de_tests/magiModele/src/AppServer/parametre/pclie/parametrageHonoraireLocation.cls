/*------------------------------------------------------------------------
File        : parametrageHonoraireLocation.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclholoc.p
derniere revue: 2018/04/11 - phm. OK
------------------------------------------------------------------------*/

class parametre.pclie.parametrageHonoraireLocation inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageHonoraireLocation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("HOLOQ").
    end constructor.

    method public logical isActif():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: agence/service
        ------------------------------------------------------------------------------*/
        return this-object:isDbParameter and this-object:zon01 = "00001".
    end method.

    method public logical ancienneRubriqueInterdite(piCodeRubrique as integer):
        /*------------------------------------------------------------------------------
        Purpose: Ancienne Rubrique interdite
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        for first pclie no-lock
            where pclie.tppar = this-object:tppar 
              and pclie.int03 = piCodeRubrique :
            return true.
        end.
        return false.
    end method.
    
    method public logical auMoinsUnArticle(piCodeRubrique as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        for first pclie no-lock
            where pclie.tppar = this-object:tppar 
              and pclie.int01 = piCodeRubrique
              and pclie.zon02 > "" :
            return true.
        end.
        return false. 
    end method.

    method public integer nouvelleRubriqueFrais():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        for first pclie no-lock
            where pclie.tppar = this-object:tppar 
              and pclie.int03 = 600
              and pclie.int04 = 01
              and pclie.zon02 > "":
            return integer(pclie.int01).
        end.
        return 0.
    end method.
    method public character getCodeArticleProprietaire(piInt01 as integer, piInt02 as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        initProperty().
        this-object:tppar = "HOLOQ".
        for first pclie no-lock
            where pclie.tppar = this-object:tppar
              and pclie.int01 = piInt01
              and pclie.int02 = piInt02:
            assignTable2property(buffer pclie).
            return this-object:zon02.
        end.
        return "".
    end method.
    method public decimal getMnt1():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:mnt01.
    end method.
    method public int64 getRubriqueProprietaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:int03.
    end method.
    method public int64 getLibelleProprietaire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:int04.
    end method.
    method public character getCodeArticleLocataire(piInt03 as integer, piInt04 as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        initProperty().
        this-object:tppar = "HOLOQ".
        for first pclie no-lock
            where pclie.tppar = this-object:tppar
              and pclie.int03 = piInt03
              and pclie.int04 = piInt04:
            assignTable2property(buffer pclie).
           return this-object:zon02.
        end.
        return "".
    end method.
    method public int64 getRubriqueLocataire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:int01.
    end method.
    method public int64 getLibelleLocataire():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        return this-object:int02.
    end method.

end class.
