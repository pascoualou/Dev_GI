/*------------------------------------------------------------------------
File        : tryCatch.i
Purpose     : bloc de controle d'erreur dans une classe be.
Author(s)   : kantena - 2017/06/15 
Notes       : 2 paramètres possibles
    - &ligne donne la ligne ({&line-number} dans l'appelant
    - &bypassErreur indique si l'on doit prendre en compte l'erreur dans le catch.
    selfDestroy est positionné à faux par la classe qui aura instancié une autre classe,
    sinon, le destructeur de la classe courante fait un 'ménage' intensif et détruit aussi l'appelant!!
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/

    define variable viSyserr   as integer   no-undo.
    define variable vcMessage  as character no-undo.
    define variable voMyErreur as class progress.lang.appError no-undo.

    {&_proparse_ prolint-nowarn(tablename)}
    catch voErreur as Progress.Lang.Error:
        &if defined(bypassErreur) = 0 or "{&bypassErreur}"="false"
        &then
        do viSyserr = voErreur:numMessages to 1 by -1:
            vcMessage = voErreur:GetMessage(viSyserr).
            message 'catch:' vcMessage.  // toutes les erreurs dans le log Progress - pas besoin de l'heure, ni de la ligne
            &if defined(ligne)
            &then vcMessage = substitute("&1-&2-&3@&4 - catch:&5.cls ligne {&ligne} - &6"
                                 , year(today), string(month(today), '99'), string(day(today), '99')
                                 , string(time, 'HH:MM:SS')
                                 , this-object:GetClass():TypeName, vcMessage).
            &else vcMessage = substitute("&1-&2-&3@&4 - catch:&5.cls - &6"
                                 , year(today), string(month(today), '99'), string(day(today), '99')
                                 , string(time, 'HH:MM:SS')
                                 , this-object:GetClass():TypeName, vcMessage).
            &endif
            if viSyserr = 1 then do:     // Uniquement la dernière erreur en retour UI
                voMyErreur = new progress.lang.appError(vcMessage).
                undo, throw voMyErreur.
            end.
        end.
        message 'erreur non catchée -------------------------------------------------------'.   // Log progress - Si on a le cas un jour, à suivre!!!
        {&_proparse_ prolint-nowarn(tablename)}
        undo, throw voErreur.
        &endif
    end catch.

    finally:
        if valid-handle(outilHandle:hTransactionManager)       
        then do:
            &if defined(bypassErreur) = 0 or "{&bypassErreur}"="false"
            &then
            {&_proparse_ prolint-nowarn(tablename)}
            if not valid-object(voErreur)                                     // si pas d'erreur technique
            and not can-find(first ttError where ttError.iType >= {&error})   // et pas d'erreur fonctionnelle
            then run transactionCommit   in outilHandle:hTransactionManager.  // On peut commiter la transaction
            else run transactionRollback in outilHandle:hTransactionManager.  // pas obligatoire, comportement par défaut.
            &else
            run transactionCommit   in outilHandle:hTransactionManager.       // On peut commiter la transaction
            &endif
        end.
        if valid-object(this-object:GetClass():GetProperty("selfDestroy"))
        and this-object:GetClass():GetProperty("selfDestroy"):toString() begins "PUBLIC PROPERTY selfDestroy AS LOGICAL"
        and not dynamic-property(this-object, "selfDestroy")  // On ne peut pas faire directement dynprop, génère une erreur (pas envie de la trapper!!).
        then . // message "Finally: selfDestroy = false, pas de delete object this-object".
        else do:
            // message "Finally: delete object this-object".  
            delete object this-object.    // si pas appelé par une autre classe, appel du destructeur pour supprimer tous les handles
        end.
    end finally.
