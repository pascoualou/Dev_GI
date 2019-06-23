/*------------------------------------------------------------------------
File        : suppiece.i
Purpose     : Suppression ou annulation d'une piece comptable suivant sa date
              comptable et la période du gestionnaire 1105/0188
Author(s)   : JR - 2006/04/27;  gga  -  2017/05/12
Notes       : reprise include cadb\comm\suppiece.i
              pour le moment seulement reprise procedure lettrage
                                                         effaparm

01  | 06/09/2006 |  OF  | Message d'erreur "La saisie 0 est en dehors de la liste"
02  | 17/11/2006 |  JR  | 0606/0225 : Gestion du regroupement des analytiques lors d'une suppression
03  | 05/09/2007 |  DM  | 0207/0077 : Mutation od regul TX et HB
04  | 19/09/2008 |  DM  | 0608/0065 : Mandat 5 chiffres
05  | 25/01/2010 |  JR  | La valeur de apbco.tpbud a été modifié : 01008 --> 01080
06  | 10/08/2010 |  OF  | 0810/0036 Problème de lettrage en suppression
07  | 05/10/2011 |  NP  | 0306/0238 modif create apbco avec NoOrdMax
08  | 17/04/2013 |  OF  | 0413/0023 gestion cecrsai.lib pour suivi financier client (doit commencer par mutations)
09  | 05/06/2013 |  NP  | 0613/0022 add gestion mdt issu d'1 migration
10  | 02/12/2015 |  NP  | 1215/0002 suite 0413/0023
11  | 11/01/2017 |  OF  | 0117/0047 Gestion du fonds travaux ALUR
----------------------------------------------------------------------*/

/*gga
define variable recno-sai        as rowid no-undo.
define variable tmp-piece-int    like cecrsai.piece-int no-undo.
define variable tmp-piece-compta like cecrsai.piece-compta no-undo.
gga*/
{compta/include/flagLettre-cLettre-inumpiec.i}
{compta/include/faletaut.i}
define temp-table tmp-cpt no-undo
  field cpt-cd     as character format "x(5)"
  field coll-cle   as character format "x(5)"
  field sscoll-cle as character format "x(5)"
  field etab-cd    as integer   format ">9"
.

/*gga
define temp-table apbco-tmp no-undo like apbco .

/* définition pour le lettrage*/
define variable txtcpt-cd      as character no-undo.
define variable txttime        as character no-undo.
define variable li             as integer   no-undo.
define variable txtlib-lettre  as character no-undo.
define variable start-time     as integer   no-undo.
define variable csolde         as character no-undo.
define variable clettrage      as character no-undo.
define variable FillColl       as character no-undo.
define variable TpBudTvrx      as character init "01080" no-undo.
define variable TpBudBU        as character init "01008" no-undo.
define variable TpBudHB        as character init "01012" no-undo.
define variable TpBudTA        as character init "01053" no-undo.

define buffer cecrln-buf9 for cecrln.
define buffer bcecrsai    for cecrsai.
define buffer bcecrln     for cecrln.
define buffer bcecrlnana  for cecrlnana.
define buffer cecrsai-buf for cecrsai.
define buffer apbco-buf   for apbco.

form
    TxtCpt-cd
    TxtTime
    txtLib-lettre
    FillColl
    with frame f-aff.

hide frame f-aff no-pause.
gga*/

procedure lettrage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piCodeSoc   as integer no-undo.
    define input parameter piCodeEtab  as integer no-undo.
    define input parameter pdaDatDebEx as date    no-undo.
    define input parameter pdaDatFinEx as date    no-undo.

    define buffer ccpt for ccpt.

message "gga debut procedure lettrage " piCodeSoc "//" piCodeEtab "//" pdaDatDebEx "//" pdaDatFinEx.
    for each tmp-cpt:
message "gga debut procedure lettrage boucle tmp-cpt " .
        for first ccpt no-lock
            where ccpt.soc-cd     = piCodeSoc
              and ccpt.coll-cle   = tmp-cpt.coll-cle
              and ccpt.cpt-cd     = tmp-cpt.cpt-cd
              and ccpt.libtype-cd = 1:
message "gga debut procedure lettrage avant appel faletaut " .
            run faletaut (buffer ccpt, piCodeEtab, true, tmp-cpt.sscoll-cle, pdaDatDebEx, pdaDatFinEx).
        end.
    end.

end procedure.

procedure effaparm private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter prRowidSai as rowid   no-undo.
    define input parameter piSocCd    as integer no-undo.

    define buffer aparm for aparm.

    {&_proparse_ prolint-nowarn(nowait)}
    find first aparm exclusive-lock
        where aparm.tppar  = "BALANCE"
          and aparm.cdpar  = string(prRowidSai)
          and aparm.soc-cd = piSocCd no-error.
/*gga cette procedure est appelé pour supprimer l'enregistrement aparm (pas pour le creer)
    if not available aparm
    then do:
        create aparm.
        assign
            aparm.tppar  = "BALANCE"
            aparm.cdpar  = string(prRowidSai)
            aparm.soc-cd = piSocCd
            aparm.lib    = "INTERRUPTION DE LA BALANCE"
        .
    end.
gga*/
    if available aparm then delete aparm. /* PS LE 19/09/00 */
end procedure.

/*gga
procedure Sup_Comptabilisation :

    define input  parameter rrwd-cecrsai-in as rowid    no-undo.
    define input  parameter rrwd-agest-in   as rowid    no-undo.
    define input  parameter GiUsrId         as character     no-undo.
    define input  parameter RpRunBatSpe-in  as character     no-undo.
    define input  parameter RprunBatStd-in  as character     no-undo.
    define input  parameter dDacompta-in    as date     no-undo.

    define output parameter ierr-out        as integer  no-undo.


    define variable cLien-Apbco-cecrsai         as character no-undo.
    define variable cLien-Apbco-cecrsai-annulle as character no-undo.

    do TRANS ON ERROR UNDO, LEAVE :

        find cecrsai where rowid(cecrsai) = rrwd-cecrsai-in exclusive-lock no-error.
        find agest   where rowid(agest)   = rrwd-agest-in exclusive-lock no-error.

        if not available cecrsai or not available agest then return.

        assign
            cLien-Apbco-cecrsai = string(cecrsai.soc-cd)       + "|" +
                       STRING(cecrsai.etab-cd)      + "|" +
                       STRING(cecrsai.jou-cd)       + "|" +
                       STRING(cecrsai.prd-cd)       + "|" +
                       STRING(cecrsai.prd-num)      + "|" +
                       STRING(cecrsai.piece-compta).

        if cecrsai.dacompta >= agest.dadeb /*AND cecrsai.dacompta <= agest.dafin*/ /**Modif OF le 11/01/17 - Sinon, on annule des mutations de janvier sur décembre!**/
            then
        do : /* Suppression de la piece, elle fait partie du gestionnaire */

            /*---- SUPPRESSION DES APBCO LIES A LA MUTATION ----*/
            run Sup_Apbco(input cLien-Apbco-cecrsai).

            recno-sai = rowid(cecrsai). /* utilisé dans cptmvtu */

/*gga
            run VALUE(RpRunBatSpe-in + "cptmvtu.p") . /* ANNULATION de la balance / dispo */
gga*/
            run compta/souspgm/cptmvtu.p (input recno-sai).

            for each cecrln
                where cecrln.soc-cd           = cecrsai.soc-cd
                and cecrln.mandat-cd        = cecrsai.etab-cd
                and cecrln.jou-cd           = cecrsai.jou-cd
                and cecrln.mandat-prd-cd    = cecrsai.prd-cd
                and cecrln.mandat-prd-num   = cecrsai.prd-num
                and cecrln.piece-int        = cecrsai.piece-int
                exclusive-lock :

                /** ANALYTIQUE **/

                for each cecrlnana of cecrln exclusive-lock :
                    if cecrlnana.regrp <> "" then
                    do :
                        for each bcecrlnana
                            where bcecrlnana.soc-cd     = cecrlnana.soc-cd
                            and   bcecrlnana.etab-cd    = cecrlnana.etab-cd
                            and   bcecrlnana.regrp      = cecrlnana.regrp
                            exclusive-lock :
                            bcecrlnana.regrp = "".
                        end.
                    end.
                    delete cecrlnana.
                end.

                /** LETTRAGE **/

                if cecrln.lettre ne "" then
                do :
                    for each bcecrln where bcecrln.soc-cd       = cecrln.soc-cd
                        and bcecrln.etab-cd      = cecrln.etab-cd
                        and bcecrln.sscoll-cle   = cecrln.sscoll-cle
                        and bcecrln.cpt-cd       = cecrln.cpt-cd
                        and bcecrln.dacompta     >= (if ietab.exercice
                        then ietab.dadebex2
                        else ietab.dadebex1)
                        and bcecrln.lettre       = cecrln.lettre exclusive-lock :
                        assign
                            bcecrln.lettre     = ""
                            bcecrln.flag-let   = false
                            bcecrln.dalettrage = ?
                            .
                    end.
                end.
                find tmp-cpt where tmp-cpt.cpt-cd = cecrln.cpt-cd
                    and tmp-cpt.sscoll-cle = cecrln.sscoll-cle no-lock no-error.
                if not available tmp-cpt then
                do :
                    create tmp-cpt.
                    assign
                        tmp-cpt.sscoll-cle = cecrln.sscoll-cle
                        tmp-cpt.coll-cle   = cecrln.coll-cle
                        tmp-cpt.cpt-cd     = cecrln.cpt-cd
                        tmp-cpt.etab-cd    = cecrln.etab-cd.
                end.
                delete cecrln.
            end. /* cecrln */
            run effaparm.
            assign
                /*cecrsai.lib   = "SUPPRESSION LE " + STRING(TODAY,"99/99/9999") + " " + STRING(TIME,"HH:MM:SS") + " " + GiUsrId*/ /**Modif OF le 17/04/13**/
                cecrsai.lib   = cecrsai.lib + " - SUPPRESSION LE " + STRING(today,"99/99/9999") + " à " + STRING(time,"HH:MM:SS") + " par " + GiUsrId
                cecrsai.mtdev = 0.

        end.
        else
        do : /* La piece à supprimer est en dehors de la periode du gest -> OD */

            /****************************************
               AFFECTATION piece-int et piece-compta    (Ajout OF le 28/05/99 pour Avance/echu)
            *****************************************/

            find cnumpiec where cnumpiec.soc-cd     = cGiCodeSoc
                and cnumpiec.etab-cd    = cGiCodeEtab
                and cnumpiec.jou-cd     = cecrsai.jou-cd
                and cnumpiec.prd-cd     = iprd.prd-cd
                and cnumpiec.prd-num    = iprd.prd-num
                exclusive-lock no-error.
            if available cnumpiec
                then assign
                    tmp-piece-int         = cnumpiec.piece-int + 1
                    cnumpiec.piece-int    = tmp-piece-int
                    cnumpiec.piece-compta = cnumpiec.piece-compta + 1
                    tmp-piece-compta      = cnumpiec.piece-compta
                    .
            else
            do:
                create cnumpiec.

                assign
                    cnumpiec.soc-cd  = cGiCodeSoc
                    cnumpiec.etab-cd = cGiCodeEtab
                    cnumpiec.jou-cd  = cecrsai.jou-cd
                    cnumpiec.prd-cd  = iprd.prd-cd
                    cnumpiec.prd-num = iprd.prd-num.

                /*gga
                             RUN VALUE (RprunBatStd-in + "inumpiec.p")
                                (INPUT-OUTPUT cnumpiec.piece-compta,
                                        INPUT ijou.fpiece,
                                        INPUT dDacompta-in).
                gga*/
                run compta/souspgm/inumpiec.p (input-output cnumpiec.piece-compta,
                    input ijou.fpiece,
                    input dDacompta-in).

                assign
                    cnumpiec.piece-int    = 1
                    tmp-piece-int         = 1
                    cnumpiec.piece-compta = cnumpiec.piece-compta + 1
                    tmp-piece-compta      = cnumpiec.piece-compta
                    .

            end.

            create cecrsai-buf.
            buffer-copy cecrsai to cecrsai-buf
                assign
                cecrsai-buf.usrid           = GiUsrId
                cecrsai-buf.prd-cd          = iprd.prd-cd
                cecrsai-buf.prd-num         = iprd.prd-num
                cecrsai-buf.dadoss          = ?
                cecrsai-buf.dacompta        = dDacompta-in
                cecrsai-buf.piece-int       = tmp-piece-int
                cecrsai-buf.piece-compta    = tmp-piece-compta
                .

            for each cecrln
                where cecrln.soc-cd           = cecrsai.soc-cd
                and cecrln.mandat-cd        = cecrsai.etab-cd
                and cecrln.jou-cd           = cecrsai.jou-cd
                and cecrln.mandat-prd-cd    = cecrsai.prd-cd
                and cecrln.mandat-prd-num   = cecrsai.prd-num
                and cecrln.piece-int        = cecrsai.piece-int
                exclusive-lock :

                create cecrln-buf.
                buffer-copy cecrln to cecrln-buf
                    assign
                    cecrln-buf.piece-int        = cecrsai-buf.piece-int
                    cecrln-buf.sens             = not cecrln.sens
                    cecrln-buf.prd-cd           = cecrsai-buf.prd-cd
                    cecrln-buf.prd-num          = cecrsai-buf.prd-num
                    cecrln-buf.dacompta         = cecrsai-buf.dacompta
                    cecrln-buf.mandat-prd-cd    = cecrsai-buf.prd-cd
                    cecrln-buf.mandat-prd-num   = cecrsai-buf.prd-num
                    cecrln-buf.lib-ecr[1]       = "SUP " + cecrln-buf.lib-ecr [1]
                    cecrln-buf.lib              = "SUP " + cecrln-buf.lib
                    /**Ajout OF le 10/08/10**/
                    cecrln-buf.lettre           = ""
                    cecrln-buf.flag-lettre      = false
                    cecrln-buf.dalettrage       = ?
                    /** **/
                    .

                find tmp-cpt where tmp-cpt.cpt-cd     = cecrln-buf.cpt-cd
                    and tmp-cpt.sscoll-cle = cecrln-buf.sscoll-cle no-lock no-error.
                if not available tmp-cpt then
                do :
                    create tmp-cpt.
                    assign
                        tmp-cpt.sscoll-cle = cecrln-buf.sscoll-cle
                        tmp-cpt.coll-cle   = cecrln-buf.coll-cle
                        tmp-cpt.cpt-cd     = cecrln-buf.cpt-cd
                        tmp-cpt.etab-cd    = cecrln-buf.etab-cd.
                end.

            end. /** for each cecrln **/

            /*cecrsai.lib = "SUPPRESSION LE " + STRING(TODAY,"99/99/9999") + " " + STRING(TIME,"HH:MM:SS") + " " + GiUsrId.*/	/* NP 1215/0002 */
            cecrsai.lib = cecrsai.lib + " - SUPPRESSION LE " + STRING(today,"99/99/9999") + " " + STRING(time,"HH:MM:SS") + " " + GiUsrId.

            find cecrsai where rowid(cecrsai) = ROWID(cecrsai-buf) exclusive-lock no-error.
            cecrsai.situ = true.

            recno-sai = rowid(cecrsai). /* utilisé dans cptmvtu */

            /*----ANNULATION DES APBCO LIES A LA MUTATION ----*/

            assign
                cLien-Apbco-cecrsai-annulle = string(cecrsai.soc-cd)       + "|" +
                       STRING(cecrsai.etab-cd)      + "|" +
                       STRING(cecrsai.jou-cd)       + "|" +
                       STRING(cecrsai.prd-cd)       + "|" +
                       STRING(cecrsai.prd-num)      + "|" +
                       STRING(cecrsai.piece-compta).

            run Annulle_Apbco(input cLien-Apbco-cecrsai,
                input dDacompta-in,
                input cLien-Apbco-cecrsai-annulle).

/*gga
            run VALUE(RpRunBatSpe-in + "cptmvt.p").
gga*/
            run compta/souspgm/cptmvt.p (input recno-sai).
            run effaparm.
            release cnumpiec.

        end. /* else */

        run lettrage.

        iErr-out = 0. /* Pas d'erreur */

    end. /* Trans */

/*gga
    tmp-cron = FALSE.
gga*/
end procedure. /* Sup_Comptabilisation */

procedure Sup_Apbco :

    define input parameter cLien-Apbco-cecrsai-in  as character no-undo.

    define variable clstcpt  as character no-undo.
    define variable cref-num as character no-undo.
    define variable cnoexe   as character no-undo.
    define variable cnoapp   as character no-undo.
    define variable NoImmUse as integer   no-undo.
    define variable TpBudUse as character no-undo.
    define variable NoBudUse as integer   no-undo.
    define variable cNature  as character no-undo. /* DM 0207/0077 */

    define buffer bijou for ijou.
    define variable cLien-apbco-cecrsai as character no-undo.
    define variable lerr                as logical   no-undo.
    define variable lsup                as logical   no-undo.

    run Criteres_Detail_Par_Lot(output lerr,
        output cLien-apbco-cecrsai,
        output clstcpt,
        output cref-num,
        output cnoexe, output cnoapp,
        output NoImmUse,
        output TpBudUse, output NoBudUse,
        output cnature).
    if lerr then return.

    find first bijou where bijou.soc-cd     = cecrsai.soc-cd
        and   bijou.etab-cd    = cecrsai.etab-cd
        and   bijou.jou-cd     = cecrsai.jou-cd
        no-lock no-error.
    if not available bijou then return.
    case bijou.natjou-gi:
        /** AFB , AFHB , AFTX, AFTA **/
        when 50 or
        when 60 or
        when 65 or
        when 74 then
            do: /**Ajout AFTA 74 par OF le 11/01/17**/
                lsup = false.
                for each apbco where apbco.tpbud = TpBudUse
                    and   apbco.nobud = NoBudUse
                    and   apbco.nomdt = intnt.nocon
                    and   apbco.noimm = NoImmUse
                    and   apbco.tpapp = cNature
                    and   apbco.noapp = INTEGER(cNoApp)
                    and   apbco.lbdiv2 = cLien-apbco-cecrsai-in
                    exclusive-lock :
                    lsup = true.
                    if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                        then
                        delete apbco.
                end. /** FOR EACH apbco **/

                if not lsup
                    then
                    for each apbco where apbco.tpbud = TpBudUse
                        and   apbco.nobud = NoBudUse
                        and   apbco.nomdt = intnt.nocon
                        and   apbco.noimm = NoImmUse
                        and   apbco.tpapp = cNature
                        and   apbco.noapp = INTEGER(cNoApp)
                        /*AND   apbco.noord = 0*/	/* NP 0306/0238 ne devrais pas passer par là mais je laisse */
                        /*AND   (apbco.noord = 0 OR apbco.noord = 50)*/	/* NP 0613/0022 */
                        and   (apbco.noord = 0 or apbco.noord = 50 or apbco.noord = 90)
                        exclusive-lock :
                        if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                            then
                            delete apbco.
                    end. /** FOR EACH apbco **/
            end.
        otherwise
        do :
            for each apbco where apbco.tpbud = TpBudUse
                and   apbco.nobud = NoBudUse
                and   apbco.nomdt = intnt.nocon
                and   apbco.noimm = NoImmUse
                and   apbco.tpapp = /* DM 0207/0077 "BU" */ cNature
                and   apbco.noapp = INTEGER(cNoApp)
                and   apbco.noord <> 0
                and   apbco.lbdiv2 = cLien-apbco-cecrsai-in
                exclusive-lock :
                if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                    then
                    delete apbco.

            end. /** FOR EACH apbco **/
        end.
    end case.

end procedure. /* Sup_Apbco */

procedure Annulle_Apbco :

    define input parameter  cLien-Apbco-cecrsai-in              as character       no-undo.
    define input  parameter dDacompta-in                        as date            no-undo.
    define input  parameter cLien-apbco-cecrsai-annulle-in      as character       no-undo.

    define variable clstcpt  as character no-undo.
    define variable cref-num as character no-undo.
    define variable cnoexe   as character no-undo.
    define variable cnoapp   as character no-undo.
    define variable NoImmUse as integer   no-undo.
    define variable TpBudUse as character no-undo.
    define variable NoBudUse as integer   no-undo.
    define variable cnature  as character no-undo.
    define variable NoordMax as integer   no-undo.

    define buffer bijou for ijou.
    define variable cLien-apbco-cecrsai as character no-undo.
    define variable lerr                as logical   no-undo.
    define variable lsup                as logical   no-undo.

    run Criteres_Detail_Par_Lot(output lerr,
        output cLien-apbco-cecrsai,
        output clstcpt,
        output cref-num,
        output cnoexe, output cnoapp,
        output NoImmUse,
        output TpBudUse, output NoBudUse,
        output cnature).
    if lerr then return.

    NoordMax = 0.
    for each apbco where apbco.tpbud = TpBudUse
        and   apbco.nobud = NoBudUse
        and   apbco.nomdt = intnt.nocon
        and   apbco.noimm = NoImmUse
        and   apbco.tpapp = cnature
        and   apbco.noapp = INTEGER(cNoApp)
        /*AND   apbco.noord <> 0*/	/* NP 0306/0238 */
        and   apbco.noord <> 0 and apbco.noord < 50
        no-lock :
        if NoordMax < apbco.noord then NoordMax = apbco.noord.
    end.

    find first bijou where bijou.soc-cd     = cecrsai.soc-cd
        and   bijou.etab-cd    = cecrsai.etab-cd
        and   bijou.jou-cd     = cecrsai.jou-cd
        no-lock no-error.
    if not available bijou then return.

    case bijou.natjou-gi:
        /** AFB , AFHB , AFTX, AFTA **/
        when 50 or
        when 60 or
        when 65 or
        when 74 then
            do: /**Ajout AFTA 74 par OF le 11/01/17**/

                lsup = false.
                NoordMax = NoordMax + 1.

                for each apbco where apbco.tpbud = TpBudUse
                    and   apbco.nobud = NoBudUse
                    and   apbco.nomdt = intnt.nocon
                    and   apbco.noimm = NoImmUse
                    and   apbco.tpapp = cnature
                    and   apbco.noapp = INTEGER(cNoApp)
                    and   apbco.lbdiv2 = cLien-apbco-cecrsai-in
                    exclusive-lock
                    break by apbco.nocop :

                    lsup = true.

                    if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                        then
                    do :
                        create apbco-buf.
                        buffer-copy apbco to apbco-buf
                            assign
                            apbco-buf.noord     = NoordMax
                            apbco-buf.mtlot     = - 1 * apbco.mtlot
                            apbco-buf.cdcsy     = "suppiec.i:Annulle_Apbco"
                            apbco-buf.dtapp     = dDacompta-in
                            apbco-buf.lbdiv2    = cLien-apbco-cecrsai-annulle-in
                            .
                    end.

                end. /** FOR EACH apbco **/

                if not lsup
                    then
                    for each apbco where apbco.tpbud = TpBudUse
                        and   apbco.nobud = NoBudUse
                        and   apbco.nomdt = intnt.nocon
                        and   apbco.noimm = NoImmUse
                        and   apbco.tpapp = cnature
                        and   apbco.noapp = INTEGER(cNoApp)
                        /*AND   apbco.noord = 0*/	/* NP 0613/0022 */
                        and   (apbco.noord = 0 or apbco.noord = 90)
                        exclusive-lock
                        break by apbco.nocop :

                        if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                            then
                        do :
                            create apbco-buf.
                            buffer-copy apbco to apbco-buf
                                assign
                                apbco-buf.noord     = NoordMax
                                apbco-buf.mtlot     = - 1 * apbco.mtlot
                                apbco-buf.cdcsy     = "suppiec.i:Annulle_Apbco"
                                apbco-buf.dtapp     = dDacompta-in
                                apbco-buf.lbdiv2    = cLien-apbco-cecrsai-annulle-in
                                .
                        end.

                    end. /** FOR EACH apbco **/

            end.
        otherwise
        do :

            NoordMax = NoordMax + 1.

            for each apbco where apbco.tpbud = TpBudUse
                and   apbco.nobud = NoBudUse
                and   apbco.nomdt = intnt.nocon
                and   apbco.noimm = NoImmUse
                and   apbco.tpapp = cnature
                and   apbco.noapp = INTEGER(cNoApp)
                and   apbco.cdcsy = "mutapbu.p"
                and   apbco.noord <> 0
                and   apbco.lbdiv2 = cLien-apbco-cecrsai-in
                exclusive-lock
                break by apbco.nocop :

                if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                    then
                do :
                    create apbco-buf.
                    buffer-copy apbco to apbco-buf
                        assign
                        apbco-buf.noord     = NoordMax
                        apbco-buf.mtlot     = - 1 * apbco.mtlot
                        apbco-buf.cdcsy     = "supapbu.p"
                        apbco-buf.dtapp     = dDacompta-in
                        apbco-buf.lbdiv2    = cLien-apbco-cecrsai-annulle-in
                        .
                end.

            end. /** FOR EACH apbco **/

        end.
    end case.


end procedure. /* Annulle_Apbco */

procedure Dupplique_Apbco :

    define input parameter  cLien-Apbco-cecrsai-in              as character       no-undo.
    define input  parameter dDacompta-in                        as date            no-undo.
    define input  parameter cLien-apbco-cecrsai-annulle-in      as character       no-undo.

    define variable clstcpt  as character no-undo.
    define variable cref-num as character no-undo.
    define variable cnoexe   as character no-undo.
    define variable cnoapp   as character no-undo.
    define variable NoImmUse as integer   no-undo.
    define variable TpBudUse as character no-undo.
    define variable NoBudUse as integer   no-undo.
    define variable cnature  as character no-undo.
    define variable NoordMax as integer   no-undo.

    define buffer bijou for ijou.
    define variable cLien-apbco-cecrsai as character no-undo.
    define variable lerr                as logical   no-undo.
    define variable lsup                as logical   no-undo.

    run Criteres_Detail_Par_Lot(output lerr,
        output cLien-apbco-cecrsai,
        output clstcpt,
        output cref-num,
        output cnoexe, output cnoapp,
        output NoImmUse,
        output TpBudUse, output NoBudUse,
        output cnature).
    if lerr then return.


    NoordMax = 0.
    for each apbco where apbco.tpbud = TpBudUse
        and   apbco.nobud = NoBudUse
        and   apbco.nomdt = intnt.nocon
        and   apbco.noimm = NoImmUse
        and   apbco.tpapp = cnature
        and   apbco.noapp = INTEGER(cNoApp)
        /*AND   apbco.noord <> 0*/	/* NP 0306/0238 */
        and   apbco.noord <> 0 and apbco.noord < 50
        no-lock :
        if NoordMax < apbco.noord then NoordMax = apbco.noord.
    end.

    find first bijou where bijou.soc-cd     = cecrsai.soc-cd
        and   bijou.etab-cd    = cecrsai.etab-cd
        and   bijou.jou-cd     = cecrsai.jou-cd
        no-lock no-error.
    if not available bijou then return.

    case bijou.natjou-gi:
        /** AFB , AFHB , AFTX, AFTA **/
        when 50 or
        when 60 or
        when 65 or
        when 74 then
            do: /**Ajout AFTA 74 par OF le 11/01/17**/

                lsup = false.
                NoordMax = NoordMax + 1.

                for each apbco where apbco.tpbud = TpBudUse
                    and   apbco.nobud = NoBudUse
                    and   apbco.nomdt = intnt.nocon
                    and   apbco.noimm = NoImmUse
                    and   apbco.tpapp = cnature
                    and   apbco.noapp = INTEGER(cNoApp)
                    and   apbco.lbdiv2 = cLien-apbco-cecrsai-in
                    exclusive-lock
                    break by apbco.nocop :

                    lsup = true.

                    if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                        then
                    do :
                        create apbco-buf.
                        buffer-copy apbco to apbco-buf
                            assign
                            apbco-buf.noord     = NoordMax
                            apbco-buf.mtlot     = apbco.mtlot
                            apbco-buf.cdcsy     = "suppiec.i:Dupplique_Apbco"
                            apbco-buf.dtapp     = dDacompta-in
                            apbco-buf.lbdiv2    = cLien-apbco-cecrsai-annulle-in
                            .
                    end.

                end. /** FOR EACH apbco **/

                if not lsup
                    then
                    for each apbco where apbco.tpbud = TpBudUse
                        and   apbco.nobud = NoBudUse
                        and   apbco.nomdt = intnt.nocon
                        and   apbco.noimm = NoImmUse
                        and   apbco.tpapp = cnature
                        and   apbco.noapp = INTEGER(cNoApp)
                        /*AND   apbco.noord = 0*/	/* NP 0613/0022 */
                        and   (apbco.noord = 0 or apbco.noord = 90)
                        exclusive-lock
                        break by apbco.nocop :

                        if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                            then
                        do :
                            create apbco-buf.
                            buffer-copy apbco to apbco-buf
                                assign
                                apbco-buf.noord     = NoordMax
                                apbco-buf.mtlot     = apbco.mtlot
                                apbco-buf.cdcsy     = "suppiec.i:Dupplique_Apbco"
                                apbco-buf.dtapp     = dDacompta-in
                                apbco-buf.lbdiv2    = cLien-apbco-cecrsai-annulle-in
                                .
                        end.

                    end. /** FOR EACH apbco **/

            end.
        otherwise
        do :

            NoordMax = NoordMax + 1.

            for each apbco where apbco.tpbud = TpBudUse
                and   apbco.nobud = NoBudUse
                and   apbco.nomdt = intnt.nocon
                and   apbco.noimm = NoImmUse
                and   apbco.tpapp = cnature
                and   apbco.noapp = INTEGER(cNoApp)
                and   apbco.cdcsy = "mutapbu.p"
                and   apbco.noord <> 0
                and   apbco.lbdiv2 = cLien-apbco-cecrsai-in
                exclusive-lock
                break by apbco.nocop :

                if lookup(string(apbco.nocop,"99999"),clstcpt,",") <> 0
                    then
                do :
                    create apbco-buf.
                    buffer-copy apbco to apbco-buf
                        assign
                        apbco-buf.noord     = NoordMax
                        apbco-buf.mtlot     = apbco.mtlot
                        apbco-buf.cdcsy     = "supapbu.p"
                        apbco-buf.dtapp     = dDacompta-in
                        apbco-buf.lbdiv2    = cLien-apbco-cecrsai-annulle-in
                        .
                end.

            end. /** FOR EACH apbco **/

        end.
    end case.




end procedure. /* Dupplique_Apbco */

procedure Recherche_Apbco :

    define variable cDateInc     as character no-undo.
    define variable cSigneTotDep as character no-undo.
    define variable cMntQuoDep   as character no-undo.

    define buffer bijou for ijou.
    define variable cLien-apbco-cecrsai as character no-undo.
    define variable clstcpt             as character no-undo.
    define variable cref-num            as character no-undo.
    define variable cnoexe              as character no-undo.
    define variable cnoapp              as character no-undo.
    define variable NoImmUse            as integer   no-undo.
    define variable TpBudUse            as character no-undo.
    define variable NoBudUse            as integer   no-undo.
    define variable cnature             as character no-undo.
    define variable lerr                as logical   no-undo.

    run Criteres_Detail_Par_Lot(output lerr,
        output cLien-apbco-cecrsai,
        output clstcpt,
        output cref-num,
        output cnoexe, output cnoapp,
        output NoImmUse,
        output TpBudUse, output NoBudUse,
        output cnature).
    if lerr then return.

    for each apbco-tmp :
        delete apbco-tmp.
    end.

    find first bijou where bijou.soc-cd     = cecrsai.soc-cd
        and   bijou.etab-cd    = cecrsai.etab-cd
        and   bijou.jou-cd     = cecrsai.jou-cd
        no-lock no-error.
    if not available bijou then return.

    case bijou.natjou-gi:
        /** AFB , AFHB , AFTX, AFTA **/
        when 50 or
        when 60 or
        when 65 or
        when 74 then
            do: /**Ajout AFTA 74 par OF le 11/01/17**/

                for each apbco where apbco.tpbud = TpBudUse
                    and   apbco.nobud = NoBudUse
                    and   apbco.nomdt = intnt.nocon
                    and   apbco.noimm = NoImmUse
                    and   apbco.tpapp = cnature
                    and   apbco.noapp = INTEGER(cNoApp)
                    and   apbco.lbdiv2 = cLien-apbco-cecrsai
                    no-lock :

                    create apbco-tmp.
                    buffer-copy apbco to apbco-tmp.

                end. /** FOR EACH apbco **/
                if not can-find (first apbco-tmp ) then
                do :
                    for each apbco where apbco.tpbud = TpBudUse
                        and   apbco.nobud = NoBudUse
                        and   apbco.nomdt = intnt.nocon
                        and   apbco.noimm = NoImmUse
                        and   apbco.tpapp = cnature
                        and   apbco.noapp = INTEGER(cNoApp)
                        /*AND   apbco.noord = 0 */		/* NP 0613/0022 */
                        and   (apbco.noord = 0 or apbco.noord = 90)
                        no-lock :
                        create apbco-tmp.
                        buffer-copy apbco to apbco-tmp.
                    end. /** FOR EACH apbco **/
                end.

            end.
        otherwise
        do :
            for each apbco where apbco.tpbud = TpBudUse
                and   apbco.nobud = NoBudUse
                and   apbco.nomdt = intnt.nocon
                and   apbco.noimm = NoImmUse
                and   apbco.tpapp = cnature
                and   apbco.noapp = INTEGER(cNoApp)
                and   apbco.noord <> 0
                and   apbco.lbdiv2 = cLien-apbco-cecrsai
                no-lock :

                create apbco-tmp.
                buffer-copy apbco to apbco-tmp.

            end. /** FOR EACH apbco **/
        end.
    end case.

end procedure. /* Recherche_Apbco */

procedure Criteres_Detail_Par_Lot:

    define output parameter lerr                        as logical      no-undo.
    define output parameter cLien-apbco-cecrsai         as character    no-undo.
    define output parameter clstcpt                     as character    no-undo.
    define output parameter cref-num                    as character    no-undo.
    define output parameter cnoexe                      as character    no-undo.
    define output parameter cnoapp                      as character    no-undo.
    define output parameter NoImmUse                    as integer      no-undo.
    define output parameter TpBudUse                    as character    no-undo.
    define output parameter NoBudUse                    as integer      no-undo.
    define output parameter cnature                     as character    no-undo.

    assign
        cLien-Apbco-cecrsai = string(cecrsai.soc-cd)       + "|" +
                   STRING(cecrsai.etab-cd)      + "|" +
                   STRING(cecrsai.jou-cd)       + "|" +
                   STRING(cecrsai.prd-cd)       + "|" +
                   STRING(cecrsai.prd-num)      + "|" +
                   STRING(cecrsai.piece-compta).

    /* DM 0207/0077

    cnature = "BU".

    **/

    /*---- Recherche de l'appel de fonds régularisé lors de la mutation ----*/

    find first cecrln where   cecrln.soc-cd             = cecrsai.soc-cd
        and   cecrln.mandat-cd          = cecrsai.etab-cd
        and   cecrln.mandat-prd-cd      = cecrsai.prd-cd
        and   cecrln.mandat-prd-num     = cecrsai.prd-num
        and   cecrln.jou-cd             = cecrsai.jou-cd
        and   cecrln.piece-int          = cecrsai.piece-int
        no-lock no-error.
    if not available cecrln then
    do :
        lerr = true.
        return.
    end.

    if      not cecrln.ref-num matches "*AFB..*"
        and not cecrln.ref-num matches "*AFTX.*" /* DM 0207/0077 */
        and not cecrln.ref-num matches "*AFHB.*" /* DM 0207/0077 */
        and not cecrln.ref-num matches "*AFTA.*" /**Ajout OF le 11/01/17**/
        then
    do :
        lerr = true.
        return.
    end.

    /* DM 0207/0077 */

    case entry(1,cecrln.ref-num,".") :
        when "AFTX" then
            cNature = "TX".
        when "AFHB" then
            cNature = "HB".
        when "AFTA" then
            cNature = "TA". /**Ajout OF le 11/01/17**/
        otherwise
        cNature = "BU".
    end.

    /** FIN DM */

    /** si cecrln.ref-num = AFB..1301 alors cref-num = 1301, cnoexe = 13 et cnoapp = 01 **/

    cref-num = trim(entry(num-entries(cecrln.ref-num,"."),cecrln.ref-num,".")).

    if length(cref-num) = 4
        then
        assign cnoexe = substring(cref-num,1,2) cnoapp = substring(cref-num,3,2).
    else
    do:
        lerr = true.
        return.
    end.

    /* Recherche du vendeur et de l'acheteur */

    clstcpt = "".
    for each cecrln where cecrln.soc-cd             = cecrsai.soc-cd
        and   cecrln.mandat-cd          = cecrsai.etab-cd
        and   cecrln.mandat-prd-cd      = cecrsai.prd-cd
        and   cecrln.mandat-prd-num     = cecrsai.prd-num
        and   cecrln.jou-cd             = cecrsai.jou-cd
        and   cecrln.piece-int          = cecrsai.piece-int
        no-lock :
        if lookup(cecrln.cpt-cd,clstcpt,",") = 0 then
        do :
            if clstcpt <> "" then clstcpt = clstcpt + ",".
            clstcpt = clstcpt + cecrln.cpt-cd.
        end.
    end.

    /* Recherche de l'immeuble du mandat */

    find first intnt
        where	intnt.tpidt = "02001"
        and	intnt.tpcon = "01003"
        and	intnt.nocon = cecrsai.etab-cd
        no-lock no-error.

    if not available Intnt then
    do :
        lerr = true.
        return.
    /** NEXT.     **/
    end.

    assign
        NoImmUse = intnt.noidt.

    /* DM 0207/0077

        TpBudUse = "01008"
        NoBudUse = INT(STRING(intnt.nocon, "9999") + STRING(INTEGER(cNoExe), "99999")).

    */

    case cNature :
        when "HB" then
            do :
                TpBudUse = TpBudHB.
                NoBudUse = INT(string(intnt.nocon, /* DM 0608/0065 "9999" */ "99999") + STRING(0, "99999")).
            end.
        when "BU" then
            do :
                TpBudUse = TpBudBU.
                NoBudUse = INT(string(intnt.nocon, /* DM 0608/0065 "9999" */ "99999") + STRING(integer(cNoExe), "99999")).
            end.
        /**Ajout OF le 11/01/17**/
        when "TA" then
            do :
                TpBudUse = TpBudTA.
                NoBudUse = INT(string(intnt.nocon, "99999") + STRING(integer(cNoExe), "99999")).
            end.
        /** **/
        otherwise
        do :
            TpBudUse = TpBudTvrx /** "01008" **/.
            NoBudUse = INT(string(intnt.nocon, /* DM 0608/0065 "9999" */ "99999") + STRING(integer(cNoExe), "99999")).
        end.
    end case.

/* FIN DM */

end procedure. /** Criteres_Detail_Par_Lot **/
gga*/

