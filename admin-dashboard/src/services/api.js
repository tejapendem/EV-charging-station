import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:5000/api',
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: (data) => api.post('/auth/admin/login', data),
  me: () => api.get('/auth/admin/me'),
};

export const stationsAPI = {
  getAll: (params) => api.get('/stations', { params }),
  getById: (id) => api.get(`/stations/${id}`),
  create: (data) => api.post('/stations', data),
  update: (id, data) => api.put(`/stations/${id}`, data),
  delete: (id) => api.delete(`/stations/${id}`),
  approve: (id) => api.put(`/stations/${id}/approve`),
  reject: (id, reason) => api.put(`/stations/${id}/reject`, { reason }),
  bulkDelete: (ids) => api.post('/stations/bulk-delete', { ids }),
  bulkApprove: (ids) => api.post('/stations/bulk-approve', { ids }),
  uploadPhoto: (id, formData) =>
    api.post(`/stations/${id}/photos`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }),
  deletePhoto: (stationId, photoId) =>
    api.delete(`/stations/${stationId}/photos/${photoId}`),
};

export const reviewsAPI = {
  getAll: (params) => api.get('/reviews', { params }),
  delete: (id) => api.delete(`/reviews/${id}`),
  flag: (id) => api.put(`/reviews/${id}/flag`),
  unflag: (id) => api.put(`/reviews/${id}/unflag`),
  moderate: (id, action) => api.put(`/reviews/${id}/moderate`, { action }),
};

export const reportsAPI = {
  getAll: (params) => api.get('/reports', { params }),
  resolve: (id) => api.put(`/reports/${id}/resolve`),
  dismiss: (id) => api.put(`/reports/${id}/dismiss`),
};

export const usersAPI = {
  getAll: (params) => api.get('/admin/users', { params }),
  getById: (id) => api.get(`/admin/users/${id}`),
  updateRole: (id, role) => api.put(`/admin/users/${id}/role`, { role }),
  deactivate: (id) => api.put(`/admin/users/${id}/deactivate`),
  activate: (id) => api.put(`/admin/users/${id}/activate`),
};

export const analyticsAPI = {
  getDashboard: () => api.get('/admin/analytics/dashboard'),
  getStationsTimeline: (period) =>
    api.get('/admin/analytics/stations-timeline', { params: { period } }),
  getUserGrowth: (period) =>
    api.get('/admin/analytics/user-growth', { params: { period } }),
  getChargerTypes: () => api.get('/admin/analytics/charger-types'),
};

export default api;
