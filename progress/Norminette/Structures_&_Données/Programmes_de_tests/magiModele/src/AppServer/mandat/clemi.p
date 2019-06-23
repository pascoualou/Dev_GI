/*------------------------------------------------------------------------
File        : clemi.p
Purpose     :
Author(s)   : kantena - 27/07/2016
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/clemi.i}

function getLibelleClemi returns character(pcCodeClemi as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for first clemi no-lock
        where clemi.cdcle = pcCodeClemi:
        return clemi.lbcle.
    end.
    return "".

end function.

procedure getClemi:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beCle.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat   as int64     no-undo.
    define input  parameter pcTypeMandat     as character no-undo.
    define input  parameter piNumeroImmeuble as integer   no-undo.
    define input  parameter pcStatutCle      as character no-undo.
    define output parameter table for ttClemi.

    define variable vhProcClemi as handle no-undo.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    empty temp-table ttClemi.
    run adblib/clemi_CRUD.p persistent set vhProcClemi.
    run getTokenInstance in vhProcClemi(mToken:JSessionId).

    if piNumeroImmeuble > 0 
    then run getClemi in vhProcClemi(?, ?, piNumeroImmeuble, ?, pcStatutCle, table ttClemi by-reference).
    else if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance}
    then for first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat :
        run getClemi in vhProcClemi(pcTypeMandat, piNumeroMandat, ?, ?, pcStatutCle, table ttClemi by-reference).              
    end.
    else if pcTypeMandat = {&TYPECONTRAT-mandat2Syndic}
    then for first ctrat no-lock
        where ctrat.tpcon = pcTypeMandat
          and ctrat.nocon = piNumeroMandat
      , first intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEBIEN-immeuble} :
        run getClemi in vhProcClemi(?, ?, intnt.noidt, ?, pcStatutCle, table ttClemi by-reference).
    end.
    run destroy in vhProcClemi.

end procedure.
