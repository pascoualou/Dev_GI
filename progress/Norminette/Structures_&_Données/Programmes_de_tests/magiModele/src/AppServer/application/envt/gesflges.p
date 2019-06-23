/*------------------------------------------------------------------------
File        : gesflges.p
Purpose     : Programme de filtrage des requetes sur le gestionnaire
Tables      : BASE sadb : tache taint bctctt ctctt ctrat roles intnt
              BASE ladb : sys_pg
2016/05/10  kantena: utilisation magiWeb
-------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}

using oerealm.token.

define input        parameter poToken       as class token no-undo.
define input        parameter piGestion     as integer   no-undo.
define input-output parameter piNoReqUse    as integer   no-undo.
define input        parameter pcTypeRequete as character no-undo.
define input        parameter pcIdentifiant as character no-undo.

function lFiltre             returns logical   private(pcTypeIdentifiant as character, piIdentifiant   as integer) forwards.
function listeServiceGestion returns character private(piServiceGestion as integer,    piCollaborateur as integer) forwards.
function FilDirect           returns integer   private(pcEnregistrement as character,  piRequete       as integer) forwards.

define variable gcLsGesUse as character no-undo.

/*--> Dans le cas d'un filtre direct piNoReqUse fait office de variable de retour */
if pcTypeRequete = "Direct" then piNoReqUse = 0.
/*--> Si cabinet sans service de gestion aucun filtre */
if poToken:iGestionnaire = 4 then return.

/*--> Si profil administrateur et selection tout les service de gestion aucun filtre */
if poToken:iGestionnaire = 0 and piGestion = 0 then return.

gcLsGesUse = listeServiceGestion(piGestion, poToken:iCollaborateur).
case pcTypeRequete:
    when "Direct" then piNoReqUse = FilDirect(pcIdentifiant, piNoReqUse).
end case.

function lFiltre returns logical private(pcTypeIdentifiant as character, piIdentifiant as integer):
    /*------------------------------------------------------------------------
    Purpose: Filtre global
    Notes  :
    ------------------------------------------------------------------------*/
    define variable vlExisteIntervenant as logical no-undo initial true.
    define buffer intnt   for intnt.
    define buffer vbRoles for roles.
    define buffer ctrat   for ctrat.
    define buffer ctctt   for ctctt.
    define buffer vbCtctt for ctctt.
    define buffer tache   for tache.
    define buffer taint   for taint.
    define buffer sys_pg  for sys_pg.

    case pcTypeIdentifiant:
        /*--ROLES------------------------------------------------------------------------------------------------------------------*/
        when {&TYPEROLE-Mandant} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-coproprietaire} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-titre2copro}
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-Garant} or when {&TYPEROLE-Locataire} or when {&TYPEROLE-Colocataire}
        then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-bail}
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-Coindivisaire} then for each intnt no-lock
            where (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} or intnt.tpcon = {&TYPECONTRAT-titre2copro})
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-Syndic2copro} or when {&TYPEROLE-Syndicat2copro} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        /*****************************************
        when {&TYPEROLE-MembreConseilSyndical} or when {&TYPEROLE-AdjointConseilSyndical} or when {&TYPEROLE-BienfaiteurConseilSyndical} or when {&TYPEROLE-RespTravauxConseilSyndical} or when {&TYPEROLE-PresidentConseilSyndical}
        then for each Taint no-lock
            where taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and taint.TpIdt = pcTypeIdentifiant
              and taint.NoIdt = piIdentifiant
              and taint.TpTac =  {&TYPETACHE-conseilSyndical}
              and taint.NoTac = 1:
            if not lFiltre(taint.tpcon,taint.nocon) then return false.
        end.
        ******************************************/

        when {&TYPEROLE-Vendeur} or when {&TYPEROLE-Acheteur} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mutation}
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-Entrepreneur} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-travaux}
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-Salarie} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-Salarie}
              and intnt.tpidt = pcTypeIdentifiant
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-SalariePegase} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-SalariePegase}
              and intnt.noidt = piIdentifiant:
            if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
        end.

        when {&TYPEROLE-Tiers} then for each vbRoles no-lock
            where vbRoles.notie = piIdentifiant:
            if not lFiltre(vbRoles.tprol, vbRoles.norol) then return false.
        end.

        /*--CONTRAT----------------------------------------------------------------------------------------------------------------*/
        when {&TYPECONTRAT-mandat2Syndic} or when {&TYPECONTRAT-mandat2Gerance} then for first ctrat no-lock
            where ctrat.tpcon = pcTypeIdentifiant
              and ctrat.nocon = piIdentifiant
          , first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = ctrat.tpcon
              and ctctt.noct2 = ctrat.nocon:
            if lookup(string(ctctt.noct1), gcLsGesUse, "|") > 0 then return false.
        end.

        when {&TYPECONTRAT-titre2copro} or when {&TYPECONTRAT-travaux} or when {&TYPECONTRAT-assuranceSyndic}
        then for first vbCtctt no-lock
            where vbCtctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
              and vbCtctt.tpct2 = pcTypeIdentifiant
              and vbCtctt.noct2 = piIdentifiant
          , first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = vbCtctt.tpct1
              and ctctt.noct2 = vbCtctt.noct1:
            if lookup(string(ctctt.noct1), gcLsGesUse, "|") > 0 then return false.
        end.

        when {&TYPECONTRAT-preBail} or when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-assuranceGerance}
        then for first vbCtctt no-lock
            where vbCtctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
              and vbCtctt.tpct2 = pcTypeIdentifiant
              and vbCtctt.noct2 = piIdentifiant
          , first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = vbCtctt.tpct1
              and ctctt.noct2 = vbCtctt.noct1:
            if lookup(string(ctctt.noct1), gcLsGesUse, "|") > 0 then return false.
        end.

        when {&TYPECONTRAT-Salarie} then for each vbCtctt no-lock
            where (vbCtctt.tpct1 = {&TYPECONTRAT-mandat2Gerance} or vbCtctt.tpct1 = {&TYPECONTRAT-mandat2Syndic})
              and vbCtctt.tpct2 = pcTypeIdentifiant
              and vbCtctt.noct2 = piIdentifiant
          , first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = vbCtctt.tpct1
              and ctctt.noct2 = vbCtctt.noct1:
            if lookup(string(ctctt.noct1), gcLsGesUse, "|") > 0 then return false.
        end.

        when {&TYPECONTRAT-SalariePegase}
        then for each vbCtctt no-lock
            where (vbCtctt.tpct1 = {&TYPECONTRAT-mandat2Gerance} or vbCtctt.tpct1 = {&TYPECONTRAT-mandat2Syndic})
              and vbCtctt.tpct2 = pcTypeIdentifiant
              and vbCtctt.noct2 = piIdentifiant
          , first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
              and ctctt.tpct2 = vbCtctt.tpct1
              and ctctt.noct2 = vbCtctt.noct1:
            if lookup(string(ctctt.noct1), gcLsGesUse, "|") > 0 then return false.
        end.

        /*--BIEN-------------------------------------------------------------------------------------------------------------------*/
        when {&TYPEBien-immeuble} then do:
            vlExisteIntervenant = false.
            for each intnt no-lock
                where intnt.tpidt = pcTypeIdentifiant
                  and intnt.noidt = piIdentifiant
                  and (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} or intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}):
                if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
                vlExisteIntervenant = true.
            end.
            return vlExisteIntervenant.
        end.

        when {&TYPEBien-lot} then do:
            vlExisteIntervenant = false.
            for each intnt no-lock
                where intnt.tpidt = pcTypeIdentifiant
                  and intnt.noidt = piIdentifiant
                  and (intnt.tpcon = {&TYPECONTRAT-titre2copro} or intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}):
                if not lFiltre(intnt.tpcon, intnt.nocon) then return false.
                vlExisteIntervenant = true.
            end.
            return vlExisteIntervenant.
        end.

        /*--LE RESTE---------------------------------------------------------------------------------------------------------------*/
        otherwise do:
            /*--> CONSEIL SYNDICAL ? (President, Membre, Adjoint, Bienfaiteur...)  */
            find first sys_pg no-lock
                where sys_pg.tppar = "R_TFR"
                  and sys_pg.zone1 = {&TYPETACHE-conseilSyndical}
                  and sys_pg.zone2 = "00001"
                  and sys_pg.zone3 = pcTypeIdentifiant no-error.
            if available sys_pg
            then for each Taint  no-lock
                where taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and taint.TpIdt = pcTypeIdentifiant
                  and taint.NoIdt = piIdentifiant
                  and taint.TpTac = {&TYPETACHE-conseilSyndical}
              , last tache  no-lock
                where tache.tpcon = taint.tpcon
                  and tache.nocon = taint.nocon
                  and tache.tptac = {&TYPETACHE-conseilSyndical}:
                {&_proparse_ prolint-nowarn(blocklabel)}
                if Taint.notac <> Tache.notac then next.

                if not lFiltre(taint.tpcon, taint.nocon) then return false.
            end.
            else return false.
        end.
    end case.
    return true.

end function.

function listeServiceGestion returns character private(piServiceGestion as integer, piCollaborateur as integer):
    /*------------------------------------------------------------------------
    Purpose: Construction de la liste des service de gestion à traiter
    Notes  :
    ------------------------------------------------------------------------*/
    define variable vcListeGestion as character no-undo.
    define buffer intnt for intnt.

    if piServiceGestion > 0 then return string(piServiceGestion).

    for each intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-serviceGestion}
          and intnt.tpidt = {&TYPEROLE-gestionnaire}
          and intnt.noidt = piCollaborateur:
        vcListeGestion = substitute('&1|&2', vcListeGestion, string(intnt.nocon)).
    end.
    return trim(vcListeGestion, "|").

end function.

function filDirect returns integer private(pcEnregistrement as character, piRequete as integer):
    /*------------------------------------------------------------------------
    Purpose: Filtrage sur un enregistrement determiné
    Notes  : Si l'element appartient au service de gestion, retour vrai
    ------------------------------------------------------------------------*/

    if num-entries(pcEnregistrement, "|") > 1
    then do:
        {&_proparse_ prolint-nowarn(noeffect)}
        integer(entry(2, pcEnregistrement, "|")) no-error.
        if not error-status:error
        and lFiltre(entry(1, pcEnregistrement, "|"), integer(entry(2, pcEnregistrement, "|"))) then return 1.
    end.
    error-status:error = false no-error. /* reset error-status */
    return piRequete.

end function.
