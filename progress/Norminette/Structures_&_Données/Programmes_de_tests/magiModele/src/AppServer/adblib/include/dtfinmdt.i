/*------------------------------------------------------------------------
File        : dtfinmdt.i
Purpose     : Module pour récupérer la date de résiliation et la date ODFM d'un mandat de Gestion 
Author(s)   : SY - 2013/03/11 : GGA - 2017/10/16
Notes       : reprise include adb\comm\dtfinmdt.i
----------------------------------------------------------------------*/

procedure DtFinMdt private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter pdaResiliation  as date      no-undo.
    define output parameter pdaOdfm         as date      no-undo.

    define variable vdaArchivage as date      no-undo.
    define variable viErrOut     as integer   no-undo.
    define variable vhProc       as handle    no-undo.

    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat
          and ctrat.dtree <> ?:
        pdaResiliation = ctrat.dtree.
        /*--> Regarder s'il existe des ecritures ODFM sur le mandat */
        run cadbgestion/soldmdt1.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run soldmdt1Controle in vhProc(integer(if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} then mToken:cRefCopro else mToken:cRefGerance),
                                       piNumeroContrat,
                                       output viErrOut, 
                                       output pdaOdfm,
                                       output vdaArchivage).
        run destroy in vhproc.   
    end.

end procedure.
