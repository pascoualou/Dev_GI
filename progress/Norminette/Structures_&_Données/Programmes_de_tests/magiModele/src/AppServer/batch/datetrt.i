/*------------------------------------------------------------------------
File        : datetrt.i
Purpose     : Date de prochain de traitement (irf/tva/crg/hono)
Author(s)   : DM 2008/07/19, Kantena - 2018/01/11
Notes       : vient de cadb/exe/batch/datetrt.p - Transformation en include.
    ATTENTION, mettre using parametre.pclie.parametrageNouveauCRG.   dans l'appelant
01  11/04/2011  DM    0411/0025 Pb date honoraire fin de mois crg libre
02  23/01/2012  DM    1010/0218  TVA EDI
03  02/07/2012  DM    0212/0155  Specif BNP Bail proportionnel
04  16/12/2014  SY    1214/0150 Ajout test mandat rattaché en compta
------------------------------------------------------------------------*/
/*
{comm/allincmn.i}
{comm/gstcptdf.i}    
*/
{comm/include/crglibre.i} /* DM 0411/0024 */
{comm/include/declatva.i} /* DM 1010/0218 f_decla_valid */

procedure datetrt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define input  parameter piCodeSociete       as integer   no-undo.
    define input  parameter piCodeEtablissement as integer   no-undo.
    define input  parameter pdaDeclaration      as date      no-undo.
    define output parameter pcParametreRetour   as character no-undo.

    define variable vdaDebutTraitement  as date    no-undo.
    define variable vdaFinTraitement    as date    no-undo.
    define variable vdaDerniereTVA      as date    no-undo.
    define variable vdaDernierCRG       as date    no-undo.
    define variable vdaDernierHonoraire as date    no-undo.
    define variable vdaDernierIRF       as date    no-undo.
    define variable vdaDernierQFL       as date    no-undo. /* DM 0212/0155 */
    define variable vdaDebutCRG         as date    no-undo.
    define variable vdaFinCRG           as date    no-undo.
    define variable vlTraite            as logical no-undo.
    define variable voNouveauCRG        as class parametrageNouveauCRG no-undo.
    define buffer iprd     for iprd.
    define buffer ietab    for ietab.
    define buffer agest    for agest.
    define buffer tache    for tache.
    define buffer trfpm    for trfpm.
    define buffer svtrf    for svtrf.
    define buffer ifdsai   for ifdsai.
    define buffer ahistcrg for ahistcrg.
    define buffer ifdparam for ifdparam.

    find first ietab no-lock
        where ietab.soc-cd  = piCodeSociete
          and ietab.etab-cd = piCodeEtablissement no-error.
    find first agest no-lock
        where agest.Soc-cd   = piCodeSociete
          and agest.gest-cle = ietab.gest-cle no-error.
    /* Ajout SY le 16/12/2014 */
    if not available agest then do:
        mError:createError({&error}, substitute("Erreur (datetrt.p): Le mandat &1 n'est pas rattache a un responsable comptable", piCodeEtablissement)).
        return.
    end.
    /*** date de derniere declaration de tva ***/
    vdaDerniereTVA = f_decla_valid(ietab.etab-cd, piCodeSociete).
    if vdaDerniereTVA = ? then vdaDerniereTVA = 01/01/1901.
    /*** dernier irf validé ***/
    vdaDernierIRF = 01/01/1901.
    for last trfpm no-lock
        where trfpm.tptrf = "IRF"
          and trfpm.tpapp = ""
          and trfpm.nomdt = ietab.etab-cd
          and trfpm.noexe >= 1901
          and trfpm.dtapp <> ?:
        vdaDernierIRF = date(12, 31, trfpm.noexe).
    end.
    /** DM 0212/0155 Specif BNP: La date de dernier quitt bail proportionnel est stockée dans vdaDernierIRF */
    if piCodeSociete = 2053 then do:
        find first tache no-lock
            where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = ietab.etab-cd
              and tache.tptac = {&TYPETACHE-bailProportionnel} no-error.
        if available tache then do:
            /* Dernier mois de quitt validé ? */
            vdaDernierQFL = ?.
            {&_proparse_ prolint-nowarn(sortaccess)}
dernierMois:
            for each svtrf no-lock
                where svtrf.cdtrt = "QUFL"
                  and svtrf.nopha = "N99"
                by svtrf.Mstrt descending:
                assign
                    vdaDernierQFL = date(integer(substring(string(svtrf.mstrt, "999999"), 5, 2, "character")), 1,
                                    integer(substring(string(svtrf.mstrt, "999999"), 1, 4, "character")))
                    vdaDernierQFL = vdaDernierQFL + 31
                    vdaDernierQFL = vdaDernierQFL - day(vdaDernierQFL)    /* Dernier jour du mois de quitt validé */
                .
                leave dernierMois.
            end.
            if vdaDernierQFL <> ? then vdaDernierIRF = maximum(vdaDernierIRF, vdaDernierQFL).
        end.
    end.
    /* periode du crg à la date du mois en cours */
    find first agest no-lock
        where agest.soc-cd = piCodeSociete
          and agest.gest-cle = ietab.gest-cle no-error.
    // todo  a reprendre
    run cadb/prdeng.p(piCodeSociete, ietab.etab-cd, agest.dafin, output vlTraite, output vdaDebutCRG, output vdaFinCRG).
    {&_proparse_ prolint-nowarn(when)}
    assign
        vdaDebutCRG   = 01/01/1901 when vdaDebutCRG = ?
        vdaFinCRG     = 01/31/1901 when vdaFinCRG = ?
        vdaDernierCRG = maximum(vdaDebutCRG - 1, 01/01/1901)        /* dernier crg validé */
        /* Crg local, Le module Edition micro ou site central est-il ouvert ?*/
        voNouveauCRG  = new parametrageNouveauCRG()
    .
    {&_proparse_ prolint-nowarn(use-index)}
    if voNouveauCRG:isNouveauCRGActif()
    then for last ahistcrg no-lock    /* dernier crg edité */
        where ahistcrg.soc-cd  = piCodeSociete
          and ahistcrg.etab-cd = ietab.etab-cd
        use-index histcrg-dtfin:
        vdaDernierCRG = ahistcrg.dtfin.
    end.
    /*** dernier calcul d'honoraires ***/
    vdaDernierHonoraire = 01/01/1901.
    for first ifdparam no-lock
        where ifdparam.soc-dest = piCodeSociete:
        {&_proparse_ prolint-nowarn(use-index)}
        for last ifdsai no-lock
            where ifdsai.soc-cd      = ifdparam.soc-cd
              and ifdsai.etab-cd     = ifdparam.etab-cd
              and ifdsai.typefac-cle = "1"
              and ifdsai.soc-dest    = piCodeSociete
              and ifdsai.etab-dest   = ietab.etab-cd
            use-index fdsai-dafac:    // pas obligatoire, mais plus prudent en cas de modif dico.
            if f_crglibre(ietab.etab-cd)
            then vdaDernierHonoraire = ifdsai.dafac.
            else assign
                vdaDernierHonoraire = ifdsai.dafac - day(ifdsai.dafac) + 32           /* 1er Jour du mois + 31 jours pour mois suivant */
                vdaDernierHonoraire = vdaDernierHonoraire - day(vdaDernierHonoraire)  /* dernier jour du mois */
            .
        end.
    end.
    assign
        /* Mois de prochain traitement = la plus grande des 4 dates */
        vdaFinTraitement   = maximum(vdaDerniereTVA, vdaDernierCRG, vdaDernierIRF, vdaDernierHonoraire, pdaDeclaration - day(pdaDeclaration))
        /* Prochain traitement */
        vdaDebutTraitement = vdaFinTraitement   - day(vdaFinTraitement) + 32    /* 1er jour du mois + 31 jours pour mois suivant du dernier traitement */
        vdaDebutTraitement = vdaDebutTraitement - day(vdaDebutTraitement) + 1   /* 1er du mois suivant = mois du prochain traitement */
        vdaFinTraitement   = vdaDebutTraitement + 31
        vdaFinTraitement   = vdaFinTraitement   - day(vdaFinTraitement)         /* dernier jour du mois  */
    .
    find first iprd no-lock
        where iprd.soc-cd = piCodeSociete
          and iprd.etab-cd = ietab.etab-cd
          and iprd.dadebprd <= vdaFinTraitement
          and iprd.dafinprd >= vdaFinTraitement no-error.
    pcParametreRetour = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8",
                                   chr(9), vdaDebutTraitement, vdaFinTraitement, if available iprd then iprd.prd-num else 0, vdaDerniereTVA, vdaDernierCRG, vdaDernierIRF, vdaDernierHonoraire).
    return.
end procedure. 
