<resource schema="maksutov_50_telescope" resdir="maksutov_50_telescope">
  <meta name="creationDate">2022-11-03T12:16:29Z</meta>

  <meta name="title">Archive of the FAI 50 cm Meniskus Maksutov telescope</meta>

  <meta name="description">
The archive of digitized plates obtained on Wide aperture Maksutov meniscus telescope with main mirror 50 cm at the Fesenkov Astrophysical Institute (FAI), Almaty, Kazakhstan. 
They represent the results of photometric observations of stars, comets, nebulae etc. for 50 years - from 1950 to 2000.    
  Observations were carried out in the optical range. Telescope specifications: diameter of main mirror D = 500 mm, focal length F = 1200 mm.
  </meta>
  <!-- Take keywords from 
    http://www.ivoa.net/rdf/uat
    if at all possible -->
  <meta name="subject">history-of-astronomy></meta>
  <meta name="subject">gaseous-nebulae</meta>
  <meta name="subject">comets</meta>
  <meta name="subject">field-of-view</meta>

  <meta name="creator">Fesenkov Astrophysical Institute</meta>
  <meta name="instrument">Wide aperture Maksutov meniscus telescope with main mirror 50 cm</meta>
  <meta name="facility">Fesenkov Astrophysical Institute</meta>

  <!-- <meta name="source"></meta> -->
  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>  <!-- or Archive, Survey, Simulation -->

  <meta name="coverage.waveband">Optical</meta>

  <table id="main" onDisk="True" mixin="//siap#pgs" adql="False">
    
    <mixin
      calibLevel="2"
      collectionName="'FAI Mak50'"
      targetName="object"
      expTime="EXPTIME"
    >//obscore#publishSIAP</mixin>
  
    <column name="object" type="char(15)[]"
      ucd="meta.id;src"
      tablehead="Objs."
      description="Name of object from the observation log."
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
    <temporal>1950-01-01 2000-01-01</temporal>
  </coverage>

  <data id="import">
    <sources pattern="/var/gavo/inputs/astroplates/maksutov_50_telescope/data/*.fit"/>

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
            "MyData {} {} {}".format(@DATE_OBS, @TARGET, @FILTER)
          <bind key="title">"{}_{}_{}_{}".format(@OBJECT, @DATEORIG, @EXPTIME, @PID)</bind>-->
          <bind key="title">@FILENAME</bind>
        </apply>

        <apply procDef="//siap#getBandFromFilter"/>

        <apply procDef="//siap#computePGS"/>

        <map key="target_ra" source="OBJCTRA" nullExcs="KeyError"/>
        <map key="target_dec" source="OBJCTDEC" nullExcs="KeyError"/>
        <map key="observer" source="OBSERVER" nullExcs="KeyError"/>
      </rowmaker>
    </make>
  </data>

  <dbCore queriedTable="main" id="imagecore">
    <condDesc original="//siap#protoInput"/>
    <condDesc original="//siap#humanInput"/>
    <condDesc buildFrom="dateObs"/>
    <condDesc>
      <inputKey name="object" type="text" multiplicity="multiple"
          tablehead="Target Object" 
          description="Object being observed, Simbad-resolvable form"
          ucd="meta.name">
          <values fromdb="unnest(object) FROM maksutov_50_telescope.main"/>
      </inputKey>
      <phraseMaker>
        <setup imports="numpy"/>
        <code><![CDATA[
          yield "%({})s && objects".format(
            base.getSQLKey("object", 
            numpy.array(inPars["object"]), outPars))
        ]]></code>
      </phraseMaker>
    </condDesc>
  </dbCore>

  <service id="web" allowed="form" core="imagecore">
    <meta name="shortName">maksutov_50_telescope web</meta>
    <meta name="title">Web interface to FAI 50 cm Meniskus Maksutov
      telescope archive</meta>
    <outputTable autoCols="accref,accsize,centerAlpha,centerDelta,
        dateObs,imageTitle">
      <outputField original="object">
        <formatter>
          return " - ".join(data)
        </formatter>
      </outputField>
    </outputTable>
  </service>

  <service id="i" allowed="form,siap.xml" core="imagecore">
    <meta name="shortName">maksutov_50_telescope siap</meta>

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

  <regSuite title="maksutov_50_telescope regression">
    <!-- see http://docs.g-vo.org/DaCHS/ref.html#regression-testing
      for more info on these. -->

    <regTest title="maksutov_50_telescope SIAP serves some data">
      <url POS="84.2,9.3" SIZE="0.1,0.1"
        >i/siap.xml</url>
      <code>
        rows = self.getVOTableRows()
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertEqual(row["object"][0].strip(), "lam Ori")
        self.assertEqual(len(row["object"]), 1)
        self.assertEqual(row["imageTitle"], 
                'lambda-Ori_209-10.02.1958_20m_11-1964.fit')
      </code>
    </regTest>

    <regTest title="Multiple objects can be queried">
      <url parSet="form">
      	<object>M20</object>
      	<object>lam Ori</object>web/form</url>
      <code><![CDATA[
      	self.assertHasStrings("29.8MiB",  # size or lam Ori image
      		"M8-NGC6523-M", # part of m8 filename
      		"<td>M8-NGC6523-M20-NGC6514_08-09.07.1953_35m_13-79")
      	self.assertLacksStrings(
      		"31.03-01.04.1960" # part of a non-matching image in the test set
      	)
      ]]></code>
    </regTest>
  </regSuite>
</resource>
