/*------------------------------------------------------------------------
File        : titreCopropriete.p
Purpose     : Récupération des informations du titre de copropriété (Intervenants, ...)
Author(s)   : OFA  -  2019/01/18
Notes       : 
derniere revue: 2019/01/25 npo ok
------------------------------------------------------------------------*/
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/paramgenerique.i}
{mandat/include/titreCopropriete.i}

procedure getTitreCopropriete:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des informations du titre de copropriété + intervenants rattachés
    Notes  : service externe (beMandatSyndic.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64 no-undo.
    define output parameter table for ttTitreCopropriete.
    define output parameter table for ttIntervenantsTitreCopropriete.

    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer roles   for roles.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.

    empty temp-table ttTitreCopropriete.
    empty temp-table ttIntervenantsTitreCopropriete.

    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-titre2Copro}
          and ctrat.nocon = piNumeroContrat:
        create ttTitreCopropriete.
        assign
            ttTitreCopropriete.iNumeroMandat                   = integer(piNumeroContrat / 100000)
            ttTitreCopropriete.iNumeroCoproprietaire           = piNumeroContrat modulo 100000
            ttTitreCopropriete.cTypeRoleDestinataireTraitement = if ctrat.tpren >= {&TYPEROLE-coproprietaire} then ctrat.tpren else {&TYPEROLE-coproprietaire}
            ttTitreCopropriete.cLibRoleDestinataireTraitement  = outilTraduction:getLibelleProg('O_ROL', ttTitreCopropriete.cTypeRoleDestinataireTraitement)
            ttTitreCopropriete.cTypeRoleDestinataireAG         = ctrat.cddur
            ttTitreCopropriete.cLibelleRoleDestinataireAG      = outilTraduction:getLibelleProg('O_ROL', if ctrat.cddur = "00001" then {&TYPEROLE-coproprietaire} else {&TYPEROLE-mandataire})
            ttTitreCopropriete.lExemplairesSupplemCopro        = entry(1, ctrat.tpact , "#" ) = "C"
            ttTitreCopropriete.lExemplairesSupplemMandataire   = num-entries(ctrat.tpact, "#") >= 2 and entry(2, ctrat.tpact, "#") = "M"
            ttTitreCopropriete.lExemplairesSupplemGerant       = num-entries(ctrat.tpact, "#") >= 3 and entry(3, ctrat.tpact, "#") = "G"
            ttTitreCopropriete.cEnvoiGardienAgence             = ctrat.lbdiv3
            .
        for each intnt no-lock
            where intnt.TpCon = ctrat.tpcon
              and intnt.nocon = ctrat.nocon
              and lookup(intnt.tpidt, substitute("&1,&2,&3,&4", {&TYPEROLE-coproprietaire}, {&TYPEROLE-mandataire}, {&TYPEROLE-coindivisaire}, {&TYPEROLE-gerant})) > 0,
            first roles no-lock
            where roles.tprol = intnt.tpidt
              and roles.norol = intnt.noidt,
            first tiers no-lock
            where tiers.notie = roles.notie:
            create ttIntervenantsTitreCopropriete.
            assign
                ttIntervenantsTitreCopropriete.iNumeroMandat           = ttTitreCopropriete.iNumeroMandat
                ttIntervenantsTitreCopropriete.iNumeroCoproprietaire   = ttTitreCopropriete.iNumeroCoproprietaire
                ttIntervenantsTitreCopropriete.cTypeRoleIntervenant    = roles.tprol
                ttIntervenantsTitreCopropriete.iNumeroRoleIntervenant  = roles.norol
                ttIntervenantsTitreCopropriete.iTantiemeIndivisaire    = intnt.nbnum
                ttIntervenantsTitreCopropriete.iBaseIndivisaire        = intnt.nbden
                ttIntervenantsTitreCopropriete.iNumeroTiersIntervenant = roles.notie
                ttIntervenantsTitreCopropriete.cLibelleRoleIntervenant = outilTraduction:getLibelleProg('O_ROL', roles.tprol)
                ttIntervenantsTitreCopropriete.cNomRoleIntervenant     = substitute("&1 &2", trim(tiers.lnom1), tiers.lpre1)
            .
            if intnt.tpidt = {&TYPEROLE-coindivisaire} then
                assign
                    ttIntervenantsTitreCopropriete.cCodeExemplaireAdFIndivis        = if intnt.edapf >= {&PARAMETRE-avec} then intnt.edapf else {&PARAMETRE-sans}
                    ttIntervenantsTitreCopropriete.cLibelleExemplaireAdFIndivis     = outilTraduction:getLibelleParam("CDA_S", ttIntervenantsTitreCopropriete.cCodeExemplaireAdFIndivis)
                    ttIntervenantsTitreCopropriete.cCodeExemplaireChargesIndivis    = if intnt.lbdiv2 >= {&PARAMETRE-avec} then intnt.lbdiv2 else {&PARAMETRE-sans}
                    ttIntervenantsTitreCopropriete.cLibelleExemplaireChargesIndivis = outilTraduction:getLibelleParam("CDA_S", ttIntervenantsTitreCopropriete.cCodeExemplaireChargesIndivis)
                .
            else if lookup(roles.tprol, substitute("&1,&2", {&TYPEROLE-mandataire}, {&TYPEROLE-gerant})) > 0 then do:
                if roles.norol = 1 then
                    ttIntervenantsTitreCopropriete.cTypeServiceGestion = "CAB".
                else
                    for first vbRoles no-lock
                        where vbRoles.tprol = {&TYPEROLE-agenceGestion}
                          and vbRoles.notie = roles.notie:
                        assign
                            ttIntervenantsTitreCopropriete.cTypeServiceGestion    = "AGE"
                            ttIntervenantsTitreCopropriete.iCodeServiceGestion    = vbRoles.norol
                            ttIntervenantsTitreCopropriete.cLibelleServiceGestion = ""
                        .
                    end.
            end.
        end.
    end.

end procedure.

