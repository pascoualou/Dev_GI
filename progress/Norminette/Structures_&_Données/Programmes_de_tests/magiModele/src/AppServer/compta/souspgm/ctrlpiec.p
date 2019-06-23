/*------------------------------------------------------------------------
File        : ctrlpiec.p
Purpose     : Programme de controle d'equilibre d'une piece
Author(s)   : OF - 1999/08/13;  gga -  2017/06/21
Notes       : reprise du pgm cadb\src\batch\ctrlpiec.p
----------------------------------------------------------------------*/

procedure ctrlpiecCtrlEquilibre:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par odreltx.p
    ------------------------------------------------------------------------------*/
    define input  parameter prRowid       as rowid   no-undo.
    define output parameter pdSolde       as decimal no-undo.
    define output parameter pdTotalDebit  as decimal no-undo.
    define output parameter pdTotalCredit as decimal no-undo.

    define buffer cecrsai for cecrsai.
    define buffer cecrln  for cecrln.

message "debut ctrlpiecCtrlEquilibre ".

    /* Recherche de la piece */
    for first cecrsai no-lock
        where rowid(cecrsai) = prRowid:
        for each cecrln no-lock
            where cecrln.soc-cd         = cecrsai.soc-cd
              and cecrln.mandat-cd      = cecrsai.etab-cd
              and cecrln.jou-cd         = cecrsai.jou-cd
              and cecrln.mandat-prd-cd  = cecrsai.prd-cd
              and cecrln.mandat-prd-num = cecrsai.prd-num
              and cecrln.piece-int      = cecrsai.piece-int:
            if cecrln.sens
            then pdTotalDebit  = pdTotalDebit  + cecrln.mt.
            else pdTotalCredit = pdTotalCredit + cecrln.mt.
        end.
        pdSolde = pdTotalDebit - pdTotalCredit.
    end.

end procedure.
