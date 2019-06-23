/*------------------------------------------------------------------------
File        : creationDocument.i
Description : procédures et fonctions de création de documents pour le courrier.
Author(s)   : kantena - 2018/05/
Notes       :
----------------------------------------------------------------------*/
function frmAnnexe      returns character(TpRolTmp as character)    forward.
function frmHuissier    returns character()                         forward.
function frmLocataire   returns character()                         forward.
function frmMandant     returns character()                         forward.
function frmSalarie     returns character(pcCodeCategorie as character)    forward.
function frmCopro       returns character()                         forward.
function frmCopro2      returns character()                         forward.    /* Ajout SY le 12/03/2009 */
function frmFournisseur returns character(pcCodeCategorie as character)    forward.
function frmMembre      returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmVendeur     returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmAcheteur    returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmPresident   returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmAssedic     returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmPaiement    returns character()                         forward.
function frmRecette     returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmCaf         returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmCdi         returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmCompagnie   returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmcourtier    returns character(pcTypeContrat as character, piNumeroContrat as integer) forward.
function frmcanloc      returns character()                         forward.
function frmSignale     returns character()                         forward.
function frmGarant      returns character()                         forward.
function frmCritere     returns integer (pcTypeContrat  as character, piNumeroContrat as integer, TpIdtUse as character, piNumeroRole as integer) forward.
                                                 
function frmCritere returns integer(pcTypeContrat as character, piNumeroContrat as integer, pcTypeIdentifiant as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche de roles annexe d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viNumeroIdentifiant as integer no-undo.

    run prcCritere(pcTypeContrat, piNumeroContrat, pcTypeIdentifiant, piNumeroRole, output viNumeroIdentifiant).
    return viNumeroIdentifiant.

end.

function frmAnnexe returns character(pcTypeRole as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche de roles annexe d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcAnnexe(pcTypeRole, output vcRetour).
    return vcRetour.

end.

function frmHuissier returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche du huissier du cabinet
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcHuissier(output vcRetour).
    return vcRetour.

end.

function frmCanLoc returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des candidats locataires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcCanLoc(output vcRetour).
    return vcRetour.

end.

function frmSignale returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des signalés par
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcSignale(output vcRetour).
    return vcRetour.

end.

function frmGarant returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des Garants
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcGarant(output vcRetour).
    return vcRetour.

end.

function frmLocataire returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des locataires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcLocataire(output vcRetour).
    return vcRetour.

end.

function frmMandant returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des mandants d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcMandant(output vcRetour).
    return vcRetour.

end.

function frmSalarie returns character(pcCodeCategorie as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du gardien d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcSalarie(pcCodeCategorie, output vcRetour).
    return vcRetour.

end.

function frmCopro returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des destinataires des coproprietaires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcCopro(input "Desti", output vcRetour).
    return vcRetour.

end function.

function frmCopro2 returns character():
    /*------------------------------------------------------------------------------
    Purpose: Recherche des coproprietaires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcCopro(input "Copro", output vcRetour).
    return vcRetour.

end function.

function frmFournisseur returns character(pcCodeCategorie as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche des fournisseurs d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    run prcFournisseur(pcCodeCategorie, output vcRetour).
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
        when {&TYPECONTRAT-mandat2Syndic} then do:
            for last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-conseilSyndical}
               , each Taint no-lock
                where taint.tpcon = tache.tpcon
                  and taint.nocon = tache.nocon
                  and taint.tpidt = {&TYPEROLE-membreConseilSyndical}
                  and taint.tptac = tache.tptac
                  and taint.notac = tache.notac:
                vcRetour = if vcRetour = ""
                           then substitute("&1&2&3", taint.tpidt, SEPAR[1], taint.noidt)
                           else substitute("&1&2&3&4&5",
                                           vcRetour,
                                           SEPAR[2],
                                           taint.tpidt,
                                           SEPAR[1],
                                           taint.noidt).
            end.
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt 
            then for last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-conseilSyndical}
               , each Taint no-lock
                where taint.tpcon = tache.tpcon
                  and taint.nocon = tache.nocon
                  and taint.tpidt = {&TYPEROLE-membreConseilSyndical}
                  and taint.tptac = tache.tptac
                  and taint.notac = tache.notac:
                vcRetour = if vcRetour = ""
                           then substitute("&1&2&3", taint.tpidt, SEPAR[1], taint.noidt)
                           else substitute("&1&2&3&4&5",
                                           vcRetour,
                                           SEPAR[2],
                                           taint.tpidt,
                                           SEPAR[1],
                                           taint.noidt).
            end.
        end.
    end.
    return vcRetour.

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
        when {&TYPECONTRAT-mandat2Syndic} then do:
            for last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-conseilSyndical}
               , each taint no-lock
                where taint.tpcon = tache.tpcon
                  and taint.nocon = tache.nocon
                  and taint.tpidt = {&TYPEROLE-presidentConseilSyndical}
                  and taint.tptac = tache.tptac
                  and taint.notac = tache.notac:
                vcRetour = if vcRetour = ""
                           then substitute("&1&2&3", taint.tpidt, SEPAR[1], taint.noidt)
                           else substitute("&1&2&3&4&5",
                                           vcRetour,
                                           SEPAR[2],
                                           taint.tpidt,
                                           SEPAR[1],
                                           taint.noidt).
            end.
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            find ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then for last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-conseilSyndical}
               , each Taint no-lock 
                where taint.tpcon = tache.tpcon
                  and taint.Nocon = tache.nocon
                  and taint.TpIdt = {&TYPEROLE-presidentConseilSyndical}
                  and taint.TpTac = tache.tptac
                  and taint.NoTac = tache.notac:
                vcRetour = if vcRetour = ""
                           then substitute("&1&2&3", taint.tpidt, SEPAR[1], taint.noidt)
                           else substitute("&1&2&3&4&5", 
                                           vcRetour,
                                           SEPAR[2],
                                           taint.tpidt,
                                           SEPAR[1],
                                           taint.noidt).
            end.
        end.
    end.
    return vcRetour.

end function.

function frmAssedic returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Centre Assedic
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    define buffer etabl for etabl.
    define buffer ctctt for ctctt.

    /* NB: Les centres ASSEDIC n'existe plus : La fusion de l'ANPE et du réseau des Assedic doit prendre effet le 1er janvier 2009 */  
    case pcTypeContrat:
        when {&TYPECONTRAT-Salarie} then do:
            find first etabl no-lock 
                where etabl.nocon = integer(substring(string(piNumeroContrat, "999999"), 1, 4)) no-error.
            if available etabl then vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
        end.
        when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance} then do:
            find first etabl no-lock
                where etabl.tpcon = pcTypeContrat
                  and etabl.nocon = piNumeroContrat no-error.
            if available etabl then vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            find first etabl no-lock
                where etabl.tpcon = pcTypeContrat
                  and etabl.nocon = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5)) no-error.
            if available etabl then vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock 
                where (ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic} or ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance})
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                find first etabl no-lock
                    where etabl.tpcon = ctctt.tpct1
                      and etabl.nocon = ctctt.noct1 no-error.
                if available etabl then vcRetour = substitute("OAS&1&2", SEPAR[1], etabl.cdass).
            end.
        end.
    end.
    return vcRetour.

end function.

function frmPaiement returns character():
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
    define variable viNumeroImmeuble as integer   no-undo.
    define variable vcTypeOrganisme  as character no-undo.
    define variable vcTemp           as character no-undo.
    define variable viCpUseInc       as integer   no-undo.
    
    define buffer etabl for etabl.
    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer ctctt for ctctt.

    vcTypeOrganisme = "ODB".
    if GestionSie() then vcTypeOrganisme = "SIE".
    case pcTypeContrat:
        when {&TYPECONTRAT-Salarie} then do:
            find first etabl no-lock
                 where etabl.nocon = integer(substring(string(piNumeroContrat, "999999"), 1, 4)) no-error.
            if available etabl and etabl.tpcon = {&TYPECONTRAT-mandat2Gerance} then do:
                /* Recherche de la tache TVA ou Droit de bail */
                find first tache no-lock
                    where tache.tpcon = etabl.tpcon
                      and tache.nocon = etabl.nocon
                      and tache.tptac = {&TYPETACHE-CRL}
                      and tache.notac = 1 no-error.
                if not available tache then
                    find first tache no-lock
                        where tache.tpcon = tache.tpcon
                          and tache.nocon = tache.nocon
                          and tache.tptac = {&TYPETACHE-TVA}
                          and tache.notac = 1 no-error.
                if available tache and tache.utreg <> "" 
                then vcRetour = substitute("&1&2&3&4", 
                                           vcTypeOrganisme,
                                           SEPAR[1],
                                           substring(tache.utreg, 1, 3),
                                           substring(tache.utreg, 5, 2)).
            end.
        end.
        when {&TYPECONTRAT-mandat2Gerance} then do:
            /* Recherche de la tache TVA ou Droit de bail */
            find first tache no-lock 
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-CRL}
                  and tache.notac = 1 no-error.
            if not available tache then
                find first tache no-lock
                    where tache.tpcon = tache.tpcon
                      and tache.nocon = tache.nocon
                      and tache.tptac = {&TYPETACHE-TVA}
                      and tache.notac = 1 no-error.
            if available tache and tache.utreg <> "" 
            then vcRetour = substitute("&1&2&3&4",
                                       vcTypeOrganisme,
                                       SEPAR[1],
                                       substring(tache.utreg, 1, 3),
                                       substring(tache.utreg, 5, 2)).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            /* Recherche du cdi rattaché à l'immeuble du locataire */
            find first intnt no-lock
                 where intnt.tpcon = pcTypeContrat
                   and intnt.nocon = piNumeroContrat
                   and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
            if available intnt then do:
                viNumeroImmeuble = intnt.noidt.
                find first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = viNumeroImmeuble  no-error.
                if available intnt then do:
                    find first tache no-lock
                        where tache.tpcon = intnt.tpcon
                          and tache.nocon = intnt.nocon
                          and tache.tptac = {&TYPETACHE-organismesSociaux}
                          and tache.tpfin = vcTypeOrganisme no-error.
                    if available tache then do:
                        assign
                            vcTemp     = trim(tache.ntges)
                            viCpUseInc = integer(substring(vcTemp, 1, 3) + substring(vcTemp, 5, 2)) 
                        no-error.
                        if not error-status:error 
                        then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
                    end.
                end.
            end.
        end.
        when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                 where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                   and ctctt.tpct2 = pcTypeContrat
                   and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                find first tache no-lock
                     where tache.tpcon = ctctt.tpct1
                       and tache.nocon = ctctt.noct1
                       and tache.tptac = {&TYPETACHE-CRL}
                       and tache.notac = 1 no-error.
                if not available tache then
                    find first tache no-lock
                         where tache.tpcon = tache.tpcon
                           and tache.nocon = tache.nocon
                           and tache.tptac = {&TYPETACHE-TVA}
                           and tache.notac = 1 no-error.
                if available tache and tache.utreg <> "" 
                then vcRetour = substitute("&1&2&3&4",
                                           vcTypeOrganisme,
                                           SEPAR[1],
                                           substring(tache.utreg, 1, 3),
                                           substring(tache.utreg, 5, 2)).
            end.
        end.
    end.
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
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-immeuble}:
                voResidenceCAF = new parametre.pclie.parametrageResidenceCAF(string(intnt.noidt)).
                if voResidenceCAF:isDbParameter
                then vcRetour = substitute("CAF&1&2", SEPAR[1], voResidenceCAF:zon02).
                delete object voResidenceCAF.
            end.
        end.
    end.
    return vcRetour.

end function.

function frmCdi returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du CDI : centre des impots
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour         as character no-undo.
    define variable viNumeroImmeuble as integer   no-undo.
    define variable vcTypeOrganisme  as character no-undo.
    define variable vcTemp           as character no-undo.
    define variable viCpUseInc       as integer   no-undo.

    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer ctctt for ctctt.

    vcTypeOrganisme = "CDI".
    if GestionSie() then vcTypeOrganisme = "SIE".
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
            if available tache and tache.dcreg <> "" then do:
                assign
                    vcTemp = trim(tache.dcreg)
                    viCpUseInc = (if vcTypeOrganisme = "CDI" then integer(substring(vcTemp, 1, 3) + substring(vcTemp, 5, 2)) else integer(vcTemp))
                no-error.
                if not error-status:error then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
            end.
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            /* Recherche du cdi rattaché à l'immeuble du locataire */
            find first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
            if available intnt then do:
                viNumeroImmeuble = intnt.noidt.
                find first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = viNumeroImmeuble no-error.
                if available intnt then do:
                    find first tache no-lock
                         where tache.tpcon = intnt.tpcon
                           and tache.nocon = intnt.nocon
                           and tache.tptac = {&TYPETACHE-organismesSociaux}
                           and tache.tpfin = "CDI" no-error.
                    if available tache then do:
                        assign
                            vcTemp     = trim(tache.ntges)
                            viCpUseInc = (if vcTypeOrganisme = "CDI" then integer(substring(vcTemp, 1, 3) + substring(vcTemp, 5, 2)) else integer(vcTemp))
                        no-error.
                        if not error-status:error then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
                    end.
                end.
            end.
        end.
        when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                /* Recherche de la tache TVA ou Droit de bail */
                find first tache no-lock
                    where tache.tpcon = ctctt.tpct1
                      and tache.nocon = ctctt.noct1
                      and tache.tptac = {&TYPETACHE-CRL}
                      and tache.notac = 1 no-error.
                if not available tache then
                    find first tache no-lock
                         where tache.tpcon = tache.tpcon
                           and tache.nocon = tache.nocon
                           and tache.tptac = {&TYPETACHE-TVA}
                           and tache.notac = 1 no-error.
                if available tache and tache.dcreg <> "" then do:
                    assign
                        vcTemp     = trim(tache.dcreg)
                        viCpUseInc = (if vcTypeOrganisme = "CDI" then integer(substring(vcTemp, 1, 3) + substring(vcTemp, 5, 2)) else integer(vcTemp))
                    no-error.
                    if not error-status:error then vcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], viCpUseInc).
                end.
            end.
        end.
    end.
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
        when {&TYPECONTRAT-mandat2Syndic} 
        then for last ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                   if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                   ctrat.tprol,
                                   SEPAR[1],
                                   ctrat.norol).
        end.
        when {&TYPECONTRAT-mandat2Gerance} 
        then for last ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                  if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                  ctrat.tprol,
                                  SEPAR[1],
                                  ctrat.norol).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} 
        then for last ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct1 = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5))
              and Ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                  if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                  ctrat.tprol,
                                  SEPAR[1],
                                  ctrat.norol).
        end.
        when {&TYPECONTRAT-titre2copro} 
        then for last ctctt no-lock
           where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
             and ctctt.noct1 = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5))
             and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
         , first ctrat no-lock 
           where ctrat.tpcon = ctctt.tpct2
             and ctrat.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                  if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                  ctrat.tprol,
                                  SEPAR[1],
                                  ctrat.norol).
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
                    vcRetour = substitute("&1&2&3&4",
                                          if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                          ctrat.tprol,
                                          SEPAR[1],
                                          ctrat.norol).
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
                        vcRetour = substitute("&1&2&3&4",
                                              if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                              ctrat.tprol,
                                              SEPAR[1],
                                              ctrat.norol).
                    end.
                end.
            end.
        end.
    end case.
    return vcRetour.

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
        when {&TYPECONTRAT-mandat2Syndic} 
        then for last ctctt no-lock
           where ctctt.tpct1 = pcTypeContrat
             and ctctt.noct1 = piNumeroContrat
             and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
          , each intnt no-lock
           where intnt.tpidt = {&TYPEROLE-courtier}
             and intnt.tpcon = ctctt.tpct2
             and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                  if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                  intnt.tpidt,
                                  SEPAR[1],
                                  intnt.noidt).
        end.
        when {&TYPECONTRAT-mandat2Gerance} 
        then for last ctctt no-lock
            where ctctt.tpct1 = pcTypeContrat
              and ctctt.noct1 = piNumeroContrat
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
           , each intnt no-lock
            where intnt.tpidt = {&TYPEROLE-courtier}
              and intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                  if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                  intnt.tpidt,
                                  SEPAR[1],
                                  intnt.noidt).
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail}
        then for last ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and ctctt.noct1 = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5))
              and Ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}
           , each intnt no-lock 
            where intnt.tpidt = {&TYPEROLE-courtier}
              and intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                  if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                  intnt.tpidt,
                                  SEPAR[1],
                                  intnt.noidt).
        end.
        when {&TYPECONTRAT-titre2copro} 
        then for last ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
              and ctctt.noct1 = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5))
              and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic}
          , first intnt no-lock
            where intnt.tpidt = {&TYPEROLE-courtier}
              and intnt.tpcon = ctctt.tpct2
              and intnt.nocon = ctctt.noct2:
            vcRetour = substitute("&1&2&3&4",
                                  if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                  intnt.tpidt,
                                  SEPAR[1],
                                  intnt.noidt).
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
                    vcRetour = substitute("&1&2&3&4",
                                          if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                          intnt.tpidt,
                                          SEPAR[1],
                                          intnt.noidt).
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
                        vcRetour = substitute("&1&2&3&4",
                                   if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                   intnt.tpidt,
                                   SEPAR[1],
                                   intnt.noidt).
                    end.
                end.
            end.
        end.
    end.
    return vcRetour.

end function.

function frmVendeur returns character(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Vendeur du dossier de mutation
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.

    define buffer intnt for intnt.

    if pcTypeContrat = {&TYPECONTRAT-DossierMutation} then do:
        find first intnt no-lock 
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEROLE-vendeur} no-error.
        if available intnt then vcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
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

    if pcTypeContrat = {&TYPECONTRAT-DossierMutation} then do:
        find first intnt no-lock
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEROLE-acheteur} no-error.
        if available intnt then vcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
    end.
    return vcRetour.

end function.

procedure prcCritere:
    /*------------------------------------------------------------------------------
    Purpose: Recherche l'identifiant du critere supplementaire lié
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat       as character no-undo.
    define input  parameter piNumeroContrat     as integer   no-undo.
    define input  parameter pcTypeIdentifiant   as character no-undo.
    define input  parameter piNumeroRole        as integer   no-undo.
    define output parameter piNumeroIdentifiant as integer   no-undo.

    define buffer Intnt  for intnt.
    define buffer bIntnt for intnt.
    define buffer ctctt  for ctctt.
    define buffer tache  for tache.
    define buffer unite  for unite.
    define buffer local  for local.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Syndic} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    find first intnt no-lock 
                         where intnt.tpidt = {&TYPEBIEN-immeuble}
                           and intnt.tpcon = pcTypeContrat
                           and intnt.nocon = piNumeroContrat no-error.
                    if available intnt then piNumeroIdentifiant = intnt.noidt.
                end.
                when "01030+01003" or when "01030+01033+01003+01045" or when "01030+01033+01003+01145" then piNumeroIdentifiant = piNumeroContrat.
            end.
        end.
        when {&TYPECONTRAT-titre2copro} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Syndic} then do:
                    find first ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                          and ctctt.tpct2 = pcTypeContrat
                          and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then piNumeroIdentifiant = ctctt.noct1.
                end.
                when {&TYPECONTRAT-titre2copro} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    find first ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                          and ctctt.tpct2 = pcTypeContrat
                          and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then do:
                        find first intnt no-lock 
                             where intnt.tpidt = {&TYPEBIEN-immeuble}
                               and intnt.tpcon = ctctt.tpct1
                               and intnt.nocon = ctctt.noct1 no-error.
                        if available intnt then piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when {&TYPEBIEN-lot} then do:
                    for first intnt no-lock
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = {&TYPEBIEN-lot}
                          and intnt.nbden = 0:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when {&TYPETACHE-cleMagnetiqueDetails} then do:
                    for first intnt no-lock 
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = {&TYPEBIEN-lot}
                          and intnt.nbden = 0
                      , first local no-lock
                        where local.noloc = intnt.noidt:
                        for first bintnt no-lock
                            where bintnt.tpcon = {&TYPECONTRAT-construction}
                              and bintnt.tpidt = {&TYPEBIEN-immeuble}
                              and bintnt.noidt = local.noimm
                           , last tache no-lock 
                            where tache.tpcon = bintnt.tpcon
                              and tache.nocon = bintnt.nocon
                              and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
                              and tache.tpfin = string(local.nolot):
                            piNumeroIdentifiant = tache.noita.
                        end.
                    end.
                end.
                when "01030+01003" or when "01030+01033+01003+01045" or when "01030+01033+01003+01145" then do:
                    find ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                          and ctctt.tpct2 = pcTypeContrat
                          and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then piNumeroIdentifiant = ctctt.noct1.
                end.
            end.
        end.
        when {&TYPECONTRAT-mandat2Gerance} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Gerance} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    find intnt no-lock
                        where intnt.tpidt = {&TYPEBIEN-immeuble}
                          and intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat no-error.
                    if available intnt then piNumeroIdentifiant = intnt.noidt.
                end.
                when "01030+01003" or when "01030+01033+01003+01045" or when "01030+01033+01003+01145" then piNumeroIdentifiant = piNumeroContrat.
            end.
        end.
        when {&TYPECONTRAT-prebail} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Gerance} then piNumeroIdentifiant = integer(substring(string(piNumeroRole, "9999999999"), 1, 5)).
                when {&TYPECONTRAT-prebail} or when {&TYPECONTRAT-bail} then piNumeroIdentifiant = piNumeroRole.
                when {&TYPEBIEN-immeuble} then do:
                    /* Recherche de l'immeuble */
                    for first intnt no-lock
                         where intnt.tpidt = {&TYPEBIEN-immeuble}
                           and intnt.tpcon = pcTypeContrat
                           and intnt.nocon = piNumeroContrat:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when {&TYPEBIEN-lot} then do:
                    /* Recherche du lot principal */
                    find first unite no-lock
                         where unite.nomdt = integer(substring(string(piNumeroRole, "9999999999"), 1, 5))
                           and unite.noapp = integer(substring(string(piNumeroRole, "9999999999"), 6, 3))
                           and unite.noact = 0 no-error.
                    if available unite then do:
                        find first local no-lock
                             where local.noimm = unite.noimm
                               and local.nolot = unite.nolot no-error.
                        if available local then piNumeroIdentifiant = local.noloc.
                    end.
                end.
                when {&TYPETACHE-cleMagnetiqueDetails} then do:
                    /* Recherche du lot principal */
                    find first unite no-lock
                        where unite.nomdt = integer(substring(string(piNumeroRole, "9999999999"), 1, 5))
                          and unite.noapp = integer(substring(string(piNumeroRole, "9999999999"), 6, 3))
                          and unite.noact = 0 no-error.
                    if available unite then do:
                        for first bintnt no-lock
                            where intnt.tpcon = {&TYPECONTRAT-construction}
                              and bintnt.tpidt = {&TYPEBIEN-immeuble}
                              and bintnt.noidt = unite.noimm
                           , last tache no-lock 
                            where tache.tpcon = bintnt.tpcon
                              and tache.nocon = bintnt.nocon
                              and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
                              and tache.tpfin = string(unite.nolot):
                            piNumeroIdentifiant = tache.noita.
                        end.
                    end.
                end.
                when "01030+01003" then piNumeroIdentifiant = integer(substring(string(piNumeroRole, "9999999999"), 1, 5)).
            end.
        end.
        when {&TYPECONTRAT-bail} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Gerance} then piNumeroIdentifiant = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5)).
                when {&TYPECONTRAT-bail} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    /* Recherche de l'immeuble */
                    find first intnt no-lock
                         where intnt.tpidt = {&TYPEBIEN-immeuble}
                           and intnt.tpcon = pcTypeContrat
                           and intnt.nocon = piNumeroContrat no-error.
                    if available intnt then piNumeroIdentifiant = intnt.noidt.
                end.
                when {&TYPEBIEN-lot} then do:
                    /*    Recherche du lot principal */
                    find first unite no-lock
                        where unite.nomdt = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5))
                          and unite.noapp = integer(substring(string(piNumeroContrat, "9999999999"), 6, 3))
                          and unite.noact = 0 no-error.
                    if available unite then do:
                        find first local no-lock
                            where local.noimm = unite.noimm
                              and local.nolot = unite.nolot no-error.
                        if available local 
                        then piNumeroIdentifiant = local.noloc.
                    end.
                end.
                when {&TYPETACHE-cleMagnetiqueDetails} then do:
                    /* Recherche du lot principal */
                    find first unite no-lock
                         where unite.nomdt = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5))
                           and unite.noapp = integer(substring(string(piNumeroContrat, "9999999999"), 6, 3))
                           and unite.noact = 0
                     no-error.
                    if available unite then do:
                        for first bintnt no-lock
                            where intnt.tpcon  = {&TYPECONTRAT-construction}
                              and bintnt.tpidt = {&TYPEBIEN-immeuble}
                              and bintnt.noidt = unite.noimm
                           , last tache no-lock
                            where tache.tpcon = bintnt.tpcon
                              and tache.nocon = bintnt.nocon
                              and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
                              and tache.tpfin = string(unite.nolot):
                            piNumeroIdentifiant = tache.noita.
                        end.
                    end.
                end.
                when {&TYPETACHE-garantieLocataire} then do:
                    for first tache no-lock
                        where tache.tpcon = pcTypeContrat
                          and tache.nocon = piNumeroContrat
                          and tache.tptac = {&TYPETACHE-garantieLocataire}:
                        piNumeroIdentifiant = tache.noita.
                    end.
                end.
                when "01088" then do:
                    for last event no-lock
                       where event.tpcon = pcTypeContrat
                         and event.nocon = piNumeroContrat:
                        piNumeroIdentifiant = event.noeve.
                    end.
                end.
                when "01030+01003" then piNumeroIdentifiant = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5)).
                when "01030+01033+01003+01045" or when "01030+01033+01003+01145" then piNumeroIdentifiant = piNumeroContrat.
            end.
        end.
        when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance} then do:
                    for first ctctt no-lock
                        where ctctt.tpct1 = pcTypeIdentifiant
                          and ctctt.tpct2 = pcTypeContrat
                          and ctctt.noct2 = piNumeroContrat:
                        piNumeroIdentifiant = ctctt.noct1.
                    end.
                end.
                when {&TYPEBIEN-immeuble} then do:
                    /* Recherche de l'immeuble */
                    find first intnt no-lock
                         where intnt.tpidt = {&TYPEBIEN-immeuble}
                           and intnt.tpcon = pcTypeContrat
                           and intnt.nocon = piNumeroContrat no-error.
                    if available intnt then piNumeroIdentifiant = intnt.noidt.
                end.
                when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then piNumeroIdentifiant = piNumeroContrat.
            end.
        end.
        when {&TYPECONTRAT-DossierMutation} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Syndic} then do:
                    find first ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                          and ctctt.tpct2 = pcTypeContrat
                          and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then piNumeroIdentifiant = ctctt.noct1.
                end.
                when {&TYPECONTRAT-DossierMutation} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    find first ctctt no-lock
                         where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                           and ctctt.tpct2 = pcTypeContrat
                           and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then do:
                        find first intnt no-lock
                            where intnt.tpidt = {&TYPEBIEN-immeuble}
                              and intnt.tpcon = ctctt.tpct1
                              and intnt.nocon = ctctt.noct1 no-error.
                        if available intnt then piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when "01030+01003" or when "01030+01033+01003+01045" or when "01030+01033+01003+01145" then do:
                    find first ctctt no-lock
                         where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                           and ctctt.tpct2 = pcTypeContrat
                           and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then piNumeroIdentifiant = ctctt.noct1.
                end.
            end.
        end.
        when {&TYPECONTRAT-fournisseur} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic} then do:
                    find first ctctt no-lock
                         where ctctt.tpct1 = pcTypeIdentifiant
                           and ctctt.tpct2 = pcTypeContrat
                           and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then piNumeroIdentifiant = ctctt.noct1.
                end.
                when {&TYPECONTRAT-fournisseur} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    find first intnt no-lock
                         where intnt.tpcon = pcTypeContrat
                           and intnt.nocon = piNumeroContrat
                           and intnt.tpidt = pcTypeIdentifiant no-error.
                    if available intnt then piNumeroIdentifiant = intnt.noidt.
                end.
                when "01030+01003" or when "01030+01033+01003+01045" or when "01030+01033+01003+01145" then do:
                    find first ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                          and ctctt.tpct2 = pcTypeContrat
                          and ctctt.noct2 = piNumeroContrat no-error.
                    if not available ctctt then
                        find first ctctt no-lock 
                             where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                               and ctctt.tpct2 = pcTypeContrat
                               and ctctt.noct2 = piNumeroContrat no-error.
                    if available ctctt then piNumeroIdentifiant = ctctt.noct1.
                end.
            end.
        end.
        when {&TYPEINTERVENTION-signalement} then do:
            case pcTypeIdentifiant:
                when {&TYPEINTERVENTION-signalement} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    for first inter no-lock
                        where inter.nosig = piNumeroContrat
                      , first intnt no-lock
                        where intnt.tpcon = inter.tpcon
                          and intnt.nocon = inter.nocon
                          and intnt.tpidt = {&TYPEBIEN-immeuble}:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when {&TYPEBIEN-lot} then run PrcCritere-Lot (pcTypeContrat, piNumeroContrat, piNumeroRole, output piNumeroIdentifiant). /* SY 0312/0102 : Si 1 seul lot rattaché au signalement alors Ajouter lidoc du lot */
            end.
        end.
        when {&TYPEINTERVENTION-demande2devis} then do:
            case pcTypeIdentifiant:
                when {&TYPEINTERVENTION-signalement} then do:
                    for first dtdev no-lock
                        where dtdev.nodev = piNumeroContrat
                      , first inter no-lock
                        where inter.noint = dtdev.noint:
                        piNumeroIdentifiant = inter.nosig.
                    end.
                end.
                when {&TYPEINTERVENTION-demande2devis} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    for first dtdev no-lock
                        where dtdev.nodev = piNumeroContrat
                      , first inter no-lock
                        where inter.noint = dtdev.noint
                      , first intnt no-lock
                        where intnt.tpcon = inter.tpcon
                          and intnt.nocon = inter.nocon
                          and intnt.tpidt = {&TYPEBIEN-immeuble}:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when {&TYPEBIEN-lot} then run PrcCritere-Lot (pcTypeContrat, piNumeroContrat, piNumeroRole, output piNumeroIdentifiant).       /* SY 0312/0102 : Si 1 seul lot rattaché au Devis alors Ajouter lidoc du lot */
                when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then do:
                    for first dtdev no-lock
                        where dtdev.nodev = piNumeroContrat
                      , first inter no-lock
                        where inter.noint = dtdev.noint:
                        run Salarie-Immeuble (input inter.tpcon, input inter.nocon, output piNumeroIdentifiant).
                    end.
                end.
                when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic} then do:
                    for first dtdev no-lock
                        where dtdev.nodev = piNumeroContrat
                      , first inter no-lock
                        where inter.noint = dtdev.noint
                          and inter.tpcon = pcTypeIdentifiant:
                        piNumeroIdentifiant = inter.nocon.
                    end.
                end.
            end.
        end.
        when {&TYPEINTERVENTION-ordre2service} then do: /* Ordre de Service */
            case pcTypeIdentifiant:
                when {&TYPEINTERVENTION-signalement} then do:
                    for first dtord no-lock
                        where dtord.noord = piNumeroContrat
                      , first inter no-lock
                        where inter.noint = dtord.noint:
                        piNumeroIdentifiant = inter.nosig.
                    end.
                end.
                when {&TYPEINTERVENTION-ordre2service} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    for first dtord no-lock
                        where dtord.noord = piNumeroContrat
                      , first inter no-lock
                        where inter.noint = dtord.noint
                      , first intnt no-lock
                        where intnt.tpcon = inter.tpcon
                          and intnt.nocon = inter.nocon
                          and intnt.tpidt = {&TYPEBIEN-immeuble}:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when {&TYPEBIEN-lot} then run PrcCritere-Lot (pcTypeContrat, piNumeroContrat, piNumeroRole, output piNumeroIdentifiant).       /* SY 0312/0102 : Si 1 seul lot rattaché à l'OS alors Ajouter lidoc du lot */
                when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then do:
                    for first ordse no-lock
                        where ordse.noord = piNumeroContrat
                      , first dtord no-lock
                        where dtord.noord = ordse.noord
                      , first inter no-lock
                        where inter.noint = dtord.noint:
                        piNumeroIdentifiant = ordse.nosal.
                        if piNumeroIdentifiant = 0 then run Salarie-Immeuble (inter.tpcon, inter.nocon, output piNumeroIdentifiant).
                    end.
                end.
                when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic} then do:
                    for first dtord no-lock
                        where dtord.noord = piNumeroContrat
                      , first inter no-lock 
                        where inter.noint = dtord.noint
                          and inter.tpcon = pcTypeIdentifiant:
                        piNumeroIdentifiant = inter.nocon.
                    end.
                end.
            end.
        end.
        when {&TYPEACCORDREGLEMENT-locataire} then do:
            case pcTypeIdentifiant:
                when {&TYPEACCORDREGLEMENT-locataire} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPECONTRAT-mandat2Gerance} then do:
                    for first acreg no-lock
                        where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
                          and acreg.nocon = piNumeroContrat
                          and acreg.tplig = "0":
                        piNumeroIdentifiant = acreg.nomdt.
                    end.
                end.
                when {&TYPECONTRAT-bail} then do:
                    for first acreg no-lock
                        where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
                          and acreg.nocon = piNumeroContrat
                          and acreg.tplig = "0":
                        piNumeroIdentifiant = acreg.norol.
                    end.
                end.
                when {&TYPEBIEN-immeuble} then do:
                    for first acreg no-lock
                        where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
                          and acreg.nocon = piNumeroContrat
                          and acreg.tplig = "0"
                      , first intnt no-lock
                        where intnt.tpcon = acreg.tpmdt
                          and intnt.nocon = acreg.nomdt
                          and intnt.tpidt = {&TYPEBIEN-immeuble}:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
            end.
        end.
        when {&TYPETACHE-cleMagnetiqueDetails} then do:
            case pcTypeIdentifiant:
                when {&TYPETACHE-cleMagnetiqueDetails} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPEBIEN-immeuble} then do:
                    for first tache no-lock
                        where tache.noita = piNumeroContrat
                      , first intnt no-lock
                        where intnt.tpcon = tache.tpcon
                          and intnt.nocon = tache.nocon
                          and intnt.tpidt = {&TYPEBIEN-immeuble}:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
                when {&TYPEBIEN-lot} then do:
                    for first tache no-lock
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
                end.
            end.
        end.
        when {&TYPETACHE-garantieLocataire} then do:
            case pcTypeIdentifiant:
                when {&TYPETACHE-garantieLocataire} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPECONTRAT-bail} then do:
                    for first tache no-lock 
                        where tache.noita = piNumeroContrat:
                        piNumeroIdentifiant = tache.nocon.
                    end.
                end.
                when {&TYPEBIEN-immeuble} then do:
                    for first tache no-lock
                        where tache.noita = piNumeroContrat
                      , first intnt no-lock
                        where intnt.tpcon = tache.tpcon
                          and intnt.nocon = tache.nocon
                          and intnt.tpidt = {&TYPEBIEN-immeuble}:
                            piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
            end.
        end.
        when "01088" then do:
            if pcTypeIdentifiant = {&TYPEBIEN-immeuble} 
            then for first event no-lock where event.noeve = piNumeroContrat:
                piNumeroIdentifiant = event.noimm.
            end.
            else if pcTypeIdentifiant = "01088" then piNumeroIdentifiant = piNumeroContrat.
            else if pcTypeIdentifiant > "01000" and pcTypeIdentifiant < "02000" 
            then for first event no-lock where event.noeve = piNumeroContrat:
                piNumeroIdentifiant = event.norol.
            end.
        end. 
        /* Ajout SY le 24/04/2009 */
        when {&TYPETACHE-noteHonoraire} then do:
            case pcTypeIdentifiant:
                when {&TYPETACHE-noteHonoraire} then
                    piNumeroIdentifiant = piNumeroContrat.
                when {&TYPECONTRAT-mandat2Gerance} then do: 
                    for first tache no-lock where tache.noita = piNumeroContrat
                      , first ctctt no-lock
                        where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                          and ctctt.tpct2 = tache.tpcon
                          and ctctt.noct2 = tache.nocon:
                        piNumeroIdentifiant = ctctt.noct1.
                    end.
                end.
                when {&TYPECONTRAT-prebail} 
                then for first tache no-lock where tache.noita = piNumeroContrat:
                    piNumeroIdentifiant = tache.nocon.
                end.
                when {&TYPECONTRAT-MandatLocation} 
                then for first tache no-lock where tache.noita = piNumeroContrat:
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
            end.
        end.
        /* Ajout SY le 06/05/2009 */
        when "06000" then do:
            case pcTypeIdentifiant:
                when "06000" then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPECONTRAT-mandat2Gerance} then do:
                    find location no-lock where location.nofiche = piNumeroContrat no-error.
                    if available location then piNumeroIdentifiant = location.nocon.
                end.
                when {&TYPECONTRAT-MandatLocation} then do:
                    find location no-lock where location.nofiche = piNumeroContrat no-error.
                    if available location then piNumeroIdentifiant = location.nomdtass.
                end.
                when {&TYPEBIEN-immeuble} 
                then for first location no-lock
                    where location.nofiche = piNumeroContrat
                  , first intnt no-lock
                    where intnt.tpcon = location.tpcon
                      and intnt.nocon = location.nocon
                      and intnt.tpidt = {&TYPEBIEN-immeuble}:
                        piNumeroIdentifiant = intnt.noidt.
                end.
            end.
        end.
        /* Ajout SY le 07/05/2009 */
        when {&TYPECONTRAT-MandatLocation} then do:
            case pcTypeIdentifiant:
                when {&TYPECONTRAT-MandatLocation} then piNumeroIdentifiant = piNumeroContrat.
                when {&TYPECONTRAT-mandat2Gerance} then do: 
                    for first intnt no-lock
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = "06000"
                      , first location no-lock
                        where location.nofiche = intnt.noidt:
                        piNumeroIdentifiant = location.nocon.
                    end.
                end.
                when {&TYPECONTRAT-bail} then do:
                    for first intnt no-lock
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = "06000"
                      , first location no-lock
                        where location.nofiche = intnt.noidt:
                        piNumeroIdentifiant = location.noderloc.
                    end.
                end.
                when "06000" then do:
                    for first intnt no-lock
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = "06000"
                      , first location no-lock
                        where location.nofiche = intnt.noidt:
                        piNumeroIdentifiant = location.nofiche.
                    end.
                end.
                when {&TYPEBIEN-immeuble} then do:
                    for first intnt no-lock 
                        where intnt.tpcon = pcTypeContrat
                          and intnt.nocon = piNumeroContrat
                          and intnt.tpidt = {&TYPEBIEN-immeuble}:
                        piNumeroIdentifiant = intnt.noidt.
                    end.
                end.
            end.
        end.
    end case.

end procedure.

procedure prcCritere-Lot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.
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

procedure prcAnnexe:
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
        pcRetour = if pcRetour = ""
                 then substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt)
                 else substitute("&1&2&3&4&5", 
                                 pcRetour,
                                 SEPAR[2],
                                 intnt.tpidt,
                                 SEPAR[1],
                                 intnt.noidt).
    end.
end.

procedure prcHuissier:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du huissier du cabinet
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer intnt   for intnt.
    define buffer vbroles for roles.

    if pcTypeContrat = {&TYPECONTRAT-DossierMutation} then do :
        /* Recherche de l'huissier : Onglet Opposition */
        find first intnt no-lock
             where intnt.tpcon = pcTypeContrat
               and intnt.nocon = piNumeroContrat
               and intnt.tpidt = {&TYPEROLE-Huissier} no-error.
        if available intnt 
        then pcRetour = substitute("&1&2&3", {&TYPEROLE-Huissier}, SEPAR[1], intnt.noidt).
    end.
    if pcRetour = "" then do:
        find first vbroles no-lock
             where vbroles.tprol = {&TYPEROLE-Huissier} no-error.
        if available vbroles then pcRetour = substitute("&1&2&3", {&TYPEROLE-Huissier}, SEPAR[1], vbroles.norol).
    end.
end.

procedure prcCanLoc:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des candidats locataires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter vcRetour        as character no-undo.

    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer tache for tache.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} then do:
            for each ctctt no-lock
               where ctctt.tpct1 = pcTypeContrat
                 and ctctt.noct1 = piNumeroContrat
                 and ctctt.tpct2 = {&TYPECONTRAT-prebail}
             , first ctrat no-lock
               where ctrat.tpcon = ctctt.tpct2
                 and ctrat.nocon = ctctt.noct2:
                vcRetour = substitute("&1&2&3&4",
                                      if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                      ctrat.tprol,
                                      SEPAR[1],
                                      ctrat.norol).
                for each intnt no-lock
                   where intnt.tpidt = {&TYPEROLE-colocataire}
                     and intnt.tpcon = ctrat.tpcon
                     and intnt.nocon = ctrat.nocon:
                    vcRetour = substitute("&1&2&3&4",
                                          if vcRetour = "" then "" else vcRetour + SEPAR[2],
                                          intnt.tpidt,
                                          SEPAR[1],
                                          intnt.noidt).
                end.
            end.
        end.
        when {&TYPECONTRAT-prebail} then do:
            vcRetour = pcTypeRole + SEPAR[1] + string(piNumeroRole).
            for each intnt no-lock
               where intnt.tpidt = {&TYPEROLE-colocataire}
                 and intnt.tpcon = pcTypeContrat
                 and intnt.nocon = piNumeroContrat:
                vcRetour = if vcRetour = ""
                           then substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt)
                           else substitute("&1&2&3&4&5", vcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPETACHE-noteHonoraire} then do:
            for last tache no-lock
               where tache.noita = piNumeroContrat
             , first ctrat no-lock
               where ctrat.tpcon = tache.tpcon
                 and ctrat.nocon = tache.nocon:
                vcRetour = substitute("&1&2&3", ctrat.tprol, SEPAR[1], ctrat.norol).
            end.
        end.
    end.
end.

procedure prcSignale:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des signalés par
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer inter for inter.

    case pcTypeContrat:
        when {&TYPEINTERVENTION-signalement}
        then for first inter no-lock
            where inter.nosig = piNumeroContrat:
            pcRetour = substitute("&1&2&3", inter.tppar, SEPAR[1], inter.nopar).
        end.
    end.
end.

procedure prcGarant:
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
        when {&TYPETACHE-garantieLocataire} then do:
            for first tache no-lock 
               where tache.noita = piNumeroContrat:
                pcRetour = substitute("&1&2&3", {&TYPEROLE-garant}, SEPAR[1], tache.notac).
            end.
        end.
        otherwise for each intnt no-lock
            where intnt.tpidt = {&TYPEROLE-garant}
              and intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat:
            pcRetour = if pcRetour = ""
                       then substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt)
                       else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
    end.
end.

procedure prcLocataire:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des locataires d'un contrat
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
    define buffer acreg for acreg.
    define buffer tache for tache.
    define buffer event for event.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} then do:
            for each ctctt no-lock
                where ctctt.tpct1 = pcTypeContrat
                  and ctctt.noct1 = piNumeroContrat
                  and ctctt.tpct2 = {&TYPECONTRAT-bail}
              , first ctrat no-lock
                where ctrat.tpcon = ctctt.tpct2
                  and ctrat.nocon = ctctt.noct2:
                pcRetour = substitute("&1&2&3&4",
                                      if pcRetour = "" then "" else pcRetour + SEPAR[2],
                                      ctrat.tprol,
                                      SEPAR[1],
                                      ctrat.norol).
                for each intnt no-lock
                   where intnt.tpidt = {&TYPEROLE-colocataire}
                     and intnt.tpcon = ctrat.tpcon
                     and intnt.nocon = ctrat.nocon:
                    pcRetour = substitute("&1&2&3&4", 
                                          if pcRetour = "" then "" else pcRetour + SEPAR[2],
                                          intnt.tpidt,
                                          SEPAR[1],
                                          intnt.noidt).
                end.
            end.
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            pcRetour = pcTypeRole + SEPAR[1] + string(piNumeroRole).
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-colocataire}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                pcRetour = if pcRetour = ""
                           then substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt)
                           else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPETACHE-garantieLocataire} then for first tache no-lock 
            where tache.noita = piNumeroContrat :
            pcRetour = {&TYPEROLE-locataire} + SEPAR[1] + string(tache.nocon).
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-colocataire}
                  and intnt.tpcon = {&TYPECONTRAT-bail}
                  and intnt.nocon = tache.nocon:
                pcRetour = if pcRetour = ""
                           then substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt)
                           else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], intnt.tpidt, SEPAR[1], intnt.noidt).
            end.
        end.
        when {&TYPEACCORDREGLEMENT-locataire} then for first acreg no-lock
            where acreg.tpcon = {&TYPEACCORDREGLEMENT-locataire}
              and acreg.nocon = piNumeroContrat
              and acreg.tplig = "0":
            pcRetour = substitute("&1&2&3", acreg.tprol, SEPAR[1], acreg.norol).
        end.
        when "01088" 
        then for first event no-lock
            where event.noeve = piNumeroContrat:
            pcRetour = substitute("&1&2&3", event.tprol, SEPAR[1], event.norol).
        end.
    end.
end.

procedure prcMandant:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des mandants d'un contrat 
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRole      as character no-undo.
    define input  parameter piNumeroRole    as integer   no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer ctrlb for ctrlb.
    define buffer ctctt for ctctt.
    define buffer location for location.
    
    case pcTypeContrat:
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            /* Indivisaire */
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and intnt.nocon = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5)):
                pcRetour = substitute("&1&2&3&4&5",
                                      pcRetour,
                                      if pcRetour = "" then "" else SEPAR[2],
                                      intnt.tpidt,
                                      SEPAR[1],
                                      intnt.noidt).
            end.
            /* Mandant */
            for first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and ctrat.nocon = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5)):
                pcRetour = substitute("&1&2&3&4&5",
                                      pcRetour,
                                      if pcRetour = "" then "" else SEPAR[2],
                                      ctrat.tprol,
                                      SEPAR[1],
                                      ctrat.norol).
            end.
            /* Bénéficiaire */
            for each ctrlb no-lock
                where ctrlb.tpctt = {&TYPECONTRAT-mandat2Gerance}
                  and ctrlb.noctt = integer(substring(string(piNumeroContrat, "9999999999"), 1, 5))
                  and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                  and ctrlb.nbnum <> 0:
                pcRetour = substitute("&1&2&3&4&5", 
                                      pcRetour,
                                      if pcRetour = "" then "" else SEPAR[2],
                                      ctrlb.tpid2,
                                      SEPAR[1],
                                      ctrlb.noid2).
            end.
        end.
        when {&TYPECONTRAT-mandat2Gerance} then do:
            /* Indivisaire */
            for each intnt no-lock
                where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat:
                pcRetour = substitute("&1&2&3&4&5",
                                      pcRetour,
                                      if pcRetour = "" then "" else SEPAR[2],
                                      intnt.tpidt,
                                      SEPAR[1],
                                      intnt.noidt).
            end.
            /* Mandant */
            pcRetour = substitute("&1&2&3&4&5",
                                  pcRetour,
                                  if pcRetour = "" then "" else SEPAR[2],
                                  pcTypeRole,
                                  SEPAR[1],
                                  piNumeroRole).
            /* Bénéficiaire */
            for each ctrlb no-lock
                where ctrlb.tpctt = pcTypeContrat
                  and ctrlb.noctt = piNumeroContrat
                  and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                  and ctrlb.nbnum <> 0:
                pcRetour = substitute("&1&2&3&4&5", 
                                      pcRetour,
                                      if pcRetour = "" then "" else SEPAR[2],
                                      ctrlb.tpid2,
                                      SEPAR[1],
                                      ctrlb.noid2).
            end.
        end.
        when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                /* Indivisaire */
                for each intnt no-lock
                    where intnt.tpidt = {&TYPEROLE-coIndivisaire}
                      and intnt.tpcon = ctctt.tpct1
                      and intnt.nocon = ctctt.noct1:
                    pcRetour = substitute("&1&2&3&4&5",
                                          pcRetour,
                                          if pcRetour = "" then "" else SEPAR[2],
                                          intnt.tpidt,
                                          SEPAR[1],
                                          intnt.noidt).
                end.
                /* Mandant */
                for first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct1
                      and ctrat.nocon = ctctt.noct1:
                    pcRetour = substitute("&1&2&3&4&5",
                                          pcRetour,
                                          if pcRetour = "" then "" else SEPAR[2],
                                          ctrat.tprol,
                                          SEPAR[1],
                                          ctrat.norol).
                end.
                /* Bénéficiaire */
                for each ctrlb no-lock
                   where ctrlb.tpctt = pcTypeContrat
                     and ctrlb.noctt = piNumeroContrat
                     and ctrlb.tpid2 = {&TYPEROLE-beneficiaire}
                     and ctrlb.nbnum <> 0:
                    pcRetour = substitute("&1&2&3&4&5",
                                          pcRetour,
                                          if pcRetour = "" then "" else SEPAR[2],
                                          ctrlb.tpid2,
                                          SEPAR[1],
                                          ctrlb.noid2).
                end.
            end.
        end.
        when {&TYPETACHE-noteHonoraire} then do:
            for last tache no-lock
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
        end.
        when "06000" then do:
            find location where location.nofiche = piNumeroContrat no-lock no-error.
            if available location 
            then pcRetour = substitute("&1&2&3", "00022", SEPAR[1], location.noman).
        end.
        when {&TYPECONTRAT-MandatLocation} then do:
            find first intnt no-lock
                 where intnt.tpcon = pcTypeContrat 
                   and intnt.nocon = piNumeroContrat 
                   and intnt.tpidt = "00022" no-error.
            if available intnt then pcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
    end.
end.

procedure prcSalarie:
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
    define variable vcTemp             as character no-undo.

    define buffer intnt      for intnt.
    define buffer salar      for salar.
    define buffer sal_intnt  for intnt.

    voPayePegase = new parametre.pclie.parametragePayePegase().
    if voPayePegase:isActif() then viNiveauPaiePegase = voPayePegase:int01.
    delete object voPayePegase.

    vcTemp = outilTraduction:getLibelle(700501).
    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-bail} then do:
            /* Modif SY le 13/05/2009 : Gérance : salarié de l'immeuble et non du mandat */
            for each intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
               , each sal_intnt no-lock
                where sal_intnt.tpidt = intnt.tpidt
                  and sal_intnt.noidt = intnt.noidt
                  and sal_intnt.tpcon = (if viNiveauPaiePegase >= 2 then {&TYPECONTRAT-SalariePegase} else {&TYPECONTRAT-Salarie})
              , first salar no-lock
                where salar.tprol = (if viNiveauPaiePegase >= 2 then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
                  and salar.norol = sal_intnt.nocon
                  and salar.dtsor = ?:    /* ajout SY le 16/12/2009 : salarié actif */
                if viNiveauPaiePegase >= 2 then do:
                    case pcCodeCategorie:
                        when "001" then if not salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie gardien */
                        when "002" then if salar.lbdiv5 matches "*CODPROFIL=GIEMP*" or salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie Autre */
                        when "003" then if not salar.lbdiv5 matches "*CODPROFIL=GIEMP*" then next. /* Categorie Employe */
                    end.
                end.
                else do:
                    case pcCodeCategorie:
                        when "001" then if salar.cdcat <> "00002" and salar.cdcat <> "00003" then next. /* Categorie gardien */
                        when "002" then if salar.cdcat <> "00004" and salar.cdcat <> "00005" then next. /* Categorie Autre   */
                        when "003" then if salar.cdcat <> "00001"                            then next. /* Categorie Employe */
                    end.
                end.
                pcRetour = if pcRetour = ""
                           then substitute("&1&2&3", salar.tprol, SEPAR[1], salar.norol)
                           else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
            end.
        end.
        when {&TYPECONTRAT-mandat2Syndic} then do:
            if viNiveauPaiePegase >= 2 then do:
                for each salar no-lock
                   where salar.tprol = {&TYPEROLE-salariePegase}
                     and salar.norol >  int64(string(piNumeroContrat, "99999") + "00001")
                     and salar.norol <= int64(string(piNumeroContrat, "99999") + "99999")
                     and salar.dtsor = ?:     /* Ajout SY le 16/12/2009 */
                    case pcCodeCategorie:
                        when "001" then if not salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie gardien */
                        when "002" then if salar.lbdiv5 matches "*CODPROFIL=GIEMP*" or salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie Autre */
                        when "003" then if not salar.lbdiv5 matches "*CODPROFIL=GIEMP*" then next. /* Categorie Employe */
                    end.
                    pcRetour = if pcRetour = ""
                               then substitute("&1&2&3", salar.tprol, SEPAR[1], salar.norol)
                               else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
                end.
            end.
            else do:
                for each salar no-lock
                    where salar.tprol = "00050"
                      and salar.norol > integer(string(piNumeroContrat, "9999") + "00")
                      and salar.norol <= integer(string(piNumeroContrat, "9999") + "99")
                      and salar.dtsor = ?:     /* Ajout SY le 16/12/2009 */
                    case pcCodeCategorie:
                        when "001" then if salar.cdcat <> "00002" and salar.cdcat <> "00003" then next. /* Categorie gardien */
                        when "002" then if salar.cdcat <> "00004" and salar.cdcat <> "00005" then next. /* Categorie Autre   */
                        when "003" then if salar.cdcat <> "00001"                            then next. /* Categorie Employe */
                    end.
                    pcRetour = if pcRetour = ""
                               then substitute("&1&2&3", salar.tprol, SEPAR[1], salar.norol)
                               else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
                end.
            end.
        end.
        when {&TYPECONTRAT-Salarie} or when {&TYPECONTRAT-SalariePegase} then do:
            find first salar no-lock
                 where salar.tprol = (if pcTypeContrat = {&TYPECONTRAT-SalariePegase} then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
                   and salar.norol = piNumeroContrat no-error.
            if available salar then do:
                if viNiveauPaiePegase >= 2 then do:
                    case pcCodeCategorie:
                        when "001" then if not salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie gardien */
                        when "002" then if salar.lbdiv5 matches "*CODPROFIL=GIEMP*" or salar.lbdiv5 matches "*CODPROFIL=GIGAR*" then next. /* Categorie Autre */
                        when "003" then if not salar.lbdiv5 matches "*CODPROFIL=GIEMP*" then next. /* Categorie Employe */
                    end.
                end.
                else do:
                    case pcCodeCategorie:
                        when "001" then if salar.cdcat <> "00002" and salar.cdcat <> "00003" then next. /* Categorie gardien */
                        when "002" then if salar.cdcat <> "00004" and salar.cdcat <> "00005" then next. /* Categorie Autre   */
                        when "003" then if salar.cdcat <> "00001"                            then next. /* Categorie Employe */
                    end.
                end.
                pcRetour = if pcRetour = ""
                           then substitute("&1&2&3", salar.tprol, SEPAR[1], salar.norol)
                           else substitute("&1&2&3&4&5", pcRetour, SEPAR[2], salar.tprol, SEPAR[1], salar.norol).
            end.
        end.
    end.

end procedure.

procedure salarie-Immeuble:
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
    define buffer sal_intnt  for intnt.

    voPayePegase = new parametre.pclie.parametragePayePegase().
    if voPayePegase:isActif() then viNiveauPaiePegase = voPayePegase:int01.
    delete object voPayePegase.

    for each intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}
       , each sal_intnt no-lock
        where sal_intnt.tpidt = intnt.tpidt
          and sal_intnt.noidt = intnt.noidt
          and sal_intnt.tpcon = (if viNiveauPaiePegase >= 2 then {&TYPECONTRAT-SalariePegase} else {&TYPECONTRAT-Salarie})
       , first salar no-lock
         where salar.tprol = (if viNiveauPaiePegase >= 2 then {&TYPEROLE-salariePegase} else {&TYPEROLE-salarie})
           and salar.norol = sal_intnt.nocon
           and salar.cdsta = "00001" /* salarié titulaire */
           and salar.dtsor = ?:      /* salarié actif */

        piNumeroSalImm = salar.norol.
        /* Si Gardien : on sort */
        if viNiveauPaiePegase >= 2
        then if salar.lbdiv5 matches "*" + "CODPROFIL=GIGAR" + separ[2] + "*" then leave.
        else if (salar.cdcat = "00002" or salar.cdcat = "00003") then leave. 
    end.

end procedure.

procedure prcCopro:
    /*------------------------------------------------------------------------------
    Purpose: Recherche des coproprietaires d'un contrat
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define input  parameter pcTypeRole      as character no-undo.
    define output parameter pcRetour        as character no-undo.

    define variable CpUseInc as integer no-undo.

    define buffer intnt  for intnt.
    define buffer bintnt for intnt.
    define buffer ctctt  for ctctt.
    define buffer ctrat  for ctrat.

    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Syndic} then do:
            for each ctctt no-lock
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
                find first bintnt no-lock
                    where bintnt.tpcon = ctrat.tpcon
                      and bintnt.nocon = ctrat.nocon
                      and bintnt.tpidt = {&TYPEROLE-mandataire} no-error.
                if available bintnt and pcTypeRole = "Desti"
                then pcRetour = if pcRetour = ""
                                then substitute("&1&2&3", bintnt.tpidt, SEPAR[1], bintnt.noidt)
                                else substitute("&1&2&3&4&5",
                                                pcRetour,
                                                SEPAR[2],
                                                bintnt.tpidt,
                                                SEPAR[1],
                                                bintnt.noidt).
                else pcRetour = if pcRetour = ""
                                then substitute("&1&2&3", ctrat.tprol, SEPAR[1], ctrat.norol)
                                else substitute("&1&2&3&4&5",
                                                pcRetour,
                                                SEPAR[2],
                                                ctrat.tprol,
                                                SEPAR[1],
                                                ctrat.norol).
            end.
        end.
        when {&TYPECONTRAT-titre2copro} then do:
            find first ctrat no-lock 
                 where ctrat.tpcon = pcTypeContrat
                   and ctrat.nocon = piNumeroContrat no-error.
            if available ctrat then do:
                find first bintnt no-lock
                     where bintnt.tpcon = ctrat.tpcon
                       and bintnt.nocon = ctrat.nocon
                       and bintnt.tpidt = {&TYPEROLE-mandataire} no-error.
                if available bintnt and pcTypeRole = "Desti" 
                then pcRetour = substitute("&1&2&3", bintnt.tpidt, SEPAR[1], bintnt.noidt).
                else pcRetour = substitute("&1&2&3", ctrat.tprol, SEPAR[1], ctrat.norol).
            end.
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            find first ctctt no-lock
                 where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                   and ctctt.tpct2 = pcTypeContrat
                   and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                CpUseInc = ctctt.noct1.
                for each ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.noct1 = CpUseInc
                      and ctctt.tpct2 = {&TYPECONTRAT-titre2copro}
                  , first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct2
                      and ctrat.nocon = ctctt.noct2
                  , first intnt no-lock
                    where intnt.tpcon = ctrat.tpcon
                      and intnt.nocon = ctrat.nocon
                      and intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.nbden = 0:
                    find first bintnt no-lock
                         where bintnt.tpcon = ctrat.tpcon
                           and bintnt.nocon = ctrat.nocon
                           and bintnt.tpidt = {&TYPEROLE-mandataire} no-error.
                    if available bintnt and pcTypeRole = "Desti" 
                    then pcRetour = if pcRetour = ""
                                    then substitute("&1&2&3", bintnt.tpidt, SEPAR[1], bintnt.noidt)
                                    else substitute("&1&2&3&4&5",
                                                    pcRetour,
                                                    SEPAR[2],
                                                    bintnt.tpidt,
                                                    SEPAR[1],
                                                    bintnt.noidt).
                    else pcRetour = if pcRetour = ""
                                    then substitute("&1&2&3", ctrat.tprol, SEPAR[1], ctrat.norol)
                                    else substitute("&1&2&3&4&5", 
                                                    pcRetour,
                                                    SEPAR[2],
                                                    ctrat.tprol,
                                                    SEPAR[1],
                                                    ctrat.norol).
                end.
            end.
        end.
    end.

end procedure.

procedure prcFournisseur:
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

    case pcTypeContrat:
        /* Contrat Fournisseur */
        when {&TYPECONTRAT-fournisseur}
        then for first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = "FOU":
            pcRetour = substitute("&1&2&3", intnt.tpidt, SEPAR[1], intnt.noidt).
        end.
        /* Devis */
        when {&TYPEINTERVENTION-demande2devis}
        then for first devis no-lock
                 where devis.nodev = piNumeroContrat:
            pcRetour = substitute("&1&2&3", "FOU", SEPAR[1], devis.nofou).
        end.
        /* Ordre de Service */
        when {&TYPEINTERVENTION-ordre2service}
        then for first ordse no-lock
                 where ordse.noord = piNumeroContrat:
            pcRetour = substitute("&1&2&3", "FOU", SEPAR[1], ordse.nofou).
        end.
        /* mandat location : délégation */
        when {&TYPECONTRAT-MandatLocation} 
        then for last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = "04347":
            pcRetour = substitute("&1&2&3", tache.tprol, SEPAR[1], tache.norol).
        end.
        otherwise do:
            if pcCodeCategorie = "" then pcCodeCategorie = "000".
            for each ccptcol no-lock
               where ccptcol.soc-cd = mtoken:iCodeSociete
                 and ccptcol.tprole = 12
              , each csscpt no-lock 
               where csscpt.soc-cd = ccptcol.soc-cd
                 and csscpt.coll-cle = ccptcol.coll-cle      /* Modif SY le 19/08/2005 "F" */
                 and csscpt.etab-cd = piNumeroContrat
             , first ifour no-lock 
               where ifour.soc-cd = csscpt.soc-cd
                 and ifour.coll-cle = csscpt.coll-cle
                 and ifour.cpt-cd = csscpt.cpt-cd
              break by csscpt.cpt-cd:
                if first-of(csscpt.cpt-cd) and csscpt.cpt-cd <> "00000" and csscpt.cpt-cd <> "99999" then do:
                    if pcCodeCategorie <> "000" then do:
                        if integer(pcCodeCategorie) = 999 and ifour.categ-cd <> 0 and ifour.categ-cd <> 999 then next.
                        else if integer(pcCodeCategorie) <> 999 and integer(pcCodeCategorie) <> ifour.categ-cd then next.
                    end.
                    pcRetour = substitute("&1&2&3&4",
                                          if pcRetour = "" then "" else pcRetour + SEPAR[2],
                                          "FOU",
                                          SEPAR[1],
                                          csscpt.cpt-cd). 
                end.
            end.
        end.
    end.

end procedure.

procedure prcPaiement:
    /*------------------------------------------------------------------------------
    Purpose: Recherche du Centre de Paiement
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcRetour        as character no-undo.

    define variable voCorrespondance as class parametre.pclie.parametrageCorrespondance no-undo.
    define variable viNumeroImmeuble as integer   no-undo.
    define variable vcTypeOrganisme  as character no-undo.
    define variable viPos            as integer   no-undo.
    define variable vcParametre      as character no-undo.
    define variable vcListeOrgSoc    as character no-undo.
    define variable vcOrgSocPegase   as character no-undo.

    define buffer etabl for etabl.
    define buffer ctrat for ctrat.
    define buffer vbroles for roles.
    define buffer ctanx for ctanx.
    define buffer salar for salar.
    define buffer intnt for intnt.
    define buffer tache for tache.

    case pcTypeContrat:
        when {&TYPECONTRAT-Salarie} then do:
            vcTypeOrganisme = "ORP".
            if GestionSie() then vcTypeOrganisme = "SIE".

            find first etabl no-lock
                where etabl.nocon = integer(substring(string(piNumeroContrat, "999999"), 1, 4)) no-error.
            if available etabl then do:
                find first ctrat no-lock
                    where ctrat.tpcon = etabl.tpcon
                      and ctrat.nocon = etabl.nocon no-error.
                if available ctrat then do:
                    find first vbroles no-lock
                        where vbroles.tprol = ctrat.tprol
                          and vbroles.norol = ctrat.norol no-error.
                    if available vbroles then do:
                        find first ctanx no-lock
                             where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                               and ctanx.tprol = "99999"
                               and ctanx.norol = vbroles.notie no-error.
                        if available ctanx and ctanx.tpren = "YES" 
                        then pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], ctanx.cdobj).
                    end.
                end.
            end.
        end.
        when {&TYPECONTRAT-SalariePegase} then do: /* SY 0114/0244 25/06/2015 */
            for first salar no-lock
                 where salar.tprol = {&TYPEROLE-salariePegase}
                   and salar.norol = piNumeroContrat:
                find first ctctt no-lock
                    where (ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic} or ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance})
                      and ctctt.tpct2 = pcTypeContrat
                      and ctctt.noct2 = piNumeroContrat no-error.
                if available ctctt 
                then do viPos = 1 to num-entries(salar.lbdiv5, separ[2]):
                    vcParametre = entry(viPos, salar.lbdiv5, separ[2]).
                    if vcParametre begins "ORGSOC" + "=" then do: 
                        vcListeOrgSoc = entry(2, vcParametre, "=").
                        leave.
                    end.
                end.
boucleOrgSoc:
                do viPos = 1 to num-entries(vcListeOrgSoc):
                    vcOrgSocPegase = entry(viPos , vcListeOrgSoc).
                    if vcOrgSocPegase begins "I" then do:
                        /* Recherche des informations dans la table de correspondance */
                        voCorrespondance = new parametre.pclie.parametrageCorrespondance((if ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro), vcOrgSocPegase).
                        if voCorrespondance:isDbParameter then do:
                            assign
                                vcTypeOrganisme = voCorrespondance:getCollGi()
                                pcRetour        = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], voCorrespondance:getCompteFournisseur()) /* fournisseur en correspondance */
                            .
                            leave boucleOrgSoc.
                        end.
                    end. 
                end. /* ctctt */
            end. /* salar */
        end.
        when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance} then do:
            vcTypeOrganisme = "ORP".
            if GestionSie() then vcTypeOrganisme = "SIE".
            find first ctrat no-lock
                where ctrat.tpcon = pcTypeContrat
                  and ctrat.nocon = piNumeroContrat no-error.
            if available ctrat then do:
                find first vbroles no-lock
                     where vbroles.tprol = ctrat.tprol
                       and vbroles.norol = ctrat.norol no-error.
                if available vbroles then do:
                    find first ctanx no-lock
                        where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                          and ctanx.tprol = "99999"
                          and ctanx.norol = vbroles.notie no-error.
                    if available ctanx and ctanx.tpren = "YES" 
                    then pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], ctanx.cdobj).
                end.
            end.
        end.
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-prebail} then do:
            /* Recherche du centre de paiement rattaché à l'immeuble du locataire */
            vcTypeOrganisme = "OTS".
            if GestionSie() then vcTypeOrganisme = "SIE".
            find first intnt no-lock
                where intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroContrat
                  and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
            if available intnt then do:
                viNumeroImmeuble = intnt.noidt.
                find first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = viNumeroImmeuble no-error.
                if available intnt then do:
                    find first tache no-lock
                         where tache.tpcon = intnt.tpcon
                           and tache.nocon = intnt.nocon
                           and tache.tptac = {&TYPETACHE-organismesSociaux}
                           and tache.tpfin = vcTypeOrganisme no-error.
                    if available tache then pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], trim(tache.ntges)).
                end.
            end.
        end.
        when {&TYPECONTRAT-DossierMutation} or when {&TYPECONTRAT-fournisseur} then do:
            vcTypeOrganisme = "ORP".
            if GestionSie() then vcTypeOrganisme = "SIE".
            find first ctctt no-lock
                where (ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic} or ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance})
                  and ctctt.tpct2 = pcTypeContrat
                  and ctctt.noct2 = piNumeroContrat no-error.
            if available ctctt then do:
                find first ctrat no-lock
                     where ctrat.tpcon = ctctt.tpct1
                       and ctrat.nocon = ctctt.noct1 no-error.
                if available ctrat then do:
                    find first vbroles no-lock
                         where vbroles.tprol = ctrat.tprol
                           and vbroles.norol = ctrat.norol no-error.
                    if available vbroles then do:
                        find ctanx no-lock  
                            where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                              and ctanx.tprol = "99999"
                              and ctanx.norol = vbroles.notie no-error.
                        if available ctanx and ctanx.tpren = "YES" 
                        then pcRetour = substitute("&1&2&3", vcTypeOrganisme, SEPAR[1], ctanx.cdobj).
                    end.
                end.
            end.
        end.
    end.
    delete object voCorrespondance.
end procedure.
