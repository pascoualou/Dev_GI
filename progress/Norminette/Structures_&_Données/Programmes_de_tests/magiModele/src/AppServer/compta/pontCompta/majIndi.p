/*------------------------------------------------------------------------
File        : majIndi.p
Purpose     : Mise a jour des indivisaires (csscpt.numerateur = 0)
Author(s)   : 20/02/98 PB - GGA 2018/04/09
Notes       : a partir de cadb/gestion/majindi.p
+--------------------------------------------------------------------------*/
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/csscpt.i}

procedure majIndivisaire:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vhProc as handle no-undo.

    define buffer ietab     for ietab.
    define buffer ccptcol   for ccptcol.
    define buffer csscptcol for csscptcol.
    define buffer csscpt    for csscpt.
 
    empty temp-table ttCsscpt. 
    for first ietab no-lock 
        where ietab.soc-cd    = integer(mtoken:cRefGerance)
          and ietab.etab-cd   = piNumeroMandat
          and ietab.profil-cd = 21
    , first ccptcol no-lock
      where ccptcol.soc-cd = ietab.soc-cd
        and ccptcol.tprole = integer({&TYPEROLE-coIndivisaire})
    , first csscptcol no-lock
      where csscptcol.soc-cd   = ietab.soc-cd
        and csscptcol.etab-cd  = ietab.etab-cd
        and csscptcol.coll-cle = ccptcol.coll-cle
        and csscptcol.facturable
    , each csscpt no-lock
     where csscpt.soc-cd     = ietab.soc-cd
       and csscpt.etab-cd    = ietab.etab-cd
       and csscpt.sscoll-cle = csscptcol.sscoll-cle:
        create ttCsscpt.
        assign
            ttCsscpt.soc-cd      = csscpt.soc-cd  
            ttCsscpt.etab-cd     = csscpt.etab-cd
            ttCsscpt.sscoll-cle  = csscpt.sscoll-cle
            ttCsscpt.cpt-cd      = csscpt.cpt-cd
            ttCsscpt.CRUD        = 'U'
            ttCsscpt.dtTimestamp = datetime(csscpt.damod, csscpt.ihmod)
            ttCsscpt.rRowid      = rowid(csscpt)
            ttCsscpt.numerateur  = 0.  
        .
    end.
    run compta/csscpt_CRUD.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    run setCsscpt in vhProc(table ttCsscpt by-reference).
    run destroy in vhProc.

end procedure.
   
