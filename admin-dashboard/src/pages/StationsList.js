import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
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
  TablePagination,
  TextField,
  Button,
  IconButton,
  MenuItem,
  InputAdornment,
  Checkbox,
  Chip,
  Tooltip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
  Snackbar,
  Alert,
  Menu,
  Skeleton,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import AddIcon from '@mui/icons-material/Add';
import FilterListIcon from '@mui/icons-material/FilterList';
import { stationsAPI } from '../services/api';
import StatusBadge from '../components/StatusBadge';

export default function StationsList() {
  const navigate = useNavigate();
  const [stations, setStations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [total, setTotal] = useState(0);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [selected, setSelected] = useState([]);
  const [deleteDialog, setDeleteDialog] = useState(null);
  const [anchorEl, setAnchorEl] = useState(null);
  const [menuStation, setMenuStation] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  const fetchStations = useCallback(async () => {
    setLoading(true);
    try {
      const { data } = await stationsAPI.getAll({
        page: page + 1,
        limit: rowsPerPage,
        search: search || undefined,
        status: statusFilter || undefined,
      });
      setStations(data.stations || data.data || []);
      setTotal(data.total || data.pagination?.total || 0);
    } catch {
      setStations([]);
      setTotal(0);
    } finally {
      setLoading(false);
    }
  }, [page, rowsPerPage, search, statusFilter]);

  useEffect(() => {
    fetchStations();
  }, [fetchStations]);

  const handleBulkApprove = async () => {
    try {
      await stationsAPI.bulkApprove(selected);
      setSnackbar({ open: true, message: `${selected.length} stations approved`, severity: 'success' });
      setSelected([]);
      fetchStations();
    } catch {
      setSnackbar({ open: true, message: 'Failed to approve stations', severity: 'error' });
    }
  };

  const handleBulkDelete = async () => {
    try {
      await stationsAPI.bulkDelete(selected);
      setSnackbar({ open: true, message: `${selected.length} stations deleted`, severity: 'success' });
      setSelected([]);
      fetchStations();
    } catch {
      setSnackbar({ open: true, message: 'Failed to delete stations', severity: 'error' });
    }
  };

  const handleDelete = async () => {
    if (!deleteDialog) return;
    try {
      await stationsAPI.delete(deleteDialog);
      setSnackbar({ open: true, message: 'Station deleted', severity: 'success' });
      setDeleteDialog(null);
      fetchStations();
    } catch {
      setSnackbar({ open: true, message: 'Failed to delete station', severity: 'error' });
    }
  };

  const handleApprove = async (id) => {
    try {
      await stationsAPI.approve(id);
      setSnackbar({ open: true, message: 'Station approved', severity: 'success' });
      fetchStations();
    } catch {
      setSnackbar({ open: true, message: 'Failed to approve station', severity: 'error' });
    }
  };

  const isSelected = (id) => selected.indexOf(id) !== -1;

  const handleSelectAll = (checked) => {
    if (checked) {
      setSelected(stations.map((s) => s.id));
    } else {
      setSelected([]);
    }
  };

  const handleSelect = (id) => {
    const idx = selected.indexOf(id);
    if (idx === -1) {
      setSelected([...selected, id]);
    } else {
      setSelected(selected.filter((s) => s !== id));
    }
  };

  const totalPages = Math.ceil(total / rowsPerPage);

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h5" sx={{ fontWeight: 700, color: '#1a1a2e' }}>
          Stations
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/stations/new')}
          sx={{ borderRadius: 2, bgcolor: '#1b5e20', '&:hover': { bgcolor: '#145214' } }}
        >
          Add Station
        </Button>
      </Box>

      <Paper sx={{ borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)', mb: 3 }}>
        <Box sx={{ p: 2, display: 'flex', gap: 2, alignItems: 'center', flexWrap: 'wrap' }}>
          <TextField
            size="small"
            placeholder="Search stations..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(0); }}
            sx={{ minWidth: 280 }}
            InputProps={{
              sx: { borderRadius: 2 },
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon sx={{ color: '#999', fontSize: 20 }} />
                </InputAdornment>
              ),
            }}
          />
          <TextField
            select
            size="small"
            value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setPage(0); }}
            sx={{ minWidth: 150 }}
            InputProps={{ sx: { borderRadius: 2 } }}
          >
            <MenuItem value="">All Status</MenuItem>
            <MenuItem value="active">Active</MenuItem>
            <MenuItem value="inactive">Inactive</MenuItem>
            <MenuItem value="maintenance">Maintenance</MenuItem>
            <MenuItem value="pending">Pending</MenuItem>
          </TextField>
          <IconButton sx={{ border: '1px solid #e0e0e0', borderRadius: 2 }}>
            <FilterListIcon />
          </IconButton>
        </Box>

        {selected.length > 0 && (
          <Box sx={{ px: 2, pb: 2, display: 'flex', gap: 1, alignItems: 'center' }}>
            <Typography variant="body2" color="text.secondary" sx={{ mr: 1 }}>
              {selected.length} selected
            </Typography>
            <Button size="small" variant="outlined" color="success" onClick={handleBulkApprove}>
              Approve All
            </Button>
            <Button size="small" variant="outlined" color="error" onClick={handleBulkDelete}>
              Delete All
            </Button>
          </Box>
        )}

        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell padding="checkbox">
                  <Checkbox
                    indeterminate={selected.length > 0 && selected.length < stations.length}
                    checked={stations.length > 0 && selected.length === stations.length}
                    onChange={(e) => handleSelectAll(e.target.checked)}
                  />
                </TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Name</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Address</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Chargers</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Rating</TableCell>
                <TableCell sx={{ fontWeight: 600, textAlign: 'right' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading
                ? Array.from({ length: 5 }).map((_, i) => (
                    <TableRow key={i}>
                      <TableCell colSpan={7}>
                        <Skeleton variant="text" />
                      </TableCell>
                    </TableRow>
                  ))
                : stations.length === 0
                ? (
                    <TableRow>
                      <TableCell colSpan={7} align="center" sx={{ py: 4 }}>
                        <Typography color="text.secondary">No stations found</Typography>
                      </TableCell>
                    </TableRow>
                  )
                : stations.map((station) => (
                    <TableRow
                      key={station.id}
                      hover
                      selected={isSelected(station.id)}
                      sx={{ '&:last-child td': { borderBottom: 0 } }}
                    >
                      <TableCell padding="checkbox">
                        <Checkbox
                          checked={isSelected(station.id)}
                          onChange={() => handleSelect(station.id)}
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" sx={{ fontWeight: 600 }}>
                          {station.name}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" color="text.secondary" sx={{ maxWidth: 250, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                          {station.address}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
                          {(station.chargerTypes || station.chargers || []).slice(0, 2).map((ct, i) => (
                            <Chip key={i} label={ct.name || ct} size="small" variant="outlined" />
                          ))}
                          {(station.chargerTypes || station.chargers || []).length > 2 && (
                            <Chip label={`+${station.chargerTypes.length - 2}`} size="small" />
                          )}
                        </Box>
                      </TableCell>
                      <TableCell>
                        <StatusBadge status={station.status || 'pending'} />
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {station.rating ? `${station.rating.toFixed(1)} ⭐` : 'N/A'}
                        </Typography>
                      </TableCell>
                      <TableCell align="right">
                        <Tooltip title="Edit">
                          <IconButton size="small" onClick={() => navigate(`/stations/${station.id}/edit`)}>
                            <EditIcon fontSize="small" />
                          </IconButton>
                        </Tooltip>
                        {station.status === 'pending' && (
                          <Tooltip title="Approve">
                            <IconButton size="small" color="success" onClick={() => handleApprove(station.id)}>
                              <CheckCircleIcon fontSize="small" />
                            </IconButton>
                          </Tooltip>
                        )}
                        <Tooltip title="Delete">
                          <IconButton size="small" color="error" onClick={() => setDeleteDialog(station.id)}>
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        </Tooltip>
                        <IconButton
                          size="small"
                          onClick={(e) => { setAnchorEl(e.currentTarget); setMenuStation(station); }}
                        >
                          <MoreVertIcon fontSize="small" />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))}
            </TableBody>
          </Table>
        </TableContainer>

        <TablePagination
          component="div"
          count={total}
          page={page}
          onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
          rowsPerPageOptions={[10, 25, 50]}
        />
      </Paper>

      <Menu anchorEl={anchorEl} open={Boolean(anchorEl)} onClose={() => setAnchorEl(null)}>
        <MenuItem onClick={() => { navigate(`/stations/${menuStation?.id}/edit`); setAnchorEl(null); }}>
          Edit
        </MenuItem>
        <MenuItem onClick={() => { handleApprove(menuStation?.id); setAnchorEl(null); }}>
          Approve
        </MenuItem>
        <MenuItem onClick={() => { setDeleteDialog(menuStation?.id); setAnchorEl(null); }} sx={{ color: 'error.main' }}>
          Delete
        </MenuItem>
      </Menu>

      <Dialog open={Boolean(deleteDialog)} onClose={() => setDeleteDialog(null)}>
        <DialogTitle>Delete Station</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to delete this station? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialog(null)}>Cancel</Button>
          <Button onClick={handleDelete} color="error" variant="contained">Delete</Button>
        </DialogActions>
      </Dialog>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={4000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity} sx={{ borderRadius: 2 }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}
