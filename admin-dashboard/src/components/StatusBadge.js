import React from 'react';
import Chip from '@mui/material/Chip';

const statusConfig = {
  active: { label: 'Active', color: 'success' },
  inactive: { label: 'Inactive', color: 'default' },
  maintenance: { label: 'Maintenance', color: 'warning' },
  pending: { label: 'Pending', color: 'info' },
  approved: { label: 'Approved', color: 'success' },
  rejected: { label: 'Rejected', color: 'error' },
  flagged: { label: 'Flagged', color: 'error' },
  resolved: { label: 'Resolved', color: 'success' },
  open: { label: 'Open', color: 'warning' },
};

export default function StatusBadge({ status, size = 'small' }) {
  const config = statusConfig[status] || { label: status, color: 'default' };

  return (
    <Chip
      label={config.label}
      color={config.color}
      size={size}
      sx={{
        fontWeight: 500,
        textTransform: 'capitalize',
        borderRadius: '8px',
      }}
    />
  );
}
