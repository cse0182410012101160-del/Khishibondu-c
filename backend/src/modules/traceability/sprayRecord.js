class SprayRecord {
  constructor({ lotId, chemical, date, preHarvestDays }) {
    this.lotId = lotId;
    this.chemical = chemical;
    this.date = date;
    this.preHarvestDays = Number(preHarvestDays);
  }
}

function getHarvestWarning(records, harvestDate) {
  const harvest = new Date(harvestDate);
  const active = records.find((record) => {
    const sprayed = new Date(record.date);
    const intervalEnd = new Date(sprayed);
    intervalEnd.setDate(intervalEnd.getDate() + record.preHarvestDays);
    return harvest >= sprayed && harvest <= intervalEnd;
  });
  return active
    ? {
        warning: true,
        message: `Harvest falls within the ${active.preHarvestDays}-day pre-harvest interval for ${active.chemical}.`,
        sprayRecord: active,
      }
    : { warning: false, message: null, sprayRecord: null };
}

module.exports = { SprayRecord, getHarvestWarning };
