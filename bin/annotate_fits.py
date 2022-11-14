from gavo.helpers import fitstricks
from gavo import api

class PAHeaderAdder(api.HeaderProcessor):

  def _createAuxiliaries(self, dd):
    # read the observation log from somewher in the resdir
    # it's usually a good idea to use a DaCHS parser for that, but
    # let's keep this example straightforward.
    self.platemeta = {}
    colLabels = ["plateid", "epoch", "emulsion", "observer", "object"]

    with open(os.path.join(dd.rd.resdir, "data", "platecat.tsv") as f:
      for ln in f:
        rec = dict(zip(colLabels, [s.strip() for s in ln.split("\t")]))
      self.platemeta[rec["plateid"] = rec

  def _isProcessed(self, srcName):
    # typically, check for a header that's not in your input files
    return "OBSERVER" in self.getPrimaryHeader(srcName)

  def _mungeHeader(self, srcName, hdr):
    plateid = hdr["PLATEID"] # more typically: grab it from srcName
    thismeta = self.platemeta["plateid"]

    # you'll usually want to drop some junky headers from hdr
    del hdr["BROKEN"]

    return fitstricks.makeHeaderFromTemplate(
      fitstricks.WFPDB_TEMPLATE,
      originalHeader=hdr,
      DATEORIG=api.jYearToDateTime(float(thismeta["epoch"])).isoformat(),
      EMULISON=thismeta["epoch"],
      OBSERVER=thismeta["observer"],
      OBJECT=thismeta["object"],
      ORIGIN="Contant")
