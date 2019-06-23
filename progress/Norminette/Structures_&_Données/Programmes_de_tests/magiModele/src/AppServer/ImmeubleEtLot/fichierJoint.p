/*------------------------------------------------------------------------
File        : fichierJoint.p
Description :
Author(s)   : Kantena  -  2017/06/01
Notes       :
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/fichierJoint.i}

procedure getPJ:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par diagnostic.p, immeuble.p, plan.p
    ------------------------------------------------------------------------------*/
    define input  parameter pctpidtuse as character no-undo.
    define input  parameter pinoidtuse as int64     no-undo.
    define input  parameter pcIdFixUse as character no-undo. /* ascenceur, plan, contrat, ... */
    define output parameter table for ttFichierJoint.

    define variable vcCheminFichier as character no-undo.
    define buffer tbfic for tbfic.

    vcCheminFichier = substitute('&1fichiers~\&2~\&3~\&4~\',
                          mToken:getValeur('REPGI'),
                          entry(1, outilTraduction:getLibelleProg("O_CLC", pctpidtuse), " "),
                          mToken:cRefPrincipale,
                          string(pinoidtuse, if pinoidtuse > 999999999 then "99999999999" else "9999999999")).
    for each tbfic no-lock
        where tbfic.tpidt = pctpidtuse
          and tbfic.noidt = pinoidtuse
          and (pcIdFixUse = "" or tbfic.lbfic begins(pcIdFixUse)):
        /*--> Si le fichier existe */
        if search(vcCheminFichier + tbfic.lbfic) <> ?
        then do:
            create ttFichierJoint.
            assign
                ttFichierJoint.CRUD         = 'R'
                ttFichierJoint.cNomFichier  = tbfic.lbfic
                ttFichierJoint.cCommentaire = if trim(pcIdFixUse) > "" then replace(tbfic.lbfic, pcIdFixUse + "-", "") else tbfic.lbfic
                ttFichierJoint.cChemin      = vcCheminFichier + tbfic.lbfic
                ttFichierJoint.iIDFichier   = tbfic.id-fich
                ttFichierJoint.dtTimestamp  = datetime(tbfic.dtmsy, tbfic.hemsy)
            .
        end.
    end.
    // TODO  pourquoi tester pctpidtuse = "01088" alors que l'appel se fait sur TYPETACHE  (04xxx)  ?????
    /*--> Evenement : Ajouter les doc bureautique */
    /*
    if pctpidtuse = "01088"
    then for first event no-lock
        where event.noeve = pinoidtuse:
        if event.nodoc > 0
        then for first docum no-lock
            where docum.nodoc = event.nodoc
          , first desti no-lock
            where desti.nodoc = docum.nodoc
          , first mddoc no-lock
            where mddoc.nodot = docum.nodot:
            create ttFichierJoint.
            assign
                ttFichierJoint.CRUD                    = 'R'
                ttFichierJoint.cNomFichier             = docum.lbdoc
                ttFichierJoint.cCommentaire            = docum.lbobj
                ttFichierJoint.cChemin                 = substitute('&1docum~\&2', mToken:getValeur('REPGI'), docum.lbdoc)
                ttFichierJoint.iNumeroDocument         = docum.nodoc
                ttFichierJoint.cLibelleCanevasDocument = docum.lbcav
                ttFichierJoint.cLibelleModeleDocument  = entry(1, mddoc.lbdot, ".")
                ttFichierJoint.dtTimestamp             = datetime(docum.dtmsy, docum.hemsy)
            .
        end.
        if event.nossd > 0
        then for each lidoc no-lock
            where lidoc.tpidt = event.tprol
              and lidoc.noidt = event.norol
              and lidoc.nossd = event.nossd
          , first docum no-lock
            where docum.nodoc = lidoc.nodoc
          , first desti no-lock
            where desti.nodoc = docum.nodoc
          , first mddoc no-lock
            where mddoc.nodot = docum.nodot:
            create ttFichierJoint.
            assign
                ttFichierJoint.CRUD                    = 'R'
                ttFichierJoint.cNomFIchier             = docum.lbdoc
                ttFichierJoint.cCommentaire            = docum.lbobj
                ttFichierJoint.cChemin                 = substitute('&1docum~\&2', mToken:getValeur('REPGI'), docum.lbdoc)
                ttFichierJoint.iNumeroDocument         = docum.nodoc
                ttFichierJoint.cLibelleCanevasDocument = docum.lbcav
                ttFichierJoint.cLibelleModeleDocument  = entry(1, mddoc.lbdot, ".")
                ttFichierJoint.dtTimestamp             = datetime(docum.dtmsy, docum.hemsy)
            .
        end.
    end.
    */
end procedure.
