const db = require('../../database/store');

function getProcurementView(req, res) {
  const { search, district, category, minQuantity } = req.query;
  let lots = db.crops.filter(crop => crop.status === 'Listed' || crop.status === 'Negotiating');

  if (search) {
    const term = search.toLowerCase();
    lots = lots.filter(crop => `${crop.title} ${crop.titleBn || ''} ${crop.description || ''}`.toLowerCase().includes(term));
  }
  if (district) lots = lots.filter(crop => crop.district.toLowerCase() === district.toLowerCase());
  if (category) lots = lots.filter(crop => crop.category.toLowerCase() === category.toLowerCase());
  if (minQuantity) lots = lots.filter(crop => Number(crop.quantity) >= Number(minQuantity));

  const suppliers = [...new Map(lots.map(crop => [crop.farmerId, {
    farmerId: crop.farmerId,
    farmerName: crop.farmerName,
    district: crop.district,
    rating: crop.farmerRating,
    activeLots: lots.filter(item => item.farmerId === crop.farmerId).length
  }])).values()];

  return res.json({ success: true, lots, suppliers, orderHistory: db.orders.filter(order => order.buyerId === req.user.id) });
}

module.exports = { getProcurementView };
