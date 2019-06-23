/*------------------------------------------------------------------------
File        : parametrageSauveCRG.cls
Description :
Author(s)   : kantena  -  2017/09/29
Notes       :
------------------------------------------------------------------------*/
block-level on error undo, throw.

class parametre.pclie.parametrageSauveCRG inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    constructor public parametrageSauveCRG():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("SVCRG").
    end constructor.

    method public int64 getLastSauveCRG():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        for last pclie no-lock
            where pclie.tppar = "SVCRG"
            use-index ix_pclie03:
            return pclie.int01 + 1.
        end.
        return 1.
    end method.

    method public void sauvePclieCRG(voPclie as class Progress.Lang.Object, piNoSauvegarde as integer):
        /*------------------------------------------------------------------------------
        Purpose: Sauvegarde de la précédente version du pclie
        Notes  :
        ------------------------------------------------------------------------------*/  
        define variable vi       as integer   no-undo.
        define variable vcTppar  as character no-undo.
        define variable vhBuffer as handle    no-undo.
        define variable vhField  as handle    no-undo.
        define buffer pclie for pclie.

        assign
            vhBuffer = buffer pclie:handle
            vcTppar  = dynamic-property(voPclie, "tppar")
        .
        if not can-find(first pclie no-lock
                        where pclie.tppar = "SVCRG"
                          and pclie.int01 = piNoSauvegarde
                          and pclie.lbdiv = vcTppar)
        then do:
            create pclie.
            do vi = 1 to vhBuffer:num-items:
                assign
                    vhField                = vhBuffer:buffer-field(vi)
                    vhField:buffer-value() = dynamic-property(voPclie, vhField:name)
                .
            end.
            assign
                pclie.tppar = "SVCRG"
                pclie.int01 = piNoSauvegarde
                pclie.lbdiv = vcTppar
            .
        end.
    end method.

end class.
