/*-----------------------------------------------------------------------------
File        : p10-2.p
Purpose     : 
Author(s)   : KANTENA - 2018/01/03
Notes       : repris de adb/comm/p10-2.i
deniere revue: 2018/04/09 - phm
todo         : la procédure initVariableDevise est-elle utilisée? programme à supprimer.
-----------------------------------------------------------------------------*/

using parametre.pclie.parametrageActivationEuro.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure initVariableDevise:
    /*---------------------------------------------------------------------------
    Purpose: Procedure qui charge les variables de devise dans un object collection
    Notes  : 
    ---------------------------------------------------------------------------*/ 
    define input        parameter piReference  as integer          no-undo.
    define input-output parameter poCollection as class collection no-undo.

    define variable voActivationEuro as class parametrageActivationEuro no-undo.
    define buffer ietab for ietab.

    /* Initialisation Var pour la compta (EURO) */
    // assign GiCodeSoc = piReference.
    // find first ietab where ietab.soc-cd  = GiCodeSoc no-lock no-error.
    find first ietab no-lock
        where ietab.soc-cd = piReference  no-error.
    if available ietab then do:
        /*  GiCodeEtab = ietab.etab-cd*/
        poCollection:set("GlDevUse", ietab.dev-cd).
        poCollection:set("GlDevRef", ietab.dev-cd).
    end.
    else do: 
        poCollection:set("GlDevUse", "EUR").
        poCollection:set("GlDevRef", "EUR").
    end.
    /* Recuperation du parametre de gestion ou non de l'euro */
    voActivationEuro = new parametrageActivationEuro().
    
    if not voActivationEuro:isDbParameter
    then poCollection:set("GlActEur", false).
    else poCollection:set("GlActEur", voActivationEuro:isEuroActif()).
    delete object voActivationEuro.
 
end procedure.
