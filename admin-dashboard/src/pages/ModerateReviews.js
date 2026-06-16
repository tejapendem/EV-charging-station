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
  TablePagination,
  IconButton,
  Skeleton,
  Snackbar,
  Alert,
  Chip,
  Tooltip,
  Menu,
  MenuItem,
  Avatar,
  Rating,
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import FlagIcon from '@mui/icons-material/Flag';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import { reviewsAPI } from '../services/api';
import StatusBadge from '../components/StatusBadge';

export default function ModerateReviews() {
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [total, setTotal] = useState(0);
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedReview, setSelectedReview] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  const fetchReviews = useCallback(async () => {
    setLoading(true);
    try {
      const { data } = await reviewsAPI.getAll({ page: page + 1, limit: rowsPerPage });
      setReviews(data.reviews || data.data || []);
      setTotal(data.total || data.pagination?.total || 0);
    } catch {
      setReviews([]);
      setTotal(0);
    } finally {
      setLoading(false);
    }
  }, [page, rowsPerPage]);

  useEffect(() => { fetchReviews(); }, [fetchReviews]);

  const handleFlag = async (id) => {
    try {
      await reviewsAPI.flag(id);
      setSnackbar({ open: true, message: 'Review flagged', severity: 'success' });
      fetchReviews();
    } catch {
      setSnackbar({ open: true, message: 'Failed to flag', severity: 'error' });
    }
  };

  const handleUnflag = async (id) => {
    try {
      await reviewsAPI.unflag(id);
      setSnackbar({ open: true, message: 'Review un-flagged', severity: 'success' });
      fetchReviews();
    } catch {
      setSnackbar({ open: true, message: 'Failed to un-flag', severity: 'error' });
    }
  };

  const handleDelete = async () => {
    if (!selectedReview) return;
    try {
      await reviewsAPI.delete(selectedReview.id);
      setSnackbar({ open: true, message: 'Review deleted', severity: 'success' });
      setAnchorEl(null);
      fetchReviews();
    } catch {
      setSnackbar({ open: true, message: 'Failed to delete', severity: 'error' });
    }
  };

  const handleModerate = async (action) => {
    if (!selectedReview) return;
    try {
      await reviewsAPI.moderate(selectedReview.id, action);
      setSnackbar({ open: true, message: `Review ${action}ed`, severity: 'success' });
      setAnchorEl(null);
      fetchReviews();
    } catch {
      setSnackbar({ open: true, message: 'Failed to moderate', severity: 'error' });
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3, color: '#1a1a2e' }}>
        Moderate Reviews
      </Typography>

      <Paper sx={{ borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell sx={{ fontWeight: 600 }}>User</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Station</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Rating</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Review</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Date</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Status</TableCell>
                <TableCell sx={{ fontWeight: 600, textAlign: 'right' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading
                ? Array.from({ length: 5 }).map((_, i) => (
                    <TableRow key={i}>
                      {[1, 2, 3, 4, 5, 6, 7].map((j) => (
                        <TableCell key={j}><Skeleton variant="text" /></TableCell>
                      ))}
                    </TableRow>
                  ))
                : reviews.length === 0
                ? (
                    <TableRow>
                      <TableCell colSpan={7} align="center" sx={{ py: 4 }}>
                        <Typography color="text.secondary">No reviews found</Typography>
                      </TableCell>
                    </TableRow>
                  )
                : reviews.map((review) => (
                    <TableRow key={review.id} hover>
                      <TableCell>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Avatar sx={{ width: 28, height: 28, fontSize: 12 }}>
                            {(review.user?.name || review.userName || 'U')[0]}
                          </Avatar>
                          <Typography variant="body2">{review.user?.name || review.userName || 'Anonymous'}</Typography>
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">{review.station?.name || review.stationName || 'N/A'}</Typography>
                      </TableCell>
                      <TableCell>
                        <Rating value={review.rating} readOnly size="small" />
                      </TableCell>
                      <TableCell>
                        <Typography
                          variant="body2"
                          color="text.secondary"
                          sx={{
                            maxWidth: 250,
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                        >
                          {review.comment || review.text || ''}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" color="text.secondary">
                          {review.createdAt ? new Date(review.createdAt).toLocaleDateString() : 'N/A'}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        {review.flagged ? <StatusBadge status="flagged" /> : <Chip label="OK" size="small" color="default" />}
                      </TableCell>
                      <TableCell align="right">
                        {review.flagged ? (
                          <Tooltip title="Un-flag">
                            <IconButton size="small" color="warning" onClick={() => handleUnflag(review.id)}>
                              <FlagIcon fontSize="small" />
                            </IconButton>
                          </Tooltip>
                        ) : (
                          <Tooltip title="Flag">
                            <IconButton size="small" onClick={() => handleFlag(review.id)}>
                              <FlagIcon fontSize="small" />
                            </IconButton>
                          </Tooltip>
                        )}
                        <Tooltip title="Delete">
                          <IconButton size="small" color="error" onClick={() => { setSelectedReview(review); handleDelete(); }}>
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        </Tooltip>
                        <IconButton
                          size="small"
                          onClick={(e) => { setAnchorEl(e.currentTarget); setSelectedReview(review); }}
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
        <MenuItem onClick={() => { handleModerate('approve'); }}>Approve</MenuItem>
        <MenuItem onClick={() => { handleModerate('reject'); }}>Reject</MenuItem>
        <MenuItem onClick={() => { handleFlag(selectedReview?.id); setAnchorEl(null); }} sx={{ color: 'warning.main' }}>Flag</MenuItem>
      </Menu>

      <Snackbar open={snackbar.open} autoHideDuration={4000} onClose={() => setSnackbar({ ...snackbar, open: false })}>
        <Alert severity={snackbar.severity} sx={{ borderRadius: 2 }}>{snackbar.message}</Alert>
      </Snackbar>
    </Box>
  );
}
