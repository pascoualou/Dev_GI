/*------------------------------------------------------------------------
File        : transactionManager.p
Purpose     : gestion d'une transaction pour plusieurs run on appserver.
Author(s)   : kantena - 2016/12/07
Notes       :
------------------------------------------------------------------------*/

/* This statement makes this procedure a transaction-initiating procedure */
transaction-mode automatic chained.

/*
procedure transactionBegin: /*  */
    /*------------------------------------------------------------------------
    Purpose : This empty internal procedure starts a transaction
    Notes   :
    ------------------------------------------------------------------------*/
end.
*/
procedure transactionCommit:
    /*------------------------------------------------------------------------
    Purpose : This internal proc arranges for a commit
    Notes   : service de validation de la transaction active.
    ------------------------------------------------------------------------*/
    define variable vhTrans as handle no-undo.

    vhTrans = this-procedure:transaction.
    if valid-handle(vhTrans) then vhtrans:set-commit().
end procedure.

procedure transactionRollback:
    /*------------------------------------------------------------------------
    Purpose : This internal proc arranges for a rollback
    Notes   : service de dévalidation de la transaction active.
    ------------------------------------------------------------------------*/
    define variable vhTrans as handle no-undo.

    vhTrans = this-procedure:transaction.
    if valid-handle(vhTrans) then vhTrans:set-rollback().
end procedure.

procedure destroy:
    /*------------------------------------------------------------------------
    Purpose : rollback sur destroy
    Notes   : service de dévalidation de la transaction active.
    ------------------------------------------------------------------------*/
//    run transactionCommit.
    run transactionRollback.
    delete procedure this-procedure.
end procedure.