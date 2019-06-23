/*------------------------------------------------------------------------
File        : parametrageRubriqueQuittHonoCabinet.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       : pclholoq.p
------------------------------------------------------------------------*/

class parametre.pclie.parametrageRubriqueQuittHonoCabinet inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/
    constructor public parametrageRubriqueQuittHonoCabinet():
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
    method public character donneCodeArticleFacturation(piNumeroFamille as integer, piNumeroSousFamille as integer):
        /*------------------------------------------------------------------------------
         Purpose: Récupère le code article de facturation associé à une famille/sous-famille
         Notes: 
        ------------------------------------------------------------------------------*/
        define buffer pclie for pclie.
        define buffer rubqt for rubqt.

        for each pclie no-lock
            where pclie.tppar = "HOLOQ"
              and pclie.zon02 > ""
              and pclie.mnt01 > 0         // Rubrique avec ventilation 70-30%
              and pclie.mnt01 < 100
          , first rubqt no-lock
            where rubqt.cdrub = pclie.int03 
              and rubqt.cdlib = pclie.int04
              and rubqt.cdfam = piNumeroFamille
              and rubqt.cdsfa = piNumeroSousFamille
            by rubqt.cdrub by rubqt.cdlib:    // nath à revoir
            return pclie.zon02.
        end.
        return ''.
    end method.

end class.
