/*------------------------------------------------------------------------
File        : erreur.p
Purpose     : Permet au controller d'accéder aux outils de gestion des erreurs
Author(s)   : kantena - 2017/02/08
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure createError:
    /*------------------------------------------------------------------------------
    Purpose: creation d'une occurrence ttError
    Notes  : service utilisé par les .cls
    ------------------------------------------------------------------------------*/
    define input parameter piSeverity   as integer   no-undo.
    define input parameter piMessage    as integer   no-undo.
    define input parameter pcListeSubst as character no-undo.

    mError:createError(piSeverity, piMessage, pcListeSubst).

end procedure.
