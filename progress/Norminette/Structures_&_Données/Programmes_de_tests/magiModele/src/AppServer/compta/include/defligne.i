/*------------------------------------------------------------------------
File        : defligne.i
Purpose     : Declarations procedures Ligne et Lignebis
Author(s)   : OF - 2006/08/10;  gga  -  2017/05/15
Notes       : reprise include com\defligne.i
              Appelé dans glbtrans.i et gen-apur.p
----------------------------------------------------------------------*/

define temp-table ttLigne no-undo
    field NumLigne as integer
    field Ligne    as character format "x(148)"
    field NmArt    as character format "x(4)"
index numligne is primary unique Numligne
.

define variable giCptLigne as integer no-undo.   /*gga variable reste global, compteur numero de ligne sur le fichier */

/*gga
define variable iNbligne     as integer   no-undo.
define variable lMethode     as logical   no-undo.
define variable lFlag        as logical   no-undo.
define variable cKeyValue    as character no-undo.
define variable cChaine      as character no-undo.
define variable lSuivi       as logical   no-undo.
define variable iSuivi       as integer   no-undo.
define variable GlbCpDps     as character extent 255 no-undo.
define variable glPme        as logical   no-undo.
define variable iCompteurEcr as integer   no-undo.
define variable iCompteurMaj as integer   no-undo.
define variable giCptLigne   as integer   no-undo.
define variable chaine1      as character no-undo.
define variable chaine2      as character no-undo.
define stream   sFichier.
define stream   StErrQtt.
define variable HdTrigTrf    as handle    extent 10	no-undo.
define variable glAppServeur as logical   no-undo.
define variable vnmart       as character no-undo.
gga*/

procedure ligne private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcVnmArtIn as character no-undo.
    define input parameter piNoRefTrans as integer no-undo.
    define input parameter pcChaine as character no-undo.

    define variable viNumLigne as integer no-undo.

/*gga todo pour l'instant GlbCpDps (init dans lancegi1.i) est vide alors on ne fait pas cette boucle
    define variable viCptCha   as integer   no-undo.
    define variable vcChValAsc as character no-undo.
    define variable vcChFinUse as character no-undo.
    assign pcChaine  = substring(pcChaine,1,137)
           vcChFinUse = "".

    do viCptCha = 1 to length(pcChaine):

        /* remplacement du caractŠre */
        vcChValAsc = GlbCpDps[asc(substring(pcChaine,viCptCha,1))].

        if vcChValAsc = ""
        and substring(pcChaine,viCptCha,1) ne ""
        then assign vcChValAsc = " ". /* PS LE 13/10/00 */

        vcChFinUse = vcChFinUse + vcChValAsc.

    end.
    pcChaine = vcChFinUse.
gga*/

    /* Ajout du nom de l'article et du num‚ro de r‚f‚rence */
    assign
        pcChaine = substring(pcChaine, 1, 137, 'character')
        pcChaine = substitute("1&1&2&3**&4*", string(pcVnmArtIn, "X(4)"), string(piNoRefTrans, "99999"), substring(pcChaine, 1, 64, 'character'), substring(pcChaine, 65, 73, 'character'))
    .
    for last ttLigne:
        viNumLigne = ttLigne.NumLigne.
    end.
    create ttLigne.
    assign
        ttLigne.NumLigne = viNumLigne + 1
        ttLigne.ligne    = pcChaine
        ttLigne.NmArt    = pcVnmArtIn
    .

    /* ecriture sur fichier toutes les 50 lignes */
/* gga todo a revoir si necessaire (en plus de la question sur utilisation du fichier) */
    if viNumLigne modulo 50 = 0 then run ecrLigneSurFichier.

end procedure.

procedure EcrLigneSurFichier private:
    /*------------------------------------------------------------------------------
     Purpose: Ecriture sur fichier de la table temporaire
     Notes:   reprise include trans\src\incl\writfich.i
    ------------------------------------------------------------------------------*/
    for each ttLigne:
        giCptLigne = giCptLigne + 1.
        put stream sFichier unformatted
//            substring(string(giCptLigne, "999999999"), 5, 5, 'character') substring(ttLigne.ligne, 1, 75, 'character') skip
//            substring(string(giCptLigne, "999999999"), 5, 5, 'character') substring(ttLigne.ligne, 76, 75, 'character') skip
            giCptLigne modulo 100000 substring(ttLigne.ligne, 1, 75, 'character') skip
            giCptLigne modulo 100000 substring(ttLigne.ligne, 76, 75, 'character') skip
        .
        delete ttLigne.
    end.
end procedure.

/*gga pas utilise pour l'instant
procedure lignebis :

    define input parameter vnmart-in as character no-undo.

    define variable cptcha   as integer   no-undo.
    define variable ChValAsc as character no-undo.
    define variable ChFinUse as character no-undo.

    /* Ex‚cution de la chaine d'initialisation de la structure de donn‚es */
    /* de l'artile … g‚n‚rer                                              */

    {&Chaine}


    /* La ligne ne peut contenir que 137 caractŠres de donn‚es */

    assign
        cChaine  = substring(cChaine,1,137)
        ChFinUse = ""
        .

    /*gga todo pour l'instant GlbCpDps (init dans lancegi1.i) est vide alors on ne fait pas cette boucle
        DO CptCha = 1 TO LENGTH(Cchaine):
            /* remplacement du caractŠre */
            ASSIGN
                ChValAsc =  GlbCpDps[Asc(substring(Cchaine,Cptcha,1))].

            IF ChValAsc = "" AND substring(Cchaine,Cptcha,1) > "" THEN ASSIGN ChValAsc = " ". /* JR le 05/12/06 1106/0317 */

            ASSIGN
                ChFinUse = ChFinUse + ChValAsc.
        END.

        ASSIGN Cchaine = ChFinUse.
    gga*/

    /* Ajout du nom de l'article et du num‚ro de r‚f‚rence */

    cChaine =
        "1" +
        string(vnmart-in,"X(4)") +
        string(giNoRefTrans,"99999") +
        substring(cChaine,1,64) +
        "*" +
        "*" +
        substring(cChaine,65,73) +
        "*" .


    find last ttLigne no-lock no-error.
    if available ttLigne then iNbLigne = ttLigne.Nbligne.
    else iNbLigne = 0.

    create ttLigne.
    assign
        ttLigne.ligne   = cchaine
        ttLigne.NmArt   = vnmart-in
        ttLigne.Nbligne = iNbLigne + 1.

    cchaine = "".

    iCompteurEcr = iCompteurEcr + 1.

    if iCompteurEcr = 50 then
    do :

        {compta/include/writfich.i}

        iCompteurEcr = 0.

    end.

end procedure. /* lignebis */

/* -------------------------------------------------------------------------
   Procedure spéciale mandat 5 chiffres : le 1er chiffre est stocké
   dans le 1er chiffre de la référence
   ----------------------------------------------------------------------- */
procedure lignemdt:

    define input parameter vnmart-in as character no-undo.
    define input parameter nomdt-in as integer no-undo.
    define input-output parameter cchaine-IO as character no-undo.

    define variable cptcha   as integer   no-undo.
    define variable ChValAsc as character no-undo.
    define variable ChFinUse as character no-undo.

    /* La ligne ne peut contenir que 137 caractŠres de donn‚es */

    assign
        cchaine-IO = substring(cchaine-IO,1,137)
        ChFinUse   = ""
        .

    /*gga todo pour l'instant GlbCpDps (init dans lancegi1.i) est vide alors on ne fait pas cette boucle
        DO CptCha = 1 TO LENGTH(cchaine-IO):
            /* remplacement du caractŠre */
            ASSIGN
                ChValAsc =  GlbCpDps[Asc(substring(cchaine-IO,Cptcha,1))].

            IF ChValAsc = "" AND substring(cchaine-IO,Cptcha,1) > "" THEN ASSIGN ChValAsc = " ".

            ASSIGN
                ChFinUse = ChFinUse + ChValAsc.

        END.

        ASSIGN cchaine-IO = ChFinUse.
    gga*/

    /* Ajout du nom de l'article et du num‚ro de r‚f‚rence */

    cchaine-IO = "1" + string(vnmart-in,"X(4)")
        + substring( string(nomdt-in , "99999") , 1 , 1)
        + string(giNoRefTrans,"9999")
        + substring(cchaine-IO,1,64)
        + "*"
        + "*"
        + substring(cchaine-IO,65,73)
        + "*" .

    find last ttLigne no-lock no-error.
    if available ttLigne then iNbLigne = ttLigne.Nbligne.
    else iNbLigne = 0.

    create ttLigne.
    assign
        ttLigne.ligne   = cchaine-IO
        ttLigne.NmArt   = vnmart-in
        ttLigne.Nbligne = iNbLigne + 1.

    /* END.                                  */


    cchaine-IO = "".

    iCompteurEcr = iCompteurEcr + 1.

    if iCompteurEcr = 50 then
    do :

        {compta/include/writfich.i}

        iCompteurEcr = 0.

    end.

end procedure. /* ligne */
gga fin pas utilise pour l'instant*/