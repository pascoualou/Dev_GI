/*------------------------------------------------------------------------
File        : tiers.p
Purpose     :
Author(s)   : KANTENA - 2016/08/01
Notes       :
tables      : BASE sadb : ctctt, roles, tiers, ctrat, csscpt, isoc, ifour, GL_FICHE_TIERS
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tiers.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{commercialisation/include/tiersCommercialisation.i &nomTable=ttTiersHistoCommercialisation}
{tiers/include/tiers.i}

function getLibelleTiers returns character (pcNumeroTiers as character, pcTypeTiers as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé partout!
    ------------------------------------------------------------------------------*/
    define variable vclibelleTiers as character no-undo.
    define buffer tiers  for tiers.
    define buffer csscpt for csscpt.

    for first tiers no-lock
        where tiers.notie = integer(pcNumeroTiers):
        vclibelleTiers = substitute('&1 &2', tiers.lnom1, tiers.lpre1).
    end.
    if vclibelleTiers = ? or vclibelleTiers = ""
    then for first csscpt no-lock
        where csscpt.soc-cd     = integer(mtoken:cRefPrincipale)
          and csscpt.etab-cd    = piNumeroContrat
          and csscpt.sscoll-cle = pcTypeTiers
          and csscpt.cpt-cd     = pcNumeroTiers:
        vclibelleTiers = trim(csscpt.lib).
    end.
    return vclibelleTiers.

end function.

function getInformationsBancairesTiers returns character (pcCodeTypeRole as character, piNumeroRole as integer, pcTypeContrat as character, piNumeroContrat as integer, piNumeroTiers as integer):
    /*------------------------------------------------------------------------------
    Purpose: Récupération des informations bancaires d'un tiers
    Notes: déplacement du code utilisé dans rechercheTiers.p pour pouvoir l'utiliser dans tacheCrg.p et ensuite dans d'autres programmes
    ------------------------------------------------------------------------------*/
    define variable vcInformationsBancaires as character no-undo.
    define buffer ctanx for ctanx.
    define buffer rlctt for rlctt.

    vcInformationsBancaires = substitute("&1&1&1", separ[1]).
    find first rlctt no-lock
        where rlctt.tpidt = pcCodeTypeRole
          and rlctt.noidt = piNumeroRole
          and rlctt.tpct1 = pcTypeContrat
          and rlctt.noct1 = piNumeroContrat
          and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
    if available rlctt 
    then find first ctanx no-lock
        where ctanx.tpcon = rlctt.tpct2 
          and ctanx.nocon = rlctt.noct2 no-error.
    else do:
        /*--> Sinon on recherche l'IBAN par defaut du tiers */
        find first ctanx no-lock
            where ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.norol = piNumeroTiers
              and ctanx.tpcon = {&TYPECONTRAT-prive}
              and ctanx.tpact = "DEFAU" no-error.
        /*--> Si on ne le trouve pas, on prend le premier IBAN du tiers.... si il existe ! */
        if not available ctanx 
        then find first ctanx no-lock
            where ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.norol = piNumeroTiers
              and ctanx.tpcon = {&TYPECONTRAT-prive} no-error.
    end.
    if available ctanx then do:
        if not ctanx.fgetr 
        then assign
            entry(3, vcInformationsBancaires, separ[1]) = ctanx.lbtit
            entry(4, vcInformationsBancaires, separ[1]) = ctanx.lbdom
        .
        assign
            entry(1, vcInformationsBancaires, separ[1]) = ctanx.iban
            entry(2, vcInformationsBancaires, separ[1]) = ctanx.bicod.
    end.
    return vcInformationsBancaires.

end function.

procedure getTiersServiceGestion:
    /*------------------------------------------------------------------------------
    Purpose: Permet de récupérer le service de gestion lié à un contrat
    Notes  : service utilisé par beTiers.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTiers.

    run getTiersGestionGestionnaire(true, piNumeroContrat, pcTypeContrat).

end procedure.

procedure getTiersGestionnaire:
    /*------------------------------------------------------------------------------
    Purpose: Permet de récupérer le gestionnaire lié à un contrat
    Notes  : service utilisé par beTiers.cls et demandeDeDevis.p, ordreDeService.p, ...
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as integer   no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTiers.

    run getTiersGestionGestionnaire(false, piNumeroContrat, pcTypeContrat).

end procedure.

procedure getTiersGestionGestionnaire private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter plGestion       as logical   no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeContrat   as character no-undo.

    define buffer ctctt   for ctctt.
    define buffer ctrat   for ctrat.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.

    for each ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
          and ctctt.tpct2 = pcTypeContrat
          and ctctt.noct2 = piNumeroContrat
      , first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-serviceGestion}
          and ctrat.nocon = ctctt.noct1:
        if plGestion
        then find first vbRoles no-lock
            where vbRoles.tprol = {&TYPEROLE-agenceGestion}
              and vbRoles.norol = ctrat.nocon no-error.
        else find first vbRoles no-lock
            where vbRoles.tprol = ctrat.tprol
              and vbRoles.norol = ctrat.norol no-error.
        if available vbRoles
        then for first tiers no-lock
            where tiers.notie = vbRoles.notie:
            run createttTiers(buffer tiers, buffer vbRoles, "").
        end.
    end.

end procedure.

procedure getListeTiersContrat:
    /*------------------------------------------------------------------------------
    Purpose: Permet de récupérer les locataires liés à un mandat
    Notes  : service utilisé par beTiers.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeTiers     as character no-undo.
    define output parameter table for ttTiers.

    define buffer ctctt   for ctctt.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.

    for each ctctt no-lock
        where ctctt.tpct1 = pcTypeContrat
          and ctctt.noct1 = piNumeroContrat
      , each intnt no-lock
        where intnt.tpcon = ctctt.tpct2
          and intnt.nocon = ctctt.noct2
          and intnt.tpidt = pcTypeTiers
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and ctrat.dtree = ?
      , first vbRoles no-lock
        where vbRoles.tprol = intnt.tpidt
          and vbRoles.norol = intnt.noidt
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:
        create ttTiers.
        assign
            ttTiers.iNumeroTiers = tiers.notie
            ttTiers.cNom1        = trim(tiers.lnom1)
            ttTiers.cNom2        = trim(tiers.lpre1)
        .
    end.

end procedure.

procedure getTiersLocatairesUL:
    /*------------------------------------------------------------------------------
    Purpose: Permet de récupérer les infos tiers d'un locataire
    Notes  : service utilisé par commercialisation.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLocataire as integer no-undo.
    define input  parameter piNumeroHisto     as integer no-undo.
    define input  parameter piNumeroFiche     as integer no-undo.
    define output parameter table for ttTiersHistoCommercialisation.

    define buffer vbRoles for roles.
    define buffer tiers   for tiers.

    empty temp-table ttTiersHistoCommercialisation.
    for each vbRoles no-lock
        where vbRoles.tprol = {&TYPEROLE-locataire}
          and vbRoles.norol = piNumeroLocataire
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:
        create ttTiersHistoCommercialisation.
        assign
            ttTiersHistoCommercialisation.CRUD                  = 'R'
            ttTiersHistoCommercialisation.cJointure             = vbRoles.tprol + string(vbRoles.norol) + string(vbRoles.notie)
            ttTiersHistoCommercialisation.iNumeroFiche          = piNumeroFiche
            ttTiersHistoCommercialisation.iNumeroHistorique     = piNumeroHisto
            ttTiersHistoCommercialisation.iTypeTiers            = {&TYPETIERS-tiersRoleGI}
            ttTiersHistoCommercialisation.cCodeTypeRoleFiche    = vbRoles.tprol
            ttTiersHistoCommercialisation.cLibelleTypeRoleFiche = outilTraduction:getLibelleProg("O_ROL", vbRoles.tprol)
            ttTiersHistoCommercialisation.cCodeTypeRole         = vbRoles.tprol
            ttTiersHistoCommercialisation.iNumeroRole           = vbRoles.norol
            ttTiersHistoCommercialisation.cNom1                 = tiers.lnom1
            ttTiersHistoCommercialisation.cPrenom1              = tiers.lpre1
            ttTiersHistoCommercialisation.cCodeCivilite1        = tiers.cdcv1
            ttTiersHistoCommercialisation.cLibelleCivilite1     = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1)
            ttTiersHistoCommercialisation.cNom2                 = tiers.lnom2
            ttTiersHistoCommercialisation.cPrenom2              = tiers.lpre2
            ttTiersHistoCommercialisation.cCodeCivilite2        = tiers.cdcv2
            ttTiersHistoCommercialisation.cLibelleCivilite2     = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2)
            ttTiersHistoCommercialisation.cCheminPhoto          = ''    // NPO  TODO
            ttTiersHistoCommercialisation.dtTimestamp           = datetime(vbRoles.dtmsy, vbRoles.hemsy)
            ttTiersHistoCommercialisation.rRowid                = rowid(vbRoles)
        .
    end.

end procedure.

procedure getTiersMandantsUL:
    /*------------------------------------------------------------------------------
    Purpose: Permet de récupérer les mandants liés à une unité de location
    Notes  : TODO pas utilisée ?!
    ------------------------------------------------------------------------------*/
    define input  parameter piNoLoc         as integer no-undo.
    define input  parameter piNumeroContrat as integer no-undo.
    define output parameter table for ttTiers.

    define buffer intnt   for intnt.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.

    for each intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-mandant}
      , each vbRoles no-lock
        where vbRoles.tprol = intnt.tpidt
          and vbRoles.norol = piNoLoc
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:
        run createttTiers(buffer tiers, buffer vbRoles, "").
    end.

end procedure.

procedure recupereInfoSignalant:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par demandeDeDevis.p, ordreDeService.p, ...
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroSignalant  as integer   no-undo.
    define output parameter pcLibelleSignalant as character no-undo.
    define output parameter pcAdresseSignalant as character no-undo.

    define buffer tiers for tiers.
    define buffer ifour for ifour.

    for first tiers no-lock
        where tiers.notie = piNumeroSignalant:
        pcLibelleSignalant = substitute('&1 &2', tiers.lnom1, tiers.lpre1).
    end.
    if pcLibelleSignalant = ? or pcLibelleSignalant = ''
    then for first iFour no-lock
        where ifour.soc-cd   = 3080
          and ifour.four-cle = string(piNumeroSignalant):
        pcLibelleSignalant = ifour.nom.
    end.

end procedure.

procedure createttTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer pbtiers for tiers.
    define parameter buffer pbroles for roles.
    define input parameter pcVueCommercialisation as character no-undo.

    create ttTiers.
    assign
        ttTiers.CRUD              = 'R'
        ttTiers.iNumeroTiers      = pbtiers.notie
        ttTiers.iNumeroRole       = pbroles.norol
        ttTiers.cCodeTypeRole     = pbroles.tprol
        ttTiers.cCodeCivilite1    = pbtiers.cdcv1
        ttTiers.cLibelleCivilite1 = outilTraduction:getLibelleProg("O_CVT", pbtiers.cdcv1)
        ttTiers.cNom1             = trim(pbtiers.lnom1)
        ttTiers.cPrenom1          = trim(pbtiers.lpre1)
    .
    if pcVueCommercialisation = ? or pcVueCommercialisation = ""
    then assign
        ttTiers.cCodeCivilite2      = pbtiers.cdcv2
        ttTiers.cLibelleCivilite2   = outilTraduction:getLibelleProg("O_CVT", pbtiers.cdcv2)
        ttTiers.cCodeFamille        = pbtiers.cdfat
        ttTiers.cLibelleFamille     = outilTraduction:getLibelleProg("O_FMT", pbtiers.cdfat)
        ttTiers.cCodeSousFamille    = pbtiers.cdsft
        ttTiers.cLibelleSousFamille = outilTraduction:getLibelleProg("O_SFF", pbtiers.cdsft)
        ttTiers.daDateNaissance1    = pbtiers.dtna1
        ttTiers.daDateNaissance2    = pbtiers.dtna2
        ttTiers.cLieuNaissance1     = pbtiers.lina1
        ttTiers.cLieuNaissance2     = pbtiers.lina2
        ttTiers.cNomJeuneFille1     = pbtiers.lnjf1
        ttTiers.cNomJeuneFille2     = pbtiers.lnjf2
        ttTiers.cNom2               = trim(pbtiers.lnom2)
        ttTiers.cPrenom2            = trim(pbtiers.lpre2)
        ttTiers.cLibelleProfession1 = pbtiers.lprf1
        ttTiers.cLibelleProfession2 = pbtiers.lprf2
        ttTiers.cCodeSituation      = pbtiers.cdst1
        ttTiers.cLibelleSituation   = outilTraduction:getLibelleProg("O_CVT", pbtiers.cdst1)
        ttTiers.cNomContact         = trim(pbtiers.lnom4)
        ttTiers.cPrenomContact      = trim(pbtiers.lpre4)
        ttTiers.cLibelleProfessionContact = pbtiers.lprf4
        ttTiers.dtTimestamp         = datetime(pbtiers.dtmsy, pbtiers.hemsy)
    .
end procedure.
