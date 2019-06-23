/*------------------------------------------------------------------------
File        : soldeCompte.p
Purpose     :
Author(s)   : gg  -  2017/03/21
Notes       : pour appel du programme cadb/gestion/solcpt.p
Tables      :
----------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/soldeCompte.i}

procedure getSoldeCompte:
    /*------------------------------------------------------------------------------
    Purpose: todo - utiliser une collection plutot que chaine | comme paramètre pour solcpt.p
    Notes  : service utilisé par beSoldeCompte.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat      as character no-undo.
    define input parameter piNumeroMandat    as int64     no-undo.
    define input parameter pcCpt             as character no-undo.
    define input parameter pcTypeSolde       as character no-undo.
    define output parameter table for ttSoldeCompte.

    define variable vcParamEnt as character no-undo.
    define variable vcParamSor as character no-undo.

    empty temp-table ttSoldeCompte.

message "soldecompte cTypeMandat "
        "pcTypeMandat" pcTypeMandat
        "piNumeroMandat" piNumeroMandat
        "pcCpt" pcCpt
        "pcTypeSolde" pcTypeSolde.

    vcParamEnt = substitute("&1|&2|&3|&4|&5|&6|&7|&8|"
                          , mtoken:getSociete(pcTypeMandat)
                          , piNumeroMandat
                          , substring(pcCpt, 1, 4, 'character')
                          , substring(pcCpt, 5)
                          , pcTypeSolde
                          , string(today, "99/99/9999")
                          , ""
                          , "").
    run compta/souspgm/solcpt.p (vcParamEnt, output vcParamSor).
    create ttSoldeCompte.
    if num-entries(vcParamSor, '|') >= 4
    then assign
        ttSoldeCompte.dSolde     = decimal(entry(1, vcParamSor, "|"))
        ttSoldeCompte.dDebit     = decimal(entry(2, vcParamSor, "|"))
        ttSoldeCompte.dCredit    = decimal(entry(3, vcParamSor, "|"))
        ttSoldeCompte.dSoldeEuro = decimal(entry(4, vcParamSor, "|"))
    .
end procedure.
