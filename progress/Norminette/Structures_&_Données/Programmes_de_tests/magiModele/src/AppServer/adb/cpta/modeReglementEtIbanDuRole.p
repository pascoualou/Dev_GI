/*------------------------------------------------------------------------
File        : modeReglementEtIbanDuRole.p
Purpose     : Renvoie le Mode de Règlement et l'IBAN d'1 Rôle en gérance
Author(s)   : ofa  -  2018/05/29 
Notes       : vient de adb/src/cpta/chgmdreg.p 
              Attention, 2 modifications par rapport à l'original:
                - remplacement du paramètre d'entrée pcCodeFonction par piNumeroProprietaireduBeneficiaire
                - On ne retourne plus le RIB (remplacé par l'IBAN)
             Codes retour :
              "000" = OK
              "001" = Rôle passé en paramètre inexistant
              "002" = Mandat inexistant
              "003" = Rib par défaut du rôle inexistant
              "004" = Enregistrement ctanx inexistant pour aller chercher les infos RIB
              "005" = rlctt inexistant( mandat avec indivision )
              "006" = Bénéficiaire non concerné par ce mandat
derniere revue: 2018/08/03 - phm: OK

13  19/06/2012  PL    0212/0155 Sous-location BNP
14  01/10/2013  OF    0713/0191 Gestion du mode règlt des acomptes
15  08/07/2015  SY    1013/0126 Prélèvement mensuel des locataires quittancés au Trimestre
*--------------------------------------------------------------------------*/

{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2Contrat.i}
{preprocesseur/referenceClient.i}
{preprocesseur/mode2Reglement.i}

define input  parameter piNumeroSociete                    as integer   no-undo.
define input  parameter piNumeroMandat                     as integer   no-undo.
define input  parameter pcTypeRole                         as character no-undo.
define input  parameter piNumeroRole                       as integer   no-undo.
define input  parameter pcTypeAppel                        as character no-undo.
define input  parameter piNumeroProprietaireduBeneficiaire as integer   no-undo.
define output parameter pcCodeRetour                       as character no-undo initial "000".
define output parameter pcInformationsRetour               as character no-undo.

define variable glTrouveRole            as logical   no-undo.
define variable gcModeReglement         as character no-undo initial "C".
define variable gcCoordonneesBancaires  as character no-undo.
define variable glAvecRepartitionTerme  as logical   no-undo.
define variable gcCodeReglementGestion  as character no-undo.
define variable gcListeModeReglement    as character no-undo.

define buffer intnt for intnt.
define buffer roles for roles.
define buffer tache for tache.
define buffer ctrat for ctrat.
define buffer ctanx for ctanx.
define buffer rlctt for rlctt.
define buffer ctrlb for ctrlb.

function getIban returns character private(piCompteBancaire as int64):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ctanx for ctanx.

    for first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-RIB}
          and ctanx.nocon = piCompteBancaire:
        return substitute("&1@&2@&3@&4@&5@&6@&7@&8@&9",
                          trim(ctanx.lbdom),
                          ctanx.lbtit,
                          ctanx.iban,
                          ctanx.bicod,
                          if ctanx.fgetr = ? then "N" else string(ctanx.fgetr,"O/N")). 
    end.
    return "".
end function.



if pcTypeAppel = "ACPTE"
then for each sys_pg no-lock
    where sys_pg.tppar = "O_MDG" 
      and sys_pg.cdpar <> "00000":
    gcListeModeReglement = substitute("&1,&2", gcListeModeReglement, sys_pg.cdpar).
end.
gcListeModeReglement = trim(gcListeModeReglement, ",").

if pcTypeRole = {&TYPEROLE-coindivisaire} then do:
    find first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-Mandat2Gerance}
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = pcTypeRole
          and intnt.noidt = piNumeroRole no-error.
    if available intnt then do:
        find first roles no-lock
            where roles.tprol = intnt.tpidt
              and roles.norol = intnt.noidt no-error.
        if available roles
        then glTrouveRole = true.
        else assign 
            pcCodeRetour = "001"
            glTrouveRole  = false
        .
    end.
    else do:
        find first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-Mandat2Gerance}
              and intnt.nocon = piNumeroMandat 
              and intnt.tpidt = {&TYPEROLE-mandant}
              and intnt.noidt = piNumeroRole no-error.
        if available intnt then do :
            find first roles no-lock
                where roles.tprol = intnt.tpidt
                  and roles.norol = intnt.noidt no-error.
            if available roles
            then assign 
                glTrouveRole = true
                pcTypeRole  = {&TYPEROLE-mandant}
            .
            else assign 
                glTrouveRole  = false
                pcCodeRetour = "001"
            .
        end.
        else do:
            assign 
                gcModeReglement        = "C"
                gcCoordonneesBancaires = ""
                pcCodeRetour           = "000"
                pcInformationsRetour   = substitute("&1|&2", gcModeReglement, gcCoordonneesBancaires)
            .
            find first tache no-lock 
                where tache.tptac = {&TYPETACHE-compteRenduGestion}
                  and tache.tpcon = {&TYPECONTRAT-Mandat2Gerance}
                  and tache.nocon = piNumeroMandat no-error.
            assign
                glAvecRepartitionTerme = available tache and tache.pdreg <> "00002"
                pcInformationsRetour  = substitute("&1|&2", pcInformationsRetour, string(glAvecRepartitionTerme,"1/0"))
            .
            return.
        end.
    end.
end.
else do :
    find first roles no-lock 
        where roles.tprol = pcTypeRole
          and roles.norol = piNumeroRole no-error.
    if available roles
    then glTrouveRole = true.
    else assign 
        glTrouveRole  = false
        pcCodeRetour = "001"
    .
end.

if glTrouveRole then do :
    if pcTypeRole = {&TYPEROLE-mandant} or pcTypeRole = {&TYPEROLE-coindivisaire} then do:
        find first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-Mandat2Gerance}
              and ctrat.nocon = piNumeroMandat no-error.
        if not available ctrat
        then pcCodeRetour = "002". 
        else case ctrat.ntcon:
            when {&NATURECONTRAT-mandatAvecIndivision} or when {&NATURECONTRAT-mandatLocationIndivision} then do:
                find first intnt no-lock
                    where intnt.Tpcon = ctrat.tpcon
                      and intnt.nocon = ctrat.nocon
                      and intnt.tpidt = roles.tprol
                      and intnt.noidt = roles.norol no-error.
                if not available intnt
                then assign 
                    gcModeReglement        = "C"
                    gcCoordonneesBancaires = ""
                .
                else do:
                    /*Si le mode de règlement des acomptes mandat n'est pas renseigné dans intnt, on prend celui des CRG
                      sauf si c'est suspendu pour Dauchez: dans ce cas, on force à chèque*/
                    gcCodeReglementGestion = if pcTypeAppel = "ACPTE" and num-entries(intnt.lbdiv,"@") > 1 and lookup(entry(2,intnt.lbdiv,"@"),gcListeModeReglement) <> 0 
                                             then entry(2, intnt.lbdiv, "@") 
                                             else if piNumeroSociete = {&REFCLIENT-DAUCHEZGERANCE} and entry(1,intnt.lbdiv,"@") = {&MODEREGLEMENT-suspendu} then {&MODEREGLEMENT-cheque}
                                             else entry(1, intnt.lbdiv, "@").
                    case gcCodeReglementGestion:
                        when {&MODEREGLEMENT-virement} or when {&MODEREGLEMENT-prelevement} or when {&MODEREGLEMENT-prelevementMensuel} then do :
                            gcModeReglement = if gcCodeReglementGestion = {&MODEREGLEMENT-virement} then "V" else "P".
                            if pcTypeAppel = "DEFAUT" then do:
                                find first ctanx no-lock
                                    where ctanx.tprol = {&TYPEROLE-tiers}
                                      and ctanx.norol = roles.notie
                                      and ctanx.tpcon = {&TYPECONTRAT-RIB}
                                      and ctanx.tpact = "DEFAU" no-error.
                                if not available ctanx
                                then find first ctanx no-lock
                                    where ctanx.tprol = {&TYPEROLE-tiers}
                                      and ctanx.norol = roles.notie
                                      and ctanx.tpcon = {&TYPECONTRAT-RIB} no-error.
                            end.
                            else do:
                                find first rlctt no-lock 
                                    where rlctt.tpidt = roles.tprol
                                      and rlctt.noidt = roles.norol
                                      and rlctt.tpct1 = {&TYPECONTRAT-Mandat2Gerance}
                                      and rlctt.noct1 = piNumeroMandat
                                      and rlctt.tpct2 = {&TYPECONTRAT-RIB} no-error.
                                if not available rlctt then do:
                                    pcCodeRetour = "003".
                                    return.
                                end.
                                find first ctanx no-lock 
                                    where ctanx.tpcon = rlctt.tpct2
                                      and ctanx.nocon = rlctt.noct2 no-error.
                            end.
                            if not available ctanx then do:
                                pcCodeRetour = "004".
                                return.
                            end.
                            gcCoordonneesBancaires = substitute("&1@&2@&3@&4@&5@&6@&7@&8@&9",
                                                                trim(ctanx.lbdom),
                                                                ctanx.lbtit,
                                                                ctanx.iban,
                                                                ctanx.bicod,
                                                                if ctanx.fgetr = ? then "N" else string(ctanx.fgetr, "O/N")).
                        end.
                        when {&MODEREGLEMENT-suspendu} then gcModeReglement = "S". 
                        otherwise gcModeReglement = "C".
                    end case.
                end.
            end.
            when {&NATURECONTRAT-mandatSansIndivision} 
                or when {&NATURECONTRAT-mandatGestionRevenusGarantis} 
                or when {&NATURECONTRAT-mandatSousLocation} 
                or when {&NATURECONTRAT-mandatLocation} 
                or when {&NATURECONTRAT-mandatLocationDelegue} 
                or when {&NATURECONTRAT-mandatSousLocationDelegue} then do : 
                find first tache no-lock 
                    where tache.tptac = {&TYPETACHE-compteRenduGestion}
                      and tache.tpcon = {&TYPECONTRAT-Mandat2Gerance}
                      and tache.nocon = piNumeroMandat no-error.
                if not available tache
                then assign 
                    gcModeReglement         = "C"
                    gcCoordonneesBancaires  = ""
                .
                else case tache.ntreg :
                    when {&MODEREGLEMENT-virement} or when {&MODEREGLEMENT-prelevement} or when {&MODEREGLEMENT-prelevementMensuel} or when {&MODEREGLEMENT-suspendu} then do: 
                        gcModeReglement = if tache.ntreg = {&MODEREGLEMENT-virement} then "V" 
                                          else if tache.ntreg = {&MODEREGLEMENT-suspendu} then "S"
                                          else "P".
                        if pcTypeAppel = "DEFAUT" then do:
                            find first ctanx no-lock
                                where ctanx.tprol = {&TYPEROLE-tiers}
                                  and ctanx.norol = roles.notie
                                  and ctanx.tpcon = {&TYPECONTRAT-RIB}
                                  and ctanx.tpact = "DEFAU" no-error.
                            if not available ctanx
                            then find first ctanx no-lock
                                where ctanx.tprol = {&TYPEROLE-tiers}
                                  and ctanx.norol = roles.notie
                                  and ctanx.tpcon = {&TYPECONTRAT-RIB} no-error.
                        end.
                        else do:
                            find first rlctt no-lock 
                                where rlctt.tpidt = roles.tprol
                                  and rlctt.noidt = roles.norol
                                  and rlctt.tpct1 = {&TYPECONTRAT-Mandat2Gerance}
                                  and rlctt.noct1 = piNumeroMandat
                                  and rlctt.tpct2 = {&TYPECONTRAT-RIB} no-error.
                            if not available rlctt
                            then do:
                                if tache.ntreg <> {&MODEREGLEMENT-suspendu} then assign pcCodeRetour = "003".
                                return.
                            end.
                            find first ctanx no-lock 
                                where ctanx.tpcon = rlctt.tpct2
                                  and ctanx.nocon = rlctt.noct2 no-error.
                        end.
                        if not available ctanx then do :
                            if tache.ntreg <> {&MODEREGLEMENT-suspendu} then assign pcCodeRetour = "004".
                            return.
                        end.
                        gcCoordonneesBancaires = substitute("&1@&2@&3@&4@&5@&6@&7@&8@&9",
                                                            trim(ctanx.lbdom),
                                                            ctanx.lbtit,
                                                            ctanx.iban,
                                                            ctanx.bicod,
                                                            if ctanx.fgetr = ? then "N" else string(ctanx.fgetr, "O/N")).
                    end.
                    otherwise gcModeReglement = "C". // sinon cheque
                end case.
            end.
            otherwise assign pcCodeRetour = "003".
        end case.
    end.
    else do:
        if pcTypeRole = {&TYPEROLE-locataire} then do:
            find first ctrat no-lock 
                where ctrat.tpcon = {&TYPECONTRAT-bail}
                  and ctrat.nocon = piNumeroRole no-error.
            if not available ctrat
            then pcCodeRetour = "002". 
            else do:
                for first tache no-lock
                    where tache.tpcon = ctrat.tpcon
                      and tache.nocon = piNumeroRole
                      and tache.Tptac = {&TYPETACHE-quittancement}:
                    case tache.cdreg:
                        when {&MODEREGLEMENT-virement}           then gcModeReglement = "V".
                        when {&MODEREGLEMENT-prelevement} 
                     or when {&MODEREGLEMENT-prelevementMensuel} then gcModeReglement = "P".
                        when {&MODEREGLEMENT-TIP}                then gcModeReglement = "T".
                        otherwise gcModeReglement = "C".
                    end case.
                end.
                // Recherche du RIB par defaut
                find first rlctt no-lock
                    where rlctt.tpidt = pcTypeRole
                      and rlctt.noidt = piNumeroRole
                      and rlctt.tpct1 = {&TYPECONTRAT-bail}
                      and rlctt.noct1 = piNumeroRole
                      and rlctt.tpct2 = {&TYPECONTRAT-RIB} no-error.
                if not available rlctt then do:
                    pcCodeRetour = "003".
                    return.
                end.
                find first ctanx no-lock 
                    where ctanx.tpcon = rlctt.tpct2
                      and ctanx.nocon = rlctt.noct2 no-error.
                if not available ctanx then do :
                    pcCodeRetour = "004".
                    return.
                end.
                gcCoordonneesBancaires = substitute("&1@&2@&3@&4@&5@&6@&7@&8@&9",
                                                    trim(ctanx.lbdom),
                                                    ctanx.lbtit,
                                                    ctanx.iban,
                                                    ctanx.bicod,
                                                    if ctanx.fgetr = ? then "N" else string(ctanx.fgetr, "O/N")).
            end.
        end.
        if pcTypeRole = {&TYPEROLE-beneficiaire} then do:
            find first ctrlb no-lock 
                where ctrlb.tpctt = {&TYPECONTRAT-Mandat2Gerance}
                  and ctrlb.noctt = piNumeroMandat
                  and ctrlb.noid1 = piNumeroProprietaireduBeneficiaire
                  and ctrlb.tpid2 = pcTypeRole
                  and ctrlb.noid2 = piNumeroRole
                  and ctrlb.nbnum <> 0 no-error.
            if not available ctrlb
            then pcCodeRetour = "006". 
            else do:
                case ctrlb.mdreg:
                    when {&MODEREGLEMENT-virement} then gcModeReglement = "V".
                    when {&MODEREGLEMENT-suspendu} then gcModeReglement = "S".
                    otherwise                           gcModeReglement = "C".
                end case.
                if ctrlb.noct2 <> 0  and gcModeReglement = "V" and getIban(ctrlb.noct2) = "" then do:
                    pcCodeRetour = "004".
                    return.
                end.
            end.
        end.
    end.
    pcInformationsRetour = substitute("&1|&2", gcModeReglement, gcCoordonneesBancaires). 
end.

if pcTypeRole = {&TYPEROLE-mandant} or pcTypeRole = {&TYPEROLE-coindivisaire} then do:
    find first tache no-lock 
        where tache.tptac = {&TYPETACHE-compteRenduGestion}
          and tache.tpcon = {&TYPECONTRAT-Mandat2Gerance}
          and tache.nocon = piNumeroMandat no-error.
    assign
        glAvecRepartitionTerme = available tache and tache.pdreg <> "00002"
        pcInformationsRetour  = substitute("&1|&2", pcInformationsRetour, string(glAvecRepartitionTerme, "1/0"))
    .
end.
