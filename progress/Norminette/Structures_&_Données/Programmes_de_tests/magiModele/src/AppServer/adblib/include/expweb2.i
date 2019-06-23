/*------------------------------------------------------------------------
File        : expweb2.i
Purpose     : procédures communes aux exports vers GINET-DATA
Author(s)   : DM 0412/0084  2012/01/02 - GGA 2017/10/20
Notes       : reprise comm\expweb.i2
----------------------------------------------------------------------*/
/*
01  | 29/12/2014 | OF  | Pb filtre résilié dans le cas d'une indivision
02  | 03/02/2015 | DM  | 0115/0253 Tiers representés
03  | 30/11/2015 | DM  | 1015/0196 Exporter tous les locataires meme resiliés pour la vue proprietaire
04  | 09/02/2016 | DM  | 0216/0037 Manque des immeubles dans l'export
05  | 10/05/2016 | OF  | 0316/0221 Export salariés Pégase
06  | 15/06/2016 | OF  | 0616/0089 Export gardiens externes
07  | 04/04/2017 | DM  | bctrat not available
08  | 06/07/2017 | DM  | #4629 jour non valide
*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
define temp-table tmp-95 no-undo
    field etab-cd as integer   format /* DM 0608/0065 "9999" */ "99999"
    field nom     as character format "X(60)"
    field actif   as logical   format "X/"
    field fgLRE   as logical   format "X/"
    index etab-cd-i is primary unique etab-cd.

define temp-table TbTiersRep no-undo
    field notie as integer
    index idx1 notie.

function f_tiers_rep returns logical (piNoTie as integer): /* DM 0115/0253 */
    /*------------------------------------------------------------------------------
    Purpose:  
    Notes  :
    ------------------------------------------------------------------------------*/
    return can-find(first TbTiersRep where TbTiersRep.notie = piNoTie).

end function. 

function f_AjtMois returns date(piNbMois as integer, pdaValDate as date):
    /*------------------------------------------------------------------------------
    Purpose:  
    Notes  : A supprimer - add-interval(pdaValDate, piNbMois, "month") fait las même chose !!!!
    ------------------------------------------------------------------------------*/
    return add-interval(pdaValDate, piNbMois, "month").
end function.

function f_datefin returns date (pdaDateRes-In as date, piNbMois-In as integer, piJour-In as integer, piMois-In as integer):
    /*------------------------------------------------------------------------------
    Purpose:  
    Notes  :
    ------------------------------------------------------------------------------*/
   if pdaDateRes-In <> ?
   then if piNbMois-In <> ? 
        then return add-interval(date(month(pdaDateRes-In), 1, year(pdaDateRes-In)), piNbMois-In + 1, "month") - 1.
        else if piJour-In <> ? and piMois-In <> ? 
             then return if piJour-In >= 28
                         then add-interval(date(piMois-In, 1, year(pdaDateRes-In) + 1), 1, "month") - 1 /* dernier jour du mois année suivante */
                         else date(piMois-In, piJour-In, year(pdaDateRes-In) + 1).                      /* Mois année suivante                 */
   return pdaDateRes-In.
end function.

function f_ctratactiv returns character (prRowIN as rowid):
    /*------------------------------------------------------------------------------
    Purpose:  
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vlActif          as logical   no-undo.
    define variable vcDate           as character no-undo.
    define variable vcActif          as character no-undo.
    define variable vcAcces          as character no-undo.
    define variable vdaDesactivation as date      no-undo.
    define variable viTmp            as integer   no-undo.
    define variable viInt            as integer   no-undo. /* 0216/0037 */
    define variable vDateRes         as date      no-undo.
    define variable vDateFin         as date      no-undo.
    define variable vcResi           as character no-undo.
    define variable viNbMoisCop      as integer   no-undo initial ?.
    define variable viJourCop        as integer   no-undo initial ?.
    define variable viMoisCop        as integer   no-undo initial ?.
    define variable viNbMoisLoc      as integer   no-undo initial ?.
    define variable viJourLoc        as integer   no-undo initial ?.
    define variable viMoisLoc        as integer   no-undo initial ?.
    define variable viNbMoisProp     as integer   no-undo initial ?.
    define variable viJourProp       as integer   no-undo initial ?.
    define variable viMoisProp       as integer   no-undo initial ?.
    define variable vdaTemp          as date      no-undo.
    define variable viNumeroMandat   as integer   no-undo.
    
    define buffer ctrat   for ctrat.
    define buffer aparm   for aparm.
    define buffer vbroles for roles.
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    define buffer tiers   for tiers.
    define buffer vbctrat for ctrat.
    define buffer tache   for tache.

    /* Prise en compte des résiliés */

    /* Param Copro */
    for first aparm no-lock
        where aparm.tppar   = "TWEB" 
          and aparm.cdpar   = "PARAMCOPRO" 
          and aparm.soc-cd  = 0 
          and aparm.etab-cd = 0
          and num-entries(aparm.zone2, "|") >= 6:  
        if entry(5, aparm.zone2, "|") = "D" 
        then assign                                                            /* C'est une date */
            vcResi      = entry(6, aparm.zone2, "|")
            viJourCop   = maximum(minimum(integer(entry(1, vcResi)), 28), 1)
            viMoisCop   = maximum(minimum(integer(entry(2, vcResi)), 12), 1)
        .
        else viNbMoisCop = integer(entry(6, aparm.zone2, "|")).                /* C'est un nombre de mois */
    end.
    /* Param propriétaire: les locataires résiliés sont-ils exportés ? */
    for first aparm no-lock
        where aparm.tppar   = "TWEB"
          and aparm.cdpar   = "PARAMPROP"
          and aparm.soc-cd  = 0
          and aparm.etab-cd = 0
          and num-entries(aparm.zone2, "|") >= 13: 
        if entry(12, aparm.zone2, "|") = "D" 
        then assign                                                            /* C'est une date */
            vcResi     = entry(13, aparm.zone2, "|")
            viJourProp = maximum(minimum(integer(entry(1, vcResi)), 28), 1)
            viMoisProp = maximum(minimum(integer(entry(2, vcResi)), 12), 1)
        .
        else viNbMoisProp = integer(entry(13, aparm.zone2, "|")).              /* C'est un nombre de mois */
    end.
    /* Param locataire: les locataires résiliés sont-ils exportés ? */
    for first aparm no-lock
        where aparm.tppar = "TWEB" 
        and aparm.cdpar   = "PARAMLOC" 
        and aparm.soc-cd  = 0 
        and aparm.etab-cd = 0
        and num-entries(aparm.zone2, "|") >= 10:
        if entry(9, aparm.zone2, "|") = "D" 
        then assign                                                            /* C'est une date */
            vcResi = entry(10, aparm.zone2, "|")
            viJourLoc = maximum(minimum(integer(entry(1, vcResi)), 28), 1)
            viMoisLoc = maximum(minimum(integer(entry(2, vcResi)), 12), 1)
        .
        else viNbMoisLoc = integer(entry(10, aparm.zone2, "|")).               /* C'est un nombre de mois */
    end.
    find first intnt no-lock 
        where rowid(intnt) = prRowIN no-error.
    if available intnt then do:                                                            /* C'est un indivisaire */    
        find first ctrat no-lock 
             where ctrat.tpcon = intnt.tpcon 
               and ctrat.nocon = intnt.nocon no-error.
        if available ctrat then vDateRes = ctrat.dtree.                                     /**Ajout OF le 29/12/14**/
        find first vbroles no-lock  
             where vbroles.tprol = intnt.tpidt
               and vbroles.norol = intnt.noidt no-error.
        if not available vbroles then return "".

        find first tiers no-lock 
             where tiers.notie = vbroles.notie no-error.
        if not available tiers then return "".
    end.
    else do:
        find first ctrat no-lock 
            where rowid(ctrat) = prRowIN no-error.
        if available ctrat 
        then do:
            vDateRes = ctrat.dtree.
            find first vbroles no-lock 
                 where vbroles.tprol = ctrat.tprol 
                   and vbroles.norol = ctrat.norol no-error.
            if not available vbroles then return "".

            find first tiers no-lock 
                where tiers.notie = vbroles.notie no-error.
            if not available tiers then return "".
        end.
        /**Ajout OF le 15/06/16 - Pour gardiens externes (pas de CTRAT -> stocké dans TACHE)**/
        else do:
            find first tache no-lock 
                where rowid(tache) = prRowIN no-error.
            if available tache 
            then do:
                vDateRes = tache.dtree.        
                find first vbroles no-lock 
                    where vbroles.tprol = tache.tprol 
                      and vbroles.norol = tache.norol no-error.
                if not available vbroles then return "".

                find first tiers no-lock 
                    where tiers.notie = vbroles.notie no-error.
                if not available tiers then return "".
            end.
        end.
    end.
    if available ctrat 
    then do:
        viNumeroMandat = integer(truncate(ctrat.nocon / 100000, 0)).
        if ctrat.tpcon = {&TYPECONTRAT-titre2copro}
        then do:                                                                                  /* Coproprietaire */
            find first tmp-95 
                where tmp-95.etab-cd = viNumeroMandat
                  and tmp-95.actif   = true no-error.
            if not available tmp-95 then return "". /* L'immeuble n'est pas sélectionné */

            /*--> On regarde si le mandat n'est pas résilié */
            find first vbctrat no-lock    
                where vbctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and vbctrat.nocon = viNumeroMandat no-error.
            if available vbctrat and (vbctrat.dtree < vDateRes or vDateRes = ?) 
            then vDateRes = vbctrat.dtree.
            /* Dernier lot du copro ? */
            find first vbintnt no-lock     
                where vbintnt.tpcon = ctrat.tpcon
                  and vbintnt.nocon = ctrat.nocon
                  and vbintnt.tpidt = {&TYPEBIEN-lot}
                  and vbintnt.nbden = 0 no-error.
            if not available vbintnt 
            then for each vbintnt no-lock /* Tous les lots du copros sont vendus -> on recherche la derniere date de vente */                            
                where vbintnt.tpcon = ctrat.tpcon
                  and vbintnt.nocon = ctrat.nocon
                  and vbintnt.tpidt = {&TYPEBIEN-lot}
                by vbintnt.nbden descending:
                assign
                    vcDate  = string(vbintnt.nbden, "99999999")
                    vdaTemp = date(integer(substring(vcDate, 5, 2, "character")),
                                   integer(substring(vcDate, 7, 2, "character")),
                                   integer(substring(vcDate, 1, 4, "character")))
                .
                if vdaTemp <= vDateRes or vDateRes = ? then vDateRes = vdaTemp.
                leave.  // seul le premier enregistrement.
            end.
            /* Prise en compte du paramétrage automatique */
            find first aparm no-lock 
                where aparm.tppar   = "TWEB" 
                  and aparm.cdpar   = "TRSFCOPRO" 
                  and aparm.soc-cd  = 0 
                  and aparm.etab-cd = 0 no-error.
            /* Immeuble activé */
            for first tmp-95 
                where tmp-95.etab-cd = viNumeroMandat:
               if available aparm and aparm.zone2 = "OUI" then vlActif = true. 
            end.
            /* La date de desactivation automatique en fonction de la date de résiliation */
            vDateFin = f_datefin(vDateRes, viNbMoisCop, viJourCop, viMoisCop).
        end.
        else if ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance} 
        then do:                                                                           /* proprietaire */
            /* Prise en compte du paramétrage automatique */
            find first aparm no-lock 
                where aparm.soc-cd  = 0 
                  and aparm.etab-cd = 0 
                  and aparm.tppar   = "TWEB"
                  and aparm.cdpar   = "TRSFPROP" no-error.
            if available aparm and aparm.zone2 = "OUI" then vlActif = true.
            /* La date de desactivation automatique en fonction de la date de résiliation */
            vDateFin = f_datefin(vDateRes, viNbMoisProp, viJourProp, viMoisProp).
        end.
        else if ctrat.tpcon = {&TYPECONTRAT-bail} 
        then do:                                                                           /* locataire */
            find first aparm no-lock  
                where aparm.tppar   = "TWEB" 
                  and aparm.cdpar   = "TRSFLOC" 
                  and aparm.soc-cd  = 0 
                  and aparm.etab-cd = 0 no-error.
            if available aparm and aparm.zone2 = "OUI" then vlActif = true.
            vDateFin = f_datefin(vDateRes,viNbMoisLoc,viJourLoc,viMoisLoc).
        end.
        /**Ajout OF le 10/05/16**/
        else if ctrat.tpcon = {&TYPECONTRAT-SalariePegase} 
        then do:                                                                                  /* salarié */
            find first aparm no-lock 
                where aparm.tppar   = "TWEB" 
                  and aparm.cdpar   = "TRSFSAL" 
                  and aparm.soc-cd  = 0 
                  and aparm.etab-cd = 0 no-error.
            if available aparm and aparm.zone2 = "OUI" then vlActif = true.
            vDateFin = f_datefin(vDateRes, viNbMoisLoc, viJourLoc, viMoisLoc).
        end.
    end.
    /**Ajout OF le 15/06/16**/
    else do:
        find first aparm no-lock 
            where aparm.tppar   = "TWEB" 
              and aparm.cdpar   = "TRSFGAR" 
              and aparm.soc-cd  = 0 
              and aparm.etab-cd = 0 no-error.
        if available aparm and aparm.zone2 = "OUI" then vlActif = true.
        vDateFin = f_datefin(vDateRes, viNbMoisLoc, viJourLoc, viMoisLoc).
    end.
    /* Vérifier si le compte avait été rendu inactif préalablement */
    if available intnt then do:
        if available ctrat                                                      /* DM 04/04/2017 Ajout du if */
        then do viTmp = 1 to num-entries(ctrat.web-div, "@"):
            assign
                vcAcces = entry(viTmp, ctrat.web-div, "@")          /* 1 indivisaire -> "NoIdt:O/N/ :date desact " */
                viInt   = integer(integer(entry(1, vcAcces, ":")))  /* DM 0216/0037 */
            no-error.
            if error-status:error = false and viInt = intnt.noidt       /* DM 0216/0037 */
            then do:
                assign 
                    vdaDesactivation = ? /* DM #4629 ajout no-error */
                    vcActif          = entry(2, vcAcces, ":")
                    vdaDesactivation = date(entry(3, vcAcces, ":"))
                no-error.     /* DM #4629 ajout no-error */
                leave.
            end.
        end.
    end.
    else do:
        if available ctrat
        then assign
            vcActif          = ctrat.web-div
            vdaDesactivation = ctrat.web-datdesact
        .
        /**Ajout OF le 15/06/16**/
        else if available tache 
        then assign
            vcActif          = tache.web-presentation
            vdaDesactivation = tache.dtreg
        .
    end.        

    if vcActif = "O" or f_tiers_rep(tiers.notie) /* DM 0115/0253 */
    then vlActif = true.  /* activation forcée */
    if vcActif = "N" then vlActif = false. /* désactivation forcée */
    if (vdaDesactivation <> ? and vdaDesactivation <= today) then vlActif = false.     /* On désactive si la date de désactivation est passée */

    /* Date de résiliation */
    if vDateFin <> ? and vDateFin <= today then vlActif = false. /* Désactivation car résilié */
    vcDate = if vdaDesactivation = ? then "" else string(vdaDesactivation, "99/99/9999").
    return substitute("&1,&2,&3,&4",
                      string(vlActif, "O/N"),
                      vcDate,
                      string(vDateRes, "99/99/9999"),    /* date de résiliation */
                      string(if vDateFin <= today then vDateFin else ?, "99/99/9999")).  /* DM 1015/0196 Date renseignée qd date date de fin de connection pour les résiliés est depassée */
end function.

function f_ctrat_tiers_actif returns logical(piNoTie as integer, plOuvert as logical):
    /*------------------------------------------------------------------------------
    Purpose:  
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcCoupleTpconTpidt as character no-undo.

/*gga todo
    if bypass("GED_ControlesDesactives",true) then return true.
gga todo*/   
 
    define buffer vbroles for ROLES.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer tiers for tiers.
    
    find first tiers no-lock
        where tiers.notie = piNoTie no-error.
    if plOuvert and tiers.web-fgouvert <> true and not f_tiers_rep(piNoTie) /* DM 0115/0253 */
    then return false.

    if f_tiers_rep(piNoTie) then return true. /* DM 0115/0253 */
    vcCoupleTpconTpidt = substitute("&1|&2,&1|&3,&4|&3,&4|&5,&6|&7,&8|&9",
                                    {&TYPECONTRAT-titre2copro}, {&TYPEROLE-coproprietaire}, {&TYPEROLE-coIndivisaire},
                                    {&TYPECONTRAT-mandat2Gerance}, {&TYPEROLE-mandant},
                                    {&TYPECONTRAT-bail}, {&TYPEROLE-locataire},
                                    {&TYPECONTRAT-SalariePegase}, {&TYPEROLE-salariePegase}).
    
BCL: 
    for each vbroles no-lock
        where vbroles.notie = piNoTie
      , each intnt no-lock
        where intnt.tpidt = vbroles.tprol
          and intnt.noidt = vbroles.norol                   
          and lookup(intnt.tpcon + "|" + intnt.tpidt, vcCoupleTpconTpidt) > 0:  /**Ajout 00150 = salariés Pégase par OF le 10/05/16**/
        for first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon:
            case intnt.tpcon:
                when {&TYPECONTRAT-mandat2Gerance}
             or when {&TYPECONTRAT-titre2copro} then   /* Proprietaire / Titre de copro */
                    if entry(1, f_ctratactiv(if intnt.tpidt = {&TYPEROLE-coIndivisaire} then rowid(intnt) else rowid(ctrat))) = "O"
                    then return true.

                when {&TYPECONTRAT-bail}
             or when {&TYPECONTRAT-SalariePegase} then  /* locataire / salarié Pégase*/  /**Ajout salarié par OF le 10/05/16**/
                    if entry(1, f_ctratactiv(rowid(ctrat))) = "O"
                    then return true.
            end case.   
        end.
    end. /* vbroles */
    return false.

end function.
