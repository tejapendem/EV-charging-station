import { fetchNearbyEVChargers } from '../services/apiNinjasService.js';
import { buildSuccessResponse, buildErrorResponse } from '../utils/helpers.js';

export const getExternalChargers = async (req, res) => {
  try {
    const { lat, lon, distance, limit } = req.query;

    const chargers = await fetchNearbyEVChargers({
      lat: parseFloat(lat),
      lon: parseFloat(lon),
      distance: distance ? parseFloat(distance) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });

    return res.json(buildSuccessResponse({ chargers }));
  } catch (error) {
    console.error('External charger fetch error:', error);
    return res.status(500).json(buildErrorResponse('Failed to fetch external chargers'));
  }
};
