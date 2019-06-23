/*------------------------------------------------------------------------
File        : workflow.p
Purpose     :
Author(s)   : GGA - 2017/04/19
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2libelle.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{commercialisation/include/workflow.i}

function getLibelle returns character private(piNoLibelle as integer):
    /*------------------------------------------------------------------------------
    Purpose:  Recherche libelle workflow
    Notes:    si libelle libre alors c'est qu'il y a eu modification du libelle alors
              on retourne ce libelle; si non retour du libelle de la table des messages
    ------------------------------------------------------------------------------*/
    define buffer gl_libelle for gl_libelle.

    for first gl_libelle no-lock
        where gl_libelle.noidt = piNoLibelle
          and gl_libelle.tpidt = {&TYPLIBELLE-workflow}:
        if gl_libelle.libellelibre > "" then return gl_libelle.libellelibre.
        return outilTraduction:getLibelle(string(gl_libelle.nomes)).
    end.
    return "".

end function.

function getNumeroOrdre returns integer private(piNoLibelle as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du numéro d'ordre du workflow
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer gl_libelle for gl_libelle.

    for first gl_libelle no-lock
        where gl_libelle.noidt = piNoLibelle
          and gl_libelle.tpidt = {&TYPLIBELLE-workflow}:
        return gl_libelle.noordre.
    end.
    return 0.

end function.

procedure getRelationWorkflow:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beWorkflow.cls
    -------------------------------------------------------------------l-----------*/
    define output parameter table for ttworkflow.

    define buffer gl_workflow for gl_workflow.

    empty temp-table ttworkflow.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each gl_workflow no-lock:
        create ttworkflow.
        assign
            ttworkflow.CRUD                    = 'R'
            ttworkflow.iOrdre                  = getNumeroOrdre(gl_workflow.noworkflow1)
            ttworkflow.iNumeroWorkflowEnCours  = gl_workflow.noworkflow1
            ttworkflow.iNumeroWorkflowSuivant  = gl_workflow.noworkflow2
            ttworkflow.cLibelleWorkflowEnCours = getLibelle(gl_workflow.noworkflow1)
            ttworkflow.cLibelleWorkflowSuivant = getLibelle(gl_workflow.noworkflow2)
            ttworkflow.lPassageGestionnaire    = gl_workflow.fggestion
            ttworkflow.lPassagecommercial      = gl_workflow.fgcommercial
            ttworkflow.lPassagelogiciel        = gl_workflow.fglogiciel
            ttworkflow.dtTimestamp             = datetime(gl_workflow.dtmsy, gl_workflow.hemsy)
            ttworkflow.rRowid                  = rowid(gl_workflow)
        .
    end.

end procedure.
