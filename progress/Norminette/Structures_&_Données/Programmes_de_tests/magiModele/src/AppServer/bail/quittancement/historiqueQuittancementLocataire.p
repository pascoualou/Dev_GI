/*------------------------------------------------------------------------
    File        : historiqueQuittancementLocataire.p
    Purpose     : 
    Description : 
    Author(s)   : KANTENA - 2018/01/04
    Created     : Thu Jan 04 14:54:10 CET 2018
    Notes       : reprise de qttloc00_srv.p
  ----------------------------------------------------------------------*/
{preprocesseur/type2Role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.syspg.syspg.
using parametre.pclie.parametrageDetailQuittance.
using parametre.pclie.parametrageProlongationExpiration.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/tmprub.i}
{bail/include/equit.i &nomtable=ttqtt}
{mandat/include/mandat.i}

function nolib returns integer
  (pcTpParUse as character, pcCdParUse as character ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    define variable oSysPg as class syspg no-undo.

    oSysPg = new syspg().
    oSysPg:reloadUnique(pcTpParUse, pcCdParUse).
    if oSysPg:isDbParameter then return oSysPg:nome1.
    if valid-object(oSysPg) then delete object oSysPg.

    return 0.

end function.

procedure creTabQtt:
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define input  parameter pcTpAffQtt         as character        no-undo.
    define input  parameter piNoLocSel         as integer          no-undo.
    define input  parameter pcTpLocSel         as character        no-undo.
    define input  parameter poGlobalCollection as class collection no-undo.
    define output parameter poCollection       as class collection no-undo.

    define variable vdaMaxQtt             as date      no-undo.
    define variable vdaResiliationBail    as date      no-undo.
    define variable vdaFinBail            as date      no-undo.
    define variable vdaSortieLocataire    as date      no-undo.
    define variable viNombreQttEncours    as integer   no-undo.
    define variable vcListeQttEncours     as character no-undo.
    define variable viNombreQttHistorique as integer   no-undo.
    define variable vcListeQttHistorique  as character no-undo.
    define variable vlTaciteReconduction  as logical   no-undo initial true.
    define variable viNumeroMoisTmp       as integer   no-undo.
    define variable viIteTab              as integer   no-undo.
    define variable viNombreQttLocataire  as integer   no-undo.
    define variable vcTpAffTmp            as character no-undo.
    define variable vcTabQttLoc           as character no-undo.
    define variable vhEncours             as handle    no-undo.
    define variable vhHistorique          as handle    no-undo.
    define variable oProlongationExpiration as class parametrageProlongationExpiration no-undo.
    define variable vhTbtmp               as handle    no-undo.
    define variable vcRubTmp              as character no-undo.
    define variable vcRecTmp              as character no-undo.
    
    define variable LbTmpPdt as character no-undo.
    define variable LbInf1Qt as character no-undo.
    define variable LbInf1GI as character no-undo.

    define buffer tache for tache.
    define buffer ctrat for ctrat.
    define buffer aquit for aquit.
    define buffer equit for equit.

    if pcTpAffQtt = "01" or pcTpAffQtt = "11" then do:
        run bail/quittancement/quittanceEncours.p persistent set vhEncours.
        run getTokenInstance in vhEncours (mToken:JSessionId).
        run getListeQuittance in vhEncours(pcTpLocSel, piNoLocSel, poGlobalCollection, output table ttQtt by-reference, output table ttRub by-reference).
        if valid-handle(vhEncours) then run destroy in vhEncours.
    end.
    if pcTpAffQtt = "10" or pcTpAffQtt = "11" then do:    
        run bail/quittancement/quittanceHistorique.p persistent set vhHistorique.
        run getTokenInstance in vhHistorique(mToken:JSessionId).
        run getListeQuittance in vhHistorique(piNoLocSel, output table ttQtt by-reference, output table ttRub by-reference).
        if valid-handle(vhHistorique) then run destroy in vhHistorique.
    end.

    /* Creation de la liste des quittances */
    assign vcTpAffTmp = if (pcTpAffQtt = "10" or pcTpAffQtt = "11") then "10" else "01".

    run quittancement/l_tbtmp.p persistent set vhTbtmp.
    /* Mode d'affichage = Histo */
    if vcTpAffTmp = "10" then do:
        run LstHstTmp in vhTbTmp (input table ttQtt by-reference, piNoLocSel, output viNombreQttHistorique, output vcListeQttHistorique).
        if pcTpAffQtt = "11" then vcTpAffTmp = "01".
    end.
    if vcTpAffTmp = "01" 
    then run LstEncTmp in vhTbTmp (input table ttQtt by-reference, piNoLocSel, output viNombreQttEncours, output vcListeQttEncours).
    if valid-handle(vhTbtmp) then run destroy in vhTbtmp.

    /* Recherche de la date de sortie du Locataire. */
    vdaSortieLocataire = ?.
    find last tache no-lock 
        where tache.TpTac = {&TYPETACHE-quittancement}
          and tache.TpCon = {&TYPECONTRAT-bail}
          and tache.NoCon = piNoLocSel no-error.
    if available tache then assign vdaSortieLocataire = tache.DtFin.

    if viNombreQttHistorique <> 0 or viNombreQttEncours <> 0 then do:
        if pcTpAffQtt = "10" /* Mode histo */ 
        then assign
            viNombreQttLocataire = viNombreQttHistorique
            vcRecTmp = vcListeQttHistorique
        .
        else do:
            if pcTpAffQtt = "01" /* Mode encours */ 
            then assign  
                viNombreQttLocataire = viNombreQttEncours
                vcRecTmp = vcListeQttEncours
            .
            else /* Mode histo + encours */
                assign 
                    viNombreQttLocataire = viNombreQttHistorique + viNombreQttEncours
                    vcRecTmp = if vcListeQttHistorique = "" 
                               then vcListeQttEncours 
                               else substitute('&1@&2', vcListeQttHistorique, vcListeQttEncours).
        end.
        assign
            vcTabQttLoc = ""
            LbTmpPdt    = ""
        .
        /* Recherche de la date de resiliation du bail */
        for first ctrat no-lock
            where ctrat.TpCon = {&TYPECONTRAT-bail}
              and ctrat.NoCon = piNoLocSel:
           assign 
               vdaFinBail           = ctrat.DtFin
               vdaResiliationBail   = ctrat.DtRee
               vlTaciteReconduction = (if ctrat.TpRen = "00001" then yes else false). /* Info "Tacite Reconduction ?" */
           .
        end.
        /* Prendre la plus petite des dates... */
        if vdaSortieLocataire <> ? and vdaResiliationBail <> ? 
        then assign vdaMaxQtt = minimum(vdaSortieLocataire, vdaResiliationBail).
        else do:
            if vdaResiliationBail <> ? then assign vdaMaxQtt = vdaResiliationBail.
            if vdaSortieLocataire <> ? then assign vdaMaxQtt = vdaSortieLocataire.
        end.
        if not vlTaciteReconduction
        then do:
            oProlongationExpiration = new parametrageProlongationExpiration().
            if oProlongationExpiration:isOuvert()
            then assign vdaMaxQtt = if vdaMaxQtt = ? then date("31/12/2950") else minimum(vdaMaxQtt, date("31/12/2950")).
            else assign vdaMaxQtt = if vdaMaxQtt = ? then vdaFinBail else minimum(vdaMaxQtt, vdaFinBail).
            delete object oProlongationExpiration.
        end.
        do viIteTab = 1 to viNombreQttLocataire:
           assign vcRubTmp = entry (viIteTab, vcRecTmp, "@").

           /* Recherche dates de la p‚riode et controle
              par rapport … la fin du bail (ou sortie loc) */
           if vdaMaxQtt <> ? then do:
               find ttqtt
               where ttqtt.noloc = piNoLocSel
                   /*AND   ttqtt.msqtt = INTEGER( ENTRY( 2, LbRubTmp,'#' ) )*/     /* Modif sy le 04/01/2007 : le mois de quitt n'est plus unique */
                 and ttqtt.noqtt = integer(entry(1, vcRubTmp, '#')) no-error.
               if available ttqtt then do:
                   /* On affiche toutes les quittances histo meme si
                      la date de r‚si. ou de sortie du bail est
                      anterieure.
                   */
                   if ttqtt.dtdpr > vdaMaxQtt and ttqtt.cdori <> "H" then leave.
               end.
           end.
           assign 
               viNumeroMoisTmp = integer(substring(entry (2, vcRubTmp, "#"), 5, 2))
               vcTabQttLoc = substitute('&1|&2#&3#&4', 
                                        vcTabQttLoc,
                                        entry(1, vcRubTmp, "#"),
                                        entry(2, vcRubTmp, "#"),
                                        entry(3, vcRubTmp, "#"))
           .
        end.
        assign viNombreQttLocataire = viIteTab - 1.

        /* Modif Sy le 09/09/2009 */
        /* Init du quittancement GI */
        assign
            LbInf1Qt = ""
            LbInf1GI = ""
        .
        /* 1er no quittance utilis?(y compris Quittance d'ant?iorit? */
        /* mais Hors factures diverses */
        find first aquit no-lock
             where aquit.noloc = piNoLocSel
               and aquit.type-fac <> "D"
               use-index ix_aquit01 no-error.
        if available aquit 
        then LbInf1Qt = string(aquit.noqtt) + "#" + string(aquit.msqtt) + "#" + "H".
        else do:
            find first equit no-lock
                 where equit.noloc = piNoLocSel
                use-index ix_equit02 no-error.
            if available equit then LbInf1Qt = string(equit.noqtt) + "#" + string(equit.msqtt) + "#" + "E".
        end.
        /* 1?e quittance GI hors Facture locataire */
        find first aquit no-lock
             where aquit.noloc = piNoLocSel
               and aquit.noqtt > 0
               and aquit.fgfac = false
                use-index ix_aquit03 no-error.
        if available aquit
        then LbInf1GI = substitute('&1#&2#&3', equit.noqtt, equit.msqtt, "H").
        else for first equit no-lock
            where equit.noloc = piNoLocSel
              use-index ix_equit02:
            LbInf1GI = substitute('&1#&2#&3', equit.noqtt, equit.msqtt, "E").
        end.
        /* Suppression du premier */
        assign vcTabQttLoc = substring (vcTabQttLoc, 2).
        poCollection:set("LbInf1GI",            LbInf1GI).
        poCollection:set("cTabQttLoc",          vcTabQttLoc).
        poCollection:set("LbInf1Qt",            LbInf1Qt).
        poCollection:set("iNombreQttLocataire", viNombreQttLocataire).
    end.
    poCollection:set("iNombreQttHistorique", viNombreQttHistorique).
    poCollection:set("iNombreQttEncours",    viNombreQttEncours).
    poCollection:set("daSortieLocataire",    vdaSortieLocataire). /* Ajout SY le 05/10/2015 */

end procedure.

procedure maj_ltrol :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    define input parameter piNumeroReference   as integer   no-undo.

    define variable NoSesEnc as character no-undo. /* TODO comment initialiser NoSesEnc ? */
    define variable NoReqUse as integer   no-undo.
    define variable LbTmpPdt as character no-undo.

    define buffer ltrol for ltrol.
    define buffer ctrat for ctrat.
/*
    run AffecIdt(0,"UseRqRol").
    run AffecIdt(1,TpIdtUse-IN).

    {RunPgExp.i &Path   = RpRunLibADB
                &Prog   = "'L_ReqRol_ext.p'"}

    run RecupIdt(1,output LbTmpPdt).
    */
    NoReqUse = integer(LbTmpPdt).

    if NoReqUse >= 0 
    then do:
        find ltrol no-lock
        where ltrol.noref = piNumeroReference
          and ltrol.cduti = mtoken:cUser
          and ltrol.noses = integer(NoSesEnc)  /* TODO comment initialiser NoSesEnc ? */
          and ltrol.noreq = NoReqUse
          and ltrol.tprol = pcTypeIdentifiant
          and ltrol.norol = piNumeroIdentifiant no-error.
        if not available ltrol 
        then do:
            find first ctrat no-lock 
                 where ctrat.tprol = pcTypeIdentifiant
                   and Ctrat.norol = piNumeroIdentifiant no-error.
            do transaction:
                create ltrol.
                assign
                    ltrol.noref = piNumeroReference /* TODO comment initialiser NoRefUse ? */
                    ltrol.cduti = mtoken:cUser
                    ltrol.noses = integer(NoSesEnc)
                    ltrol.noreq = NoReqUse
                    ltrol.tprol = pcTypeIdentifiant
                    ltrol.norol = piNumeroIdentifiant
                    ltrol.lbrol = (if available ctrat then ctrat.lbnom else "?").
            end.
        end.
    end.

end procedure.

procedure IniWinRch :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define input  parameter poGlobalCollection as class collection no-undo.
    define output parameter poCollection       as class collection no-undo.

    define variable viNumeroLocataire       as integer   no-undo.
    define variable vcTypeContratBail       as character no-undo.
    define variable daInitialBail           as character no-undo.
    define variable daEffetBail             as date      no-undo.
    define variable vlGesFourloyer          as logical   no-undo.
    define variable vlBailFourloyer         as logical   no-undo.
    define variable vlValidationSepareeEchu as logical   no-undo.
    define variable daDebutPeriode1Qtt      as date      no-undo format "99/99/9999".
    define variable daDebut1Qtt             as date      no-undo format "99/99/9999".
    define variable vlSenCre                as logical   no-undo.
    define variable vcCodeTerme1Qt          as character no-undo.
    define variable viMoisQtt1Qtt           as integer   no-undo.
    define variable viNumeroQtt1Qtt         as integer   no-undo.
    define variable vcTypeQtt1Qtt           as character no-undo.
    define variable vcCodePeriode1Qtt       as character no-undo.
    define variable vlRepMes                as logical   no-undo.
    define variable viMoisModifiable        as integer   no-undo.
    define variable viMoisMEchu             as integer   no-undo.
    define variable vhCtrat                 as handle    no-undo.

    define variable LbTmpPdt as character no-undo.
    define variable LbInf1Qt as character no-undo.

    define buffer aquit for aquit.
    define buffer equit for equit.

    assign
        viMoisModifiable = poGlobalCollection:getInteger("GlMoiMdf")
        viMoisMEchu      = poGlobalCollection:getInteger("GlMoiMEc")
    .
/*
    NoLocSel = integer(getValeur("NoLocSel")).
    TpCttBai = getValeur("TpCttBai").
    LbInf1Qt = getValeur("LbInf1Qt").
    FgValEch = logical(getValeur("FgValEch")).
    FgGesFlo = logical(getValeur("FgGesFlo")).
    FgBaiFlo = logical(getValeur("FgBaiFlo")).
    
*/
    vlSenCre = no.
    if viNumeroLocataire <> 0 then do:
        empty temp-table ttMandat.
        /* Recuperation date effet du Bail dans Contrat */
        run adblib/ctrat_CRUD.p persistent set vhCtrat.
        run getTokenInstance in vhCtrat.
        run readCtrat in vhCtrat(vcTypeContratBail, viNumeroLocataire, table ttMandat by-reference).
        run destroy in vhCtrat.

        find first ttMandat no-error. 
        if available(ttMandat)
        then do:
            run GestMess (000003, "", 100057, "", "", "ERROR", output vlRepMes).
            daEffetBail = ?.
        end.
        else do:
            /* Recuperation de la Date d'Effet initiale (ou date d'effet si vide) */
            run RecupIdt (31, output daInitialBail).
            run RecupIdt (5, output LbTmpPdt).
            daEffetBail = (if date(daInitialBail) <> ? then date(daInitialBail) else date( LbTmpPdt )).
        end.
        if LbInf1Qt <> "" 
        then do:
            assign 
                viNumeroQtt1Qtt    = integer(entry(1, LbInf1Qt, "#"))
                viMoisQtt1Qtt      = integer(entry(2, LbInf1Qt, "#"))
                vcTypeQtt1Qtt      = entry(3, LbInf1Qt , "#")
                vcCodePeriode1Qtt  = ?
                vcCodeTerme1Qt     = ?
                daDebut1Qtt        = ?
                daDebutPeriode1Qtt = ?
            .

            /* Recherche de la 1ere Quittance Existante */
            if vcTypeQtt1Qtt = "H" 
            then do:
                find first aquit no-lock
                     where aquit.NoLoc = viNumeroLocataire 
                       and aquit.Noqtt = viNumeroQtt1Qtt 
                       and aquit.MsQtt = viMoisQtt1Qtt no-error.
                if available aquit 
                then assign /* Recuperation de la periodicite & Terme & DtDpr de la 1ere quittance connue */
                    vcCodePeriode1Qtt  = aquit.pdqtt
                    vcCodeTerme1Qt     = aquit.cdter
                    daDebut1Qtt        = aquit.dtdeb
                    daDebutPeriode1Qtt = aquit.dtdpr
                .
            end.
            else do:
                find first equit no-lock
                     where equit.NoLoc = viNumeroLocataire
                       and equit.Noqtt = viNumeroQtt1Qtt 
                       and equit.MsQtt = viMoisQtt1Qtt no-error.
                if available equit 
                then assign /* Recuperation de la periodicite & Terme & DtDpr de la 1ere quittance connue */
                    vcCodePeriode1Qtt  = equit.pdqtt
                    vcCodeTerme1Qt     = equit.cdter
                    daDebut1Qtt        = equit.dtdeb
                    daDebutPeriode1Qtt = equit.dtdpr
                .
            end.

            /*--> date debut periode 1ere quittance <= 1er mois modifiable ? */
            if daDebutPeriode1Qtt <> ? 
            then do:
                LbTmpPdt = string(year(daDebutPeriode1Qtt), "9999" ) + string(month(daDebutPeriode1Qtt), "99").

                /*--> Validation separee des echus */
                if vlValidationSepareeEchu then
                do:
                    if ((vcCodeTerme1Qt = "00001" and integer(LbTmpPdt) <= viMoisModifiable) 
                         or (vcCodeTerme1Qt = "00002" and integer(LbTmpPdt) <= viMoisMEchu)) 
                    and daEffetBail < daDebutPeriode1Qtt 
                    then vlSenCre = yes. /* Date d'Effet du Bail < DtDpr 1ere quittance ? */
                end.
                else do:
                    if vlGesFourloyer and vlBailFourloyer 
                    then do:
                        if integer(LbTmpPdt) <= viMoisModifiable
                        and daEffetBail < daDebutPeriode1Qtt /* Date d'Effet du Bail < DtDpr 1ere quittance ? */
                        then vlSenCre = yes. 
                    end.
                    else do:
                        if integer(LbTmpPdt) <= viMoisModifiable 
                        and daEffetBail < daDebutPeriode1Qtt /* Date d'Effet du Bail < DtDpr 1ere quittance ? */
                        then vlSenCre = yes.
                    end.
                end.
            end.
        end.
    end.
    poCollection:set("FgSenCre", vlSenCre).
    poCollection:set("DtEffBai", daEffetBail).
    poCollection:set("DtDpr1Qt", daDebutPeriode1Qtt).
    poCollection:set("CdPer1Qt", vcCodePeriode1Qtt).

end procedure.

procedure RunBtnQtt :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define input parameter piNoLocSel   as integer no-undo.
    define input parameter piNoQttSel   as integer no-undo.
    define input parameter piDtSorLoc   as date    no-undo.
    define input parameter poCollection as class collection no-undo.
    
    define variable vcTpAffTmp          as character no-undo.
    define variable viNumInterneFacture as integer   no-undo.
    define variable vlFactureLocataire  as logical   no-undo.
    define variable vlDetailQtt         as logical   no-undo.
    define variable vcTypeFacUse        as character no-undo.
    define variable oDetailQuittance    as class parametre.pclie.parametrageDetailQuittance no-undo.

    define buffer equit  for equit.
    define buffer aquit  for aquit.
    define buffer bAquit for aquit.
    define buffer iftsai for iftsai.
    define buffer daquit for daquit.

    assign
        vcTpAffTmp = "10"
        viNumInterneFacture  = 0
    .
    find first equit no-lock
         where equit.noloc = piNoLocSel
           and equit.noqtt = piNoQttSel no-error.
    if available equit 
    then vcTpAffTmp = "01".
    else do:
        find first aquit no-lock
             where aquit.noloc = piNoLocSel
               and aquit.noqtt = piNoQttSel no-error.
        if available aquit and aquit.fgfac = yes 
        then do:
            assign
                vlFactureLocataire  = yes
                viNumInterneFacture = aquit.num-int-fac
            .
            if viNumInterneFacture = 0 then do:
                /*-----------------------------------------------*
                 | On essaye de retrouver la facture             |
                 *-----------------------------------------------*/
                 if piDtSorLoc = ? then vcTypeFacUse = "E". /* Facture d'entree */ 
                 else do:
                     find first baquit no-lock
                          where baquit.noloc = aquit.noloc
                            and baquit.noqtt < aquit.noqtt no-error.
                     if available baquit 
                     then vcTypeFacUse = "S". /* Facture de sortie */
                     else vcTypeFacUse = "E". /* Facture d'entree  */
                 end.
                 find first iftsai no-lock
                      where iftsai.soc-cd = integer(mtoken:cRefGerance)
                      /*AND    iftsai.etab-cd = INT(SUBSTRING(STRING(aquit.noloc,"999999999"), 1 , 4))*/ /* NP 0608/0065 */
                        and iftsai.etab-cd = integer(truncate(aquit.noloc / 100000, 0)) // int(substring(string(aquit.noloc, "9999999999"), 1 , 5))
                        and iftsai.tprole = 19
                      /*AND    iftsai.sscptg-cd = SUBSTRING(STRING(aquit.noloc,"999999999"), 5 , 5)*/ /* NP 0608/0065 */
                        and iftsai.sscptg-cd = substring(string(aquit.noloc, "9999999999"), 6, 5)
                      /*AND    iftsai.fg-edifac */
                        and iftsai.typefac-cle = (if vcTypeFacUse = "S" then "Sortie" else "Entr?") no-error.
                 if available iftsai 
                 then viNumInterneFacture = iftsai.num-int.
            end.
        end.
        if vlFactureLocataire and viNumInterneFacture <> 0 
        then do:
            /* Ajout SY le 28/08/2012 : au choix d?ail quittance ou acc? facture locataire en compta */
            vlDetailQtt = false.
            oDetailQuittance = new parametrageDetailQuittance().
            if oDetailQuittance:isOuvert() 
            then for first daquit  no-lock
                     where daquit.tprol    = {&TYPEROLE-locataire}
                       and daquit.noloc    = piNoLocSel 
                       and daquit.norefqtt = pinoqttsel:
                vlDetailQtt = true.
            end.
            delete object oDetailQuittance.
            poCollection:set("lDetailQtt", vlDetailQtt).
        end.
    end.
    poCollection:set("lFactureLocataire",  vlFactureLocataire).
    poCollection:set("cTpAffTmp",          vcTpAffTmp).
    poCollection:set("iNumInterneFacture", viNumInterneFacture).

end procedure.

procedure main :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.

    define variable viNumeroRole      as integer   no-undo.
    define variable vcTypeRole        as character no-undo.
    define variable vcTypeContrat     as character no-undo.
    define variable viNumeroContrat   as integer   no-undo.
    define variable vcTypeBail        as character no-undo.
    define variable viNumeroBail      as integer   no-undo.
    define variable viNumeroQuittance as integer   no-undo.
    define variable vcTypeLocataire   as character no-undo.
    define variable viNumeroLocataire as integer   no-undo.
    define variable viNumeroFacture   as integer   no-undo.
    define variable vcDocument        as character no-undo.
    define variable vhProc            as handle    no-undo.
    define variable viNoRefUse        as integer   no-undo.

    define variable TpMtrQtt          as character no-undo.
    define variable PgFrmLstRol       as character no-undo.


    define buffer iftsai for iftsai.
    define buffer aquit  for aquit.
    define buffer ctrat  for ctrat.
/*
    NoDocSel = getValeur("NoDocSel").
    NoBaiSel = integer(getValeur("NoBaiSel")).
    TpMtrQtt = getValeur("TpMtrQtt").
    NoRolSel = integer(getValeur("NoRolSel")).
    TpRolSel = getValeur("TpRolSel").
    TpCttSel = getValeur("TpCttSel").
    NoCttSel = integer(getValeur("NoCttSel")).
    TpLocSel = getValeur("TpLocSel").
    NoLocSel = integer(getValeur("NoLocSel")).
    TpBaiSel = getValeur("TpBaiSel").
*/

    viNoRefUse = integer(if vcTypeContrat = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance).

    /* Rechercher le Libelle du Type de Role locataire */
    if TpMtrQtt = "11" 
    then poCollection:set("NoLibLoc", NOLIB("O_ROL", "00059")).
    else poCollection:set("NoLibLoc", NOLIB("O_ROL", vcTypeLocataire)).
    
    poCollection:set("NoLibMnd", NOLIB("O_ROL", vcTypeRole)).    /* Rechercher le Libelle du Type de Role mandant */
    poCollection:set("NoLibMdt", NOLIB("O_CLC", vcTypeContrat)). /* Rechercher le Libelle du Type de Contrat mdt */
    poCollection:set("NoLibBai", NOLIB("O_CLC", vcTypeBail)).    /* Libelle du Type de Contrat bail */
    poCollection:set("NoLibBie", NOLIB("O_BIE", "02001")).       /* Libelle du Type de Bien */

    viNumeroQuittance = integer(vcDocument) no-error.
    if error-status:error then do:
        /* recherche Facture entr? ou sortie */
        viNumeroFacture = integer(replace(vcDocument, "FL", "")).
        find first iftsai no-lock
             where iftsai.soc-cd = integer(mtoken:cRefGerance)
               /*AND    iftsai.etab-cd = INT(SUBSTRING(STRING(NoBaiSel,"999999999"), 1 , 4))*/ /* NP 0608/0065 */
               and iftsai.etab-cd = integer(truncate(viNumeroBail / 100000, 0)) // integer(substring(string(NoBaiSel, "9999999999"), 1, 5))
               and iftsai.tprole = 19
               /*AND    iftsai.sscptg-cd = SUBSTRING(STRING(NoBaiSel,"999999999"), 5 , 5)*/ /* NP 0608/0065 */
               and iftsai.sscptg-cd = substring(string(viNumeroBail,"9999999999"), 6 , 5)
               and iftsai.fg-edifac = yes
               and iftsai.fac-num = viNumeroFacture no-error.
        if available iftsai 
        then do:
            find last aquit no-lock
                where aquit.noloc = viNumeroBail
                  and aquit.fgfac = yes
                  and aquit.num-int-fac = iftsai.num-int no-error.
            if available aquit 
            then viNumeroQuittance = aquit.noqtt. 
            else do:
                /* au cas o?ce serai une tr? vielle facture sans lien... */                                                                          
                if iftsai.typefac-cle = "Entr?" 
                then do:
                    find first aquit no-lock
                         where aquit.noloc = viNumeroBail
                           and aquit.fgfac = yes no-error.
                    if available aquit then viNumeroQuittance = aquit.noqtt. 
                end.
            end.
        end.
    end.
    /* Recuperation du dernier numero d'identifiant selon le maitre*/
    if (TpMtrQtt  = "00" and viNumeroRole = 0 ) or (TpMtrQtt <> "00" and viNumeroLocataire = 0 )then
    do:
        run GetIdtEnc in vhProc(vcTypeRole,      output viNumeroRole).
        run GetIdtEnc in vhProc(vcTypeContrat,   output viNumeroContrat).
        run GetIdtEnc in vhProc(vcTypeLocataire, output viNumeroLocataire).
        run GetIdtEnc in vhProc(vcTypeBail,      output viNumeroBail).
    end.
    PgFrmLstRol = "frmlrl02.p".

    /* Ajout SY le 19/10/2010 */
    if vcTypeBail = "01033" and viNumeroBail <> 0 
    then do:
        find first ctrat no-lock 
             where ctrat.tpcon = vcTypeBail 
               and ctrat.nocon = viNumeroBail no-error.
        if available ctrat and ctrat.dtree <> ? then PgFrmLstRol = "FrmLrl20.p". /* Actifs + inactifs */
    end.   
    /* SY 0115/0156 : Ajouter le role en cours dans la liste de la requête en cours (ltrol) */ 
    if TpMtrQtt = "01" or TpMtrQtt = "11" 
    then do:
        /* Locataire Maitre */
        if viNumeroLocataire <> 0 
        then run Maj_ltrol(vcTypeLocataire, viNumeroLocataire, viNoRefUse).
    end.
    else do:
        /* Mandant maitre */ 
        if viNumeroRole <> 0 
        then run Maj_ltrol(input vcTypeRole, input viNumeroRole, viNoRefUse).
    end.
    poCollection:set("PgFrmLstRol", PgFrmLstRol).
    poCollection:set("NoRolSel",   viNumeroRole).
    poCollection:set("NoCttSel",   viNumeroContrat).
    poCollection:set("NoLocSel",   viNumeroLocataire).
    poCollection:set("NoBaiSel",   viNumeroContrat).
    poCollection:set("NoQttSel",   viNumeroQuittance).

end procedure.

