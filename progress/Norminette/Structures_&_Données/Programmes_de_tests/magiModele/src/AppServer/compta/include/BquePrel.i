/*ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
º                                                                           º
º Application      : A.D.B. Progress V7                                     º
º Programme        : BquePrel.i                                             º
º Objet            : Retourne la banque de prélèvement pour les locataires  º
º                    et les copropriétaires Cf Fiche : 1004/0246            º
ºÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
º                                                                           º
º Date de cr‚ation : 21/04/2005                                             º
º Auteur(s)        : JR                                                     º
º                                                                           º
ºÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
º                                                                           º
º ParamŠtres d'entr‚es  :                                                   º
º                                                                           º
º ParamŠtres de sorties :                                                   º
º                                                                           º
º Exemple d'appel       :                                                   º
º                                                                           º
ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
º Historique des modifications                                              º
ºÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
º  Nø  ³    Date    ³ Auteur ³                  Objet                       º
ºÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
|  001 | 15/01/2013 |   SY   | correction utilisation ietab (Banque_Du_Compte)|
|  002 | 03/06/2015 |   SY   | 0215/0040 Ajout maj ctanx.dtmsy/hemsy/cdmsy  |
|      |            |        | dans proc Maj_Rib                            |
|      |            |        | + trace modif dans idetail                   |
|  003 | 04/06/2015 |   SY   | Pb GcUserId    inconnu en gestion adb          |
|      |            |        |                                              |
*---------------------------------------------------------------------------*/

procedure Banque_Du_Compte :
    /*------------------------------------------------------------------------------
        Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter isoc-in     as integer   no-undo.
    define input  parameter iMdt-in     as integer   no-undo.
    define input  parameter cSsColl-in  as character no-undo.
    define input  parameter cCpt-in     as character no-undo.
    define output parameter cJou-out    as character no-undo.
    define output parameter iMdt-out    as integer   no-undo.
    define output parameter iProfil-out as integer   no-undo.
    define buffer bietab     for ietab.
    define buffer bietab-bqu for ietab.
    
    find bietab no-lock 
        where bietab.soc-cd  = isoc-in 
          and bietab.etab-cd = imdt-in no-error.
    if not available bietab then return.

    find first csscptcol no-lock
         where csscptcol.soc-cd     = bietab.soc-cd 
           and csscptcol.etab-cd    = bietab.etab-cd 
           and csscptcol.sscoll-cle = cssColl-in no-error.
    if not available csscptcol then return.

    find first ccptcol no-lock
         where ccptcol.soc-cd   = csscptcol.soc-cd 
           and ccptcol.coll-cle = csscptcol.coll-cle no-error.
    if not available ccptcol then return.    

    case ccptcol.tprole :
        /*** Copropriétaire ***/
        when 00008 then do :
            /** Titre de copropriété **/
            find first ctrat no-lock
                 where ctrat.tpcon = "01004" 
                   and ctrat.nocon = INTEGER(string(bietab.etab-cd,"99999") + cCpt-in) no-error.
            if not available ctrat then return.

            /** banque de prélèvement au niveau du titre de copropriété **/
            if num-entries(ctrat.lbdiv2, separ[1]) > 1
            then assign 
                cJou-out = entry(1,ctrat.lbdiv2,separ[1])
                iMdt-out = integer(entry(2,ctrat.lbdiv2,separ[1]))
            .
        end.
        /*** Locataire **/
        when 00019 then do :
            /** Bail **/
            find first ctrat no-lock
                 where ctrat.tpcon =  {&TYPECONTRAT-Bail} 
                   and ctrat.nocon = INTEGER(string(bietab.etab-cd,"99999") + cCpt-in) no-error.

            if not available ctrat then return.

            /*** Tache quittancement ***/
            find first tache no-lock 
                 where tache.tptac = "04029"
                   and tache.notac = 1
                   and tache.tpcon = "01033"
                   and tache.nocon = ctrat.nocon no-error.
            if not available tache then return.

            /** banque de prélèvement au niveau de la tache quittancement du bail **/
            if num-entries(tache.lbdiv,separ[1]) > 1
            then assign 
                cJou-out = entry(1,tache.lbdiv,separ[1])
                iMdt-out = integer(entry(2,tache.lbdiv,separ[1]))
            .
        end.
    end case.
    if iMdt-out <> 0 then do :
        find first bietab-bqu no-lock
             where bietab-bqu.soc-cd  = bietab.soc-cd 
               and bietab-bqu.etab-cd = imdt-out no-error.
        if available bietab-bqu then iProfil-out = bietab-bqu.profil-cd.
    end.

end procedure.

procedure Maj_Bque_Prel :
    /*------------------------------------------------------------------------------
        Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input parameter TpRole-in    as integer      no-undo.
    define input parameter iMdt-in      as integer      no-undo.
    define input parameter cCpt-in      as character    no-undo.
    define input parameter cJou-in      as character    no-undo.
    define input parameter iMdtBque-in  as integer      no-undo.

    case TpRole-in :
        when 00008 then do transaction :         /*** Copropriétaire ***/
            /** Titre de copropriété **/
            find first ctrat exclusive-lock
                 where ctrat.tpcon = "01004" 
                   and ctrat.nocon = integer(string(iMdt-in,"99999") + cCpt-in) no-error.
            if not available ctrat then return.

            /** banque de prélèvement au niveau du titre de copropriété **/
            ctrat.lbdiv2 = cJou-in + separ[1] + STRING(iMdtBque-in,">>>>9").
        end.
        when 00019 then do transaction:         /*** Locataire **/
            /** Bail **/
            find first ctrat no-lock
                 where ctrat.tpcon = "01033" 
                   and ctrat.nocon = integer(string(iMdt-in, "99999") + cCpt-in) no-error.
            if not available ctrat then return.

            /*** Tache quittancement ***/
            find first tache exclusive-lock
                 where tache.tptac = "04029" 
                   and tache.notac = 1
                   and tache.tpcon = "01033"
                   and tache.nocon = ctrat.nocon no-error.
            if not available tache then return.

            /** banque de prélèvement au niveau de la tache quittancement du bail **/
            tache.lbdiv = cJou-in + separ[1] + string(iMdtBque-in, ">>>>9").
        end.
    end case.

end procedure.

procedure Maj_Rib :
    /*------------------------------------------------------------------------------
        Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input parameter TpRole-in   as integer   no-undo.
    define input parameter iMdt-in     as integer   no-undo.
    define input parameter cCpt-in     as character no-undo.
    define input parameter cBque-in    as character no-undo.
    define input parameter cGuichet-in as character no-undo.
    define input parameter cCptRib-in  as character no-undo.
    define input parameter cCle-in     as character no-undo.
    define input parameter cDomi01-in  as character no-undo.
    define input parameter cDomi02-in  as character no-undo.
    define input parameter cIban-in    as character no-undo.

    define variable TpCttUse as character no-undo.
    define variable NoCttUse as integer   no-undo.
    define variable NoBquUse as integer   no-undo.

    case TpRole-in:
        when 00008  /*** Copropriétaire ***/
        then assign 
            TpCttUse = {&TYPECONTRAT-titre2copro}
            NoCttUse = imdt-IN * 100000 + integer(cCpt-IN)
        .
        when 00019 
        then assign /*** Locataire **/ 
            TpCttUse = {&TYPECONTRAT-bail}
            NoCttuse = imdt-IN * 100000 + integer(cCpt-IN)
            cCpt-in  = string(NoCttUse)
        .
    end case.

    find rlctt no-lock
        where rlctt.tpidt   = string(TpRole-IN, "99999")
            and rlctt.noidt = integer(cCpt-in)
            and rlctt.tpct1 = TpCttUse
            and rlctt.noct1 = NoCttUse
            and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
    if available rlctt then NoBquUse = rlctt.noct2.

    if NoBquUse <> 0 then do transaction:
        find first ctanx exclusive-lock
             where ctanx.tpcon = {&TYPECONTRAT-prive}
               and ctanx.nocon = NoBquUse no-error.

        if available ctanx then do:
            /* Ajout Sy le 03/06/2015 */
            create idetail.
            assign
                idetail.cddet = "LOG-" + TpCttUse + "-" + string(NoCttUse, "9999999999")
                idetail.nodet = integer({&TYPECONTRAT-prive})
                /*idetail.iddet */            
                idetail.ixd01 = mtoken:cUser    /*GcUserId    inconnu en gestion adb */ /* Utilisateur */
                idetail.ixd02 = string(TpRole-in , "99999")
                idetail.ixd03 = cCpt-in
            .
            assign
                idetail.dtcsy = today
                idetail.hecsy = time
                idetail.cdcsy = mtoken:cUser + "@" + "Maj_Rib"
            .
            /* modifications */
            idetail.tbchr[1] = "Modifications IBAN/DOMICILIATION : " + (if TpRole-in = 00008 then "Copropriétaire " else "Locataire ") + STRING(NoCttUse) .
            /* avant */
            idetail.tbchr[2] = "Avant modification" + "|" + "IBAN " + ctanx.iban
                                                    + "|" + "DOMICILIATION " + ctanx.lbdom
                                                    + "|" + "Titulaire " + ctanx.lbtit
            .
            /* après */
            idetail.tbchr[3] = "Apres modification" + "|" + "IBAN " + cIban-in
                                                    + "|" + "DOMICILIATION " + cDomi01-in
                                                    + "|" + "Titulaire " + cDomi02-in
            .

            idetail.tbchr[4] = string(os-getenv("COMPUTERNAME")) .
            idetail.tbchr[5] = string(os-getenv("USERNAME")) .

            assign 
                ctanx.lbdom = cDomi01-in
                ctanx.lbtit = cDomi02-in
                ctanx.cdbqu = cBque-in
                ctanx.cdgui = cGuichet-in
                ctanx.nocpt = cCptRib-in
                ctanx.norib = integer(cCle-in)
                ctanx.iban  = cIban-in
            . 
            /* Ajout Sy le 03/06/2015 */
            assign
                ctanx.dtmsy = today
                ctanx.hemsy = time
                ctanx.cdmsy = mtoken:cUser + "@" + "bqueprel.i" + "@" + "Maj_Rib"
            .
        end.
    end.
    
end procedure. /** Maj_Rib **/

procedure Rib_Etranger :
    /*------------------------------------------------------------------------------
        Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter TpRole-in as integer   no-undo.
    define input  parameter iMdt-in   as integer   no-undo.
    define input  parameter cCpt-in   as character no-undo.
    define output parameter FgEtr-out as logical   no-undo.

    define variable TpCttUse as character no-undo.
    define variable NoCttUse as integer   no-undo.
    define variable NoBquUse as integer   no-undo.

    case TpRole-in :
        when 00008  /*** Copropriétaire ***/ 
        then assign 
            TpCttUse = {&TYPECONTRAT-titre2copro}
            NoCttUse = imdt-IN * 100000 + integer(cCpt-IN)
        .
        when 00019 /*** Locataire **/
        then assign TpCttUse = {&TYPECONTRAT-Bail}
            NoCttuse = imdt-IN * 100000 + integer(cCpt-IN)
            cCpt-in  = string(NoCttUse)
        .
    end case.
    find rlctt no-lock
        where rlctt.tpidt   = string(TpRole-IN, "99999")
            and rlctt.noidt = integer(cCpt-in)
            and rlctt.tpct1 = TpCttUse
            and rlctt.noct1 = NoCttUse
            and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
    if available rlctt then NoBquUse = rlctt.noct2.

    if NoBquUse <> 0 then do :
        find first ctanx no-lock
             where ctanx.tpcon = {&TYPECONTRAT-prive}
               and ctanx.nocon = NoBquUse no-error.
        if available ctanx and ctanx.fgetr 
        then FgEtr-out = true.
    end.

end procedure. /** Rib_Etranger **/

procedure IBAN-RoleContrat:
    /*------------------------------------------------------------------------------
        Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter iMdt-in     as integer   no-undo.
    define input  parameter TpCtt-in    as character no-undo.
    define input  parameter NoCtt-in    as int64     no-undo.
    define input  parameter TpRol-in    as character no-undo.
    define input  parameter NoRol-in    as int64     no-undo.
    define output parameter NoConBqu-OU as integer   no-undo.
    define output parameter cIBAN-OU    as character no-undo.

    run resetParam.
    run addParam("iMdt-in",iMdt-in ).
    run addParam("TpCtt-in",TpCtt-in).
    run addParam("NoCtt-in",NoCtt-in).
    run addParam("TpRol-in",TpRol-in).
    run addParam("NoRol-in",NoRol-in).
    if not dynamic-function("action","_IBAN-RoleContrat") then return.
    NoConBqu-OU = dynamic-function("getField","NoConBqu-OU").
    cIBAN-OU = dynamic-function("getField","cIBAN-OU").

    define buffer binc_roles for roles.
    define buffer binc_rlctt for rlctt.
    define buffer binc_ctanx for ctanx.

    find binc_roles no-lock
        where binc_roles.tprol = TpRol-in 
          and binc_roles.norol = NoRol-in no-error.
    if available binc_roles then do:
        NoConBqu-OU = 0.
        find binc_rlctt no-lock 
           where binc_rlctt.Tpct1 = TpCtt-in
             and binc_rlctt.Noct1 = NoCtt-in
             and binc_rlctt.Tpidt = TpRol-in
             and binc_rlctt.Noidt = NoRol-in
             and binc_rlctt.Tpct2 = {&TYPECONTRAT-prive} no-error.
        if available binc_rlctt then do:
            find first binc_ctanx no-lock
                where binc_ctanx.tpcon = binc_rlctt.tpct2 
                  and binc_ctanx.nocon = binc_rlctt.noct2 no-error.
            if available binc_ctanx then 
            assign
                NoConBqu-OU = binc_rlctt.Noct2
                cIBAN-OU = binc_ctanx.iban
            .
        end.
        if NoConBqu-OU = 0 then do:
            /* Récupération d'un compte bancaire s'il en a un*/
            for each binc_ctanx no-lock
               where binc_ctanx.tpcon = {&TYPECONTRAT-prive}
                 and binc_ctanx.tprol = "99999"
                 and binc_ctanx.norol = binc_roles.notie
                break by binc_ctanx.nocon:    
                if first (binc_ctanx.nocon) or binc_ctanx.tpact = "DEFAU" 
                then assign
                    NoConBqu-OU = binc_ctanx.nocon
                    cIBAN-OU = binc_ctanx.iban.
                .
            end.
        end.
    end.

end procedure.

