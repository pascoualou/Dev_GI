/*------------------------------------------------------------------------
File        : parametre.p
Purpose     :
Author(s)   : kantena - 2016/07/13
Notes       :
------------------------------------------------------------------------*/

using parametre.pclie.pclie.
{oerealm/include/instanciateTokenOnModel.i} /* Doit �tre positionn�e juste apr�s using */

define variable ghttParam as handle no-undo.      // le handle de la temp table � mettre � jour

procedure getParam:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilis� par beParam.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcNomTable  as character no-undo.
    define input  parameter pcTypeParam as character no-undo.
    define output parameter table-handle phttParam.

    ghttParam = phttParam.
    case pcNomTable:
        when "pclie" then run getPclie(pcTypeParam).
    end case.
    delete object ghttParam no-error.
    error-status:error = false no-error.
    return.
end procedure.

procedure getPclie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeParam as character no-undo.

    define variable voParametre as class pclie no-undo.
    define variable viNbParam   as integer   no-undo.
    define variable vcItem      as character no-undo.

    do viNbParam = 1 to num-entries(pcTypeParam, ","):
        vcItem = entry(viNbParam, pcTypeParam).
        if can-do("CDEVE,CDAGE", vcItem) then do:
            voParametre = new pclie(vcItem).
            voParametre:getttParam(table-handle ghttParam by-reference).
            delete object voParametre.
        end.
    end.
end procedure.
