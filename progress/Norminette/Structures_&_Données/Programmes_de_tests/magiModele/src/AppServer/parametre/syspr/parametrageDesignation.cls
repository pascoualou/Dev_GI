/*------------------------------------------------------------------------
File        : parametrageDesignation.cls
Purpose     : 
Author(s)   : kantena  -  2017/11/08
Notes       : 
------------------------------------------------------------------------*/

using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspr.parametrageDesignation inherits parametre.syspr.syspr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}

    constructor public parametrageDesignation():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            this-object:tppar     = "NTPIE"
            this-object:cNomCombo = "CMBDESIGNATIONPIECE"
        .
    end constructor.

    method public void getComboDesignation (output table ttCombo):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes  : todo - remplacer pclie par parametrageNaturePiece (à créer éventuellement)
        ------------------------------------------------------------------------------*/
        define buffer sys_pr for sys_pr.
        define buffer pclie  for pclie.
    
        define variable viNumeroItem as integer no-undo.
    
        // Chargement des pièces "GI"
        for each sys_pr no-lock where sys_pr.tppar = this-object:tppar:
            create ttCombo.
            assign 
                viNumeroItem      = viNumeroItem + 1
                ttcombo.iSeqId    = viNumeroItem
                ttCombo.cNomCombo = this-object:cNomCombo
                ttCombo.cCode     = sys_pr.cdpar
                ttCombo.cLibelle  = outilTraduction:getLibelle(sys_pr.nome1)
                ttCombo.cLibelle2 = string(entry(1, sys_pr.zone2, "@") = "P")
            .
        end.
        /* Chargement de la saisie client */
        for each pclie no-lock
           where pclie.tppar = "NTPIE":
            /* Ce code existe ? */
            find first ttCombo
                where ttCombo.cNomCombo = this-object:cNomCombo
                  and ttCombo.cCode     = pclie.zon01 no-error.
            if not available ttCombo
            /* Si la désignation n'existe pas on l'ajoute */
            then do:
                create ttCombo.
                assign 
                    viNumeroItem      = viNumeroItem + 1
                    ttcombo.iSeqId    = viNumeroItem        
                    ttCombo.cNomCombo = this-object:cNomCombo
                    ttCombo.cCode     = pclie.zon01
                    ttCombo.cLibelle  = if pclie.zon02 = "GI" then ttCombo.cLibelle else pclie.zon04
                    ttCombo.cLibelle2 = string(pclie.zon05 = "P")
                .
            end.
            /* Si la désignation ne doit pas être affichée on la supprime */
            else if pclie.zon03 = "S" then delete ttCombo.
        end.
    end method.
    
    method public character getLibelleDesignation ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer pclie  for pclie.

        define variable vcLibelle as character no-undo.

        vcLibelle = outilTraduction:getLibelle(this-object:nome1).

        /* Chargement de la saisie client */
        for first pclie no-lock
            where pclie.tppar = "NTPIE"
              and pclie.zon01 = this-object:cdpar:
            vcLibelle = if pclie.zon03 = "S"
                        then ""
                        else if pclie.zon02 = "GI" then vcLibelle else pclie.zon04
            .
        end.
    end method.
end class.
