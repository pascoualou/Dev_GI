/*------------------------------------------------------------------------
File        : IBANRoleContrat.p
Purpose     : Recherche du no contrat banque pour un role et un contrat
Created     : SPo 2018/06/2018
Notes       : ancien include BquePrel.i - procedure IBAN-RoleContrat
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure IBAN-RoleContrat:
    /*------------------------------------------------------------------------------
    Purpose: Recherche de l'IBAN en cours pour un role + contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat      as character    no-undo.
    define input parameter piNumeroContrat    as int64        no-undo.
    define input parameter pcTypeRole         as character    no-undo.
    define input parameter piNumeroRole       as int64        no-undo.
    define output parameter piNoContratBanque as integer      no-undo.
    define output parameter pcIBAN            as character    no-undo.

    define buffer roles for roles.
    define buffer rlctt for rlctt.
    define buffer ctanx for ctanx.

    for first roles no-lock
        where roles.tprol = pcTypeRole and roles.norol = piNumeroRole:
        for first rlctt no-lock
            where rlctt.Tpct1 = pcTypeContrat
              and rlctt.Noct1 = piNumeroContrat
              and rlctt.Tpidt = pcTypeRole
              and rlctt.Noidt = piNumeroRole
              and rlctt.Tpct2 = {&TYPECONTRAT-RIB}
           ,first ctanx no-lock
            where ctanx.tpcon = rlctt.tpct2
              and ctanx.nocon = rlctt.noct2:
            assign
                piNoContratBanque = ctanx.nocon
                pcIBAN            = ctanx.iban
                .
        end.
        if piNoContratBanque = 0 then do:
            /* Récupération d'un compte bancaire du tiers s'il en a un*/
            for each ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-RIB}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = roles.notie
                break by ctanx.nocon:
                if first (ctanx.nocon) or ctanx.tpact = "DEFAU" then do:
                    assign
                        piNoContratBanque = ctanx.nocon
                        pcIBAN            = ctanx.iban
                    .
                end.
            end.
        end.
    end.
end procedure.
