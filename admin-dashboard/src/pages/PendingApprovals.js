import React, { useState, useEffect, useCallback } from 'react';
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  IconButton,
  Skeleton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Snackbar,
  Alert,
  Chip,
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import VisibilityIcon from '@mui/icons-material/Visibility';
import { stationsAPI } from '../services/api';
import StatusBadge from '../components/StatusBadge';

export default function PendingApprovals() {
  const [stations, setStations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null);
  const [rejectDialog, setRejectDialog] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  const fetchPending = useCallback(async () => {
    setLoading(true);
    try {
      const { data } = await stationsAPI.getAll({ status: 'pending', limit: 100 });
      setStations(data.stations || data.data || []);
    } catch {
      setStations([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchPending(); }, [fetchPending]);

  const handleApprove = async (id) => {
    try {
      await stationsAPI.approve(id);
      setSnackbar({ open: true, message: 'Station approved', severity: 'success' });
      fetchPending();
    } catch {
      setSnackbar({ open: true, message: 'Failed to approve', severity: 'error' });
    }
  };

  const handleReject = async () => {
    if (!selected) return;
    try {
      await stationsAPI.reject(selected.id, rejectReason);
      setSnackbar({ open: true, message: 'Station rejected', severity: 'success' });
      setRejectDialog(false);
      setSelected(null);
      setRejectReason('');
      fetchPending();
    } catch {
      setSnackbar({ open: true, message: 'Failed to reject', severity: 'error' });
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3, color: '#1a1a2e' }}>
        Pending Approvals
      </Typography>

      <Paper sx={{ borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell sx={{ fontWeight: 600 }}>Station Name</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Owner</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>City</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Submitted</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600, textAlign: 'right' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading
                ? Array.from({ length: 4 }).map((_, i) => (
                    <TableRow key={i}>
                      {[1, 2, 3, 4, 5, 6].map((j) => (
                        <TableCell key={j}><Skeleton variant="text" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                : stations.length === 0
                ? (
                    <TableRow>
                      <TableCell colSpan={6} align="center" sx={{ py: 6 }}>
                        <Typography variant="body1" color="text.secondary" sx={{ mb: 1 }}>
                          No pending approvals
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          All stations have been reviewed.
                        </Typography>
                      </TableCell>
                    </TableRow>
                  )
                : stations.map((station) => (
                    <TableRow key={station.id} hover>
                      <TableCell>
                        <Typography variant="body2" sx={{ fontWeight: 600 }}>{station.name}</Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">{station.owner?.name || station.ownerName || 'N/A'}</Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">{station.city}</Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" color="text.secondary">
                          {station.createdAt ? new Date(station.createdAt).toLocaleDateString() : 'N/A'}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <StatusBadge status="pending" />
                      </TableCell>
                      <TableCell align="right">
                        <IconButton size="small" onClick={() => setSelected(station)}>
                          <VisibilityIcon fontSize="small" />
                        </IconButton>
                        <IconButton size="small" color="success" onClick={() => handleApprove(station.id)}>
                          <CheckCircleIcon fontSize="small" />
                        </IconButton>
                        <IconButton size="small" color="error" onClick={() => { setSelected(station); setRejectDialog(true); }}>
                          <CancelIcon fontSize="small" />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      <Dialog open={Boolean(selected && !rejectDialog)} onClose={() => setSelected(null)} maxWidth="sm" fullWidth>
        <DialogTitle>{selected?.name}</DialogTitle>
        <DialogContent dividers>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
            <Box><Typography variant="caption" color="text.secondary">Address</Typography><Typography variant="body2">{selected?.address}</Typography></Box>
            <Box><Typography variant="caption" color="text.secondary">City / State</Typography><Typography variant="body2">{selected?.city}, {selected?.state}</Typography></Box>
            <Box><Typography variant="caption" color="text.secondary">Charger Types</Typography>
              <Box sx={{ display: 'flex', gap: 0.5, mt: 0.5 }}>
                {(selected?.chargerTypes || selected?.chargers || []).map((ct, i) => (
                  <Chip key={i} label={`${ct.type || ct.name} (x${ct.count || 1})`} size="small" variant="outlined" />
                ))}
              </Box>
            </Box>
            <Box><Typography variant="caption" color="text.secondary">Amenities</Typography>
              <Box sx={{ display: 'flex', gap: 0.5, mt: 0.5 }}>
                {(selected?.amenities || []).map((a, i) => (
                  <Chip key={i} label={a} size="small" />
                ))}
              </Box>
            </Box>
            <Box><Typography variant="caption" color="text.secondary">Contact</Typography><Typography variant="body2">{selected?.contactPhone || 'N/A'} | {selected?.contactEmail || 'N/A'}</Typography></Box>
            <Box><Typography variant="caption" color="text.secondary">Coordinates</Typography><Typography variant="body2">{selected?.latitude}, {selected?.longitude}</Typography></Box>
          </Box>
        </DialogContent>
        <DialogActions sx={{ p: 2, gap: 1 }}>
          <Button onClick={() => setSelected(null)}>Close</Button>
          <Button variant="contained" color="success" onClick={() => { handleApprove(selected.id); setSelected(null); }}>
            Approve
          </Button>
          <Button variant="contained" color="error" onClick={() => setRejectDialog(true)}>
            Reject
          </Button>
        </DialogActions>
      </Dialog>

      <Dialog open={rejectDialog} onClose={() => { setRejectDialog(false); setRejectReason(''); }}>
        <DialogTitle>Reject Station</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            multiline
            rows={3}
            fullWidth
            label="Rejection Reason"
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
            sx={{ mt: 1 }}
            InputProps={{ sx: { borderRadius: 2 } }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => { setRejectDialog(false); setRejectReason(''); }}>Cancel</Button>
          <Button onClick={handleReject} color="error" variant="contained">Reject</Button>
        </DialogActions>
      </Dialog>

      <Snackbar open={snackbar.open} autoHideDuration={4000} onClose={() => setSnackbar({ ...snackbar, open: false })}>
        <Alert severity={snackbar.severity} sx={{ borderRadius: 2 }}>{snackbar.message}</Alert>
      </Snackbar>
    </Box>
  );
}
