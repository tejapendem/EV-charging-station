import dotenv from 'dotenv';

dotenv.config();

const BASE_URL = 'https://api.api-ninjas.com/v1/evcharger';

export const fetchNearbyEVChargers = async ({ lat, lon, distance, limit }) => {
  const apiKey = process.env.API_NINJAS_KEY;
  if (!apiKey) {
    console.warn('API Ninjas key not configured');
    return [];
  }

  const params = new URLSearchParams({
    lat: lat.toString(),
    lon: lon.toString(),
  });
  if (distance) params.append('distance', distance.toString());
  if (limit) params.append('limit', limit.toString());

  try {
    const response = await fetch(`${BASE_URL}?${params}`, {
      headers: { 'X-Api-Key': apiKey },
    });

    if (!response.ok) {
      console.error(`API Ninjas error: ${response.status} ${response.statusText}`);
      return [];
    }

    const data = await response.json();
    return data.map(normalizeCharger);
  } catch (error) {
    console.error('API Ninjas request failed:', error.message);
    return [];
  }
};

const normalizeCharger = (item) => ({
  id: null,
  name: item.name || 'Unknown Station',
  address: item.address || '',
  city: item.city || '',
  state: item.region || '',
  country: item.country || '',
  latitude: item.latitude,
  longitude: item.longitude,
  is_active: item.is_active ?? true,
  connections: (item.connections || []).map((c) => ({
    type_name: c.type_name || '',
    type_official: c.type_official || '',
    level: c.level,
    num_connectors: c.num_connectors || 0,
  })),
  is_external: true,
  source: 'api_ninjas',
});
