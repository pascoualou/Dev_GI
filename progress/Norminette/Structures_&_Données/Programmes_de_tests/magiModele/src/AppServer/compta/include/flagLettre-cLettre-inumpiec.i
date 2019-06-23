/*------------------------------------------------------------------------
File        : flagLettre-cLettre-inumpiec.i
Purpose     : reprise include cadb\src\batch\clettre.i, creation d'une fonction clettre
              reprise include cadb\src\batch\flag-let, creation d'une fonction flag-let
              reprise pgm gest\src\batch\inumpiec.p, creation d'une fonction inumpiecNumerotationPiece
Author(s)   : gg  -  2017/05/12
Notes       :
------------------------------------------------------------------------*/

function flag-let returns logical private(buffer pbCecrln for cecrln, pdaLettrage as date):
    /*------------------------------------------------------------------------------
    Purpose: Procedure de tri des Ecritures Lettrées/Non Lettrées
    Notes  : {1} = Date de Lettrage
             {2} = Suffixe Fichier ( Fichier = cecrln )
             {3} = buffer
    ------------------------------------------------------------------------------*/
    define buffer vbCsscptcol  for csscptcol.
    define buffer vbIlibnatjou for ilibnatjou.
    define buffer cpardt       for cpardt.
    define buffer ctvamod      for ctvamod.
    define variable vcPipo as character no-undo case-sensitive.

message "gga debut flag-let".
    vcPipo = substring(pbCecrln.lettre, 1, 1, 'character').
    if pbCecrln.lettre = "*****" or (vcPipo >= "A" and vcPipo <= "Z")
    then do:
        assign
            pbCecrln.flag-lettre = true
            pbCecrln.dalettrage  = pdaLettrage
        .
        {&_proparse_ prolint-nowarn(wholeIndex)}
        if can-find (first iparam no-lock where iparam.install-tva)
        then for first vbCsscptcol no-lock
            where vbCsscptcol.soc-cd     = pbCecrln.soc-cd
              and vbCsscptcol.etab-cd    = pbCecrln.etab-cd
              and vbCsscptcol.sscoll-cle = pbCecrln.sscoll-cle
              and vbCsscptcol.libtier-cd <= 3
          , first vbIlibnatjou no-lock
            where vbIlibnatjou.soc-cd     = vbCsscptcol.soc-cd
              and if vbCsscptcol.libtier-cd = 1 then vbIlibnatjou.vente else vbIlibnatjou.achat
          , first cpardt no-lock
            where cpardt.soc-cd    = vbCsscptcol.soc-cd
              and cpardt.natjou-cd = vbIlibnatjou.natjou-cd
              and not cpardt.type-declar:
            if not can-find (first ctvamod no-lock
                             where ctvamod.soc-cd     = pbCecrln.soc-cd
                               and ctvamod.etab-cd    = pbCecrln.etab-cd
                               and ctvamod.sscoll-cle = pbCecrln.sscoll-cle
                               and ctvamod.cpt-cd     = pbCecrln.cpt-cd
                               and ctvamod.jou-cd     = pbCecrln.lettre
                               and ctvamod.let        = true)
            then do:
                create ctvamod.
                assign
                    ctvamod.soc-cd     = pbCecrln.soc-cd
                    ctvamod.etab-cd    = pbCecrln.etab-cd
                    ctvamod.let        = true
                    ctvamod.sscoll-cle = pbCecrln.sscoll-cle
                    ctvamod.cpt-cd     = pbCecrln.cpt-cd
                    ctvamod.jou-cd     = pbCecrln.lettre
                    ctvamod.damod      = today
                .
            end.
        end.
    end.
    else assign
        pbCecrln.flag-lettre = false
        pbCecrln.dalettrage  = ?
    .
end function.

function clettre returns character private(prCcpt as rowid, pcTypLet as character):
    /*------------------------------------------------------------------------------
    Purpose: Formule du lettrage automatique, Il faut avoir defini 'li' et le compte (def var li as i.)
    Notes  : {1} = par pour lettrage partiel, tot pour lettrage total
             {2} = mandat courant
    ------------------------------------------------------------------------------*/
    define variable viLi as integer no-undo.

    define buffer ccpt   for ccpt.
    define buffer cecrln for cecrln.

message "gga debut clettre".

    for first ccpt exclusive-lock
        where rowid(ccpt) = prCcpt:
        for first cecrln no-lock
            where cecrln.soc-cd = ccpt.soc-cd
              and cecrln.etab-cd = ccpt.etab-cd
              and cecrln.coll-cle = ccpt.coll-cle
              and cecrln.cpt-cd = ccpt.cpt-cd
              and cecrln.lettre = ccpt.lettre:
            ccpt.lettre = "".
            if ccpt.libtype-cd = 1 then do:                                   /* Lettrable */
boucle:
                do viLi = 1 to 5:
                    ccpt.lettre-int[viLi] = ccpt.lettre-int[viLi] + 1.
                    if ccpt.lettre-int[viLi] = 27
                    then ccpt.lettre-int[viLi] = 1.
                    else leave boucle.
                end.
                do viLi = 1 to 5:
                    if ccpt.lettre-int[viLi] <> 0
                    then ccpt.lettre = chr(64 + ccpt.lettre-int[viLi]) + ccpt.lettre.
                end.
                if pcTypLet = "par" then ccpt.lettre = lc(ccpt.lettre).
            end.
        end.
        return ccpt.lettre.
    end.
    return "".
end function.

function inumpiecNumerotationPiece returns integer(pcPiece as character, pdaDatCompta as date):
    /*------------------------------------------------------------------------------
    Purpose: Numerotation des pieces en fonction d'un format
    Notes  : service utilisé par cptagli.p, cptaprov.p, inumpiec.p, odreltx.p et supodtx.p
    Formats possibles: AAMMxxx, xxx etant un format numerique de depart.
                       AMMxxx
                       MMxxx
                       neant
    ------------------------------------------------------------------------------*/

message "gga inumpiec.p " pcPiece "//" pdaDatCompta.

    if pcPiece begins "AMM"
    then return integer(substitute('&1&2&3'
                          , string(year(pdaDatCompta) modulo 10, '9')
                          , string(month(pdaDatCompta), "99")
                          , substring(pcPiece, index(pcPiece, "MM") + 2, 9, 'character'))
                        ).

    if pcPiece begins "AAMM"
    then return integer(substitute('&1&2&3'
                          , string(year(pdaDatCompta) modulo 100, '99')
                          , string(month(pdaDatCompta), "99")
                          , substring(pcPiece, index(pcPiece, "MM") + 2, 9, 'character'))
                        ).

    if pcPiece begins "MM"
    then return integer(string(month(pdaDatCompta), "99") + substring(pcPiece, index(pcPiece, "MM") + 2, 9, 'character')).

    return 0.

end function.
