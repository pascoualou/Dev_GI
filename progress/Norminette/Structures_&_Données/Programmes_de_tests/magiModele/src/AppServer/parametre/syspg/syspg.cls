/*------------------------------------------------------------------------
File      : syspg.cls
Purpose   : classe générique de paramétrage défini dans sys_pg 
Author(s) : Kantena  -  2017/11/08
Notes     : 
------------------------------------------------------------------------*/
{preprocesseur/niveauErreur.i}

using oerealm.magiToken.

using outils.outilTraduction.

block-level on error undo, throw.

class parametre.syspg.syspg: 
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}
    define public static property mError as class outils.errorHandler no-undo get. set.
    define public property isDbParameter as logical   no-undo get. set.
    define public property giNumeroItem  as integer   no-undo get. set.
    define public property cNomCombo     as character no-undo get. set.
    define public property tppar as character no-undo get. set.
    define public property cdpar as character no-undo get. set.
    define public property lbpar as character no-undo get. set.
    define public property nome1 as integer   no-undo get. set.
    define public property nome2 as integer   no-undo get. set.
    define public property zone1 as character no-undo get. set.
    define public property zone2 as character no-undo get. set.
    define public property zone3 as character no-undo get. set.
    define public property zone4 as character no-undo get. set.
    define public property zone5 as character no-undo get. set.
    define public property zone6 as character no-undo get. set.
    define public property zone7 as character no-undo get. set.
    define public property zone8 as character no-undo get. set.
    define public property zone9 as character no-undo get. set.
    define public property rprun as character no-undo get. set.
    define public property nmprg as character no-undo get. set.
    {&_proparse_ prolint-nowarn(idiskeyword)}
    define public property minim as integer   no-undo get. set.
    define public property maxim as integer   no-undo get. set.

    constructor public syspg():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: Attention, pas de reload dans ce cas.
        ------------------------------------------------------------------------------*/
    end constructor.
    
    constructor public syspg(pcTypeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        reload(pcTypeParam).
        this-object:tppar = pcTypeParam.
    end constructor.
    constructor public syspg(pcTypeParam as character, pcNomCombo as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: Attention, pas de reload dans ce cas.
        ------------------------------------------------------------------------------*/
        assign
            this-object:tppar     = pcTypeParam
            this-object:cNomCombo = pcNomCombo
        .
    end constructor.
    method public void renew(pcTypeParam as character, pcNomCombo as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes: Attention, pas de reload dans ce cas.
        ------------------------------------------------------------------------------*/
        assign
            this-object:tppar     = pcTypeParam
            this-object:cNomCombo = pcNomCombo
        .
    end method.
    method public void reload(pcTypeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.

        this-object:initProperty().
        for first sys_pg no-lock
            where sys_pg.tppar = pcTypeParam:
            this-object:assignTable2property(buffer sys_pg).
        end.
    end method.
    method public void reload(pcTypeParam as character, pcNomCombo as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        this-object:initProperty().
        this-object:reload(pcTypeParam).
        this-object:cNomCombo = pcNomCombo.
    end method.
    method public void reloadZone1(pcTypeParam as character, pcZone1 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.

        this-object:initProperty().
        for first sys_pg no-lock
            where sys_pg.tppar = pcTypeParam
              and sys_pg.zone1 = pcZone1:
            this-object:assignTable2property(buffer sys_pg).
        end.
    end method.
    method public void reloadZone2(pcTypeParam as character, pcZone2 as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.

        this-object:initProperty().
        for first sys_pg no-lock
            where sys_pg.tppar = pcTypeParam
              and sys_pg.zone2 = pcZone2:
            this-object:assignTable2property(buffer sys_pg).
        end.
    end method.
    method public void reloadUnique(pcTypeParam as character, pcCodeParam as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.

        this-object:initProperty().
        for first sys_pg no-lock
            where sys_pg.tppar = pcTypeParam
              and sys_pg.cdpar = pcCodeParam:
            this-object:assignTable2property(buffer sys_pg).
        end.
    end method.
    method public void reloadDynamique(pcWhereClause as character):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.

        this-object:initProperty().
        buffer sys_pg:find-first(pcWhereClause, no-lock) no-error.
        if buffer sys_pg:available then this-object:assignTable2property(buffer sys_pg).
    end method.

    method public void initProperty():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            this-object:isDbParameter = false
            this-object:tppar         = ""
            this-object:cdpar         = ""
            this-object:zone1         = ""
            this-object:zone2         = ""
            this-object:zone3         = ""
            this-object:zone4         = ""
            this-object:zone5         = ""
            this-object:zone6         = ""
            this-object:zone7         = ""
            this-object:zone8         = ""
            this-object:zone9         = ""
            this-object:nome1         = 0
            this-object:nome2         = 0
            this-object:lbpar         = ""
            this-object:rprun         = ""
            this-object:nmprg         = ""
            this-object:minim         = 0
            this-object:maxim         = 0
            this-object:cNomCombo     = ""
        .
    end method.

    method private void createttCombo(pcNomCombo as character, pcCode as character, pcLibelle as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        create ttCombo.
        assign
            giNumeroItem             = giNumeroItem + 1
            ttcombo.iSeqId           = giNumeroItem
            ttCombo.cNomCombo        = pcNomCombo
            ttCombo.cCode            = trim(pcCode)
            ttCombo.cLibelle         = trim(pcLibelle)
        .
    end method.

    method public integer creationttCombo(pcNomCombo as character, pcCode as character, pcLibelle as character, output table ttCombo):    
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  :
    ------------------------------------------------------------------------------*/
        for last ttCombo where ttCombo.cNomCombo = pcNomCombo: giNumeroItem = ttCombo.iSeqId. end.
        create ttCombo.
        assign
            giNumeroItem             = giNumeroItem + 1
            ttcombo.iSeqId           = giNumeroItem
            ttCombo.cNomCombo        = pcNomCombo
            ttCombo.cCode            = trim(pcCode)
            ttCombo.cLibelle         = trim(pcLibelle)
        .
    end method.
    method public integer createttComboWithParent(pcNomCombo as character, pcCode as character, pcParent as character, piLibelle as integer):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttcombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = pcNomCombo
            ttCombo.cCode     = pcCode
            ttCombo.cParent   = pcParent
            ttCombo.cLibelle  = outilTraduction:getLibelle(piLibelle)
        .
    end method.

    method private void assignTable2property(buffer pbSyspg for sys_pg):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        assign
            this-object:tppar = pbSyspg.tppar
            this-object:cdpar = pbSyspg.cdpar
            this-object:lbpar = pbSyspg.lbpar
            this-object:nome1 = pbSyspg.nome1
            this-object:nome2 = pbSyspg.nome2
            this-object:zone1 = pbSyspg.zone1
            this-object:zone2 = pbSyspg.zone2
            this-object:zone3 = pbSyspg.zone3
            this-object:zone4 = pbSyspg.zone4
            this-object:zone5 = pbSyspg.zone5
            this-object:zone6 = pbSyspg.zone6
            this-object:zone7 = pbSyspg.zone7
            this-object:zone8 = pbSyspg.zone8
            this-object:zone9 = pbSyspg.zone9
            this-object:rprun = pbSyspg.rprun
            this-object:nmprg = pbSyspg.nmprg
            this-object:minim = pbSyspg.minim
            this-object:maxim = pbSyspg.maxim
            this-object:isDbParameter = true
        .
    end method.
    method public integer getComboParametre(pcTypeParam as character, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libellé long sur nome1
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.
        for each sys_pg no-lock
            where sys_pg.tppar = pcTypeParam
            by sys_pg.cdpar:
            createttCombo(pcNomCombo, sys_pg.cdpar, outilTraduction:getLibelle(sys_pg.nome1)).
        end.
        return giNumeroItem.
    end method.    
    method public integer getComboParametre(pcTypeParam as character, pcCdpar as character, pcNomCombo as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose: libellé long sur nome1
    Notes  :
    ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.
        for each sys_pg no-lock
            where sys_pg.tppar = pcTypeParam
              and sys_pg.cdpar = pcCdpar
            by sys_pg.zone1:
//gga todo a revoir ce n'est surement pas sys_pg.cdpar qu'il faut comme code dans la combo               
            createttCombo(pcNomCombo, sys_pg.cdpar, outilTraduction:getLibelle(sys_pg.nome1)).
        end.
        return giNumeroItem.    
    end method.    
    method public integer getComboParametreWithParent(pcZone2 as character, output table ttCombo):
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : pcZone2 = Exception
        ------------------------------------------------------------------------------*/
        define buffer sys_pg for sys_pg.
        if pcZone2 > ""
        then for each sys_pg no-lock
            where sys_pg.tppar = this-object:tppar
              and sys_pg.zone2 <> pcZone2
            by sys_pg.zone1 by sys_pg.cdpar:
            createttComboWithParent(this-object:cNomCombo, sys_pg.zone2, sys_pg.zone1, sys_pg.nome1).
        end.
        else for each sys_pg no-lock
            where sys_pg.tppar = this-object:tppar
            by sys_pg.zone1 by sys_pg.cdpar:
            createttComboWithParent(this-object:cNomCombo, sys_pg.zone2, sys_pg.zone1, sys_pg.nome1).
        end.
    end method.

    method public void setgiNumeroItem(piNumeroItem as integer) :
    /*------------------------------------------------------------------------------
     Purpose: Assignation de giNumeroItem
     Notes:
    ------------------------------------------------------------------------------*/
        giNumeroItem = piNumeroItem.
    end method.
          
    method public logical creationComboSysPgZonXX(pcTpLibPar as character, pcLbZonPrg as character, output table ttCombo):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
        creationComboSysPgZonXX(this-object:tppar, this-object:cNomCombo, pcTpLibPar, pcLbZonPrg, output table ttCombo).
    end method.
  
    method public logical creationComboSysPgZonXX(pcTypeParam as character, pcNomCombo as character, pcTpLibPar as character, pcLbZonPrg as character, output table ttCombo):          
        /*------------------------------------------------------------------------------
        Purpose: Procédure qui récupère les Codes et les Libellés en fonction d'un Type de
                 paramètre et des champs zoneX ‚ éventuellement renseignés.
        Parametre d'entrée:  (1) = libellé court "C", ou loong (autre valeur)
                             (2) = code parametre
                             (3) = nom de la combo
        todo:  gga pour l'instant on conserve en entree les parametre avec plusieurs infos et separateur
               il faudra revoir quand on trouvera un appel plus complexe de cette procedure
        Notes: service externe
        ------------------------------------------------------------------------------*/
        define variable vcLbMesUse as character no-undo.
        define variable viNbParPrg as integer   no-undo.
        define variable vcTbParPrg as character no-undo extent 9.
        define variable viNoZonPar as integer   no-undo.
        define variable vcTpParZon as character no-undo.
    
        define buffer sys_pg for sys_pg.
        define buffer pclie  for pclie.

        if pcTpLibPar <> "C" then pcTpLibPar = "L".
        if pcLbZonPrg > "" then do:
            viNbParPrg = num-entries(pcLbZonPrg, "-").
            // Recherche de l'existence du type de parametre
            find first sys_pg no-lock
                 where sys_pg.tppar = "#####"
                   and sys_pg.cdpar = pcTypeParam no-error.
            if not available sys_pg
            then do:
                if valid-object(mError) then mError:createError({&error}, "parametre inexistant").     //todo creation message
                return false.
            end.
            // Calcul du nombre de zones de la table
            if sys_pg.zone1 > "" then viNoZonPar = 1.
            if sys_pg.zone2 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone3 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone4 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone5 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone6 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone7 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone8 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone9 > "" then viNoZonPar = viNoZonPar + 1.
            // Nombre de zones recherchées incompatible avec le nombre de zones de la table.
            if viNoZonPar < viNbParPrg
            then do:
                if valid-object(mError) then mError:createError({&error}, "Nombre de zones recherches incompatible avec le nombre de zones de la table").     //todo creation message
                return false.
            end.
            // Recherche de l'existence du code parametre.
            do viNoZonPar = 1 to viNbParPrg:
                vcTbParPrg[viNoZonPar] = entry(viNoZonPar, pcLbZonPrg, "-").
                case viNoZonPar:
                    when 1 then vcTpParZon = sys_pg.zone1.
                    when 2 then vcTpParZon = sys_pg.zone2.
                    when 3 then vcTpParZon = sys_pg.zone3.
                    when 4 then vcTpParZon = sys_pg.zone4.
                    when 5 then vcTpParZon = sys_pg.zone5.
                    when 6 then vcTpParZon = sys_pg.zone6.
                    when 7 then vcTpParZon = sys_pg.zone7.
                    when 8 then vcTpParZon = sys_pg.zone8.
                    when 9 then vcTpParZon = sys_pg.zone9.
                end case.
                if not can-find(first sys_pg no-lock
                                where sys_pg.tppar = vcTpParZon
                                  and sys_pg.cdpar = vcTbParPrg[viNoZonPar])
                then do:
                    if valid-object(mError) then mError:createError({&error}, "ano existence param").     //todo creation message
                    return false.
                end.
            end.
        end.
        // A ce niveau, le type de parametre ainsi que le code de parametre existent, on peut donc effectuer la recherche.
        /* REMARQUE : Le FOR EACH ne traite que les 3 premiere zones.
                      Si Il y a besoin d'une autre zone, le programme signale le besoin: il faudra rajouter un for each.
        */

        // Recherche sur sys_pg.
        case viNbParPrg:
            /* cas: aucune zone recherchée */
            when 0 then for each sys_pg no-lock
                where sys_pg.tppar = pcTypeParam
                by sys_pg.cdpar:                                //  Utilisé pour l'ordre
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTypeParam begins "O_" then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.

                if pcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe2)).
                else vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe1)).
                createttCombo(pcNomCombo, sys_pg.cdpar, vcLbMesUse).
            end.
            /* cas : zone1 recherche */
            when 1 then for each sys_pg no-lock
                where sys_pg.tppar = pcTypeParam
                  and sys_pg.zone1 = vcTbParPrg[1]
                by sys_pg.cdpar:                                  // Utilisé pour l'ordre
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTypeParam begins "O_" then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.
    
                if pcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe2)).
                else vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe1)).
                createttCombo(pcNomCombo, sys_pg.zone2, vcLbMesUse).
            end.
            /* cas : zone1 et/ou zone 2 recherche */
            when 2 then for each sys_pg no-lock
                where sys_pg.tppar = pcTypeParam
                  and sys_pg.zone1  = vcTbParPrg[1]
                  and sys_pg.zone2  = vcTbParPrg[2]
                by sys_pg.cdpar:                                 // Utilisé pour l'ordre
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTypeParam begins ("O_") then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.
    
                if pcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(Sys_Pg.NoMe2)).
                else vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(Sys_Pg.NoMe1)).
                createttCombo(pcNomCombo, sys_pg.zone3, vcLbMesUse).
            end.
            /* cas : zone1 et/ou zone 2 et/ou zone3 recherche */
            when 3 then for each sys_pg no-lock
                where sys_pg.tppar = pcTypeParam
                  and sys_pg.zone1 = vcTbParPrg[1]
                  and sys_pg.zone2 = vcTbParPrg[2]
                  and sys_pg.zone3 = vcTbParPrg[3]
                by sys_pg.cdpar:                                 // Utilisé pour l'ordre
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTypeParam begins ("O_") then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.
    
                if pcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe2)).
                else vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe1)).
                createttCombo(pcNomCombo, sys_pg.zone4, vcLbMesUse).
            end.
            otherwise do:
    //            message "La Zone " viNbParPrg " est Absente du 'For Each'" skip
    //                "dans l_parprg.p : Il faut l'ajouter.".
                if valid-object(mError) then mError:createError({&error}, "????").     //todo creation message
                return false.
            end.
        end case.

        // Affectation du Code Retour.
        if not can-find (first ttCombo)
        then do:
            if valid-object(mError) then mError:createError({&error}, "erreur parametrage, aucune valeur proposee").     //todo creation message
            return false.
        end.
        return true.
    end method.
    method public character getTraductionCourt():
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  :
    ------------------------------------------------------------------------------*/
        return outilTraduction:getLibelle(this-object:nome2).
    end method.
    method public character getTraductionLong():
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  :
    ------------------------------------------------------------------------------*/
        return outilTraduction:getLibelle(this-object:nome1).
    end method.
    method public character getTraductionCourtZonX(pcLbZonPrg as character, pcCode as character):
        return getTraductionZonX("C", pcLbZonPrg, pcCode).
    end method.
    method public character getTraductionLongZonX(pcLbZonPrg as character, pcCode as character):
        return getTraductionZonX("L", pcLbZonPrg, pcCode).
    end method.

    method private character getTraductionZonX(pcTpLibPar as character, pcLbZonPrg as character, pcCode as character):
        /*------------------------------------------------------------------------------
        Purpose: Procédure qui récupère le Libellé d'un code en fonction des champs zoneX.
        Parametre d'entrée: (1) = libellé court "C", ou long (autre valeur)
                            (2) = champs zoneX
                            (3) = code parametre
        ------------------------------------------------------------------------------*/
        define variable viNbParPrg as integer   no-undo.
        define variable vcTbParPrg as character no-undo extent 9.
        define variable viNoZonPar as integer   no-undo.
        define variable vcTpParZon as character no-undo.

        define buffer sys_pg for sys_pg.
        define buffer pclie  for pclie.

        if pcTpLibPar <> "C" then pcTpLibPar = "L".
        if pcLbZonPrg > "" then do:
            viNbParPrg = num-entries(pcLbZonPrg, "-").
            // Recherche de l'existence du type de parametre
            find first sys_pg no-lock
                 where sys_pg.tppar = "#####"
                   and sys_pg.cdpar = this-object:tppar no-error.
            if not available sys_pg then return substitute("?.&1.?", pcCode).

            // Calcul du nombre de zones de la table
            if sys_pg.zone1 > "" then viNoZonPar = 1.
            if sys_pg.zone2 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone3 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone4 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone5 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone6 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone7 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone8 > "" then viNoZonPar = viNoZonPar + 1.
            if sys_pg.zone9 > "" then viNoZonPar = viNoZonPar + 1.
            // Nombre de zones recherchées incompatible avec le nombre de zones de la table.
            if viNoZonPar < viNbParPrg then return substitute("?.&1.?", pcCode).

            // Recherche de l'existence du code parametre.
            do viNoZonPar = 1 to viNbParPrg:
                vcTbParPrg[viNoZonPar] = entry(viNoZonPar, pcLbZonPrg, "-").
                case viNoZonPar:
                    when 1 then vcTpParZon = sys_pg.zone1.
                    when 2 then vcTpParZon = sys_pg.zone2.
                    when 3 then vcTpParZon = sys_pg.zone3.
                    when 4 then vcTpParZon = sys_pg.zone4.
                    when 5 then vcTpParZon = sys_pg.zone5.
                    when 6 then vcTpParZon = sys_pg.zone6.
                    when 7 then vcTpParZon = sys_pg.zone7.
                    when 8 then vcTpParZon = sys_pg.zone8.
                    when 9 then vcTpParZon = sys_pg.zone9.
                end case.
                if not can-find(first sys_pg no-lock
                                where sys_pg.tppar = vcTpParZon
                                  and sys_pg.cdpar = vcTbParPrg[viNoZonPar])
                then return substitute("?.&1.?", pcCode).
            end.
        end.
        // A ce niveau, le type de parametre ainsi que le code de parametre existent, on peut donc effectuer la recherche.
        /* REMARQUE : Le FOR EACH ne traite que les 3 premiere zones.
                      Si Il y a besoin d'une autre zone, le programme signale le besoin: il faudra rajouter un for each.
        */
        // Recherche sur sys_pg.
        case viNbParPrg:
            when 0 then for each sys_pg no-lock
                where sys_pg.tppar = this-object:tppar
                  and sys_pg.cdpar = pcCode:
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if this-object:tppar begins "O_" then pcCode else sys_pg.zone2) no-error.
                if not available pclie or pclie.fgact = "YES"
                then return if pcTpLibPar = "C"
                       then if available pclie and pclie.lbdiv2 > ""
                            then trim(pclie.lbdiv2)
                            else outilTraduction:getLibelle(string(sys_pg.nome2))
                       else if available pclie and pclie.lbdiv > ""
                            then trim(pclie.lbdiv)
                            else outilTraduction:getLibelle(string(sys_pg.nome1)).
            end.
            /* cas : zone1 recherche */
            when 1 then for first sys_pg no-lock
                where sys_pg.tppar = this-object:tppar
                  and sys_pg.cdpar = pcCode
                  and sys_pg.zone1 = vcTbParPrg[1]:
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if this-object:tppar begins "O_" then pcCode else sys_pg.zone2) no-error.
                if not available pclie or pclie.fgact = "YES"
                then return if pcTpLibPar = "C"
                       then if available pclie and pclie.lbdiv2 > ""
                            then trim(pclie.lbdiv2)
                            else outilTraduction:getLibelle(string(sys_pg.nome2))
                       else if available pclie and pclie.lbdiv > ""
                            then trim(pclie.lbdiv)
                            else outilTraduction:getLibelle(string(sys_pg.nome1)).
            end.
            /* cas : zone1 et/ou zone 2 recherche */
            when 2 then for first sys_pg no-lock
                where sys_pg.tppar = this-object:tppar
                  and sys_pg.cdpar = pcCode
                  and sys_pg.zone1 = vcTbParPrg[1]
                  and sys_pg.zone2 = vcTbParPrg[2]:
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if this-object:tppar begins "O_" then pcCode else sys_pg.zone2) no-error.
                if not available pclie or pclie.fgact = "YES"
                then return if pcTpLibPar = "C"
                       then if available pclie and pclie.lbdiv2 > ""
                            then trim(pclie.lbdiv2)
                            else outilTraduction:getLibelle(string(sys_pg.nome2))
                       else if available pclie and pclie.lbdiv > ""
                            then trim(pclie.lbdiv)
                            else outilTraduction:getLibelle(string(sys_pg.nome1)).
            end.
            /* cas : zone1 et/ou zone 2 et/ou zone3 recherche */
            when 3 then for first sys_pg no-lock
                where sys_pg.tppar = this-object:tppar
                  and sys_pg.cdpar = pcCode
                  and sys_pg.zone1 = vcTbParPrg[1]
                  and sys_pg.zone2 = vcTbParPrg[2]
                  and sys_pg.zone3 = vcTbParPrg[3]:
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if this-object:tppar begins "O_" then pcCode else sys_pg.zone2) no-error.
                if not available pclie or pclie.fgact = "YES"
                then return if pcTpLibPar = "C"
                       then if available pclie and pclie.lbdiv2 > ""
                            then trim(pclie.lbdiv2)
                            else outilTraduction:getLibelle(string(sys_pg.nome2))
                       else if available pclie and pclie.lbdiv > ""
                            then trim(pclie.lbdiv)
                            else outilTraduction:getLibelle(string(sys_pg.nome1)).
            end.
            otherwise return substitute("?.&1.?", pcCode).
        end case.
        return substitute("?.&1.?", pcCode).
    end method.
    method public logical isDbParameter(pcZone1 as character, pcZone2 as character):
    /*------------------------------------------------------------------------------
    Purpose: usage externe
    Notes  :
    ------------------------------------------------------------------------------*/
        return can-find(first sys_pg no-lock where sys_pg.tppar = this-object:tppar and sys_pg.zone1 = pcZone1 and sys_pg.zone2 = pcZone2).
    end method.
    
    method public logical isParamExist(pcTppar as character, pcZone1 as character, pcZone2 as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
        return can-find(first sys_pg no-lock 
                        where sys_pg.tppar = pcTppar 
                          and sys_pg.zone1 = pcZone1  
                          and sys_pg.zone2 = pcZone2).
    end method.
    
end class.
