/*-----------------------------------------------------------------------------
File        : outilBail.i
Purpose     : Procédures et fonctions communes à la gestion du bail
Author(s)   : PL - 2018/04/19
Notes       :
derniere revue: 2018/06/01 - phm: OK
-----------------------------------------------------------------------------*/
{preprocesseur/categorie2bail.i}

function isBailCommercial returns logical private(pcNatureContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: determine si la nature fournie est de la catégorie Commerciale
    Notes  : reprise de isBailCommercial.i de NP : 15/02/2018
    ------------------------------------------------------------------------------*/
    return can-find(first sys_pg no-lock
                    where sys_pg.tppar = "R_CBA"
                      and sys_pg.zone2 = pcNatureContrat
                      and lookup(sys_pg.zone1, {&CATEGORIE2BAIL-categoriesCommerciales}) > 0).
 end function.

 function donneCategorieBail returns character private(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Donne la catégorie d'un bail (HAB / COM)
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voSyspg         as class     syspg no-undo.
    define variable vcCategorieBail as character no-undo.
    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        // Sélection sur la nature du contrat
        voSyspg = new syspg().
        voSyspg:reloadZone2("R_CBA", ctrat.ntcon).
        if lookup(voSyspg:zone1, {&CATEGORIE2BAIL-categoriesCommerciales}) > 0
        then vcCategorieBail = "COM".
        else if lookup(voSyspg:zone1, {&CATEGORIE2BAIL-categoriesHabitations}) > 0 then vcCategorieBail = "HAB".
        delete object voSyspg.
    end.
    return vcCategorieBail.
end function.

function isBailResilie returns logical private(pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: Procedure de test de la date de résiliation par rapport au quittancement du bail
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    define buffer aquit for aquit.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat
          and ctrat.dtree <> ?:
        {&_proparse_ prolint-nowarn(use-index)}
        find last aquit no-lock
            where aquit.noloc = piNumeroContrat
              and aquit.fgfac = no use-index ix_aquit03 no-error.
        if available aquit then return (if not ctrat.dtree > aquit.dtfpr then true else false). // ne pas modifier, attention à la valeur ?

        if ctrat.dtree < today then return true.
    end.
    return false.
end function.
