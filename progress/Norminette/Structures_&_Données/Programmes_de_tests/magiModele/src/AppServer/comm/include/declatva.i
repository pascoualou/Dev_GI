/*------------------------------------------------------------------------
File        : declatva.i 
Purpose     : fonction controle declaration TVA
Author(s)   : DM 01/12  -  GGA 2017/12/06
Notes       : reprise comm/declatva.i
derniere revue: 2018/05/28 - phm: KO
        supprimer le code en commentaire, car non utilisé.

01  24/10/2014  DM    1014/0140 Pb date valid si chgmt type décla
02  16/11/2017  OF    #8597 Pb sur date de dernière déclaration
----------------------------------------------------------------------*/

function f_decla_valid returns date (piNumeroContrat as int64, piCodeSoc as integer): 
    /*------------------------------------------------------------------------------
    Purpose: recherche date de derniere déclaration validée 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vdaDerDeclVal as date no-undo.
    define buffer arectva for arectva.
    define buffer iparmdt for iparmdt.
    define buffer ietab   for ietab.
    define buffer tache   for tache.
  
    find first ietab no-lock 
         where ietab.soc-cd  = piCodeSoc
           and ietab.etab-cd = piNumeroContrat no-error.
    if not available ietab then return ?.

    find first tache no-lock  
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = ietab.etab-cd
          and tache.tptac = {&TYPETACHE-TVA}
          and tache.notac = 1 no-error.  
    if not available tache            /* la tache TVA n'est pas activée -> c'est la date de fin du dernier exercice cloturé */     
    then return (if ietab.exercice then ietab.dafinex1 else ietab.dadebex1 - 1).

    find first iparmdt no-lock 
        where iparmdt.soc-cd  = piCodeSoc
          and iparmdt.etab-cd = piNumeroContrat no-error.
    if not available iparmdt 
    then return (if ietab.exercice then ietab.dafinex1 else ietab.dadebex1 - 1).

    vdaDerDeclVal = tache.dtdeb - day(tache.dtdeb).  /* dernier jour du mois précédent la date d'activation de la tache TVA */
    {&_proparse_ prolint-nowarn(sortaccess)}
premierTva:
    for each arectva no-lock                /**Modif OF le 16/11/17 - Le FOR LAST ne prend pas en compte le tri de l'option BY -> Pb si changement de régime de déclaration (ENTRY 2 du siren)**/
        where arectva.soc-cd  = piCodeSoc
          and arectva.siren   begins (if iparmdt.fg-mandat-ind then ietab.siret else ietab.siren) + "|"
          and arectva.fg-valid
        by arectva.date_decla descending:
        vdaDerDeclVal = if vdaDerDeclVal = ? 
                        then arectva.date_decla                             /* date de dernière déclaration */
                        else maximum(arectva.date_decla, vdaDerDeclVal).    /* priorité sur la tache tva */
        leave premierTva.
    end.
    if tache.dtree <> ?                   /* Permettre la modification de la TVA si décla validée et fin de tache renseignée */ 
    then vdaDerDeclVal = (if ietab.exercice then ietab.dafinex1 else ietab.dadebex1 - 1).
    if vdaDerDeclVal = ? 
    then vdaDerDeclVal = (if ietab.exercice then ietab.dafinex1 else ietab.dadebex1 - 1).
    return vdaDerDeclVal.
end function.

/*
function f_siren_decla_valid returns date (pcSiren as character,  pcTypeDecla as character, piCodeSoc as integer) : 
    /*------------------------------------------------------------------------------
    Purpose: recherche date de derniere déclaration validée pour un siren/type de déclaration
    Notes  : 
    todo   pas utilisé. a supprimer?
    ------------------------------------------------------------------------------*/
    define buffer arectva for arectva.
  
    for last arectva no-lock  
        where arectva.soc-cd               = piCodeSoc
          and entry(1, arectva.siren, "|") = pcSiren
          and arectva.fg-valid             = true
          and entry(2, arectva.siren, "|") = pcTypeDecla:
        return arectva.date_decla.
    end.
    return ?.
end function.
*/
function f_tva_valid returns logical (piNumeroContrat as int64, pdaDebPer as date, piCodeSoc as integer):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    assign
        pdaDebPer = pdaDebPer - day(pdaDebPer) + 1 + 31
        pdaDebPer = pdaDebPer - day(pdaDebPer) /* fin de mois */
    .
    return f_decla_valid(piNumeroContrat, piCodeSoc) >= pdaDebPer.
end function.
