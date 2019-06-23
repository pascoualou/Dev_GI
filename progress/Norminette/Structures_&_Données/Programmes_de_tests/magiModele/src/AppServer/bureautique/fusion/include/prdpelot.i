/*-----------------------------------------------------------------------------
File        : prdpelot.i
Description : Recherche Etiquettes energie/climat d'un lot à partir de l'enregistrement local en cours
Author(s)   : SY - 2011/02/02, KANTENA - 2018/03/02
Notes       : Fiche 1010/0020: Etiquettes Energie et climat du lot à partir du Diagnostique Technique Immeuble (04201)
              "Performance energétique" (DPE = code CDDIA "00009") 
-----------------------------------------------------------------------------*/

procedure RchEtqDPELot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLocal    as int64     no-undo.
    define input  parameter piNumeroImmeuble as integer   no-undo.
    define output parameter pdaDPE           as date      no-undo.
    define output parameter pcEnergie        as character no-undo.
    define output parameter pcClimat         as character no-undo.
    define output parameter piEnergie        as integer   no-undo.  /* NP #7589 */
    define output parameter piClimat         as integer   no-undo.  /* NP #7589 */

    define buffer intnt for intnt.
    define buffer tache for tache.
    define buffer taint for taint.

    find first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-construction}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble no-error.
    if not available intnt then return.

    /* boucle sur les lots des diagnostiques privatifs DPE */   
    {&_proparse_ prolint-nowarn(sortaccess)}
boucle:
    for each taint no-lock
        where taint.tpcon = {&TYPECONTRAT-construction}
          and taint.nocon = intnt.nocon
          and taint.tptac = {&TYPETACHE-diagnosticTechnique}
          and taint.tpidt = {&TYPEBIEN-lot}
          and taint.noidt = piNumeroLocal
      , first tache no-lock
        where tache.tpcon = taint.tpcon
          and tache.nocon = taint.nocon
          and tache.tptac = {&TYPETACHE-diagnosticTechnique}
          and tache.notac = taint.notac
          and tache.dcreg = "00009"     /* Performance Energétique */
          and tache.pdreg = "TRUE"      /* privatif */
        by tache.dtdeb descending:
        assign
            pdaDPE    = tache.dtdeb
            pcEnergie = tache.etqEnergie
            pcClimat  = tache.etqClimat
            piEnergie = tache.valetqenergie
            piClimat  = tache.valetqclimat
        .
        leave boucle.
    end.
end procedure.
