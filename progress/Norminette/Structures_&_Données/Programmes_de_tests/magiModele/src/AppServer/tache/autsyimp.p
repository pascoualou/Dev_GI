/*------------------------------------------------------------------------
File        : autsyimp.p
Purpose     : Simulation d'un contrat imputation partic
Author(s)   : LGI/RT - 1996/01/09  /  kantena - 2017/01/02
Notes       :
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit �tre positionn�e juste apr�s using */
{application/include/error.i}
{adblib/include/assat.i}

define input parameter pcTypeContrat as character no-undo.
define input parameter piNumContrat  as integer   no-undo.
define input parameter pcTypeTache   as character no-undo.
define output parameter pcCodeRetour as character no-undo initial '00'.
