<resource schema="test2" resdir=".">
  <meta name="creationDate">2022-11-03T12:16:29Z</meta>

  <meta name="title">Archive of the FAI 50 cm Meniskus Maksutov</meta>

  <meta name="description">
The archive of Plates of the Fesenkov Astrophysical Institute (FAI) is an archive of digitized plates and films of the Institute's Glass Library. They represent the results of photometric and spectral observations for about 50 years - from 1950 to 2000.    
  </meta>
  <!-- Take keywords from 
    http://www.ivoa.net/rdf/uat
    if at all possible -->
  <meta name="subject">History of astronomy, Active galaxies, Nebulae, Comets, Minor Planets </meta>

  <meta name="creator">Fesenkov Astrophysical Institute</meta>
  <meta name="instrument">Image intensifier</meta>
  <meta name="facility">Fesenkov Astrophysical Institute</meta>

  <!-- <meta name="source"></meta> -->
  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>  <!-- or Archive, Survey, Simulation -->

  <!-- Waveband is of Radio, Millimeter, 
      Infrared, Optical, UV, EUV, X-ray, Gamma-ray, can be repeated -->
  <meta name="coverage.waveband">Optical</meta>

  <table id="main" onDisk="True" mixin="//siap#pgs" adql="True">

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
  
    </table>

 	<coverage>
    <updater sourceTable="main"/>
  </coverage>

  <!-- if you have data that is continually added to, consider using
    updating="True" and an ignorePattern here; see also howDoI.html,
    incremental updating -->
  <data id="import">
    <sources pattern="data/*.fits"/>

    <!-- the fitsProdGrammar should do it for whenever you have
    halfway usable FITS files.  If they're not halfway usable,
    consider running a processor to fix them first – you'll hand
    them out to users, and when DaCHS can't deal with them, chances
    are their clients can't either -->
    <fitsProdGrammar>
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.main"</bind>
      </rowfilter>
    </fitsProdGrammar>

    <make table="main">
      <rowmaker>
        <!-- put vars here to pre-process FITS keys that you need to
          re-format in non-trivial ways. -->
        <apply procDef="//siap#setMeta">
          <!-- DaCHS can deal with some time formats; otherwise, you
            may want to use parseTimestamp(@DATE_OBS, '%Y %m %d...') -->
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

        <!-- any custom columns need to be mapped here; do *not* use
          idmaps="*" with SIAP -->
      </rowmaker>
    </make>
  </data>

  <!-- if you want to build an attractive form-based service from
    SIAP, you probably want to have a custom form service; for
    just basic functionality, this should do, however. -->
  <service id="i" allowed="form,siap.xml">
    <meta name="shortName">%up to 16 characters%</meta>

    <!-- other sia.types: Cutout, Mosaic, Atlas -->
    <meta name="sia.type">Pointed</meta>
    
    <meta name="testQuery.pos.ra">%ra one finds an image at%</meta>
    <meta name="testQuery.pos.dec">%dec one finds an image at%</meta>
    <meta name="testQuery.size.ra">0.1</meta>
    <meta name="testQuery.size.dec">0.1</meta>

    <!-- this is the VO publication -->
    <publish render="scs.xml" sets="ivo_managed"/>
    <!-- this puts the service on the root page -->
    <publish render="form" sets="local,ivo_managed"/>
    <!-- all publish elements only become active after you run
      dachs pub q -->

    <dbCore queriedTable="main">
      <condDesc original="//siap#protoInput"/>
      <condDesc original="//siap#humanInput"/>
      <condDesc buildFrom="dateObs"/>


      <!-- enable further parameters like
        <condDesc>
          <inputKey name="object" type="text" 
              tablehead="Target Object" 
              description="Object being observed, Simbad-resolvable form"
              ucd="meta.name" verbLevel="5" required="True">
              <values fromdb="object FROM lensunion.main"/>
          </inputKey>
        </condDesc> -->
    </dbCore>
  </service>

  <regSuite title="test2 regression">
    <!-- see http://docs.g-vo.org/DaCHS/ref.html#regression-testing
      for more info on these. -->

    <regTest title="test2 SIAP serves some data">
      <url POS="%ra,dec that has a bit of data%" SIZE="0.1,0.1"
        >i/siap.xml</url>
      <code>
        <!-- to figure out some good strings to use here, run
          dachs test -D tmp.xml q
          and look at tmp.xml -->
        self.assertHasStrings(
          "%some characteristic string returned by the query%",
          "%another characteristic string returned by the query%")
      </code>
    </regTest>

    <!-- add more tests: image actually delivered, form-based service
      renders custom widgets, etc. -->
  </regSuite>
</resource>
