/*------------------------------------------------------------------------
File        : flag-let.i
Purpose     : Procedure de tri des Ecritures Lettrees/Non Lettrees
Author(s)   : GIPZ - 1996/01/07, Kantena - 2018/01/11
Notes       : vient de cadb/src/batch/flag-let (sans .i!)
              Attention, maintenant les définitions de variables doivent être dans l'appelant
{1} = Date de Lettrage
{2} = Suffixe Fichier ( Fichier = cecrln ) 
{3} = buffer
------------------------------------------------------------------------*/
if (asc(substring({3}cecrln{2}.lettre, 1, 1, "character")) >= asc("A")
and asc(substring({3}cecrln{2}.lettre, 1, 1, "character")) <= asc("Z"))
 or {3}cecrln{2}.lettre = "*****" then do:
    assign
        {3}cecrln{2}.flag-lettre = true
        {3}cecrln{2}.dalettrage  = {1}
    .
    if vlInstallTva then do:
        vlCreation = false.
        if {3}cecrln{2}.sscoll-cle <> vcSousCollectif
        then for first csscptcol no-lock
            where csscptcol.soc-cd = gicodesoc
              and csscptcol.etab-cd = gicodeetab
              and csscptcol.sscoll-cle = {3}cecrln{2}.sscoll-cle
              and csscptcol.libtier-cd <= 3:
            if csscptcol.libtier-cd = 1
            then find first ilibnatjou no-lock
                where ilibnatjou.soc-cd = gicodesoc
                  and ilibnatjou.vente no-error.
            else find first ilibnatjou no-lock
                where ilibnatjou.soc-cd = gicodesoc
                  and ilibnatjou.achat no-error.
            vlCreation = available ilibnatjou
                      and can-find(first cpardt no-lock
                                   where cpardt.soc-cd      = gicodesoc
                                     and cpardt.natjou-cd   = ilibnatjou.natjou-cd
                                     and cpardt.type-declar = false).
        end.
        if vlCreation
        and ({3}cecrln{2}.sscoll-cle <> vcSousCollectif
          or {3}cecrln{2}.cpt-cd <> vcCompte
          or {3}cecrln{2}.lettre <> vcLettre2) then do:
            assign
                vcSousCollectif = {3}cecrln{2}.sscoll-cle
                vcCompte        = {3}cecrln{2}.cpt-cd
                vcLettre2       = {3}cecrln{2}.lettre
            .
            if not can-find(first ctvamod no-lock
                            where ctvamod.soc-cd     = gicodesoc
                              and ctvamod.etab-cd    = gicodeetab
                              and ctvamod.sscoll-cle = {3}cecrln{2}.sscoll-cle
                              and ctvamod.cpt-cd     = {3}cecrln{2}.cpt-cd
                              and ctvamod.jou-cd     = {3}cecrln{2}.lettre
                              and ctvamod.let)
            then do:
                create ctvamod.
                assign
                    ctvamod.soc-cd     = gicodesoc
                    ctvamod.etab-cd    = gicodeetab
                    ctvamod.let        = true
                    ctvamod.sscoll-cle = {3}cecrln{2}.sscoll-cle
                    ctvamod.cpt-cd     = {3}cecrln{2}.cpt-cd
                    ctvamod.jou-cd     = {3}cecrln{2}.lettre
                    ctvamod.damod      = today
                .
            end.
        end.
    end.
end.
else assign
    {3}cecrln{2}.flag-lettre = false
    {3}cecrln{2}.dalettrage  = ?
.
