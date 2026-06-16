import React, { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Box,
  Typography,
  Paper,
  Grid,
  TextField,
  Button,
  Chip,
  IconButton,
  MenuItem,
  Snackbar,
  Alert,
  CircularProgress,
  Divider,
  Card,
  CardMedia,
  CardActions,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import { stationsAPI } from '../services/api';
import StatusBadge from '../components/StatusBadge';

const CHARGER_TYPES = ['CCS2', 'CHAdeMO', 'Type 2', 'GB/T', 'Tesla Supercharger'];
const COMMON_AMENITIES = ['Parking', 'Restroom', 'Cafe', 'WiFi', '24/7 Access', 'Security', 'Shopping', 'Hotel'];

export default function StationEdit() {
  const { id } = useParams();
  const navigate = useNavigate();
  const isNew = id === 'new';

  const [form, setForm] = useState({
    name: '',
    address: '',
    city: '',
    state: '',
    pincode: '',
    latitude: '',
    longitude: '',
    status: 'pending',
    chargerTypes: [{ type: 'CCS2', count: 1, power: '50kW' }],
    amenities: [],
    photos: [],
    openingTime: '00:00',
    closingTime: '23:59',
    contactPhone: '',
    contactEmail: '',
    pricePerKwh: '',
  });
  const [loading, setLoading] = useState(!isNew);
  const [saving, setSaving] = useState(false);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const [amenityInput, setAmenityInput] = useState('');

  useEffect(() => {
    if (!isNew && id) {
      const fetchStation = async () => {
        try {
          const { data } = await stationsAPI.getById(id);
          const station = data.station || data;
          setForm({
            name: station.name || '',
            address: station.address || '',
            city: station.city || '',
            state: station.state || '',
            pincode: station.pincode || '',
            latitude: station.latitude?.toString() || '',
            longitude: station.longitude?.toString() || '',
            status: station.status || 'pending',
            chargerTypes: station.chargerTypes?.length > 0
              ? station.chargerTypes.map((ct) => ({
                  type: ct.type || ct.name || '',
                  count: ct.count || 1,
                  power: ct.power || '50kW',
                }))
              : [{ type: 'CCS2', count: 1, power: '50kW' }],
            amenities: station.amenities || [],
            photos: station.photos || [],
            openingTime: station.openingTime || '00:00',
            closingTime: station.closingTime || '23:59',
            contactPhone: station.contactPhone || '',
            contactEmail: station.contactEmail || '',
            pricePerKwh: station.pricePerKwh?.toString() || '',
          });
        } catch {
          setSnackbar({ open: true, message: 'Failed to load station', severity: 'error' });
        } finally {
          setLoading(false);
        }
      };
      fetchStation();
    }
  }, [id, isNew]);

  const handleChange = (field) => (e) => setForm({ ...form, [field]: e.target.value });

  const addCharger = () => {
    setForm({ ...form, chargerTypes: [...form.chargerTypes, { type: 'CCS2', count: 1, power: '50kW' }] });
  };

  const removeCharger = (idx) => {
    setForm({ ...form, chargerTypes: form.chargerTypes.filter((_, i) => i !== idx) });
  };

  const updateCharger = (idx, field, value) => {
    const updated = [...form.chargerTypes];
    updated[idx] = { ...updated[idx], [field]: value };
    setForm({ ...form, chargerTypes: updated });
  };

  const addAmenity = (amenity) => {
    if (!form.amenities.includes(amenity)) {
      setForm({ ...form, amenities: [...form.amenities, amenity] });
    }
  };

  const removeAmenity = (amenity) => {
    setForm({ ...form, amenities: form.amenities.filter((a) => a !== amenity) });
  };

  const handlePhotoUpload = async (e) => {
    const file = e.target.files[0];
    if (!file || isNew) return;
    const formData = new FormData();
    formData.append('photo', file);
    try {
      const { data } = await stationsAPI.uploadPhoto(id, formData);
      setForm({ ...form, photos: [...form.photos, data.photo || data] });
      setSnackbar({ open: true, message: 'Photo uploaded', severity: 'success' });
    } catch {
      setSnackbar({ open: true, message: 'Upload failed', severity: 'error' });
    }
  };

  const handleDeletePhoto = async (photoId) => {
    try {
      await stationsAPI.deletePhoto(id, photoId);
      setForm({ ...form, photos: form.photos.filter((p) => p.id !== photoId) });
    } catch {
      setSnackbar({ open: true, message: 'Failed to delete photo', severity: 'error' });
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        ...form,
        latitude: parseFloat(form.latitude) || null,
        longitude: parseFloat(form.longitude) || null,
        pricePerKwh: parseFloat(form.pricePerKwh) || null,
      };
      if (isNew) {
        await stationsAPI.create(payload);
        setSnackbar({ open: true, message: 'Station created', severity: 'success' });
      } else {
        await stationsAPI.update(id, payload);
        setSnackbar({ open: true, message: 'Station updated', severity: 'success' });
      }
      setTimeout(() => navigate('/stations'), 1000);
    } catch {
      setSnackbar({ open: true, message: 'Failed to save station', severity: 'error' });
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 3 }}>
        <IconButton onClick={() => navigate('/stations')}>
          <ArrowBackIcon />
        </IconButton>
        <Typography variant="h5" sx={{ fontWeight: 700, color: '#1a1a2e' }}>
          {isNew ? 'Add Station' : 'Edit Station'}
        </Typography>
        {!isNew && <StatusBadge status={form.status} size="medium" />}
      </Box>

      <Box component="form" onSubmit={handleSubmit}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={8}>
            <Paper sx={{ p: 3, borderRadius: 3, mb: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Basic Information</Typography>
              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <TextField fullWidth label="Station Name" value={form.name} onChange={handleChange('name')} required InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={12}>
                  <TextField fullWidth label="Address" value={form.address} onChange={handleChange('address')} required multiline rows={2} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={4}>
                  <TextField fullWidth label="City" value={form.city} onChange={handleChange('city')} required InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={4}>
                  <TextField fullWidth label="State" value={form.state} onChange={handleChange('state')} required InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={4}>
                  <TextField fullWidth label="Pincode" value={form.pincode} onChange={handleChange('pincode')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={6}>
                  <TextField fullWidth label="Latitude" type="number" value={form.latitude} onChange={handleChange('latitude')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={6}>
                  <TextField fullWidth label="Longitude" type="number" value={form.longitude} onChange={handleChange('longitude')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                {!isNew && (
                  <Grid item xs={12}>
                    <TextField select fullWidth label="Status" value={form.status} onChange={handleChange('status')} InputProps={{ sx: { borderRadius: 2 } }}>
                      <MenuItem value="active">Active</MenuItem>
                      <MenuItem value="inactive">Inactive</MenuItem>
                      <MenuItem value="maintenance">Maintenance</MenuItem>
                      <MenuItem value="pending">Pending</MenuItem>
                    </TextField>
                  </Grid>
                )}
              </Grid>
            </Paper>

            <Paper sx={{ p: 3, borderRadius: 3, mb: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="h6" sx={{ fontWeight: 600 }}>Charger Types</Typography>
                <Button size="small" startIcon={<AddIcon />} onClick={addCharger}>Add Charger</Button>
              </Box>
              {form.chargerTypes.map((ct, idx) => (
                <Box key={idx} sx={{ display: 'flex', gap: 1.5, mb: 1.5, alignItems: 'center' }}>
                  <TextField
                    select
                    size="small"
                    value={ct.type}
                    onChange={(e) => updateCharger(idx, 'type', e.target.value)}
                    sx={{ minWidth: 180 }}
                    InputProps={{ sx: { borderRadius: 2 } }}
                  >
                    {CHARGER_TYPES.map((t) => (
                      <MenuItem key={t} value={t}>{t}</MenuItem>
                    ))}
                  </TextField>
                  <TextField
                    size="small"
                    type="number"
                    label="Count"
                    value={ct.count}
                    onChange={(e) => updateCharger(idx, 'count', parseInt(e.target.value) || 1)}
                    sx={{ minWidth: 80 }}
                    InputProps={{ sx: { borderRadius: 2 } }}
                  />
                  <TextField
                    size="small"
                    label="Power"
                    value={ct.power}
                    onChange={(e) => updateCharger(idx, 'power', e.target.value)}
                    sx={{ minWidth: 100 }}
                    InputProps={{ sx: { borderRadius: 2 } }}
                  />
                  <IconButton color="error" onClick={() => removeCharger(idx)}>
                    <DeleteIcon />
                  </IconButton>
                </Box>
              ))}
            </Paper>

            <Paper sx={{ p: 3, borderRadius: 3, mb: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Amenities</Typography>
              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mb: 2 }}>
                {form.amenities.map((amenity) => (
                  <Chip
                    key={amenity}
                    label={amenity}
                    onDelete={() => removeAmenity(amenity)}
                    color="primary"
                    variant="outlined"
                  />
                ))}
              </Box>
              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                {COMMON_AMENITIES.filter((a) => !form.amenities.includes(a)).map((amenity) => (
                  <Chip
                    key={amenity}
                    label={`+ ${amenity}`}
                    onClick={() => addAmenity(amenity)}
                    variant="outlined"
                    size="small"
                    sx={{ cursor: 'pointer', '&:hover': { borderColor: '#4caf50', color: '#4caf50' } }}
                  />
                ))}
              </Box>
            </Paper>

            {!isNew && (
              <Paper sx={{ p: 3, borderRadius: 3, mb: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Photos</Typography>
                <Grid container spacing={2}>
                  {form.photos.map((photo) => (
                    <Grid item xs={6} sm={4} md={3} key={photo.id}>
                      <Card sx={{ borderRadius: 2 }}>
                        <CardMedia
                          component="img"
                          height={120}
                          image={photo.url}
                          alt="Station"
                        />
                        <CardActions sx={{ justifyContent: 'center', p: 1 }}>
                          <IconButton size="small" color="error" onClick={() => handleDeletePhoto(photo.id)}>
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        </CardActions>
                      </Card>
                    </Grid>
                  ))}
                  <Grid item xs={6} sm={4} md={3}>
                    <Button
                      variant="outlined"
                      component="label"
                      sx={{ width: '100%', height: 120, borderRadius: 2, borderStyle: 'dashed' }}
                    >
                      <CloudUploadIcon sx={{ fontSize: 32, color: '#999' }} />
                      <input type="file" hidden accept="image/*" onChange={handlePhotoUpload} />
                    </Button>
                  </Grid>
                </Grid>
              </Paper>
            )}
          </Grid>

          <Grid item xs={12} md={4}>
            <Paper sx={{ p: 3, borderRadius: 3, mb: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
              <Typography variant="h6" sx={{ fontWeight: 600, mb: 2 }}>Contact & Hours</Typography>
              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <TextField fullWidth label="Phone" value={form.contactPhone} onChange={handleChange('contactPhone')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={12}>
                  <TextField fullWidth label="Email" type="email" value={form.contactEmail} onChange={handleChange('contactEmail')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={6}>
                  <TextField fullWidth label="Opens" type="time" value={form.openingTime} onChange={handleChange('openingTime')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={6}>
                  <TextField fullWidth label="Closes" type="time" value={form.closingTime} onChange={handleChange('closingTime')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
                <Grid item xs={12}>
                  <TextField fullWidth label="Price per kWh (₹)" type="number" value={form.pricePerKwh} onChange={handleChange('pricePerKwh')} InputProps={{ sx: { borderRadius: 2 } }} />
                </Grid>
              </Grid>
            </Paper>

            <Box sx={{ display: 'flex', gap: 2 }}>
              <Button
                variant="outlined"
                fullWidth
                onClick={() => navigate('/stations')}
                sx={{ borderRadius: 2, py: 1.5 }}
              >
                Cancel
              </Button>
              <Button
                type="submit"
                variant="contained"
                fullWidth
                disabled={saving}
                sx={{ borderRadius: 2, py: 1.5, bgcolor: '#1b5e20', '&:hover': { bgcolor: '#145214' } }}
              >
                {saving ? 'Saving...' : isNew ? 'Create Station' : 'Save Changes'}
              </Button>
            </Box>
          </Grid>
        </Grid>
      </Box>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={4000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity} sx={{ borderRadius: 2 }}>{snackbar.message}</Alert>
      </Snackbar>
    </Box>
  );
}
