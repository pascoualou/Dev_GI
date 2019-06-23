/*------------------------------------------------------------------------
File        : majCpt.p
Purpose     : creation de compte
Author(s)   : 28/03/1997 PB - GGA 2018/03/30
Notes       : a partir de cadb/gestion/majcpt.p

Historique des modifications 
001  06/05/97     CD   ajout du Numerateur et denominateur         
                       parcour de tous les collectifs              
002  26/06/97     PZ   maj du Numerateur et denominateur           
003  17/07/97     PB   maj mode de règlement                       
004  28/08/97     SK   maj ccpt.fg-mandat                          
005  09/01/98     PB   Problème LOCK                               
006  25/05/98     CD   Maj lib indivisaire qd modif lib mandant    
007  23/11/98     OF   Gestion du multi-utilisateur                
008  13/04/99     JR   Création du Fr0 00000 pour chaque création  
                       de mandat                                   
009  04/10/99     JR   Modif sur la requete de actrc pour rapidité 
010  10/01/01     MP   Fiche 0101/0104: Modif ne concernant que le  
                       client Réside Etudes (3025), création du     
                       compte LH 99999 lors de la création du mandat
011  05/03/01     CC   Optimisation                                 
012  26/09/01     NP   Correction modif ne concernant que le        
                       client Réside Etudes (3025): création du     
                       compte LH 99999 lors de la création du mandat
013  25/07/03     PS   FR1, FR2 abscent sur les mandats nouveaux    
                       fiche 0703/0366                              
014  07/02/05     DM   1104/0129:Rajout creation FSxx 00000         
015  31/06/05     RF   0904/0105:Assignation de l'adresse/cp/ville  
                       en creation/mod des csscpt de type           
                       copropriétaire/locataire/mandat              
0016 16/09/2008   SY   0608/0065 Gestion mandats 5 chiffres         
0017 12/11/2010   SY   1110/0056  Mutation gérance/mandat provisoire
                       les mandats provisoires ne doivent pas aller 
                       en compta (suite fiche 0706/0018)            
0018 26/09/2014   SY   Ajout Mlog pour trace Maj compta             
0019 19/05/2017   OF   #2795 Création compte FTA 00000              
0020 06/11/2017   SY   #8575 MANPOWER V17.00 Pb available actrc     
+--------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/referenceClient.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define temp-table ttParamCompte no-undo
    field iCodeSoc       as integer
    field cTypeContrat   as character 
    field iCodeEtab      as int64
    field cTypeRole      as character
    field iNumeroRole    as int64
    field cNomRole       as character
    field iNumerateur    as integer
    field iDenominateur  as integer
    field cModeReglement as character
.

procedure createCompte:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttParamCompte.
    define output parameter piRetour as integer no-undo.

    define variable vrRccpt     as rowid     no-undo.
    define variable viTypeCd    as integer   no-undo.
    define variable vlFgConf    as logical   no-undo.
    define variable vlFgTiers   as logical   no-undo.
    define variable vlExiste    as logical   no-undo.
    define variable vcSscollCpt as character no-undo.
    define variable viCodeTaxe  as integer   no-undo.
    define variable cErr        as character no-undo. 
    define variable cInfosAdr   as character no-undo.
    define variable vcCodeindi  as character no-undo.
    define variable vcCodeRole  as character no-undo.

    define buffer ctrat       for ctrat.
    define buffer aparm       for aparm.
    define buffer ccptcol     for ccptcol.
    define buffer csscptcol   for csscptcol.
    define buffer actrc       for actrc. 
    define buffer ccpt        for ccpt.
    define buffer ietab       for ietab.
    define buffer vbcsscpt    for csscpt.
    define buffer vbcsscptcol for csscptcol.

message "createCompte ". 

    /* Lecture du parametre d'entree */
    find first ttParamCompte no-error.
    if not available ttParamCompte then do:
        piRetour = 3.
        return.
    end.
    assign 
        vcCodeindi = string(ttParamCompte.iNumeroRole, "99999")
        vcCodeRole = (if ttParamCompte.cTypeRole = {&TYPEROLE-mandant}
                      then "00000"
                      else string(ttParamCompte.iNumeroRole, "99999"))
    .
    find first ctrat no-lock
         where ctrat.tpcon = ttParamCompte.cTypeContrat
           and ctrat.nocon = ttParamCompte.iCodeEtab no-error.
    if available ctrat and ctrat.fgprov
    then do:
        piRetour = 0.
        return.
    end.
    find first ietab no-lock 
         where ietab.soc-cd  = ttParamCompte.iCodeSoc 
           and ietab.etab-cd = ttParamCompte.iCodeEtab no-error.
    if not available ietab       
    then do:
        piRetour = 999.
        return.
    end.
    if ttParamCompte.cTypeRole = {&TYPEROLE-coIndivisaire} 
    then do:
        /* verif denominateur different de zero */
        if ttParamCompte.iDenominateur = 0 
        then do:
            piRetour = 4.
            return.
        end.
        /* Verif mode de règlement */
        if ttParamCompte.cModeReglement = ""
        then do: 
            piRetour = 5.
            return.
        end.
        else do:
            find first aparm no-lock
                 where aparm.tppar   = "TREGP"
                   and aparm.soc-cd  = 0
                   and aparm.etab-cd = 0
                   and aparm.cdpar   = ttParamCompte.cModeRegl no-error.
            if not available aparm 
            then do:
                piRetour = 6.
                return.
            end.
        end.
    end.
    /* Recherche du regroupement */
    find first ccptcol no-lock
         where ccptcol.soc-cd = ttParamCompte.iCodeSoc 
           and ccptcol.tprole = integer(ttParamCompte.cTypeRole) no-error.
    if not available ccptcol 
    then do:
        piRetour = 1.
        return.
    end.    
Mlogger:writeLog (0, "maj compte compta : ref " + string(ttParamCompte.iCodeSoc) + " mandat = " + string(ttParamCompte.iCodeEtab) + " type de role = " + string(ttParamCompte.cTypeRole) + " " + ccptcol.coll-cle + " No compte = " + vcCodeRole + " " + ttParamCompte.cNomRole  ).
    /* Recherche de la définition du compte */
    find first csscptcol no-lock 
         where csscptcol.soc-cd   = ttParamCompte.iCodeSoc  
           and csscptcol.coll-cle = ccptcol.coll-cle 
           and csscptcol.etab-cd  = ttParamCompte.iCodeEtab no-error.
    if available csscptcol 
    then vcSscollCpt = csscptcol.sscoll-cpt.
    for first actrc no-lock 
       where actrc.fg-coll-cle 
         and actrc.cptdeb = vcSscollCpt
         and actrc.cptfin >= vcSscollCpt
         and actrc.tprole  = ccptcol.tprole:
        assign 
            viTypeCd  = actrc.type-cd
            vlFgConf  = actrc.fg-conf
            vlFgTiers = actrc.fg-tiers
            vlExiste  = true
        .
    end.                         
    if not vlExiste 
    then for first actrc no-lock
             where actrc.fg-coll-cle 
               and actrc.cptdeb <= vcSscollCpt
               and actrc.cptfin >= vcSscollCpt
               and actrc.tprole = ccptcol.tprole:
        assign 
            viTypeCd  = actrc.type-cd
            vlFgConf  = actrc.fg-conf
            vlFgTiers = actrc.fg-tiers
        . 
    end.
    /* test si existence du compte général */
    find first ccpt exclusive-lock
         where ccpt.soc-cd   = ttParamCompte.iCodeSoc 
           and ccpt.coll-cle = ccptcol.coll-cle 
           and ccpt.cpt-cd   = vcCodeRole no-error.
    if not available ccpt 
    then do:
        viCodeTaxe = 0.
        if ccptcol.libcat-cd = 2 
        then for first itaxe no-lock
                 where itaxe.soc-cd = ttParamCompte.iCodeSoc 
                   and itaxe.port-emb:
            viCodeTaxe = itaxe.taxe-cd.
        end.
        create ccpt.
        assign
            ccpt.soc-cd      = ttParamCompte.iCodeSoc
            ccpt.etab-cd     = 0
            ccpt.cpt-cd      = vcCodeRole
            ccpt.libtype-cd  = ccptcol.libtype-cd
            ccpt.centra      = ccptcol.centra
            ccpt.libcat-cd   = ccptcol.libcat-cd
            ccpt.cptaffect   = ccptcol.cptaffect
            ccpt.tva-oblig   = false
            ccpt.cptprov-num = ccptcol.cptprov-num
            ccpt.cpt-int     = ccptcol.coll-cle + vcCodeRole
            ccpt.coll-cle    = ccptcol.coll-cle
            ccpt.taxe-cd     = viCodeTaxe
            ccpt.libimp-cd   = ccptcol.libimp-cd
            ccpt.libsens-cd  = ccptcol.libsens-cd
            ccpt.type-cd     = viTypeCd  /* actrc.type-cd */
            ccpt.fg-conf     = vlFgConf  /* actrc.fg-conf */
            ccpt.fg-tiers    = vlFgTiers /* actrc.fg-tiers */
            ccpt.sscpt-cd    = vcCodeRole
            ccpt.fg-libsoc   = ccptcol.fg-libsoc
            ccpt.fg-mandat   = ccptcol.fg-mandat
            vrRccpt         = rowid(ccpt)
        .
    end.
    else vrRccpt = rowid(ccpt).
    /* Recherche des collectifs lies au regroupement */
    for each csscptcol no-lock
       where csscptcol.soc-cd   = ttParamCompte.iCodeSoc  
         and csscptcol.etab-cd  = ttParamCompte.iCodeEtab 
         and csscptcol.coll-cle = ccptcol.coll-cle:
        /* test si existence du compte individuel */
        find first csscpt exclusive-lock
             where csscpt.soc-cd     = ttParamCompte.iCodeSoc 
               and csscpt.etab-cd    = ttParamCompte.iCodeEtab 
               and csscpt.coll-cle   = csscptcol.coll-cle 
               and csscpt.sscoll-cle = csscptcol.sscoll-cle 
               and csscpt.cpt-cd     = vcCodeRole no-error.
        if not available csscpt 
        then do:
            create csscpt.
            assign
                csscpt.soc-cd     = ttParamCompte.iCodeSoc
                csscpt.etab-cd    = ttParamCompte.iCodeEtab
                csscpt.sscoll-cle = csscptcol.sscoll-cle
                csscpt.cpt-cd     = vcCodeRole
                csscpt.cpt-int    = csscptcol.sscoll-cpt + vcCodeRole
                csscpt.coll-cle   = csscptcol.coll-cle
                csscpt.facturable = csscptcol.facturable
                csscpt.douteux    = csscptcol.douteux
            .
        end.
        /* Mise à jour numérateur, dénominateur et du mode de règlement */
        assign 
            csscpt.numerateur   = ttParamCompte.iNumerateur
            csscpt.denominateur = ttParamCompte.iDenominateur
            csscpt.regl-cd      = if available aparm then aparm.zone1 else 0  
        .
        
        
message "creation csscpt " csscpt.soc-cd "//" csscpt.etab-cd "//" csscpt.sscoll-cle "//" csscpt.cpt-cd "//" csscpt.cpt-int "//"  csscpt.numerateur.      
        
        /* RF - 31/05/05 - 0904/0105 chargement adresse */
        if ccptcol.libtier-cd = 1
        and ccptcol.tprole <> integer({&TYPEROLE-coIndivisaire}) /* indivisaires non traités */
        then do:
//gga todo pour l'instant reprise de adb/cpta/chgadr01.p avec le minimum de modification  
        run adb/cpta/chgadr01.p (mtoken:iCodeLangueSession,
                                 "",
                                 ttParamCompte.iCodeSoc,
                                 ttParamCompte.iCodeEtab,
                                 string(ccptcol.tprole,"99999"),
                                 if ccptcol.tprole = integer({&TYPEROLE-locataire}) /* locataire */
                                                     then string(ietab.etab-cd,"99999") + csscpt.cpt-cd
                                                     else csscpt.cpt-cd,                                                     
                                 output cErr,
                                 output cInfosAdr). 
            if num-entries(cInfosAdr,"¤") >= 5
            then assign
                     csscpt.adr   = entry(2,cInfosAdr,"¤")
                     csscpt.cp    = entry(4,cInfosAdr,"¤")
                     csscpt.ville = entry(5,cInfosAdr,"¤")
            .
            else assign
                     csscpt.adr   = ""
                     csscpt.cp    = ""
                     csscpt.ville = ""
            .
        end.
        if csscptcol.sscoll-cle begins "FR" 
        or csscptcol.sscoll-cle begins "FS" /* DM 1104/0129 */
        or csscptcol.sscoll-cle = "FTA" /**Ajout OF le 19/05/17**/
        then do:
            if not can-find(first vbcsscpt no-lock
                            where vbcsscpt.soc-cd     = ttParamCompte.iCodeSoc 
                              and vbcsscpt.etab-cd    = ttParamCompte.iCodeEtab 
                              and vbcsscpt.coll-cle   = csscptcol.coll-cle 
                              and vbcsscpt.sscoll-cle = csscptcol.sscoll-cle 
                              and vbcsscpt.cpt-cd     = "00000")
            then do:
                create vbcsscpt.
                buffer-copy csscpt to vbcsscpt
                assign 
                    vbcsscpt.cpt-cd     = "00000"
                    vbcsscpt.cpt-int    = csscptcol.sscoll-cpt + vbcsscpt.cpt-cd
                    vbcsscpt.lib        = ietab.nom
                .
                if not can-find(first ccpt no-lock
                                where ccpt.soc-cd    = ttParamCompte.iCodeSoc    
                                  and ccpt.coll-cle  = vbcsscpt.coll-cle
                                  and ccpt.cpt-cd    = vbcsscpt.cpt-cd)
                then do:
                    create ccpt.
                    assign 
                        ccpt.soc-cd     = ttParamCompte.iCodeSoc
                        ccpt.etab-cd    = 0
                        ccpt.coll-cle   = vbcsscpt.coll-cle
                        ccpt.cpt-cd     = vbcsscpt.cpt-cd
                        ccpt.cpt-int    = csscptcol.coll-cle + ccpt.cpt-cd
                        ccpt.sscpt-cd   = vbcsscpt.cpt-cd
                        ccpt.lib        = vbcsscpt.lib
                        ccpt.libimp-cd  = 2
                        ccpt.libcat-cd  = 4
                        ccpt.libtype-cd = 1
                        ccpt.libsens-cd = 3
                    .
                end.   
            end.
        end.
    end.

    /* Mise à jour des libellés */
    for first ccpt exclusive-lock
        where rowid(ccpt) = vrRccpt:
        ccpt.lib = (if ccptcol.fg-libsoc then ttParamCompte.cNomRole else "").
    end.     
    run majLibCsscpt (buffer ccptcol, ttParamCompte.iCodeEtab, vcCodeRole, ttParamCompte.cNomRole).          

    /*** CD le 25/05/98 ***/
    if ttParamCompte.cTypeRole = {&TYPEROLE-mandant} 
    then do:
        find first ccptcol no-lock
             where ccptcol.soc-cd = ttParamCompte.iCodeSoc 
               and ccptcol.tprole = integer({&TYPEROLE-coIndivisaire}) no-error.
        if not available ccptcol then return.
        /* Mise à jour des libellés */
        for first ccpt exclusive-lock
            where ccpt.soc-cd   = ttParamCompte.iCodeSoc
              and ccpt.coll-cle = ccptcol.coll-cle
              and ccpt.cpt-cd   = vcCodeindi:
             ccpt.lib = (if ccptcol.fg-libsoc then ttParamCompte.cNomRole else "").
        end.        
        run majLibCsscpt (buffer ccptcol, ttParamCompte.iCodeEtab, vcCodeindi, ttParamCompte.cNomRole).          
    end.
    /*** Fin modif CD le 25/05/98 ***/

    /** MP le 10/01/01 Création du compte LH 99999 pour client Réside Etudes seulement **/
    if ttParamCompte.iCodeSoc = {&REFCLIENT-03025} 
    then do:
        if not can-find(first csscptcol no-lock 
                        where csscptcol.soc-cd     = ttParamCompte.iCodeSoc        /* NP deb add 26/09/01 0901/0286 */
                          and csscptcol.etab-cd    = ttParamCompte.iCodeEtab 
                           and csscptcol.sscoll-cle = "LH")
        then do:
            for first vbcsscptcol no-lock  
                where vbcsscptcol.soc-cd     = ttParamCompte.iCodeSoc
                  and vbcsscptcol.sscoll-cle = "LH":
                create csscptcol.
                buffer-copy vbcsscptcol to csscptcol
                      assign
                          csscptcol.etab-cd = ttParamCompte.iCodeEtab
                .
            end.
        end.      
        if not can-find(first csscpt no-lock  
                        where csscpt.soc-cd     = ttParamCompte.iCodeSoc
                          and csscpt.etab-cd    = ttParamCompte.iCodeEtab
                          and csscpt.sscoll-cle = "LH"
                          and csscpt.cpt-cd     = "99999")
        then do:
            for first vbcsscpt no-lock  
                where vbcsscpt.soc-cd     = ttParamCompte.iCodeSoc
                  and vbcsscpt.sscoll-cle = "LH"
                  and vbcsscpt.cpt-cd     = "99999"
                  and vbcsscpt.lib begins "REPORTS":
                create csscpt.
                buffer-copy vbcsscpt to csscpt
                      assign
                          csscpt.etab-cd = ttParamCompte.iCodeEtab
                .
            end.
        end.
    end.
    /** fin modif MP **/

    piRetour = 0.

end procedure.

procedure majLibCsscpt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ccptcol for ccptcol.
    define input parameter piEtabCd as integer   no-undo.
    define input parameter pcCptCd  as character no-undo.
    define input parameter pcLib    as character no-undo.
    
    define buffer csscpt for csscpt.

    /* si le libellé est unique au niveau de la société */
    if ccptcol.fg-libsoc 
    then for each csscpt exclusive-lock
            where csscpt.soc-cd   = ccptcol.soc-cd
              and csscpt.coll-cle = ccptcol.coll-cle
              and csscpt.cpt-cd   = pcCptCd:
            csscpt.lib = pcLib.
    end.
    else for each csscpt exclusive-lock
            where csscpt.soc-cd   = ccptcol.soc-cd
              and csscpt.etab-cd  = piEtabCd
              and csscpt.coll-cle = ccptcol.coll-cle
              and csscpt.cpt-cd   = pcCptCd:
            csscpt.lib = pcLib.
    end.

end procedure.
