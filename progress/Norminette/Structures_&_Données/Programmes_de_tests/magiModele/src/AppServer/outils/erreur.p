/*------------------------------------------------------------------------
File        : erreur.p
Purpose     : Permet au controller d'acc�der aux outils de gestion des erreurs
Author(s)   : kantena - 2017/02/08
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit �tre positionn�e juste apr�s using */

procedure createError:
    /*------------------------------------------------------------------------------
    Purpose: creation d'une occurrence ttError
    Notes  : service utilis� par les .cls
    ------------------------------------------------------------------------------*/
    define input parameter piSeverity   as integer   no-undo.
    define input parameter piMessage    as integer   no-undo.
    define input parameter pcListeSubst as character no-undo.

    mError:createError(piSeverity, piMessage, pcListeSubst).

end procedure.
