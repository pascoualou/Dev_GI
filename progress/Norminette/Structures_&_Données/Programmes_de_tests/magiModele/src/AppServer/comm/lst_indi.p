/*---------------------------------------------------------------------------
File        : lst_indi.p
Purpose     : Indivisions successives
Author(s)   : JR 26/03/2008  -  GGA 2018/02/22
Notes       : reprise comm/lst_indi.i 
              3 programmes adb\envt\lst_indi.p, cadb\batch\lst_indi.p et trans\gene\lst_indi.p exécutent le include comm/lst_indi.i

01  17/02/2011  DM    0211/0017 Limiter les erreurs d'arrondi
02  16/04/2012  OF    Pb format numéro de tiers
03  27/11/2017  OF    #8933 Pb tantièmes à ?
---------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}

using parametre.pclie.pclie.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{comm/include/tantiemeMandat.i}

define temp-table ttLienIndivisionIndivisaire no-undo
    field iNumeroIndivision  as integer
    field iNumeroIndivisaire as integer
.
define temp-table ttIndivisionIndivisaire no-undo
    field iNumeroLigne                 as integer
    field iNumeroRang                  as integer
    field iNumeroIndivisionSui         as integer
    field iNumeroIndivision            as integer
    field cLibelleIndivision           as character
    field iNumeroIndivisaire           as integer
    field cTpIndivision                as character
    field iNumeroTiersIndivisaire      as integer
    field cNomIndivisaire              as character
    field iBanqueIndivisaire           as integer
    field cCompteIndivisaire           as character
    field cLibelleModeReglement        as character
    field cModeReglement               as character
    field iTantiemesIndivisaire        as integer
    field cDecompteIndivisaire         as character
    field cEditionAppel                as character       
    field iTantiemesIndivisionSuivante as integer
    field iTantiemesUsufruitier        as integer
    field iTantiemesNuProprietaire     as integer
    field iTotalTantiemesIndivision    as integer
    field iTotalTantiemesNuPropriete   as integer
    field iTotalTantiemesUsufruit      as integer
    field dDebutIndivision             as date
    field dFinIndivision               as date
    field cTypeMutation                as character
    field iNumeroIndivisionSuivante    as integer
    field cLibelleIndivisionSuivante   as character
.
define variable giNumeroMandat as integer no-undo.    
define variable glIndivSucc    as logical no-undo.
define variable giNiveau       as integer no-undo initial 1.

function donneNomRole return character(pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.

    for each vbRoles no-lock
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = piNumeroRole
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:
        return tiers.lnom1 + " " + tiers.lpre1.
    end.
    return "".
end function.

function DonneTiersRole return integer(pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer vbRoles for roles.

    for each vbRoles no-lock
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = piNumeroRole:
        return vbRoles.notie.
    end.
    return 0.
end function.

procedure lstIndiLancement:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroMandat as integer no-undo.
    define output parameter table for ttTantiemeMandat.

    define variable voPclie as class pclie no-undo.
    define buffer ctrat for ctrat.

    empty temp-table ttLienIndivisionIndivisaire. 
    empty temp-table ttIndivisionIndivisaire. 
    assign
        voPclie        = new pclie("INDVS")
        glIndivSucc    = voPclie:isDbParameter
        giNumeroMandat = piNumeroMandat
    .
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then return.

    case ctrat.ntcon:
        when {&NATURECONTRAT-mandatAvecIndivision} or when {&NATURECONTRAT-mandatLocationIndivision} then run Indivision.
        otherwise run SansIndivision.
    end case.
    run edite_log.

end procedure.
    
procedure SansIndivision private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : 
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpidt = {&TYPEROLE-mandant}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = giNumeroMandat:
        create ttTantiemeMandat.
        assign 
            ttTantiemeMandat.iNoBranche         = 1
            ttTantiemeMandat.iRang              = 1
            ttTantiemeMandat.iNoLigne           = 1
            ttTantiemeMandat.iNumeroIndivisaire = intnt.noidt
            ttTantiemeMandat.iMdt               = giNumeroMandat
            ttTantiemeMandat.iIndivision        = 0
            ttTantiemeMandat.iIndivisionSuivant = 0
            ttTantiemeMandat.inum_reel          = 100 /** intnt.nbnum **/
            ttTantiemeMandat.iden_reel          = 100 /** intnt.nbden **/
            ttTantiemeMandat.inum[1]            = ttTantiemeMandat.inum_reel /** intnt.nbnum **/
            ttTantiemeMandat.iden[1]            = ttTantiemeMandat.iden_reel /** intnt.nbden **/   
            ttTantiemeMandat.iNumTot_reel       = ttTantiemeMandat.inum_reel /** intnt.nbnum **/
            ttTantiemeMandat.iDenTot_reel       = ttTantiemeMandat.iden_reel /** intnt.nbden **/            
            ttTantiemeMandat.lib_calcul         = ""
        .
    end.

end procedure.

procedure Indivision private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : 
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpidt = {&TYPEROLE-mandant}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = giNumeroMandat:
        run chgTabInd(intnt.idsui).
    end.

end procedure.

procedure edite_log private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : 
    ------------------------------------------------------------------------------*/
    define variable vdeTotalIndivisaire as decimal   no-undo.
    define variable vdeTotalIndivision  as decimal   no-undo.
    define variable viTotalBranche      as integer   no-undo.
    define variable viNombreBranche     as integer   no-undo.
    define variable vi                  as integer   no-undo.
    define variable vdeTotalTantieme    as decimal   no-undo.

    define buffer vbttTantiemeMandat        for ttTantiemeMandat.
    define buffer vbttIndivisionIndivisaire for ttIndivisionIndivisaire.

    output to value ("c:~\tmp~\indivisions_bat.01").  // todo  gga remplacer par repgi...
    put unformatted 
        " MANDAT : " giNumeroMandat skip
        " " skip
        " LISTE DES LIENS INDIVISIONS-INDIVISAIRES" skip 
        " " skip
    .
    for each ttLienIndivisionIndivisaire:
        put unformatted 
            ttLienIndivisionIndivisaire.iNumeroIndivision " " ttLienIndivisionIndivisaire.iNumeroIndivisaire skip
        .
    end.
    put unformatted skip
        " LISTE DES INDIVISIONS" skip
        " " skip.
    for each ttIndivisionIndivisaire
        by ttIndivisionIndivisaire.iNumeroLigne:
        if ttIndivisionIndivisaire.iNumeroRang = 1
        then assign 
            viNombreBranche = viNombreBranche + 1
            viTotalBranche  = ttIndivisionIndivisaire.iTotalTantiemesIndivision
        .
        create ttTantiemeMandat.
        assign
            ttTantiemeMandat.iNoBranche         = viNombreBranche
            ttTantiemeMandat.iRang              = ttIndivisionIndivisaire.iNumeroRang
            ttTantiemeMandat.iNoLigne           = ttIndivisionIndivisaire.iNumeroLigne
            ttTantiemeMandat.iNumeroIndivisaire = ttIndivisionIndivisaire.iNumeroIndivisaire
            ttTantiemeMandat.iMdt               = giNumeroMandat
            ttTantiemeMandat.iIndivision        = ttIndivisionIndivisaire.iNumeroIndivision
            ttTantiemeMandat.iIndivisionSuivant = ttIndivisionIndivisaire.iNumeroIndivisionSui
            ttTantiemeMandat.iden_reel          = viTotalBranche    
        .
        /** Recherche du niveau sup **/
        if ttTantiemeMandat.iRang = 1 
        then assign 
            ttTantiemeMandat.inum[1] = ttIndivisionIndivisaire.iTantiemesIndivisaire
            ttTantiemeMandat.iden[1] = ttIndivisionIndivisaire.iTotalTantiemesIndivision
        .
        else if ttTantiemeMandat.iRang > 1 
        then do:
            for first vbttTantiemeMandat
                where vbttTantiemeMandat.iIndivisionSuivant = ttTantiemeMandat.iIndivisionSuivant:
                do vi = 1 to ttTantiemeMandat.iRang - 1:
                    assign 
                        ttTantiemeMandat.inum[vi] = vbttTantiemeMandat.inum[vi]
                        ttTantiemeMandat.iden[vi] = vbttTantiemeMandat.iden[vi]
                    .
                end.
            end.
            assign 
                ttTantiemeMandat.inum[ttTantiemeMandat.iRang] = ttIndivisionIndivisaire.iTantiemesIndivisaire
                ttTantiemeMandat.iden[ttTantiemeMandat.iRang] = ttIndivisionIndivisaire.iTotalTantiemesIndivision
            .                
        end.
        /** Calcul du tantième réel **/
        ttTantiemeMandat.inum_reel = ttTantiemeMandat.iden_reel.
        do vi = 1 to ttTantiemeMandat.iRang:
            ttTantiemeMandat.inum_reel = if ttTantiemeMandat.inum_reel <> ttTantiemeMandat.iden[vi] 
                                         then ttTantiemeMandat.inum_reel * (ttTantiemeMandat.inum[vi] / ttTantiemeMandat.iden[vi])
                                         else ttTantiemeMandat.inum[vi].
        end.
        if ttTantiemeMandat.inum_reel = ? then ttTantiemeMandat.inum_reel = 0.
        /** Libelle de justification du calcul **/
        /** ttTantiemeMandat.lib_calcul = STRING (ttTantiemeMandat.iden_reel).  **/
        do vi = 1 to ttTantiemeMandat.iRang:
            if ttTantiemeMandat.lib_calcul > ""
            then ttTantiemeMandat.lib_calcul = ttTantiemeMandat.lib_calcul + " * ".
            ttTantiemeMandat.lib_calcul = ttTantiemeMandat.lib_calcul
                                        + string(ttTantiemeMandat.inum[vi]) + "/" + string(ttTantiemeMandat.iden[vi]).
        end. 
        /** EXISTE-T-IL DES SOUS-INDIVISIONS ? Si OUI le tantième réel sera zéro **/                
        if ttIndivisionIndivisaire.iNumeroIndivisionSui <> 0 
        then for first vbttIndivisionIndivisaire
            where vbttIndivisionIndivisaire.iNumeroIndivision     = ttIndivisionIndivisaire.iNumeroIndivisionSui  
              and vbttIndivisionIndivisaire.iTantiemesIndivisaire <> 0
              and vbttIndivisionIndivisaire.cTpIndivision         = {&TYPEROLE-coIndivisaire}:
            ttTantiemeMandat.inum_reel = 0.
        end.
        put unformatted skip
            "BRANCHE : " viNombreBranche                      format ">>>>9"      " "
            ttIndivisionIndivisaire.iNumeroLigne              format ">>>>9"      " "
            ttIndivisionIndivisaire.iNumeroRang               format "99"         " "
            ttIndivisionIndivisaire.iNumeroIndivisionSui      format ">>>>9"      " "
            ttIndivisionIndivisaire.iNumeroIndivision         format ">>>>9"      " "
            ttIndivisionIndivisaire.cLibelleIndivision        format "x(50)"      " "
            ttIndivisionIndivisaire.iNumeroIndivisaire        format "99999"      " "
            ttIndivisionIndivisaire.iNumeroTiersIndivisaire   format "999999"     " "
            ttIndivisionIndivisaire.cNomIndivisaire           format "x(50)"      " "
            ttIndivisionIndivisaire.iTantiemesIndivisaire     format "9999999999" " "
            ttIndivisionIndivisaire.iTotalTantiemesIndivision format "9999999999"
            skip
            "   TANTIEMES REELS : " ttTantiemeMandat.inum_reel " / " ttTantiemeMandat.iden_reel 
            skip 
            "   TANTIEMES DETAILLES : "
            ttTantiemeMandat.iden_reel
        .
        do vi = 1 to ttTantiemeMandat.iRang:
            put unformatted 
                " * ( " ttTantiemeMandat.inum[vi] " / " ttTantiemeMandat.iden[vi] " )"
            .
        end.
    end.
    put unformatted skip
        " " skip
        " SOMME DES TANTIEMES REELS " skip 
        " " skip
    .
    vdeTotalTantieme = 0.
    for each ttTantiemeMandat 
        where ttTantiemeMandat.imdt = giNumeroMandat 
        by ttTantiemeMandat.inoligne:
        vdeTotalTantieme = vdeTotalTantieme + ttTantiemeMandat.inum_reel.
        put unformatted skip
            "INDIVISAIRE : " ttTantiemeMandat.iNumeroIndivisaire 
            " REEL : " ttTantiemeMandat.inum_reel format ">,>>>,>>>,>>9.99" " / " ttTantiemeMandat.iden_reel format ">,>>>,>>>,>>9.99"
            " DETAIL : " ttTantiemeMandat.lib_calcul
        .
    end.
    vdeTotalTantieme = truncate(vdeTotalTantieme, 2).
    put unformatted skip
        "TOTAL TANTIEMES : " vdeTotalTantieme format ">,>>>,>>>,>>9.99"
    .
    for each ttTantiemeMandat 
        where ttTantiemeMandat.imdt = giNumeroMandat:
        assign 
            ttTantiemeMandat.iNumTot_reel = vdeTotalTantieme
            ttTantiemeMandat.iDenTot_reel = ttTantiemeMandat.iDen_reel
        .
    end.
    put unformatted skip
        " " skip
        " LISTE DES TANTIEMES PAR INDIVSIONS " skip 
        " " skip
    .
    for each ttLienIndivisionIndivisaire 
        break by ttLienIndivisionIndivisaire.iNumeroIndivision:

        if first-of (ttLienIndivisionIndivisaire.iNumeroIndivision) then do:
            put unformatted skip
                "INDIVISION : " ttLienIndivisionIndivisaire.iNumeroIndivision
            .
            assign 
                vdeTotalIndivisaire = 0
                vdeTotalIndivision  = 0
            .
        end.
        for each ttIndivisionIndivisaire 
           where ttIndivisionIndivisaire.iNumeroIndivision = ttLienIndivisionIndivisaire.iNumeroIndivision:
            put unformatted skip  
                "   --> INDIVISAIRE : " 
                ttIndivisionIndivisaire.iNumeroIndivisaire                              
                " TANTIEME : " 
                ttIndivisionIndivisaire.iTantiemesIndivisaire      format "9999999999" " " 
                ttIndivisionIndivisaire.iTotalTantiemesIndivision  format "9999999999"
            .  
            assign
                vdeTotalIndivisaire = vdeTotalIndivisaire + ttIndivisionIndivisaire.iTantiemesIndivisaire
                vdeTotalIndivision  = ttIndivisionIndivisaire.iTotalTantiemesIndivision
            .
        end.

        if last-of (ttLienIndivisionIndivisaire.iNumeroIndivision) 
        then put unformatted skip 
                 "       TOTAL INDIVISION : " 
                 vdeTotalIndivisaire format "9999999999" " " 
                 vdeTotalIndivision  format "9999999999"
        .
    end.
    put unformatted skip
        " " skip
    .
    output close.

end procedure.

procedure ChgTabInd private:
    /*------------------------------------------------------------------------------
    purpose: Procedure de chargement de la table temporaire
    Note   : 
    ------------------------------------------------------------------------------*/
    define input parameter piIdentifiantSuivant as integer no-undo.

    define buffer intnt for intnt.

    /** CHARGEMENT DU LIEN N° INDIVISION ET N° INDIVISAIRE PRINCIPAL **/
    for each intnt no-lock
        where intnt.tpidt = {&TYPEROLE-coIndivisaire}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = giNumeroMandat:
        create ttLienIndivisionIndivisaire.
        assign 
            ttLienIndivisionIndivisaire.iNumeroIndivision  = (if glIndivSucc then intnt.idsui else 0)
            ttLienIndivisionIndivisaire.iNumeroIndivisaire = intnt.noidt
        .
    end.
    /** CHARGEMENT DE L'ARBORESCENCE **/
    run chgIndSui(1, if glIndivSucc then piIdentifiantSuivant else 0).

end procedure.

procedure ChgIndSui private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : 
    ------------------------------------------------------------------------------*/
    define input parameter  piNumeroRang      as integer no-undo.
    define input parameter  piIdentifiantPrec as integer no-undo.
    
    define buffer intnt for intnt.
    
    for each intnt no-lock
        where intnt.tpidt = {&TYPEROLE-coIndivisaire}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = giNumeroMandat
          and intnt.idpre = piIdentifiantPrec:
        /* on est sur le dernier niveau ou bien on a fini de traiter le niveau suivant */
        run CreTabInd(buffer intnt, piNumeroRang). 
        /* on descend la chaine des indivision si nécessaire */
        if glIndivSucc and intnt.idsui <> 0 then run chgIndSui(piNumeroRang + 1, intnt.idsui).
    end.
end procedure.

procedure CreTabInd private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : 
    ------------------------------------------------------------------------------*/    
    define parameter buffer intnt for intnt.
    define input parameter piNumeroRang as integer no-undo.

    define variable viNumeroIndivisaire as integer no-undo.

    /* Nom de l'indivision */
    for first ttLienIndivisionIndivisaire 
        where ttLienIndivisionIndivisaire.iNumeroIndivision = intnt.idpre:
        viNumeroIndivisaire = ttLienIndivisionIndivisaire.iNumeroIndivisaire.
    end.
    /* Création enregistrement dans table du Browse */
    create ttIndivisionIndivisaire.
    assign  
        giNiveau = giNiveau + 10
        ttIndivisionIndivisaire.iNumeroLigne              = giNiveau
        ttIndivisionIndivisaire.iNumeroRang               = piNumeroRang
        ttIndivisionIndivisaire.iNumeroIndivisionSui      = intnt.idsui
        ttIndivisionIndivisaire.iNumeroIndivision         = intnt.idpre
        ttIndivisionIndivisaire.cLibelleIndivision        = fill ("-",(piNumeroRang - 1) * 3 ) + 
                                                            (if piNumeroRang <> 1 then ">" else "") + 
                                                            DonneNomRole({&TYPEROLE-mandant}, viNumeroIndivisaire)
        ttIndivisionIndivisaire.iNumeroIndivisaire        = intnt.noidt
        ttIndivisionIndivisaire.cTpIndivision             = intnt.tpidt
        ttIndivisionIndivisaire.iNumeroTiersIndivisaire   = DonneTiersRole(intnt.tpidt, intnt.noidt)
        ttIndivisionIndivisaire.cNomIndivisaire           = DonneNomRole(intnt.tpidt, intnt.noidt)
        ttIndivisionIndivisaire.iTantiemesIndivisaire     = (if intnt.tpidt = {&TYPEROLE-coIndivisaire} then intnt.nbnum else 0)        
        ttIndivisionIndivisaire.iTotalTantiemesIndivision = intnt.nbden
    .

end procedure.
