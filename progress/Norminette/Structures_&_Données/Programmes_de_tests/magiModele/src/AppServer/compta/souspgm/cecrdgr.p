/*------------------------------------------------------------------------
File        : cecrdgr.p
Purpose     : Creation automatique des lignes de depot de garantie
              dans le programme de saisie des OD
Author(s)   : Olivier FALCY - 19/09/00  :  gga - 2017/05/12
Notes       : reprise du pgm cadb\src\batch\cecrdgr.p
---------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define temp-table ttCecrln no-undo like cecrln
    index primaire soc-cd etab-cd jou-cd prd-cd prd-num piece-int lig.

procedure cecrdgrCreLgDepotGar:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par cecrgval.p
    ------------------------------------------------------------------------------*/
    define input parameter prRecnoCecTmp as rowid no-undo.
    define input-output parameter table for ttCecrln.

    define buffer aparm      for aparm.
    define buffer vbAparm    for aparm.
    define buffer vbttCecrln for ttCecrln.
    define buffer csscptcol  for csscptcol.

    for first ttCecrln
        where rowid(ttCecrln) = prRecnoCecTmp:

message "debut ttCecrln" ttCecrln.soc-cd "//" ttCecrln.mandat-cd "//" ttCecrln.jou-cd "//"
ttCecrln.mandat-prd-cd "//" ttCecrln.mandat-prd-num "//" ttCecrln.piece-int
"// " ttCecrln.fourn-sscoll-cle .

        find first csscptcol no-lock
            where csscptcol.soc-cd     = ttCecrln.soc-cd
              and csscptcol.etab-cd    = ttCecrln.etab-cd
              and csscptcol.sscoll-cle = ttCecrln.fourn-sscoll-cle no-error.
        if not available csscptcol then return.

        find first vbAparm no-lock
            where vbAparm.soc-cd  = 0
              and vbAparm.etab-cd = 0
              and vbAparm.tppar   = "TPDGR"
              and vbAparm.zone2   = csscptcol.sscoll-cle no-error.
        if not available vbAparm then return.

        find first aparm no-lock
            where aparm.soc-cd  = 0
              and aparm.etab-cd = 0
              and aparm.tppar   = "TPDGR"
              and aparm.cdpar   = "P" + substring(vbAparm.cdpar, 2) no-error.
        if not available aparm then return.

        /* +====================+
        ===| Ligne locataire    |==================================================
           +====================+ */
        if not can-find(first vbttCecrln
                        where vbttCecrln.soc-cd    = ttCecrln.soc-cd
                          and vbttCecrln.etab-cd   = ttCecrln.etab-cd
                          and vbttCecrln.jou-cd    = ttCecrln.jou-cd
                          and vbttCecrln.prd-cd    = ttCecrln.prd-cd
                          and vbttCecrln.prd-num   = ttCecrln.prd-num
                          and vbttCecrln.piece-int = ttCecrln.piece-int
                          and vbttCecrln.lig       = ttCecrln.lig + 1)
        then do:
            create vbttCecrln.
            buffer-copy ttCecrln to vbttCecrln
                assign
                    vbttCecrln.coll-cle            = csscptcol.coll-cle
                    vbttCecrln.sscoll-cle          = csscptcol.sscoll-cle
                    vbttCecrln.cpt-cd              = ttCecrln.fourn-cpt-cd
                    vbttCecrln.lig                 = ttCecrln.lig + 1
                    vbttCecrln.sens                = ttCecrln.sens
                    vbttCecrln.zone1               = "DGR11"
                    vbttCecrln.fg-ana100           = false
                    vbttCecrln.analytique          = false
                    vbttCecrln.type-ecr            = 0
                    vbttCecrln.fourn-sscoll-cle    = ""
                    vbttCecrln.fourn-cpt-cd        = ""
                    vbttCecrln.taxe-cd             = 0
                    vbttCecrln.mttva               = 0
                    vbttCecrln.mttva-dev           = 0
                    vbttCecrln.type-ecr            = 1
            .
        end.

        /* +====================+
        ===| Ligne proprietaire |==================================================
           +====================+ */
        if not can-find(first vbttCecrln
                        where vbttCecrln.soc-cd    = ttCecrln.soc-cd
                          and vbttCecrln.etab-cd   = ttCecrln.etab-cd
                          and vbttCecrln.jou-cd    = ttCecrln.jou-cd
                          and vbttCecrln.prd-cd    = ttCecrln.prd-cd
                          and vbttCecrln.prd-num   = ttCecrln.prd-num
                          and vbttCecrln.piece-int = ttCecrln.piece-int
                          and vbttCecrln.lig       = ttCecrln.lig + 2)
        then do:
            create vbttCecrln.
            buffer-copy ttCecrln to vbttCecrln
                assign
                    vbttCecrln.coll-cle            = ""
                    vbttCecrln.sscoll-cle          = ""
                    vbttCecrln.cpt-cd              = aparm.zone2
                    vbttCecrln.lig                 = ttCecrln.lig + 2
                    vbttCecrln.sens                = not ttCecrln.sens
                    vbttCecrln.zone1               = "DGR12"
                    vbttCecrln.fg-ana100           = false
                    vbttCecrln.analytique          = false
                    vbttCecrln.type-ecr            = 0
                    vbttCecrln.fourn-sscoll-cle    = ""
                    vbttCecrln.fourn-cpt-cd        = ""
                    vbttCecrln.taxe-cd             = 0
                    vbttCecrln.mttva               = 0
                    vbttCecrln.mttva-dev           = 0
                    vbttCecrln.type-ecr            = 1
            .
        end.
    end.

end procedure.
