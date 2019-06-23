/*------------------------------------------------------------------------
File        : extencqt.p 
Purpose     : Extraction de l'eclatement des encaissements pour le reporting Detail des quittancements/Encaissements
Author(s)   : OF - 2006/06/15, Kantena - GGA 2018/01/11
Notes       : reprise cadb/src/batch/extencqt.p
01  03/11/06    DM    1006/0282 Edition detail encaissement ne pas prendre les ecr lettrees dans le solde init
02  24/11/06    DM    1106/0082 Prise en compte des OD/Avoirs
03  14/02/08    JR    0108/0343 Modif procecla.i
04  03/09/08    DM    0508/0177 Modif procecla.i
05  03/11/08    JR    1008/0296 Modif procecla.i
06  03/02/09    DM    0109/0232 Filtrer les reguls d'AN
07  07/04/09    DM    0409/0037 Rajout Simulation + rub par defaut
08  07/04/09    DM    0409/0037 Rajout Simulation + rub par defaut
09  06/10/09    DM    0809/0042 Pb période solde début etat excel
10  10/02/2011  DM    0211/0063 Taux de tva du bail par défaut
11  27/06/12    DM    Pas de fiche - Pb extraction regule d'ODT
12  15/05/13    CC    Ajout des LF
13  17/06/13    DM    Extraction hono CRG cardif
14  05/08/13    OF    0714/0239 Mauvais taux TVA du bail -> Modif procecla.i
----------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/listeRubQuit2TVA.i}
&SCOPED-DEFINE IncludeDevelop 0
/*Definition testee dans TbEclat.i et procecla.i*/
&SCOPED-DEFINE REPORT 0
/*Definition testee dans TbEclat.i*/
&SCOPED-DEFINE VARLOC 0

using parametre.pclie.parametrageNouveauCRG.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

/* 
{comm/allincmn.i}
{comm/glblibpr.i}     
{comm/gstcptdf.i}    
{comm/develop.i}
*/

{comm/include/tbeclat01.i} /*Declaration de la table cecrln-enc  */
{comm/include/tbeclat02.i} /*Declaration de la table aligtva-tmp */
{comm/include/tbeclat03.i} /*Declaration de la table impaye      */
{bail/include/rubqt.i}

define input  parameter piCodeSoc         as integer   no-undo.
define input  parameter piNumeroMandat    as integer   no-undo.
define input  parameter pdaDebutQuittance as date      no-undo.
define input  parameter pdaFinQuittance   as date      no-undo.
define input  parameter pcParametreDivers as character no-undo.
define output parameter table for aligtva-tmp.
define output parameter pcRetour          as character no-undo.

define variable goNouveauCrg as class parametrageNouveauCRG no-undo.
define variable ghProcRubqt  as handle  no-undo.
define variable ghOutilsTva  as handle  no-undo.
define variable glExtractCRG as logical no-undo. /* DM 0113/0150, utilisé dans procecla.i */
define variable glSimulation as logical no-undo. 
define variable glFlagLF     as logical no-undo. 

{comm/include/tbeclat04.i}
{comm/include/tbeclat05.i}
{comm/include/tbeclat06.i}

{batch/datetrt.i}
{comm/include/datean.i}            //  fonction f_DebExeClot

define buffer ietab for ietab.      // todo   pour l'instant, global

goNouveauCrg = new parametrageNouveauCRG().
run compta/outilsTVA.p persistent set ghOutilsTva.
run getTokenInstance in ghOutilsTva(mToken:JSessionId).

run extencqtPrivate.

delete object goNouveauCrg.

procedure extencqtPrivate private:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    VlRBHO = true.
    /* DM 0409/0037 Recherche de la 1ere rubrique loyer du CRG 1 */
    if num-entries(pcParametreDivers, "|") >=2
    then assign
        glSimulation = entry(1, pcParametreDivers, "|") = "O"
        glFlagLF   = entry(2, pcParametreDivers, "|") = "O"
    .
    else glSimulation = (pcParametreDivers = "O").
    glExtractCRG = num-entries(pcParametreDivers, "|") >= 3 and entry(3, pcParametreDivers, "|") = "O". /* DM 0113/0150 */
    find first ietab no-lock    // todo   mettre un for-first (un buffer local?) - attention, ietab utilisé dans creation-aligtva-tmp, creation-impaye
        where ietab.soc-cd  = piCodeSoc
          and ietab.etab-cd = piNumeroMandat no-error.
    if available ietab then do:
        assign
            tmp-dadeb = pdaDebutQuittance 
            tmp-dafin = pdaFinQuittance
        .
        empty temp-table aligtva-tmp.
        for first ccptcol no-lock
            where ccptcol.soc-cd = piCodeSoc
              and ccptcol.tprole = 19:
            find first csscptcol no-lock      // todo   mettre un for first (un buffer local?) - attention, csscptcol utilisé dans creation-aligtva-tmp, Impayes_Debut_Exercice
                where csscptcol.soc-cd = piCodeSoc
                  and csscptcol.etab-cd = ietab.etab-cd
                  and csscptcol.sscoll-cle = ccptcol.coll-cle no-error.
            if available csscptcol
            then for each csscpt no-lock      // todo   mettre un buffer local? - attention, csscpt utilisé
                where csscpt.soc-cd = piCodeSoc
                  and csscpt.etab-cd = ietab.etab-cd
                  and (csscpt.sscoll-cle = csscptcol.sscoll-cle or csscpt.sscoll-cle = (if glFlagLF then "LF" else csscptcol.sscoll-cle)):
                /* Creation de la table temporaire aligtva-tmp en fonction des aligtva et adbtva */
                run creation-aligtva-tmp.
                /** IMPAYES DEBUT PERIODE **/
                run creation-impaye.
            end.
        end.    
    end.
end procedure.

/*Procedure creation-aligtva-tmp et creation-impaye*/
{comm/include/procecla.i}
