<resource schema="maksutov_50_telescope" resdir=".">
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
  
    <column name="object" type="text"
      ucd="meta.id;src"
      tablehead="Objs."
      description="Name of object from the observation log."
      verbLevel="3"/>
    <column name="filename" type="text"
      ucd="meta.id;src"
      tablehead="FileName."
      description="Name of .fit file (object_date_exp_id.fit)."
      verbLevel="5"/>
    <column original="dateObs"
      description="The date of observation from observational log. (Y-M-D .. Y-M-D)"/>
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
    <column name="telescope" type="text"
      ucd="instr.tel"
      tablehead="Telescope"
      description="Telescope from observation log."
      verbLevel="5"/>
  </table>

  <coverage>
    <updater sourceTable="main"/>
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
          telescope: TELESCOP,
          filename: FILENAME,
        </simplemaps>
        <var key="perhaps_date_obs" nullExcs="KeyError">@DATE_OBS</var>

        <apply procDef="//siap#setMeta">
          <bind key="bandpassId">"Optical"</bind>
          <bind key="title">@FILENAME</bind>
          <bind key="dateObs">@perhaps_date_obs</bind>
        </apply>

        <apply procDef="//siap#getBandFromFilter"/>
        <apply procDef="//siap#computePGS"/>

        <map key="object" source="OBJECT" nullExcs="KeyError"/>
        <map key="target_ra" source="OBJCTRA" nullExcs="KeyError"/>
        <map key="target_dec" source="OBJCTDEC" nullExcs="KeyError"/>
        <map key="exptime" source="EXPTIME" nullExcs="KeyError"/>
      </rowmaker>
    </make>
  </data>

  <table id="calibration" onDisk="True" mixin="//products#table">
    <column original="main.dateObs"/>
    <column name="exptime"
      unit="s" ucd="time.duration;obs.exposure"
      tablehead="T.Exp"
      description="Exposure time from observation log."
      verbLevel="5"/>
    <column name="telescope" type="text"
      ucd="instr.tel"
      tablehead="Telescope"
      description="Telescope from observation log."
      verbLevel="5"/>
  </table>

  <data id="import_calibration">
    <sources pattern="/var/gavo/inputs/astroplates/maksutov_50_telescope/calib_frames/*.fit"/>
    <fitsProdGrammar>
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.calibration"</bind>
      </rowfilter>
    </fitsProdGrammar>
    
    <make table="calibration">
      <rowmaker>
        <simplemaps>
          telescope: TELESCOP,
          exptime: EXPTIME
        </simplemaps>
        <map key="dateObs">dateTimeToMJD(parseTimestamp(@DATE_OBS))</map>
      </rowmaker>
    </make>
  </data>

  <service id="cal" allowed="form">
    <meta name="title">FAI Calibration Data for 50 cm Meniskus Maksutov telescope</meta>
    <meta name="description">
        This service collects plates taken for calibration purposes
        on FAI's 50 cm Meniskus Maksutov telescope. 
        Calibration frames are used for correction and enhancement of astronomical images.
        They allow the conversion of optical densities of an image into relative intensities
        and subtract the background radiation, making the data suitable for scientific analysis.
    </meta>
    <!-- TODO: Metadata -->
    <dbCore queriedTable="calibration">
      <condDesc buildFrom="dateObs"/>
      <condDesc buildFrom="exptime"/>
      <condDesc>
        <inputKey original="telescope">
          <values fromdb="telescope FROM \schema.calibration"/>
        </inputKey>
      </condDesc>
    </dbCore>
  </service>

  <dbCore queriedTable="main" id="imagecore">
    <condDesc original="//siap#protoInput"/>
    <condDesc original="//siap#humanInput"/>
    <condDesc buildFrom="dateObs"/>
    <condDesc>
      <inputKey name="object" type="text"
        tablehead="Target Object" 
        description="Object being observed, Simbad-resolvable form"
        ucd="meta.name"> 
        <values fromdb="object FROM maksutov_50_telescope.main ORDER BY object"/>
      </inputKey>
    </condDesc>
    <!--<condDesc>
      <inputKey name="object" type="text"
        tablehead="Target Object" 
        description="Object being observed, Simbad-resolvable form"
        ucd="meta.name">
        <values fromdb="object FROM maksutov_50_telescope.main"/>
      </inputKey>
      <phraseMaker>
        <setup imports="numpy"/>
        <code><![CDATA[
          yield "%({})s && object".format(
            base.getSQLKey("object", inPars["object"], outPars))
        ]]></code>
      </phraseMaker>
    </condDesc> -->
  </dbCore>

  <service id="web" allowed="form" core="imagecore">
    <meta name="shortName">maksutov_50_telescope web</meta>
    <meta name="title">Web interface to FAI 50 cm Meniskus Maksutov
      telescope archive</meta>
    <meta name="_related" title="Calibration data for these frames">
      \internallink{\rdId/cal/form}
    </meta>

    <outputTable autoCols="accref,accsize,centerAlpha,centerDelta,
        dateObs"><!--,imageTitle">-->
      <outputField original="object">
        <formatter>
          return "".join(data)
        </formatter>
      </outputField>
    </outputTable>
  </service>

  <service id="i" allowed="form,siap.xml" core="imagecore">
    <meta name="shortName">maksutov_50_telescope siap</meta>

    <meta name="sia.type">Pointed</meta>
    
    <meta name="testQuery.pos.ra">84.4</meta>
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
      <url POS="84.4,9.3" SIZE="0.1,0.1"
        >i/siap.xml</url>
      <code>
        rows = self.getVOTableRows()
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertEqual(row["object"], "lam Ori")
        self.assertEqual(row["filename"], 
                'lambda-Ori_209-10.02.1958_20m_11-1964.fit')
      </code>
    </regTest>
  </regSuite>
</resource>
