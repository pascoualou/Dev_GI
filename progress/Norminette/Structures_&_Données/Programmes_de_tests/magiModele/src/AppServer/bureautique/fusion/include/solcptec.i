/*------------------------------------------------------------------------
File        : solcptec.i
Purpose     : Fonction Calcul du solde par rapport à date du document
Author(s)   : Kantena - 2018/02/05
Notes       :
Derniere revue: 2018/03/20 - phm
------------------------------------------------------------------------*/

function f_solcptec returns decimal(
    piNumeoSociete   as integer, piNumeroEtab as integer, pcCsscoll-cle as character, pcCcpt-cd as character, pcTypeSolde as character,
    pdaDateSolde     as date, pcRef-num as character,   /** N° de doc **/
    pcExtraComptable as character):    /** Insérer les écritures exta-comptables dans le solde **/
    define variable vcSolde      as character no-undo.
    define variable vcsscoll-cpt as character no-undo.

    run solcptec.p(substitute("&1|&2|&3|&4|&5|&6|&7|&8",
                              piNumeoSociete, piNumeroEtab, pcCsscoll-cle, pcCcpt-cd, pcTypeSolde, string(pdaDateSolde, "99/99/9999"), pcRef-num, pcExtraComptable),
                   output vcSolde).
    return decimal(entry(1, vcSolde, "|")) / 100.

end function.
