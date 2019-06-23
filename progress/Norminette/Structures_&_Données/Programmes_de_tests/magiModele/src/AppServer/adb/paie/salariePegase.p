/*------------------------------------------------------------------------
File        : salariePegase.p
Purpose     : Visualisation d'un salarié de Paie Pégase
Author(s)   : GGA - 2017/11/16
Notes       : a partir de adb/paie/salpeg00.p
derniere revue: 2018/04/10 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/paie/include/salariePegase.i}
{application/include/glbsepar.i}

procedure getSalarie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroSalarie as int64 no-undo.
    define output parameter table for ttSalariePegase.

    empty temp-table ttSalariePegase.
    run chgSalariePrivate(piNumeroSalarie).

end procedure.

procedure chgSalariePrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroSalarie as int64 no-undo.

    define variable vhTiers    as handle    no-undo.
    define variable vcInfosRib as character no-undo.
    define variable vcTempo    as character no-undo.

    define buffer tiers   for tiers.
    define buffer salar   for salar.
    define buffer vbroles for roles.
    define buffer ctrat   for ctrat.

    for first salar no-lock
        where salar.tprol = {&TYPEROLE-salariePegase}
          and salar.norol = piNumeroSalarie
      , first vbroles no-lock
        where vbroles.tprol = salar.tprol
          and vbroles.norol = salar.norol
      , first tiers no-lock
        where tiers.notie = vbroles.notie:
        create ttSalariePegase.
        assign
            ttSalariePegase.cTypeIdentifiant   = salar.tprol
            ttSalariePegase.iNumeroIdentifiant = salar.norol
            ttSalariePegase.iNumeroTiers       = vbroles.notie
            ttSalariePegase.cNom               = outilFormatage:getNomTiers(salar.tprol, salar.norol)
            ttSalariePegase.cCivilite          = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1)
            ttSalariePegase.iNiveau            = salar.nivea
            ttSalariePegase.iCoefficient       = salar.coeff
            ttSalariePegase.cStatut            = salar.cdsta
            ttSalariePegase.cLibStatut         = outilTraduction:getLibelleParam("PASTA", salar.cdsta)
            ttSalariePegase.cEmploi            = salar.lbemp
            ttSalariePegase.daNaissance        = tiers.dtna1
            ttSalariePegase.daAnciennete       = salar.dtanc
            ttSalariePegase.daEntree           = salar.dtent
            ttSalariePegase.daSortie           = salar.dtsor
            ttSalariePegase.cNoSS              = salar.nosec
            ttSalariePegase.cCleSS             = salar.clsec
        .
        // infos RIB
        run tiers/tiers.p persistent set vhTiers.
        run getTokenInstance in vhTiers(mToken:JSessionId).
        vcInfosRib = dynamic-function("getInformationsBancairesTiers" in vhTiers,
                                      {&TYPEROLE-salariePegase},
                                      piNumeroSalarie,
                                      {&TYPECONTRAT-SalariePegase},
                                      piNumeroSalarie,
                                      vbroles.notie).
        run destroy in vhTiers.
        if num-entries(vcInfosRib, separ[1]) >= 4
        then assign
            ttSalariePegase.cIban          = entry(1, vcInfosRib, separ[1])
            ttSalariePegase.cBic           = entry(2, vcInfosRib, separ[1])
            ttSalariePegase.cTitulaire     = entry(3, vcInfosRib, separ[1])
            ttSalariePegase.cDomiciliation = entry(4, vcInfosRib, separ[1])
        .
        // Mode reglement
        for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-SalariePegase}
              and ctrat.nocon = piNumeroSalarie
              and num-entries(ctrat.lbdiv, "@") >= 2:
            assign
                vcTempo = entry(2, ctrat.lbdiv, "@")
                ttSalariePegase.cModeReglement = entry(1, vcTempo, "#")
                ttSalariePegase.cLibModeReglement = outilTraduction:getLibelleProg("O_MDG", ttSalariePegase.cModeReglement)
            .
        end.
        run chgSolde(piNumeroSalarie).
    end.

end procedure.

procedure chgSolde private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroSalarie as int64 no-undo.
    
    define variable viNumeroMandat as integer    no-undo.
    define variable vcCompte       as character  no-undo.
    define variable voCollection   as collection no-undo.

    define buffer ccptcol   for ccptcol.
    define buffer csscptcol for csscptcol.
    define buffer csscpt    for csscpt.

    assign 
        viNumeroMandat = truncate(piNumeroSalarie / 100000, 0) 
        vcCompte       = string(piNumeroSalarie modulo 100000, "99999")
        voCollection   = new collection()
    .
    voCollection:set('iNumeroSociete',      integer(mtoken:cRefGerance)).
    voCollection:set('iNumeroMandat',       viNumeroMandat).
    voCollection:set('cNumeroCompte',       vcCompte).
    voCollection:set('iNumeroDossier',      0).
    voCollection:set('lAvecExtraComptable', false).
    voCollection:set('daDateSolde',         today).
    voCollection:set('cNumeroDocument',     '').
    for first ccptcol no-lock
        where ccptcol.soc-cd = integer(mtoken:cRefGerance)
          and ccptcol.tpRole = {&TYPEROLE-salarieComptaEI} 
      , each csscptcol no-lock
        where csscptcol.soc-cd   = ccptcol.soc-cd
          and csscptcol.coll-cle = ccptcol.coll-cle
          and csscptcol.etab-cd  = viNumeroMandat
      , first csscpt no-lock
        where csscpt.soc-cd     = csscptcol.soc-cd
          and csscpt.etab-cd    = csscptcol.etab-cd
          and csscpt.sscoll-cle = csscptcol.sscoll-cle
          and csscpt.cpt-cd     = vcCompte:
        voCollection:set('cCodeCollectif', csscptcol.sscoll-cle).
        voCollection:set('dSoldeCompte',   decimal(0)).  // entre deux run, il vaut mieux réinitialiser.
        run compta/calculeSolde.p(input-output voCollection).
        assign
            ttSalariePegase.cCollectifSolde = csscptcol.sscoll-cle
            ttSalariePegase.cCompteSolde    = csscptcol.sscoll-cpt
            ttSalariePegase.dMontantSolde   = voCollection:getDecimal('dSoldeCompte')
        .
    end. 
    delete object voCollection.
end procedure.
