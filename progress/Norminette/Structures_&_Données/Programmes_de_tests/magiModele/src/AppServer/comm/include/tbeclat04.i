/*-----------------------------------------------------------------------------
File        : tbeclat04.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  -- diverses temp-table  
              NB: il faut que la variable pré-processeur &VARLOC soit pas définie
-----------------------------------------------------------------------------*/

define temp-table adbtva-tmp no-undo
    like adbtva
    index ligtva-i soc-cd etab-cd num-int
.
define temp-table ijou-tmp2 no-undo
    field cd-jou like ijou.jou-cd
.
