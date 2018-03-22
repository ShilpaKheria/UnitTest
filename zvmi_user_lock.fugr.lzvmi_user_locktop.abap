FUNCTION-POOL ZVMI_USER_LOCK.               "MESSAGE-ID ..

* INCLUDE LZVMI_USER_LOCKD...                " Local class definition
* MS01CTCO    Konstanten

INCLUDE <symbol>.                                          "#EC INCL_OK
INCLUDE <icon>.                                            "#EC INCL_OK

SET EXTENDED CHECK OFF.

* Systemsprache
DATA:   syst_language VALUE 'D'.


* Laengenkonstanten
DATA:   ptextlng    LIKE sy-fdpos VALUE 60,   "Länge der Kurztexte
        vallng      LIKE sy-fdpos VALUE 40,   " -    Wertlaenge
        maxlinelng  TYPE i        VALUE 66,   "Maximale Anzahl Zeichen pro Zeile
        authlng     LIKE sy-fdpos VALUE 12,
        proflng     LIKE sy-fdpos VALUE 12,   " -    Profile
        objlng      LIKE sy-fdpos VALUE 10,   " -    Objekt
        fldlng      LIKE sy-fdpos VALUE 10,   " -    Feld
        fblng       TYPE i        VALUE 8,    " Länge Funktionsblockfeld
        maxrec      TYPE i        VALUE 3750, "Max. Laenge eines Datenrecords
        c_flaglng   TYPE i        VALUE 2,
        maxusr      TYPE i        VALUE 312,  "Profile assignments per user
        maxcpf      TYPE i        VALUE 312,
        maxpro      TYPE i        VALUE 170.
CONSTANTS:
        gc_ptextlng LIKE sy-fdpos VALUE 60,  "Länge der Kurztexte
        gc_vallng   LIKE sy-fdpos VALUE 40,    " -    Wertlaenge
        gc_maxlinelng TYPE i      VALUE 66, "Maximale Anzahl Zeichen pro Zeil
        gc_authlng  LIKE sy-fdpos VALUE 12,
        gc_proflng  LIKE sy-fdpos VALUE 12,   " -    Profile
        gc_objlng   LIKE sy-fdpos VALUE 10,  " -    Objekt
        gc_fldlng   LIKE sy-fdpos VALUE 10,  " -    Feld
        gc_fblng    TYPE i        VALUE 8,    " Länge Funktionsblockfeld
        gc_maxrec   TYPE i        VALUE 3750, "Max. Laenge eines Datenrecords
        gc_maxusr   TYPE i        VALUE 312,  "Profile assignments per user
        gc_maxcpf   TYPE i        VALUE 300,
        gc_maxpro   TYPE i        VALUE 170.

* Abgleich
CONSTANTS: gc_er_user_prof TYPE agr_agrs2-attributes VALUE 'USER_PROF'.

* Konstanten fuer die Pruefung
DATA:   obj_auth          VALUE 'A',
        obj_objct         VALUE 'O',
        obj_prof          VALUE 'P',
        obj_user          VALUE 'U',
        obj_group         VALUE 'G',
        obj_sys(3)        VALUE 'SYS',
        act_add(2)        VALUE '01',
        act_change(2)     VALUE '02',
        act_show(2)       VALUE '03',
        act_lock(2)       VALUE '05',
        act_delete(2)     VALUE '06',
        act_activate(2)   VALUE '07',
        act_history(2)    VALUE '08',
        act_include(2)    VALUE '22',
        act_archivate(2)  VALUE '24',
        act_unlock(2)     VALUE '43',
        act_dummy(2)      VALUE '00'.

DATA:   docact_show       VALUE 'X',
        docact_maint      VALUE ' ',
        docobj_object(2)  VALUE 'UO',
        docobj_field(2)   VALUE 'UF',
        docobj_profile(2) VALUE 'UP'.

DATA:   singleprof        VALUE 'S',
        colectprof        VALUE 'C',
        generprof         VALUE 'G',
        aktivated         VALUE 'A',
        inwork            VALUE 'P',
        finesel           VALUE 'F',
        roughsel          VALUE 'R'.

DATA:
        typdia            VALUE 'A', "Dialog
        typbatch          VALUE 'B', "Systembenutzer (interner RFC und Batch)
        typcpic           VALUE 'C', "Kommunikation-Benutzer (externer RFC)
        typref            VALUE 'L', "Referenzbenutzer
        typsim            VALUE 'S', "Servicebenutzer
        typodc            VALUE 'O', "obsolet
        typbdc            VALUE 'D', "obsolet
        typtelex          VALUE 'T'. "obsolet

DATA:
        otypkern          VALUE 'K',
        otypnorm          VALUE 'N',
        otypmodi          VALUE 'M',
        otypar            VALUE 'A'.

DATA:
        rec_type_create   VALUE 'C',
        rec_type_modify   VALUE 'M',
        rec_type_delete   VALUE 'D',
        rec_type_rename   VALUE 'R'.

DATA:   obj_def_name_system(2) VALUE 'S_',
        max_sap_obj_name(2)    VALUE 'W_'.

DATA:   yulock   TYPE x VALUE '80',       "Gesperrt durch Falschanmeld.
        yusloc   TYPE x VALUE '40',       "Gesperrt durch Administrator
        yugloc   TYPE x VALUE '20'.   "Gesperrt durch globalen Admin.

DATA:   typ_tcode(2)  VALUE 'TR',
        typ_fb(2)     VALUE 'FB',
        typ_report(2) VALUE 'RE'.

DATA: type_tcode(2)     VALUE 'TR',
      type_rfc(2)       VALUE 'RF',
      type_tadir_srv(2) VALUE 'HT',
      type_ext_srv(2)   VALUE 'HS',
      type_fb(2)        VALUE 'FB',
      type_report(2)    VALUE 'RE',
      type_reuse(2)     VALUE 'RU'.

CONSTANTS:
      col_blue      TYPE seu_color VALUE 1,
      col_white     TYPE seu_color VALUE 2,
      col_yellow    TYPE seu_color VALUE 3,
      col_turq      TYPE seu_color VALUE 4,
      col_green     TYPE seu_color VALUE 5,
      col_red       TYPE seu_color VALUE 6,
      col_violet    TYPE seu_color VALUE 7.

CONSTANTS:                     "max lines for a range in a SQL-statement
      gc_max_range_sel TYPE i VALUE 500 .

TYPES: BEGIN OF type_auth,
         auth LIKE ust12-auth,
       END OF type_auth .
TYPES: type_auth_table TYPE SORTED TABLE OF type_auth
                            WITH UNIQUE KEY auth.

TYPES: BEGIN OF type_prof,
         profn LIKE ust10s-profn,
       END OF type_prof .
TYPES: type_prof_table TYPE STANDARD TABLE OF type_prof.

CONSTANTS:
  gc_sap_all  TYPE xuprofile VALUE 'SAP_ALL',
  gc_sap_app  TYPE xuprofile VALUE 'SAP_APP',
  gc_act_show TYPE c VALUE 'S',
  gc_act_chg  TYPE c VALUE 'C'.

TYPES: BEGIN OF ts_intprof,
         profn TYPE xuprofname,
         aktps TYPE xuaktpas,
         modda TYPE xumoddate,
         modti TYPE xumodtime,
         modbe TYPE xumodifier,
         typ   TYPE xutyp,
         ptext TYPE xutext,
         langu TYPE langu,
       END OF ts_intprof,
       tt_intprof  TYPE TABLE OF ts_intprof,

       tt_usproflst TYPE TABLE OF usproflang.







SET EXTENDED CHECK ON.

* MS01CTP2    Datendeklarationen

TABLES: usr_flags.                     "Flags für Ber.programme.
TABLES: tobj, tobjt, tobct, tobc, tautl.                    "MBK38864
TABLES: tactt, tactz.
TABLES: usr01, usr02, *usr02, usr04, *usr04.
TABLES: usr03, usr05, usgrp, usr08, usr09, usr30.           "USR0340A
TABLES: usr10, usr11, usr12, *usr10, *usr12, usr13, *usr13, usr16.
TABLES: ush04, ush10, ush12, ush02.
TABLES: ust04, ust10c, ust10s, ust12.
*TABLES: USRBF, USRBF2.
TABLES: dfies.
TABLES: xu100, xu180, xu190, stat, xu114, xu122, xu124, xu150.
* Fuer Doku
TABLES: dokhl.
*
TABLES usexit. " Exit bei Feldpflege

*ATA:   MAXREC TYPE I VALUE 3750.  "Maximallaenge eines Records im Pool

DATA:   fcode(4),                  "Funktionscode
        fcode2(4),                 "Funktionscode
        blank VALUE ' ',           "value fuer einen Leerstring
        dummy TYPE i,              "dummy-variable fuer return aus form
        ret,                       "Hilfsfeld zur Anwort aus popups
        flag,                      "Irgendeine Flage
        x,                         "Hilfsfeld fuer ankreuzen
        day LIKE sy-index,         "Tag fuer Passwort
        date TYPE d,
        f(30),                     "Platz fuer Feldname bei get-cursor
        l LIKE sy-tabix,           "Zeile im Loop bei get-cursor
        nocpf TYPE i,              "Flag, dass ein Profile nicht def.
        noobj TYPE i,              "Flag, dass ein Objekt nicht def.
        nober TYPE i,              "Flag, dass eine Berecht. n. def.
        flag1 TYPE i,              "Fuer Form LIST_AKT_PAS_AUTH und
        flag2 TYPE i,              "Form READ_TABSET
        abtfill LIKE sy-tfill,     "Anzahl Records  in Tab. tababt
        aktfill LIKE sy-tfill,     "Anzahl Profiles in Tab. aktpro
        setfill LIKE sy-tfill,     "Anzahl Werte in Tab. tabset
        abttopix LIKE sy-tabix,    "Zeilennr. int. Tab. die oben a. Bild
        settopix LIKE sy-tabix,    "Zeilennr. int. Tab. die oben a. Bild
        akttopix LIKE sy-tabix,    "Zeilennr. int. Tab. die oben a. Bild
        firstpro LIKE sy-tabix,    "1. Rec. des angez. Feldes
        lastpro  LIKE sy-tabix,    "letzter Rec. des angez. Feldes.
        firstset LIKE sy-tabix,    "1. Rec. des angez. Feldes
        firstaktset LIKE sy-tabix,            "
        lastset  LIKE sy-tabix,    "letzter Rec. des angez. Feldes.
        lastaktset  LIKE sy-tabix,            "
        probottom LIKE sy-tabix,   "Zeilennr. int. Tab. die unten a. Bil
        abtloop TYPE i,            "Anzahl der Loopzeilen fuer abteilung
        usrloop TYPE i,            "Anzahl der Loopzeilen fuer user
        cpfloop TYPE i,            "Anzahl der Loopzeilen fuer Sam.prof.
        proloop TYPE i,            "Anzahl der Loopzeilen fuer Profiles
        rulloop TYPE i,            "Anzahl der Loopzeilen fuer Berecht.
        setloop TYPE i,            "Anzahl der Loopzeilen fuer set
        uchange TYPE i,            "Flag, ob User veraendert
        cchange TYPE i,            "Flag, ob Sammelprofile veraendert
        pchange TYPE i,            "Flag, ob Profile veraendert
        rchange TYPE i,            "Flag, ob Regel veraendert
        bchange TYPE i,            "Flag, ob Berechtigung veraendert
        countx  LIKE sy-tabix,     "Hilfsvariable
        del     TYPE i,            "Zaehler fuer geloeschte Objekte
        pickline LIKE sy-tabix,    "Angepickte Zeile
        refusr  LIKE usr04-bname,  "Feld fuer Referenzuser
        refpro  LIKE usr10-profn  , "Feld fuer Referenzprofile
*       OLDDEV  LIKE TMPRO-PATTPROF,"Hilfsfeld
        oldpro  LIKE usr10-profn,   "Hilfsfeld
        oldobj  LIKE tobj-objct,  "Hilfsfeld
        old1    LIKE tobj-fiel1,  "Hilfsfeld fuer Abgleich akt. -
        old2    LIKE tobj-fiel1,  "Berecht. u. Pflegeberecht.
        btyp,                      "Berecht.typ (R=Sammel. B=Einzel.)
        aktiv,                     "Aktiv ? Wenn ja dann 'X'
        found TYPE i,              "Flag fuer Suchen im Loop
        no_akt TYPE i,             "Flag ob aktiviert werden kann
        fertig TYPE i VALUE 0,     "flag fuer Liste aus Window
        fertig2 TYPE i VALUE 0,     "flag fuer Liste aus Window
        fpick TYPE i VALUE 0,      "Angepickt ?
        sele TYPE i,               "Selectiert ?
        selval(30),                "Platz fuer selekt. Wert
        usrflag TYPE i,            "Flag zur Steuerung von Dynpros
        lstflag TYPE i,            "Flag zur Steuerung von Dynpros
        aktflag TYPE i,            "Flag für Direktpflad Aktivierung
        showflag(1),
        insertflag TYPE i VALUE 0, "1=Benutzer wurde angelegt
        menueflag TYPE i VALUE 0,  "Flag für Steuerung Berecht.pflege
        prof_read_flag TYPE i VALUE 0,  "Flag für Profilread
        modify_flag TYPE i VALUE 1, "Anzeige- od. Aend.modus
        rc LIKE sy-subrc,          "Hilfsfeld f. Returncode
        locrc LIKE sy-subrc,       "Hilfsfeld f. Returncode
        rc1 LIKE sy-subrc,         "Hilfsfeld f. Returncode
        rc2 LIKE sy-subrc,         "Hilfsfeld f. Returncode
        usrlng LIKE sy-fdpos VALUE 12,  "Laenge Benutzername
        abtlng LIKE sy-fdpos VALUE 10,  " -    Abteilungsname
        divlng LIKE sy-fdpos VALUE 10,  " -    Abteilungsname
        otextlng LIKE sy-fdpos VALUE 60," -    Objekttext
        strglng TYPE i VALUE 60,   " -    Suchstring
        outputlen TYPE i,               "Laenge Valuefeld
        convexit  LIKE dfies-convexit,  "Conversionexit
        max TYPE i,
        berecht LIKE usr12-auth,    "Hilfsfeld f. Berechtigungsname
        field   LIKE tobj-fiel1,  "Hilfsfeld f. Feldname
        field2  LIKE tobj-fiel1,  "Hilfsfeld f. Feldname
        field3  LIKE tobj-fiel1,  "Hilfsfeld f. Feldname
        sfield  LIKE tobj-fiel1,  "         "
        oldfield LIKE tobj-fiel1, "         "
        aktobj   LIKE usr12-objct, "Anzeige
        aktauth  LIKE usr12-auth,   "     der aktiven-
        pasobj   LIKE usr12-objct, "          und Pflege-
        pasauth  LIKE usr12-auth,   "               berechtigung
        z       TYPE i,            "Hilfvariable
        z1      TYPE i,            "Hilfvariable
        v1      TYPE i,            "Hilfvariable
        b1      TYPE i,            "Hilfvariable
        v2      TYPE i,            "Hilfvariable
        new     TYPE i,            "Hilfvariable
        gen     TYPE i,            "Hilfvariable
        state TYPE i VALUE 0,      "Save-Status
        opt1,                      "Option 1 bei Exit-Dynpro
        opt2,                      "Option 2 bei Exit-Dynpro
        opt3,                      "Option 3 bei Exit-Dynpro
        was(12),                   "Feld zur Textausgabe auf Dynpro
        name(12),                  "Feld zur Textausgabe auf Dynpro
        f1      TYPE i,            "Hilfflag
        f2      TYPE i,            "Hilfflag
        f3      TYPE i,            "Hilfflag
        f4      TYPE i,            "Hilfflag
        codeflag TYPE i,           "Hilfflag
        bcode_c(8),                "Hilfsfeld zum speichern d. Passworts
        xcode LIKE usr02-bcode,    "Hilfsfeld fuer codierte Passwort
        xcodvn LIKE usr02-codvn,   "Hilfsfeld fuer Codeversion
        pass(8) TYPE x,            "Hilfsfeld fuer PASS
        cls     LIKE tobc-oclss.  "Objektklasse

DATA:   cc113 LIKE sy-cucol VALUE 2,
        cr113 LIKE sy-curow VALUE 5,
        save_line113 LIKE sy-lilli VALUE 1,
        save_lsind113 LIKE sy-lsind VALUE 1,
        cc412 LIKE sy-cucol VALUE 2,
        cr412 LIKE sy-curow VALUE 6,
        save_line412 LIKE sy-lilli VALUE 1,
        save_lsind412 LIKE sy-lsind VALUE 1.

DATA:   tabname LIKE dfies-tabname.

DATA: docuobject LIKE dokhl-object.

DATA:   transobj LIKE e071-obj_name,
        korrret.

DATA:   longstring(3750),
        longstring1(3750).


*Lokale Daten (aus Form) global machen
DATA:   usr  LIKE usr04-bname,      "Info fuer Druck
        ap   LIKE usr10-aktps,
        apa  LIKE usr10-aktps,
        ty   LIKE usr12-typ,
        pf   LIKE usr10-profn,
        obj  LIKE usr12-objct,
        ath  LIKE usr12-auth,
        txt  LIKE usr11-ptext,
        fld  LIKE tobj-fiel1,
        val(40),
        sel,
        str(40).

*Positionsangaben (Spalte) zur Ausgabe in einer Liste
DATA:   p1   TYPE i        VALUE 01,  "Anzeigen Profile
        pspf TYPE i        VALUE 04,
        pobj TYPE i        VALUE 09,
        preg TYPE i        VALUE 16,
        pber TYPE i        VALUE 22,
        pbe2 TYPE i        VALUE 44,
        pfld TYPE i        VALUE 30,
        pvon TYPE i        VALUE 41,
        pbis TYPE i        VALUE 60,
        pval TYPE i        VALUE 33,
        pakp TYPE i        VALUE 14,  "Liste Profiles
        pcpf TYPE i        VALUE 19,
        pptx TYPE i        VALUE 26,
        pabt TYPE i        VALUE 67,
        potx TYPE i        VALUE 15,  "Liste von Objekten
        pfl1 TYPE i        VALUE 20,
        pfl2 TYPE i        VALUE 31,
        pfl3 TYPE i        VALUE 42,
        pfl4 TYPE i        VALUE 53,
        pfl5 TYPE i        VALUE 64,
        pbel TYPE i        VALUE 12,  "Liste von Regel u. Berecht.
        papl TYPE i        VALUE 25,
        ptyp TYPE i        VALUE 35,
        pppf TYPE i        VALUE 40,  "Aktive u. Pflegeprofiles
        pbak TYPE i        VALUE 13,
        ppak TYPE i        VALUE 13,
        ppft TYPE i        VALUE 27,
        pbpf TYPE i        VALUE 52,
        ppfl TYPE i        VALUE 18,  "Aktive u. Pflegeregeln
        pakt TYPE i        VALUE 07,  "Aktive u. Pflegeberecht.
        ppf2 TYPE i        VALUE 40,
        pakb TYPE i        VALUE 26,
        ppfb TYPE i        VALUE 51,
        paka TYPE i        VALUE 05,  "Zu aktivierende Profs und Berecht
        paob TYPE i        VALUE 20,
        pusr TYPE i        VALUE 08,  "Liste der Benutzer
        pnbr TYPE i        VALUE 15,
        ppro TYPE i        VALUE 27,
        pnam TYPE i        VALUE 21,  "Titel bei Anzeige von Werten
        pwrt TYPE i        VALUE 35,
        pode TYPE i        VALUE 15,  "Abteilungen   listen
        poct TYPE i        VALUE 30,
        pck1 TYPE i        VALUE 13,  "Fehlende Vernetzungen listen
        pck2 TYPE i        VALUE 40,
        pck3 TYPE i        VALUE 55,
        psav TYPE i        VALUE 68,  "Anzeige Berechtigung (125)
        psta TYPE i        VALUE 58,
        ptit TYPE i        VALUE 17,
        pwer TYPE i        VALUE 03,
        plb1 TYPE i        VALUE 03,  "Liste der Berecht. od. Objekte
        plb2 TYPE i        VALUE 64,
        plb3 TYPE i        VALUE 77.


* Uebergabeparameter an die Lese- und Schreiberoutinen zur Datenbank
*ATA:   DIVISION LIKE TMPRO-PATTPROF, "Hilfsfeld fuer Abteilung
*       DIVHIGH  LIKE TMPRO-PATTPROF, "Hilfsfeld fuer Abteilung
DATA:   user    LIKE usr04-bname,  "Hilfsfeld fuer Benutzer
        usrhigh LIKE usr04-bname,  "Hilfsfeld fuer Benutzer
        profile LIKE usr10-profn,   "Hilfsfeld fuer Profile
        profhigh LIKE usr10-profn,  "Hilfsfeld fuer Profile
        ptext   LIKE usr11-ptext,  "Hilfsfeld fuer Profiletext
        otext   LIKE tobjt-ttext,  "Hilfsfeld fuer Objekttext
*       PPTEXT   LIKE TMPRT-PPTEXT,  "Hilfsfeld fuer Abteilungstext
        object   LIKE usr12-objct,
        objhigh  LIKE usr12-objct,
        auth     LIKE usr12-auth,
        authhigh LIKE usr12-auth,
        fieldhigh LIKE tobj-fiel1,
        aktpas   LIKE usr12-aktps,
        akthigh  LIKE usr12-aktps,
        bertyp   LIKE usr12-typ,
        h_objct LIKE usr12-objct,
        value12(18),
        value13(18),
        value21(18),
        value22(18),
        value23(18),
        value31(18),
        value32(18),
        value33(18),
        value(18).

DATA:   ap1      LIKE usr10-aktps,
        ap2      LIKE usr10-aktps,
        ap3      LIKE usr10-aktps,
        typ1     LIKE usr10-typ,
        typ2     LIKE usr10-typ,
        typ3     LIKE usr10-typ.

* Hilfsfelder zum lesen u. schreiben auf die Datenbank
DATA:
        off LIKE sy-index,
        foff LIKE sy-index,
        ll  TYPE i,
        offt LIKE off,
        offw LIKE off,
        wlng LIKE ll,
        wt   TYPE x,
        lng TYPE i,                "Laenge eines Wertes abh. v. Feld
        glng TYPE i,               "Laenge eines genersischen Wertes
        clng(2),                   "Generische Laenge in Char
        cflng(4),                  "Laenge der Feldinfo in Char
        vtyp,                      "Value-typ: F, V, B, E oder G
        itype,                     "interner Typ: C, X oder P
        flng LIKE sy-index,
        vlng LIKE flng,
        blng LIKE flng.

* Hide-Felder
DATA:   h_412_object LIKE usr12-objct,
        h_412_auth   LIKE usr12-auth,
        h_412_aktpas LIKE usr12-aktps,
        h_412_type   LIKE usr12-typ,
        h_113_profile LIKE usr10-profn,
        h_113_aktpas LIKE usr10-aktps,
        h_113_proftype LIKE usr10-typ,
        h_061_oclss  LIKE tobc-oclss,
        h_061_ctext  LIKE tobct-ctext,
        h_111_object LIKE usr12-objct,
        h_111_otext  LIKE tobjt-ttext,
        h_133_actvt  LIKE tactt-actvt,
        h_551_object LIKE usr12-objct,
        h_551_auth   LIKE usr12-auth,
        h_551_otext  LIKE tobjt-ttext,
        h_aktp_oldpro LIKE usr10-profn,
        h_aktp_newpro LIKE usr10-profn,
        h_aktp_oldobj LIKE usr12-objct,
        h_aktp_oldauth LIKE usr12-auth,
        h_aktp_newobj LIKE usr12-objct,
        h_aktp_newauth LIKE usr12-auth.

* note 841612/2:
* Return table for error messages
DATA: it_return_tab TYPE bapirettab.
* end of correction (note 841612/2)

DATA:   BEGIN OF tabusr OCCURS 30,    "Int. Tab. fuer User
          profile LIKE usr10-profn,
          samprof(1),
          ptext   LIKE usr11-ptext,
        END OF tabusr.

TYPES: BEGIN OF ty_intpro,
          profile LIKE usr10-profn,
          samprof LIKE usr10-typ,
          aktpas  LIKE usr10-aktps,
          ptext   LIKE usr11-ptext,
        END OF ty_intpro.

TYPES: BEGIN OF ty_intpro2,
          profile LIKE usr10-profn,
          ptext   LIKE usr11-ptext,
        END OF ty_intpro2.

TYPES: BEGIN OF ty_profiles,
          profile TYPE usr10-profn,
          samprof TYPE usr10-typ,
          sym_sam TYPE icon_d,
          aktpas  TYPE usr10-aktps,
          sym_akt TYPE icon_d,
          ptext   TYPE usr11-ptext,
        END OF ty_profiles.

TYPES: BEGIN OF ty_cpf,
         prof TYPE usr10-profn,
       END OF ty_cpf.

TYPES: BEGIN OF ty_tabpro,
         object TYPE usr12-objct,
         otext  TYPE tobjt-ttext,
         rule   TYPE usr12-auth,
         atext  TYPE usr13-atext,
         mark   TYPE c,
         type   TYPE usr12-typ,
       END OF ty_tabpro.

TYPES: BEGIN OF ty_aktpro,
         object TYPE usr12-objct,
         otext  TYPE tobjt-ttext,
         rule   TYPE usr12-auth,
       END OF ty_aktpro.

TYPES: BEGIN OF ty_aktpro_alv,
         object    TYPE usr12-objct,
         rule      TYPE usr12-auth,
         active    TYPE c,
         inact     TYPE c,
         otext     TYPE tobjt-ttext,
       END OF ty_aktpro_alv.

TYPES: BEGIN OF ty_missprof,
         profile   TYPE usr10-profn,
         coll_prof TYPE usr10-profn,
       END OF ty_missprof.

TYPES: BEGIN OF ty_missauth,
         otext   TYPE tobjt-ttext,
         rule    TYPE usr12-auth,
         profile TYPE usr10-profn,
       END OF ty_missauth.

TYPES: BEGIN OF ty_benutzer,
         bname TYPE usr02-bname,
       END OF ty_benutzer.


DATA: intpro  TYPE TABLE OF ty_intpro  INITIAL SIZE 30 WITH HEADER LINE,
      intpro2 TYPE TABLE OF ty_intpro2 INITIAL SIZE 30 WITH HEADER LINE.

DATA: tabcpf TYPE TABLE OF ty_cpf INITIAL SIZE 30 WITH HEADER LINE, "Int. Tab. fuer Profiles
      aktcpf TYPE TABLE OF ty_cpf INITIAL SIZE 30 WITH HEADER LINE. "Int. Tab. fuer Profiles

DATA: tabpro TYPE TABLE OF ty_tabpro INITIAL SIZE 30 WITH HEADER LINE.

DATA: tabprores TYPE TABLE OF ty_aktpro INITIAL SIZE 30 WITH HEADER LINE,
      aktpro    TYPE TABLE OF ty_aktpro INITIAL SIZE 30 WITH HEADER LINE.

DATA:   maxrul TYPE i VALUE 170.
DATA:   BEGIN OF tabrul OCCURS 30,   "Zwischenfelder fuer Bild Regeln
          auth LIKE usr12-auth,
        END OF tabrul.

DATA:   BEGIN OF aktrul OCCURS 30,   "Zwischenfelder fuer Bild Regeln
          auth LIKE usr12-auth,
        END OF aktrul.

DATA:   maxset TYPE i VALUE 100.
DATA:   BEGIN OF tabset OCCURS 30.  "Zwischenfelder fuer Bild Berecht
        INCLUDE STRUCTURE ustabset.    " ms 17.04.97  für exit
*         sfield like tobj-fiel1,
*         von(40),
*         bis(40),
DATA    END OF tabset.

DATA maint_tabset LIKE tabset OCCURS 30."note 560315


DATA saved_tabset LIKE LINE OF tabset OCCURS 0.      "b4
*
DATA:   BEGIN OF intfield OCCURS 10,  "Zwischenfelder fuer Bild Berecht
          fieldname LIKE tobj-fiel1,
          lng       TYPE i,
          type,
          ftext     LIKE dfies-fieldtext,
          convexit  LIKE dfies-convexit,
        END OF intfield.

DATA: BEGIN OF convout,
        filler1(16)  VALUE 'CONVERSION_EXIT_',
        convexit     LIKE dfies-convexit,
        filler2(7)   VALUE '_OUTPUT',
      END OF convout.
DATA: BEGIN OF convin,
        filler1(16)  VALUE 'CONVERSION_EXIT_',
        convexit     LIKE dfies-convexit,
        filler2(7)   VALUE '_INPUT',
      END OF convin.
DATA: convform LIKE convin.


DATA:   BEGIN OF aktset OCCURS 30,   "Zwischenfelder fuer Bild Berecht
          sfield LIKE tobj-fiel1,
          von LIKE tabset-von,
          bis LIKE tabset-bis,
        END OF aktset.

DATA:   BEGIN OF s,                    "Felder fuer SHOW-Windows
          user   LIKE usr04-bname,
          profile LIKE usr10-profn,
          object LIKE usr12-objct,
          auth LIKE usr12-auth,
          aktpas LIKE usr10-aktps,
          obj1 LIKE usr12-objct,
          obj2 LIKE usr12-objct,
          obj3 LIKE usr12-objct,
          obj4 LIKE usr12-objct,
          obj5 LIKE usr12-objct,
          obj6 LIKE usr12-objct,
          obj7 LIKE usr12-objct,
          val1 LIKE tabset-von,
          val2 LIKE tabset-von,
          val3 LIKE tabset-von,
          val4 LIKE tabset-von,
          akt1(1),
          akt2(1),
        END OF s.

DATA:   BEGIN OF intshow OCCURS 30,
          object    LIKE usr12-objct,
          auth      LIKE usr12-auth,
          cpf       LIKE usr10-profn,
          profile   LIKE usr10-profn,
          cauth     LIKE usr12-auth,
        END OF intshow.

DATA:   BEGIN OF relation1 OCCURS 30,
          father    LIKE usr10-profn,
          son       LIKE usr10-profn,
        END OF relation1.

DATA:   BEGIN OF relation2 OCCURS 30,
          father    LIKE usr10-profn,
          son       LIKE usr10-profn,
        END OF relation2.

DATA:   BEGIN OF fathers OCCURS 30,
          name    LIKE usr10-profn,
        END OF fathers.

DATA:   BEGIN OF sons OCCURS 30,
          name    LIKE usr10-profn,
        END OF sons.

DATA:   BEGIN OF values OCCURS 20,
          value   LIKE xu180-value,
        END OF values.

DATA:   stackdepth TYPE i VALUE 0.
DATA:   BEGIN OF profilestack OCCURS 10,
          profile LIKE usr10-profn,
        END OF profilestack.

DATA:   BEGIN OF fattr.
        INCLUDE STRUCTURE dfies.
DATA:   END OF fattr.

DATA:   stackptr TYPE i,               "Pointer fuer Ret.Nr.-Stack
        dnr      TYPE i.               "einzutragende Return-Nummer
DATA:   BEGIN OF stack OCCURS 10,      "Stack fuer Return-Nummern
          dnr TYPE i,
        END OF stack.


FIELD-SYMBOLS: <text>.                                      "#EC NEEDED
FIELD-SYMBOLS: <input>.
FIELD-SYMBOLS: <output>.                                    "#EC NEEDED
FIELD-SYMBOLS: <profile>.                                   "#EC NEEDED

*-----------------------------------------------------------------------
*                         ALV presentation
*-----------------------------------------------------------------------
DATA: g_local_cua  TYPE c,
      g_alvt(2)    TYPE c VALUE 'AV',
      g_collective TYPE c.

DATA: gt_cpf TYPE TABLE OF ty_cpf,
      gt_pro TYPE TABLE OF ty_aktpro.

DATA: gr_profiles TYPE REF TO cl_salv_table,
      gt_profiles TYPE TABLE OF ty_profiles.

DATA: gr_benutzer TYPE REF TO cl_salv_table,
      gt_benutzer TYPE TABLE OF ty_benutzer.

DATA: gr_container        TYPE REF TO cl_gui_container,
      splitter            TYPE REF TO cl_gui_splitter_container,
      gr_top_container    TYPE REF TO cl_gui_container,
      gr_upper_container  TYPE REF TO cl_gui_container,
      gr_bottom_container TYPE REF TO cl_gui_container,
      gr_left_container   TYPE REF TO cl_gui_container,
      gr_right_container  TYPE REF TO cl_gui_container.

DATA: gr_aktpro      TYPE REF TO cl_salv_table,
      gr_inaktpro    TYPE REF TO cl_salv_table,
      gr_top_of_page TYPE REF TO cl_salv_form_dydos,
      gt_aktpro      TYPE TABLE OF sim_show_prof_auth_alv,
      gt_inaktpro    TYPE TABLE OF sim_show_prof_auth_alv,
      gt_aktcpf      TYPE TABLE OF sim_show_coll_prof_alv,
      gt_inaktcpf    TYPE TABLE OF sim_show_coll_prof_alv.
*-----------------------------------------------------------------------
*    ALV presentation of values display for maintain
*-----------------------------------------------------------------------
DATA:
* docking container to display active values
  values_container         TYPE REF TO    cl_gui_docking_container,
* ALV Tree for active and maintain values
  values_tree_alv          TYPE REF TO    cl_salv_tree,
* fcode for 255 screen
  fcode255(4)              TYPE           c.
