<resource schema="fai50mak" resdir="fai50mak">
  <meta name="creationDate">2022-11-03T12:16:29Z</meta>

  <meta name="title">Archive of the FAI 50 cm Meniskus Maksutov telescope</meta>

  <meta name="description">
The archive of digitized plates obtained on Wide aperture Maksutov meniscus telescope with main mirror 50 cm at the Fesenkov Astrophysical Institute (FAI), Almaty, Kazakhstan. They represent the results of photometric and spectral observations of stars, star clusrets, active galaxies, nebulaes, etc. for about 50 years - from 1950 to 1997.    
  Observations were carried out in the optical range. Telescope specifications: diameter of main mirror D = 500 mm, focal length F = 1200 mm.
  </meta>
  <!-- Take keywords from 
    http://www.ivoa.net/rdf/uat
    if at all possible -->
  <meta name="subject">history-of-astronomy></meta>
  <meta name="subject">active-galaxies</meta>
  <meta name="subject">gaseous-nebulae</meta>
  <meta name="subject">star-clusters</meta>
  <meta name="subject">comets</meta>
  <meta name="subject">binary-stars</meta>
  <meta name="subject">multiple-stars</meta>

  <meta name="creator">Fesenkov Astrophysical Institute</meta>
  <meta name="instrument">Wide aperture Maksutov meniscus telescope with main mirror 50 cm</meta>
  <meta name="facility">Fesenkov Astrophysical Institute</meta>

  <!-- <meta name="source"></meta> -->
  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>  <!-- or Archive, Survey, Simulation -->

  <meta name="coverage.waveband">Optical</meta>

  <table id="main" onDisk="True" mixin="//siap#pgs" adql="False">
    
    <!-- in the following, just delete any attribute you don't want to
    set.
    
    Get the target class, if any, from 
    http://simbad.u-strasbg.fr/guide/chF.htx -->
   <!--  <mixin
      calibLevel="2"
      collectionName="'%a few letters identifying this data%'"
      targetName="%column name of an object designation%"
      expTime="%column name of an exposure time%"
      targetClass="'%simbad target class%'"
    >//obscore#publishSIAP</mixin> -->
  
    <column name="objects" type="text[]"
      ucd="meta.id;src"
      tablehead="Objs."
      description="Names objects from the observation log."
      verbLevel="3"/>
    <column name="target_ra"
      unit="deg" ucd="pos.eq.ra;meta.main"
      tablehead="Target RA"
      description="Right ascension of object from observation log."
      verbLevel="1"/>
    <column name="target_dec"
      unit="deg" ucd="pos.eq.dec;meta.main"
      tablehead="Target Dec"
      description="Declination of object from observation log."
      verbLevel="1"/>
    <column name="exptime"
      unit="s" ucd="time.duration;obs.exposure"
      tablehead="T.Exp"
      description="Exposure time from observation log."
      verbLevel="5"/>
    <column name="observer" type="text"
      ucd="meta.id;obs.observer"
      tablehead="Obs. by."
      description="Observer name from observation log."
      verbLevel="20"/>
    <column name="telescope" type="text"
      ucd="instr.tel"
      tablehead="Telescope"
      description="Telescope from observation log."
      verbLevel="5"/>

  </table>

  <coverage>
    <updater sourceTable="main"/>
    <temporal>1950-01-01 1997-12-31</temporal>
  </coverage>

  <data id="import">
    <sources pattern="data/*.fits"/>

    <fitsProdGrammar>
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.main"</bind>
      </rowfilter>
    </fitsProdGrammar>

    <make table="main">
      <rowmaker>
        <simplemaps>
          exptime: EXPTIME,
          telescope: TELESCOP
        </simplemaps>
        <apply procDef="//siap#setMeta">
          <bind key="dateObs">@DATE_OBS</bind>

          <!-- bandpassId should be one of the keys from
            dachs adm dumpDF data/filters.txt;
            perhaps use //procs#dictMap for clean data from the header. -->
          <bind key="bandpassId">"Optical"</bind>

          <!-- pixflags is one of: C atlas image or cutout, F resampled, 
            X computed without interpolation, Z pixel flux calibrated, 
            V unspecified visualisation for presentation only 
          <bind key="pixflags"></bind> -->
          
          <!-- titles are what users usually see in a selection, so
            try to combine band, dateObs, object..., like
            "MyData {} {} {}".format(@DATE_OBS, @TARGET, @FILTER) -->
          <bind key="title">@IRAFNAME</bind>
        </apply>

        <apply procDef="//siap#getBandFromFilter"/>

        <apply procDef="//siap#computePGS"/>

        <apply procDef="//procs#mapValue">
          <bind name="destination">"mapped_names"</bind>
          <bind name="failuresMapThrough">True</bind>
          <bind name="logFailures">True</bind>
          <bind name="value">@OBJECT</bind>
          <bind name="sourceName">"fai50mak/res/name-map.txt"</bind>
        </apply>

        <map key="target_ra">hmsToDeg(@OBJCTRA, sepChar=":")</map>
        <map key="target_dec">dmsToDeg(@OBJCTDEC, sepChar=":")</map>
        <map key="observer" source="OBSERVER" nullExcs="KeyError"/>
        <map key="objects">@mapped_names.split("|")</map>
      </rowmaker>
    </make>
  </data>

  <dbCore queriedTable="main" id="imagecore">
    <condDesc original="//siap#protoInput"/>
    <condDesc original="//siap#humanInput"/>
    <condDesc buildFrom="dateObs"/>
    <condDesc>
      <inputKey name="object" type="text" multiplicity="force-single"
          tablehead="Target Object" 
          description="Object being observed, Simbad-resolvable form"
          ucd="meta.name">
          <values fromdb="unnest(objects) FROM fai50mak.main"/>
      </inputKey>
      <phraseMaker>
        <code><![CDATA[
          yield "array[%({})s] && objects".format(
            base.getSQLKey("object", inPars["object"], outPars))
        ]]></code>
      </phraseMaker>
    </condDesc>
  </dbCore>

  <service id="web" allowed="form" core="imagecore">
    <meta name="shortName">fai50mak web</meta>
    <outputTable autoCols="accref,accsize,centerAlpha,centerDelta,
        dateObs,imageTitle">
      <outputField original="objects">
        <formatter>
          return " - ".join(data)
        </formatter>
      </outputField>
    </outputTable>
  </service>

  <service id="i" allowed="form,siap.xml" core="imagecore">
    <meta name="shortName">fai50mak siap</meta>

    <meta name="sia.type">Pointed</meta>
    
    <meta name="testQuery.pos.ra">84.2</meta>
    <meta name="testQuery.pos.dec">9.3</meta>
    <meta name="testQuery.size.ra">0.1</meta>
    <meta name="testQuery.size.dec">0.1</meta>

    <!-- this is the VO publication -->
    <publish render="siap.xml" sets="ivo_managed"/>
    <!-- this puts the service on the root page -->
    <publish render="form" sets="local,ivo_managed" service="web"/>

  </service>

  <regSuite title="fai50mak regression">
    <!-- see http://docs.g-vo.org/DaCHS/ref.html#regression-testing
      for more info on these. -->

    <regTest title="fai50mak SIAP serves some data">
      <url POS="84.2,9.3" SIZE="0.1,0.1"
        >i/siap.xml</url>
      <code>
        rows = self.getVOTableRows()
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertEqual(row["object"], "lambda-Ori")
        self.assertEqual(row["imageTitle"], 
                'lambda-Ori_209-10.02.1958_20m_11-1964.fit')
      </code>
    </regTest>

    <!-- add more tests: image actually delivered, form-based service
      renders custom widgets, etc. -->
  </regSuite>
</resource>
