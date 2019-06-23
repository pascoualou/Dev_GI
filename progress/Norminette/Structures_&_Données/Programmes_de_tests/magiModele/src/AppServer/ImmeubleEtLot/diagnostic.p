/*------------------------------------------------------------------------
File        : diagnostic.p
Purpose     :
Author(s)   : NPO  -  2016/12/13
Notes       :
              13/10/2017  npo  #7589 add valeur etiquette nrj et climat
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/diagnostic.i}

define variable ghFichierJoint as handle no-undo.

procedure getDiagnosticEtudeImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble      as integer no-undo.
    define input  parameter piContratConstruction as int64   no-undo.
    define output parameter table for ttDiagnosticEtude.

    define buffer tache for tache.

    empty temp-table ttDiagnosticEtude.

    run immeubleEtLot/fichierJoint.p persistent set ghFichierJoint.
    run getTokenInstance in ghFichierJoint(mToken:JSessionId).

    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = piContratConstruction
          and tache.tptac = {&TYPETACHE-diagnosticTechnique}
          and tache.pdreg = "FALSE":
        run createttDiagnostique(piNumeroImmeuble, 0, 0, input buffer tache:handle).
    end.

    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = piContratConstruction
          and tache.tptac = {&TYPETACHE-miseEnConformite}
          and tache.pdreg = "FALSE":
        run createttDiagnostique(piNumeroImmeuble, 0, 0, input buffer tache:handle).
    end.
    run destroy in ghFichierJoint.

end procedure.

procedure getDiagnosticEtudeLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble      as integer no-undo.
    define input  parameter piNumeroBien          as integer no-undo.
    define input  parameter piContratConstruction as int64   no-undo.
    define output parameter table for ttDiagnosticEtude.

    define buffer taint for taint.
    define buffer local for local.
    define buffer tache for tache.

    empty temp-table ttDiagnosticEtude.


boucle:
    for each taint no-lock
       where taint.tpcon = {&TYPECONTRAT-construction}
         and taint.nocon = piContratConstruction
         and (taint.tptac = {&TYPETACHE-diagnosticTechnique}
              or taint.tptac = {&TYPETACHE-miseEnConformite})
         and taint.tpidt = {&TYPEBIEN-lot}
         and taint.noidt = piNumeroBien
     , first local no-lock
       where local.noloc = taint.noidt
      , each tache no-lock
       where tache.tpcon = {&TYPECONTRAT-construction}
         and tache.nocon = piContratConstruction
         and tache.tptac = tache.tptac
         and tache.notac = taint.notac
         and tache.pdreg = "TRUE":
        run createttDiagnostique(piNumeroImmeuble, local.nolot, 0, input buffer tache:handle).
    end.

end procedure.


procedure createttDiagnostique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define input parameter piNumeroLot      as integer no-undo.
    define input parameter piNumeroFiche    as integer no-undo.
    define input parameter phBuffer         as handle  no-undo.

    define buffer ccptCol for ccptCol.
    define buffer ifour   for ifour.

    create ttdiagnosticEtude.
    assign
        ttdiagnosticEtude.CRUD                      = "R"
        ttdiagnosticEtude.iNumeroImmeuble           = piNumeroImmeuble
        ttdiagnosticEtude.iNumeroLot                = piNumeroLot
        ttdiagnosticEtude.iNumeroFiche              = piNumeroFiche
        ttdiagnosticEtude.iNumeroTache              = phBuffer::noita
        ttdiagnosticEtude.cTypeContrat              = phBuffer::tpcon
        ttdiagnosticEtude.iNumeroContrat            = phBuffer::nocon
        ttdiagnosticEtude.cCodeTypeTache            = phBuffer::tptac
        ttdiagnosticEtude.iChronoTache              = phBuffer::notac
        ttdiagnosticEtude.cCodeDisposition          = phBuffer::DcReg
        ttdiagnosticEtude.cCodeBatiment             = phBuffer::ntreg
        ttdiagnosticEtude.cTypediagnosticEtude      = trim(string(phBuffer::tptac = {&TYPETACHE-miseEnConformite}, "etude/diagnostic"))       // TODO: Traduction ?
        ttdiagnosticEtude.lControle                 = (phBuffer::NtGes = {&oui})
        ttdiagnosticEtude.lSurveillance             = (phBuffer::TpGes = {&oui})
        ttdiagnosticEtude.lTravaux                  = (phBuffer::PdGes = {&oui})
        ttDiagnosticEtude.lPrivatif                 = (phBuffer::PdReg = "TRUE")
        ttdiagnosticEtude.cLibelleDisposition       = outilTraduction:getLibelleParam(string(phBuffer::tptac = {&TYPETACHE-miseEnConformite},'CDETU/CDDIA'), phBuffer::DcReg)
        ttdiagnosticEtude.daDateRecherche           = phBuffer::dtdeb
        ttdiagnosticEtude.cCodeResultatRecherche    = phBuffer::tpfin
        ttdiagnosticEtude.cLibelleResultatRecherche = if ttdiagnosticEtude.cCodeResultatRecherche = "00001" then "+" else if ttdiagnosticEtude.cCodeResultatRecherche > "" then "-" else ""
        ttdiagnosticEtude.daDatePrevueDT            = phBuffer::dtfin
        ttdiagnosticEtude.daDateRealiseeDT          = phBuffer::dtree
        ttdiagnosticEtude.daDateControle            = phBuffer::dtreg
        ttdiagnosticEtude.cCommentaire              = phBuffer::cdreg
        ttdiagnosticEtude.cEtiquetteEnergie         = phBuffer::etqenergie
        ttdiagnosticEtude.iValeurEtiquetteEnergie   = phBuffer::valetqenergie   /* npo #7589 */
        ttdiagnosticEtude.cEtiquetteClimat          = phBuffer::etqclimat
        ttdiagnosticEtude.iValeurEtiquetteClimat    = phBuffer::valetqclimat    /* npo #7589 */
        ttdiagnosticEtude.daDateCreation            = date(phBuffer::dtcsy)
        ttdiagnosticEtude.dtTimestamp               = datetime(phBuffer::dtmsy, phBuffer::hemsy)
        ttdiagnosticEtude.rRowid                    = phBuffer:rowid
    .
    // Libellé Organisme Vérificateur
    if num-entries(phBuffer::cdhon, ',') > 1
    then for first ccptCol no-lock
        where ccptCol.tprol  = 12
          and ccptcol.soc-cd = integer(mtoken:cRefCopro)
     , first ifour no-lock
       where ifour.soc-cd   = ccptcol.soc-cd
         and ifour.coll-cle = ccptcol.coll-cle
         and ifour.cpt-cd   = string(entry(2, phBuffer::cdhon, ','), "99999"):
       assign
           ttdiagnosticEtude.cCodeOrganisme    = ifour.cpt-cd
           ttdiagnosticEtude.cLibelleOrganisme = trim(ifour.nom)
       .
    end.
    else if phBuffer::utreg > ""
    then assign ttdiagnosticEtude.cLibelleOrganisme = phBuffer::utreg.

end procedure.
