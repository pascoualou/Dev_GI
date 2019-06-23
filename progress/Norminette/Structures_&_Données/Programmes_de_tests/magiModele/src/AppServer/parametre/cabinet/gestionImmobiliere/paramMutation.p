/*------------------------------------------------------------------------
File        : paramMutation.p
Purpose     : parametres par defaut de l'application Mutations de gerance faites par la copropriete 
Author(s)   : GGA  2018/02/07
Notes       : reprise pgm adb/prmcl/pclmutag.p
------------------------------------------------------------------------*/

using parametre.pclie.parametrageMutation.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{parametre/cabinet/gestionImmobiliere/include/paramMutation.i}

procedure getParamMutation:
    /*------------------------------------------------------------------------------
    Purpose: lecture parametre gestion immo mutation
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttParamMutation.
 
    define variable voparametrageMutation as class parametrageMutation no-undo.

    empty temp-table ttParamMutation.
    create ttParamMutation.
    ttParamMutation.CRUD = "R".
    voparametrageMutation = new parametrageMutation().
    if voparametrageMutation:isDbParameter
    then assign
             ttParamMutation.lMutationGeranceCopro = voparametrageMutation:MutationGeranceDepuisCoproAutorise()
             ttParamMutation.dtTimestamp           = datetime(voparametrageMutation:dtmsy , voparametrageMutation:hemsy)
             ttParamMutation.rRowid                = voparametrageMutation:rRowid
    .
    delete object voparametrageMutation.

end procedure.

procedure setParamMutation:
    /*------------------------------------------------------------------------------
    Purpose: maj parametre gestion immo mutation
             on ne traite que les CRUD a U, mais si parametre inexistant alors creation 
    Notes  : service externe. 
    ------------------------------------------------------------------------------*/
    define input parameter table for ttParamMutation.
 
    define variable voparametrageMutation as class parametrageMutation no-undo.

    for first ttParamMutation where ttParamMutation.CRUD = "U":
        voparametrageMutation = new parametrageMutation().
        if voparametrageMutation:isDbParameter
        then voparametrageMutation:updateParamMutation(ttParamMutation.lMutationGeranceCopro).
        else voparametrageMutation:createParamMutation(ttParamMutation.lMutationGeranceCopro).
        delete object voparametrageMutation.
    end.     

end procedure.

