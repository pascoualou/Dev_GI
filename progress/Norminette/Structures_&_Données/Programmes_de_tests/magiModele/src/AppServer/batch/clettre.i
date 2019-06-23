/*------------------------------------------------------------------------
File        : clettre.i
Purpose     : Formule du lettrage automatique
Author(s)   : , Kantena - 2018/01/11
Notes       : vient de cadb/src/batch/clettre.i
{1} = "par" pour lettrage partiel, "tot" pour lettrage total
{2} = mandat courant
------------------------------------------------------------------------*/

for first cecrln-buf no-lock
    where cecrln-buf.soc-cd = giCodeSoc
      and cecrln-buf.etab-cd = {2}
      and cecrln-buf.coll-cle = ccpt.coll-cle
      and cecrln-buf.cpt-cd = ccpt.cpt-cd
      and cecrln-buf.lettre = ccpt.lettre:
    ccpt.lettre = "".
    if ccpt.libtype-cd = 1 then do:                   /* Lettrable */
boucle:
        do viBoucle = 1 to 5:
            ccpt.lettre-int[viBoucle] = ccpt.lettre-int[viBoucle] + 1.
            if ccpt.lettre-int[viBoucle] <> 27 then leave boucle.
            ccpt.lettre-int[viBoucle] = 1.
        end.
        do viBoucle = 1 to 5:
            if ccpt.lettre-int[viBoucle] <> 0
            then ccpt.lettre = chr(64 + ccpt.lettre-int[viBoucle]) + ccpt.lettre.
        end.
        if "{1}" = "par" then ccpt.lettre = lc(ccpt.lettre).
    end.
end.
