import dotenv from 'dotenv';

dotenv.config();

const GOOGLE_GEOCODE_BASE = 'https://maps.googleapis.com/maps/api/geocode/json';

export const geocodeAddress = async (address) => {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) {
    console.warn('Google Maps API key not configured. Using fallback coordinates.');
    return getFallbackCoordinates(address);
  }

  try {
    const url = `${GOOGLE_GEOCODE_BASE}?address=${encodeURIComponent(address)}&key=${apiKey}&region=IN`;
    const response = await fetch(url);
    const data = await response.json();

    if (data.status === 'OK' && data.results.length > 0) {
      const { lat, lng } = data.results[0].geometry.location;
      const formattedAddress = data.results[0].formatted_address;
      const components = data.results[0].address_components;

      const getComponent = (types) => components.find((c) => types.some((t) => c.types.includes(t)))?.long_name || '';

      return {
        latitude: lat,
        longitude: lng,
        formattedAddress,
        pincode: getComponent(['postal_code']),
        city: getComponent(['locality', 'administrative_area_level_2']),
        state: getComponent(['administrative_area_level_1']),
        country: getComponent(['country']),
        placeId: data.results[0].place_id,
      };
    }

    console.warn(`Geocoding failed for "${address}": ${data.status}`);
    return getFallbackCoordinates(address);
  } catch (error) {
    console.error('Geocoding error:', error.message);
    return getFallbackCoordinates(address);
  }
};

export const reverseGeocode = async (latitude, longitude) => {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) {
    return { formattedAddress: `${latitude}, ${longitude}` };
  }

  try {
    const url = `${GOOGLE_GEOCODE_BASE}?latlng=${latitude},${longitude}&key=${apiKey}&region=IN`;
    const response = await fetch(url);
    const data = await response.json();

    if (data.status === 'OK' && data.results.length > 0) {
      const components = data.results[0].address_components;

      const getComponent = (types) => components.find((c) => types.some((t) => c.types.includes(t)))?.long_name || '';

      return {
        formattedAddress: data.results[0].formatted_address,
        pincode: getComponent(['postal_code']),
        city: getComponent(['locality', 'administrative_area_level_2']),
        state: getComponent(['administrative_area_level_1']),
        country: getComponent(['country']),
        placeId: data.results[0].place_id,
      };
    }

    return { formattedAddress: `${latitude}, ${longitude}` };
  } catch (error) {
    console.error('Reverse geocoding error:', error.message);
    return { formattedAddress: `${latitude}, ${longitude}` };
  }
};

const getFallbackCoordinates = (address) => {
  const lower = address.toLowerCase();
  if (lower.includes('mumbai')) return { latitude: 19.076, longitude: 72.8777, city: 'Mumbai', state: 'Maharashtra' };
  if (lower.includes('delhi')) return { latitude: 28.7041, longitude: 77.1025, city: 'Delhi', state: 'Delhi' };
  if (lower.includes('bangalore') || lower.includes('bengaluru')) return { latitude: 12.9716, longitude: 77.5946, city: 'Bengaluru', state: 'Karnataka' };
  if (lower.includes('hyderabad')) return { latitude: 17.385, longitude: 78.4867, city: 'Hyderabad', state: 'Telangana' };
  if (lower.includes('chennai')) return { latitude: 13.0827, longitude: 80.2707, city: 'Chennai', state: 'Tamil Nadu' };
  if (lower.includes('pune')) return { latitude: 18.5204, longitude: 73.8567, city: 'Pune', state: 'Maharashtra' };
  if (lower.includes('ahmedabad')) return { latitude: 23.0225, longitude: 72.5714, city: 'Ahmedabad', state: 'Gujarat' };
  if (lower.includes('kolkata')) return { latitude: 22.5726, longitude: 88.3639, city: 'Kolkata', state: 'West Bengal' };
  if (lower.includes('jaipur')) return { latitude: 26.9124, longitude: 75.7873, city: 'Jaipur', state: 'Rajasthan' };
  if (lower.includes('lucknow')) return { latitude: 26.8467, longitude: 80.9462, city: 'Lucknow', state: 'Uttar Pradesh' };
  if (lower.includes('surat')) return { latitude: 21.1702, longitude: 72.8311, city: 'Surat', state: 'Gujarat' };
  if (lower.includes('noida')) return { latitude: 28.5355, longitude: 77.391, city: 'Noida', state: 'Uttar Pradesh' };
  if (lower.includes('gurgaon') || lower.includes('gurugram')) return { latitude: 28.4595, longitude: 77.0266, city: 'Gurugram', state: 'Haryana' };
  if (lower.includes('chandigarh')) return { latitude: 30.7333, longitude: 76.7794, city: 'Chandigarh', state: 'Chandigarh' };
  if (lower.includes('indore')) return { latitude: 22.7196, longitude: 75.8577, city: 'Indore', state: 'Madhya Pradesh' };
  if (lower.includes('bhopal')) return { latitude: 23.2599, longitude: 77.4126, city: 'Bhopal', state: 'Madhya Pradesh' };
  if (lower.includes('kochi') || lower.includes('cochin')) return { latitude: 9.9312, longitude: 76.2673, city: 'Kochi', state: 'Kerala' };
  if (lower.includes('thiruvananthapuram') || lower.includes('trivandrum')) return { latitude: 8.5241, longitude: 76.9366, city: 'Thiruvananthapuram', state: 'Kerala' };
  if (lower.includes('visakhapatnam')) return { latitude: 17.6868, longitude: 83.2185, city: 'Visakhapatnam', state: 'Andhra Pradesh' };
  if (lower.includes('nagpur')) return { latitude: 21.1466, longitude: 79.0882, city: 'Nagpur', state: 'Maharashtra' };
  return { latitude: 20.5937, longitude: 78.9629, city: '', state: '' };
};
