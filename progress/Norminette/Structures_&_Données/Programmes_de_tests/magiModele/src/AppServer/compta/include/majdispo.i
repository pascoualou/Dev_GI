/*------------------------------------------------------------------------
File        : majdispo.i
Purpose     : Mise a jour du disponible lors de la validation des ecritures
Author(s)   : OF - 1997/04/04;   gga  -  2017/05/15
Notes       : reprise include cadb\src\batch\majdispo.i creation d'une procedure majdispo
              appele par cptmvt.p cptmvtgi.p cptmvtu.p
       TODO - A transformer en dynamique pour mettre dans une procédure ou une fonction

 {1} = fichier cecrln ou cextln
 {2} = TRUE si creation d'une ecriture
       FALSE si suppression d'une ecriture

01 | OF | 29/04/1999 | Remplacement des giCodeSoc par {1}.soc-cd, Filtre sur les A Nouveau de cloture
02 | DM | 17/12/2003 | 1103/0259 Maj du dispo travaux
----------------------------------------------------------------------*/

procedure majdispo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer pbcecrln for cecrln.
    define input parameter plSens     as logical no-undo.
    define input parameter pcNomTable as character no-undo.

    define buffer vb2iprd   for iprd.
    define buffer ietab     for ietab.
    define buffer actrcln   for actrcln.
    define buffer csscptcol for csscptcol.
    define buffer agest     for agest.
    define buffer iprd      for iprd.
    define buffer idispohb  for idispohb.
    
    define variable vdaJDaDeb as date no-undo.
    define variable vdaJDaFin as date no-undo.
   
message "debut majdispo ".     
    if can-find(first ijou no-lock
                where ijou.soc-cd    =  pbcecrln.soc-cd
                  and ijou.etab-cd   =  pbcecrln.mandat-cd
                  and ijou.jou-cd    =  pbcecrln.jou-cd
                  and ijou.natjou-gi <> 93)
    then do: /**Ajout OF le 29/04/99**/
        for first ietab no-lock
            where ietab.soc-cd     = pbcecrln.soc-cd
              and ietab.etab-cd    = pbcecrln.etab-cd
              and (ietab.profil-cd = 21 or ietab.profil-cd = 91):
    
            /** DM 1103/0259 **/
            if pcNomTable = "cecrln" 
            then 
            if pbcecrln.affair-num > 0
            then do:
                if pbcecrln.sscoll-cle > ""
                then for first csscptcol no-lock
                    where csscptcol.soc-cd = pbcecrln.soc-cd
                      and csscptcol.etab-cd = pbcecrln.etab-cd
                      and csscptcol.sscoll-cle = pbcecrln.sscoll-cle:
                    find first actrcln no-lock
                        where actrcln.cptdeb <= csscptcol.sscoll-cpt
                          and actrcln.cptfin >= csscptcol.sscoll-cpt
                          and actrcln.sscptdeb <= pbcecrln.cpt-cd
                          and actrcln.sscptfin >= pbcecrln.cpt-cd
                          and actrcln.profil-cd = ietab.profil-cd
                          and actrcln.fg-dispohb no-error.
                end.
                else find first actrcln no-lock
                    where actrcln.cptdeb <= substring(pbcecrln.cpt-cd,1,ietab.lgcum, 'character')
                      and actrcln.cptfin >= substring(pbcecrln.cpt-cd,1,ietab.lgcum, 'character')
                      and actrcln.sscptdeb <= substring(pbcecrln.cpt-cd, ietab.lgcum + 1, ietab.lgcpt - ietab.lgcum, 'character')
                      and actrcln.sscptfin >= substring(pbcecrln.cpt-cd, ietab.lgcum + 1, ietab.lgcpt - ietab.lgcum, 'character')
                      and actrcln.profil-cd = ietab.profil-cd
                      and actrcln.fg-dispohb no-error.
                if available actrcln
                then do:
                    {&_proparse_ prolint-nowarn(use-index)}
                    for first vb2iprd no-lock
                        where vb2iprd.soc-cd  = pbcecrln.soc-cd
                          and vb2iprd.etab-cd = pbcecrln.etab-cd use-index prd-i:
                        assign
                            vdaJDaDeb = vb2iprd.dadebprd
                            vdaJDaFin = vb2iprd.dafinprd
                        .
                    end.
                    for first agest no-lock
                        where agest.soc-cd = pbcecrln.soc-cd
                          and agest.gest-cle = ietab.gest-cle:
                        find first vb2iprd no-lock
                            where vb2iprd.soc-cd = pbcecrln.soc-cd
                            and vb2iprd.etab-cd  = pbcecrln.etab-cd
                            and vb2iprd.dadebprd = agest.dadeb no-error.
                        if available vb2iprd
                        then do:
                            {&_proparse_ prolint-nowarn(use-index)}
                            find next vb2iprd no-lock
                                where vb2iprd.soc-cd = pbcecrln.soc-cd
                                  and vb2iprd.etab-cd = pbcecrln.etab-cd use-index prd-i2 no-error.
                            if available vb2iprd
                            then vdaJDaFin = vb2iprd.dafinprd.
                        end.
                    end.
                    for each iprd exclusive-lock
                        where iprd.soc-cd = pbcecrln.soc-cd
                          and iprd.etab-cd = pbcecrln.etab-cd
                          and iprd.dadebprd >= vdaJDaDeb
                          and iprd.dafinprd <= vdaJDaFin:
                        {&_proparse_ prolint-nowarn(nowait)}
                        find first idispohb exclusive-lock
                            where idispohb.soc-cd  = pbcecrln.soc-cd
                              and idispohb.etab-cd = pbcecrln.etab-cd
                              and idispohb.prd-cd  = iprd.prd-cd
                              and idispohb.prd-num  = iprd.prd-num
                              and idispohb.affair-num = pbcecrln.affair-num no-error.
                        if not available idispohb
                        then do:
                            create idispohb.
                            assign
                                idispohb.soc-cd     = pbcecrln.soc-cd
                                idispohb.etab-cd    = pbcecrln.etab-cd
                                idispohb.prd-cd     = iprd.prd-cd
                                idispohb.prd-num    = iprd.prd-num
                                idispohb.affair-num = pbcecrln.affair-num.
                        end.
                        idispohb.dispo = if pbcecrln.sens = plSens then idispohb.dispo + pbcecrln.mt else idispohb.dispo - pbcecrln.mt.
                    end. /* for each iprd */
                end. /* if available actrcln */
            end. /* affair-num > 0 */
            /** FIN DM **/
    
            {&_proparse_ prolint-nowarn(release)}
            release actrcln.
            if pbcecrln.sscoll-cle > ""
            then for first csscptcol no-lock
                where csscptcol.soc-cd     = pbcecrln.soc-cd
                  and csscptcol.etab-cd    = pbcecrln.etab-cd
                  and csscptcol.sscoll-cle = pbcecrln.sscoll-cle:
                find first actrcln no-lock
                    where actrcln.cptdeb    <= csscptcol.sscoll-cpt
                      and actrcln.cptfin    >= csscptcol.sscoll-cpt
                      and actrcln.sscptdeb  <= pbcecrln.cpt-cd
                      and actrcln.sscptfin  >= pbcecrln.cpt-cd
                      and actrcln.profil-cd = ietab.profil-cd
                      and actrcln.fg-dispo no-error.
            end.
            else find first actrcln no-lock
                where actrcln.cptdeb    <= substring(pbcecrln.cpt-cd, 1, ietab.lgcum, 'character')
                  and actrcln.cptfin    >= substring(pbcecrln.cpt-cd, 1, ietab.lgcum, 'character')
                  and actrcln.sscptdeb  <= substring(pbcecrln.cpt-cd, ietab.lgcum + 1, ietab.lgcpt - ietab.lgcum, 'character')
                  and actrcln.sscptfin  >= substring(pbcecrln.cpt-cd, ietab.lgcum + 1, ietab.lgcpt - ietab.lgcum, 'character')
                  and actrcln.profil-cd = ietab.profil-cd
                  and actrcln.fg-dispo no-error.
            if available actrcln
            then do:
                {&_proparse_ prolint-nowarn(use-index)}
                for first vb2iprd no-lock
                    where vb2iprd.soc-cd  = pbcecrln.soc-cd
                      and vb2iprd.etab-cd = pbcecrln.etab-cd use-index prd-i:
                    assign
                        vdaJDaDeb = vb2iprd.dadebprd
                        vdaJDaFin = vb2iprd.dafinprd
                    .
                end.
                for first agest no-lock
                    where agest.soc-cd   = pbcecrln.soc-cd
                      and agest.gest-cle = ietab.gest-cle:
                    find first vb2iprd no-lock
                        where vb2iprd.soc-cd   = pbcecrln.soc-cd
                          and vb2iprd.etab-cd  = pbcecrln.etab-cd
                          and vb2iprd.dadebprd = agest.dadeb no-error.
                    if available vb2iprd
                    then do:
                        {&_proparse_ prolint-nowarn(use-index)}
                        find next vb2iprd no-lock
                            where vb2iprd.soc-cd  = pbcecrln.soc-cd
                              and vb2iprd.etab-cd = pbcecrln.etab-cd use-index prd-i2 no-error.
                        if available vb2iprd
                        then vdaJDaFin = vb2iprd.dafinprd.
                    end.
                end.
                for each iprd exclusive-lock
                    where iprd.soc-cd   =  pbcecrln.soc-cd
                      and iprd.etab-cd  =  pbcecrln.etab-cd
                      and iprd.dadebprd >= vdaJDaDeb
                      and iprd.dafinprd <= vdaJDaFin:
                    assign
                        iprd.dispo      = if pbcecrln.sens = plSens then iprd.dispo + pbcecrln.mt else iprd.dispo - pbcecrln.mt
                        iprd.dispo-EURO = if pbcecrln.sens = plSens then iprd.dispo-EURO + pbcecrln.mt-EURO else iprd.dispo-EURO - pbcecrln.mt-EURO
                    .
                end.
            end. /* if available actrcln */
        end. /* for first ietab no-lock  */
    end. /* if can-find(first ijou no-lock */

end procedure.

