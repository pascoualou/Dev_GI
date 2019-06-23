/*------------------------------------------------------------------------
File        : pregln-let.i
Purpose     : LETTRAGE AUTOMATIQUE
Author(s)   : PZ 1992/10/28;  gga  -  2017/05/12
Notes       : reprise include cadb\src\batch\pregln.let

     {1} = Fichier pregln
     cecrsai = entete creee
     cecrln  = ligne creee
     cecrsai-buf + vbCecrln = Facture/Avoir
     vdaLettrage doit etre defini
----------------------------------------------------------------------*/
{&_proparse_ prolint-nowarn(nowait)}
find first vbCecrln exclusive-lock
    where vbCecrln.soc-cd    = {1}.soc-cd
      and vbCecrln.etab-cd   = {1}.etab-cd
      and vbCecrln.jou-cd    = {1}.ecrln-jou-cd
      and vbCecrln.prd-cd    = {1}.ecrln-prd-cd
      and vbCecrln.prd-num   = {1}.ecrln-prd-num
      and vbCecrln.piece-int = {1}.ecrln-piece-int
      and vbCecrln.lig       = {1}.ecrln-lig no-error.
if available vbCecrln
then do:
/*gga plus d'appel, pregln-mtr est vide
    {batch/pregln.mtr {1} +} /*** MAJ mtregl ***/  gga*/
    find first ccpt no-lock
        where ccpt.soc-cd   = {1}.soc-cd
          and ccpt.etab-cd  = {1}.etab-cd
          and ccpt.coll-cle = {1}.coll-cle
          and ccpt.cpt-cd   = {1}.cpt-cd no-error.
    if available ccpt
    and ccpt.libtype-cd = 1
    and not vbCecrln.flag-lettre
    then do:
        if vbCecrln.lettre = ? or vbCecrln.lettre = ""
        then do:
            vbCecrln.lettre = clettre(rowid(ccpt), "par").
            flag-let(buffer vbCecrln, ?).
            cecrln.lettre = ccpt.lettre.
            flag-let(buffer cecrln, ?).
        end.
        else do:
            cecrln.lettre = vbCecrln.lettre.
            flag-let(buffer cecrln, ?).
        end.
        assign
            cecrln.tva-enc-deb = vbCecrln.tva-enc-deb
            cecrln.zone1       = vbCecrln.zone1
            cecrln.zone2       = vbCecrln.zone2
            cecrln.zone3       = vbCecrln.zone3
            {1}.tva-enc-deb    = vbCecrln.tva-enc-deb
            {1}.zone1          = vbCecrln.zone1
            {1}.zone2          = vbCecrln.zone2
            {1}.zone3          = vbCecrln.zone3
            vdSolde            = 0
            vdaLettrage        = 01/01/1901
        .
        /* PS le 02/12/99 */
        for first ietab no-lock
            where ietab.soc-cd = vbCecrln.soc-cd
            and ietab.etab-cd = vbCecrln.etab-cd:
            assign
                piCodePerFin = ietab.prd-cd-2
                piCodePerDeb = if ietab.exercice then ietab.prd-cd-2 else ietab.prd-cd-1
            .
        end.
        /* PS le 02/12/99 */ /* PB de lettrage partiel au lieu de total */
        for each vb2Cecrln no-lock
            where vb2Cecrln.soc-cd     = vbCecrln.soc-cd
              and vb2Cecrln.etab-cd    = vbCecrln.etab-cd
              and vb2Cecrln.sscoll-cle = vbCecrln.sscoll-cle
              and vb2Cecrln.cpt-cd     = vbCecrln.cpt-cd
              and vb2Cecrln.lettre     = vbCecrln.lettre
              and vb2Cecrln.prd-cd     >= piCodePerDeb
              and vb2Cecrln.prd-cd     <= piCodePerFin:
            if vdaLettrage < vb2Cecrln.dacompta
            then vdaLettrage = vb2Cecrln.dacompta.
            if vb2Cecrln.sens
            then vdSolde = vdSolde + vb2Cecrln.mt.
            else vdSolde = vdSolde - vb2Cecrln.mt.
        end.
        if vdSolde = 0 and vdaLettrage <> 01/01/1901 /* Ceci est un controle, vdaLettrage est ici different de 01/01/1901 */
        then for each vb2Cecrln exclusive-lock
            where vb2Cecrln.soc-cd   = vbCecrln.soc-cd
              and vb2Cecrln.etab-cd    = vbCecrln.etab-cd
              and vb2Cecrln.sscoll-cle = vbCecrln.sscoll-cle
              and vb2Cecrln.cpt-cd     = vbCecrln.cpt-cd
              and vb2Cecrln.lettre     = vbCecrln.lettre
              and vb2Cecrln.prd-cd     >= piCodePerDeb
              and vb2Cecrln.prd-cd     <= piCodePerFin:
            vb2Cecrln.lettre = caps(vbCecrln.lettre).
            flag-let(buffer vb2Cecrln, vdaLettrage).
        end.
    end.
end.
else if {1}.sscoll-cle > "" and ({1}.ecrln-jou-cd = ? or {1}.ecrln-jou-cd = "")
then assign
    cecrln.zone1 = {1}.zone1
    cecrln.zone2 = {1}.zone2
    cecrln.zone3 = {1}.zone3
.
