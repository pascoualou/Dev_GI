/*------------------------------------------------------------------------
File        : organismesSociauxPegase.p
Purpose     : Visualisation infos organismes sociaux de Paie Pégase
Author(s)   : GGA - 2017/11/16
Notes       : a partir de adb/tache/prmmtpeg.p
derniere revue: 2018/04/10 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageCorrespondance.
using parametre.pclie.parametrageCorrespondancePegase.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/paie/include/organismesSociauxPegase.i}
{application/include/glbsepar.i}

{comm/include/prclbdiv.i}
{comm/include/prccoros.i}

procedure getOrgSociauxSalarie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beGestionSalariePegase.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat    as character no-undo.
    define input parameter piNumeroSalarie as int64     no-undo.
    define output parameter table for ttOrganismeSociauxPegase.

    define variable viNumeroMandat  as int64     no-undo.
    define variable viI             as integer   no-undo.
    define variable vcListeOrgSoc   as character no-undo.

    define buffer salar for salar.

    empty temp-table ttOrganismeSociauxPegase.
    viNumeroMandat = truncate(piNumeroSalarie / 100000, 0). //mandat principal integer(substring(string(piNumeroSalarie, "9999999999"), 1, 5)).
    for first salar no-lock
        where salar.tprol = {&TYPEROLE-salariePegase}
          and salar.norol = piNumeroSalarie:
        vcListeOrgSoc = getValeurParametre ("ORGSOC", "=", separ[2], salar.lbdiv5).
        do viI = 1 to num-entries(vcListeOrgSoc):
            run chgOrgSociauxPrivate (entry(viI, vcListeOrgSoc), viNumeroMandat, pcTypeMandat).
        end.
    end.

end procedure.

procedure getOrgSociauxMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttOrganismeSociauxPegase.

    define variable viI             as integer   no-undo.
    define variable vcListeOrgSoc   as character no-undo.

    define buffer etabl for etabl.

    for first etabl no-lock
        where etabl.tpcon = pcTypeMandat
          and etabl.nocon = piNumeroMandat
          and etabl.tptac = {&TYPETACHE-organismesSociaux}:
        vcListeOrgSoc = getValeurParametre ("ORGSOC", "=", separ[2], etabl.lbdiv5).
        do viI = 1 to num-entries(vcListeOrgSoc):
            run chgOrgSociauxPrivate (entry(viI, vcListeOrgSoc), piNumeroMandat, pcTypeMandat).
        end.
    end.

end procedure.

procedure getOrganisme:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMontantDeclareOrgSociaux.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcOrganisme    as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttOrganismeSociauxPegase.

    run chgOrgSociauxPrivate (pcOrganisme, piNumeroMandat, pcTypeMandat).

end procedure.

procedure chgOrgSociauxPrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcOrganisme    as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.

    define variable vcRefererence          as character no-undo.
    define variable vcPerioDeclarURSSAF    as character no-undo.
    define variable voCorrespondance       as class parametrageCorrespondance       no-undo.
    define variable voCorrespondancePegase as class parametrageCorrespondancePegase no-undo.

    define buffer csscptcol for csscptcol.
    define buffer ifour     for ifour.
    define buffer detail    for detail.

    create ttOrganismeSociauxPegase.
    assign
        ttOrganismeSociauxPegase.cCodeOrganisme    = pcOrganisme
        ttOrganismeSociauxPegase.cLibTypeOrganisme = getLibelleTypeOrganisme (ttOrganismeSociauxPegase.cCodeOrganisme)
        /* Recherche des informations dans la table de correspondance */
        vcRefererence    = (if pcTypeMandat = {&TYPECONTRAT-mandat2Gerance} then mtoken:cRefGerance else mtoken:cRefCopro)
        voCorrespondance = new parametrageCorrespondance (vcRefererence, ttOrganismeSociauxPegase.cCodeOrganisme)
    .
    if voCorrespondance:isDbParameter
    then do:
        assign
            ttOrganismeSociauxPegase.cCollGi           = voCorrespondance:getCollGi()
            ttOrganismeSociauxPegase.cCompteFour       = voCorrespondance:getCompteFournisseur()
            ttOrganismeSociauxPegase.cNomOrganisme     = voCorrespondance:getNomOrganisme()
            ttOrganismeSociauxPegase.cAdresseOrganisme = voCorrespondance:getAdresseOrganisme()
        .
        if ttOrganismeSociauxPegase.cCollGi > ""
        then for first csscptcol no-lock
            where csscptcol.soc-cd   = integer(vcRefererence)
              and csscptcol.coll-cle = ttOrganismeSociauxPegase.cCollGi
              and csscptcol.etab-cd  = piNumeroMandat:
            assign
                ttOrganismeSociauxPegase.cCompte        = csscptcol.sscoll-cpt
                ttOrganismeSociauxPegase.cLibelleCollGi = csscptcol.lib
            .
            for first ifour no-lock
                where ifour.soc-cd   = integer(vcRefererence)
                  and ifour.coll-cle = ttOrganismeSociauxPegase.cCollGi
                  and ifour.cpt-cd   = ttOrganismeSociauxPegase.cCompteFour:
                assign
                    ttOrganismeSociauxPegase.cNomFour        = ifour.nom
                    ttOrganismeSociauxPegase.cAdresseFour    = ifour.adr[1]
                    ttOrganismeSociauxPegase.cCPFour         = ifour.cp
                    ttOrganismeSociauxPegase.cVilleFour      = ifour.ville
                    ttOrganismeSociauxPegase.cCleFour        = ifour.four-cle
                    ttOrganismeSociauxPegase.cCPVilleFourGI  = substitute('&1 &2', trim(ifour.cp), trim(ifour.ville))
                    ttOrganismeSociauxPegase.identifiantGI   = trim(replace(ifour.four-cle, ttOrganismeSociauxPegase.cCollGi, ""))        /* ifour.cCleFour sans ifour.coll-cle */
                    ttOrganismeSociauxPegase.cLibelleAdresse = "" 
                .
            end.
        end.
    end.
    for last detail no-lock
       where detail.cddet = "PZ_ORGSC_" + pcTypeMandat
         and detail.nodet = piNumeroMandat
         and detail.ixd01 = pcOrganisme:
        assign
            ttOrganismeSociauxPegase.cPerioDeclar = (if detail.tbchr[3] <> ? then detail.tbchr[3] else "")   /* mis à jour par adporgsc.p */
            ttOrganismeSociauxPegase.cExigibilite = detail.tbchr[6]
        .
    end.
    /* Ajout SY le 12/07/2016 : Recherche périodicité URSSAF */
    vcPerioDeclarURSSAF = "".
    for last detail no-lock
        where detail.cddet = "PZ_ORGSC_" + pcTypeMandat
          and detail.nodet = piNumeroMandat
          and detail.ixd01 begins "U":
        vcPerioDeclarURSSAF = detail.tbchr[3].
    end.
    for last detail no-lock
       where detail.cddet = "PZ_ORGSC_" + pcTypeMandat
         and detail.nodet = piNumeroMandat
         and detail.ixd01 = pcOrganisme:
        assign
            ttOrganismeSociauxPegase.cNoAffiliation        = detail.tbchr[1]
            ttOrganismeSociauxPegase.cModeReg              = detail.tbchr[2]                     /* mis à jour par adporgsc.p */
            ttOrganismeSociauxPegase.cPerioDeclar          = (if detail.tbchr[3] <> ? then detail.tbchr[3] else "")                  /* mis à jour par adporgsc.p */
            ttOrganismeSociauxPegase.cEtabRattach          = (if integer(detail.tbchr[5]) > 0 then string(integer(detail.tbchr[5]), "99999") else "")
            ttOrganismeSociauxPegase.cExigibilite          = detail.tbchr[6]
            ttOrganismeSociauxPegase.cPerioTaxe            = detail.tbchr[7]
            ttOrganismeSociauxPegase.cRefInterneEdi        = detail.tbchr[8]            /* SY 0316/0282 Gestion référence interne Virement Organisme */
            ttOrganismeSociauxPegase.cFlgPeriodiciteUrssaf = detail.tbchr[9].           /* SY 27/10/2016 pour DSN obligatoire à partir de 2017 */
        .
        if ttOrganismeSociauxPegase.cPerioDeclar = ? or ttOrganismeSociauxPegase.cPerioDeclar = "" 
        then do:
            if ttOrganismeSociauxPegase.cCodeOrganisme begins "R"
            then do:
                if ttOrganismeSociauxPegase.cFlgPeriodiciteUrssaf = "0" or ttOrganismeSociauxPegase.cFlgPeriodiciteUrssaf = "1"
                then ttOrganismeSociauxPegase.cPerioDeclar = (if ttOrganismeSociauxPegase.cFlgPeriodiciteUrssaf = "0" then "(Mens)" else "(Trim)").  /* obl à partir de Janvier 2017 */
                else ttOrganismeSociauxPegase.cPerioDeclar = (if vcPerioDeclarURSSAF = "DUCSM" then "(Mens)" else "(Trim)").     /* Jusqu'en 2015, RETRAITE avec périodicité Trim / à partir de Janvier 2016 si Périodicité URSSAF Mensuelle alors RETRAITE mensuelle aussi (ALLIANZ) */
            end.
            else if (ttOrganismeSociauxPegase.cCodeOrganisme begins "M" or ttOrganismeSociauxPegase.cCodeOrganisme begins "P")
            then ttOrganismeSociauxPegase.cPerioDeclar = "(Trim)".
        end.
        if ttOrganismeSociauxPegase.cPerioDeclar begins "TAXA"
        then ttOrganismeSociauxPegase.PerioReglt = substring(ttOrganismeSociauxPegase.cPerioDeclar, 5, 1, "character").
        else if ttOrganismeSociauxPegase.cPerioDeclar begins "("
        then ttOrganismeSociauxPegase.PerioReglt = substring(ttOrganismeSociauxPegase.cPerioDeclar, 2, 1, "character").
        else if ttOrganismeSociauxPegase.cCodeOrganisme begins "U"
        then case ttOrganismeSociauxPegase.cFlgPeriodiciteUrssaf:
            when "1" then ttOrganismeSociauxPegase.PerioReglt = "T".
            when "0" then ttOrganismeSociauxPegase.PerioReglt = "M".
            otherwise     ttOrganismeSociauxPegase.PerioReglt = "". 
        end case.
        else ttOrganismeSociauxPegase.PerioReglt = "". 
    end.

    /* recherche compte Pégase */
    voCorrespondancePegase = new parametrageCorrespondancePegase(ttOrganismeSociauxPegase.cCollGi).
    if voCorrespondancePegase:isDbParameter
    then assign
        ttOrganismeSociauxPegase.cCptSalPegase = voCorrespondancePegase:getCptSalPegase()
        ttOrganismeSociauxPegase.cCptPatPegase = voCorrespondancePegase:getCptPatPegase()
    .
end procedure.
