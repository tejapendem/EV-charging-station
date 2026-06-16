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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import VisibilityIcon from '@mui/icons-material/Visibility';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import FlagIcon from '@mui/icons-material/Flag';
import BugReportIcon from '@mui/icons-material/BugReport';
import SpamIcon from '@mui/icons-material/Report';
import ErrorIcon from '@mui/icons-material/Error';
import { reportsAPI } from '../services/api';
import StatusBadge from '../components/StatusBadge';

const reportTypeConfig = {
  spam: { label: 'Spam', icon: <SpamIcon fontSize="small" />, color: '#ff9800' },
  inappropriate: { label: 'Inappropriate', icon: <FlagIcon fontSize="small" />, color: '#f44336' },
  bug: { label: 'Bug', icon: <BugReportIcon fontSize="small" />, color: '#9c27b0' },
  other: { label: 'Other', icon: <ErrorIcon fontSize="small" />, color: '#2196f3' },
};

export default function Reports() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [total, setTotal] = useState(0);
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedReport, setSelectedReport] = useState(null);
  const [viewDialog, setViewDialog] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  const fetchReports = useCallback(async () => {
    setLoading(true);
    try {
      const { data } = await reportsAPI.getAll({ page: page + 1, limit: rowsPerPage });
      setReports(data.reports || data.data || []);
      setTotal(data.total || data.pagination?.total || 0);
    } catch {
      setReports([]);
      setTotal(0);
    } finally {
      setLoading(false);
    }
  }, [page, rowsPerPage]);

  useEffect(() => { fetchReports(); }, [fetchReports]);

  const handleResolve = async (id) => {
    try {
      await reportsAPI.resolve(id);
      setSnackbar({ open: true, message: 'Report marked as resolved', severity: 'success' });
      fetchReports();
    } catch {
      setSnackbar({ open: true, message: 'Failed to resolve report', severity: 'error' });
    }
  };

  const handleDismiss = async (id) => {
    try {
      await reportsAPI.dismiss(id);
      setSnackbar({ open: true, message: 'Report dismissed', severity: 'success' });
      fetchReports();
    } catch {
      setSnackbar({ open: true, message: 'Failed to dismiss report', severity: 'error' });
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h5" sx={{ fontWeight: 700, mb: 3, color: '#1a1a2e' }}>
        Reports
      </Typography>

      <Paper sx={{ borderRadius: 3, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell sx={{ fontWeight: 600 }}>Type</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Reporter</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Target</TableCell>
                <TableCell sx={{ fontWeight: 600 }}>Description</TableCell>
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
                : reports.length === 0
                ? (
                    <TableRow>
                      <TableCell colSpan={7} align="center" sx={{ py: 4 }}>
                        <Typography color="text.secondary">No reports found</Typography>
                      </TableCell>
                    </TableRow>
                  )
                : reports.map((report) => {
                    const config = reportTypeConfig[report.type] || reportTypeConfig.other;
                    return (
                      <TableRow key={report.id} hover>
                        <TableCell>
                          <Chip
                            icon={config.icon}
                            label={config.label}
                            size="small"
                            sx={{
                              bgcolor: `${config.color}18`,
                              color: config.color,
                              fontWeight: 500,
                            }}
                          />
                        </TableCell>
                        <TableCell>
                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <Avatar sx={{ width: 28, height: 28, fontSize: 12, bgcolor: '#1b5e20' }}>
                              {(report.reporter?.name || report.reporterName || 'U')[0]}
                            </Avatar>
                            <Typography variant="body2">{report.reporter?.name || report.reporterName || 'Anonymous'}</Typography>
                          </Box>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2">{report.targetType || 'station'} #{report.targetId}</Typography>
                        </TableCell>
                        <TableCell>
                          <Typography
                            variant="body2"
                            color="text.secondary"
                            sx={{
                              maxWidth: 220,
                              overflow: 'hidden',
                              textOverflow: 'ellipsis',
                              whiteSpace: 'nowrap',
                            }}
                          >
                            {report.description || report.reason || ''}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" color="text.secondary">
                            {report.createdAt ? new Date(report.createdAt).toLocaleDateString() : 'N/A'}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <StatusBadge status={report.status || 'open'} />
                        </TableCell>
                        <TableCell align="right">
                          <Tooltip title="View Details">
                            <IconButton size="small" onClick={() => setViewDialog(report)}>
                              <VisibilityIcon fontSize="small" />
                            </IconButton>
                          </Tooltip>
                          {report.status !== 'resolved' && (
                            <Tooltip title="Mark Resolved">
                              <IconButton size="small" color="success" onClick={() => handleResolve(report.id)}>
                                <CheckCircleIcon fontSize="small" />
                              </IconButton>
                            </Tooltip>
                          )}
                          <IconButton
                            size="small"
                            onClick={(e) => { setAnchorEl(e.currentTarget); setSelectedReport(report); }}
                          >
                            <MoreVertIcon fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    );
                  })}
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
        <MenuItem onClick={() => { handleResolve(selectedReport?.id); setAnchorEl(null); }}>Mark Resolved</MenuItem>
        <MenuItem onClick={() => { handleDismiss(selectedReport?.id); setAnchorEl(null); }}>Dismiss</MenuItem>
      </Menu>

      <Dialog open={Boolean(viewDialog)} onClose={() => setViewDialog(null)} maxWidth="sm" fullWidth>
        <DialogTitle>Report Details</DialogTitle>
        <DialogContent dividers>
          {viewDialog && (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <Box>
                <Typography variant="caption" color="text.secondary">Type</Typography>
                <Box sx={{ mt: 0.5 }}>
                  <Chip
                    icon={reportTypeConfig[viewDialog.type]?.icon}
                    label={reportTypeConfig[viewDialog.type]?.label || viewDialog.type}
                    size="small"
                    sx={{
                      bgcolor: `${(reportTypeConfig[viewDialog.type] || reportTypeConfig.other).color}18`,
                      color: (reportTypeConfig[viewDialog.type] || reportTypeConfig.other).color,
                    }}
                  />
                </Box>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Reported by</Typography>
                <Typography variant="body2">{viewDialog.reporter?.name || viewDialog.reporterName || 'Anonymous'}</Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Target</Typography>
                <Typography variant="body2">{viewDialog.targetType || 'Station'} #{viewDialog.targetId}</Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Description</Typography>
                <Typography variant="body2">{viewDialog.description || viewDialog.reason || 'No description provided'}</Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Status</Typography>
                <Box sx={{ mt: 0.5 }}><StatusBadge status={viewDialog.status || 'open'} /></Box>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Submitted on</Typography>
                <Typography variant="body2">{viewDialog.createdAt ? new Date(viewDialog.createdAt).toLocaleString() : 'N/A'}</Typography>
              </Box>
            </Box>
          )}
        </DialogContent>
        <DialogActions sx={{ p: 2, gap: 1 }}>
          <Button onClick={() => setViewDialog(null)}>Close</Button>
          {viewDialog?.status !== 'resolved' && (
            <>
              <Button variant="contained" color="success" onClick={() => { handleResolve(viewDialog.id); setViewDialog(null); }}>
                Mark Resolved
              </Button>
              <Button variant="outlined" onClick={() => { handleDismiss(viewDialog.id); setViewDialog(null); }}>
                Dismiss
              </Button>
            </>
          )}
        </DialogActions>
      </Dialog>

      <Snackbar open={snackbar.open} autoHideDuration={4000} onClose={() => setSnackbar({ ...snackbar, open: false })}>
        <Alert severity={snackbar.severity} sx={{ borderRadius: 2 }}>{snackbar.message}</Alert>
      </Snackbar>
    </Box>
  );
}
