/*------------------------------------------------------------------------
File        : creationCorrespondance.i (ancien fcredoc.i)
Description : Fonction de creation de correspondances
Author(s)   : kantena - 2018/05/
Notes       :
derniere revue: 2018/08/17 - phm: KO
        creer la variable preprocesseur "00001", "00002", ...  dans ?  pour le Code Categorie
        traiter les todo 
----------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2role.i}
{preprocesseur/typeAccord2Reglement.i}
{preprocesseur/type2application.i}

function frmAnnexe            returns character(pcTypeRole as character)      forwards.
function frmHuissier          returns character()                             forwards.
function frmLocataire         returns character()                             forwards.
function frmMandant           returns character()                             forwards.
function frmSalarie           returns character(pcCodeCategorie as character) forwards.
function frmCoproprietaire    returns character()                             forwards.
function frmCoproprietaire2   returns character()                             forwards.    /* Ajout SY le 12/03/2009 */
function frmFournisseur       returns character(pcTypeContrat as character, piNumeroContrat as integer, pcCodeCategorie as character) forwards.
function frmMembre            returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmVendeur           returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmAcheteur          returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmPresident         returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmAssedic           returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmCentrePaiement    returns character()                             forwards.
function frmRecette           returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmCaf               returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmCdi               returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmCompagnie         returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmcourtier          returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmCandidatLocataire returns character()                             forwards.
function frmSignalePar        returns character(pcTypeContrat as character, piNumeroContrat as integer) forwards.
function frmGarant            returns character()                             forwards.
function frmCritere           returns integer (pcTypeContrat  as character, piNumeroContrat as integer, pcTypeIdentifiant as character, piNumeroRole as integer) forwards.

function frmCritere returns integer(pcTypeContrat as character, piNumeroContrat as integer, pcTypeIdentifiant as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche de roles annexe d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viNumeroIdentifiant as integer no-undo.

    run rechercheCritere(pcTypeContrat, piNumeroContrat, pcTypeIdentifiant, piNumeroRole, output viNumeroIdentifiant).
    return viNumeroIdentifiant.
end function.

function frmAnnexe returns character(pcTypeRole as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche de roles annexe d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheAnnexe(pcTypeRole, output vcRetour).
    return vcRetour.
end function.

function frmHuissier returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche du huissier du cabinet
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheHuissier(output vcRetour).
    return vcRetour.
end function.

function frmCandidatLocataire returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des candidats locataires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheCandidatLocataire(output vcRetour).
    return vcRetour.
end function.

function frmSignalePar returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche des signalés par
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheSignalePar(pcTypeContrat, piNumeroContrat, output vcRetour).
    return vcRetour.
end function.

function frmGarant returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des Garants
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheGarant(output vcRetour).
    return vcRetour.
end function.

function frmLocataire returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des locataires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheLocataire(output vcRetour).
    return vcRetour.
end function.

function frmMandant returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des mandants d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheMandant(output vcRetour).
    return vcRetour.
end function.

function frmSalarie returns character(pcCodeCategorie as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du gardien d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheSalarie(pcCodeCategorie, output vcRetour).
    return vcRetour.
end function.

function frmCoproprietaire returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des destinataires des coproprietaires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheCoproprietaire("Desti", output vcRetour).
    return vcRetour.
end function.

function frmCoproprietaire2 returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des coproprietaires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheCoproprietaire("Copro", output vcRetour).
    return vcRetour.
end function.

function frmFournisseur returns character(pcTypeContrat as character, piNumeroContrat as integer, pcCodeCategorie as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche des fournisseurs d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run rechercheFournisseur(pcTypeContrat, piNumeroContrat, pcCodeCategorie, output vcRetour).
    return vcRetour.
end function.

function frmMembre returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche des membres du conseil syndical
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    define buffer tache for tache.
    define buffer taint for taint.
    define buffer ctctt for ctctt.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then for last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-conseilSyndical}
          , each taint no-lock
            where taint.tpcon = tache.tpcon
              and taint.nocon = tache.nocon
              and taint.tpidt = {&TYPEROLE-membreConseilSyndical}
              and taint.tptac = tache.tptac
              and taint.notac = tache.notac:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], taint.tpidt, SEPAR[1], taint.noidt).
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then for first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat
          , last tache no-lock
            where tache.tpcon = ctctt.tpct2
              and tache.nocon = ctctt.noct2
              and tache.tptac = {&TYPETACHE-conseilSyndical}
           , each taint no-lock
            where taint.tpcon = tache.tpcon
              and taint.nocon = tache.nocon
              and taint.tpidt = {&TYPEROLE-membreConseilSyndical}
              and taint.tptac = tache.tptac
              and taint.notac = tache.notac:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], taint.tpidt, SEPAR[1], taint.noidt).
        end.
    end case.
    return trim(vcRetour, SEPAR[2]).
end function.

function frmPresident returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du president du conseil syndical
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define buffer tache for tache.
    define buffer taint for taint.
    define buffer ctctt for ctctt.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then for last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-conseilSyndical}
          , each taint no-lock
            where taint.tpcon = tache.tpcon
              and taint.nocon = tache.nocon
              and taint.tpidt = {&TYPEROLE-presidentConseilSyndical}
              and taint.tptac = tache.tptac
              and taint.notac = tache.notac:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], taint.tpidt, SEPAR[1], taint.noidt).
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then for first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat
          , last tache no-lock
            where tache.tpcon = ctctt.tpct2
              and tache.nocon = ctctt.noct2
              and tache.tptac = {&TYPETACHE-conseilSyndical}
          , each taint no-lock 
            where taint.tpcon = tache.tpcon
              and taint.Nocon = tache.nocon
              and taint.TpIdt = {&TYPEROLE-presidentConseilSyndical}
              and taint.TpTac = tache.tptac
              and taint.NoTac = tache.notac:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], taint.tpidt, SEPAR[1], taint.noidt).
        end.
    end case.
    return trim(vcRetour, SEPAR[2]).
end function.

function frmAssedic returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Centre Assedic
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    define buffer etabl for etabl.
    define buffer ctctt for ctctt.

    /* NB: Les centres ASSEDIC n'existe plus: La fusion de l'ANPE et du réseau des Assedic a pris effet le 1er janvier 2009 */  
    case pcTypeContrat:
        when {&TYPECONTRAT-Salarie} then do:
            find first etabl no-lock 
                where etabl.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and etabl.nocon = integer(truncate(piNumeroContrat / 100, 0)) no-error.
            if not available etabl 
            then find first etabl no-lock 
                where etabl.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and etabl.nocon = integer(truncate(piNumeroContrat / 100, 0)) no-error.
            if available etabl then vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
        end.
        when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance} then for first etabl no-lock
            where etabl.tpcon = pcTypeContrat
              and etabl.nocon = piNumeroContrat:
            vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then for first etabl no-lock
            where etabl.tpcon = pcTypeContrat
              and etabl.nocon = integer(truncate(piNumeroContrat / 100000, 0)):
            vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then for first ctctt no-lock 
            where (ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic} or ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance})
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat
          , first etabl no-lock
            where etabl.tpcon = ctctt.tpct1
              and etabl.nocon = ctctt.noct1:
            vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
        end.
    end case.
    return vcRetour.
end function.

function frmCentrePaiement returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Centre de Paiement
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour  as character no-undo.

    run prcPaiement(output vcRetour).
    return vcRetour.
end function.

function frmSIE returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Centre SIE remplaçant CDI,CDR, ORP, ODB, OTS et CDA 
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcPaiement(output vcRetour).
    if vcRetour = "" then vcRetour = frmRecette(pcTypeContrat, piNumeroContrat).
    if vcRetour = "" then vcRetour = frmCDI(pcTypeContrat, piNumeroContrat).
    return vcRetour.
end function.

function frmRecette returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Centre de Recette
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour         as character no-undo.
    define variable vcTypeOrganisme  as character no-undo.
    define variable vcTemp           as character no-undo.
    define variable viCpUseInc       as integer   no-undo.
    define variable voTypeCentre     as class parametrageTypeCentre no-undo.

    define buffer etabl   for etabl.
    define buffer tache   for tache.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctctt   for ctctt.

    voTypeCentre    = new parametrageTypeCentre().
    vcTypeOrganisme = string(voTypeCentre:isGesTypeCentre(), "SIE/ODB").  // même longueur de chaine, pas de trim!
    case pcTypeContrat:
        when {&TYPECONTRAT-Salarie} then for first etabl no-lock
            where etabl.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and etabl.nocon = integer(truncate(piNumeroContrat / 100, 0)):
            /* Recherche de la tache TVA ou Droit de bail */
            find first tache no-lock
                where tache.tpcon = etabl.tpcon
                  and tache.nocon = etabl.nocon
                  and tache.tptac = {&TYPETACHE-CRL}
                  and tache.notac = 1 no-error.
            if not available tache
            then find first tache no-lock
                where tache.tpcon = tache.tpcon
                  and tache.nocon = tache.nocon
                  and tache.tptac = {&TYPETACHE-TVA}
                  and tache.notac = 1 no-error.
            if available tache and tache.utreg > "" 
            then vcRetour = substitute("&1&2&3&4", vcTypeOrganisme, SEPAR[1], substring(tache.utreg, 1, 3, "character"), substring(tache.utreg, 5, 2, "character")).
        end.
        when {&TYPECONTRAT-mandat2Gerance} then do:
            /* Recherche de la tache TVA ou Droit de bail */
            find first tache no-lock 
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-CRL}
                  and tache.notac = 1 no-error.
            if not available tache
            then find first tache no-lock
                where tache.tpcon = tache.tpcon
                  and tache.nocon = tache.nocon
                  and tache.tptac = {&TYPETACHE-TVA}
                  and tache.notac = 1 no-error.
            if available tache and tache.utreg > "" 
            then vcRetour = substitute("&1&2&3&4", vcTypeOrganisme, SEPAR[1], substring(tache.utreg, 1, 3, "character"), substring(tache.utreg, 5, 2, "character")).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then for first intnt no-lock /* Recherche du cdi rattaché à l'immeuble du locataire */
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-immeuble}
          , first vbIntnt no-lock
            where vbIntnt.tpcon = {&TYPECONTRAT-construction}
              and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
              and vbIntnt.noidt = intnt.noidt
          , first tache no-lock
            where tache.tpcon = vbIntnt.tpcon
              and tache.nocon = vbIntnt.nocon
              and tache.tptac = {&TYPETACHE-organismesSociaux}
              and tache.tpfin = vcTypeOrganisme:
            assign
                vcTemp     = trim(tache.ntges)
                viCpUseInc = integer(substring(vcTemp, 1, 3, "character") + substring(vcTemp, 5, 2, "character")) 
            no-error.
            if not error-status:error 
            then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
        end.
        when {&TYPECONTRAT-fournisseur} then for first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat:
            find first tache no-lock
                where tache.tpcon = ctctt.tpct1
                  and tache.nocon = ctctt.noct1
                  and tache.tptac = {&TYPETACHE-CRL}
                  and tache.notac = 1 no-error.
            if not available tache
            then find first tache no-lock
                where tache.tpcon = ctctt.tpct1
                  and tache.nocon = ctctt.noct1
                  and tache.tptac = {&TYPETACHE-TVA}
                  and tache.notac = 1 no-error.
            if available tache and tache.utreg > "" 
            then vcRetour = substitute("&1&2&3&4", vcTypeOrganisme, SEPAR[1], substring(tache.utreg, 1, 3, "character"), substring(tache.utreg, 5, 2, "character")).
        end.
    end case.
    return vcRetour.
end function.

function frmCaf returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche de la CAF
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour       as character no-undo.
    define variable voResidenceCAF as class parametre.pclie.parametrageResidenceCAF no-undo.

    define buffer intnt for intnt.

    case pcTypeContrat:
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then for first intnt no-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            voResidenceCAF = new parametre.pclie.parametrageResidenceCAF(string(intnt.noidt)).
            if voResidenceCAF:isDbParameter then vcRetour = substitute("CAF&1&2", SEPAR[1], voResidenceCAF:zon02).
            delete object voResidenceCAF.
        end.
    end case.
    return vcRetour.
end function.

function frmCdi returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du CDI : centre des impots
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour         as character no-undo.
    define variable vcTypeOrganisme  as character no-undo.
    define variable vcTemp           as character no-undo.
    define variable viCpUseInc       as integer   no-undo.
    define variable voTypeCentre     as class parametrageTypeCentre no-undo.

    define buffer tache   for tache.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctctt   for ctctt.

    voTypeCentre    = new parametrageTypeCentre().
    vcTypeOrganisme = string(voTypeCentre:isGesTypeCentre(), "SIE/CDI").  // même longueur de chaine, pas de trim!
    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} then do:
            /* Recherche de la tache TVA ou Droit de bail */
            find first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-CRL}
                  and tache.notac = 1 no-error.
            if not available tache
            then find first tache no-lock
                where tache.tpcon = tache.tpcon
                  and tache.nocon = tache.nocon
                  and tache.tptac = {&TYPETACHE-TVA}
                  and tache.notac = 1 no-error.
            if available tache and tache.dcreg > "" then do:
                assign
                    vcTemp     = trim(tache.dcreg)
                    viCpUseInc = integer(if vcTypeOrganisme = "CDI"
                                         then substring(vcTemp, 1, 3, "character") + substring(vcTemp, 5, 2, "character")
                                         else vcTemp)
                no-error.
                if not error-status:error then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
            end.
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then for first intnt no-lock  /* Recherche du cdi rattaché à l'immeuble du locataire */
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-immeuble}
          , first vbIntnt no-lock
            where vbIntnt.tpcon = {&TYPECONTRAT-construction}
              and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
              and vbIntnt.noidt = intnt.noidt
          , first tache no-lock
            where tache.tpcon = vbIntnt.tpcon
              and tache.nocon = vbIntnt.nocon
              and tache.tptac = {&TYPETACHE-organismesSociaux}
              and tache.tpfin = "CDI":
            assign
                vcTemp     = trim(tache.ntges)
                viCpUseInc = integer(if vcTypeOrganisme = "CDI"
                                     then substring(vcTemp, 1, 3, "character") + substring(vcTemp, 5, 2, "character")
                                     else vcTemp)
            no-error.
            if not error-status:error then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
        end.
        when {&TYPECONTRAT-fournisseur} then for first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat:
            /* Recherche de la tache TVA ou Droit de bail */
            find first tache no-lock
                where tache.tpcon = ctctt.tpct1
                  and tache.nocon = ctctt.noct1
                  and tache.tptac = {&TYPETACHE-CRL}
                  and tache.notac = 1 no-error.
            if not available tache
            then find first tache no-lock
                where tache.tpcon = tache.tpcon
                  and tache.nocon = tache.nocon
                  and tache.tptac = {&TYPETACHE-TVA}
                  and tache.notac = 1 no-error.
            if available tache and tache.dcreg > "" then do:
                assign
                    vcTemp     = trim(tache.dcreg)
                    viCpUseInc = integer(if vcTypeOrganisme = "CDI"
                                         then substring(vcTemp, 1, 3, "character") + substring(vcTemp, 5, 2, "character")
                                         else vcTemp)
                no-error.
                if not error-status:error then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
            end.
        end.
    end case.
    return vcRetour.
end function.

function frmCompagnie returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche des Compagnies d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour     as character no-undo.
    define variable viContratTmp as integer   no-undo.

    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then for last ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
        end.
        when {&TYPECONTRAT-mandat2Gerance} then for last ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then for last ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct1 = integer(truncate(piNumeroContrat / 100000, 0))
              and Ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
        end.
        when {&TYPECONTRAT-titre2copro} then for last ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
              and ctctt.noct1 = integer(truncate(piNumeroContrat / 100000, 0))
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
          , first ctrat no-lock 
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                viContratTmp = ctctt.noct1.
                for last ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.noct1 = viContratTmp
                      and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
                  , first ctrat no-lock
                    where Ctrat.tpcon = ctctt.tpct2
                      and ctrat.nocon = ctctt.noct2:
                    vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
                end.
            end.
            else do:
                find first ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                      and ctctt.tpct2 = pcTypeContrat
                      and ctctt.noct2 = piNumeroContrat no-error.
                if available ctctt then do:
                    viContratTmp = ctctt.noct1.
                    for last ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                          and ctctt.noct1 = viContratTmp
                          and Ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
                      , first ctrat no-lock
                        where Ctrat.tpcon = ctctt.tpct2
                          and ctrat.nocon = ctctt.noct2:
                        vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
                    end.
                end.
            end.
        end.
    end case.
    return trim(vcRetour, SEPAR[2]).
end function.

function frmCourtier returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche des Courtiers d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour     as character no-undo.
    define variable viContratTmp as integer   no-undo.

    define buffer ctctt for ctctt.
    define buffer intnt for intnt.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then for last ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
          , each intnt no-lock
            where intnt.tpidt = {&TYPEROLE-courtier}
              and intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
        when {&TYPECONTRAT-mandat2Gerance} then for last ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
           , each intnt no-lock
            where intnt.tpidt = {&TYPEROLE-courtier}
              and intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then for last ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct1 = integer(truncate(piNumeroContrat / 100000, 0))
              and Ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
           , each intnt no-lock 
            where intnt.tpidt = {&TYPEROLE-courtier}
              and intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
        when {&TYPECONTRAT-titre2copro} then for last ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
              and ctctt.noct1 = integer(truncate(piNumeroContrat / 100000, 0))
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
          , first intnt no-lock
            where intnt.tpidt = {&TYPEROLE-courtier}
              and intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                viContratTmp = ctctt.noct1.
                for last ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.noct1 = viContratTmp
                      and Ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
                  , first intnt no-lock
                    where intnt.tpidt = {&TYPEROLE-courtier}
                      and intnt.tpcon = ctctt.tpct2
                      and intnt.nocon = ctctt.noct2:
                    vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
                end.
            end.
            else do:
                find first ctctt no-lock 
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                      and ctctt.tpct2 = pcTypeContrat
                      and ctctt.noct2 = piNumeroContrat no-error.
                if available ctctt then do:
                    viContratTmp = ctctt.noct1.
                    for last ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                          and ctctt.noct1 = viContratTmp
                          and Ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
                      , first intnt no-lock
                        where intnt.tpidt = {&TYPEROLE-courtier}
                          and intnt.tpcon = ctctt.tpct2
                          and intnt.nocon = ctctt.noct2:
                        vcRetour = substitute("&1&2&3&4&5", vcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
                    end.
                end.
            end.
        end.
    end case.
    return trim(vcRetour, SEPAR[2]).
end function.

function frmVendeur returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Vendeur du dossier de mutation
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define buffer intnt for intnt.

    if pcTypeContrat = {&TYPECONTRAT-DossierMutation}
    then for first intnt no-lock 
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-vendeur}:
        vcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
    end.
    return vcRetour.
end function.

function frmAcheteur returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche de l'Acheteur du dossier de mutation
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define buffer intnt for intnt.

    if pcTypeContrat = {&TYPECONTRAT-DossierMutation}
    then for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-acheteur}:
        vcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
    end.
    return vcRetour.
end function.

procedure rechercheCritere private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche l'identifiant du critere supplementaire lié
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat       as character no-undo.
    define input  parameter piNumeroContrat     as integer   no-undo.
    define input  parameter pcTypeIdentifiant   as character no-undo.
    define input  parameter piNumeroRole        as integer   no-undo.
    define output parameter piNumeroIdentifiant as integer   no-undo.

    define variable vcMandat        as character no-undo           // todo  pas très élégant cette liste de valeur!
           initial '{&TYPECONTRAT-mandat2Gerance}+{&TYPECONTRAT-mandat2Syndic}'.
    define variable vcSalarie       as character no-undo           // todo  pas très élégant cette liste de valeur!
           initial '{&TYPECONTRAT-mandat2Gerance}+{&TYPECONTRAT-bail}+{&TYPECONTRAT-mandat2Syndic}+{&TYPECONTRAT-Salarie}'.
    define variable vcSalariePegase as character no-undo           // todo  pas très élégant cette liste de valeur!
           initial '{&TYPECONTRAT-mandat2Gerance}+{&TYPECONTRAT-bail}+{&TYPECONTRAT-mandat2Syndic}+{&TYPECONTRAT-SalariePegase}'.

    define buffer intnt    for intnt.
    define buffer inter    for inter.
    define buffer vbIntnt  for intnt.
    define buffer ctctt    for ctctt.
    define buffer tache    for tache.
    define buffer unite    for unite.
    define buffer local    for local.
    define buffer ordse    for ordse.
    define buffer dtord    for dtord.
    define buffer dtdev    for dtdev.
    define buffer location for location.
    define buffer acreg    for acreg.
    define buffer vbEvent  for event.

    assign              // suppression des "
        vcMandat        = replace(vcMandat, '"', '')
        vcSalarie       = replace(vcSalarie, '"', '')
        vcSalariePegase = replace(vcSalariePegase, '"', '')
    .
    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Syndic} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                piNumeroIdentifiant = intnt.noidt.
            end.
            /* todo    très étrange comme valeurs (vcMandat, vcSalarie, vcSalariePegase). dépend de l'ordre ! D'ou cela vient t'il ?????*/
            when vcMandat or when vcSalarie or when vcSalariePegase then piNumeroIdentifiant = piNumeroContrat.
        end case.

        when {&TYPECONTRAT-titre2copro} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Syndic} then for first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat:
                piNumeroIdentifiant = ctctt.noct1.
            end.
            when {&TYPECONTRAT-titre2copro} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat
              , first intnt no-lock 
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = ctctt.tpct1
                  and intnt.nocon = ctctt.noct1:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPEBIEN-lot} then for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.nbden = 0:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPETACHE-cleMagnetiqueDetails} then for first intnt no-lock 
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.nbden = 0
              , first local no-lock
                where local.noloc = intnt.noidt
              , first vbIntnt no-lock
                where vbIntnt.tpcon = {&TYPECONTRAT-construction}
                  and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
                  and vbIntnt.noidt = local.noimm
              , last tache no-lock 
                where tache.tpcon = vbIntnt.tpcon
                  and tache.nocon = vbIntnt.nocon
                  and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
                  and tache.tpfin = string(local.nolot):
                piNumeroIdentifiant = tache.noita.
            end.
            /* todo    très étrange comme valeurs (vcMandat, vcSalarie, vcSalariePegase). dépend de l'ordre ! D'ou cela vient t'il ?????*/
            when vcMandat or when vcSalarie or when vcSalariePegase
            then for first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat:
                piNumeroIdentifiant = ctctt.noct1.
            end.
        end case.

        when {&TYPECONTRAT-mandat2Gerance} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Gerance} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                piNumeroIdentifiant = intnt.noidt.
            end.
            /* todo    très étrange comme valeurs (vcMandat, vcSalarie, vcSalariePegase). dépend de l'ordre ! D'ou cela vient t'il ?????*/
            when vcMandat or when vcSalarie or when vcSalariePegase then piNumeroIdentifiant = piNumeroContrat.
        end case.

        when {&TYPECONTRAT-prebail} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Gerance} then piNumeroIdentifiant = truncate(piNumeroRole / 100000, 0).
            when {&TYPECONTRAT-prebail} or when {&TYPECONTRAT-bail} then piNumeroIdentifiant = piNumeroRole.
            when {&TYPEBIEN-immeuble} then for first intnt no-lock                      /* Recherche de l'immeuble */
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPEBIEN-lot} then for first unite no-lock                             /* Recherche du lot principal */
                where unite.nomdt = integer(truncate(piNumeroRole / 100000, 0))
                  and unite.noapp = integer(truncate(piNumeroRole modulo 100000 / 100, 0))
                  and unite.noact = 0
              , first local no-lock
                where local.noimm = unite.noimm
                  and local.nolot = unite.nolot:
                piNumeroIdentifiant = local.noloc.
            end.
            when {&TYPETACHE-cleMagnetiqueDetails} then for first unite no-lock            /* Recherche du lot principal */
                where unite.nomdt = integer(truncate(piNumeroRole / 100000, 0))
                  and unite.noapp = integer(truncate(piNumeroRole modulo 100000 / 100, 0))
                  and unite.noact = 0
              , first vbIntnt no-lock
                where vbIntnt.tpcon = {&TYPECONTRAT-construction}
                  and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
                  and vbIntnt.noidt = unite.noimm
              , last tache no-lock 
                where tache.tpcon = vbIntnt.tpcon
                  and tache.nocon = vbIntnt.nocon
                  and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
                  and tache.tpfin = string(unite.nolot):
                piNumeroIdentifiant = tache.noita.
            end.
            when vcMandat then piNumeroIdentifiant = integer(truncate(piNumeroRole / 100000, 0)).
        end case.

        when {&TYPECONTRAT-bail} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Gerance} then piNumeroIdentifiant = integer(truncate(piNumeroContrat / 100000, 0)).
            when {&TYPECONTRAT-bail} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first intnt no-lock                      /* Recherche de l'immeuble */
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPEBIEN-lot} then for first unite no-lock                           /*    Recherche du lot principal */
                where unite.nomdt = integer(truncate(piNumeroContrat / 100000, 0))
                  and unite.noapp = integer(truncate(piNumeroContrat modulo 100000 / 100, 0))
                  and unite.noact = 0
              , first local no-lock
                where local.noimm = unite.noimm
                  and local.nolot = unite.nolot:
                piNumeroIdentifiant = local.noloc.
            end.
            when {&TYPETACHE-cleMagnetiqueDetails} then for first unite no-lock         /* Recherche du lot principal */
                where unite.nomdt = integer(truncate(piNumeroContrat / 100000, 0))
                  and unite.noapp = integer(truncate(piNumeroContrat modulo 100000 / 100, 0))
                  and unite.noact = 0
              , first vbIntnt no-lock
                where vbIntnt.tpcon = {&TYPECONTRAT-construction}
                  and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
                  and vbIntnt.noidt = unite.noimm
              , last tache no-lock
                where tache.tpcon = vbIntnt.tpcon
                  and tache.nocon = vbIntnt.nocon
                  and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
                  and tache.tpfin = string(unite.nolot):
                piNumeroIdentifiant = tache.noita.
            end.
            when {&TYPETACHE-garantieLocataire} then for first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-garantieLocataire}:
                piNumeroIdentifiant = tache.noita.
            end.
            when {&TYPECONTRAT-evenement} then for last vbEvent no-lock
               where vbEvent.tpcon = pcTypeContrat
                 and vbEvent.nocon = piNumeroContrat:
/* todo   douteux comme moyen d'accès à noeve ???? */
                piNumeroIdentifiant = vbEvent.noeve.
            end.
            /* todo    très étrange comme valeurs (vcMandat, vcSalarie, vcSalariePegase). dépend de l'ordre ! D'ou cela vient t'il ?????*/
            when vcMandat then piNumeroIdentifiant = integer(truncate(piNumeroContrat / 100000, 0)).
            /* todo    très étrange comme valeurs (vcMandat, vcSalarie, vcSalariePegase). dépend de l'ordre ! D'ou cela vient t'il ?????*/
            when vcSalarie or when vcSalariePegase then piNumeroIdentifiant = piNumeroContrat.
        end case.

        when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance}
            then for first ctctt no-lock
                where ctctt.tpct1 = pcTypeIdentifiant
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat:
                piNumeroIdentifiant = ctctt.noct1.
            end.
            when {&TYPEBIEN-immeuble} then for first intnt no-lock                     /* Recherche de l'immeuble */
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then piNumeroIdentifiant = piNumeroContrat.
        end case.

        when {&TYPECONTRAT-DossierMutation} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Syndic} then for first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat:
                piNumeroIdentifiant = ctctt.noct1.
            end.
            when {&TYPECONTRAT-DossierMutation} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat
              , first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = ctctt.tpct1
                  and intnt.nocon = ctctt.noct1:
                piNumeroIdentifiant = intnt.noidt.
            end.
            /* todo    très étrange comme valeurs (vcMandat, vcSalarie, vcSalariePegase). dépend de l'ordre ! D'ou cela vient t'il ?????*/
            when vcMandat or when vcSalarie or when vcSalariePegase
            then for first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat:
                piNumeroIdentifiant = ctctt.noct1.
            end.
        end case.

        when {&TYPECONTRAT-fournisseur} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic}
            then for first ctctt no-lock
                where ctctt.tpct1 = pcTypeIdentifiant
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat:
                piNumeroIdentifiant = ctctt.noct1.
            end.
            when {&TYPECONTRAT-fournisseur} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = pcTypeIdentifiant:
                piNumeroIdentifiant = intnt.noidt.
            end.
            /* todo    très étrange comme valeurs (vcMandat, vcSalarie, vcSalariePegase). dépend de l'ordre ! D'ou cela vient t'il ?????*/
            when vcMandat or when vcSalarie or when vcSalariePegase then do:
                find first ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.tpct2 = pcTypeContrat
                      and ctctt.noct2 = piNumeroContrat no-error.
                if not available ctctt
                then find first ctctt no-lock 
                     where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                       and ctctt.tpct2 = pcTypeContrat
                       and ctctt.noct2 = piNumeroContrat no-error.
                if available ctctt then piNumeroIdentifiant = ctctt.noct1.
            end.
        end case.

        when {&TYPEINTERVENTION-signalement} then case pcTypeIdentifiant:
            when {&TYPEINTERVENTION-signalement} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first inter no-lock
                where inter.nosig = piNumeroContrat
              , first intnt no-lock
                where intnt.tpcon = inter.tpcon
                  and intnt.nocon = inter.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPEBIEN-lot} then run rechercheCritereLot(pcTypeContrat, piNumeroContrat, output piNumeroIdentifiant). /* SY 0312/0102 : Si 1 seul lot rattaché au signalement alors Ajouter lidoc du lot */
        end case.

        when {&TYPEINTERVENTION-demande2devis} then case pcTypeIdentifiant:
            when {&TYPEINTERVENTION-signalement} then for first dtdev no-lock
                where dtdev.nodev = piNumeroContrat
              , first inter no-lock
                where inter.noint = dtdev.noint:
                piNumeroIdentifiant = inter.nosig.
            end.
            when {&TYPEINTERVENTION-demande2devis} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first dtdev no-lock
                where dtdev.nodev = piNumeroContrat
              , first inter no-lock
                where inter.noint = dtdev.noint
              , first intnt no-lock
                where intnt.tpcon = inter.tpcon
                  and intnt.nocon = inter.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPEBIEN-lot} then run rechercheCritereLot (pcTypeContrat, piNumeroContrat, output piNumeroIdentifiant).       /* SY 0312/0102 : Si 1 seul lot rattaché au Devis alors Ajouter lidoc du lot */
            when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then for first dtdev no-lock
                where dtdev.nodev = piNumeroContrat
              , first inter no-lock
                where inter.noint = dtdev.noint:
                run rechercheSalarieImmeuble (input inter.tpcon, input inter.nocon, output piNumeroIdentifiant).
            end.
            when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic} then for first dtdev no-lock
                where dtdev.nodev = piNumeroContrat
              , first inter no-lock
                where inter.noint = dtdev.noint
                  and inter.tpcon = pcTypeIdentifiant:
                piNumeroIdentifiant = inter.nocon.
            end.
        end case.

        when {&TYPEINTERVENTION-ordre2service} then case pcTypeIdentifiant: /* Ordre de Service */
            when {&TYPEINTERVENTION-signalement} then for first dtord no-lock
                where dtord.noord = piNumeroContrat
              , first inter no-lock
                where inter.noint = dtord.noint:
                piNumeroIdentifiant = inter.nosig.
            end.
            when {&TYPEINTERVENTION-ordre2service} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first dtord no-lock
                where dtord.noord = piNumeroContrat
              , first inter no-lock
                where inter.noint = dtord.noint
              , first intnt no-lock
                where intnt.tpcon = inter.tpcon
                  and intnt.nocon = inter.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPEBIEN-lot} then run rechercheCritereLot (pcTypeContrat, piNumeroContrat, output piNumeroIdentifiant).       /* SY 0312/0102 : Si 1 seul lot rattaché à l'OS alors Ajouter lidoc du lot */
            when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then for first ordse no-lock
                where ordse.noord = piNumeroContrat
              , first dtord no-lock
                where dtord.noord = ordse.noord
              , first inter no-lock
                where inter.noint = dtord.noint:
                piNumeroIdentifiant = ordse.nosal.
                if piNumeroIdentifiant = 0 then run rechercheSalarieImmeuble (inter.tpcon, inter.nocon, output piNumeroIdentifiant).
            end.
            when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic} then for first dtord no-lock
                where dtord.noord = piNumeroContrat
              , first inter no-lock 
                where inter.noint = dtord.noint
                  and inter.tpcon = pcTypeIdentifiant:
                piNumeroIdentifiant = inter.nocon.
            end.
        end case.

        when {&TYPEACCORDREGLEMENT-locataire} then case pcTypeIdentifiant:
            when {&TYPEACCORDREGLEMENT-locataire} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPECONTRAT-mandat2Gerance} then for first acreg no-lock
                where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
                  and acreg.nocon = piNumeroContrat
                  and acreg.tplig = "0":
                piNumeroIdentifiant = acreg.nomdt.
            end.
            when {&TYPECONTRAT-bail} then for first acreg no-lock
                where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
                  and acreg.nocon = piNumeroContrat
                  and acreg.tplig = "0":
                piNumeroIdentifiant = acreg.norol.
            end.
            when {&TYPEBIEN-immeuble} then for first acreg no-lock
                where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
                  and acreg.nocon = piNumeroContrat
                  and acreg.tplig = "0"
              , first intnt no-lock
                where intnt.tpcon = acreg.tpmdt
                  and intnt.nocon = acreg.nomdt
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
        end case.

        when {&TYPETACHE-cleMagnetiqueDetails} then case pcTypeIdentifiant:
            when {&TYPETACHE-cleMagnetiqueDetails} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPEBIEN-immeuble} then for first tache no-lock
                where tache.noita = piNumeroContrat
              , first intnt no-lock
                where intnt.tpcon = tache.tpcon
                  and intnt.nocon = tache.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
            when {&TYPEBIEN-lot} then for first tache no-lock
                where tache.noita = piNumeroContrat
              , first intnt no-lock
                where intnt.tpcon = tache.tpcon
                  and intnt.nocon = tache.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
              , first local no-lock
                where local.noimm = intnt.noidt
                  and local.nolot = integer(tache.tpfin):
                piNumeroIdentifiant = local.noloc.
            end.
        end case.

        when {&TYPETACHE-garantieLocataire} then case pcTypeIdentifiant:
            when {&TYPETACHE-garantieLocataire} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPECONTRAT-bail} then for first tache no-lock 
                where tache.noita = piNumeroContrat:
                piNumeroIdentifiant = tache.nocon.
            end.
            when {&TYPEBIEN-immeuble} then for first tache no-lock
                where tache.noita = piNumeroContrat
              , first intnt no-lock
                where intnt.tpcon = tache.tpcon
                  and intnt.nocon = tache.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
        end case.

        when {&TYPECONTRAT-evenement} then do:
            if pcTypeIdentifiant = {&TYPEBIEN-immeuble} 
            then for first vbEvent no-lock where vbEvent.noeve = piNumeroContrat:
                piNumeroIdentifiant = vbEvent.noimm.
            end.
            else if pcTypeIdentifiant = {&TYPECONTRAT-evenement} then piNumeroIdentifiant = piNumeroContrat.
            else if pcTypeIdentifiant > "01000" and pcTypeIdentifiant < "02000" 
            then for first vbEvent no-lock where vbEvent.noeve = piNumeroContrat:
                piNumeroIdentifiant = vbEvent.norol.
            end.
        end. 

        /* Ajout SY le 24/04/2009 */
        when {&TYPETACHE-noteHonoraire} then case pcTypeIdentifiant:
            when {&TYPETACHE-noteHonoraire} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPECONTRAT-mandat2Gerance} then for first tache no-lock
                where tache.noita = piNumeroContrat
              , first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                  and ctctt.tpct2 = tache.tpcon
                  and ctctt.noct2 = tache.nocon:
                piNumeroIdentifiant = ctctt.noct1.
            end.
            when {&TYPECONTRAT-prebail} then for first tache no-lock
                where tache.noita = piNumeroContrat:
                piNumeroIdentifiant = tache.nocon.
            end.
            when {&TYPECONTRAT-MandatLocation} then for first tache no-lock
                where tache.noita = piNumeroContrat:
                piNumeroIdentifiant = integer(tache.ntges).
            end.
            when {&TYPEBIEN-immeuble} then for first tache no-lock
                where tache.noita = piNumeroContrat
              , first intnt no-lock 
                where intnt.tpcon = tache.tpcon
                  and intnt.nocon = tache.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
        end case.

        // Module optionnel RELOCATION ALLIANZ
        when {&TYPEAPPLI-FicheRelocation} then case pcTypeIdentifiant:
            when {&TYPEAPPLI-FicheRelocation} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPECONTRAT-mandat2Gerance} then for first location no-lock
                where location.nofiche = piNumeroContrat:
                piNumeroIdentifiant = location.nocon.
            end.
            when {&TYPECONTRAT-MandatLocation} then for first location no-lock
                where location.nofiche = piNumeroContrat:
                piNumeroIdentifiant = location.nomdtass.
            end.
            when {&TYPEBIEN-immeuble} then for first location no-lock
                where location.nofiche = piNumeroContrat
              , first intnt no-lock
                where intnt.tpcon = location.tpcon
                  and intnt.nocon = location.nocon
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
        end case.

        /* Ajout SY le 07/05/2009 */
        when {&TYPECONTRAT-MandatLocation} then case pcTypeIdentifiant:
            when {&TYPECONTRAT-MandatLocation} then piNumeroIdentifiant = piNumeroContrat.
            when {&TYPECONTRAT-mandat2Gerance} then for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = "06000"
              , first location no-lock
                where location.nofiche = intnt.noidt:
                piNumeroIdentifiant = location.nocon.
            end.
            when {&TYPECONTRAT-bail} then for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = "06000"
              , first location no-lock
                where location.nofiche = intnt.noidt:
                piNumeroIdentifiant = location.noderloc.
            end.
            when "06000" then for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = "06000"
              , first location no-lock
                where location.nofiche = intnt.noidt:
                piNumeroIdentifiant = location.nofiche.
            end.
            when {&TYPEBIEN-immeuble} then for first intnt no-lock 
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                piNumeroIdentifiant = intnt.noidt.
            end.
        end case.
    end case.

end procedure.

procedure rechercheCritereLot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter piIdLocal       as integer   no-undo.

    define variable viNombreLotContrat as integer no-undo.
    define buffer dtlot for dtlot.
    define buffer local for local.

    for each dtlot no-lock
        where dtlot.tptrt = pcTypeContrat 
          and dtlot.notrt = piNumeroContrat
      , first local no-lock
        where local.noloc = dtlot.noloc:
        assign
            viNombreLotContrat = viNombreLotContrat + 1
            piIdLocal          = dtlot.noloc
        .
    end.
    if viNombreLotContrat > 1 then piIdLocal = 0.      /* 1 seul lot possible pour pouvoir valoriser les champs de fusion */

end procedure.

procedure rechercheRoleAnnexe private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche de roles annexe d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeRole      as character no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer intnt for intnt.

    for each intnt no-lock
        where intnt.tpidt = pcTypeRole
          and intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat:
        pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
    end.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheHuissier private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du huissier du cabinet
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer intnt   for intnt.
    define buffer vbroles for roles.

    if pcTypeContrat = {&TYPECONTRAT-DossierMutation}
    then for first intnt no-lock                         /* Recherche de l'huissier: Onglet Opposition */
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-Huissier}:
        pcRetour = substitute("&1&2&3", {&TYPEROLE-Huissier}, SEPAR[1], intnt.noidt).
    end.
    if pcRetour = ? or pcRetour = ""
    then for first vbroles no-lock
        where vbroles.tprol = {&TYPEROLE-Huissier}:
        pcRetour = substitute("&1&2&3", {&TYPEROLE-Huissier}, SEPAR[1], vbroles.norol).
    end.
end procedure.

procedure rechercheCandidatLocataire private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des candidats locataires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer tache for tache.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} then for each ctctt no-lock
           where ctctt.tpct1 = pcTypeContrat
             and ctctt.noct1 = piNumeroContrat
             and ctctt.tpct2 = {&TYPECONTRAT-prebail}
         , first ctrat no-lock
           where ctrat.tpcon = ctctt.tpct2
             and ctrat.nocon = ctctt.noct2:
            pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
            for each intnt no-lock
               where intnt.tpidt = {&TYPEROLE-colocataire}
                 and intnt.tpcon = ctrat.tpcon
                 and intnt.nocon = ctrat.nocon:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPECONTRAT-prebail} then do:
            pcRetour = pcTypeRole + SEPAR[1] + string(piNumeroRole).
            for each intnt no-lock
               where intnt.tpidt = {&TYPEROLE-colocataire}
                 and intnt.tpcon = pcTypeContrat
                 and intnt.nocon = piNumeroContrat:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPETACHE-noteHonoraire} then for last tache no-lock
           where tache.noita = piNumeroContrat
         , first ctrat no-lock
           where ctrat.tpcon = tache.tpcon
             and ctrat.nocon = tache.nocon:
           pcRetour = substitute("&1&2&3", ctrat.tprol, SEPAR[1], ctrat.norol).
        end.
    end case.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheSignalePar private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des signalés par
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer inter for inter.

    case pcTypeContrat:
        when {&TYPEINTERVENTION-signalement} then for first inter no-lock
            where inter.nosig = piNumeroContrat:
            pcRetour = substitute("&1&2&3", inter.tppar, SEPAR[1], inter.nopar).
        end.
    end case.
end procedure.

procedure rechercheGarant private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des garants
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer intnt for intnt.
    define buffer tache for tache.

    case pcTypeContrat:
        when {&TYPETACHE-garantieLocataire} then for first tache no-lock
            where tache.noita = piNumeroContrat:
            pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], {&TYPEROLE-garant}, SEPAR[1], tache.notac).
        end.
        otherwise for each intnt no-lock
            where intnt.tpidt = {&TYPEROLE-garant}
              and intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat:
            pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
    end case.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheLocataire private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des locataires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer ctctt   for ctctt.
    define buffer ctrat   for ctrat.
    define buffer intnt   for intnt.
    define buffer acreg   for acreg.
    define buffer tache   for tache.
    define buffer vbEvent for event.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} then for each ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-bail}
          , first ctrat no-lock
            where Ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-colocataire}
                  and intnt.tpcon = ctrat.tpcon
                  and intnt.nocon = ctrat.nocon:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            pcRetour = pcTypeRole + SEPAR[1] + string(piNumeroRole).
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-colocataire}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPETACHE-garantieLocataire} then for first tache no-lock 
            where tache.noita = piNumeroContrat :
            pcRetour = {&TYPEROLE-locataire} + SEPAR[1] + string(tache.nocon).
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-colocataire}
                  and intnt.tpcon = {&TYPECONTRAT-bail}
                  and intnt.nocon = tache.nocon:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPEACCORDREGLEMENT-locataire} then for first acreg no-lock
            where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
              and acreg.nocon = piNumeroContrat
              and acreg.tplig = "0":
            pcRetour = substitute("&1&2&3", acreg.tprol, SEPAR[1], acreg.norol).
        end.
        when {&TYPECONTRAT-evenement} then for first vbEvent no-lock
            where vbEvent.noeve = piNumeroContrat:
            pcRetour = substitute("&1&2&3", vbEvent.tprol, SEPAR[1], vbEvent.norol).
        end.
    end case.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheMandant private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des mandants d'un contrat 
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer ctrlb for ctrlb.
    define buffer ctctt for ctctt.
    define buffer location for location.

    case pcTypeContrat:
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.nocon = integer(truncate(piNumeroContrat / 100000, 0)):
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
            /* Mandant */
            for first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and ctrat.nocon = integer(truncate(piNumeroContrat / 100000, 0)):
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
            end.
            for each ctrlb no-lock
                where ctrlb.tpctt = {&TYPECONTRAT-mandat2Gerance}
                  and ctrlb.noctt = integer(truncate(piNumeroContrat / 100000, 0))
                  and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                  and ctrlb.nbnum <> 0:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrlb.tpid2, SEPAR[1], ctrlb.noid2).
            end.
        end.
        when {&TYPECONTRAT-mandat2Gerance} then do:
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
            /* Mandant */
            pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], pcTypeRole, SEPAR[1], piNumeroRole).
            for each ctrlb no-lock
                where ctrlb.tpctt = pcTypeContrat
                  and ctrlb.noctt = piNumeroContrat
                  and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                  and ctrlb.nbnum <> 0:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrlb.tpid2, SEPAR[1], ctrlb.noid2).
            end.
        end.
        when {&TYPECONTRAT-fournisseur} then for first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat:
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                  and intnt.tpcon = ctctt.tpct1
                  and intnt.nocon = ctctt.noct1:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
            /* Mandant */
            for first ctrat no-lock
                where ctrat.tpcon = ctctt.tpct1
                  and ctrat.nocon = ctctt.noct1:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
            end.
            for each ctrlb no-lock
               where ctrlb.tpctt = pcTypeContrat
                 and ctrlb.noctt = piNumeroContrat
                 and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                 and ctrlb.nbnum <> 0:
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrlb.tpid2, SEPAR[1], ctrlb.noid2).
            end.
        end.
        when {&TYPETACHE-noteHonoraire} then for last tache no-lock
            where tache.noita = piNumeroContrat
          , first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.tpct2 = tache.tpcon
              and ctctt.noct2 = tache.nocon
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct1
              and ctrat.nocon = ctctt.noct1:
            pcRetour = substitute("&1&2&3", ctrat.tprol, SEPAR[1], ctrat.norol).
        end.
        when "06000" then for first location no-lock
            where location.nofiche = piNumeroContrat:
            pcRetour = substitute("&1&2&3", {&TYPEROLE-mandant}, SEPAR[1], location.noman).
        end.
        when {&TYPECONTRAT-MandatLocation} then for first intnt no-lock
            where intnt.tpcon = pcTypeContrat 
              and intnt.nocon = piNumeroContrat 
              and intnt.tpidt = {&TYPEROLE-mandant}:
            pcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
    end case.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheSalarie private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du gardien d'un contrat 
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcCodeCategorie as character no-undo.
    define output parameter pcRetour        as character no-undo.

    define variable voPayePegase       as class parametre.pclie.parametragePayePegase no-undo.
    define variable viNiveauPaiePegase as integer   no-undo.

    define buffer intnt      for intnt.
    define buffer salar      for salar.
    define buffer vbIntntSal for intnt.

    voPayePegase = new parametre.pclie.parametragePayePegase().
    if voPayePegase:isActif() then viNiveauPaiePegase = voPayePegase:int01.
    delete object voPayePegase.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-bail} then for each intnt no-lock
            /* Modif SY le 13/05/2009: Gérance : salarié de l'immeuble et non du mandat */
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-immeuble}
          , each vbIntntSal no-lock
            where vbIntntSal.tpidt = intnt.tpidt
              and vbIntntSal.noidt = intnt.noidt
              and vbIntntSal.tpcon = (if viNiveauPaiePegase >= 2 then {&TYPECONTRAT-SalariePegase} else {&TYPECONTRAT-Salarie})
          , first salar no-lock
            where salar.tprol = (if viNiveauPaiePegase >= 2 then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
              and salar.norol = vbIntntSal.nocon
              and salar.dtsor = ?:    /* ajout SY le 16/12/2009 : salarié actif */
            if viNiveauPaiePegase >= 2
            then case pcCodeCategorie:
                when "001" then if not salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie gardien */
                when "002" then if     salar.lbdiv5 matches "*CODPROFIL=GIEMP*" or salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie Autre */
                when "003" then if not salar.lbdiv5 matches "*CODPROFIL=GIEMP*" then next. /* Categorie Employe */
            end case.
            else case pcCodeCategorie:
                when "001" then if salar.cdcat <> "00002" and salar.cdcat <> "00003" then next. /* Categorie gardien */
                when "002" then if salar.cdcat <> "00004" and salar.cdcat <> "00005" then next. /* Categorie Autre   */
                when "003" then if salar.cdcat <> "00001"                            then next. /* Categorie Employe */
            end case.
            pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
        end.
        when {&TYPECONTRAT-mandat2Syndic} then do:
            if viNiveauPaiePegase >= 2
            then for each salar no-lock
                where salar.tprol = {&TYPEROLE-salariePegase}
                  and salar.norol >  INT64(string(piNumeroContrat, "99999") + "00001")
                  and salar.norol <= INT64(string(piNumeroContrat, "99999") + "99999")
                  and salar.dtsor = ?:     /* Ajout SY le 16/12/2009 */
                case pcCodeCategorie:
                    when "001" then if not salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie gardien */
                    when "002" then if salar.lbdiv5 matches "*CODPROFIL=GIEMP*" or salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie Autre */
                    when "003" then if not salar.lbdiv5 matches "*CODPROFIL=GIEMP*" then next. /* Categorie Employe */
                end case.
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
            end.
            else for each salar no-lock
                where salar.tprol = {&TYPEROLE-salarie}
                  and salar.norol > integer(string(piNumeroContrat, "9999") + "00")
                  and salar.norol <= integer(string(piNumeroContrat, "9999") + "99")
                  and salar.dtsor = ?:     /* Ajout SY le 16/12/2009 */
                case pcCodeCategorie:
                    when "001" then if salar.cdcat <> "00002" and salar.cdcat <> "00003" then next. /* Categorie gardien */
                    when "002" then if salar.cdcat <> "00004" and salar.cdcat <> "00005" then next. /* Categorie Autre   */
                    when "003" then if salar.cdcat <> "00001"                            then next. /* Categorie Employe */
                end case.
                pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
            end.
        end.
        when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then for first salar no-lock
            where salar.tprol = (if pcTypeContrat = {&TYPECONTRAT-SalariePegase} then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
              and salar.norol = piNumeroContrat:
            if viNiveauPaiePegase >= 2
            then case pcCodeCategorie:
                when "001" then if not salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie gardien */
                when "002" then if salar.lbdiv5 matches "*CODPROFIL=GIEMP*" or salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie Autre */
                when "003" then if not salar.lbdiv5 matches "*CODPROFIL=GIEMP*" then next. /* Categorie Employe */
            end case.
            else case pcCodeCategorie:
                when "001" then if salar.cdcat <> "00002" and salar.cdcat <> "00003" then next. /* Categorie gardien */
                when "002" then if salar.cdcat <> "00004" and salar.cdcat <> "00005" then next. /* Categorie Autre   */
                when "003" then if salar.cdcat <> "00001"                            then next. /* Categorie Employe */
            end case.
            pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
        end.
    end case.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheSalarieImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure recherche du gardien ou du 1er salarié imm à partir d'un mandat 
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeMandat   as character no-undo.
    define input  parameter piNumeroMandat as integer   no-undo.
    define output parameter piNumeroSalImm as integer   no-undo.

    define variable voPayePegase       as class parametre.pclie.parametragePayePegase no-undo.
    define variable viNiveauPaiePegase as integer no-undo.

    define buffer salar      for salar.
    define buffer intnt      for intnt.
    define buffer vbIntntSal for intnt.

    voPayePegase = new parametre.pclie.parametragePayePegase().
    if voPayePegase:isActif() then viNiveauPaiePegase = voPayePegase:int01.
    delete object voPayePegase.
    for each intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , each vbIntntSal no-lock
        where vbIntntSal.tpidt = intnt.tpidt
          and vbIntntSal.noidt = intnt.noidt
          and vbIntntSal.tpcon = (if viNiveauPaiePegase >= 2 then {&TYPECONTRAT-SalariePegase} else {&TYPECONTRAT-Salarie})
      , first salar no-lock
        where salar.tprol = (if viNiveauPaiePegase >= 2 then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
          and salar.norol = vbIntntSal.nocon
          and salar.cdsta = "00001" /* salarié titulaire */
          and salar.dtsor = ?:      /* salarié actif */
        piNumeroSalImm = salar.norol.
        /* Si Gardien : on sort */
        if viNiveauPaiePegase >= 2
        and (salar.lbdiv5 matches substitute("*CODPROFIL=GIGAR&1*", separ[2])
          or salar.cdcat = "00002" or salar.cdcat = "00003") then leave.
    end.

end procedure.

procedure rechercheCoproprietaire private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des coproprietaires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeRole      as character no-undo.
    define output parameter pcRetour        as character no-undo.

    define variable viContratPrincipal as integer no-undo.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctctt   for ctctt.
    define buffer ctrat   for ctrat.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then for each ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-titre2copro}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2
          , first intnt no-lock 
            where intnt.tpcon = ctrat.tpcon
              and intnt.nocon = ctrat.nocon
              and intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.nbden = 0:
            find first vbIntnt no-lock
                where vbIntnt.tpcon = ctrat.tpcon
                  and vbIntnt.nocon = ctrat.nocon
                  and vbIntnt.tpidt = {&TYPEROLE-mandataire} no-error.
            pcRetour = if available vbIntnt and pcTypeRole = "Desti"
                       then substitute("&1&2&3&4&5", pcRetour, SEPAR[2], vbIntnt.tpidt, SEPAR[1], vbIntnt.noidt)
                       else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrat.tprol,   SEPAR[1], ctrat.norol).
        end.
        when {&TYPECONTRAT-titre2copro} then for first ctrat no-lock 
            where ctrat.tpcon = pcTypeContrat
              and ctrat.nocon = piNumeroContrat:
            find first intnt no-lock
                 where intnt.tpcon = ctrat.tpcon
                   and intnt.nocon = ctrat.nocon
                   and intnt.tpidt = {&TYPEROLE-mandataire} no-error.
            pcRetour = if available intnt and pcTypeRole = "Desti" 
                       then substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt)
                       else substitute("&1&2&3", ctrat.tprol, SEPAR[1], ctrat.norol).
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                 where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                   and ctctt.tpct2 = pcTypeContrat
                   and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                viContratPrincipal = ctctt.noct1.
                for each ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.noct1 = viContratPrincipal
                      and ctctt.tpct2 = {&TYPECONTRAT-titre2copro}
                  , first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct2
                      and ctrat.nocon = ctctt.noct2
                  , first intnt no-lock
                    where intnt.tpcon = ctrat.tpcon
                      and intnt.nocon = ctrat.nocon
                      and intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.nbden = 0:
                    find first vbIntnt no-lock
                         where vbIntnt.tpcon = ctrat.tpcon
                           and vbIntnt.nocon = ctrat.nocon
                           and vbIntnt.tpidt = {&TYPEROLE-mandataire} no-error.
                    pcRetour = if available vbIntnt and pcTypeRole = "Desti" 
                               then substitute("&1&2&3&4&5", pcRetour, SEPAR[2], vbIntnt.tpidt, SEPAR[1], vbIntnt.noidt)
                               else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], ctrat.tprol, SEPAR[1], ctrat.norol).
                end.
            end.
        end.
    end case.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des fournisseurs d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcCodeCategorie as character no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer intnt   for intnt.
    define buffer devis   for devis.
    define buffer ordse   for ordse.
    define buffer tache   for tache.
    define buffer ccptcol for ccptcol.
    define buffer csscpt  for csscpt.
    define buffer ifour   for ifour.

    if pcCodeCategorie = ? or pcCodeCategorie = "" then pcCodeCategorie = "000".
    case pcTypeContrat:
        when {&TYPECONTRAT-fournisseur} then for first intnt no-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = "FOU":
            pcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
        when {&TYPEINTERVENTION-demande2devis} then for first devis no-lock
            where devis.nodev = piNumeroContrat:
            pcRetour = substitute("&1&2&3", "FOU", SEPAR[1], devis.nofou).
        end.
        when {&TYPEINTERVENTION-ordre2service} then for first ordse no-lock
            where ordse.noord = piNumeroContrat:
            pcRetour = substitute("&1&2&3", "FOU", SEPAR[1], ordse.nofou).
        end.
        /* mandat location: délégation */
        when {&TYPECONTRAT-MandatLocation} then for last tache no-lock
            where tache.tpcon = pcTypeContrat
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-location}:
            pcRetour = substitute("&1&2&3", tache.tprol, SEPAR[1], tache.norol).
        end.
        otherwise for each ccptcol no-lock
            where ccptcol.soc-cd = mtoken:iCodeSociete
              and ccptcol.tprole = 12
          , each csscpt no-lock 
            where csscpt.soc-cd = ccptcol.soc-cd
              and csscpt.coll-cle = ccptcol.coll-cle      /* Modif SY le 19/08/2005 "F" */
              and csscpt.etab-cd = piNumeroContrat
              and csscpt.cpt-cd <> "00000"
              and csscpt.cpt-cd <> "99999"
          , first ifour no-lock 
            where ifour.soc-cd = csscpt.soc-cd
              and ifour.coll-cle = csscpt.coll-cle
              and ifour.cpt-cd = csscpt.cpt-cd
            break by csscpt.cpt-cd:
            if first-of(csscpt.cpt-cd) then do:
               if pcCodeCategorie <> "000"
               and ((integer(pcCodeCategorie) = 999 and ifour.categ-cd <> 0 and ifour.categ-cd <> 999)
                 or (integer(pcCodeCategorie) <> 999 and integer(pcCodeCategorie) <> ifour.categ-cd)) then next.

               pcRetour = substitute("&1&2&3&4&5", pcRetour, SEPAR[2], "FOU", SEPAR[1], csscpt.cpt-cd).
            end.
        end.
    end case.
    pcRetour = trim(pcRetour, SEPAR[2]).
end procedure.

procedure rechercheCentrePaiement private:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Centre de Paiement
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define variable viNumeroImmeuble as integer   no-undo.
    define variable vcTypeOrganisme  as character no-undo.
    define variable viPos            as integer   no-undo.
    define variable vcParametre      as character no-undo.
    define variable vcListeOrgSoc    as character no-undo.
    define variable vcOrgSocPegase   as character no-undo.
    define variable voTypeCentre     as class parametrageTypeCentre no-undo.
    define variable voCorrespondance as class parametre.pclie.parametrageCorrespondance no-undo.

    define buffer etabl   for etabl.
    define buffer ctrat   for ctrat.
    define buffer vbroles for roles.
    define buffer ctanx   for ctanx.
    define buffer salar   for salar.
    define buffer intnt   for intnt.
    define buffer tache   for tache.
    define buffer ctctt   for ctctt.

    case pcTypeContrat:
        when {&TYPECONTRAT-Salarie} then do:
            voTypeCentre    = new parametrageTypeCentre().
            vcTypeOrganisme = string(voTypeCentre:isGesTypeCentre(), "SIE/ORP").  // même longueur de chaine, pas de trim!
            for first etabl no-lock
                where etabl.nocon = integer(truncate(piNumeroContrat / 100, 0))   // whole-index corrige par la creation dans la version d'un index sur nocon
              , first ctrat no-lock
                where ctrat.tpcon = etabl.tpcon
                  and ctrat.nocon = etabl.nocon
              , first vbroles no-lock
                where vbroles.tprol = ctrat.tprol
                  and vbroles.norol = ctrat.norol
              , first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = vbroles.notie
                  and ctanx.tpren = "YES":
                pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], ctanx.cdobj).
            end.
        end.
        when {&TYPECONTRAT-SalariePegase} then for first salar no-lock /* SY 0114/0244 25/06/2015 */
            where salar.tprol = {&TYPEROLE-salariePegase}
              and salar.norol = piNumeroContrat:
            find first ctctt no-lock
                where (ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic} or ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance})
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt
            then do viPos = 1 to num-entries(salar.lbdiv5, separ[2]):
                vcParametre = entry(viPos, salar.lbdiv5, separ[2]).
                if vcParametre begins "ORGSOC=" then do: 
                    vcListeOrgSoc = entry(2, vcParametre, "=").
                    leave.
                end.
            end.
boucleOrgSoc:
            do viPos = 1 to num-entries(vcListeOrgSoc):
                vcOrgSocPegase = entry(viPos, vcListeOrgSoc).
                if vcOrgSocPegase begins "I" then do:
                    /* Recherche des informations dans la table de correspondance */

/* todo  utilisation d'un ctctt alors qu'il n'est pas toujours available. Si , mais compliqué à voir pourquoi !!! mettre une variable ? */
/*       instanciation d'un objet dans une boucle, pas terrible. ne pas oublier le delete object (dans la boucle, pas que à la fin (on ne supprime que la derniere instanciation*/
                    voCorrespondance = new parametre.pclie.parametrageCorrespondance((if ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro), vcOrgSocPegase).
                    if voCorrespondance:isDbParameter then do:
                        assign
                            vcTypeOrganisme = voCorrespondance:getCollGi()
                            pcRetour        = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], voCorrespondance:getCompteFournisseur()) /* fournisseur en correspondance */
                        .
                        delete object(voCorrespondance).
                        leave boucleOrgSoc.
                    end.
                    delete object(voCorrespondance).
                end. 
            end.
        end.
        when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance} then do:
            vcTypeOrganisme = string(voTypeCentre:isGesTypeCentre(), "SIE/ORP").  // même longueur de chaine, pas de trim!
            for first ctrat no-lock
                where ctrat.tpcon = pcTypeContrat
                  and ctrat.nocon = piNumeroContrat
              , first vbroles no-lock
                where vbroles.tprol = ctrat.tprol
                  and vbroles.norol = ctrat.norol
              , first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                  and ctanx.tprol = "99999"
                  and ctanx.norol = vbroles.notie
                  and ctanx.tpren = "YES":
                pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], ctanx.cdobj).
            end.
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            /* Recherche du centre de paiement rattaché à l'immeuble du locataire */
            vcTypeOrganisme = string(voTypeCentre:isGesTypeCentre(), "SIE/OTS").  // même longueur de chaine, pas de trim!
            find first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
            if available intnt then do:
                viNumeroImmeuble = intnt.noidt.
                for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = viNumeroImmeuble
                  , first tache no-lock
                    where tache.tpcon = intnt.tpcon
                      and tache.nocon = intnt.nocon
                      and tache.tptac = {&TYPETACHE-organismesSociaux}
                      and tache.tpfin = vcTypeOrganisme:
                    pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], trim(tache.ntges)).
                end.
            end.
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            vcTypeOrganisme = string(voTypeCentre:isGesTypeCentre(), "SIE/ORP").  // même longueur de chaine, pas de trim!
            for first ctctt no-lock
                where (ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic} or ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance})
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat
              , first ctrat no-lock
                where ctrat.tpcon = ctctt.tpct1
                  and ctrat.nocon = ctctt.noct1
              , first vbroles no-lock
                where vbroles.tprol = ctrat.tprol
                  and vbroles.norol = ctrat.norol
              , first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                  and ctanx.tprol = "99999"
                  and ctanx.norol = vbroles.notie
                  and ctanx.tpren = "YES":
                pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], ctanx.cdobj).
            end.
        end.
    end case.
end procedure.
