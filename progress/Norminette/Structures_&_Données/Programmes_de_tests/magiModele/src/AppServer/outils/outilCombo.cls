 
 /*------------------------------------------------------------------------
    File        : outilCombo
    Purpose     : Outil de création des combos 
    Syntax      : 
    Description : 
    Author(s)   : POF
    Created     : Fri Oct 20 11:03:05 CEST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using oerealm.magiToken.
using outils.outilTraduction.
{preprocesseur/niveauErreur.i}

block-level on error undo, throw.

class outils.outilCombo use-widget-pool final:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    {application/include/combo.i}
    /*{application/include/error.i}*/

    define public static property mError  as class outils.errorHandler no-undo get. set.
    define public static property mLogger as class outils.logHandler   no-undo get. set.

    define variable giNumeroItem as integer no-undo.

    constructor public outilCombo ( ):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    end constructor.

    method public static void getLibellesCombos( phttBuffer as handle, pcListeNomChampsCode as character, table-handle phTtCombo ):
        /*------------------------------------------------------------------------------
        purpose: Alimente automatiquement les champs libellés des combos
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable icpt                as integer          no-undo.
        define variable vhBufferTtCombo     as handle           no-undo.

            /*On parcourt tous les champs de la table*/
            do icpt = 1 to phttBuffer:num-fields:
                /*Sur les champs de type character qui sont éventuellement listés dans le paramètre d'entrée, on cherche si c'est une champ "code combo" 
                  qui se trouve dans la table ttCombo*/
                if phttBuffer:buffer-field(iCpt):extent = 0
                    and (pcListeNomChampsCode = "" or lookup(phttBuffer:buffer-field(iCpt):name,pcListeNomChampsCode) > 0) 
                    and phttBuffer:buffer-field(iCpt):data-type = "character" 
                    and phttBuffer:buffer-field(iCpt):buffer-value ne ?
                then do:
                    vhBufferTtCombo = phTtCombo:default-buffer-handle.
                    vhBufferTtCombo:find-first("where ttcombo.cNomChampCode = " + quoter(phttBuffer:buffer-field(iCpt):name) + " and ttcombo.cCode = " + quoter(phttBuffer:buffer-field(iCpt):buffer-value)) no-error.
                    //Si on a trouvé le champ code dans la table ttcombo, on peut assigner le champ libellé avec sa valeur
                    if vhBufferTtCombo:available and
                       vhBufferTtCombo::cNomChampLibelle ne "" 
                    then do:
/*message "+++++++++++Assignation champ " vhBufferTtCombo::cNomChampLibelle " - valeur "  vhBufferTtCombo::cLibelle.*/
                        phttBuffer:buffer-field(vhBufferTtCombo::cNomChampLibelle):buffer-value = vhBufferTtCombo::cLibelle.
                    end.
                end.
            end.

    end method.
    
    method public void setgiNumeroItem(piNumeroItem as integer) :
    /*------------------------------------------------------------------------------
     Purpose: Assignation de giNumeroItem
     Notes:
    ------------------------------------------------------------------------------*/
        giNumeroItem = piNumeroItem.
    end method.
    
   /*------------------------------------------------------------------------------
    Purpose: Outil générique de création de la table ttCombo
    Notes:
    ------------------------------------------------------------------------------*/
  
    method public void creationComboGen(pcNomCombo as character, pcNomTable as character, pcClauseWhere as character, pcNomCode as character, pcNomLibelle as character, pcNomChampTtCode as character, pcNomChampTtLibelle as character, output table ttCombo):
		
        define variable bTable              as widget-handle    no-undo.
        define variable qTable              as widget-handle    no-undo.
        define variable iCpt                as integer          no-undo.
        define variable cValeurCode         as character no-undo.
        define variable cValeurLibelle      as character no-undo.
    
        create buffer bTable for table pcNomTable.
        create query qTable.
    
        qTable:set-buffers(bTable).
        qTable:query-prepare(pcClauseWhere).
        qTable:query-open().
    
        find last ttcombo no-error.
        giNumeroItem = if available ttcombo then ttcombo.iSeqId else 0.     
    
        repeat:
            qTable:get-next(no-lock).
            if qTable:query-off-end then leave.
            /*On parcourt tous les champs de la table*/
            do icpt = 1 to bTable:num-fields:
                /*On récupère la valeur du champ code et celle du champ libellé*/
                if bTable:buffer-field(iCpt):name = pcNomCode then cValeurCode = string(bTable:buffer-field(iCpt):buffer-value).
                else if bTable:buffer-field(iCpt):name = pcNomLibelle then cValeurLibelle = string(bTable:buffer-field(iCpt):buffer-value).
            end.
            /*On crée la table ttcombo*/
            createttCombo(pcNomCombo, cValeurCode, cValeurLibelle, pcNomChampTtCode, pcNomChampTtLibelle).
        end.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose: Création de la table ttCombo à partir de la table sys_pr
	 Notes:
	------------------------------------------------------------------------------*/

	method public void CreationComboSysPr( pcNom as character, pcTppar as character, output table ttCombo):
		
        define buffer sys_pr for sys_pr.
    
        for each sys_pr no-lock where sys_pr.tppar = pcTppar:
            createttCombo(pcNom, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1)).
        end.
		return.

    end method.
    method public void CreationComboSysPr( pcNom as character, pcTppar as character, pdZone1 as decimal, output table ttCombo):
        
        define buffer sys_pr for sys_pr.
    
        for each sys_pr no-lock where sys_pr.tppar = pcTppar
                                  and sys_pr.zone1 = pdZone1:
            createttCombo(pcNom, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1)).
        end.
        return.

    end method.
    method public void CreationComboSysPr( pcNom as character, pcTppar as character, pcNomChampCode as character, pcNomChampLibelle as character, output table ttCombo ):
        
        define buffer sys_pr for sys_pr.
    
        for each sys_pr no-lock where sys_pr.tppar = pcTppar:
            createttCombo(pcNom, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1),pcNomChampCode,pcNomChampLibelle).
        end.
        return.

    end method.
    method public void CreationComboSysPr( pcNom as character, pcTppar as character, pdZone1 as decimal, pcNomChampCode as character, pcNomChampLibelle as character, output table ttCombo ):
        
        define buffer sys_pr for sys_pr.
    
        for each sys_pr no-lock where sys_pr.tppar = pcTppar
                                  and sys_pr.zone1 = pdZone1:
            createttCombo(pcNom, sys_pr.cdpar, outilTraduction:getLibelle(sys_pr.nome1),pcNomChampCode,pcNomChampLibelle).
        end.
        return.

    end method.

/*
    /*------------------------------------------------------------------------------
     Purpose: Création de la table ttCombo à partir de la table sys_pg
     Notes:
    ------------------------------------------------------------------------------*/

    method public void CreationComboSysPg( pcNom as character, pcTppar as character, output table ttCombo):
        
        define buffer sys_pg for sys_pg.
    
        for each sys_pg no-lock where sys_pg.tppar = pcTppar:
            createttCombo(pcNom, sys_pg.cdpar, outilTraduction:getLibelle(sys_pg.nome1)).
        end.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose: Création de la table ttCombo à partir de la table sys_pg
     Notes:
    ------------------------------------------------------------------------------*/

    method public void CreationComboSysPg( pcNom as character, pcTppar as character, pcNomChampCode as character, pcNomChampLibelle as character, output table ttCombo ):
        
        define buffer sys_pg for sys_pg.
    
        for each sys_pg no-lock where sys_pg.tppar = pcTppar:
            createttCombo(pcNom, sys_pg.cdpar, outilTraduction:getLibelle(sys_pg.nome1),pcNomChampCode,pcNomChampLibelle).
        end.
        return.

    end method.
*/
    /*------------------------------------------------------------------------------
     Purpose: Création de la table ttCombo à partir des parametres
     Notes:
    ------------------------------------------------------------------------------*/

    method public void CreationCombo (pcNom as character, pcTppar as character, pcLibelle as character, pcNomChampCode as character, pcNomChampLibelle as character, output table ttCombo):
        
        createttCombo(pcNom, pcTppar, pcLibelle, pcNomChampCode, pcNomChampLibelle).
        return.

    end method.


    method public logical creationComboSysPgZonXX(pcTpParPrg as character, pcLbZonPrg as character, pcNomCombo as character, pcNomChampCode as character, pcNomChampLibelle as character , output table ttCombo ):
        /*------------------------------------------------------------------------------
        Purpose: Procédure qui récupère les Codes et les Libellés en fonction d'un Type de
                 paramètre et des champs zoneX ‚ éventuellement renseignés.
        Parametre d'entrée:       (1) = Type de parametre-type de lib
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
        define variable vcTpLibPar as character no-undo initial "C". // par defaut on charge le libelle court
    
        define buffer sys_pg for sys_pg.
        define buffer pclie  for pclie.
    
        // Récuperation du type de libelle demande
        if num-entries(pcTpParPrg, '-') > 1
        then assign
            vcTpLibPar = entry(2, pcTpParPrg, "-")
            pcTpParPrg = entry(1, pcTpParPrg, "-")
        .
        viNbParPrg = num-entries (pcLbZonPrg, "-").
    
        // Recherche de l'existence du type de parametre
        find first sys_pg no-lock
             where sys_pg.tppar = "#####"
               and sys_pg.cdpar = pcTpParPrg no-error.
        if not available sys_pg
        then do:
            mError:createError({&error}, "parametre inexistant").     //todo creation message
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
            mError:createError({&error}, "Nombre de zones recherches incompatible avec le nombre de zones de la table").     //todo creation message
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
            if not can-find (first sys_pg no-lock
                             where sys_pg.tppar = vcTpParZon
                               and sys_pg.cdpar = vcTbParPrg[viNoZonPar])
            then do:
                mError:createError({&error}, "ano existence param").     //todo creation message
                return false.
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
                where sys_pg.tppar = pcTpParPrg
                use-index ix_sys_pg01:                                /* Ne pas enlever : Utilisé pour l'ordre */
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTpParPrg begins "O_" then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.
    
                if vcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe2)).
                else if vcTpLibPar = "L"
                then vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe1)).
                createttCombo(pcNomCombo, trim(sys_pg.cdpar), trim(vcLbMesUse), pcNomChampCode, pcNomChampLibelle).
            end.
            /* cas : zone1 recherche */
            when 1 then for each sys_pg no-lock
                where sys_pg.tppar = pcTpParPrg
                  and sys_pg.zone1 = vcTbParPrg[1]
                use-index ix_sys_pg01:                                  /* Ne pas enlever: Utilisé pour l'ordre */
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTpParPrg begins "O_" then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.
    
                if vcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe2)).
                else if vcTpLibPar = "L"
                then vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe1)).
                createttCombo(pcNomCombo, trim(sys_pg.zone2), trim(vcLbMesUse), pcNomChampCode, pcNomChampLibelle).
            end.
            /* cas : zone1 et/ou zone 2 recherche */
            when 2 then for each sys_pg no-lock
                where sys_pg.tppar = pcTpParPrg
                  and sys_pg.zone1  = vcTbParPrg[1]
                  and sys_pg.zone2  = vcTbParPrg[2]
                use-index ix_sys_pg01:                                 /* Ne pas enlever: Utilisé pour l'ordre */
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTpParPrg begins ("O_") then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.
    
                if vcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(Sys_Pg.NoMe2)).
                else if vcTpLibPar = "L"
                then vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(Sys_Pg.NoMe1)).
                createttCombo(pcNomCombo, trim(sys_pg.zone3), trim(vcLbMesUse), pcNomChampCode, pcNomChampLibelle).
            end.
            /* cas : zone1 et/ou zone 2 et/ou zone3 recherche */
            when 3 then for each sys_pg no-lock
                where sys_pg.tppar = pcTpParPrg
                  and sys_pg.zone1 = vcTbParPrg[1]
                  and sys_pg.zone2 = vcTbParPrg[2]
                  and sys_pg.zone3 = vcTbParPrg[3]
                use-index ix_sys_pg01:                                 /* Ne pas enlever: Utilisé pour l'ordre */
                find first pclie no-lock
                     where pclie.tppar = "DEFBX"
                       and pclie.zon01 = (if pcTpParPrg begins ("O_") then sys_pg.cdpar else sys_pg.zone2) no-error.
                {&_proparse_ prolint-nowarn(blocklabel)}
                if available pclie and pclie.fgact <> "YES" then next.
    
                if vcTpLibPar = "C"
                then vcLbMesUse = if available pclie and pclie.lbdiv2 > ""
                                  then trim(pclie.lbdiv2)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe2)).
                else if vcTpLibPar = "L" 
                then vcLbMesUse = if available pclie and pclie.lbdiv > ""
                                  then trim(pclie.lbdiv)
                                  else outilTraduction:getLibelle(string(sys_pg.noMe1)).
                createttCombo(pcNomCombo, trim(sys_pg.zone4), trim(vcLbMesUse), pcNomChampCode, pcNomChampLibelle).
            end.
            otherwise do:
    //            message "La Zone " viNbParPrg " est Absente du 'For Each'" skip
    //                "dans l_parprg.p : Il faut l'ajouter.".
                mError:createError({&error}, "????").     //todo creation message
                return false.
            end.
        end case.
    
        // Affectation du Code Retour.
        if not can-find (first ttCombo)
        then do:
            mError:createError({&error}, "erreur parametrage, aucune valeur proposee").     //todo creation message
            return false.
        end.

		return true.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/

	method private void createttCombo( pcNom as character, pcCode as character, pcLibelle as character ):
		
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttcombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = pcNom
            ttCombo.cCode     = pcCode
            ttCombo.cLibelle  = pcLibelle
        .
		return.

	end method.
	
    method private void createttCombo( pcNom as character, pcCode as character, pcLibelle as character, pcNomChampCode as character, pcNomChampLibelle as character ):
        
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttcombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = pcNom
            ttCombo.cCode     = pcCode
            ttCombo.cLibelle  = pcLibelle
        .
        return.

    end method.

end class.

