/*-----------------------------------------------------------------------------
File        : tbeclat.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  -- diverses variables 
              NB: il faut que la variable pré-processeur &VARLOC soit pas définie
-----------------------------------------------------------------------------*/
    define variable iCdRub        as integer no-undo.
    define variable iCdLib        as integer no-undo.
    define variable iCdRubTva     as integer no-undo.
    define variable iCdRubTva-old as integer no-undo.
    define variable iCdLibTva     as integer no-undo.
    define variable dMtEnc          as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtEnc-Euro     as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtEncTva       as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtEncTva-Euro  as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtRegl         as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtRegl-Euro    as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtReglTva      as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtReglTva-Euro as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtAdbtva       as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtAdbtva-Euro  as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dSoldeL         as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable VlRBHO          as logical                              no-undo.
    define variable tmp-dadeb  as date no-undo.
    define variable tmp-dafin  as date no-undo.
    define variable tmp-date   as date no-undo. /** MP le 23/10/00 **/
    define variable iMdGerGlb    as integer    no-undo.
    define variable iMdGesCom    as integer    no-undo.
/*
    define variable iCode         as integer no-undo.
    define variable iCompteur     as integer no-undo.
    define variable iLong         as integer no-undo.
    define variable iLong2        as integer no-undo.
    define variable cDateCompta     as character no-undo.
    define variable cRetourBail     as character no-undo.
    define variable cErr            as character no-undo.
    define variable cMntImpaye-Euro as character no-undo.
    define variable cMntImpaye      as character no-undo.
    define variable cMnt-Euro       as character no-undo.
    define variable cMnt            as character no-undo.
    define variable dDateSolde as date no-undo.
    define variable lDebugProg      as logical                              no-undo.
    define variable VdTotHon        as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable VdTotEnc        as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dSomRub         as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtImpaye-Euro  as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
    define variable dMtImpaye       as decimal format "->>>,>>>,>>>,>>9.99" no-undo.
*/
