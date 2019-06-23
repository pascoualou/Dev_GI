/*------------------------------------------------------------------------
File        : dateFinMandat.i
Purpose     : Module pour récupérer la date de résiliation et la date ODFM d'un mandat de Gestion 
Author(s)   : SY - 2013/03/11 : GGA - 2017/10/16
Notes       : reprise include adb\comm\dtfinmdt.i
              nécessite cadbgestion/include/soldmdt1.i (soldmdt1Controle).
derniere revue: 2018/07/29 - phm: 
----------------------------------------------------------------------*/

procedure dateFinMandat private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define output parameter pdaResiliation  as date      no-undo.
    define output parameter pdaOdfm         as date      no-undo.

    define variable vdaArchivage as date no-undo.

    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat
          and ctrat.dtree <> ?:
        pdaResiliation = ctrat.dtree.
        /*--> Regarder s'il existe des ecritures ODFM sur le mandat */
        run soldmdt1Controle(integer(if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} then mToken:cRefCopro else mToken:cRefGerance),
                             piNumeroContrat,
                             output pdaOdfm,
                             output vdaArchivage).
    end.
end procedure.
