"""
This is a DaCHS processor (http://docs.g-vo.org/DaCHS/processors.html)
to add standard headers to FITS files from the FAI 50cm Maksutov telescope.
"""

import csv
import glob
import os
import re
import sys

from gavo.helpers import fitstricks
from gavo import api

TELESCOPE_LATIN = {
  "50cm менисковый телескоп Максутова":
    "Wide aperture Maksutov meniscus telescope with main mirror 50 cm",
  "Большой Шмидт": "Schmidt telescope (large camera)"}

FOCAL_LENGTHS = {
  "Wide aperture Maksutov meniscus telescope with main mirror 50 cm": 1.2,
  "Schmidt telescope (large camera)": 0.773,
  "Schmidt telescope (small camera)":0.17}
    
OBSERVERS_LATIN = {
  'Рожковский Д.А.': 'Rozhkovskij D.A.', 
  'Торопова Т.П.':'Tropova T.P.', 
  'Городецкий Д.И.':'Gordetskij D.I.',
  'Глушков Ю.И.':'Glushkovskij Yu.I.',
  'Торопова Т.П.  Рожковский Д.А.': 'Tropova T.P., Rozhkovskij D.A.',
  'Рожковский Д.А., Торопова Т.П.' : 'Rozhkovskij D.A., Tropova T.P.', 
  'Рожковский Д.А., Павлова Л.А.' : 'Rozhkovskij D.A., Pavlova L.A.',
  'Карягина З.В.':'Karyagina Z.V.', 
  'Матягин В.С.': 'Matyagin V.S.', 
  'Павлова Л.А': 'Pavlova L.A.', 
  'Гаврилов': 'Gavrilov', 
  'Курчаков А.В.': 'Kurchakov A.V.',
  'Рожковский Д.А.   Городецкий Д.И.':'Rozhkovskij D.A.   Gordetskij D.I.',
  'Солодовников В.В.': 'Solodovnikov V.V.'}



def parse_single_time(raw_time):
  """returns seconds of time for an h-m-s time string.

  Here is the syntax supported by the function.

  >>> parse_single_time("1h")
  3600.0
  >>> parse_single_time("4h30m")
  16200.0
  >>> parse_single_time("1h30m20s")
  5420.0
  >>> parse_single_time("20m")
  1200.0
  >>> parse_single_time("10.5m")
  630.0
  >>> parse_single_time("1m10s")
  70.0
  >>> parse_single_time("15s")
  15.0
  >>> parse_single_time("s23m")
  Traceback (most recent call last):
  ValueError: Cannot understand time 's23m'
  """
  mat = re.match(
    r"^(?P<hours>\d+(?:\.\d+)?h)?"
    r"(?P<minutes>\d+(?:\.\d+)?m)?"
    r"(?P<seconds>\d+(?:\.\d+)?s)?$", raw_time)
  if mat is None:
    raise ValueError(f"Cannot understand time '{raw_time}'")
  parts = mat.groupdict()

  return (float((parts["hours"] or "0h")[:-1])*3600
    + float((parts["minutes"] or "0m")[:-1])*60
    + float((parts["seconds"] or "0s")[:-1]))
  

def parse_exposure_times(raw_exp_times):
  """
  returns a list of floats giving the exposure times encoded in raw_exp_times.

  This is a ;-separated list of individual items.  see parse_single_time for
  details on the format.
  >>> parse_exposure_times("1h;2h;3h")
  [3600.0, 7200.0, 10800.0]
  >>> parse_exposure_times("1h30m20s;2h20m10s")
  [5420.0, 8410.0]
  >>> parse_exposure_times("1h30m20s;h20m10s")
  Traceback (most recent call last):
  ValueError: Cannot understand time 'h20m10s'
  """
  return [parse_single_time(raw_time) 
    for raw_time in raw_exp_times.split(";")]


def get_exposure_cards(raw_exp_times):
  """
  returns dict of keyword-value pairs for the FITS headers for our raw
  exposure times.

  >>> get_exposure_cards("1h")
  {'EXPTIME': 3600.0}
  >>> get_exposure_cards("1h;5h")
  {'EXPTIME': 3600.0, 'EXPTIM1': 3600.0, 'EXPTIM2': 18000.0}
  """
  exptimes = parse_exposure_times(raw_exp_times)
  if len(exptimes)==1:
    return {"EXPTIME": exptimes[0]}
  else:
    retval = {"EXPTIME": exptimes[0]}
    retval.update(dict(
      (f"EXPTIM{n+1}", val) for n, val in enumerate(exptimes)))
    return retval


def reformat_dec(raw_dec):
  """
  returns declination in the format "dd:mm:ss".

  >>> reformat_dec("29.06")
  '29:03:36'
  >>> reformat_dec("-23.30")
  '-23:18:00'
  >>> reformat_dec("50 41 45")
  '50:41:45'
  >>> reformat_dec("-01 28 02")
  >>> reformat_dec("-01 28")
  """
  if "." in raw_dec:
    return api.degToDms(float(raw_dec), sepChar=":")
  else:
    return raw_dec.replace(" ", ":")


def run_tests(*args):
  """
  runs all doctests and exits the program.
  """
  import doctest
  sys.exit(doctest.testmod()[0])


class PAHeaderAdder(api.HeaderProcessor):
  @staticmethod
  def addOptions(optParser):
    api.FileProcessor.addOptions(optParser)
    optParser.add_option("--test", help="Run unit tests, then exit",
      action="callback", callback=run_tests)

  def _createAuxiliaries(self, dd):
    logs_dir = os.path.join(
      dd.rd.resdir, "logbook")
    recs = []

    for src_f in glob.glob(logs_dir+"/*.csv"):
      with open(src_f, "r", encoding="utf-8") as f:
        rdr = csv.DictReader(f)
        desired_keys = dict(
          (n, (n or "EMPTY").split()[0]) for n in rdr.fieldnames)
        source_key = os.path.basename(src_f).split(".")[0]

        for rec in rdr:
          new_rec = {
            "source-file": source_key}
          for k, v in rec.items():
            new_key = desired_keys[k]
            if new_key=="Идентификационный":
              new_key = "ID"
            new_rec[new_key] = v
          recs.append(new_rec)

    self.platemeta = dict(
      (rec["ID"], rec) for rec in recs)

  def _isProcessed(self, srcName):
    return os.path.exists(srcName+".hdr")

  def _mungeHeader(self, srcName, hdr):
    plateid = srcName.split(".")[-2].split("_")[-1]
    thismeta = self.platemeta[plateid]

    #group 2
    #coords orig

    mat = re.match(r"(\d\d)h(\d\d)m$", thismeta["RA"])
    formatted_ra = "{}:{}".format(mat.group(1), mat.group(2))
    mat = re.match(r"(\d\d)\.(\d\d)$", thismeta["DEC"])
    formatted_dec = "{}:{}".format(mat.group(1), mat.group(2))
    cleaned_object = re.sub("[^ -~]+", "", thismeta["OBJECT"])

    #date orig

    #time start

    #time end

    #obj type

    #numexp

    #observat
    observatory = "Fesenkov Astrophysical Institute"
    sitename = "https://www.fai.kz"
    sitelong = 43.17667
    sitelat = 76.96611
    siteelev = 1450

    #telescope
    telescope = "unknown"
    if thismeta["TELESCOPE"]:
      telescope = TELESCOPE_LATIN[thismeta["TELESCOPE"]]

    foclen = foclen_dic.get(telescope)
    
    observer = OBSERVERS_LATIN[thismeta["OBSERVER"]]

    variable_arguments = get_exposure_cards(thismeta["EXPTIME"])
    # variable_arguments.update(...)

    return fitstricks.makeHeaderFromTemplate(
      fitstricks.WFPDB_TEMPLATE,
      originalHeader=hdr,
      RA_ORIG=formatted_ra,
      DEC_ORIG=formatted_dec,
#      OBSERVER=thismeta["OBSERVER"],
      OBJECT=cleaned_object,
      EXPTIM=exptime,
      SCANAUTH="Shomshekova S., Umirbayeva A., Moshkina S.",
      ORIGIN="Contant",
      **variable_arguments)


if __name__=="__main__":
  api.procmain(PAHeaderAdder, "fai50mak/q", "import")
