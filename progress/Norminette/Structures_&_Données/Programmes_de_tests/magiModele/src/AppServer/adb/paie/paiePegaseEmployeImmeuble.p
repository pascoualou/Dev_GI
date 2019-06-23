/*------------------------------------------------------------------------
File        : paiePegaseEmployeImmeuble.p
Purpose     : tache paie pegase employe immeubme (Suivi des etablissements de Paie Pégase)
Author(s)   : GGA - 2017/11/15
Notes       : a partir de adb/paie/etbpeg00.p
deniere revue: 2018/04/10 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2Adresse.i}

using parametre.pclie.parametrageCorrespondance.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adresse/include/adresse.i}
{adresse/include/coordonnee.i}
{adresse/include/moyenCommunication.i}
{adb/paie/include/etablissementPaie.i}
{adb/paie/include/salariePegase.i}
{application/include/glbsepar.i}
{comm/include/prccoros.i}    // function getNomOrganisme
{comm/include/prclbdiv.i}    // function getValeurParametre

define variable ghSalarie as handle    no-undo.
define variable ghAdresse as handle    no-undo.
define variable gcRef     as character no-undo.

procedure getPaiePegaseEmployeImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat    as int64     no-undo.
    define input  parameter pcListeTypeMandat as character no-undo.
    define output parameter table for ttEtablissementPaie.
    define output parameter table for ttSalariePegase.
    define output parameter table for ttAdresse.
    define output parameter table for ttMoyenCommunication.

    empty temp-table ttEtablissementPaie.
    empty temp-table ttSalariePegase.
    empty temp-table ttAdresse.
    empty temp-table ttMoyenCommunication.

    run ChgInfoSociete (piNumeroMandat, pcListeTypeMandat).

end procedure.

procedure ChgInfoSociete private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat    as int64     no-undo.
    define input parameter pcListeTypeMandat as character no-undo.

    define variable viI           as integer   no-undo.
    define variable vcTempo       as character no-undo.
    define variable vcListeOrgSoc as character no-undo.

    define buffer etabl   for etabl.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer vbctrat for ctrat.
    define buffer imble   for imble.
    define buffer ctctt   for ctctt.

    run adb/paie/salariePegase.p persistent set ghSalarie.
    run getTokenInstance in ghSalarie(mToken:JSessionId).
    run adresse/adresse.p persistent set ghAdresse.
    run getTokenInstance in ghAdresse(mToken:JSessionId).

    for each etabl no-lock
        where lookup(etabl.tpcon, pcListeTypeMandat) > 0
          and etabl.lbdiv4 begins "PEGASE=OUI"
          and etabl.nocon = (if piNumeroMandat > 0 then piNumeroMandat else etabl.nocon)      /* SY 23/06/2015 */
      , first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = etabl.tpcon
          and intnt.nocon = etabl.nocon
      , first ctrat no-lock
        where ctrat.tpcon = etabl.tpcon
          and ctrat.nocon = etabl.nocon
      , first imble no-lock
        where imble.noimm = intnt.noidt:
        create ttEtablissementPaie.
        assign
            gcRef                                      = if etabl.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                                         then mtoken:cRefGerance
                                                         else mtoken:cRefCopro
            ttEtablissementPaie.cTypeContrat           = etabl.tpcon
            ttEtablissementPaie.iNumeroContrat         = etabl.nocon
            ttEtablissementPaie.cTypeRole              = ctrat.tprol                             //mandant ou syndicat
            ttEtablissementPaie.iNumeroRole            = ctrat.norol
            ttEtablissementPaie.cLibIntervenantContrat = ctrat.lbnom
            ttEtablissementPaie.cCodeSiret             = string(etabl.siren,"999999999")
            ttEtablissementPaie.cCodeNic               = string(etabl.nonic,"99999")
            ttEtablissementPaie.dTauxTaxSal            = etabl.txtax
            ttEtablissementPaie.iNumeroImmeuble        = intnt.noidt                             //Immeuble du mandat
            ttEtablissementPaie.daResiliationContrat   = ctrat.dtree                             //Mandat actif
            ttEtablissementPaie.cCodeSociete           = getValeurParametre("CODSOCIETE", "=", separ[2], etabl.lbdiv4)
            ttEtablissementPaie.daDebutPaiePegase      = date(getValeurParametre("DTDEB"   , "=", separ[2], etabl.lbdiv4))
            ttEtablissementPaie.daDebutPaiePegase      = date(getValeurParametre("DTFIN"   , "=", separ[2], etabl.lbdiv4))
            ttEtablissementPaie.daExport               = date(getValeurParametre("DT1EXPOR", "=", separ[2], etabl.lbdiv4))
            vcListeOrgSoc                      = getValeurParametre("ORGSOC", "=", separ[2], etabl.lbdiv5)
            ttEtablissementPaie.cOrgRetraite   = ""
            ttEtablissementPaie.cOrgPrevoyance = ""
            ttEtablissementPaie.cOrgMutuelle   = ""
        .
        do viI = 1 to num-entries(vcListeOrgSoc):
            vcTempo = entry(viI , vcListeOrgSoc).
            case substring(vcTempo, 1, 1, "character"):
                when "U" then ttEtablissementPaie.cCodeUrssaf    = vcTempo.
                when "I" then ttEtablissementPaie.cCodeRecette   = vcTempo.
                when "M" then ttEtablissementPaie.cOrgMutuelle   = substitute("&1&2,", ttEtablissementPaie.cOrgMutuelle, vcTempo).
                when "P" then ttEtablissementPaie.cOrgPrevoyance = substitute("&1&2,", ttEtablissementPaie.cOrgPrevoyance, vcTempo).
                when "R" then ttEtablissementPaie.cOrgRetraite   = substitute("&1&2,", ttEtablissementPaie.cOrgRetraite, vcTempo).
            end case.
        end.
        assign
            ttEtablissementPaie.cOrgRetraite   = trim(ttEtablissementPaie.cOrgRetraite, ",")
            ttEtablissementPaie.cOrgPrevoyance = trim(ttEtablissementPaie.cOrgPrevoyance, ",")
            ttEtablissementPaie.cOrgMutuelle   = trim(ttEtablissementPaie.cOrgMutuelle, ",")
        .
        /* Gestionnaire */
        for first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = etabl.tpcon
              and ctctt.noct2 = etabl.nocon:
            ttEtablissementPaie.iNumeroGestionnaire = ctctt.noct1.
            for first vbctrat no-lock
                where vbctrat.tpcon = {&TYPECONTRAT-serviceGestion}
                  and vbctrat.nocon = ctctt.noct1:
                ttEtablissementPaie.cNomGestionnaire = vbctrat.noree.
            end.
        end.
        if ttEtablissementPaie.cCodeUrssaf > ""
        then ttEtablissementPaie.cNomUrssaf = getNomOrganisme(gcRef, ttEtablissementPaie.cCodeUrssaf).
        if ttEtablissementPaie.cCodeRecette > ""
        then ttEtablissementPaie.cNomRecette = getNomOrganisme(gcRef, ttEtablissementPaie.cCodeRecette).
        run chgInfoSalarie.
    end.
    run destroy in ghSalarie.
    run destroy in ghAdresse.

end procedure.

procedure ChgInfoSalarie private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcListeOrgSoc as character no-undo.
    define variable viI           as integer   no-undo.
    define variable viNumeroRole  as int64     no-undo.
    define variable vcTempo       as character no-undo.
    define buffer salar for salar.

    viNumeroRole = ttEtablissementPaie.iNumeroContrat * 100000.
    for each salar no-lock
        where salar.tprol = {&TYPEROLE-salariePegase}
          and salar.norol >= viNumeroRole + 1
          and salar.norol <= viNumeroRole + 99999:
        run getSalarie in ghSalarie(salar.norol, output table ttSalariePegase by-reference).
        run getAdresse in ghAdresse(
            salar.tprol,
            salar.norol,
            {&TYPEADRESSE-Principale},
            "1",
            output table ttAdresse by-reference,
            output table ttCoordonnee by-reference,
            output table ttMoyenCommunication by-reference
        ).
        // on complete la table avec les infos provenant de Pegase
        for first ttSalariePegase
            where ttSalariePegase.cTypeIdentifiant   = salar.tprol
              and ttSalariePegase.iNumeroIdentifiant = salar.norol:
            assign
                ttSalariePegase.cOrgRetraite      = ""
                ttSalariePegase.cNomOrgRetraite   = ""
                ttSalariePegase.cOrgPrevoyance    = ""
                ttSalariePegase.cNomOrgPrevoyance = ""
                ttSalariePegase.cOrgMutuelle      = ""
                ttSalariePegase.cNomOrgMutuelle   = ""
                vcListeOrgSoc                     = getValeurParametre("ORGSOC", "=", separ[2], salar.lbdiv5)
            .
            do viI = 1 to num-entries(vcListeOrgSoc):
                vcTempo = entry(viI, vcListeOrgSoc).
                if vcTempo begins "M"
                then assign
                    ttSalariePegase.cOrgMutuelle    = substitute("&1&2,", ttSalariePegase.cOrgMutuelle, vcTempo)
                    ttSalariePegase.cNomOrgMutuelle = substitute("&1&2,", ttSalariePegase.cNomOrgMutuelle, getNomOrganisme(gcRef, vcTempo))
                .
                else if vcTempo begins "P"
                then assign
                     ttSalariePegase.cOrgPrevoyance    = substitute("&1&2,", ttSalariePegase.cOrgPrevoyance, vcTempo)
                     ttSalariePegase.cNomOrgPrevoyance = substitute("&1&2,", ttSalariePegase.cNomOrgPrevoyance, getNomOrganisme(gcRef, vcTempo))
                .
                else if vcTempo begins "R"
                then assign
                     ttSalariePegase.cOrgRetraite    = substitute("&1&2,", ttSalariePegase.cOrgRetraite, vcTempo)
                     ttSalariePegase.cNomOrgRetraite = substitute("&1&2,", ttSalariePegase.cNomOrgRetraite, getNomOrganisme(gcRef, vcTempo))
                .
            end.
            assign
                ttSalariePegase.cOrgRetraite      = trim(ttSalariePegase.cOrgRetraite, ",")
                ttSalariePegase.cNomOrgRetraite   = trim(ttSalariePegase.cNomOrgRetraite, ",")
                ttSalariePegase.cOrgPrevoyance    = trim(ttSalariePegase.cOrgPrevoyance, ",")
                ttSalariePegase.cNomOrgPrevoyance = trim(ttSalariePegase.cNomOrgPrevoyance, ",")
                ttSalariePegase.cOrgMutuelle      = trim(ttSalariePegase.cOrgMutuelle, ",")
                ttSalariePegase.cNomOrgMutuelle   = trim(ttSalariePegase.cNomOrgMutuelle, ",")
            .
        end.
    end.

end procedure.
